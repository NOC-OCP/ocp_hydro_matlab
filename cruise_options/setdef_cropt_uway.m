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
            case 'ship_data_sys_names'
                crhelp_str = {'Datasystem- (and possibly ship-) specific list of mexec directory names '
                    'and variable names for certain categories: tsg variables, met/surfmet file, '
                    'lat, lon, heading, and wind variables. Presently there are defaults for '
                    'tsgpre and metpre (mexec directory names), salvar, condvar, tempvar, tempsst '
                    '(tsg file variable names for salinity, conductivity, tsg housing temperature, and '
                    'remote [intake] temperature), latvar, lonvar, headvar (for lat, lon, heading), and '
                    'winds and windd (variable names for wind speed and direction).'};
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
        end
        %%%%%%%%%% end ship (not a script) %%%%%%%%%%
        
        %%%%%%%%%% bathy (not a script) %%%%%%%%%%
    case 'bathy'
        switch oopt
            case 'bathy_grid'
                crhelp_str = {'load gridded bathymetry into top.lon, top.lat, top.depth'};
        end
        %%%%%%%%%% end bathy (not a script) %%%%%%%%%%
        
        
        %%%%%%%%%% m_daily_proc %%%%%%%%%%
    case 'm_daily_proc'
        switch oopt
            case 'excludestreams'
                crhelp_str = {'uway_excludes lists streams to skip and uway_excludep lists '
                    'patterns (in stream names) to skip. Defaults depend on ship data system.'};
                switch MEXEC_G.Mshipdatasystem
                    case 'techsas'
                        uway_excludes = {'posmvtss'};
                        uway_excludep = {'satinfo';'aux';'dps'};
                    case 'rvdas'
                        uway_excludes = {'gravity';'mag';'winch'};
                end
            case 'comb_uvars'
                crhelp_str = {'umtypes lists types underway files to combine'
                    'Default is {''bathy'' ''tsgsurfmet''}, to interpolate the swath centre'
                    'beam depth into the single-beam file, and vice versa; and to'
                    'add the tsg (and for rvdas windsonic) variables into the surfmet file,'
                    '(re)calculating salinity from conductivity and housing temperature.'}; 
                umtypes = {'bathy' 'tsgsurfmet'};
        end
        %%%%%%%%%% end m_daily_proc %%%%%%%%%%
        
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
        
        %%%%%%%%%% mtsg_01 %%%%%%%%%%
    case 'mtsg_01'
        switch oopt
            case 'indata'
                sal_mat_file = ['sal_' mcruise '_01.mat'];
            case 'flag'
                %set bottle/bottle reading flags
        end
        %%%%%%%%%% end mtsg_01 %%%%%%%%%%
        
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
            case 'tsg_editvars'
                crhelp_str = {'editvars is a list of possible variables to edit (where they exist)'
                    'based on bad times. Add to this list if you have a new variable name; only'
                    'need to set it in opt_cruise if you want to exclude one of the variables'
                    'in the list even though it''s found in your file.'};
                %default: edit all ocean vars
                editvars = {'salinity','tstemp','sstemp','sstemp2','sampletemp','chlorophyll','trans','psal','fluo','cond','temp_m','temp_h','salin','fluor'};
                editvars = [editvars {'temp_housing_raw','conductivity_raw','salinity_raw','soundvelocity_raw','temp_remote_raw'}]; % bak jc211 added for rvdas
            case 'tsg_badlims'
                crhelp_str = 'kbadlims (default []) is an Nx2 vector of start and end datenums of bad times to NaN';
                kbadlims = [];
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
        
        %%%%%%%%%% mtsg_merge_and_listing %%%%%%%%%%
    case 'mtsg_merge_and_listing' %***is this mtsgsurfmet_merge?
        switch oopt
            case 'tsgmetfiles'
                tsgfile = fullfile(root_tsg, ['tsg_' mcruise '_01_medav_clean_cal.nc']);
                metfile = fullfile(root_met, ['met_tsg_' mcruise '_01.nc']);
                metlightfile = fullfile(root_metlight, 'met', 'surflight', ['met_light_' mcruise '_01.nc']);
                posfile = fullfile(root_pos, ['bst_nav_' mcruise '_01.nc']);
        end
        %%%%%%%%%% end mtsg_merge_and_listing %%%%%%%%%%
        
        
end
