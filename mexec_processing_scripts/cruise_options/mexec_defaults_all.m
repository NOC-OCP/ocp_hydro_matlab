% this script is called by get_cropt to set defaults for
% parameters/variables used by multiple scripts (those used in only one
% script are set in situ), before calling opt_{cruise} to set
% cruise-specific parameters if applicable. note opt_{cruise} may also call
% mexec_defaults_sbe or mexec_defaults_noc to set some CTD processing
% parameters, while this script contains ship- or underway data system
% specific parameters as well as generally applicable defaults (e.g. broad
% acceptable range of atmospheric variables, default directory tree for
% output data, etc.***)
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
            case 'redoctm'
            case 'cnvfilename'
            case 'cast_split_comb'
            case 'ctd_raw_extra'
                clear ctd_raw_extra
            case 'header_edits'
                %mctd_02
            case 'ctd_cals'
                %remove any co.calstr; must be set by opt_{cruise}
                co.docal.temp = 0; %do not apply any user calibration to temp
                co.docal.cond = 0; %do not apply any user calibration to cond
                co.docal.oxygen = 0; %do not apply any user calibration to oxy
                co.docal.fluor = 0; %etc
                co.docal.transmittance = 0; %etc
                if isfield(co,'calstr')
                    co = rmfield(co,'calstr');
                end
                %mctd_03
            case 'sensor_choice'
                s_choice = 1; %CTD1 is primary
                stns_alternate_s = []; %on these stations it's the other one
                o_choice = 1; %oxygen1 is primary
                stns_alternate_o = []; %on these stations it's the other one
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
                niskin_number = [1:24]'; %replace with S/N
                niskin_pos = [1:24]'; %position (firing number)
            case 'fir_fill'
            case 'fir_extra'
                fir_extra = true; %do also add background gradient and variance, and density-matched downcast data, to fir_ (and sam_) file
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
                tvars = fieldnames(dg)';
                tvars = [tvars(cellfun(@(x) contains(x,'time'),tvars)) 'dday'];
                vars_to_ed = setdiff(fieldnames(dg)',tvars);
                switch datatype
                    case 'bathy'
                        handedit = 1;
                    case 'ocean'
                        handedit = 1;
                        %ucsw system things should be NaNed when pump speed out of range, including remote temp (inside inlet)
                        fvars = {'temph','temp_remote','fluo','trans','cond','salinity','soundvelocity'};
                        for no = 1:length(fvars)
                            uopts.badflow.(fvars{no}) = [-inf 0.6; 2.5 inf];
                        end
                        %soundvelocity depends on remote temp
                        uopts.badtemp_remote.soundvelocity = [NaN NaN];
                        %conductivity and salinity depend on housing temp
                        uopts.badtemph.cond = [NaN NaN];
                        uopts.badtemph.salinity = [NaN NaN];
                        vars_offset_scale.trans = [-95; 0.1];
                    case 'atmos'
                        handedit = 1;
                        wvars = {'truwind_e','truwind_n','truwind_dir'};
                        for no = 1:length(wvars)
                            uopts.badtruwind_spd.(wvars{no}) = [NaN NaN];
                        end
                        vars_to_ed = setdiff(vars_to_ed,wvars); %just edit speed and apply to other wind vars (by re-running after editing)
                        vars_offset_scale.airpressure = [-1000; 1];
                        vars_offset_scale.humidity = [-80; 0.5];
                        vars_offset_scale.parport = [0; 1e-7];
                        vars_offset_scale.parstarboard = vars_offset_scale.parport;
                        vars_offset_scale.tirport = vars_offset_scale.parport;
                        vars_offset_scale.tirstarboard = vars_offset_scale.parport;
                    case 'nav'
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
        end

    case 'samp_proc'
        switch opt2
            case 'files'
                %no general defaults
            case 'parse'
                clear varmap
                varmap.sampnum = {'sampnum'}; %always keep this
            case 'check'
                %threshold to use to check replicate agreement (set to 0 to
                %skip a sample type) 
                checksam.chl = 1;
                checksam.oxy = 0.01;
                checksam.nut = 1;
                checksam.sal = 1;
                checksam.co2 = 1; %***code for this?
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
        end

    case 'adcp_proc'
        %for vmadcp
        min_nvmadcpprf = 3;      %throws a warning if number of vmADCP profiles within an LADCP cast is less than this
        min_nvmadcpbin = 3;      %masks depths with number of valid bins less than this
        min_nvmadcpbin_refl = 3; %throws a warning if number of good profiles at any depth in the watertrack reference layer is less than this
        root_vmadcp = mgetdir('M_VMADCP');
        avfile = fullfile(root_vmadcp, 'mproc', [dataname '_ave.nc']);
        if MEXEC_G.ix_ladcp
            %for ladcp, using vmadcp
            ladfile = fullfile(root_vmadcp, 'mproc', [dataname '_forladcp.mat']);
            cfg.f.sadcp = ladfile;
            %and ctd: set file location and format for ascii file of 1hz ctd
            %data and nmea nav data, which will be used in ladcp LDEO_IX processing
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
            %parameters for LADCP processing
            cfg.p.magdec_source = 1;
            %cfg.p.edit_mask_dn_bins = 1;
            %cfg.p.edit_mask_up_bins = 1;
            cfg.p.orig = 0; % save original data or not
            isul = 1; %is there an uplooker? process it first on its own
            cfg.rawdir = fullfile(mgetdir('ladcp'),'rawdata',cfg.stnstr);
            cfg.pdir_root = fullfile(mgetdir('ladcp'),'ix');
            cfg.p.ambiguity = 4.0; %this one is not used?
            SADCP_inst = 'os75nb';
            %cfg.p.vlim = 4.0; %this one is***require setting in opt_cruise
        end

    case 'outputs'
        switch opt2
            case 'grid'
                ctd_regridlist  = {'temp' 'psal' 'potemp' 'oxygen'}; %grid these variables
                sam_gridlist = {'botpsal' 'botoxy'}; %grid these variables
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
