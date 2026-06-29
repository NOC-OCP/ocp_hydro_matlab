switch opt1

    case 'setup'
        switch opt2
            case 'time_origin'
                MEXEC_G.MDEFAULT_DATA_TIME_ORIGIN = [2024 1 1 0 0 0];
            case 'setup_datatypes'
                use_ix_ladcp = 'no';
        end

    case 'ship'
        switch opt2
            case 'rvdas_skip'
                skips.sentence_pat = [skips.sentence, 'logta'];
        end

end
