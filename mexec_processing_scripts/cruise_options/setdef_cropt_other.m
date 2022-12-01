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
    
    case 'm_setup'
        switch oopt
            case 'time_origin'
                crhelp_str = {'Set MEXEC_G.MDEFAULT_DATA_TIME_ORIGIN, 6-element vector [yyyy mm dd HH MM SS],'
                    'usually the start of the cruise year'};
            case 'setup_datatypes'
                crhelp_str = {'Set use_ix_ladcp to ''yes'' (default) if you are collecting '
                    'LADCP data and want to add LDEO IX scripts to the path; set to '
                    '''query'' if you are processing both LADCP and mooring data on this '
                    'cruise, so that m_setup will ask which to add to path (due to repeated'
                    'filenames); set to ''no'' to never add.'
                    'Set skipunderway to 0 to read in and process ship underway data'
                    '(default if MEXEC_G.SITE contains ''atsea''),'
                    '1 to set best nav stream etc. but not set up underway directories'
                    '(default otherwise)'
                    'and 2 to ignore underway data entirely.'};
                use_ix_ladcp = 'yes';
                if contains(MEXEC_G.SITE,'atsea')
                    skipunderway = 0;
                else
                    skipunderway = 1;
                end
        end
        
        %%%%%%%%%% batchactions (not a script) %%%%%%%%%%
    case 'batchactions'
        switch oopt
            case 'output_for_others'
                crhelp_str = {'additional actions after operating on ctd or sam files'
                    'for instance to sync the resulting files'
                    'to a shared drive accessible by e.g. chemistry team'};
        end
        %%%%%%%%%% batchactions (not a script) %%%%%%%%%%
        
        
        %%%%%%%%%% station_summary %%%%%%%%%%
    case 'station_summary'
        switch oopt
            case 'sum_stn_list'
                crhelp_str = {'stnmiss (default []) is a list of CTD station numbers that have '
                    'been processed but that are to be excluded from the summary;'
                    'stnadd (default []) is a list of stations without processed CTD data that '
                    'are to be included.'};
                stnmiss = [];
                stnadd = [];
            case 'sum_varsams'
                crhelp_str = {'Place to set or select from vars, a list of station/ctd variables, their '
                    'units, fill values, and formats for printing to table (see code for defaults); '
                    'snames (default {''nsal''} a list of variable groups to count,'
                    'sgrps (default {{''sal''}}), a list of the corresponding variable names.'
                    'For samples analysed ashore, elements of snames should end in _shore.'};
                %names, units, fill values, table headers, formats for printing to table
                %rows with empty units are for table only, rows with empty
                %header/formats are for .nc file only, rows with header
                %column -1 are printed before the rest, with header column
                %+1 after
                %if last column is not a format string the row must have
                %code to print it under case sum_special_print
                vars = {
                    'statnum'      'number'    -999  'stn '            '%03d '
                    'time_start'   'seconds'   -999  -1                ''
                    'time_bottom'  'seconds'   -999  'yy/mm/dd     '   'special'
                    'time_end'     'seconds'   -999  1                 ''
                    'lat'          'degN'      -999  'lat deg min '    'special'
                    'lon'          'degE'      -999  'lon deg min '    'special'
                    'cordep'       'metres'    -999  'cordep'          '  %4.0f'
                    'maxd'         'metres'    -999  'maxd'            '%4.0f'
                    'minalt'       'metres'    -9    'minalt'          '   %2.0f'
                    'resid'        'metres'    -9    'resid'           ' %4.0f '
                    'maxw'         'metres'    -999  'maxw'            '%4.0f'
                    'maxp'         'metres'    -999  'maxp'            '%4.0f'
                    'ndepths'      'number'     0    'ndpths'          '    %2d'
                    };
                snames = {'nsal'};
                sgrps = {{'botpsal'}}; % salt
            case 'sum_extras'
                crhelp_str = {'Place to add columns before or after the existing ones, for instance'
                    'for event numbers or station names, or comments. Add the names to vars either '
                    'at the start or end, and set the corresponding variables as cell arrays.'};
            case 'sum_edit'
                crhelp_str = {'Place to edit cordep, the vector of corrected depths for the set of stations'
                    'to be processed (default is to get from _psal file header), and/or minalt, the minimum '
                    'altimeter distance above bottom (set to -9 for did not detect the bottom));'
                    'also to set times for stations with no ctd cast.'};
            case 'sum_special_print'
                crhelp_str = {'Code for printing special cases, by default lat and lon in degrees minutes'
                    'format, and start, bottom, and end times as yy/mm/dd HHMM.'};
                switch vars{cno,1}
                    case 'time_start'
                        ii = find(strcmp('time_bottom',vars(:,1))); ii = 1:ii-1;
                        co = 0;
                        for pcno = 1:length(ii)
                            co = co + length(vars{ii(pcno),4});
                        end
                        svar = [repmat(' ',1,co+1) datestr(ds.time_start(k), ' yy/mm/dd HHMM ')];
                    case 'time_bottom'
                        svar = datestr(ds.time_bottom(k), 'yy/mm/dd HHMM');
                    case 'time_end'
                        svar = [repmat(' ',1,co+1) datestr(ds.time_end(k), ' yy/mm/dd HHMM')];
                    case 'lat'
                        latd = floor(abs(ds.lat(k))); latm = 60*(abs(ds.lat(k))-latd); if latm>=59.995; latm = 0; latd = latd+1; end
                        if ds.lat(k)>=0; lath = 'N'; else; lath = 'S'; end
                        svar = sprintf('%02d %06.3f %s ', latd, latm, lath);
                    case 'lon'
                        lond = floor(abs(ds.lon(k))); lonm = 60*(abs(ds.lon(k))-lond); if lonm>=59.995; lonm = 0; lond = lond+1; end
                        if ds.lon(k)>=0; lonh = 'E'; else; lonh = 'W'; end
                        svar = sprintf('%03d %06.3f %s', lond, lonm, lonh);
                end
        end
        %%%%%%%%%% end station_summary %%%%%%%%%%
        
        
        %%%%%%%%%% mout_exch %%%%%%%%%%
    case 'mout_exch'
        switch oopt
            case 'woce_expo'
                crhelp_str = {'information for header of exchange-format csv files: '
                    'expocode and sect_id (defaults: ''unknown'' and empty, respectively)'};
                expocode = 'unknown';
                sect_id = '';
            case 'woce_ctd_flags'
                crhelp_str = {'optional: change flag variables ctdflag (temp, sal), ctoflag (oxygen), '
                    'ctdfflag (fluor) from default of 2 where data present, 9 otherwise'};
            case 'woce_vars_exclude'
                crhelp_str = {'vars_exclude_ctd and vars_exclude_sam are lists of mstar variable names'
                    'to exclude from woce exchange-format output files for submission to cchdo, even if '
                    'they are in ctd/sam files and in lists set in m_cchdo_vars_list.m. '
                    'Defaults: vars_exclude_ctd = {}, vars_exclude_sam = {}.'};
                vars_exclude_ctd = {}; %changed jc238 from {'fluor' 'transmittance'};
                vars_exclude_sam = {};
            case 'woce_file_flagonly'
                crhelp_str = {'varsexclude is a cell array listing variables to NaN before printing to'
                    'exchange-format csv files (default: {})'};
                varsexclude = {};
            case 'woce_ctd_headstr'
                crhelp_str = {'optional headstring is a cell array of strings to add to header of '
                    'exchange-format csv file of ctd data (default: empty)'};
            case 'woce_sam_headstr'
                crhelp_str = {'optional headstring is a cell array of strings to add to header of '
                    'exchange-format csv file of sample data (default: empty)'};
        end
        %%%%%%%%%% end mout_exch %%%%%%%%%%
        
        %%%%%%%%%% msec_grid %%%%%%%%%%
    case 'msec_grid'
        switch oopt
            case 'sections_to_grid'
                crhelp_str = {'sections (cell array) contains a list of all sections to grid for this cruise'};
            case 'sec_stns_grids'
                crhelp_str = {'Use switch-case on section to set kstns (1xN, default 1:99):'
                    'list of stations (on this cruise) for each section;'
                    'xstatnumgrid and zpressgrid for maphsec (default [], if left empty they'
                    'will be looked up in msec_grid based on section, or set to maphsec defaults).'};
                kstns = 1:99;
                xstatnumgrid = [];
                zpressgrid = [];
            case 'ctd_regridlist'
                crhelp_str = {'ctd_regridlist is a cell array list of CTD variables to be gridded;'
                    'default is temp, psal, potemp, oxygen. If empty, gridded CTD data will'
                    'be loaded from existing grid_ file and only bottle data will be remapped.'};
                ctd_regridlist  = {'temp' 'psal' 'potemp' 'oxygen'};
            case 'sam_gridlist'
                crhelp_str = {'sam_gridlist is a cell array list of bottle variables to be gridded;'
                    'default is botpsal, botoxy.'};
                sam_gridlist = {'botpsal' 'botoxy'};
        end
        %            case 'xzlim'
        %                flaglim = 2; % default 2; highest flag to be used for gridding
        %                s.xlim = 2; % default 1; width of gridding window, +/- xlim, measured in statnum
        %                s.zlim = 4; % default 4; vertical extent of gridding window measured in plev
        %                % bak jc191 reset s.xlim and s.zlim in a cruise option.
        %                % s.xlim and s.zlim are the half-width of the number of points used in the
        %                % local fit. ie s.xlim = 1 means three stations used. This one and one
        %                % either side.
        %            case 'scales_xz'
        %                % bak jc191 feb 2020 . scale_x and scale_z are scalings on the distances xu and zu.
        %                % xu and zu measure the distance away in counts of stations for x and
        %                % levels for z. s.xlim and s.zlim control the number of stations/levels
        %                % included. scale_x and scale_z control the relative importance of
        %                % those distances in the weight. So low values of scale_x and scale_z
        %                % make the map smoother by not reducing the weight of more distant points.
        %                % High values of scale_x and scale_z give high weight to nearby points
        %                % and low weight to distant points. Default for scale_x and scale_z is
        %                % unity, unless changed in opt_cruise.
        %                scale_x = 0.5; % choose value < 1 for smoother
        %                scale_z = 1;
        
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
        
    case 'mout_1hzasc'
        switch oopt
            case '1hz_fname'
                crhelp_str = {'name, fnot, for text file of 1Hz CTD data (e.g. for IX LADCP processing'};
                root_out = mgetdir('M_LADCP');
                fnot = fullfile(root_out, 'CTD', ['ctd.' stn_string '.02.asc']);
        end
        
        %%%%%%%%%% ix_cast_params %%%%%%%%%%
    case 'ix_cast_params'
        switch oopt
            case 'ladcpopts'
                crhelp_str = {'place to change parameters for IX ladcp processing that are set in'
                    '(or can be set in) ix_cast_params as fields of (existing) structure p,'
                    'for instance: '
                    'p.ambiguity (ambiguity velocity), p.vlim (velocity limits), '
                    'p.btrk_mode (bottom track mode), p.up_sn and p.do_sn (instrument serial'
                    'numbers), etc.; see ix_cast_params for more'};
        end
        %%%%%%%%%% end ix_cast_params %%%%%%%%%%
        
    case 'run_proc_ladcp'
        switch oopt
            case 'is_uplooker'
                crhelp_str = {'isul (default 1) sets whether there is an uplooking as well as a'
                    'downlooking LADCP'};
                isul = 1;
        end
        
    case 'codas_to_mstar'
        switch oopt
            case 'codas_file'
                fnin = fullfile(root_vmadcp, 'postprocessing', upper(mcruise), 'proc_editing', inst, 'contour', [inst '.nc']);
        end
        
end
