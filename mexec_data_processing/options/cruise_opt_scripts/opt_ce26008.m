% processing settings for cruise ce26008

% at the time this file was initialised, MEXEC_G included:
% datatypes.ctd: 'sbe'
% datatypes.tref: 'sbe35'
% datatypes.uway: 'scs'
% datatypes.sadcp: 'codas'
% datatypes.ladcp: 'ix'
% datatypes.moor: 'no'
% data_time_origin_string: '2026-01-01 00:00:00'
% mexec_version: '5ed81ad5 (last commit)'

%context notes:
% cast 1 and 48 aborted, converted from .hex but not processed
% cast 42 aborted, not converted from .hex
% cast 2 deep test cast, cast 3 shallow test dip with ***
% cast 71 and 72 yo-yos, no Niskins
% cast 25 CTD deck box restarted, CTD recorded in 025 and 025b
% cast 22 exported without time elapsed***
%
% record of Niskin samples collected in *** and of Niskin flags in ***
% record of underway samples collected in ***
%
% SUNA on *** casts

foundit = false; outofopts = false;
while ~foundit & ~outofopts

    switch opt1

        case 'test'
            foundit = true;
            if ~exist('MEXEC_G','var')
                fprintf(2,'running the cruise options file %s requires global MEXEC_G\n', mfilename)
            elseif ~strcmp(MEXEC_G.opt_cruise,[mfilename '.m'])
                fprintf(2,'this file (%s) is not the cruise options file set in MEXEC_G.opt_cruise (%s)\n',[mfilename '.m'], MEXEC_G.opt_cruise)
            else
                fprintf(1, 'the cruise options file %s has no syntax errors that prevent it from being called\n', mfilename)
            end

        case 'setup'
            switch opt2
                case 'mstar'
                    foundit = true;
                    %times in mstar files changed in 2024 to CF-compliant, and
                    %to using a constant base
                    %(MEXEC_G.MDEFAULT_DATA_TIME_ORIGIN) for every file on a
                    %cruise
                    if MEXEC_G.MDEFAULT_DATA_TIME_ORIGIN(1)>=2024
                        docf = 1; %units are cf-compliant and include the base, e.g. 'seconds since 2024-01-01 00:00:00'
                    else
                        docf = 0; %time base is given by h.data_time_origin (e.g. [2024 1 1 0 0 0]) and often differs from file to file, units are just e.g. 'seconds'
                    end
                case 'm_stn_string'
                    foundit = true;
                    %CTD station/cast naming convention
                    if ~exist('stn', 'var')
                        stn = input('type stn number ');
                    end
                    stn_string = sprintf('%03d',stn); %used for file names, default: 001, 002, etc.
                    if stn>70
                        stn_string = sprintf('%04.1f',stn); %yo-yos stn_string 071.1, 071.2***
                    end
                    stnlocal = stn;
            end

        case 'adcp_proc'
            %set input and output files, instrument names, parameters for
            %averaging sadcp data processed using CODAS or another system
            switch opt2
                case 'sadcp_files'
                    foundit = true;
                    infiles.sadcp_all = fullfile(MEXEC_G.data_root, 'vmadcp', 'postprocessing', upper(MEXEC_G.mcruise), 'proc_editing', inst, 'contour', [inst '_' MEXEC_G.mcruise '.nc']);
                    pfiles.sadcp_stnav = fullfile(MEXEC_G.data_root, 'vmadcp', 'mproc', [inst '_' MEXEC_G.mcruise '_%s_ave.nc']); %stn_string
                case 'sadcp_on_station'
                    foundit = true;
                    min_nvmadcpprf = 3;      %throws a warning if number of vmADCP profiles within an LADCP cast is less than this
                    min_nvmadcpbin = 3;      %masks depths with number of valid bins less than this
                    min_nvmadcpbin_refl = 3; %throws a warning if number of good profiles at any depth in the watertrack reference layer is less than this
            end
            %set input and output files and contraints for processing LADCP
            %data using e.g. LDEO IX toolbox
            switch opt2
                case 'ladcp_files'
                    foundit = true;
                    infiles.ladcp_raw = fullfile(MEXEC_G.data_root, 'ladcp', 'rawdata', '%s'); %stn_string
                    pfiles.forladcp_ctdnav = fullfile(MEXEC_G.data_root, 'ladcp', 'ctd', 'ctd.%s.02.asc'); %stn_string
                    if exist('inst','var')
                        pfiles.forladcp_sadcpav = fullfile(MEXEC_G.data_root, 'ladcp', 'sadcp', [inst '_' MEXEC_G.mcruise '_ctd_%s_forladcp.mat']); %stn_string
                    end
                case 'ladcp_cfg'
                    foundit = true;
                    %file for vmadcp data corresponding to this cast. if available, use
                    %the instrument/mode with deepest range
                    cfg.f.sadcp = sprintf(pd.sadcp_for_ix,'os75nb',stn_string);
                    %file and format for ascii file of 1hz ctd data and corresponding nmea nav data
                    cfg.f.ctd = sprintf(pd.ctdnav_for_ix, stn_string);
                    cfg.f.ctd_header_lines      = 1;
                    cfg.f.ctd_fields_per_line	= 6;
                    cfg.f.ctd_time_base = 1; %year-day
                    cfg.f.ctd_time_field = 1;
                    cfg.f.ctd_pressure_field	= 2;
                    cfg.f.ctd_temperature_field = 3;
                    cfg.f.ctd_salinity_field	= 4;
                    cfg.f.nav                   = cfg.f.ctd;
                    cfg.f.nav_header_lines	= cfg.f.ctd_header_lines;
                    cfg.f.nav_fields_per_line	= cfg.f.ctd_fields_per_line;
                    cfg.f.nav_time_base = cfg.f.ctd_time_base;
                    cfg.f.nav_time_field	= cfg.f.ctd_time_field;
                    cfg.f.nav_lat_field 	= 5;
                    cfg.f.nav_lon_field 	= 6;
                    %parameters for LADCP processing
                    %cfg.p.magdec_source = 1;
                    %cfg.p.drot = system()
                    %cfg.p.edit_mask_dn_bins = 1;
                    %cfg.p.edit_mask_up_bins = 1;
                    cfg.p.orig = 0; % save original data or not
                    isul = 1; %is there an uplooker? process it first on its own
                    cfg.p.ambiguity = 4.0; %this one is not used?
                    %cfg.p.vlim = 4.0; %this one is***require setting in opt_cruise
                    cfg.rawdir = fullfile(MEXEC_G.MDIRLIST.M_LADCP,'rawdata');
                    cfg.uppat = sprintf('UL%s00*s.000',cfg.stnstr);
                    cfg.dnpat = sprintf('DL%s00*m.000',cfg.stnstr);
                    if stnlocal==6
                        cfg.uppat = sprintf('UL%s00*m.000',cfg.stnstr);
                        cfg.dnpat = sprintf('DL%s00*s.000',cfg.stnstr);
                        %elseif stnlocal==2
                        %    cfg.uppat = 'UL001001s.000';
                        %    cfg.dnpat = 'DL001001m.000';
                        %    cfg.f.ctd = fullfile(MEXEC_G.MDIRLIST.M_LADCP, 'ctd', ['ctd.' stn_string '.02.asc']);
                    end
                    %set magnetic declination here, rather than using either of the two
                    %options built in to LDEO_IX/loadnav
                    %[p, f, ext] = fileparts(cfg.f.ctd); y0 = MEXEC_G.MDEFAULT_DATA_TIME_ORIGIN(1);
                    a = {dbstack(2).file};
                    if ~strcmp(a{1},'mout_1hzasc.m') %bash script uses the output of mout_1hzasc so don't want to try to call this before that
                        mdfile = fullfile(MEXEC_G.MDIRLIST.M_LADCP,'magdec.txt');
                        if ~exist(mdfile,'file')
                            fprintf(1,'in terminal, run the following:\nbash /data/pstar/programs/repos_github/mexec_exec/run_pyIGRF.sh\nthen enter to continue (here)')
                            pause
                        end
                        md = load(mdfile);
                        if ~sum(md==stnlocal)
                            fprintf(1,'in terminal, run the following:\nbash /data/pstar/programs/repos_github/mexec_exec/run_pyIGRF.sh\nthen enter to continue (here)')
                            pause
                            md = load(mdfile);
                        end
                        ii = find(md==stnlocal);
                        if isempty(ii)
                            warning('no mag dec for %s',stn_string)
                        else
                            ii = ii(1);
                            cfg.p.drot = md(ii+1);
                            fprintf(1,'using mag dec %f for %s',cfg.p.drot,stn_string)
                        end
                    end
            end

        case 'ctd_proc'
            %set input files and parameters for processing of data from sensors
            %on the CTD frame (other than LADCP)
            switch opt2
                %lines to be added to opt_cruise file, under opt1 = 'ctd_proc' by
                %create_opt_cruise, if MEXEC_G.datatypes.ctd = 'sbe'
                case 'ctd_infiles'
                    foundit = true;
                    helptext = 'specify input .cnv, .bl or .btl, and SBE35 files using stn_string';
                    %set patterns for input file paths and names (either including %s
                    %to be filled with stn_string, or with wildcards to be used by dir
                    %function)
                    infiles.ctd_raw = fullfile(MEXEC_G.data_root, 'ctd', 'ASCII_FILES', [upper(MEXEC_G.mcruise) '_%s.cnv']); %stn_string
                    infiles.ctd_nisk_fir = fullfile(MEXEC_G.data_root, 'ctd', 'ASCII_FILES', [upper(MEXEC_G.mcruise) '_%s.bl']); %stn_string
                case 'rawedit_auto'
                    foundit = true;
                    %when pumps are off
                    co.pumpsNaN.temp1 = 12; %based on jc159, T takes 1/2 s to recover
                    co.pumpsNaN.temp2 = 12;
                    co.pumpsNaN.cond1 = 12;
                    co.pumpsNaN.cond2 = 12;
                    co.pumpsNaN.oxy1 = 8*24; %based on jc159, O takes 8 s to recover
                    co.pumpsNaN.oxy2 = 8*24;
                    %use rangelim first to exclude large spikes
                    co.rangelim.press = [-1.25 3300];
                    if stnlocal<=45
                        co.rangelim.cond1 = [3 5];
                    else
                        co.rangelim.cond1 = [2.5 5];
                    end
                    co.rangelim.cond2 = co.rangelim.cond1;
                    co.rangelim.temp1 = [-2 18]; co.rangelim.temp2 = co.rangelim.temp1;
                    if stnlocal<=34
                        co.rangelim.oxy2 = [170 290];
                        co.rangelim.oxy1 = [155 275];
                    elseif stnlocal>=35 && stnlocal<=45
                        co.rangelim.oxy2 = [230 310];
                        co.rangelim.oxy1 = [215 290];
                    elseif stnlocal>45
                        co.rangelim.oxy2 = [240 385];
                        co.rangelim.oxy1 = [230 385];
                    end
                    co.rangelim.oxy1 = co.rangelim.oxy2;
                    co.rangelim.turbidity = [0 1];
                    co.rangelim.fluor = [0 8];
                    co.rangelim.transmittance = [0 100];
                    co.rangelim.turbidity = [0 1];
                    %co.rangelim.par = [0 100];
                    %then despike with 2 repetitions of a 12-scan median
                    %despiker
                    co.despike.press = [2 12; 2 12]; %avg 1m/s so 2 dbar/0.5 s is large
                    co.despike.temp1 = [0.5 12; 0.5 12];
                    co.despike.cond1 = [0.02 12; 0.02 12];
                    co.despike.oxy1 = [3 12; 3 12];
                    co.despike.temp2 = co.despike.temp1;
                    co.despike.cond2 = co.despike.cond1;
                    co.despike.oxy2 = co.despike.oxy1;
                    % if ismember(stnlocal,[24 34 40 41 43 68 68])
                    %      co.despike.oxy1 = [10,24*20];
                    % end
                    %mask some bad scan ranges
                    % if stnlocal==39
                    %     co.badscan.oxy1 = [4.92 17.602]*1e4;
                    % end
                    %if ismember(stnlocal,[17:22 24:32 34:43 45:47 51:53 55:59 63:])
                    %if ismember(stnlocal,[22:26 27 ...
                    %        :32 34:41 43 45:47 52 53 55:57 63 66 68:70]) %54 58 59 60 64 65 67 might need revisiting
                    %    co.badscan.oxy1 = [-inf inf]; %so many spikes it's not worth cleaning
                    %end
                    %then mask all on CTD whenever P is bad
                    co.badpress.temp1 = [NaN NaN];
                    co.badpress.temp2 = [NaN NaN];
                    co.badpress.cond1 = [NaN NaN];
                    co.badpress.cond2 = [NaN NaN];
                    co.badpress.oxy1 = [NaN NaN];
                    co.badpress.oxy2 = [NaN NaN];
                    %when there is a pressure spike, everything is likely to be
                    %bad
                    co.badpress.turbidity = [NaN NaN];
                    co.badpress.transmittance = [NaN NaN];
                    co.badpress.fluor = [NaN NaN];
                    co.badpress.par = [NaN NaN];
                case 'raw_corrs'
                    foundit = true;
                    co.dpoff_calc = 1; %try to calculate deck pressure from start of record
                    co.dpoff_checked = []; %columnar list of [stn dpoff] pairs (e.g. [1 0.2; 14 0.153]) to use instead of automatic calculations
                    % number of seconds to shift oxygen earlier, based on delay in membrane response (varies from 1-8 S partially depending on temperature)
                    co.oxy_align = 0; %set to 0 until hysteresis is checked.
                    co.doturbV = 0; %don't recalculate turbidity from V
                    %unusual: set dooxy1V or dooxy2V to 1 or 2 to recalculate using
                    %temp1 or temp2
                    co.dooxy1V = 0; co.dooxy2V = 0;
                    %set re_dooxyhyst = 1 to (re)do the oxygen hysteresis correction:
                    % if a correction was already applied in SBE processing,
                    %   reverse it using hyst_oxy0, then
                    % apply oxygen hysteresis correction hyst_oxy1 (for oxy1)
                    %   and hyst_oxy2 (for oxy2)
                    %
                    % note SBE defaults are: H1 = -0.033, H2 = 5000, H3 = 1450;
                    %  if you somehow applied different values in SBE
                    %  processing, change hyst_oxy0 here, but this is very
                    %  unlikely
                    co.re_dooxyhyst = 1; %default: nothing applied in SBE processing, so this is on
                    co.hyst_oxy0.H1 = -0.033; %probably do not change!
                    co.hyst_oxy0.H2 = 5000; %probably do not change!
                    co.hyst_oxy0.H3 = 1450; %probably do not change!
                    co.hyst_oxy1 = co.hyst_oxy0; %default: apply default coefficients to oxy1; may want to change this
                    co.hyst_oxy2 = co.hyst_oxy0; %default: apply default coefficients to oxy2; may want to change this
            end
            switch opt2
                case 'ctd_pfiles' %consider just resolving %s to stn_string?***
                    foundit = true;
                    helptext = 'specify paths and names of files produced by ctd processing';
                    %processed files
                    pfiles.ctd_raw = fullfile(MEXEC_G.data_root, 'ctd', ['ctd_' MEXEC_G.mcruise '_%s_cnv.nc']); %stn_string
                    pfiles.ctd_cleancal = fullfile(MEXEC_G.data_root, 'ctd', ['ctd_' MEXEC_G.mcruise '_%s_24hz.nc']); %stn_string
                    efiles.ctd_editsrecord = fullfile(MEXEC_G.data_root, 'ctd', 'editlogs', 'ctd_%s_editpoints'); %stn_string %files that go into producing pfiles.ctd_clean from pfiles.ctd_raw
                    pfiles.ctd_1hz = fullfile(MEXEC_G.data_root, 'ctd', ['ctd_' MEXEC_G.mcruise '_%s_1hz.nc']); %stn_string
                    pfiles.ctd_10s = fullfile(MEXEC_G.data_root, 'ctd', ['ctd_' MEXEC_G.mcruise '_%s_10s.nc']); %stn_string
                    pfiles.ctd_2db_dn = fullfile(MEXEC_G.data_root, 'ctd', ['ctd_' MEXEC_G.mcruise '_%s_2db.nc']); %stn_string
                    pfiles.ctd_2db_up = fullfile(MEXEC_G.data_root, 'ctd', ['ctd_' MEXEC_G.mcruise '_%s_2up.nc']); %stn_string
                    pfiles.ctd_nisk = fullfile(MEXEC_G.data_root, 'ctd', ['fir_' MEXEC_G.mcruise '_%s.nc']); %stn_string
                    pfiles.ctd_castcut = fullfile(MEXEC_G.data_root, 'ctd', ['dcs_' MEXEC_G.mcruise '_%s.nc']); %stn_string
                    pfiles.ctd_win = fullfile(MEXEC_G.data_root, 'ctd', 'WINCH', ['win_' MEXEC_G.mcruise '_%s.nc']); %stn_string
                    %other standard outputs
                    pfiles.svel = fullfile(MEXEC_G.data_root, 'bathy', 'svel_for_echosounders', ['ctd_' MEXEC_G.mcruise '_10s_down_svel.csv']);
                    pfiles.ctd_sns = fullfile(MEXEC_G.data_root, 'ctd', 'sensor_groups.mat'); %***
                    pfiles.ctd_nisk_sum = fullfile(MEXEC_G.data_root, 'collected_files', ['station_summary_' MEXEC_G.mcruise '_all.nc']); %***
                case 'ctd_raw_extra'
                    foundit = true;
                    if stn==22
                        %add time since it was not exported
                        extrasource = {'d.time = d.scan/24;'};
                        extravars = {'time'; 'seconds since 2026-07-28 15:41:17'};
                    elseif stn==25
                        %cast split over two files, 025 and 025b
                        append_stn_strings = {'025b'};
                        append_scan_offsets = 154152;
                    elseif stn==70
                        split_castnos_scans = [70 1 inf];

                    elseif stn==71
                        %70 and 71 were yo-yo casts, need to be divided and
                        %renumbered***
                    end
                case 'header_edits'
                    foundit = true;
                    h.comment = replace(h.comment,'PSO: Caroline Cusack','PSO: Yvonne Firing');
                case 'ctd_cals'
                    foundit = true;
                    co.docal.temp = 0; %do not apply any user calibration to temp
                    co.docal.cond = 0; %do not apply any user calibration to cond
                    co.docal.oxy = 0; %do not apply any user calibration to oxy
                    co.docal.fluor = 0; %etc
                    co.docal.transmittance = 0; %etc
                case 'sensor_choice'
                    foundit = true;
                    %we often have a pair of CT sensors (temp1, cond1 and
                    %temp2, cond2) and sometimes a pair of DO sensors
                    %(oxy1, oxy2); the preferred sensor (can vary by cast) will
                    %be copied to suffix-less temp, cond and oxy
                    %ts_choice and o_choice are not required to be the same,
                    %but it may be preferrable as temp1 will have been used to
                    %calculate oxy1 from volts, and temp2 to calculate oxy2
                    if stn == 4 %oxy1 switched to good cable, oxy2 off
                        ts_choice = 1;
                        o_choice = 1;
                    else
                        ts_choice = 2; %CTD2 is preferred; temp = temp2, cond = cond2
                        o_choice = 2; %oxygen 1 on bad y-cable (shared with par but par end okay), so CTD DO2 is preferred; oxy = oxy2
                    end
                case '1hz_interp'
                    foundit = true;
                    maxfill24 = 24;
                    maxfill1 = 1;
                case 'cast_divide'
                    foundit = true;
                    force_auto.start = 0; force_auto.bot = 0; force_auto.end = 0;
                case 'rawshow'
                    foundit = true;
                    %two groupings to show
                    rppars = {{'temp','cond','press','oxy'}
                        {'fluor','turbidity','transmittance','par'}};
                    repars.g1 = {{'press'}, {'temp1','temp2'}, {'cond1','cond2'},{'oxy1','oxy2'}};
                    %repars.g1 = setdiff(repars.g1,{'oxy1'}); %at first, don't show oxy on the spike editing plot
                    %not editing fluo etc.
                    %repars.g2 = {{'press'},{'fluor'},{'turbidity'},{'transmittance'},{'par'}};
                    yl.temp = [0 18]; yl.cond = [3 5]; yl.oxy = [120 300];
                    yl.press = [-1 3200];
                    yl.press = [-1 ceil(d.press(ddcs.dc24_bot)/100)*100+10];
                    yl.fluor = [0 8]; yl.par = [0 40];
                    if stnlocal>40
                        yl.temp = [-2 10]; yl.cond = [2.5 4.5]; yl.oxy = [200 380];
                        yl.fluor = [0 5];
                    end
                    yl.temp1 = yl.temp; yl.temp2 = yl.temp;
                    yl.cond1 = yl.cond; yl.cond2 = yl.cond;
                    yl.oxy1 = yl.oxy; yl.oxy2 = yl.oxy;
                    yl.turbidity = [0 1]; yl.transmittance = [60 101]; yl.par = [0 200];
                    doed = 1; %always end mctd_raw_show_check by running mctd_rawedit (can turn this off in opt_cruise)
                    %ctd flags: 1 not calibrated, 2 acceptable, 3 questionable
                    %,4 bad, 5 not reported, 6 interpolated over > 2 dbar, 7
                    %despiked
                    edit_vars_exclude = {'pressure_temp'}; %starts with press but don't plot this
                    edit_vars_exclude = [edit_vars_exclude 'par_corrected']; %this seems to be identically 0 so don't bother
                case 'nisk_flags'
                    foundit = true;
                    ft = {'1 no info';
                        '2 no problems noted';
                        '3 leaking';
                        '4 did not trip correctly';
                        '5 not reported';
                        '7 unknown problem';
                        '9 samples not drawn'}; %***
                    if ~MEXEC_G.quiet
                        fprintf(1,'using WOCE Niskin flags: \n%s',ft{:})
                    end
                    niskin_flag(position==3) = 4; %latch does not release
                    f = readtable(fullfile(MEXEC_G.MDIRLIST.M_CTD,'niskin_flags_logged_ce26008.csv'),'Delimiter',',');
                    f = f(f.statnum==stnlocal,:);
                    [~,ia,ib] = intersect(position,f.position,'stable');
                    niskin_flag(ia) = f.niskin_flag(ib);
                case 'nisk_numbers'
                    foundit = true;
                    niskin_number = [1:24]'; %replace with S/N, bedford number, etc.
                    niskin_pos = [1:24]'; %position on firing carousel
                case 'fir_fill'
                    foundit = true;
                    firmethod = 'medint';
                    clear firopts;
                    firopts.int = [-1 120]; %average over 5 s, like in .ros file
                    firopts.prefill = 24*5; %fill gaps up to 5 s first
                case 'fir_extra'
                    foundit = true;
                    fir_extra = true; %do also add background gradient and variance, and density-matched downcast data, to fir_ (and sam_) file
            end

        case 'samp_proc'
            switch opt2
                case 'sbe35_files'
                    foundit = true;
                    infiles.sbe35_raw = fullfile(MEXEC_G.data_root, 'ctd', 'ASCII_FILES', 'SBE35', [upper(MEXEC_G.mcruise) '_*.txt']);
                    pfiles.sbe35_all = fullfile(MEXEC_G.data_root, 'ctd', 'ASCII_FILES', 'SBE35', ['sbe35_' MEXEC_G.mcruise '_all.nc']);
                    %stnind is indices in filename sbe35file normally
                    %containing the station number; use negative to indicate
                    %distance from end e.g. [-6:-4] for dy113_SBE35_CTD_010.asc
                    stnind = -6:-4;
                case 'sbe35_irreguar_parse'
                    foundit = true;
                    %deal with combined file(s)
                    if strcmp(file_list{kf},'CE26008_002_003.txt')
                        m = t.datnum<datenum(2026,7,24,10,0,0);
                        t.statnum(m) = 2;
                    elseif strcmp(file_list{kf},'CE26008_005_006_007.txt')
                        m = t.datnum<datenum(2026,7,25,5,0,0);
                        t.statnum(m) = 5;
                        m = t.statnum==7 & t.datnum<datenum(2026,7,25,9,0,0);
                        t.statnum(m) = 6;
                    end

                case 'sbe35_flags'
                    foundit = true;
                    %convention to follow: as for CTD or as for bottle data?
                    %no defaults
            end
            switch opt2
                case 'samp_infiles'
                    foundit = true;
                    helptext = 'set list of files to load for a particular samtyp, and set sopts to specify how to read in csv/spreadsheet files';
                    %how to read in csv/spreadsheet files
                    sopts.remove_empty_cols = 1;
                    uway_sample_log_file = fullfile(MEXEC_G.MDIRLIST.M_BOT,'uway_sample_log.csv');
                    switch samtyp
                        case 'ulog'
                        case 'chl'
                        case 'oxy'
                            files = {fullfile(MEXEC_G.MDIRLIST.M_BOT_OXY,'Oxygen_concentration_calculation_worksheet_final.xlsx')};
                            sopts.numhead = 9;
                            %force column names and types
                            ct = {'statnum','double';...
                                'position','double';...
                                'd','char';...
                                'botno','char';...
                                'botvol25','double';...
                                'blank_titre','double';...
                                'vol_std','double';...
                                'std_titre','double';...
                                'fix_temp','double';...
                                'bot_vol_tfix','double';...
                                'sample_titre','double';...
                                'iodatemol','double';...
                                'n_o2','double';...
                                'conc_o2','double';...
                                'notes','char'};
                            sopts.VariableNames = ct(:,1)';
                            sopts.VariableTypes = ct(:,2)';
                            sopts.sheets = 1:15;
                        case 'sal'
                            %files = {dir(fullfile(MEXEC_G.MDIRLIST.M_BOT_SAL,'portasal*.csv')).name};
                            %files = cellfun(@(x) fullfile(MEXEC_G.MDIRLIST.M_BOT_SAL,x),files,'UniformOutput',false);
                            files = {fullfile(MEXEC_G.MDIRLIST.M_BOT_SAL,'sal_all.csv')};
                            ct = {'bottle_no','char';...
                                'reading1','double';...
                                'reading2','double';...
                                'reading3','double';...
                                'reading4','double';...
                                'cellT','double';...
                                'sampnum','double';...
                                'runtime','char';...
                                'notes','char'};
                            sopts.VariableNames = ct(:,1)';
                            sopts.VariableTypes = ct(:,2)';
                            sopts.numhead = 4;
                        case 'nut'
                        case 'co2'
                        case 'cfc'
                        case 'doc'
                        case 'iso'
                    end
                case 'samp_pfiles'
                    foundit = true;
                    %concatenated file for a type of sample data
                    if exist('samtyp','var')
                        pfiles.(samtyp) = fullfile(MEXEC_G.data_root, 'bottle_samples', [samtyp '_' MEXEC_G.mcruise '_all.nc']);
                    end
                    %combined files for all sample (and comparison sensor) data
                    %pfiles.samp_ctd = fullfile(MEXEC_G.data_root, 'bottle_samples', ['samp_nisk_' MEXEC_G.mcruise '_all.nc']);
                    pfiles.samp_ctd = fullfile(MEXEC_G.data_root, 'bottle_samples', ['samp_nisk_' MEXEC_G.mcruise '_all.nc']);
                    pfiles.samp_uway = fullfile(MEXEC_G.data_root, 'bottle_samples', ['samp_ucsw_' MEXEC_G.mcruise '_all.nc']);
                case 'samp_file_parse'
                    foundit = true;
                    clear varmap
                    %keepothervars, varmap
                    addcomment = '';
                case 'parse'
                    foundit = true;
                    switch samtyp
                        case 'sal'
                            ssw_k15 = 0.99983;
                            ssw_batch = 'P169';
                            %combine replicates in different columns
                            sdata.reading = [sdata.reading1 sdata.reading2 sdata.reading3 sdata.reading4];
                            sdata.reading(cellfun(@(x) contains(x,'bad'),sdata.notes),:) = NaN;
                            sdata.runtime = datetime(sdata.runtime,'InputFormat','MMddHHmm');
                            sdata.flag = 2+zeros(size(sdata.reading));
                            sdata.flag(cellfun(@(x) contains(x,'bad'),sdata.notes)) = 4;
                            sdata.flag(cellfun(@(x) contains(x,'questionable'),sdata.notes)) = 3;
                            sdata.flag(strcmp('ignore readings 3 and 4',sdata.notes),3:4) = 4;
                            sdata.flag(strcmp('start level a little low still on shoulder',sdata.notes),:) = 3;
                            sdata.flag(strcmp('larger variations',sdata.notes),:) = 3;
                            sdata.flag(strcmp('Mislabeled?',sdata.notes),:) = 3;
                            %sdata(sdata.flag(:,1)==2 & ~cellfun('isempty',sdata.notes),:)
                            sdata.reading(sdata.flag==4) = NaN;
                        case 'oxy'
                            sdata.flag = 2+zeros(size(sdata.statnum));
                            m = ~cellfun('isempty',sdata.notes);
                            sdata.flag(m) = 5; %various notes mean (should) not (be) reported
                            sdata.sample_titre(m) = NaN;
                            sdata.conc_o2(m) = NaN;
                            sdata(:,ismember(sdata.Properties.VariableNames,{'botno','botvol25','notes','statnum','position'})) = [];
                    end
                case 'samp_repls'
                    foundit = true;
                    %threshold to use to check replicate agreement (set to 0 to
                    %skip checking that sample type)
                    rc.chl = [1 2]; %compare by ratio, highlight differences over factor of 2
                    rc.oxy = [2 0.01]; %compare by ratio, highlight differences over +/- 1%
                    rc.nut = [2 0.05]; %compare by ratio, highlight differences over +/- 5%
                    rc.sal = [0 1e-5]; %compare (salinometer reading) by difference, highlight differences over +/- 1e-5
                    rc.co2 = [2 0.05]; %***confirm default
                    rc.sbe35 = 0; %no threshold but if set to 1, check ascii file download quality (rarely necessary)
                case 'samp_flags'
                    foundit = true;
                    ft = {'1 = sample drawn but analysis not received';
                        '2 = acceptable';
                        '3 = questionable';
                        '4 = bad';
                        '5 = not reported';
                        '6 = mean of duplicates';
                        '9 = sample not drawn'};
                    if ~MEXEC_G.quiet || (exist('helpmode','var') && helpmode)
                        fprintf(1,'WOCE flags: \n%s', ft{:})
                    end
                    %***these should be set using gui and editlogs and
                    %apply_edits, so record is all in one place. only niskin
                    %flags should be set in opt_cruise*** also data file
                    %metadata should list location/name pattern of editlogs
                    %files (when they exist/have been applied)
                case 'oxy_calc'
                    foundit = true;
                    %calculate oxygen concentration (umol/kg) from winkler
                    %titre volume and fixing temperature?
                    calc_oxy_from_titre = true;
                case 'nut_calc'
                    foundit = true;
                    %***convert units?
                case 'sal_calc'
                    foundit = true;
                    %***
            end

        case 'uway_proc'
            switch opt2
                case 'scs_skip'
                    foundit = true;
                    skip = {'USBL'};
                case 'scs_nmea_form'
                    foundit = true;
                    colsi = {}; colsf = {};
                    untsi = {}; untsf = {};
                case 'scs_nmea_custom'
                    foundit = true;
                    inform = '';
                case 'uway_ascii_parse'
                    foundit = true;
                    if exist('inform','var') && ~isempty(inform) && ~strcmp(inform,'none')
                        t = ua_times_parse(t, MEXEC_G.data_time_origin_string, 'inform', inform);
                    elseif strcmp(inform,'none')
                        t.time = [1:length(t.lat)]'+t0; t.Properties.VariableUnits(end) = {'temporary invented seconds'};
                        t.dday = t.time/86400; t.Properties.VariableUnits(end) = {'temporary invented days'};
                    else
                        t = ua_times_parse(t, MEXEC_G.data_time_origin_string);
                    end
                    if sum(strcmp(t.Properties.VariableNames','msg')) && strcmp(t.msg(1),'$PSXN')
                        t = t(t.linetype==23,:);
                    end
                    m = strcmp(t.Properties.VariableNames,'nslatitude');
                    if sum(m)
                        if strcmp(t.Properties.VariableUnits(m),'cdegrees')
                            t.lat = t.nslatitude/100;
                        else
                            t.lat = t.nslatitude;
                        end
                        t.lat(strcmp(t.ns,'S')) = -t.lat(strcmp(t.ns,'S'));
                        t.Properties.VariableUnits{strcmp(t.Properties.VariableNames,'lat')} = 'degrees N';
                    end
                    m = strcmp(t.Properties.VariableNames,'ewlongitude');
                    if sum(m)
                        if strcmp(t.Properties.VariableUnits(m),'cdegrees')
                            t.lon = t.ewlongitude/100;
                        else
                            t.lon = t.ewlongitude;
                        end
                        t.lon(strcmp(t.ew,'W')) = -t.lon(strcmp(t.ew,'W'));
                        t.Properties.VariableUnits{strcmp(t.Properties.VariableNames,'lon')} = 'degrees E';
                    end
                    m = strcmp(t.Properties.VariableNames,'psxn_heave');
                    if sum(m)
                        t.heave = cellfun(@(x) str2double(x(1:end-3)), t.psxn_heave);
                        t.Properties.VariableUnits{strcmp(t.Properties.VariableNames,'heave')} = 'm';
                    end
            end
            switch opt2
                case 'uway_pfiles'
                    foundit = true;
                    pfiles.uway_raw = fullfile(MEXEC_G.data_root,mtable.mstardir{m},['%s_' MEXEC_G.mcruise '_all_raw.nc']); %abbrev
                    pfiles.uway_edt = fullfile(MEXEC_G.data_root,mtable.mstardir{m},['%s_' MEXEC_G.mcruise '_all_edt.nc']); %abbrev
                    pfiles.nav_final = fullfile(MEXEC_G.data_root, 'nav', ['bestnav_' MEXEC_G.mcruise '_all.nc']);
                    pfiles.uocean_final = fullfile(MEXEC_G.data_root, 'surfmet', ['surface_ocean_' MEXEC_G.mcruise '_all.nc']);
                    pfiles.met_final = fullfile(MEXEC_G.data_root, 'surfmet', ['atmos_truwind_' MEXEC_G.mcruise '_all.nc']);
                    pfiles.bathy_final = fullfile(MEXEC_G.data_root, 'bathy', ['bathy_' MEXEC_G.mcruise '_all.nc']);
                case 'uway_raw_tstep_save'
                    foundit = true;
                    %subsample high-frequency streams and match up different
                    %messages from the same system by rounding timestamp
                    %if your samples are coming in at a *regular* high
                    %frequency (e.g. 40Hz on the SDA), set stepfreq_force to
                    %subsample to (approximately) 1/tstep_force hz before
                    %saving
                    stepfreq_force = [];
                    %round time to nearest tstep_resol s before saving, to
                    %avoid precision-related duplicate time steps (lots of
                    %time steps that have data from A but not B, or B but not A) later
                    tstep_resol = 1; %this should be much shorter than the later averaging interval (e.g. 30 or 60 s)
                case 'uway_raw_edit'
                    foundit = true;
                    %assume no repeated or backwards times at edit stage
                    fixtimes = 0;
                    check_mono = 0;
                    %range limits by variable type should usually be
                    %conservative (wide) so as not to risk throwing out good
                    %points, or masking certain types of problems
                    r = {'head', [-0.1 360.1]; 'pitch', [-5 5]; 'roll', [-7 7];...
                        'lon', [-181 181]; 'lat', [-91 91];...
                        'airtemp', [-50 50]; 'humid', [0.1 110];...
                        'rwindd', [-0.1 360.1]; 'twindd', [-0.1 360.1];...
                        'rwinds', [-0.001 200]; 'twinds', [-0.001 200];...
                        'airpres', [0.01 1500];...
                        'ppar', [-10 1500]*1e6; 'ptir', [-10 1500]*1e6;...
                        'spar', [-10 1500]*1e6; 'stir', [-10 1500]*1e6;...
                        'sst', [-2 50]; 'temp', [-2 50];...
                        'cond', [0 10]; 'trans', [0 105];...
                        'dep', [20 1e4]; 'depsref', [20 1e4]; 'deptref', [20 1e4]};
                    %now match to actual variable names in the file being
                    %worked on
                    for no = 1:size(r,1)
                        n = munderway_varname([r{no,1} 'var'], h.fldnam, 's');
                        for nno = 1:length(n)
                            uopts.rangelim.(n{nno}) = r{no,2};
                        end
                    end
                    %despike bathymetry because it usually needs it
                    n = munderway_varname('depvar', h.fldnam, 's');
                    n = union(n, munderway_varname('depsrefvar', h.fldnam, 's'));
                    n = union(n, munderway_varname('deptrefvar', h.fldnam, 's'));
                    for nno = 1:length(n)
                        uopts.despike.(n{nno}) = [10 5 3]; %m
                    end
                case 'uway_sensor_unit_conversions'
                    foundit = true;
                    so = struct(); %default: none, parameters are read from database in physical units
                case 'rawedit'
                    foundit = true;
                    %lots of these (including ranges for many parameters), so
                    %set in separate function
                    uopts = mday_01_default_autoedits(h, streamtype);
                    handedit = 0;
                case 'avedit'
                    foundit = true;
                    uopts = struct();
                    tvars = fieldnames(dg)';
                    tvars = [tvars(cellfun(@(x) contains(x,'time'),tvars)) 'dday'];
                    vars_to_ed.g1 = {setdiff(fieldnames(dg)',tvars)};
                    switch datatype
                        case 'bathy'
                            handedit = 1;
                        case 'ocean'
                            handedit = 1;
                            %ucsw system things should be NaNed when pump speed out of range, including remote temp (inside inlet)
                            fvars = {'temph','temp_remote','temp_tsg','temp_in','fluo','fluor','transmissivity','trans','cond','salinity','psal','conductivity'};
                            for no = 1:length(fvars)
                                uopts.badflow.(fvars{no}) = [-inf 0.6; 2.5 inf];
                            end
                            %soundvelocity depends on remote temp
                            uopts.badtemp_remote.soundvelocity = [NaN NaN];
                            %conductivity and salinity depend on housing temp
                            uopts.badtemph.cond = [NaN NaN];
                            uopts.badtemph.salinity = [NaN NaN];
                            yl.trans = [-95 0.1]; %***
                            yl.cond = [20 40]; yl.psal = [33 38]; yl.salinity = yl.psal;
                            yl.fluor = [0 12]; yl.fluo = yl.fluor;
                            yl.turbidity = [0 1];
                            yl.transmittance = [60 101];
                            yl.temph = [-2 30]; yl.temp_remote = yl.temph;
                            yl.temp_in = yl.temph; yl.temp_tsg = yl.temph;
                            vars_to_ed.g1 = {{'temph','temp_in','temp_remote','temp_tsg'}, {'cond','conductivity'}, {'psal'}};
                            vars_to_ed.g2 = {{'temph'},{'fluor'},{'turbidity'},{'trans','transmittance'}};
                        case 'atmos'
                            handedit = 1;
                            wvars = {'truwind_e','truwind_n','truwind_dir'};
                            for no = 1:length(wvars)
                                uopts.badtruwind_spd.(wvars{no}) = [NaN NaN];
                            end
                            vars_to_ed.g1 = {{'airpressure'},{'airtemp'},{'humidity'},{'truwind_spd','truwind_e','truwind_n'},{'parport','parstarboard','tirport','tirstarboard'}};
                            yl.airpressure = [500 1500];
                            yl.airtemp = [0 30];
                            yl.humidity = [0 100];
                            yl.parport = [0 1e7];
                            yl.parstarboard = yl.parport;
                            yl.tirport = yl.parport;
                            yl.tirstarboard = yl.parport;
                            yl.truwind_e = [-50 50]; yl.truwind_n = yl.truwind_e;
                            yl.truwind_spd = [0 round(yl.truwind_e(2)*sqrt(2))];
                            yl.truwind_dir = [0 360];
                        case 'nav'
                            handedit = 0;
                    end
                case 'tsg_cals'
                    foundit = true;
                    uo.docal.temp = 0; %do not apply any calibration to tsg temp
                    uo.docal.cond = 0; %etc
                    uo.docal.fluor = 0; %etc
                    if isfield(uo,'calstr')
                        uo = rmfield(uo,'calstr'); %no default, must be set by opt_{cruise}
                        %see opt_sd025 for examples
                    end
            end

        case 'outputs'
            switch opt2
                case 'summary'
                    foundit = true;
                    snames = {'nsal' 'noxy' 'nnut' 'nco2'};
                    sgrps = {{'botpsal'} {'botoxy'} {'silc' 'phos' 'totnit'} {'dic' 'talk' 'ph'}};
                case 'grid'
                    foundit = true;
                    ctd_regridlist  = {'temp' 'psal' 'potemp' 'oxy'}; %grid these sensor variables
                    sam_gridlist = {'botoxy' 'silc' 'phos' 'totnit' 'botpsal'}; %and these sample variables
                    mgrid.sdata_flag_accept = [2 3]; %***or just 2
                    if contains(section,'ar7e')
                        kstns = [4:41 43:47 49:51];
                        mgrid.xlim = 2; mgrid.zlim = 4;
                    elseif contains(section,'km')
                        kstns = 52:57;
                        mgrid.xlim = 2; mgrid.zlim = 4;
                    elseif contains(section,'ta')
                        kstns = 58:63;
                    elseif contains(section,'kgh')
                        kstns = 64:69;
                    end
                case 'section_for_station'
                    foundit = true;
                    if stnlocal>=4 && stnlocal<88
                        sections = {'ar7e','km','ta','kgh'};
                    end
                case 'columndata'
                    foundit = true;
                    outtypes = {'bodc','exch'};
                case 'exch'
                    foundit = true;
                    ns = 35;
                    expocode = '54CE20260723';
                    sect_id = 'AR7E; AR07E';
                    submitter = 'OCPNOCYLF'; %group institution person
                    common_headstr = {'#SHIP: RV Celtic Explorer';...
                        '#Cruise CE26008; GO-SHIP AR7E 2026';...
                        '#Region: subpolar north Atlantic';...
                        ['#EXPOCODE: ' expocode];...
                        '#DATES: 20260723 - 20260811';...
                        '#Chief Scientist: Y. Firing (NOC); Co-Chief Scientist: M. Clark (NOC)';...
                        '#Supported by ...'};
                    if strcmp(params.in,'ctd')
                        headstring = {['CTD,' datestr(now,'yyyymmdd') submitter]};
                        headstring = [headstring; common_headstr;
                            {sprintf('#%d stations with 24-place rosette',ns);...
                            % '#CTD: Who - Y. Firing (NOC); Status - final.';...
                            % '#The CTD PRS; TMP; SAL; OXY data are all calibrated and good.';...
                            % '# DEPTH_TYPE   : COR';...
                            % '# DEPTH_TYPE   : rosette depth from CTDPRS + CTD altimeter range to bottom, or speed of sound-corrected ship-mounted bathymetric echosounder'...
                            }];
                    else
                        headstring = {['BOTTLE,' datestr(now,'yyyymmdd') submitter]};
                        headstring = [headstring; common_headstr;
                            {sprintf('#%d stations with 24-place rosette',ns);...
                            % '#CTD: Who - Y. Firing (NOC); Status - final';...
                            % '#Notes: Includes CTDSAL, CTDOXY, CTDTMP';...
                            % '#The CTD PRS; TMP; SAL; OXY data are all calibrated and good.';...
                            % '# DEPTH_TYPE   : rosette depth from CTDPRS + CTD altimeter range to bottom';...
                            % '#Salinity: Who - Y. Firing (NOC); Status - final; SSW batch P168.';...
                            % '#Oxygen: Who - R. Abell (SAMS); Status - final.';...
                            % '#Nutrients: Who - R. Abell (SAMS); Status - preliminary.';...
                            % '#DIC and Talk: Who - C. Johnson (SAMS); Status - not yet analysed.';...
                            }];
                    end
                    vars_exclude_ctd = {}; %changed jc238 from {'fluor' 'transmittance'};
                    vars_exclude_sam = {};
                    vars_rename = {}; %first column in m_exch_vars_list, newname (e.g. CTDTURB, CTDBETA650_124)
                case 'bodc'
                    foundit = true;
                    %vars_exclude = {};
                case 'plot' %***
                    foundit = true;
                    station_depth_width = 0;
                    bottle_depth_size = 0;
            end

    end
    outofopts = true;

end

if ~foundit
    if exist('opt2','var')
        fprintf(2,'opt1 = %s, opt2 = %s was not found in %s\n',opt1,opt2,mfilename)
    else
        fprintf(2,'opt1=%s with no opt2 was not found in %s\n',opt1,mfilename)
    end
end