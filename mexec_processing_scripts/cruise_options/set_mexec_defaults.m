% this script is called by get_cropt to set defaults for
% parameters/variables used by multiple scripts (settings used in only one
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

    case 'mstar'
        %things about mstar file format
        docf = 1; %use cf-compliant time units
        docf = 0; %use seconds since h.data_time_origin
        
    case 'castpars'
        %parameters related to CTD setup
        switch opt2
            case 'minit'
                if ~exist('stn', 'var'); stn = input('type stn number '); end
                stnlocal = stn; clear stn
                stn_string = sprintf('%03d',stnlocal); %used for file names
            case 'nnisk'
                nnisk = 24; %number of Niskins on rosette; may be station-dependent
            case 'oxyvars'
                %name in raw file, name in 24 hz file (don't change the 2nd
                %column!)
                oxyvars = {'oxygen_sbe1', 'oxygen1'; 'oxygen_sbe2', 'oxygen2'};
            case 'oxy_align'
                oxy_align = 6; %number of seconds by which oxygen has been shifted in SBE processing***read this
                oxy_end = 0; %set to 1 to select end of cast based on T,S and truncate O earlier (based on oxy_align)
            case 'ctdsens_groups'
                sgfile = fullfile(mgetdir('ctd'),'sensor_groups.mat'); %generated by get_sensor_groups, contains sg, sng
            case 's_choice'
                s_choice = 1; %CTD1 is primary
                stns_alternate_s = []; %on these stations it's the other one
            case 'o_choice'
                o_choice = 1; %oxygen1 is primary
                stns_alternate_o = []; %on these stations it's the other one
        end

    case 'calibration'
        switch opt2
            case 'ctd_cals'
                castopts.docal.temp = 0; %do not apply any calibration to temp
                castopts.docal.cond = 0; %do not apply any calibration to cond
                castopts.docal.oxygen = 0; %do not apply any calibration to oxy
                castopts.docal.fluor = 0; %etc
                castopts.docal.transmittance = 0; %etc
                if isfield(castopts,'calstr')
                    castopts = rmfield(castopts,'calstr'); %no default, must be set by opt_{cruise}
                    %see *** for examples
                end
            case 'sensor_factory_cals'
                sensorcals = struct(); %default: none
                xducer_offset = []; %default: none
            case 'tsg_cals'
                tsgopts.docal.temp = 0; %do not apply any calibration to tsg temp
                tsgopts.docal.cond = 0; %etc
                tsgopts.docal.fluor = 0; %etc
                if isfield(tsgopts,'calstr')
                    tsgopts = rmfield(tsgopts,'calstr'); %no default, must be set by opt_{cruise}
                    %see *** for examples
                end
        end

    case 'check_sams'
        check_sal = 0; %do not plot individual salinity readings
        check_oxy = 0; %do not step through mismatched oxygen replicates
        check_sbe35 = 0; %do not display bad sbe35 lines (may error later if they are present and not flagged)

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
                        uway_root = fullfile(MEXEC_G.mexec_data_root, 'scs_raw'); % scs raw data on logger machine
                        uway_sed = fullfile(MEXEC_G.mexec_data_root, 'scs_sed'); % scs raw data on logger machine
                        uway_mat = fullfile(MEXEC_G.mexec_data_root, 'scs_mat'); % local directory for scs converted to matlab
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
            case 'rvdas_form'
                switch MEXEC_G.Mship
                    case 'sda'
                        use_cruise_views = 1; %prepend string view_name to names from json files
                        view_name = lower(MEXEC_G.MSCRIPT_CRUISE_STRING);
                        npre = 1; %table names start with an extra prefix before the instrument make/model e.g. anemometer_ft_technologies_etc
                    otherwise
                        npre = 0; %table names start with instrument name
                end
        end

    case 'ctd_proc'
        switch opt2
            case '1hz_interp'
                maxfill24 = 0; maxfill1 = 2; 
        end
        
    case 'uway_proc'
        switch opt2
            case 'avtime'
                avnav = 30; %average nav and heading data over 30 s
                avmet = 60; %average met data over 60 s
                avtsg = 60; %average tsg data over 60 s
            case 'comb_uvars'
                %combine *** variables in averaged files
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
            case 'plot' %***
                station_depth_width = 0;
                bottle_depth_size = 0;

        end

end
