
switch opt1

    case 'setup'
        switch opt2
            case 'time_origin'
                MEXEC_G.MDEFAULT_DATA_TIME_ORIGIN = [2026 1 1 0 0 0];
        end

    case 'shipuway'
        switch opt2
            case 'rvdas_database'
                RVDAS.loginfile = '/data/plocal/rvdas_addr';
        end
    
    case 'uway_proc'
        switch opt2
            case 'datasys_best'
                default_navstream = 'posmv_gpgga';
                default_hedstream = 'posmv_pashr';
                default_attstream = 'posmv_pashr';
            case 'rvdas_skip'
                % %usbl not used, wamos not used
                % %don't need to read ctd depth through rvdas
                % %can read surfmet variables from nudam instead
                % skips.sentence_pat = [skips.sentence_pat, ...
                %     'usbl', 'wamos', 'ctuopd', 'surfmet'];
                % %below tables are present but have 0 data (return COPY 0)
                skips.sentence = [skips.sentence, ...
                    'truewind_truewind', ...
                    'ranger2usbl_psonlld', 'ctd_smctd', ...
                     ];
        end
    case 'ctd_proc'
        switch opt2
            case 'ctdfiles'
                cnvfile = fullfile(MEXEC_G.MDIRLIST.M_CTD_CNV,...
                    sprintf('%s_CTD%s.cnv', upper(mcruise), stn_string));
            case 'redoctm'
                redoctm = 1;
            case 'niskfilename'            
                blinfile = fullfile(MEXEC_G.MDIRLIST.M_CTD_BOT,...
                    sprintf('%s_CTD%s.bl', upper(mcruise), stn_string));
            case 'rawshow'
                if stn==1 
                    yl.cond = [48 50];
                    yl.press = [-2 40];
                    yl.temp = [20.5 21];
                    yl.fluor = [0 2];
                    yl.turbidity = [0 0.2];
                end

        
        end
    
end
