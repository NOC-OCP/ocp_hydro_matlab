switch opt1
    case 'setup'
        switch opt2
            case 'time_origin'
                MEXEC_G.MDEFAULT_DATA_TIME_ORIGIN = [2026 1 1 0 0 0];
        end

    case 'ship'
        switch opt2
            case 'rvdas_database'
        		RVDAS.loginfile = '/data/plocal/rvdas_addr';
                RVDAS.jsondir = fullfile(MEXEC_G.mexec_data_root,'rvdas','json_files');
        end

end