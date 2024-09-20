switch opt1

    case 'ctd_proc'
        switch opt2
            case 'redoctm'
                redoctm = 0; %start from _align_CTM
            case 'cnvfilename'
                % datadir = ***
                cnvfile = fullfile(datadir, sprintf('%s_CTD%03d_align_CTM.cnv',upper(mcruise),stn));
            case 'raw_corrs'
                co.dooxyhst = 0; %already done
        end

    case 'setup'
        switch opt2
            case 'time_origin'
                MEXEC_G.MDEFAULT_DATA_TIME_ORIGIN = [2023 1 1 0 0 0];
            case 'mdirlist'
                MEXEC_G.MDIRLIST{strcmp('M_CTD_CNV',MEXEC_G.MDIRLIST,1),2} = 'CTD_Processed';
                MEXEC_G.MDIRLIST{strcmp('M_CTD',MEXEC_G.MDIRLIST,1),2} = 'Proc_At_NOC';
                MEXEC_G.MDIRLIST{strcmp('M_BOT_OXY',MEXEC_G.MDIRLIST,1),2} = 'DO_data';
                MEXEC_G.MDIRLIST{strcmp('M_BOT_SAL',MEXEC_G.MDIRLIST,1),2} = 'Autosal_Data';

        end

    case 'botpsal'
        switch opt2
            

        end

end
