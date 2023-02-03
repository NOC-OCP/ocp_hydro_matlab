ticasts = [3 4 7 11];

switch scriptname

    case 'm_setup'
        switch oopt
            case 'time_origin'
        MEXEC_G.MDEFAULT_DATA_TIME_ORIGIN = [2023 1 1 0 0 0];
            case 'setup_datatypes'
                skipunderway = 0;
        end

    case 'castpars'
        switch oopt
            case 'oxy_align'
                oxy_end = 1;
            case 'shortcasts'
                shortcasts = [3 4 7];
            case 'ctdsens_groups'
        end

    case 'mctd_01'
        switch oopt
            case 'redoctm'
                redoctm = 1;
            case 'cnvfilename'
                if ismember(stnlocal,ticasts)
                    cnvfile = sprintf('%s_%03d_Ti.cnv',upper(mcruise),stnlocal);
                else
                    cnvfile = sprintf('%s_%03d_SS.cnv',upper(mcruise),stnlocal);
                end
                cnvfile = fullfile(mgetdir('M_CTD_CNV'),cnvfile);
            case 'ctdvars'
                ctdvars_add = {};
            case 'absentvars'
        end

    case 'mfir_01'
        switch oopt
            case 'blinfile'
                if ismember(stnlocal,ticasts)
                    blinfile = fullfile(root_botraw,sprintf('%s_%03d_Ti.bl', upper(mcruise), stnlocal));
                else
                    blinfile = fullfile(root_botraw,sprintf('%s_%03d_SS.bl', upper(mcruise), stnlocal));
                end
        end

end