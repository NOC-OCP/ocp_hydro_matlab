% this script is called by get_cropt to set defaults for
% parameters/variables used by multiple scripts (those used in only one
% script are set in situ), before calling opt_cruise to set cruise-specific
% parameters if applicable
%
% see get_cropt help
%
% options are specified by switch-case through two
% variables:
%     opt1 (usually the name of the calling script)
%     opt2 (another string, which for ease of searching should be
%         kept unique, not reused under different opt1s)


switch opt1

    case 'setup'
        switch opt2
            case 'time_origin'
                %no default, set MEXEC_G.MDEFAULT_DATA_TIME_ORIGIN
            %case 'use_ix_ladcp'
            %    use_ix_ladcp = 'query'; %'query' means ask each time; or set to 'no' or 'yes'
        end

    case 'mstar'
        %things about mstar file format
        if MEXEC_G.MDEFAULT_DATA_TIME_ORIGIN(1)>=2024
            docf = 1; %cf-compliant time units
        else
            docf = 0; %use seconds since h.data_time_origin, units called 'seconds'
        end

    case 'ship'
        %parameters related to ship underway data
        switch opt2
            case 'datasys_best'
                switch MEXEC_G.Mshipdatasystem
                    case 'techsas'
                        uway_torg = datenum([1899 12 30 0 0 0]); % techsas time origin as a matlab datenum
                        uway_root = fullfile(MEXEC_G.mexec_data_root, 'techsas', 'netcdf_files_links');
                        if ismac; uway_root = [uway_root '_mac']; end
                    case 'scs'
                        uway_torg = 0; % mexec parsing of SCS files converts matlab datenum, so no offset required
                        uway_root = fullfile(MEXEC_G.mexec_data_root, 'scs', 'scs_raw'); % scs raw data on logger machine
                        uway_sed = fullfile(MEXEC_G.mexec_data_root, 'scs', 'scs_sed'); % scs raw data on logger machine
                        uway_mat = fullfile(MEXEC_G.mexec_data_root, 'scs', 'scs_mat'); % local directory for scs converted to matlab
                    case 'rvdas'
                        uway_torg = 0; % mrvdas parsing returns matlab dnum. No offset required.
                end
            case 'ship_data_sys_names'
                switch MEXEC_G.Mshipdatasystem
                    case 'rvdas'
                        tsgpre = 'tsg';
                        metpre = 'surfmet';
                    case 'techsas'
                        tsgpre = 'tsg';
                        metpre = 'met';
                    case 'scs'
                        tsgpre = 'oceanlogger';
                        metpre = 'met';
                end
            case 'rvdas_database'
                RVDAS.csvroot = fullfile(MEXEC_G.mexec_data_root, 'rvdas', 'rvdas_csv_tmp');
                %RVDAS.jsondir = '/data/pstar/mounts/links/mnt_cruise_data/Ship_Systems/Data/RVDAS/sensorfiles/';
                RVDAS.database = ['"' upper(MEXEC_G.MSCRIPT_CRUISE_STRING) '"'];
            case 'rvdas_form'
                switch MEXEC_G.Mship
                    case 'sda'
                        use_cruise_views = 1; %prepend string view_name to names from json files
                        view_name = lower(MEXEC_G.MSCRIPT_CRUISE_STRING);
                        npre = 1; %table names start with an extra prefix before the instrument make/model e.g. anemometer_ft_technologies_etc
                    otherwise
                        npre = 0; %table names start with instrument name
                        use_cruise_views = 0;
                end
            case 'rvdas_skip'
                %see opt_dy181
        end
        
    case 'ctd_proc'
        switch opt2
            %multiple files
            case 'minit'
                if ~exist('stn', 'var'); stn = input('type stn number '); end
                stn_string = sprintf('%03d',stn); %used for file names
                stnlocal = stn;
            case 'oxy_align'
                %name in raw file, name in 24 hz file (don't change the 2nd
                %column!)
                oxyvars = {'oxygen_sbe1', 'oxygen1'; 'oxygen_sbe2', 'oxygen2'};
                oxyunit = 'umol/kg';
                oxy_align = 6; %number of seconds by which oxygen has been shifted in SBE processing (or should be shifted by mctd_02)
                oxy_end = 1; %set to 1 to truncate O oxy_align seconds earlier than T, C
                %mctd_01
            case 'redoctm'
            case 'cnvfilename'
            case 'cast_split_comb'
            case 'ctd_raw_extra'
                clear ctd_raw_extra
            case 'header_edits'
                %mctd_02
            case 'rawedit_auto'
                %when pumps are off
                co.pumpsNaN.temp1 = 12; %T takes 1/2 s to recover
                co.pumpsNaN.temp2 = 12;
                co.pumpsNaN.cond1 = 12;
                co.pumpsNaN.cond2 = 12;
                co.pumpsNaN.oxygen_sbe1 = 8*24; %O takes 8 s to recover
                co.pumpsNaN.oxygen_sbe2 = 8*24;
            case 'raw_corrs'
                oxyrev.H1 = -0.033;
                oxyrev.H2 = 5000;
                oxyrev.H3 = 1450;
                oxyhyst.H1 = -0.033;
                oxyhyst.H2 = 5000;
                oxyhyst.H3 = 1450;
                co.H_0 = [oxyhyst.H1 oxyhyst.H2 oxyhyst.H3]; %this line stores defaults for later reference; don't change!
            case 'ctd_cals'
                co.docal.temp = 0; %do not apply any calibration to temp
                co.docal.cond = 0; %do not apply any calibration to cond
                co.docal.oxygen = 0; %do not apply any calibration to oxy
                co.docal.fluor = 0; %etc
                co.docal.transmittance = 0; %etc
                if isfield(co,'calstr')
                    co = rmfield(co,'calstr'); %no default, must be set by opt_{cruise}
                end
                %mctd_03
            case 'sensor_choice'
                s_choice = 1; %CTD1 is primary
                stns_alternate_s = []; %on these stations it's the other one
                o_choice = 1; %oxygen1 is primary
                stns_alternate_o = []; %on these stations it's the other one
            case '1hz_interp'
                maxfill24 = 0; maxfill1 = 2;
                %other steps
            case 'ctdsens_groups'
                sgfile = fullfile(mgetdir('ctd'),'sensor_groups.mat'); %generated by get_sensor_groups, contains sg, sng
            case 'rawshow'
                %by default, do not plot press_temp, turb, xmiss, fluor,
                %lat, lon in mctd_rawshow
                rawplotvars = {'temp1','temp2','cond1','cond2','press','oxygen_sbe1','oxygen_sbe2'};
                show1 = 1; %do plot 1 hz also
        end

    case 'nisk_proc'
        switch opt2
            case 'blfilename'
            case 'botflags'
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
            case 'niskins'
                niskin_number = [1:24]'; %s/n
                niskin_pos = [1:24]'; %position (firing number)
            case 'fir_fill'
        end

    case 'uway_proc'
        switch opt2
            case 'tstep_save'
                %subsample high-frequency streams and match up different
                %messages from the same system by rounding timestamp
                %if your samples are coming in at a *regular* high
                %frequency (e.g. 40Hz on the SDA), set tstep_force to
                %subsample to (approximately) 1/tstep_force hz before
                %saving 
                tstep_force = []; 
                %round time to nearest tstep_resol s before saving
                tstep_resol = 1; 
            case 'time_problems'
                fixtimes = 0; check_mono = 0; %assume no repeated or backwards times at edit stage
            case 'sensor_unit_conversions'
                so = struct(); %default: none, parameters are read from database in physical units
            case 'rawedit'
                %lots of these (including ranges for many parameters), so
                %set in separate function 
                uopts = mday_01_default_autoedits(h, streamtype);
                handedit = 0;
            case 'avedit'
                uopts = struct();
                vars_to_ed = setdiff(fieldnames(dg)',{'dday','time','times'});
                if strcmp(datatype,'bathy')
                    handedit = 1;
                elseif strcmp(datatype,'ocean')
                    handedit = 1;
                else
                    handedit = 0;
                end
            case 'tsg_cals'
                uo.docal.temp = 0; %do not apply any calibration to tsg temp
                uo.docal.cond = 0; %etc
                uo.docal.fluor = 0; %etc
                if isfield(uo,'calstr')
                    uo = rmfield(uo,'calstr'); %no default, must be set by opt_{cruise}
                    %see opt_sd025 for examples
                end
            case 'uway_av'
                %tavp in s
                switch datatype
                    case 'nav'
                        tavp = 30;
                        method = 'meanbin';
                    case 'bathy'
                        tavp = 5*60; 
                        method = 'medbin';
                    case 'tsg'
                        tavp = 60;
                        method = 'medbin';
                    case 'wind'
                        tavp = 30;
                        method = 'meanbin';
                end
        end

    case 'ladcp_proc'
        min_nvmadcpprf = 3;      %throws a warning if number of vmADCP profiles within an LADCP cast is less than this
        min_nvmadcpbin = 3;      %masks depths with number of valid bins less than this
        min_nvmadcpbin_refl = 3; %throws a warning if number of good profiles at any depth in the watertrack reference layer is less than this
        spath = fullfile(mgetdir('M_LADCP'), 'ix', 'SADCP');
        sfile = fullfile(spath, sprintf('os75nb_%s_ctd_%03d_forladcp.mat',mcruise,stn));

    case 'samp_proc'
        switch opt2
            case 'files'
                switch samtyp
                    case 'chl'
                        allctd = 0;
                    case 'oxy'
                        sopts.hcpat = {'Bottle';'Number'}; %Flag is on 2nd line so start here
                        stops.icolhead = 1;
                        sopts.icolunits = 2;
                        allctd = 1; 
                    case 'nut'
                        allctd = 1; %don't usually have underway, and may need to fill in statnum on some lines
                    case 'sal'
                        sopts.DateLocale = "en_GB"; %***
                        allctd = 0; %usually have underway too
                end
            case 'parse'
                msam_load_parse_defaults %script with switch-case to set varmap and calc flags
            case 'check'
                checksam.chl = 0;
                checksam.oxy = 1;
                checksam.nut = 1;
                checksam.sal = 1;
                checksam.sbe35 = 1;
            case 'flags'
                ft = {'1 sample drawn but analysis not received';
                    '2 acceptable';
                    '3 questionable';
                    '4 bad';
                    '5 not reported';
                    '6 mean of duplicates';
                    '9 sample not drawn'};
                if ~MEXEC_G.quiet
                    fprintf(1,'using WOCE flags: \n%s', ft{:})
                end
            case 'calc'
                switch samtyp
                    case 'oxy'
                        labT = 25;
                        vol_reag_tot = 2;
                end
        end

    case 'outputs'
        switch opt2
            case 'grid'
                ctd_regridlist  = {'temp' 'psal' 'potemp' 'oxygen'}; %grid these variables
                sam_gridlist = {'botpsal' 'botoxy'}; %grid these variables
            case 'ladcp'
                %set file location and format for ascii file of 1hz ctd
                %data (same as nav file) and location for sadcp file
                cfg.f.ctd = fullfile(mgetdir('ladcp'), 'ctd', ['ctd.' stn_string '.02.asc']);
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
                cfg.f.sadcp = fullfile(mgetdir('ladcp'),'ix','SADCP',['os75nb_' mcruise '_' cfg.stnstr '_for_ladcp.mat']);
            case 'exch'
                expocode = 'unknown';
                sect_id = '';
                vars_exclude_ctd = {}; %changed jc238 from {'fluor' 'transmittance'};
                vars_exclude_sam = {};
                vars_rename = {}; %first column in m_exch_vars_list, newname (e.g. CTDTURB, CTDBETA650_124)
            case 'bodc'
                %vars_exclude = {};
            case 'plot' %***
                station_depth_width = 0;
                bottle_depth_size = 0;

        end

end
