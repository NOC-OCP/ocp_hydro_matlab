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
            case 'mdirlist'
                MEXEC_G.MDIRLIST{strcmp('M_CTD_CNV',MEXEC_G.MDIRLIST,1),2} = 'CTD - Pro';
        end

end
