% this script is called by get_cropt to set defaults for
% parameters/variables used by multiple scripts (those used in only one
% script are set in situ). it may call mexec_defaults_sbe,
% mexec_defaults_uway to set some parameters for CTD and underway data.
% get_cropt then calls opt_{cruise} to set cruise-specific parameters if
% applicable. note opt_{cruise} may also call e.g. mexec_defaults_noc 
% this script contains ship- or underway data system
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

mcruise = MEXEC_G.MSCRIPT_CRUISE_STRING;

switch opt1

    case 'setup'
        switch opt2
            case 'time_origin'
                %no default, set MEXEC_G.MDEFAULT_DATA_TIME_ORIGIN
            case 'm_stn_string'
                %station naming convention
                if ~exist('stn', 'var')
                    stn = input('type stn number '); 
                end
                stn_string = sprintf('%03d',stn); %used for file names, default: 001, 002, etc.
                stnlocal = stn;
        end

    case 'mstar'
                %things about mstar file format
                if MEXEC_G.MDEFAULT_DATA_TIME_ORIGIN(1)>=2024
                    docf = 1; %cf-compliant time units
                else
                    docf = 0; %use seconds since h.data_time_origin, units called 'seconds'
                end
    
    case 'shipuway'
        mexec_defaults_shipuway

    case 'ctd_proc'
        if strcmp(MEXEC_G.datatypes.ctd,'sbe')
            mexec_defaults_sbe %ctdvarsunits, rawedit_auto, raw_corrs
        end
        switch opt2
            case 'ctdfiles'
                helptext = sprintf('input .cnv file, set in opt_%s',mcruise);
            case 'absentvars' 
                helptext = sprintf('if necessary, set in opt_%s to create time variable (if missing) or add variables absent for only some stations as NaNs',mcruise);
            case 'cast_split_comb'
                %helptext = sprintf('if nec')
            case 'ctd_raw_extra'
                extrasource = {}; extravars = {};
            case 'header_edits'
            case 'ctd_cals'
                %remove any co.calstr; must be set by opt_{cruise}
                co.docal.temp = 0; %do not apply any user calibration to temp
                co.docal.cond = 0; %do not apply any user calibration to cond
                co.docal.oxy = 0; %do not apply any user calibration to oxy
                co.docal.fluor = 0; %etc
                co.docal.transmittance = 0; %etc
                if isfield(co,'calstr')
                    co = rmfield(co,'calstr');
                end
            case 'sensor_choice'
                ts_choice = 1; %CTD1 is primary, temp1 will be copied to temp, etc.
                o_choice = 1; %CTDO1 is primary, oxy1 will be copied to oxy, etc.
            case '1hz_interp'
                maxfill24 = 24;
                maxfill1 = 1;
            case 'cast_divide'
                force_auto.start = 0; force_auto.bot = 0; force_auto.end = 0;
            case 'rawshow'
                %two groupings to show
                rppars = {{'temp','cond','press','oxy'}
                    {'fluor','turbidity','transmittance','par'}};
                repars.g1 = {{'press'}, {'temp1','temp2'}, {'cond1','cond2'},{'oxy1','oxy2'}};
                repars.g2 = {{'press'},{'fluor'},{'turbidity'},{'transmittance'},{'par'}};
                yl.temp = [-2 40]; yl.temp1 = yl.temp; yl.temp2 = yl.temp;
                if strcmp(h.fldunt{strcmp(h.fldnam,'cond1')},'S/m')
                    yl.cond = [20 40];
                else
                    yl.cond = [2 4];
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
            case 'niskfilename'
                %no default for .bl file
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
                niskin_number = [1:24]'; %replace with S/N, bedford number, etc.
                niskin_pos = [1:24]'; %position (firing number)
            case 'fir_fill'
                firmethod = 'medint';
                clear firopts;
                firopts.int = [-1 120]; %average over 5 s, like in .ros file
                firopts.prefill = 24*5; %fill gaps up to 5 s first
            case 'fir_extra'
                fir_extra = true; %do also add background gradient and variance, and density-matched downcast data, to fir_ (and sam_) file
        end
    
    case 'uway_proc'
        switch opt2
                    case 'scs_skip'
            skip = {'USBL'};
        case 'scs_nmea_form'
            colsi = {}; colsf = {};
            untsi = {}; untsf = {};
            colsi = {'date','time'};
            untsi = {'mm/dd/yyyy','HH:MM:SS.SSS'};
        case 'scs_nmea_custom'
            inform = '';
        case 'uway_ascii_parse'
            if exist('inform','var') && ~isempty(inform)
                t = ua_times_parse(t, MEXEC_G.data_time_origin_string, 'inform', inform);
            else
                t = ua_times_parse(t, MEXEC_G.data_time_origin_string);
            end
            if sum(strcmp(t.Properties.VariableNames','msg')) && strcmp(t.msg(1),'PSXN')
                t = t(t.linetype==23,:);
            end
            m = strcmp(t.Properties.VariableNames,'nslatitude');
            if sum(m)
                t.lat = t.nslatitude/100;
                t.lat(strcmp(t.ns,'S')) = -t.lat(strcmp(t.ns,'S'));
                t.Properties.VariableUnits{strcmp(t.Properties.VariableNames,'lat')} = 'degrees N';
            end
            m = strcmp(t.Properties.VariableNames,'ewlongitude');
            if sum(m)
                t.lon = t.ewlongitude/100;
                t.lon(strcmp(t.ew,'W')) = -t.lon(strcmp(t.ew,'W'));
                t.Properties.VariableUnits{strcmp(t.Properties.VariableNames,'lon')} = 'degrees E';
            end
            m = strcmp(t.Properties.VariableNames,'psxn_heave');
            if sum(m)
                t.heave = cellfun(@(x) str2double(x(1:end-3)), t.psxn_heave);
                t.Properties.VariableUnits{strcmp(t.Properties.VariableNames,'heave')} = 'm';
            end
            case 'tstep_save'
                %subsample high-frequency streams and match up different
                %messages from the same system by rounding timestamp
                %if your samples are coming in at a *regular* high
                %frequency (e.g. 40Hz on the SDA), set stepfreq_force to
                %subsample to (approximately) 1/tstep_force hz before
                %saving
                stepfreq_force = [];
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
                vars_to_ed.g1 = {setdiff(fieldnames(dg)',tvars)};
                switch datatype
                    case 'bathy'
                        handedit = 1;
                    case 'ocean'
                        handedit = 1;
                        %ucsw system things should be NaNed when pump speed out of range, including remote temp (inside inlet)
                        fvars = {'temph','temp_remote','temp_tsg','temp_in','fluo','fluor','transmissivity','trans','cond','salinity','psal'};
                        for no = 1:length(fvars)
                            uopts.badflow.(fvars{no}) = [-inf 0.6; 2.5 inf];
                        end
                        %soundvelocity depends on remote temp
                        uopts.badtemp_remote.soundvelocity = [NaN NaN];
                        %conductivity and salinity depend on housing temp
                        uopts.badtemph.cond = [NaN NaN];
                        uopts.badtemph.salinity = [NaN NaN];
                        yl.trans = [-95; 0.1]; %***
                        yl.cond = [20 40]; yl.psal = [33 38]; yl.salinity = yl.psal;
                        yl.fluor = [0 12]; yl.fluo = yl.fluor;
                        yl.turbidity = [0 1]; 
                        yl.transmittance = [60 101]; 
                        yl.temph = [-2 30]; yl.temp_remote = yl.temph;
                        yl.temp_in = yl.temph; yl.temp_tsg = yl.temph;
                    case 'atmos'
                        handedit = 1;
                        wvars = {'truwind_e','truwind_n','truwind_dir'};
                        for no = 1:length(wvars)
                            uopts.badtruwind_spd.(wvars{no}) = [NaN NaN];
                        end
                        vars_to_ed.g1 = {setdiff(vars_to_ed.g1{1},wvars)}; %just edit speed and apply to other wind vars (by re-running after editing)
                        yl.airpressure = [500 1500];
                        yl.humidity = [0 100];
                        yl.parport = [0 1e7];
                        yl.parstarboard = yl.parport;
                        yl.tirport = yl.parport;
                        yl.tirstarboard = yl.parport;
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
                sopts.remove_empty_cols = 1;
            case 'parse'
                clear varmap
                %keepothervars, varmap
                addcomment = '';
            case 'replcheck'
                %threshold to use to check replicate agreement (set to 0 to
                %skip checking that sample type)
                checksam.chl = [1 2]; %compare by ratio, highlight differences over factor of 2
                checksam.oxy = [2 0.01]; %compare by ratio, highlight differences over +/- 1%
                checksam.nut = [2 0.05]; %compare by ratio, highlight differences over +/- 5%
                checksam.sal = [0 1e-5]; %compare (salinometer reading) by difference, highlight differences over +/- 1e-5
                checksam.co2 = [2 0.05]; %***confirm default
                checksam.sbe35 = 0; %no threshold but if set to 1, check ascii file download quality (rarely necessary)
            case 'flags'
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
        end

    case 'adcp_proc'
        %for vmadcp
        min_nvmadcpprf = 3;      %throws a warning if number of vmADCP profiles within an LADCP cast is less than this
        min_nvmadcpbin = 3;      %masks depths with number of valid bins less than this
        min_nvmadcpbin_refl = 3; %throws a warning if number of good profiles at any depth in the watertrack reference layer is less than this
        if strcmp(MEXEC_G.datatypes.ladcp,'ix')
            mexec_defaults_ixladcp
        end

    case 'outputs'
        switch opt2
            case 'grid'
                ctd_regridlist  = {'temp' 'psal' 'potemp' 'oxy'}; %grid these variables
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
