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
            case 'shiptsg'
                crhelp_str = {'ship-specific list of tsg directory prefix and variable names:';
                    'tsgpre is used to find directory for tsg data in m_udirs,';
                    'salvar/condvar are the salinity/conductivity variables in tsg data stream,';
                    'tempvar/tempsst are the housing/intake temperatures'};
                switch MEXEC_G.Mship
                    case {'cook','discovery'}
                        tsgpre = 'tsg';
                        salvar = 'psal'; % salinity var in tsg data stream
                        tempvar = 'temp_h'; % housing temp
                        tempsst = 'temp_r'; % remote temp
                        condvar = 'cond'; % conductivity
                    case 'jcr'
                        tsgpre = 'oceanlogger';
                        salvar = 'salinity'; % salinity var in tsg data stream
                        tempvar = 'tstemp'; % housing temp
                        condvar = 'conductivity'; % conductivity
                        tempsst = 'sstemp'; % "sea surface" temperature?
                end
        end
        %%%%%%%%%% end ship (not a script) %%%%%%%%%%
        
                
        %%%%%%%%%% m_daily_proc %%%%%%%%%%
    case 'm_daily_proc'
        switch oopt
            case 'exclude'
                if ~exist('uway_streams_proc_exclude'); uway_streams_proc_exclude = {'posmvtss'}; end
                if ~exist('uway_pattern_proc_exclude'); uway_pattern_proc_exclude = {'satinfo';'aux';'dps'}; end
            case 'bathycomb'
                bathycomb = 1;
            case 'allmat'
                allmat = 0;
        end
        %%%%%%%%%% end m_daily_proc %%%%%%%%%%
        
        %%%%%%%%%% mday_01_clean_av %%%%%%%%%%
    case 'mday_01_clean_av'
        % set non-cruise-specific calibration or editing actions
        switch oopt
            case 'uway_apply_cal'
                switch abbrev
                    case 'cnav'
                        d = mload(infile, 'lat long');
                        if max(mod(abs([d.lat(:);d.long(:)])*100,100))<=61
                            if std(d.lat)<.1 & std(d.lon)<.1 % ship hasn't moved much
                                warning('Cannot determine whether or not to apply cnav fix. Not applying.');
                                sensors_to_cal={};
                            else
                                mdocshow(scriptname, ['applying cnav fix to cnav_' mcruise '_d' day_string '_edt.nc']);
                                sensors_to_cal={'lat','long'};
                                sensorcals={'y=cnav_fix(x1)' 'y=cnav_fix(x1)'};
                                sensorunits={'/','/'}; % keep existing units
                            end
                        else
                            mdocshow(scriptname, ['cnav fix not required for cnav_' mcruise '_d' day_string '_edt.nc']);
                            sensors_to_cal={};
                        end
                    otherwise
                        sensors_to_cal={};
                end
        end
        %%%%%%%%%% end mday_01_clean_av %%%%%%%%%%
        
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
        
        
        %%%%%%%%%% vmadcp_proc %%%%%%%%%%
    case 'vmadcp_proc'
        switch oopt
            case 'aa0_75' %set approximate/nominal instrument angle
                ang = 0; amp = 1;
            case 'aa0_150' %set approximate/nominal instrument angle
                ang = 0; amp = 1;
            case 'aa75' %refined additional rotation and amplitude corrections based on btm/watertrk
                ang = 0;
                amp = 1;
            case 'aa150' %refined additional rotation and amplitude corrections based on btm/watertrk
                ang = 0;
                amp = 1;
        end
        %%%%%%%%%% end vmadpc_proc %%%%%%%%%%
        
        
        %%%%%%%%%% mvad_01 %%%%%%%%%%
    case 'mvad_01'
        switch oopt
            case 'files'
                datadir = [root_vmadcp '/mproc/dy113/' inst nbbstr '/contour'];
                fnin = [datadir '/' inst nbbstr '.nc'];
                dataname = [inst nbbstr '_' mcruise '_01'];
                %vmdas defaults
                %                pre1 = [mcruise '_' inst '/adcp_pyproc/' mcruise '_enrproc/' inst nbbstr];
                %                datadir = [root_vmadcp '/' pre1 '/contour'];
                %                fnin = [datadir '/' inst nbbstr '.nc'];
                %                dataname = [inst '_' mcruise '_01'];
        end
        %%%%%%%%%% end mvad_01 %%%%%%%%%%
        
        %%%%%%%%%% vel_compare %%%%%%%%%%
    case 'vel_compare'
        switch oopt
            case 'lpre'
                %directory for uhladcp files, e.g.
                %lpre = '/local/users/pstar/cruise/data/ladcp/uh/pro/jc1802/ladcp/proc/matprof/h/';
        end
        %%%%%%%%%% end vel_compare %%%%%%%%%%
        
        
end
