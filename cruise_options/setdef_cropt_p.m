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
    
   
        
        %%%%%%%%%% mout_cchdo_ctd %%%%%%%%%%
    case 'mout_cchdo_ctd'
        switch oopt
            case 'expo'
                expocode = 'unknown';
                sect_id = 'unknown';
            case 'outfile'
                outfile = [expocode '_ct1'];
            case 'headstr'
                headstring = [];
        end
        %%%%%%%%%% end mout_cchdo_ctd %%%%%%%%%%
        
                %%%%%%%%%% mout_cchdo_sam %%%%%%%%%%
    case 'mout_cchdo_sam'
        switch oopt
            case 'expo'
                expocode = 'unknown';
                sect_id = 'unknown';
            case 'nocfc'
                nocfc = 0;
            case 'outfile'
                outfile = expocode;
            case 'headstr'
                headstring = [];
        end
        %%%%%%%%%% end mout_cchdo_sam %%%%%%%%%%
        

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
        
        %%%%%%%%%% msec_run_mgridp %%%%%%%%%%
    case 'msec_run_mgridp'
        switch oopt
            case 'sections'
                %set list of all sections here, if not specified as an input (see opt_jr302)
            case 'gpars'
                gstart = []; gstop = []; gstep = []; %default grid range and spacing--can be set per cruise but is also specified by section name in msec_run_mgridp (or can be provided as an input argument)
            case 'varlist'
                varlist  = ['press temp psal potemp oxygen'];
            case 'kstns'
            case 'varuse'
        end
        %%%%%%%%%% end msec_run_mgridp %%%%%%%%%%
                
        
end
