switch scriptname

    case 'm_setup'
        switch oopt
            case 'time_origin'
        MEXEC_G.MDEFAULT_DATA_TIME_ORIGIN = [2023 1 1 0 0 0];
            case 'setup_datatypes'
                skipunderway = 1;
        end

end