ticasts = [3 4 7 11 12:21];

switch scriptname

    case 'm_setup'
        switch oopt
            case 'time_origin'
        MEXEC_G.MDEFAULT_DATA_TIME_ORIGIN = [2023 1 1 0 0 0];
            case 'setup_datatypes'
                skipunderway = 0;
        end

    case 'castpars'
        switch oopt
            case 'oxy_align'
                oxy_end = 1;
            case 'shortcasts'
                shortcasts = [3 4 7 11 12 13];
            case 'ctdsens_groups'
        end

    case 'mctd_01'
        switch oopt
            case 'redoctm'
                redoctm = 1;
            case 'cnvfilename'
                if ismember(stnlocal,ticasts)
                    cnvfile = sprintf('%s_%03d_Ti.cnv',upper(mcruise),stnlocal);
                else
                    cnvfile = sprintf('%s_%03d_SS.cnv',upper(mcruise),stnlocal);
                end
                cnvfile = fullfile(mgetdir('M_CTD_CNV'),cnvfile);
            case 'ctdvars'
                ctdvars_add = {};
            case 'absentvars'
        end

    case 'mfir_01'
        switch oopt
            case 'blinfile'
                blinfile = fullfile(root_botraw,sprintf('%s_%03d_',upper(mcruise),stnlocal));
                if ismember(stnlocal,ticasts)
                    blinfile = [blinfile 'Ti.bl'];
                else
                    blinfile = [blinfile 'SS.bl'];
                end
            case 'botflags'
                %3 = leak (confirmed after sampling), 4 = misfire, 7 = possible issue
                %(unclear, investigate further), 9 = no samples
                switch stnlocal
                    case 2 % CTD number
                        niskin_flag(ismember(position,[2 11 16])) = 4 ;
                        niskin_flag(ismember(position,[20 21 22 23 24])) = 3 ;
                    case 5 
                        niskin_flag(ismember(position,[1 2 4 5 7 8 10 15 16 21 22 24])) = 3 ;
                        niskin_flag(position==1) = 4 ;
                    case 6
                        niskin_flag(ismember(position,[2 5 8 16 17])) = 3 ;
                        niskin_flag(position==21) = 4 ;
                    case 8
                        niskin_flag(ismember(position,[2 5 8 10 11 14 16 24])) = 3 ;
                        % 5, 8, 10, 16 24 only leaking when top opened
                        niskin_flag(ismember(position,[17 18])) = 7 ; % bottle cop sheet says 'little dribble'
                        niskin_flag(position==21) = 4 ;
                    case 9 
                        niskin_flag(ismember(position,[2 8 16 18])) = 3 ;
                        niskin_flag(position==21) = 4 ;
                        niskin_flag(position==23) = 7 ; % cable stuck in tap
                    case 10
                        niskin_flag(position==2) = 7 ;
                    case 15
                        niskin_flag(ismember(position,[2 6])) = 9;
                        niskin_flag(ismember(position,[12 20])) = 7; %possible leaks
                    case 16
                        niskin_flag(ismember(position,[2 6 8 16])) = 9; %did not close
                    case 17
                        niskin_flag(ismember(position,[2])) = 9; %did not close (presumably this is what leaking at top means)
                        niskin_flag(ismember(position,[6 16])) = 3; 
                    case 18
                        niskin_flag(ismember(position,[6 8 18])) = 9;
                    case 19
                        niskin_flag(ismember(position,[8 18])) = 9;
                        niskin_flag(ismember(position,[10])) = 3;
                        niskin_flag(ismember(position,[24])) = 7; %fired on the fly?
                    case 20
                        niskin_flag(~ismember(position,[4 20 22 24])) = 9; % :(
                end
        end

    case 'msbe35_01'
        switch oopt
            case 'sbe35file'              
                sbe35file = sprintf('%s_*_sbe35.asc', upper(mcruise));
        end

            case 'moxy_01'
        switch oopt
            case 'oxy_files'
                ofiles = {'oxygen_calculation_newflasks_sd025.xlsx'};
                hcpat = {'Niskin';'Bottle'};
                chrows = 1:2;
                chunits = 3;
                sheets = 1:50;
            case 'oxy_parse'
                                oxyvarmap = {
                    'statnum',       'cast_number'
                    'position',      'niskin_bottle'
                    'vol_blank',     'blank_titre'
                    'vol_std',       'std_vol'
                    'vol_titre_std', 'standard_titre'
                    'fix_temp',      'fixing_temp'
                    'sample_titre',  'sample_titre'
                    'flag',          'flag'
                    'oxy_bottle'     'bottle_no'
                    'date_titre',    'dnum'
                    'bot_vol_tfix'   'botvol_at_tfix'
                    'conc_o2',       'c_o2_'}; %not including conc_o2, recalculating instead
                                fillstat = 1;
        end

    case 'best_station_depths'
        switch oopt
            case 'bestdeps'
                replacedeps = [];
        end

end