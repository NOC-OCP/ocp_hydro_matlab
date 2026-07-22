switch opt1
    
    case 'setup'
        switch opt2
            case 'time_origin'
                MEXEC_G.MDEFAULT_DATA_TIME_ORIGIN = [2026 1 1 0 0 0];
        end

    case 'ctd_proc'
        switch opt2
            case 'ctdfiles'
                cnvfile = fullfile(MEXEC_G.MDIRLIST.M_CTD_CNV,[upper(mcruise) '_' stn_string '.cnv']);
            case 'rawedit_auto'
                co.redoctm = 1;
        end

    case 'nisk_proc'
        switch opt2
            case 'blfilename'
                f = sprintf('%s_%s',upper(mcruise),stn_string);
                blinfile = fullfile(MEXEC_G.MDIRLIST.M_CTD_BOT,[f '.bl']);
        end


end
