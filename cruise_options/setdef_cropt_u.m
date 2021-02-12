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
                crhelp_str = {'umtypes lists types of operations to perform combining multiple '
                    'appended underway files. Default is {''bathy''}, to interpolate the swath '
                    'centre beam depth into the single-beam file, and vice versa; for techsas, '
                    'and curently for rvdas, default also includes ''tsgmet'', to combine the '
                    'tsg and surfmet variables (techsas) or the digital sonic anemometer and surfmet '
                    'variables (rvdas) in a single file.'};
                umtypes = {'bathy'};
                if sum(strcmp(MEXEC_G.Mshipdatasystem,{'techsas' 'rvdas'}))
                    umtypes = [umtypes 'tsgsurfmet'];
                end
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
                    'be applied to underway sensors: sensors_to_cal is a cell array list of sensors,'
                    'and sensorcals is a corresponding list of calibration equations ***'
                    'sensorunits gives the corresponding units for data once the cals have been applied.'
                    'sensors_to_cal defaults to empty ({}) meaning no action.s'};
                        sensors_to_cal={};
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
            case 'usecal'
                if ~exist('usecal'); usecal = 0; end
            case 'dbbad'
                %NaN some of the bottle salinity points
            case 'sdiff'
                sc1 = 0.5; sc2 = 0.02; %thresholds to use for smoothed series
        end
        %%%%%%%%%% end mtsg_bottle_compare %%%%%%%%%%
        
        %%%%%%%%%% mtsg_cleanup %%%%%%%%%%
    case 'mtsg_cleanup'
        switch oopt
            case 'kbadlims'
                crhelp_str = 'kbadlims = [t1 t2]; %bad from t1 to t2 (matlab datenum)';
                kbadlims = [];
            case 'editvars'
                %default: edit all ocean vars
                editvars = {'salinity','tstemp','sstemp','sstemp2','sampletemp','chlorophyll','trans','psal','fluo','cond','temp_m','temp_h','salin','fluor'};
            case 'moreedit'
                %can specify non-time-range based edits (see e.g. opt_jc069)
        end
        %%%%%%%%%% end mtsg_cleanup %%%%%%%%%%
        
        
        %%%%%%%%%% mtsg_medav_clean_cal %%%%%%%%%
    case 'mtsg_medav_clean_cal'
        switch oopt
        end
        %%%%%%%%%% end mtsg_medav_clean_cal %%%%%%%%%%
        
        %%%%%%%%%% tsgsal_apply_cal %%%%%%%%%%
    case 'tsgsal_apply_cal'
        switch oopt;
            case 'saladj'
                salout = salin;
        end
        %%%%%%%%%% end tsgsal_apply_cal %%%%%%%%%%
        
        %%%%%%%%%% mtsg_merge_and_listing %%%%%%%%%%
    case 'mtsg_merge_and_listing'
        switch oopt
            case 'tsgmetfiles'
                tsgfile = [root_tsg '/tsg_' mcruise '_01_medav_clean_cal.nc'];
                metfile = [root_met '/met_tsg_' mcruise '_01.nc'];
                metlightfile = [root_metlight '/met/surflight/met_light_' mcruise '_01.nc'];
                posfile = [root_pos '/bst_nav_' mcruise '_01.nc'];
        end
        %%%%%%%%%% end mtsg_merge_and_listing %%%%%%%%%%
        
        
end
