switch opt1

    case 'setup'
        switch opt2
            case 'time_origin'
                MEXEC_G.MDEFAULT_DATA_TIME_ORIGIN = [2024 1 1 0 0 0 ];
            case 'setup_datatypes'
                use_ix_ladcp = 'no';
        end

    case 'ship'
        switch opt2
            case 'datasys_best'
                default_navstream = 'pospmv';
                default_hedstream = 'attpmv';
                default_attstream = 'attpmv';
            case 'rvdas_database'
                RVDAS.machine = '192.168.65.51';
                RVDAS.jsondir = '/data/pstar/mounts/mnt_cruise_data/Ship_Systems/Data/RVDAS/Sensorfiles/'; %original
                RVDAS.user = 'sciguest';
                RVDAS.database = ['"' upper(MEXEC_G.MSCRIPT_CRUISE_STRING) '"'];
        end
    case 'uway_daily_proc'
        switch opt2
            case 'excludestreams'
                uway_excludes = [uway_excludes;'autosal';'ranger2usbl2'];
        end

end

