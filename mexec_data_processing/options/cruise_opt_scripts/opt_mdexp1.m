% processing settings for cruise mdexp1

% at the time this file was initialised, MEXEC_G included:
% datatypes.ctd: 'sbe'
% datatypes.nisk: 'sbe'
% datatypes.tref: 'no'
% datatypes.uway: 'scs'
% datatypes.sadcp: 'codas'
% datatypes.ladcp: 'ix'
% datatypes.moor: 'no'
% data_time_origin_string: '2026-01-01 00:00:00'
% mexec_version: 'e1b6412c (last commit)'

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
                    stn_string = sprintf('%03d',stn); %stainless casts
                case 'pfiles'
                    foundit = true;
                    helptext = 'specify paths and names of processed data files (created by mexec_data_processing, and possibly used by later steps)';
                    pfiles.ctd_raw = fullfile(MEXEC_G.data_root, 'ctd', ['ctd_' MEXEC_G.mcruise '_stn_string_cnv.nc']); %stn_string
                    pfiles.ctd_cleancal = fullfile(MEXEC_G.data_root, 'ctd', ['ctd_' MEXEC_G.mcruise '_stn_string_24hz.nc']); %stn_string
                    pfiles.ctd_editsrecords = fullfile(MEXEC_G.data_root, 'ctd', 'editlogs', 'ctd_stn_string_editpoints'); %stn_string %files that go into producing pfiles.ctd_clean from pfiles.ctd_raw
                    pfiles.ctd_1hz = fullfile(MEXEC_G.data_root, 'ctd', ['ctd_' MEXEC_G.mcruise '_stn_string_1hz.nc']); %stn_string
                    pfiles.ctd_10s = fullfile(MEXEC_G.data_root, 'ctd', ['ctd_' MEXEC_G.mcruise '_stn_string_10s.nc']); %stn_string
                    pfiles.ctd_2db_dn = fullfile(MEXEC_G.data_root, 'ctd', ['ctd_' MEXEC_G.mcruise '_stn_string_2db.nc']); %stn_string
                    pfiles.ctd_2db_up = fullfile(MEXEC_G.data_root, 'ctd', ['ctd_' MEXEC_G.mcruise '_stn_string_2up.nc']); %stn_string
                    pfiles.ctd_nisk = fullfile(MEXEC_G.data_root, 'ctd', ['fir_' MEXEC_G.mcruise '_stn_string.nc']); %stn_string
                    pfiles.ctd_castcut = fullfile(MEXEC_G.data_root, 'ctd', ['dcs_' MEXEC_G.mcruise '_stn_string.nc']); %stn_string
                    pfiles.ctd_win = fullfile(MEXEC_G.data_root, 'ctd', 'WINCH', ['win_' MEXEC_G.mcruise '_stn_string.nc']); %stn_string
                    %other standard outputs
                    pfiles.svel = fullfile(MEXEC_G.data_root, 'bathy', 'svel_for_echosounders', ['ctd_' MEXEC_G.mcruise '_10s_down_svel.csv']);
                    pfiles.ctd_nisk_sum = fullfile(MEXEC_G.data_root, 'collected_files', ['station_summary_' MEXEC_G.mcruise '_all.nc']); %***
                    pfiles.sbe35 = fullfile(MEXEC_G.data_root, 'ctd', 'ASCII_FILES', 'SBE35', ['sbe35_' MEXEC_G.mcruise '_all.nc']);
                    if exist('samtyp','var')
                        pfiles.(samtyp) = fullfile(MEXEC_G.data_root, 'bottle_samples', [samtyp '_' MEXEC_G.mcruise '_all.nc']);
                    end
                    %combined files for all sample (and comparison sensor) data
                    pfiles.samp_ctd = fullfile(MEXEC_G.data_root, 'bottle_samples', ['samp_nisk_' MEXEC_G.mcruise '_all.nc']);
                    pfiles.samp_uway = fullfile(MEXEC_G.data_root, 'bottle_samples', ['samp_ucsw_' MEXEC_G.mcruise '_all.nc']);
                    %underway data files
                    if exist('mtable','var') && exist('m','var')
                        pfiles.uway_raw = fullfile(MEXEC_G.data_root,mtable.mstardir{m},['abbrev_' MEXEC_G.mcruise '_all_raw.nc']); %abbrev
                        pfiles.uway_edt = fullfile(MEXEC_G.data_root,mtable.mstardir{m},['abbrev_' MEXEC_G.mcruise '_all_edt.nc']); %abbrev
                    end
                    pfiles.nav_final = fullfile(MEXEC_G.data_root, 'nav', ['bestnav_' MEXEC_G.mcruise '_all.nc']);
                    pfiles.uocean_final = fullfile(MEXEC_G.data_root, 'surfmet', ['surface_ocean_' MEXEC_G.mcruise '_all.nc']);
                    pfiles.met_final = fullfile(MEXEC_G.data_root, 'surfmet', ['atmos_truwind_' MEXEC_G.mcruise '_all.nc']);
                    pfiles.bathy_final = fullfile(MEXEC_G.data_root, 'bathy', ['bathy_' MEXEC_G.mcruise '_all.nc']);
                    %adcp
                    if exist('inst','var')
                        pfiles.sadcp_stnav = fullfile(MEXEC_G.data_root, 'vmadcp', 'mproc', [inst '_' MEXEC_G.mcruise '_stn_string_ave.nc']); %stn_string
                    end
            end

        case 'adcp_proc'
            %set input and output files, instrument names, parameters for
            %averaging sadcp data processed using CODAS or another system
            switch opt2
                case 'sadcp_infiles'
                    foundit = true;
                    infiles.sadcp_all = fullfile(MEXEC_G.data_root, 'vmadcp', 'postprocessing', upper(MEXEC_G.mcruise), 'proc_editing', inst, 'contour', [inst '_' MEXEC_G.mcruise '.nc']);
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
                    cfg.stnstr = stn_string;
                    %file and format for ascii file of 1hz ctd data and corresponding nmea nav data
                    cfg.f.ctd = fullfile(MEXEC_G.data_root, 'ladcp', 'ctd', sprintf('ctd.%s.asc',stn_string));
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
                    if exist('inst','var')
                        cfg.f.sadcp = replace(pfiles.sadcp_stnav,'stn_string',stn_string);
                    end
                    cfg.rawdir = fullfile(MEXEC_G.data_root, 'ladcp','rawdata');
                    if stn==6
                        cfg.uppat = sprintf('UL%s00*m.000',cfg.stnstr);
                        cfg.dnpat = sprintf('DL%s00*s.000',cfg.stnstr);
                    else
                        cfg.uppat = sprintf('UL%s00*s.000',cfg.stnstr);
                        cfg.dnpat = sprintf('DL%s00*m.000',cfg.stnstr);
                    end
                case 'ladcp_cfg'
                    foundit = true;
                    %file for vmadcp data corresponding to this cast. if available, use
                    %the instrument/mode with deepest range
                    %parameters for LADCP processing
                    %cfg.p.magdec_source = 1;
                    %cfg.p.drot = system()
                    %cfg.p.edit_mask_dn_bins = 1;
                    %cfg.p.edit_mask_up_bins = 1;
                    cfg.p.orig = 0; % save original data or not
                    isul = 1; %is there an uplooker? process it first on its own
                    cfg.p.ambiguity = 4.0; %this one is not used?
                    %cfg.p.vlim = 4.0; %no default set; check LADCP configuration and
                    %set to match
            end


        case 'ctd_proc'
            %set input files and parameters for processing of data from the
            %CTD/rosette system and other sensors on the CTD frame (except
            %LADCP)
            switch opt2
                %lines to be added to opt_cruise file, under opt1 = 'ctd_proc' by
                %create_opt_cruise, if MEXEC_G.datatypes.ctd = 'sbe'
                case 'ctd_infiles'
                    foundit = true;
                    helptext = 'specify input .cnv file pattern to be resolved using stn_string';
                    %set patterns for input file paths and names, will be filled with stn_string from the m_stn_string case above
                    if ismember(stn,[1 4:2:20]) %stainless rosette casts, for example (modify!)
                        infiles.ctd_raw = fullfile(MEXEC_G.data_root, 'ctd', 'ASCII_FILES', ['CTD_' MEXEC_G.mcruise '_stn_stringS.cnv']); %stn_string
                    else
                        infiles.ctd_raw = fullfile(MEXEC_G.data_root, 'ctd', 'ASCII_FILES', ['CTD_' MEXEC_G.mcruise '_stn_stringT.cnv']); %stn_string
                    end
                case 'raw_edits_corrs'
                    foundit = true;
                    sbe_ctd_coeffs %set co.hyst_oxy0 and co.pumpsNaN
                    co.dpoff_calc = 60; %try to calculate deck pressure from first 60 s of record, when it is assumed to be stable on deck
                    co.dpoff_checked = []; %list of
                    % number of seconds to shift oxygen earlier, based on delay in membrane response (varies from 1-8 S partially depending on temperature)
                    co.oxy_align = 2; %check hysteresis first?
                    co.doturbV = 0; %don't recalculate turbidity from V
                    %unusual: set dooxy1V or dooxy2V to 1 or 2 to recalculate using
                    %temp1 or temp2
                    co.dooxy1V = 0; co.dooxy2V = 0;
                    %apply default oxygen hysteresis correction (if it was already applied in SBE processing, and no new coefficients are supplied, this will be skipped)
                    co.re_dooxyhyst = 1;
                    co.hyst_oxy1 = co.hyst_oxy0;
                    co.hyst_oxy2 = co.hyst_oxy0;
            end

            switch opt2
                %lines to be added to opt_cruise file, under opt1 = 'ctd_proc' by
                %create_opt_cruise, if MEXEC_G.datatypes.nisk = 'sbe'
                case 'nisk_infiles'
                    foundit = true;
                    helptext = 'specify input .bl or .btl file pattern to be resolved using stn_string';
                    %set patterns for input file paths and names (including %s
                    %to be filled with stn_string as set by setup,
                    %m_stn_string case above)
                    infiles.ctd_nisk_fir = fullfile(MEXEC_G.data_root, 'ctd', 'ASCII_FILES', ['CTD_' MEXEC_G.mcruise '_stn_string.bl']); %stn_string
            end

            switch opt2
                case 'ctd_raw_extra'
                    foundit = true;
                    helptext = 'if necessary, set to create time variable (if missing) or add variables absent for only some stations as NaNs';
                    extrasource = {}; extravars = {};
                    append_stn_strings = {}; append_scan_offsets = [];
                    split_castnos_scans = [];
                case 'header_edits'
                    foundit = true;
                    helptext = 'edit CTD file header information, e.g. cruise code, PI, etc.';
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
                    ts_choice = 1; %CTD1 is preferred; temp = temp1; cond = cond1
                    o_choice = 1; %CTD-DO1 is preferred; oxy = oxy1
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
                    pg = [0:2:1e4]';
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
                    repars.g2 = {{'press'},{'fluor'},{'turbidity'},{'transmittance'},{'par'}};
                    yl.temp = [-2 40]; yl.temp1 = yl.temp; yl.temp2 = yl.temp;
                    if strcmp(h.fldunt{strcmp(h.fldnam,'cond1')},'S/m')
                        yl.cond = [2 4];
                    else
                        yl.cond = [20 40];
                    end
                    yl.cond1 = yl.cond; yl.cond2 = yl.cond;
                    yl.press = [-2 6000];
                    yl.oxy = [100 400]; yl.oxy1 = yl.oxy; yl.oxy2 = yl.oxy;
                    yl.fluor = [0 8];
                    yl.turbidity = [0 1]; yl.transmittance = [60 101]; yl.par = [0 200];
                    doed = 1; %always end mctd_raw_show_check by running mctd_rawedit (can turn this off in opt_cruise)
                    %ctd flags: 1 not calibrated, 2 acceptable, 3 questionable
                    %,4 bad, 5 not reported, 6 interpolated over > 2 dbar, 7
                    %despiked
                    edit_vars_exclude = {'pressure_temp'}; %starts with press but don't plot this
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
                case 'nisk_numbers'
                    foundit = true;
                    nnisk = 24;
                    niskin_pos = (1:nnsik)'; %position on firing carousel
                    niskin_number = (1:nnisk)'; %replace with S/N, bedford number, etc.
                case 'fir_fill'
                    foundit = true;
                    firmethod = 'medint';
                    clear firopts;
                    firopts.int = [-1 120]; %average over 5 s, like in .ros file***
                    firopts.prefill = 24*5; %fill gaps up to 5 s first
                case 'fir_extra'
                    foundit = true;
                    fir_extra = true; %do also add background gradient and variance, and density-matched downcast data, to fir_ (and sam_) file
            end

        case 'samp_proc'
            switch opt2
                case 'samp_infiles'
                    foundit = true;
                    helptext = 'set list of files to load for a particular samtyp, and set sopts to specify how to read in csv/spreadsheet files';
                    %how to read in csv/spreadsheet files
                    sopts.remove_empty_cols = 1;
                case 'samp_file_parse'
                    foundit = true;
                    clear varmap
                    %keepothervars, varmap
                    addcomment = '';
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
                case 'sbe35_flags'
                    foundit = true;
                    %convention to follow: as for CTD or as for bottle data?
                    %no defaults
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
                case 'station_lists'
                    foundit = true;
                    %statnums for each section
                    kstns.all = [1:999];
                case 'summary_counts'
                    foundit = true;
                    samp_groups.sal = {'botpsal'};
                    samp_groups.oxy = {'botoxy'};
                    samp_groups.nut = {'silc','phos','totnit'};
                case 'grid'
                    foundit = true;
                    ctd_regridlist  = {'temp' 'psal' 'potemp' 'oxy', 'fluor', 'transmittance', 'par'}; %grid these variables
                    sam_gridlist = {'botpsal', 'botoxy', 'silc', 'phos', 'totnit'}; %grid these variables
                    mgrid.sdata_flag_accept = [2 3]; %or just 2
                    if strcmp(section,'ungridded')
                        otfile = fullfile(MEXEC_G.data_root,'ctd',['allctd_' MEXEC_G.mcruise '_2db.mat']);
                    elseif strcmp(section,'quick')
                        otfile = fullfile(MEXEC_G.data_root,'ctd',['allctd_' MEXEC_G.mcruise '_quick.mat']);
                    else
                        otfile = fullfile(MEXEC_G.data_root,'mapped',['grid_' MEXEC_G.mcruise '_' section '.mat']);
                    end
                case 'section_for_station'
                    foundit = true;
                    %set list of sections (from station_lists above) that
                    %correspond to this station?
                case 'columndata'
                    foundit = true;
                    outtypes = {'bodc','exch'};
                case 'exch'
                    foundit = true;
                    expocode = 'unknown';
                    sect_id = '';
                    submitter = whoami; %group institution person
                    ns = nan;
                    common_headstr = {'#Ship: ';...
                        '#Cruise ';...
                        '#Region ';...
                        ['#EXPOCODE: ' expocode];...
                        '#DATES:  - ';...
                        '#Chief Scientist: Name (Institution); Co-Chief Scientist: Name (Institution)';...
                        '#Supported by '};
                    if strcmp(params.in,'ctd')
                        headstring = {['CTD,' datestr(now,'yyyymmdd') submitter]};
                        headstring = [headstring; common_headstr;
                            {sprintf('#%d stations with 24-place rosette',ns);...
                            '#CTD: Who - ; Status - .';... %preliminary/final
                            % '#The CTD PRS; TMP; SAL; OXY data are all calibrated and good.';...
                            '# DEPTH_TYPE   : ';... %COR / UNCOR
                            % '# DEPTH_TYPE   : rosette depth from CTDPRS + CTD altimeter range to bottom, or speed of sound-corrected ship-mounted bathymetric echosounder'...
                            }];
                    else
                        headstring = {['BOTTLE,' datestr(now,'yyyymmdd') submitter]};
                        headstring = [headstring; common_headstr;
                            {sprintf('#%d stations with 24-place rosette',ns);...
                            '#CTD: Who - ; Status - ';...
                            '#Notes: Includes CTDSAL, CTDOXY, CTDTMP';...
                            % '#The CTD PRS; TMP; SAL; OXY data are all calibrated and good.';...
                            % '# DEPTH_TYPE   : rosette depth from CTDPRS + CTD altimeter range to bottom';...
                            '#Salinity: Who - ; Status - ; SSW batch P   .';...
                            '#Oxygen: Who - ; Status - .';...
                            %'#Nutrients: Who - ; Status - .';...
                            % '#DIC and Talk: Who - ; Status - .';...
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
