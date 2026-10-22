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
%     mctd_raw_show_check_edit), mctd_04_profile, mfir_04_addctd,
%     mfir_to_sam (and, if useGUI, mctd_checkplots***)
% as well as: 
%   'sbe35' to run msbe35_01 and msbe35_to_sam
%   'winch' to run mwin_01_load, mfir_02_addwin, mfir_to_sam 
% and: 
%   'outputs' to run ***
%   
% order of steps does not depend on their order as input arguments but will
%   be run in the logical order of propagation of information through the 
%   files, e.g.
% ctd_process(stns, 0, 'sbe35', 'load', 'average', 'edit')
%   runs
% msbe_01_load
% mfir_01_load
% msbe_02_edcal
% msbe_03_derive_tbin
% mdcs_01_auto
% mctd_04_profile
% mfir_04_addctd
% mfir_to_sam
% msbe35_01
% msbe35_to_sam
%
% if you want to run the complete set of steps from the start, including
%   graphical user interface data selection/editing functions: 
% ctd_process(stns, 1, 'load', 'edit', 'average', 'sbe35', 'winch')
% 
% if running without a display or to skip manual editing stages and accept
%   the default selections made by mdcs_01, set useGUI to 0 
% 
% a quick run through the preliminary steps (e.g. to prepare data for other
%   users, such as 1 Hz data for mooring caldip processing or LADCP
%   processing): 
% ctd_process(stns, 0, 'load', 'average', 'outputs') 
% should be followed at some point by
% ctd_process(stns, 1, 'edit', 'average', 'outputs') 
% for improved data
%
% after setting new calibration coefficients (using settings in
%   opt_cruise***) and/or edits for 24-Hz data (using settings in
%   opt_cruise*** or by running gui_editpoints)):
% ctd_process(stns, 0, 'edit', 'average', 'outputs')
%   will apply these changes and propagate them through the subsequent
%   steps
% ctd_process(stns, 1, 'edit')
%   allows you to check the results of new automatic or manual edits
%

m_common

%possible steps
allsteps = {'load','edit','average','sbe35','winch','outputs'};
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
if dostep.average && ~dostep.outputs
    warning('not running outputs step; averaged and sample data saved only as mstar .nc files')
end

stns = stns(:)'; %needs to be row vector for loop

if dostep.load
    stns_all = stns;
    for stn = stns
        %read in sbe .cnv data to mstar
        stns_split = msbe_01_load(stn);
        stns_all = union(stns_all, stns_split); %add new yo-yo station numbers (if any)
        mfir_01_load(stn) %***come back to this; edit msbe_to_mstar so mfir_01_load can also call it one or more times
        if exist('comb_stns','var') && ismember(comb_stns(:,1),stn)
            stns_all = setdiff(stns_all,stn);
        end
        stns = stns_all(:)';
    end
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
    end
    for stn = stns
        % in order to find cast start, bottom, and end
        mdcs_01_auto(stn)
    end
end

if useGUI && dostep.edit
    for stn = stns
        %call gui to check raw or cleaned data and check cast start, bottom, and end
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

if dostep.average
    if strcmp(MEXEC_G.datatypes.ladcp,'ix')
        %output 1 hz data
        for stn = stns
            mout_1hzasc(stn)
        end
    end
    for stn = stns
        %average to 2 dbar
        mctd_04_profile(stn)
    end
end

if dostep.edit || dostep.average
    for stn = stns
        %bottle firing data into .fir file, if there is one
        mfir_04_addctd(stn)
    end
end

if dostep.winch
    try
        %extract and add winch data
        mwin_01_load(stn);
        mfir_02_addwin(stn);
    catch me
        warning('could not get or add winch data for station %d',stn)
        warning(me.message)
    end
end

if dostep.sbe35
    msbe35_01(max(stns)) %read sbe35 data for stations up to max(stns)
end

if dostep.edit || dostep.average || dostep.winch || dostep.sbe35
    for stn = stns
        mfir_to_sam(stn)
    end
end

if dostep.part2
    %add serial numbers to sam_ file
    if dostep.reload_sns
        get_sensor_groups(stns,'restart')
    else
        get_sensor_groups(stns)
    end
end

if dostep.guisteps && (dostep.part2 || dostep.postedit)
    for stn = stns
        mctd_checkplots(stn,3)
        pause
    end
end


if dostep.part2 || dostep.postedit
    %calculate depths and other info for a range of stations
    station_summary(stns)
    for stn = stns
        %add max depths to various files
        depth_to_headers(stn)
    end
end

if dostep.output
    %output from ctd_*_2db and sam_*_all to csv files, if relevant and set in
    %opt_cruise file
    outc = 0; 
    if dostep.part2 || dostep.postedit
        outc = 1;
    end
    outs = 1;
    opt1 = 'outputs'; opt2 = 'columndata'; run(MEXEC_G.opt_cruise)
    if exist('outtypes','var')
        for ono = 1:length(outtypes)
            if exist('outparams','var') && isfield(outparams,outtypes{ono})
                if outc
                    mout_columns('ctd',outtypes{ono},outparams.(outtypes{ono}))
                end
                if outs
                    mout_columns('sam',outtypes{ono},outparams.(outtypes{ono}))
                end
            else
                if outc
                    mout_columns('ctd',outtypes{ono})
                end
                if outs
                    mout_columns('sam',outtypes{ono})
                end
            end
        end
    end

    %sync to shared drive***
    opt1 = 'output'; opt2 = 'copyover'; run(MEXEC_G.opt_cruise)

end
