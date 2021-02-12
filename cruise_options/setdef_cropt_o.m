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
    
    %%%%%%%%%% batchactions (not a script) %%%%%%%%%%
    case 'batchactions'
        switch oopt
            case 'ctd'
                crhelp_str = {'additional actions after operating on ctd files, default will be*** to run mout_cchdo_ctd'};
                %stn = stnlocal; mout_cchdo_ctd %station_summary first?
            case 'sam'
                crhelp_str = {'additional actions after operating on sam files, default will be*** to run mout_cchdo_sam'};
                %mout_cchdo_sam
            case 'sync'
                crhelp_str = {'actions to sync mstar processed data and other output files to shared drive, no default'};
        end
    %%%%%%%%%% batchactions (not a script) %%%%%%%%%%    
    
    
    %%%%%%%%%% station_summary %%%%%%%%%%
    case 'station_summary'
        switch oopt
            case 'sum_sams'
                crhelp_str = {'snames (default {''nsal''; ''noxy''} lists variable groups to count,'
                    'snames_shore (default {''nsal_shore''; ''noxy_shore''} lists the corresponding group names for '
                    'variables to be analysed ashore, '
                    'sgrps (default {{''sal''}; {''botoxy''}}) lists the corresponding variable names in each group,'
                    'and sashore (default [0 0]) is a flag for which of snames_shore will be used (as opposed to all done at sea).'};
                snames = {'nsal'; 'noxy'};
                snames_shore = {};
                sgrps = {{'sal'} % salt
                    {'botoxy'}}; % oxygen
                sashore = [0; 0];
            case 'sum_varnames'
                crhelp_str = {'varnames is a list of variables, besides the numbers of samples, to include in the'
                    'station summary; varunits is the corresponding units'};
            case 'sum_stn_list'
                crhelp_str = {'stnmiss (default []) is a list of CTD station numbers that have '
                    'been processed but that are to be excluded from the summary;'
                    'stnadd (default []) is a list of stations without processed CTD data that '
                    'are to be included.'};
                stnmiss = []; 
                stnadd = [];
            case 'sum_dep_edit'
                crhelp_str = {'Place to edit cordep, the vector of corrected depths for the set of stations'
                    'to be processed (default is to get from _psal file header), and minalt, the minimum '
                    'altimeter distance above bottom (set to -9 for did not detect the bottom)).'};
            case 'alttimes'
            case 'sum_comments'
                crhelp_str = {'Place to fill in comments, a cell array of comments for each station in'
                    'list (default Nx1, each empty)'};
        end
        %%%%%%%%%% end station_summary %%%%%%%%%%
        
        %%%%%%%%%% mout_cchdo %%%%%%%%%%
    case 'mout_cchdo'
        switch oopt
            case 'expo'
                crhelp_str = {'information for header of exchange-format csv files: '
                    'expocode and sect_id (defaults: ''unknown'')'};
                expocode = '740H20210202';
                sect_id = 'SR1b_A23';
            case 'woce_ctd_flags';
                crhelp_str = {'optional: change flags from default of 2 where data present, 9 otherwise'};
            case 'woce_file_pre'
                crhelp_str = {'prefix: filename prefix for exchange-format csv file of ctd data '
                    '(default: expocode)'};
                prefix = expocode;
            case 'woce_ctd_headstr'
                crhelp_str = {'optional ctdheadstring is a cell array of strings to add to header of '
                    'exchange-format csv file of ctd data (default: empty)'};
                headstring = {['CTD,' datestr(now,'yyyymmdd') 'POGBASEPA'];...
                    '#SHIP: James Cook';...
                    '#Cruise JC211; SR1B and A23';...
                    '#Region: Drake Passage, Weddell Sea, Scotia Sea';...
                    ['#EXPOCODE: ' expocode];...
                    '#DATES: 20210202 - 20210307';...
                    '#Chief Scientist: E. P. Abrahamsen, BAS';...
                    '#Supported by NERC National Capability NE/N018095/1 (ORCHESTRA)';...
                    '#?? stations with 24-place rosette';...
                    '#Notes: PI for SR1B section (??-??): Y. Firing; PI for A23 section (??-??): E. P. Abrahamsen';...
                    '#CTD: Who - B. King and Y. Firing; Status - preliminary';...
                    '#Notes: Includes CTDSAL, CTDOXY, SBE35';...
                    '#CTD data not yet calibrated';...%'#The CTD PRS;  TMP;  SAL; OXY data are all calibrated and good.';...
                    '# DEPTH_TYPE   : COR';...
                    '#These data should be acknowledged with: "Data were collected and made publicly available by the international Global Ship-based Hydrographic Investigations Program (GO-SHIP; http://www.go-ship.org/) with National Capability funding from the UK Natural Environment Research Council to the National Oceanography Centre and the British Antarctic Survey."'};
            case 'woce_sam_headstr'
                crhelp_str = {'optional samheadstring is a cell array of strings to add to header of '
                    'exchange-format csv file of sample data (default: empty)'};
                headstring = {['BOTTLE,' datestr(now,'yyyymmdd') 'POGBASEPA'];... %the last field specifies group, institution, initials
                    '#SHIP: James Cook';...
                    '#Cruise JC211; SR1B and A23';...
                    '#Region: Drake Passage, Weddell Sea, Scotia Sea';...
                    ['#EXPOCODE: ' expocode];...
                    '#DATES: 20210202 - 20210307';...
                    '#Chief Scientist: E. P. Abrahamsen, BAS';...
                    '#Supported by NERC National Capability NE/N018095/1 (ORCHESTRA)';...
                    '#?? stations with 24-place rosette';...
                    '#Notes: PI for SR1B section (??-??): Y. Firing; PI for A23 section (??-??): E. P. Abrahamsen';...
                    '#CTD: Who - B. King and Y. Firing; Status - not yet calibrated';...
                    '#Notes: Includes CTDSAL, CTDOXY, SBE35';...
                    '#CTD data not yet calibrated';...%'#The CTD PRS;  TMP;  SAL; OXY data are all calibrated and good.';...
                    '#CTD files also contain CTDXMISS, CTDFLUOR';...
                    '#Salinity: Who - A. Marzocchi; Status - not yet analysed';...
                    '#Oxygen: Who - Y. Firing; Status - not yet analysed';...
                    '#Nutrients: Who - C. Liszka; Status - not yet analysed';...
                    '#DELO18: Who - M. Leng; Status - not yet analysed';...
                    '#Nutrient isotopes: Who - S. Fielding/K. Hendry?; Status - not yet analysed';...
                    '#POM: Who - G. Stowasser - not yet analysed';...
                    '#Chlorophyll: Who - C. Liszka; Status - not yet analysed';...
                    '#These data should be acknowledged with: "Data were collected and made publicly available by the international Global Ship-based Hydrographic Investigations Program (GO-SHIP; http://www.go-ship.org/) with National Capability funding from the UK Natural Environment Research Council to the National Oceanography Centre and the British Antarctic Survey."'};
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
        %%%%%%%%%% end set_clev_col %%%%%%%%%%
        
                %%%%%%%%%% set_cast_params_cfgstr %%%%%%%%%%
    case 'set_cast_params_cfgstr'
        switch oopt
            case 'ladcpopts'
                crhelp_str = {'place to change parameters for IX ladcp processing that are set in'
                    '(or can be set in) set_cast_params_cfgstr, for instance: '
                    'ambiguity velocity, velocity limits, bottom track mode, instrument serial'
                    'numbers, etc.'};
        end
        %%%%%%%%%% end set_cast_params_cfgstr %%%%%%%%%%

        
end
