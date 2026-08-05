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
            case 'minit'
                %station naming convention
                if ~exist('stn', 'var'); stn = input('type stn number '); end
                stn_string = sprintf('%03d',stn); %used for file names
                stnlocal = stn;
            case 'mdirlist'
                dirs = {
                    'M_CTD' 'ctd'
                    'M_CTD_CNV' fullfile('ctd','ASCII_FILES')
                    'M_CTD_BOT' fullfile('ctd','ASCII_FILES')
                    'M_CTD_WIN' fullfile('ctd','WINCH')
                    'M_CTD_DEP' 'station_information'
                    'M_BOT'     'bottle_samples'
                    'M_BOT_SAL' fullfile('bottle_samples','SAL')
                    'M_BOT_OXY' fullfile('bottle_samples','OXY')
                    'M_BOT_NUT' fullfile('bottle_samples','NUT')
                    'M_BOT_PIG' fullfile('bottle_samples','PIG')
                    'M_BOT_CO2' fullfile('bottle_samples','CO2')
                    'M_BOT_CFC' fullfile('bottle_samples','CFC')
                    'M_BOT_CH4' fullfile('bottle_samples','CH4')
                    'M_BOT_CHL' fullfile('bottle_samples','PIG')
                    'M_BOT_ISO' fullfile('bottle_samples','LOGS')
                    'M_SAM' 'ctd'
                    'M_SBE35' fullfile('ctd','ASCII_FILES','SBE35')
                    'M_SUM' 'collected_files'
                    'M_VMADCP' 'vmadcp'
                    }; %***change how MDIRLIST is used?
                if ~strcmp(MEXEC_G.Mshipdatasystem,'auto')
                    dirs = [dirs;
                        {'M_UWAY_RAW' fullfile(MEXEC_G.Mshipdatasystem,'raw_local')}];
                end
                if strcmp(MEXEC_G.datatypes.ladcp,'ix')
                    dirs = [dirs;
                        {'M_LADCP' 'ladcp'
                        'M_IX' fullfile('ladcp','ix')}];
                end
                if exist('mutv','var')
                    dirs = [dirs; ...
                        [cellfun(@(x) ['M_' upper(x)], mutv.mstarpre, 'UniformOutput', false), ...
                        mutv.mstardir]];
                    [~,ii] = unique(dirs(:,1),'stable');
                    dirs = dirs(ii,:);
                end
                dirs(:,2) = cellfun(@(x) fullfile(MEXEC_G.mexec_data_root,x),dirs(:,2),'UniformOutput',false);
                MEXEC_G.MDIRLIST = cell2struct(dirs(:,2),dirs(:,1));
            case 'procfiles'
                %.nc files for different processing stages
                ctdfile.dataname = ['ctd_' mcruise '_%s'];
                firfile.dataname = ['fir_' mcruise '_%s'];
                dcsfile.dataname = ['dcs_' mcruise '_%s'];
                winfile.dataname = ['win_' mcruise '_%s'];
                ctdfile.raw = fullfile(MEXEC_G.MDIRLIST.M_CTD, [ctdfile.dataname '_cnv.nc']);
                ctdfile.clean = fullfile(MEXEC_G.MDIRLIST.M_CTD, [ctdfile.dataname '_cleaned.nc']);
                ctdfile.p24 = fullfile(MEXEC_G.MDIRLIST.M_CTD, [ctdfile.dataname '_24hz.nc']);
                ctdfile.p1 = fullfile(MEXEC_G.MDIRLIST.M_CTD, [ctdfile.dataname '_1hz.nc']);
                ctdfile.d = fullfile(MEXEC_G.MDIRLIST.M_CTD, [ctdfile.dataname '_2db.nc']);
                ctdfile.u = fullfile(MEXEC_G.MDIRLIST.M_CTD, [ctdfile.dataname '_2up.nc']);
                edfiles.ctd24 = fullfile(MEXEC_G.MDIRLIST.M_CTD,'editlogs','ctd_%s_editpoints');
                firfile.fir = fullfile(MEXEC_G.MDIRLIST.M_CTD, [firfile.dataname '.nc']);
                dcsfile.dcs = fullfile(MEXEC_G.MDIRLIST.M_CTD, [dcsfile.dataname '.nc']);
                winfile.win = fullfile(MEXEC_G.MDIRLIST.M_CTD_WIN, [winfile.dataname '.nc']);
                if exist('inst','var') 
                    if exist('cast_select','var') && exist('stn_string', 'var')
                        sadcpfile.dataname = [inst '_' mcruise '_' cast_select '_' stn_string];
                        sadcpfile.av = fullfile(MEXEC_G.MDIRLIST.M_VMADCP, 'mproc', '%s_ave.nc');
                    end
                    sadcpfile.proc = fullfile(MEXEC_G.MDIRLIST.VMADCP, 'postprocessing', upper(mcruise), 'proc_editing', inst, 'contour', [inst '.nc']);
                end
                ctdfile.sg = fullfile(MEXEC_G.MDIRLIST.M_CTD,'sensor_groups.mat'); %generated by get_sensor_groups, contains groups of sensors by serial number, sg, sng
                samfile = fullfile(MEXEC_G.MDIRLIST.M_CTD,['sam_' mcruise '_all.nc']);
                samufile = fullfile(MEXEC_G.MDIRLIST.M_BOT,['ucsw_' mcruise '_all.nc']);
                sumfile = fullfile(MEXEC_G.MDIRLIST.M_SUM,['station_summary_' mcruise '_all.nc']);
                sbe35file.dataname = ['sbe35_' mcruise '_all'];
                sbe35file.sbe35 = fullfile(MEXEC_G.MDIRLIST.M_SBE35, [sbe35file.dataname '.nc']);
                if exist('samtyp','var')
                    sampfile.dataname = [samtyp '_' mcruise '_all'];
                    if strcmp(samtyp,'sbe35')
                        sampfile.(samtyp) = fullfile(MEXEC_G.MDIRLIST.M_SBE35,[sampfile.dataname '.nc']);
                    else
                        sampfile.(samtyp) = fullfile(MEXEC_G.MDIRLIST.(['M_BOT_' upper(samtyp)]),[sampfile.dataname '.nc']);
                    end
                end
                if isfield(MEXEC_G.MDIRLIST,'M_POS')
                    ucfiles.nav = fullfile(MEXEC_G.MDIRLIST.M_POS,['bestnav_' mcruise '_all.nc']);
                    ucfiles.ocean = fullfile(MEXEC_G.MDIRLIST.M_TSG,['surface_ocean_' mcruise '_all.nc']);
                end
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
        switch MEXEC_G.MSCRIPT_CRUISE_STRING(1:2)
            case {'di' 'dy'}
                MEXEC_G.PLATFORM_IDENTIFIER = 'RRS Discovery';
                if MEXEC_G.MDEFAULT_DATA_TIME_ORIGIN(1)>=2021
                    MEXEC_G.Mshipdatasystem = 'rvdas';
                else
                    MEXEC_G.Mshipdatasystem = 'techsas';
                end
            case 'jc'
                MEXEC_G.PLATFORM_IDENTIFIER = 'RRS James Cook';
                if MEXEC_G.MDEFAULT_DATA_TIME_ORIGIN(1)>=2021
                    MEXEC_G.Mshipdatasystem = 'rvdas';
                else
                    MEXEC_G.Mshipdatasystem = 'techsas';
                end
            case 'sd'
                MEXEC_G.PLATFORM_IDENTIFIER = 'RRS Sir David Attenborough';
                MEXEC_G.Mshipdatasystem = 'rvdas';
            case 'jr'
                MEXEC_G.PLATFORM_IDENTIFIER = 'RRS James Clark Ross';
                MEXEC_G.Mshipdatasystem = 'scs_ascii';
            case 'kn'
                MEXEC_G.PLATFORM_IDENTIFIER = 'RV Knorr';
                MEXEC_G.Mshipdatasystem = 'scs'; %***update to scs_nc?
            case 'en'
                MEXEC_G.PLATFORM_IDENTIFIER = 'RV Endeavor';
                MEXEC_G.Mshipdatasystem = 'scs_nc';
            case 'ce'
                MEXEC_G.PLATFORM_IDENTIFIER = 'RV Celtic Explorer';
                MEXEC_G.Mshipdatasystem = 'scs_ascii';
            otherwise
                merr = ['Ship ''' MEXEC_G.MSCRIPT_CRUISE_STRING(1:2) ''' not recognised, underway system will not be set up'];
                %fprintf(2,'%s\n',merr);
                %return
                warning(merr)
                MEXEC_G.Mship = '';
                MEXEC_G.PLATFORM_IDENTIFIER = '';
        end

    case 'ctd_proc'
        if strcmp(MEXEC_G.datatypes.ctd,'sbe')
            mexec_defaults_sbe %rawedit_auto, raw_corrs
        end
        switch opt2
            case 'ctdfiles'
                %input .cnv file set by cruise
            case 'absentvars'
                %if a sensor was missing for only some stations, can add it
                %as NaNs. this is also the place to create time variable if
                %not present
            case 'cast_split_comb'
                %no defaults
            case 'ctd_raw_extra'
                extrasource = {}; extravars = {};
            case 'header_edits'
            case 'raw_corrs'
                co.oxy_align = 0;
                co.dpoff = 0;
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
                    {'fluor','turbidity','transmittance'}};
                repars.g1 = {{'press'}, {'temp1','temp2'}, {'cond1','cond2'},{'oxy1','oxy2'}};
                repars.g2 = {{'press'},{'fluor'},{'turbidity'},{'transmittance'}};
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
                yl.turbidity = [0 1]; yl.transmittance = [60 101];
                doed = 1; %always end mctd_raw_show_check by running mctd_rawedit (can turn this off in opt_cruise)
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
            mexec_defaults_uway %rawedit_auto, raw_corrs
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
                vars_to_ed.g1 = {setdiff(fieldnames(dg)',tvars)};
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
                        yl.trans = [-95; 0.1];
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
