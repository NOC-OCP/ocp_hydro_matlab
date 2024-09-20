switch opt1

case 'setup'
    switch opt2
        case 'setup_datatypes'
            use_ix_ladcp = 1;
        case 'time_origin'
            MEXEC_G.MDEFAULT_DATA_TIME_ORIGIN = [2024 1 1 0 0 0];
    end

case 'ctd_proc'


end

