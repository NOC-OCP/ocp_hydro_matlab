switch opt1
    case 'setup'
        switch opt2
            case 'time_origin'
                MEXEC_G.MDEFAULT_DATA_TIME_ORIGIN = [2026 1 1 0 0 0];
        end

    case 'ship'
        switch opt2
            case 'rvdas_database'
                RVDAS.database = 'DY203post';
        		RVDAS.loginfile = '/data/plocal/rvdas_addr';
        end

end