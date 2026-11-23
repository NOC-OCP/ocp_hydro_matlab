function ctd_process(stns, useGUI, varargin)
% ctd_process(stns, useGUI, varargin)
%
% wrapper for scripts in ctd_steps to do some or all of the following:
%   load, convert, and average CTD data,
%   extract data at Niskin bottle firing times and put into sam_*_all file,
%   load SBE35 data,
%   output 1Hz data in a format suitable for LADCP processing using LDEO IX
%     software
%   make a set of plots comparing primary and secondary sensors, up- and
%     down-casts, T-S and T-O diagrams, useful to highlight sensor issues
%     and give a preliminary view of oxygen hysteresis
%
% varargin can include:
%   'load' to run msbe_01_load and mfir_01_load
%   'edit' to run msbe_02_edcal (and, if useGUI, mctd_raw_show_check_edit)
%   'average' to run msbe_03_derive_tbin, mdcs_01_auto (and, if useGUI,
%     mctd_raw_show_check_edit), mctd_04_profile, mfir_04_addctd (and, if
%     useGUI, mctd_checkplots)
%   'check' to run mctd_checkplots
%   'compile' to run mfir_to_sam, station_summary, depth_to_headers
%   'reformat' to run mout_columns
%
% order of steps does not depend on their order as input arguments but will
%   be run in the logical order of propagation of information through the
%   files, e.g.
% ctd_process(stns, 0, 'load', 'average', 'edit')
%   runs load then edit then average:
% msbe_01_load
% mfir_01_load
% msbe_02_edcal
% msbe_03_derive_tbin
% mdcs_01_auto
% mctd_04_profile
% mfir_04_addctd
%
% if you want to run the complete set of steps from the start, including
%   graphical user interface data selection/editing functions, compiling
%   data at Niskin firing times, and outputting processed data to column
%   formats:
% ctd_process(stns, 1, 'load', 'edit', 'average', 'check', 'compile', 'reformat')
%
% if running without a display or to skip manual editing stages and accept
%   the default selections made by mdcs_01, set useGUI to 0
%
% a quick run through the preliminary steps (e.g. to prepare data for other
%   users, such as 1 Hz data for mooring caldip processing or LADCP
%   processing):
% ctd_process(stns, 0, 'load', 'average', 'compile', 'reformat')
% should be followed at some point by
% ctd_process(stns, 1, 'edit', 'average', 'check', 'compile', 'reformat')
% for improved data
%
% after setting new calibration coefficients and/or edits for 24-Hz data
% (using settings in the opt_cruise file, or by manual editing in the gui):
% ctd_process(stns, 0, 'edit')
%  will apply these changes without rerunning the raw data editing gui
% ctd_process(stns, 1, 'average', 'check', 'compile', 'reformat')
%  will propagate them through the subsequent steps, and allow you to check
%  the resulting averaged data by running mctd_checkplots
%

m_common

%possible steps
allsteps = {'load','edit','average','profile','compile','check','reformat'};
if nargin<3
    warning('specify one or more steps from this list:')
    disp(allsteps)
    return
end
dostep = array2table(ismember(allsteps,varargin),'VariableNames',allsteps);
if dostep.edit && ~dostep.average
    warning('edits or calibrations will not be propagated to averaged files (including bottle sample files)')
    if ~useGUI
        dostep.average = strcmp(input('add averaging step? (y/n)   ','s'),'y');
    end
end
if dostep.average && ~dostep.compile
    warning('not adding data to compiled Niskin sample or station summary files')
end
if dostep.average && ~dostep.reformat
    warning('not running reformat step; averaged and sample data saved only as mstar .nc files')
end

stns = stns(:)'; %needs to be row vector for loop

if dostep.load
    stns_all = stns;
    for stn = stns
        %read in sbe .cnv data to mstar
        out = msbe_01_load(stn);
        if isfield(out,'split_stns')
            stns_all = union(stns_all, out.split_stns);
            %a yo-yo cast will at most have bottle data from the last cast
            mfir_01_load(out.split_stns(end))
        else
            mfir_01_load(stn)
        end
    end
    %subsequently, loop through stations including any yo-yos divided above
    stns = stns_all(:)';
end

if dostep.edit
    for stn = stns
        %apply corrections (e.g. oxygen hysteresis) and calibrations, as specified in opt_cruise
        msbe_02_edcal(stn)
        %average to 1 hz, compute salinity from C and T
    end
end

if dostep.average

    for stn = stns
        % do the quick (regular time binning) averages
        msbe_03_derive_tbin(stn)
        % in order to find cast start, bottom, and end
        mdcs_01_auto(stn)
    end

    if useGUI && dostep.edit
        for stn = stns
            %call gui to check raw or cleaned data and check cast start,
            %bottom, and end (also uses 1 hz data)
            ed = mctd_raw_show_check_edit(stn);
            if strcmp(ed,'y')
                %new edits to apply
                msbe_02_edcal(stn)
                if dostep.average
                    %and to propagate by re-running steps above
                    msbe_03_derive_tbin(stn)
                    mdcs_01_auto(stn)
                end
            end
        end
    end

    if strcmp(MEXEC_G.datatypes.ladcp,'ix')
        %output 1 hz CTD and lon, lat data for LADCP processing
        for stn = stns
            mout_1hzasc(stn)
        end
    end

    if dostep.compile
        %compile the 10s averaged data for all available stations
        msec_grid('quick')
    end

    if useGUI && dostep.check
        %plots with 1 hz and 10 s data
        mctd_checkplots(stn,3,'quick')
        disp('Press any key to continue...');
        pause
    end

end

if dostep.profile

    for stn = stns
        %make the down- and upcast pressure profiles (2 dbar grid)
        mctd_04_profile(stn)
    end

    if dostep.compile
        %create compiled (not gridded) file of all 2 dbar downcast data
        msec_grid('ungridded')
    end

    if useGUI && dostep.check
        for stn = stns
            %plots with 1 hz and 2 dbar data
            mctd_checkplots(stn,3)
            disp('Press any key to continue...');
            pause
        end
    end

end

if dostep.average || dostep.profile
    %bottle firing data into .fir file, if there is one (uses 1 hz and
    %2 dbar CTD data, if available)
    for stn = stns
        mfir_04_addctd(stn)
    end
end

if dostep.average && dostep.load && isfield(pfiles,'ctd_win')
    try
        %extract and add winch data (uses ctd 1 hz file)
        mwin_01_load(stn)
        mfir_02_addwin(stn)
    catch me
        warning('could not get or add winch data for station %d',stn)
        warning(me.message)
    end
end

if dostep.compile
    for stn = stns
        %add bottle firing data to appended Niskin sample file
        %(pfiles.samp_ctd)
        mfir_to_sam(stn)
    end
    %depth and Niskin stats for this set of stations
    station_summary(stns)
    for stn = stns
        %use the file created by station_summary to update water depth in
        %CTD processed file headers
        depth_to_headers(stn)
    end
end

if dostep.reformat
    %output from ctd_*_2db and sam_*_all to csv files, if relevant and set in
    %opt_cruise file
    opt1 = 'outputs'; opt2 = 'columndata'; run(MEXEC_G.opt_cruise)
    if exist('outtypes','var')
        for ono = 1:length(outtypes)
            if exist('outparams','var') && isfield(outparams,outtypes{ono})
                mout_columns('ctd',outtypes{ono},outparams.(outtypes{ono}))
                mout_columns('sam',outtypes{ono},outparams.(outtypes{ono}))
            else
                mout_columns('ctd',outtypes{ono})
                mout_columns('sam',outtypes{ono})
            end
        end
    end

    %sync to shared drive***
    opt1 = 'outputs'; opt2 = 'copyover'; run(MEXEC_G.opt_cruise)

end
