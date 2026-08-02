function ctd_process(stns, varargin)
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
% if you want to run the complete set of steps from the start:
% ctd_process(stns, 'part1', 'clean_cut', 'part2', 'checkplots', 'sbe35', 'sum')
%   or you can leave out 'clean_cut' if running without a display / to
%   accept the default selections made automatically by mdcs_01 and the
%   automatic edits, or leave out 'sbe35' if those data are not available,
%   or leave out 'sum' to skip creating the station summary file etc.
%
% if you need to run preliminary steps first (e.g. to prepare data for
%   other users) and additional steps later:
% ctd_process(stns, 'part1')
%   to run only the steps necessary for processing mooring caldips based on
%   comparison with 1 Hz data
% OR
% ctd_process(stns, 'part1', 'for_ladcp')
%   to run only the steps necessary for processing LADCP data using the
%   LDEO IX software
% OR
% ctd_process(stns, 'part1', 'checkplots')
%   to run preliminary processing steps and compare two sensors' and up-
%   and downcast data at 1 Hz to help highlight any sensor problems
% AND THEN LATER
% ctd_process(stns, 'clean_cut', 'part2', 'sbe35', 'checkplots')
%   to continue through to the end of the processing (add 'sbe35' if
%   relevant) including plots comparing 2 dbar data as well as 1 Hz data
%
% after setting new calibration coefficients (using settings in
%   opt_cruise***) and/or edits for 24-Hz data (using settings in
%   opt_cruise*** or by running mctd_rawedit):
% ctd_process(stns, 'postedit')
%   will apply these changes to 24-Hz data and propagate them through
%   subsequent steps
%

m_common
stns = stns(:)'; %row vector needed to loop
steps = {'part1','part2','postedit','nisk_fir','reload_sns','for_ladcp','clean_cut','winch','sbe35','checkplots','out_ctdcolumns','out_samcolumns'};
if nargin==1
    warning('specify one or more steps from this list:')
    disp(steps)
    return
end

dostep = array2table(ismember(steps,varargin),'VariableNames',steps);
if ~dostep.for_ladcp && strcmp(MEXEC_G.datatypes.ladcp,'ix') && (dostep.part1 || dostep.postedit)
    %output 1 Hz data even if for_ladcp not set
    dostep.for_ladcp = true;
end
if dostep.part2 || dostep.postedit || dostep.nisk_fir || dostep.sbe35
    %have updated sam file, write to .csv if specified in opt_cruise
    dostep.out_samcolumns = true;
    if dostep.part2 || dostep.postedit
        %have updated 2db files, write to .csv if specified in opt_cruise
        dostep.out_ctdcolumns = true;
    end
end

opt1 = 'ctd_proc'; opt2 = 'cast_split_comb'; get_cropt
if dostep.part1
    for stn = stns
        %read in sbe .cnv data to mstar
        msbe_01_load(stn);
    end
end

if dostep.part1 || dostep.nisk_fir
    for stn = stns
        %read in sbe .bl file to mstar
        mfir_01_load(stn)
        if ismember(stn,comb_stns(:,1))
            %now it should have been 
            stns = setdiff(stns,stn);
            continue
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
    end
end

if dostep.part1 || dostep.postedit
    for stn = stns
        %apply corrections (e.g. oxygen hysteresis) and calibrations, as specified in opt_cruise
        msbe_02_edcal(stn)
        %average to 1 hz, compute salinity from C and T
        msbe_03_1hz(stn)
    end
end

if dostep.for_ladcp
    for stn = stns
        mout_1hzasc(stn) %output 1 hz data in ascii format (required for LDEO IX LADCP processing)
    end
end

if dostep.part1
    for stn = stns
        %autodetect cast start (after soak), bottom (max p), and end (last
        %before surface)
        mdcs_01_auto(stn)
    end
end

if dostep.clean_cut
    for stn = stns
        %call gui to check raw or cleaned data and check/select cast start, bottom, and end
        mctd_raw_show_check_edit(stn)
    end
end

%***rawedit?

if dostep.part2 || dostep.postedit
    %***check we already have the preliminary files?
    for stn = stns
        %average to 2 dbar
        mctd_04_profile(stn)
    end
end

if dostep.part2 || dostep.postedit || dostep.nisk_fir
    for stn = stns
        %bottle firing data into .fir file, if there is one
        mfir_04_addctd(stn)
        mfir_to_sam(stn)
    end
end
if dostep.part2
    %add serial numbers to sam_ file
    if dostep.reload_sns
        get_sensor_groups(stns,'restart','samonly')
    else
        get_sensor_groups(stns,'samonly')
    end
end

if dostep.checkplots
    for stn = stns
        mctd_checkplots
        pause
    end
end

if dostep.sbe35 %***move this to msam_load
    msbe35_01(max(stns)) %read sbe35 data for stations up to max(stns)
end

if dostep.part2 || dostep.postedit
    %calculate depths and other info for a range of stations
    station_summary(stns)
    for stn = stns
        %add max depths to various files
        depth_to_headers(stn)
    end
end

%output from ctd_*_2db and sam_*_all to csv files, if relevant and set in
%opt_cruise file
outc = 0; outs = 0;
if dostep.part2 || dostep.postedit
    outc = 1; outs = 1;
elseif dostep.nisk_fir || dostep.sbe35
    outs = 1;
end
if dostep.out_ctdcolumns || dostep.out_samcolumns
    opt1 = 'outputs'; opt2 = 'columndata'; get_cropt
end
if exist('outtypes','var')
    for ono = 1:length(outtypes)
        if exist('outparams','var') && isfield(outparams,outtypes{ono})
            if dostep.out_ctdcolumns
                mout_columns('ctd',outtypes{ono},outparams.(outtypes{ono}))
            end
            if dostep.out_samcolumns
                mout_columns('sam',outtypes{ono},outparams.(outtypes{ono}))
            end
        else
            if dostep.out_ctdcolumns
                mout_columns('ctd',outtypes{ono})
            end
            if dostep.out_samcolumns
                mout_columns('sam',outtypes{ono})
            end
        end
    end
end

%sync to shared drive***
opt1 = 'output'; opt2 = 'copyover'; get_cropt

