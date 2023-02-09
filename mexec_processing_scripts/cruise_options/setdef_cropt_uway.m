% this script is called by get_cropt to set defaults for
% parameters/variables used by other scripts,
% before calling opt_cruise to set cruise-specific parameters if applicable
%
% see get_cropt help
%
% options are specified by switch-case through two
% variables:
%     scriptname (usually the name of the calling script)
%     oopt (another string, which for ease of searching should be
%         kept unique, not reused under different scriptnames)


switch scriptname

    %%%%%%%%%% ship (not a script) %%%%%%%%%%
    case 'ship'
        %parameters used by multiple scripts, related to ship underway data
        switch oopt
            case 'datasys_best'
                crhelp_str = {'Set (or overwrite) ship-based defaults for data '
                    'system and best navigation and heading/attitude streams '
                    '(MEXEC_G.default_navstream and MEXEC_G.default_hedstream'};
                if strcmp(MEXEC_G.Mship,'sda')
                    default_navstream = 'posseapath_320_1';
                    default_hedstream = 'hdtseapath_320_1';
                elseif ismember(MEXEC_G.Mship,{'cook','discovery'})
                    if strcmp(MEXEC_G.Mshipdatasystem,'rvdas')
                        default_navstream = 'pospmv';
                        default_hedstream = 'attpmv';
                    else
                        default_navstream = 'posmvpos';
                        default_hedstream = 'attposmv';
                    end
                elseif strcmp(MEXEC_G.Mship,'jcr')
                    default_navstream = 'seatex_gll';
                    default_hedstream = 'seatex_hdt';
                elseif ismember(MEXEC_G.Mship,{'knorr','endeavor'})
                    warning('add fields default_navstream and default_hedstream here or in opt_{cruise}.m');
                else
                    warning('No underway data system and default nav streams set for %s',MEXEC_G.Mship)
                end
                switch MEXEC_G.Mshipdatasystem
                    case 'techsas'
                        uway_torg = datenum([1899 12 30 0 0 0]); % techsas time origin as a matlab datenum
                        uway_root = fullfile(MEXEC_G.mexec_data_root, 'techsas', 'netcdf_files_links');
                        if ismac; uway_root = [uway_root '_mac']; end
                    case 'scs'
                        uway_torg = 0; % mexec parsing of SCS files converts matlab datenum, so no offset required
                        uway_root = fullfile(MEXEC_G.mexec_data_root, 'scs_raw'); % scs raw data on logger machine
                        uway_sed = fullfile(MEXEC_G.mexec_data_root, 'scs_sed'); % scs raw data on logger machine
                        uway_mat = fullfile(MEXEC_G.mexec_data_root, 'scs_mat'); % local directory for scs converted to matlab
                    case 'rvdas'
                        uway_torg = 0; % mrvdas parsing returns matlab dnum. No offset required.
                end
            case 'ship_data_sys_names'
                crhelp_str = {'Datasystem- (and possibly ship-) specific list of mexec directory names '
                    'for tsg file (tsgpre) and surfmet file (metpre).'};
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
            case 'avtime'
                crhelp_str = {'Number of seconds over which to average nav, met, and tsg measurements'
                    'in appended files.'};
                avnav = 30;
                avmet = 60;
                avtsg = 60;
        end
        %%%%%%%%%% end ship (not a script) %%%%%%%%%%
        
        %%%%%%%%%% mrvdas_ingest (not a script) %%%%%%%%%%
    case 'mrvdas_ingest'
        switch oopt
            case 'rvdas_database'
                RVDAS.csvroot = fullfile(MEXEC_G.mexec_data_root, 'rvdas', 'rvdas_csv_tmp');
                switch MEXEC_G.Mship
                    case 'cook'
                        RVDAS.machine = 'rvdas.cook.local';
                        RVDAS.jsondir = ['/home/rvdas/ingester/sensorfiles/jcmeta/' MEXEC_G.MSCRIPT_CRUISE_STRING];
                        RVDAS.user = 'rvdas';
                        RVDAS.database = ['"' upper(MEXEC_G.MSCRIPT_CRUISE_STRING) '"'];
                    case 'discovery'
                        RVDAS.machine = '192.168.62.12';
                        RVDAS.jsondir = ['/home/rvdas/ingester/sensorfiles/dymeta/' MEXEC_G.MSCRIPT_CRUISE_STRING];
                        RVDAS.user = 'rvdas';
                        RVDAS.database = ['"' upper(MEXEC_G.MSCRIPT_CRUISE_STRING) '"'];
                    case 'sda'
                        RVDAS.machine = 'sdl-rvdas-s1.sda.bas.ac.uk';
                        %local(ly) mounted directory in this case (legwork)
                        RVDAS.jsondir = '/local/users/pstar/mounts/public/data_management/documentation/json_sensor_files/';
                        RVDAS.user = 'rvdas_ro';
                        RVDAS.database = ['"' '20210321' '"'];
                end
                if ismac
                    RVDAS.psql_path = '/usr/local/bin/';
                else
                    RVDAS.psql_path = ''; %'/usr/bin/' but on linux matlab finds it on path on its own
                end
    case 'rvdas_skip'
        crhelp_str = {'Determine which tables and variables are listed in mrtables_from_json and'
            'therefore read into mexec processing, by adding to or modifying:'
            'table_skip: list of tables (id in the json files; also json file prefixes) to not load at all'
            '  (e.g. air2sea_gravity)'
            'msg_skip: list of messages (name or [talkId messageId]) to never read in from any '
            '  instrument (e.g. GPDTM)'
            'sentence_skip: list of instrument-message combinations ([id talkId messageId])'
            '  not to read in (often because they duplicate other messages from the same '
            '  instrument, e.g. phins_att_pixsepositi),'
            'pat_skip: list of patterns, variables containing any of which will never be read in'
            '  (e.g. unitsOf),'
            'var_skip: list of variables to never be read in from any table/message'
            '  (e.g. speedknots),'
            'sentence_var_skip: list of instrument_message_variable combinations to not read in'
            '  (e.g. sbe45_nanan_soundVelocity).'
            'All are case-insensitive.'
            'Defaults in msg_skip include datum, time zone, and satellite status,'
            'defaults in json_skip include gravimeters, USBL, and (depending on the ship)'
            'skipperlog and/or chernikeef E/M log,'
            'defaults in sentence_skip are ship-dependent and include many phins messages on DY';
            'defaults in pat_skip and var_skip include units, flags, and satellite-status related fields,'
            'and there are no defaults for sentence_var_skip.'};
        msg_skip = {'glgsv', ...
            'gndtm', 'gngsa', 'gngst', 'gnzda', ...
            'gpdtm', 'gpgga', 'gpgsa', 'gpgst', 'gpgsv', ...
            'gprmc', 'gpzda', ...
            'heths', 'inzda', 'ppnsd', ...
            'pcrfs', 'pctnh'};
        pat_skip = {'unitsOf', 'unitOf', 'Unit', 'des', 'geoid', 'dgnss', 'type', ...
            'magvar', 'status', 'vbw', 'depthfeet', 'fathom', ...
            'magnetic' 'flag' 'hdop' 'ggaqual' 'version' 'device' ...
            };
        var_skip = {'speedknots' 'winchDatum' 'undefined' 'celsiusFlag' 'maxrangescale' ...
            'geoid' 'diffcAge' 'UTCDate' 'maxrange' 'trueheading' ...
            'truecourse' 'positioningmode' 'ggaqual' 'numsat' 'hdop' 'gllqual' ...
            'selftest' 'testmode' 'spare' 'checksum' 'syncbyte2' ...
            'identity' 'serialnumber'};
        sentence_var_skip = {};
        table_skip = {};
        sentence_skip = {};
        switch MEXEC_G.Mship
            case 'discovery'
                table_skip = [table_skip '10_at1m_uw' 'at1m_u12_uw' ...
                    'air2sea_gravity' 'air2sea_s84' ...
                    'posmv_att' 'posmv_gyro' 'seaspy'];
                sentence_skip = ['phins_att_pixsepositi', 'phins_att_pixsespeed', 'phins_att_pixseutmwgs',...
                    'phins_att_pixsetime', 'phins_att_pixsestdhrp', 'phins_att_pixsestdpos',...
                    'phins_att_pixsestdspd', 'phins_att_pixseutcin', 'phins_att_pixsegp2in', ...
                    'phins_att_pixsealgsts', 'phins_att_pixsestatus', 'phins_att_pixseht0sts'];
            case 'cook'
                table_skip = [table_skip 'airsea2', 'gravat1m', 'ranger2usbl', 'seaspy2', 'slogchernikeef', 'rex2'];
                sentence_skip = [sentence_skip 'cnav_gngll', 'cnav_gnrmc', 'posmv_prdid', ...
                    'seapathatt_ingga', 'seapathatt_psxn20', 'seapathgps_inrmc', 'seapathgps_ingll'...
                    'sgyro_hchdm', 'ea640_sddbs'];
                msg_skip = [msg_skip, ...
                    'rex2_3rr0r'];
            case 'sda'
                sentence_skip = [sentence_skip, 'singlebeam_skipper_gds_102_sddpt', 'singlebeam_skipper_gds102_sddbs',...
                    'singlebeam_skipper_gds102_sddbk', 'singlebeam_skipper_gds102_pskpdpt', 'singlebeam_skipper_gds102_sdalr',...
                    'gnss_saab_r5_supreme_gnrmc'];
            otherwise
        end
    case 'use_cruise_views'
        crhelp_str = {'If use_cruise_views = 1 (default 0), prepend string view_name'
            '(default lower(MEXEC_G.MSCRIPT_CRUISE_STRING)) to names from the json files.'};
        if strcmp(MEXEC_G.Mship,'sda')
            use_cruise_views = 1;
            view_name = lower(MEXEC_G.MSCRIPT_CRUISE_STRING);
        else
            use_cruise_views = 0;
        end
    case 'rvdas_nameform'
        crhelp_str = {'Set npre, the number of prefixes (separated by underscores) in '
            'rvdas table names which are not part of the instrument name, e.g.'
            'with npre=1, ''anemometer_ft_technologies_ft702lt_wimwv'' the instrument'
            'name would be ft_technologies_ft702lt'};
        switch MEXEC_G.Mship
            case 'sda'
                npre = 1;
            otherwise
                npre = 0;
        end
end

        %%%%%%%%%% bathy (not a script) %%%%%%%%%%
    case 'bathy'
        switch oopt
            case 'bathy_grid'
                crhelp_str = {'load gridded bathymetry into top.lon, top.lat, top.depth,'
                    'for use by mbathy_edit_av'};
        end
        %%%%%%%%%% end bathy (not a script) %%%%%%%%%%
        
        
        %%%%%%%%%% uway_daily_proc %%%%%%%%%%
    case 'uway_daily_proc'
        switch oopt
            case 'excludestreams'
                crhelp_str = {'uway_excludes lists streams to skip and uway_excludep lists '
                    'patterns (in stream names) to skip. Defaults depend on ship data system.'};
                switch MEXEC_G.Mshipdatasystem
                    case 'techsas'
                        uway_excludes = {'posmvtss'};
                        uway_excludep = {'satinfo';'aux';'dps'};
                    case 'rvdas'
                        uway_excludes = {'gravity';'mag'};
                end
            case 'comb_uvars'
                crhelp_str = {'umtypes lists types underway files to combine'
                    'Default is {''bathy'' ''tsgsurfmet''}, to interpolate the swath centre'
                    'beam depth into the single-beam file, and vice versa; and to'
                    'add the tsg (and for rvdas windsonic) variables into the surfmet file,'
                    '(re)calculating salinity from conductivity and housing temperature.'}; 
                umtypes = {'bathy' 'tsgsurfmet'};
        end
        %%%%%%%%%% end uway_daily_proc %%%%%%%%%%
        
        %%%%%%%%%% mday_01_clean_av %%%%%%%%%%
    case 'mday_01_clean_av'
        switch oopt
            case 'pre_edit_uway'
                crhelp_str = {'place to do specific edits like patching in data from another source'};
        end
        %%%%%%%%%% end mday_01_clean_av %%%%%%%%%%
        
        %%%%%%%%%% mday_01_fcal %%%%%%%%%%
    case 'mday_01_fcal'
        % set non-cruise-specific calibration or editing actions
        switch oopt
            case 'uway_factory_cal'
                crhelp_str = {'this is a place to include factory calibration coefficients to'
                    'be applied to underway sensors: sensorcals is a structure giving'
                    'calibration equations, as strings, for each variable e.g. '
                    'sensorcals.fluo = ''y=(x1-0.082)*04.9;'';'
                    'sensorunits gives the corresponding units for data once the cals have been applied.'
                    'xducer_offset gives the depth of the transducer for converting e.g.'
                    'multib_t to multib (if not present; if multib already exists it will not be overwritten).'
                    'both sensors_to_cal (and sensorcals and sensorunits) and xducer_offset'
                    'should be set within a switch-case on abbrev. there are no default settings'};
                clear sensorcals
                xducer_offset = [];
        end
        %%%%%%%%%% end mday_01_fcal %%%%%%%%%%
        
        %%%%%%%%%% msim_plot %%%%%%%%%%
    case 'msim_plot'
        switch oopt
            case 'sbathy'
                bfile = '/local/users/pstar/topo/s_atlantic';
        end
        %%%%%%%%%% end msim_plot %%%%%%%%%%
        
        %%%%%%%%%% mem120_plot %%%%%%%%%%
    case 'mem120_plot'
        switch oopt
            case 'sbathy'
                bfile = '/local/users/pstar/topo/s_atlantic';
        end
        %%%%%%%%%% end mem120_plot %%%%%%%%%%
                
        %%%%%%%%%% mtsg_bottle_compare %%%%%%%%%%
    case 'mtsg_bottle_compare'
        switch oopt
            case 'tsg_usecal'
                crhelp_str = {'If usecal has not been set before calling mtsg_bottle_compare,'
                    'set here (default 0) to determine whether to inspect the calibrated (1) or'
                    'uncalibrated (0) salinities.'};
                if ~exist('usecal','var'); usecal = 0; end
            case 'tsg_badsal'
                crhelp_str = {'Place to NaN some of the bottle salinity points.'};
            case 'tsg_timebreaks'
                crhelp_str = {'tbreak (default []) is vector of datenums of break points for'
                    'the calibration e.g. when the TSG was cleaned'};
                tbreak = [];
            case 'tsg_sdiff'
                crhelp_str = {'sc1 (default 0.5) and sc2 (default 0.02) are thresholds to use'
                    'for successive smoothing of bottle-tsg differences by removing outliers.'};
                sc1 = 0.5; sc2 = 0.02;
        end
        %%%%%%%%%% end mtsg_bottle_compare %%%%%%%%%%
        
        %%%%%%%%%% mtsg_medav_clean_cal %%%%%%%%%%
    case 'mtsg_medav_clean_cal'
        switch oopt
            case 'tsg_edits'
                  crhelp_str = {'Edits to one or more tsg variables: '
                    'tsgedits.pumpsNaN.var1 = N gives the number of bad points N expected for variable var1'
                    '    after pumps come back on;'
                    'tsgedits.badtimes.var1 = [t1_low t1_hi; ... tN_low tN_hi] gives 1 ... N ranges of times'
                    '    over which to NaN variable var1 (inclusive);'
                    'tsgedits.rangelim.var1 = [V1 V2] gives the range of acceptable values for variable var1;'
                    'tsgedits.despike.var1 = [T1 ... Tn] gives the successive thresholds T1 to Tn for '
                    '    applying median despiking to variable var1.'
                    'e.g.:'
                    'tsgedits.pumpsNaN.temp_housing_raw = 120; %takes 2 minutes to flow through'
                    'tsgedits.pumpsNaN.conductivity_raw = 120; '
                    'tsgedits.badtimes.conductivity_raw = [-10 1e3; 5.5e5 5.6e5]; %start of cruise and TSG cleaning'
                    'tsgedits.badtimes.temp_housing_raw = [-10 1e3; 5.5e5 5.6e5]; '
                    'tsgedits.despike.fluor = [0.3 0.2 0.2];'
                    'All default to not set (no action).'};
            case 'tsgcals'
                crhelp_str = {'Set calibration functions to be applied to tsg variables, if'
                    'corresponding flags are set to true. See help for mctd_02, ctdcals (in setdef_cropt_uway.m).'};
                tsgopts.docal.temp = 0;
                tsgopts.docal.cond = 0;
                tsgopts.docal.fluor = 0;
                if isfield(tsgopts,'calstr')
                    %no default
                    tsgopts = rmfield(tsgopts,'calstr');
                end
        end
        %%%%%%%%%% end mtsg_medav_clean_cal %%%%%%%%%%
                
        
end
