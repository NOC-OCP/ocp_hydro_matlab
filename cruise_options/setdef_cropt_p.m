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
    
        %%%%%%%%%% station_summary %%%%%%%%%%
    case 'station_summary'
        switch oopt
            case 'optsams'
                snames = {'nsal'}; 
                sgrps = {{'sal'}}; 
                sashore = [0]; 
            case 'stnmiss'
                stnmiss = []; %this is only for processed stations numbered between 1 and 900 that you don't want to include in the summary
            case 'cordep'
                cordep(k) = h2.water_depth_metres; % jc159 changed to h2, which is header from psal instead of 2db
            case 'comments'
                %             comments = cell(size(stnall));
                comments = cell(max(stnall),1); % bak fix jc159 30 March 2018; If stnall = [1 2 3 5] then size(stnall) is 4 but we need comments ot be of size 5 so we can prepare comments by station number rather than by index in stnall
            case 'altdep'
            case 'varnames'
                varnames={'statnum' 'time_start' 'time_bottom' 'time_end' 'lat' 'lon' 'cordep' 'maxd' 'minalt' 'resid' 'maxw' 'maxp' 'ndpths' 'nsal'}; %these probably won't change, but in any case the first 6 should always be the same
                varnames = [varnames snames']; %if snames has been set in opt_cruise, this will incorporate it
                varunits = {'number' 'seconds' 'seconds' 'seconds' 'deg min' 'deg min' 'metres' 'metres' 'metres' 'metres' 'metres' 'dbar' 'number' 'number'};
                varunits = [varunits  repmat({'number'},1,length(snames)) ];
        end
        %%%%%%%%%% end station_summary %%%%%%%%%%
                
        %%%%%%%%%% mout_cchdo %%%%%%%%%%
    case 'mout_cchdo'
        switch oopt
            case 'expo'
                crhelp_str = {'information for header of exchange-format csv files: '
                    'expocode and sect_id (defaults: ''unknown'')'};
                expocode = 'unknown';
                sect_id = 'unknown';
            case 'woce_ctd_flags';
                crhelp_str = {'optional: change flags from default of 2 where data present, 9 otherwise'};
            case 'woce_file_pre'
                crhelp_str = {'prefix: filename prefix for exchange-format csv file of ctd data '
                    '(default: expocode)'};
                prefix = expocode;
            case 'woce_ctd_headstr'
                crhelp_str = {'optional ctdheadstring is a cell array of strings to add to header of '
                    'exchange-format csv file of ctd data (default: empty)'};
                headstring = [];
            case 'woce_sam_headstr'
                crhelp_str = {'optional samheadstring is a cell array of strings to add to header of '
                    'exchange-format csv file of sample data (default: empty)'};
                headstring = [];
            case 'woce_file_flagonly'
                crhelp_str = {'varsexclude is a cell array listing variables to NaN before printing to'
                    'exchange-format csv files (default: {})'};
                varsexclude = {};
        end
        %%%%%%%%%% end mout_cchdo %%%%%%%%%%
        
        %%%%%%%%%% msec_run_mgridp %%%%%%%%%%
    case 'msec_run_mgridp'
        switch oopt
            case 'sections'
                crhelp_str = {'sections (cell array) contains a list of all sections to grid for this cruise'};
            case 'gpars'
                crhelp_str = {'Set gstart, gstop, and gstep to override section-dependent default pressure grid'
                    'range and spacing (dbar) coded in msec_run_mgridp.'};
                gstart = []; gstop = []; gstep = []; 
            case 'ctd_regridlist'
                crhelp_str = {'ctd_regridlist (string) is a list of CTD variables separated by spaces to grid using '
                    'mgridp. Default is [''press temp psal potemp oxygen'']}. Make ctd_regridlist empty to not rerun '
                    'the gridding.'};
                ctd_regridlist  = ['press temp psal potemp oxygen'];
            case 'sec_stns'
                crhelp_str = {'kstns (1xN) contains list of stations (on this cruise) in each section'};
            case 'sam_gridlist'
                crhelp_str = {'varuselist.names (default: {''botpsal'' ''botoxy''}) contains a list of sample '
                    'variables to grid.'};
                varuselist.names = {'botpsal' 'botoxy'};
        end
        %%%%%%%%%% end msec_run_mgridp %%%%%%%%%%
        
        %%%%%%%%%% m_maptracer %%%%%%%%%%
    case 'm_maptracer'
        switch oopt
            case 'samfn'
                samfn = [root_ctd '/sam_' MEXEC_G.MSCRIPT_CRUISE_STRING '_all' ];
            case 'kstatgroups'
                kstatgroups = {[1:999]};
            case 'xzlim'
                flaglim = 2; % default 2; highest flag to be used for gridding
                s.xlim = 2; % default 1; width of gridding window, +/- xlim, measured in statnum
                s.zlim = 4; % default 4; vertical extent of gridding window measured in plev
                % bak jc191 reset s.xlim and s.zlim in a cruise option.
                % s.xlim and s.zlim are the half-width of the number of points used in the
                % local fit. ie s.xlim = 1 means three stations used. This one and one
                % either side.
            case 'scales_xz'
                % bak jc191 feb 2020 . scale_x and scale_z are scalings on the distances xu and zu.
                % xu and zu measure the distance away in counts of stations for x and
                % levels for z. s.xlim and s.zlim control the number of stations/levels
                % included. scale_x and scale_z control the relative importance of
                % those distances in the weight. So low values of scale_x and scale_z
                % make the map smoother by not reducing the weight of more distant points.
                % High values of scale_x and scale_z give high weight to nearby points
                % and low weight to distant points. Default for scale_x and scale_z is
                % unity, unless changed in opt_cruise.
                scale_x = 0.5; % choose value < 1 for smoother
                scale_z = 1;
        end
        %%%%%%%%%% end m_maptracer %%%%%%%%%%      
        
        %%%%%%%%%% msec_plot_contrs %%%%%%%%%%
    case 'msec_plot_contrs'
        switch oopt
            case 'add_station_depths'
                crhelp_str = {'station_depth_width (default 0), if greater than 0, gives linewidth '
                    'for adding station depths to contour plots.'};
                station_depth_width = 0;
            case 'add_bottle_depths'
            crhelp_str = {'bottle_depth_size (default 0), if greater than 0, gives markersize '
                'for adding bottle positions to contour plots.'};
                bottle_depth_size = 0;
        end
        %%%%%%%%%% end msec_plot_contrs %%%%%%%%%%

        %%%%%%%%%% set_clev_col %%%%%%%%%%
    case 'set_clev_col'
        switch oopt
            case 'samfn'

end
