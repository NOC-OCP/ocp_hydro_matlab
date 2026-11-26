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

% CTD station notes:
% cast 1 and 48 aborted, converted from .hex but not processed
% cast 42 aborted, not converted from .hex
% cast 2 deep test cast, cast 3 shallow test dip with ***
% cast 71 and 72 yo-yos, no Niskins
% cast 25 CTD deck box restarted, CTD recorded in 025 and 025b
% cast 22 exported without time elapsed***
%
% record of Niskin samples collected, and Niskin flags observed at collection, in bottle_samples/LOGS/niskin_samples_log.xlsx
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
                case 'station_lists'
                    foundit = true;
                    %1, 42, 48 were aborted casts; 3 was very shallow dip
                    %to test a cable
                    stnlists.all = [2 4:41 43:47 49:82]; %all CTD casts to process
                    stnlists.stns_short = []; %no non-full-depth casts being processed
                    stnlists.ar7e = [4:41 43:47 49:51]; %AR7E section
                    stnlists.km = 52:57; %KM
                    stnlists.ta = 58:63; %TA
                    stnlists.kgh = 64:69; %KGH
                    stnlists.yoyo1 = 70:79;
                    stnlists.yoyo2 = 80:82;
                case 'summary_counts'
                    %type of samples (from concatenated sample data file,
                    %if available, or as listed on niskin sampling logsheet
                    %otherwise) to group together for summary table
                    foundit = true;
                    %each field of samp_groups should have an entry in the
                    %metadata_cruise_data file below
                    samp_groups.sal = {'botpsal'};
                    samp_groups.oxy = {'botoxy'};
                    samp_groups.nut = {'silc', 'phos', 'totnit'}; %variable names in this group
                    samp_groups.co2 = {'dic_ta', 'dic', 'talk', 'ph'};
                    samp_groups.tt = {'sf6', 'cfc13'};
                    samp_groups.pig = {'chl', 'hplc'};
                    samp_groups.gas = {'n2o_ch4'};
                    samp_groups.rn = {'dic14','rn'}; %
                    samp_groups.doc = {'doc'};
                    samp_groups.d18o = {'d18o'};
                    samp_groups.bioo = {'ifcb_planktoscope','lugols'};
                    samp_groups.omic = {'edna','viral'};
                case 'metadata'
                    foundit = true;
                    mdc = readtable(fullfile(MEXEC_G.data_root,'collected_files','metadata_ce26008_cruise.csv'));
                    mdd = readtable(fullfile(MEXEC_G.data_root,'collected_files','metadata_ce26008_data.csv'));

                    mdd.ctd.number = sprintf('#%d stations with 24-place rosette',length(stnlists.all));
                    mdd.ctd.comment = {'#The CTD PRS; TMP; SAL; OXY are all calibrated and good.';...
                        '# DEPTH_TYPE   : COR';...
                        '# DEPTH_TYPE   : rosette depth from CTDPRS + CTD altimeter range to bottom, or speed of sound-corrected ship-mounted bathymetric echosounder'...
                        };
                    %exch_headstr = {['#SHIP: ' mdc.ship];...
                    % ['#Cruise: ' mdc.cruise_code '; ' mdc.project_cruise_section_tags];...
                    % ['#Region: ' mdc.region]';...
                    % ['#EXPOCODE: ' expocode];...
                    % ['#OceanOps cruise ID: ' oopsid]
                    % ['#DATES: ' mdc.start ' - ' mdc.end];...
                    % ['#Chief Scientist: ' mdc.cs '; Co-Chief Scientist: ' mdc.ccs];...
                    % ['#' mdc.acknowl]};
                    %                        headstring = {['CTD,' datestr(now,'yyyymmdd') submitter]};
                    %                        headstring = [headstring; common_headstr;
                    %                        headstring = {['BOTTLE,' datestr(now,'yyyymmdd') submitter]};
                    %                        headstring = [headstring; common_headstr;
                case 'infiles'

                case 'pfiles'
                    foundit = true;
                    helptext = 'specify paths and names of processed data files (created by mexec_data_processing, and possibly used by later steps)';
                    if exist('stn_string','var')
                        pfiles.ctd_raw = fullfile(MEXEC_G.data_root, 'ctd', sprintf('ctd_%s_%s_cnv.nc', MEXEC_G.mcruise, stn_string));
                        pfiles.ctd_cleancal = fullfile(MEXEC_G.data_root, 'ctd', sprintf('ctd_%s_%s_24hz.nc', MEXEC_G.mcruise, stn_string)); %stn_string
                        pfiles.ctd_editsrecords = fullfile(MEXEC_G.data_root, 'ctd', 'editlogs', sprintf('ctd_%s_editpoints', stn_string)); %stn_string %files that go into producing pfiles.ctd_clean from pfiles.ctd_raw
                        pfiles.ctd_1hz = fullfile(MEXEC_G.data_root, 'ctd', sprintf('ctd_%s_%s_1hz.nc', MEXEC_G.mcruise, stn_string));
                        pfiles.ctd_10s = fullfile(MEXEC_G.data_root, 'ctd', sprintf('ctd_%s_%s_10s.nc', MEXEC_G.mcruise, stn_string));
                        pfiles.ctd_2db_dn = fullfile(MEXEC_G.data_root, 'ctd', sprintf('ctd_%s_%s_2db.nc', MEXEC_G.mcruise, stn_string));
                        pfiles.ctd_2db_up = fullfile(MEXEC_G.data_root, 'ctd', sprintf('ctd_%s_%s_2up.nc', MEXEC_G.mcruise, stn_string));
                        pfiles.ctd_nisk = fullfile(MEXEC_G.data_root, 'ctd', sprintf('fir_%s_%s.nc', MEXEC_G.mcruise, stn_string));
                        pfiles.ctd_castcut = fullfile(MEXEC_G.data_root, 'ctd', sprintf('dcs_%s_%s.nc', MEXEC_G.mcruise, stn_string));
                        %pfiles.ctd_win = fullfile(MEXEC_G.data_root, 'ctd', 'WINCH', sprintf('win_%s_%s.nc', MEXEC_G.mcruise, stn_string));                    pfiles.ctd_1hz_asc = fullfile(MEXEC_G.data_root, 'ladcp', 'ctd', sprintf('ctd.%s.asc',stn_string));
                        pfiles.ctd_1hz_asc = fullfile(MEXEC_G.data_root, 'ladcp', 'ctd', sprintf('ctd.%s.asc',stn_string));
                        %adcp on station average
                        if exist('SADCP_inst','var')
                            pfiles.sadcp_stnav = fullfile(MEXEC_G.data_root, 'vmadcp', 'mproc', sprintf('%s_%s_%s_ave.nc', SADCP_inst, MEXEC_G.mcruise, stn_string));
                        end
                    end
                    %other standard outputs
                    pfiles.svel = fullfile(MEXEC_G.data_root, 'bathy', 'svel_for_echosounders', sprintf('ctd_%s_10s_down_svel.csv',MEXEC_G.mcruise)); %don't store these, overwrite with latest
                    pfiles.ctd_nisk_sum = fullfile(MEXEC_G.data_root, 'collected_files', sprintf('station_summary_%s_all.nc', MEXEC_G.mcruise)); %cast stats
                    pfiles.sbe35 = fullfile(MEXEC_G.data_root, 'ctd', 'ASCII_FILES', 'SBE35', sprintf('sbe35_%s_all.nc', MEXEC_G.mcruise));
                    if exist('samtyp','var')
                        pfiles.(samtyp) = fullfile(MEXEC_G.data_root, 'bottle_samples', sprintf('%s_%s_all.nc', samtyp, MEXEC_G.mcruise));
                    end
                    %combined files for all sample (and comparison sensor) data
                    pfiles.samp_ctd = fullfile(MEXEC_G.data_root, 'bottle_samples', sprintf('samp_nisk_%s_all.nc', MEXEC_G.mcruise));
                    pfiles.samp_uway = fullfile(MEXEC_G.data_root, 'bottle_samples', sprintf('samp_ucsw_%s_all.nc', MEXEC_G.mcruise));
                    %underway data files (all days appended)
                    if exist('mtable','var') && exist('m','var') && exist('abbrev','var')
                        pfiles.uway_raw = fullfile(MEXEC_G.data_root,mtable.mstardir{m},sprintf('%s_%s_all_raw.nc', abbrev, MEXEC_G.mcruise));
                        pfiles.uway_edt = fullfile(MEXEC_G.data_root,mtable.mstardir{m},sprintf('%s_%s_all_edt.nc', abbrev, MEXEC_G.mcruise));
                    end
                    pfiles.nav_final = fullfile(MEXEC_G.data_root, 'nav', sprintf('bestnav_%s_all.nc', MEXEC_G.mcruise));
                    pfiles.ocean_final = fullfile(MEXEC_G.data_root, 'surfmet', sprintf('surface_ocean_%s_all.nc', MEXEC_G.mcruise));
                    pfiles.atmos_final = fullfile(MEXEC_G.data_root, 'surfmet', sprintf('atmos_truwind_%s_all.nc', MEXEC_G.mcruise));
                    pfiles.bathy_final = fullfile(MEXEC_G.data_root, 'bathy', sprintf('bathy_%s_all.nc', MEXEC_G.mcruise));
            end

        case 'adcp_proc'
            %set input files, instrument names, parameters for averaging
            %sadcp data processed using CODAS or another system
            switch opt2
                case 'sadcp_infiles'
                    foundit = true;
                    infiles.sadcp_all = fullfile(MEXEC_G.data_root, 'vmadcp', 'postprocessing', upper(MEXEC_G.mcruise), 'proc_editing', SADCP_inst, 'contour', [SADCP_inst '_' MEXEC_G.mcruise '.nc']);
                case 'sadcp_on_station'
                    foundit = true;
                    SADCP_inst = 'os75nb'; %***
                    min_nvmadcpprf = 3;      %throws a warning if number of vmADCP profiles within an LADCP cast is less than this
                    min_nvmadcpbin = 3;      %masks depths with number of valid bins less than this
                    min_nvmadcpbin_refl = 3; %throws a warning if number of good profiles at any depth in the watertrack reference layer is less than this
            end
            %set input and output*** files and contraints for processing LADCP
            %data using LDEO IX toolbox
            switch opt2
                case 'ladcp_files'
                    foundit = true;
                    %directory for raw (.000) ladcp data
                    rawdir = fullfile(MEXEC_G.data_root, 'ladcp','rawdata');
                    %uplooker and downlooker files in uppat and dnpat
                    %(allows wildcards in case of rare case of multiple
                    %files for one cast)
                    if stn==6
                        %mistakenly deployed with uplooker as master
                        uppat = ['UL' stn_string '00*m.000'];
                        dnpat = ['DL' stn_string '00*s.000'];
                    else
                        uppat = ['UL' stn_string '00*s.000'];
                        dnpat = ['DL' stn_string '00*m.000'];
                    end
                    pdir = fullfile(MEXEC_G.data_root,'ladcp','ix');
                    f.checkpoints = fullfile(pdir, 'checkpoints', stn_string);
                case 'ladcp_cfg'
                    foundit = true;
                    %parameters that can be set automatically (based on
                    %constraints being used, for example) are set in
                    %set_cast_params. here are others you may want to
                    %change from default:
                    %p.magdec_source = 1;
                    %p.drot = system()
                    %p.edit_mask_dn_bins = 1;
                    %p.edit_mask_up_bins = 1;
                    p.orig = 0; % save original data or not
                    p.ambiguity = 4.0; %this one is not used?
                    %p.vlim = 4.0; %this one is***require setting in opt_cruise
                    %set magnetic declination here, rather than using either of the two
                    %options built in to LDEO_IX/loadnav
                    %[p, f, ext] = fileparts(f.ctd); y0 = MEXEC_G.MDEFAULT_DATA_TIME_ORIGIN(1);
            end

        case 'ctd_proc'
            %set input files and parameters for processing of data from sensors
            %on the CTD frame (other than LADCP)
            switch opt2
                case 'ctd_infiles'
                    foundit = true;
                    helptext = 'specify input file (e.g. .cnv file), and the original sampling frequency';
                    if stn<=71
                        infiles.ctd_raw = fullfile(MEXEC_G.data_root, 'ctd', 'ASCII_FILES', sprintf('%s_%s.cnv', upper(MEXEC_G.mcruise), stn_string));
                    elseif stn==80
                        %CE26008_071.cnv is a yo-yo file containing casts
                        %71:79; CE26008_072.cnv is a yo-yo file containing
                        %casts 80:82
                        infiles.ctd_raw = fullfile(MEXEC_G.data_root, 'ctd', 'ASCII_FILES', 'CE26008_072.cnv');
                    else
                        warning('no .cnv file for stn=%d',stn)
                        infiles.ctd_raw = 'no_file';
                    end
                    infiles.ctd_raw_hz = 24;
                case 'raw_edits_corrs'
                    foundit = true;
                    sbe_ctd_coeffs %set co.hyst_oxy0 and co.pumpsNaN
                    %use rangelim first to exclude large spikes
                    co.rangelim.press = [-1.25 3300];
                    if stn<=45
                        co.rangelim.cond1 = [3 5];
                    else
                        co.rangelim.cond1 = [2.5 5];
                    end
                    co.rangelim.cond2 = co.rangelim.cond1;
                    co.rangelim.temp1 = [-2 18]; co.rangelim.temp2 = co.rangelim.temp1;
                    co.rangelim.turbidity = [0 1];
                    co.rangelim.fluor = [-0.05 8]; %leave values below 0 as this could be a calibration issue?
                    co.rangelim.transmittance = [0 100];
                    co.rangelim.turbidity = [0 1];
                    %co.rangelim.par = [0 100];
                    %then despike with 2 repetitions of a 12-scan median
                    %despiker
                    co.despike.press = [2 12; 2 12]; %avg 1m/s so 2 dbar/0.5 s is large
                    co.despike.temp1 = [0.5 12; 0.5 12];
                    co.despike.cond1 = [0.02 12; 0.02 12];
                    co.despike.temp2 = co.despike.temp1;
                    co.despike.cond2 = co.despike.cond1;
                    %then mask all other vars whenever P is bad
                    fn = setdiff(h.fldnam,{'press','scan','time','pumps','altimeter','dday'});
                    co.badpress = cell2struct(repmat({[NaN NaN]},length(fn),1),fn);
                    %23 has an oddity where the regularly-occurring spike
                    %in oxy2 stops at the bottom stop; meanwhile on 24 it
                    %looks worse there if anything, also on 28. likely
                    %depends on the wireout.
                    %025 unfortunately oxy2 also goes completely bad on the upcast
                    if stn<=34 %oxy1 is s/n 3339, oxy2 is s/n 2819
                        if ismember(stn,[2 13:15 18 19 21 22 24:32 34])
                            co.badscan.oxy1 = [-inf inf]; %2 bad coeffs, 13-15, 18, 22 have numerous/prolonged steps, others have too many bad segments, especially on the downcast
                        else
                            co.rangelim.oxy1 = [155 275];
                        end
                        co.rangelim.oxy2 = [170 290];
                        if stn==25
                            co.badscan.oxy2 = [151660 inf];
                        end
                    elseif stn>=35 && stn<=45 %oxy1 is s/n 3339, oxy2 is s/n 2819
                        co.badscan.oxy1 = [-inf inf]; %will have too many gaps to correct for hysteresis. 39 is missing points even in the cnv/raw stage
                        %co.rangelim.oxy1 = [215 290];
                        co.rangelim.oxy2 = [230 310];
                    elseif stn>=46 && stn<=58 %oxy1 is s/n 3339, oxy2 is s/n 2819
                        if ismember(stn,[46 52 53 56 57])
                            co.badscan.oxy1 = [-inf inf];
                        else
                            co.rangelim.oxy1 = [230 385];
                        end
                        co.rangelim.oxy2 = [240 390];
                    elseif stn>=59 && stn<=62 %oxy1 is s/n 2539, oxy2 is s/n 2819
                        co.rangelim.oxy2 = [260 385];
                        co.rangelim.oxy1 = [240 370];
                    elseif stn>=63 && stn<=68 %oxy1 is s/n 2819, oxy2 is s/n 2539
                        if ismember(stn,[63 66 68])
                            co.badscan.oxy1 = [-inf inf];
                        else
                            co.rangelim.oxy1 = [260 400];
                        end
                        co.rangelim.oxy2 = [230 400];
                    elseif stn>=69 %oxy1 is s/n 2819, oxy2 is s/n 2539
                        co.badscan.oxy1 = [-inf inf]; %not worth keeping oxy1 for these casts
                        co.rangelim.oxy2 = [220 400];
                    end
                    if ~isfield(co,'badscan') || ~isfield(co.badscan,'oxy1')
                        co.special.oxy1 = {
                            %@(x) isnan(median_despike(x(:,1)./x(:,2),24*20,0.02,[])) | [false; abs(diff(x(:,1)))>1], {'oxy1','oxy2'};...
                            @(x) isnan(oxy_spikeclean(x,24,0.02)), {'oxy1'}};
                        co.despike.oxy1 = [3 24; 3 24];
                    end
                    co.despike.oxy2 = [3 24; 3 24];
                    co.dpoff_calc = 60; %try to calculate deck pressure from first 60 s of record, when it is assumed to be stable on deck
                    co.dpoff_checked = [(72:79)', repmat(0.278,8,1);... %use dpoff from cast 71 for all yos in this set
                        [81;82], repmat(0.274,2,1)]; %use dpoff from cast 80 for all yos in this set
                    co.dooxy1V = 0; co.dooxy2V = 0; %don't recalculate oxy from V (set to 1 or 2 to recalculate using temp1 or temp2)
                    %set re_dooxyhyst = 1 to (re)do the oxygen hysteresis correction:
                    % if a correction was already applied in SBE processing,
                    %   reverse it using hyst_oxy0 (set in sbe_ctd_coeffs
                    %   above), then apply oxygen hysteresis correction
                    %   hyst_oxy1 (for oxy1) and hyst_oxy2 (for oxy2)
                    co.re_dooxyhyst = 1; %default: chose not to apply in SBE processing, so need to apply here even if coefficients not changed from default
                    co.hyst_oxy1 = co.hyst_oxy0; %apply default coefficients (defined in sbe_ctd_coeffs) to oxy1
                    co.hyst_oxy2 = co.hyst_oxy0;
                    co.hyst_oxy2.H3 = 1450;
                    co.hyst_oxy2.H1 = -0.026;
                    % number of seconds to shift oxygen earlier, based on delay in membrane response (varies from 1-8 S partially depending on temperature)
                    co.oxy_align = 1.5; %make upcast oxy(potemp) line up with downcast
                    co.doturbV = 0; %don't recalculate turbidity from V
            end
            switch opt2
                case 'nisk_infiles'
                    foundit = true;
                    infiles.ctd_nisk = fullfile(MEXEC_G.data_root, 'ctd', 'ASCII_FILES', sprintf('%s_%s.bl', upper(MEXEC_G.mcruise), stn_string));
                    helptext = 'specify input .bl or .btl files using stn_string';
            end
            switch opt2
                case 'sbe35_infiles'
                    foundit = true;
                    infiles.sbe35 = fullfile(MEXEC_G.data_root, 'ctd', 'ASCII_FILES', 'SBE35', sprintf('%s_*.txt', upper(MEXEC_G.mcruise)));
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
                case 'ctd_raw_extra'
                    foundit = true;
                    extrasource = []; split_castnos_scans = []; append_stn_strings = [];
                    if stn==22
                        %add time since it was not exported
                        extrasource = {'d.time = d.scan/24;'};
                        extravars = {'time'; 'seconds since 2026-07-28 15:41:17'};
                    elseif stn==25
                        %cast split over two files, 025 and 025b
                        append_stn_strings = {'025b'};
                        append_scan_offsets = 154152;
                    elseif stn==71
                        %one file contains 8 yo-yo casts (71-79)
                        split_castnos_scans = {'071' 35334;
                            '072' 63917;
                            '073' 91835;
                            '074' 121035;
                            '075' 151810;
                            '076' 180860;
                            '077' 210901;
                            '078' 242311;
                            '079' inf};
                    elseif stn==80
                        %one file contains 3 yo-yo casts (80-82)
                        split_castnos_scans = {'080' 74124;
                            '081' 132166;
                            '082' inf};
                    end
                case 'cnv_header_edits'
                    foundit = true;
                    h.comment = replace(h.comment,'PSO: Caroline Cusack','PSO: Yvonne Firing');
                case 'metadata_edits'
                    add_stns_depths_times = []; %add or replace in list
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
                case 'ctd_checkplots'
                    foundit = true;
                    saltype = 'psal'; %plot practical salinity
                case '1hz_interp'
                    foundit = true;
                    maxfillr = infiles.ctd_raw_hz/2; %fill up to 0.5 s in cleancal data before averaging to 1 hz
                    maxfill1 = 1; %fill up to 1 s after averaging to 1 hz
                case 'profiles'
                    foundit = true;
                    doloopedit = 0;
                    ptol = 0.08; %default is not to apply if doloopedit = 0, but these would be the default values if you did
                    spdtol = 0.24; %default value from SBE program
                    %these settings, along with the default of filling up to 1 s in the time
                    %series, mean there is not at this stage any interpolation over more than
                    %2 dbar (which would necessitate a woce flag of 6)
                    g2opts.pbin = 2; %2 dbar bins
                    g2opts.postfill = 0; %don't fill after gridding
                    g2opts.ignore_nan = 1;
                    g2opts.int = [-1 1]; %interval for bins
                    g2opts.grid_ends = [0 0]; %discard empty bins
                    g2opts.bin_partial = 0; %only use bins with data in both halves
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
                    yl.press = [-1 ceil(d.press(ddcs.dcr_bot)/100)*100+10];
                    yl.fluor = [0 8]; yl.par = [0 40];
                    if stn>24
                        yl.oxy = [180 320];
                    end
                    if stn>40
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
                case 'samp_nisk_infiles'
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
                    infiles.ctd_nisk_flags = fullfile(MEXEC_G.data_root, 'bottle_samples', 'LOGS', 'niskin_samples_log_ce26008.csv'); %flags from sampling logsheet (leaks or misfires)
                    f = readtable(infiles.ctd_nisk_flags,'Delimiter',',');
                    f = f(f.statnum==stn,:);
                    [~,ia,ib] = intersect(position,f.position,'stable');
                    niskin_flag(ia) = f.niskin_flag(ib);
                    niskin_flag(position==3) = 4; %latch does not release
                case 'samp_infiles'
                    foundit = true;
                    helptext = 'set list of files to load for a particular samtyp, and set sopts to specify how to read in csv/spreadsheet files';
                    %how to read in csv/spreadsheet files
                    sopts.remove_empty_cols = 1;
                    infiles.uway_log = fullfile(MEXEC_G.data_root,'bottle_samples','uway_sample_log.csv');
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
                case 'grid'
                    foundit = true;
                    %compile and grid these sensor variables:
                    ctd_regridlist  = {'temp', 'psal', 'potemp', 'oxy', 'fluor', 'transmittance', 'par'};
                    %and these sample variables:
                    sam_gridlist = {'botoxy', 'silc', 'phos', 'totnit', 'botpsal', 'dic', 'talk', 'ph'};
                    mgrid.sdata_flag_accept = [2 3]; %***or just 2
                    if contains(section,'ar7e')
                        mgrid.xlim = 2; mgrid.zlim = 4;
                    elseif contains(section,'km')
                        mgrid.xlim = 2; mgrid.zlim = 4;
                    elseif contains(section,'ta')
                    elseif contains(section,'kgh')
                    end
                    if strcmp(section,'ungridded')
                        otfile = fullfile(MEXEC_G.data_root,'ctd',['allctd_' MEXEC_G.mcruise '_2db.mat']);
                    elseif strcmp(section,'quick')
                        otfile = fullfile(MEXEC_G.data_root,'ctd',['allctd_' MEXEC_G.mcruise '_quick.mat']);
                    else
                        otfile = fullfile(MEXEC_G.data_root,'mapped',['grid_' MEXEC_G.mcruise '_' section '.mat']);
                    end
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
        fprintf(2,'opt1 = ''%s'', opt2 = ''%s'' was not found in %s\n',opt1,opt2,mfilename)
    else
        fprintf(2,'opt1 = ''%s'' with no opt2 was not found in %s\n',opt1,mfilename)
    end
end