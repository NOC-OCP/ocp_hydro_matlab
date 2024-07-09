switch opt1

    case 'setup'
        switch opt2
            case 'time_origin'
                MEXEC_G.MDEFAULT_DATA_TIME_ORIGIN = [2024 1 1 0 0 0];
            case 'setup_datatypes'
                use_ix_ladcp = 'query';

        end

    case 'ship'
        switch opt2
            case 'datasys_best'
                default_navstream = 'posmv_gpgga';
                default_hedstream = 'posmv_pashr';
                default_attstream = 'posmv_pashr';
            case 'rvdas_database'
                %RVDAS.jsondir = '/data/pstar/mounts/mnt_cruise_data/Ship_Systems/Data/RVDAS/Sensorfiles/'; %original
                RVDAS.database = ['"' upper(MEXEC_G.MSCRIPT_CRUISE_STRING) '"'];
                RVDAS.loginfile = '/data/pstar/plocal/rvdas_addr';
        end

    case 'uway_proc'
        switch opt2
            case 'excludestreams'
        end

    case 'castpars'
        switch opt2
            case 'oxy_align'
                oxy_end = 1; %truncate oxygen oxy_align s before T,C
            case 's_choice'
                s_choice = 1; %fin sensor
            case 'o_choice'
                o_choice = 1; %fin sensor

        end

    case 'ctd_proc'
        switch opt2
            case 'redoctm'
                redoctm = 1;
            case 'cnvfilename'
                cnvfile = fullfile(cdir,sprintf('%s_CTD%03d.cnv',upper(mcruise),stn)); %try stainless first
            case 'blfilename'
                blinfile = fullfile(root_botraw,sprintf('%s_CTD%03d.bl', upper(mcruise), stn));
            case 'rawedit_auto'
        end

    case 'mfir_01'
        switch opt2
            case 'botflags'
                if stn==6
                    niskin_flag(ismember(position,[11 21])) = 9;
                end
        end

    case 'ladcp_proc'
        cfg.rawdir = fullfile(mgetdir('ladcp'),'rawdata');
        cfg.uppat = sprintf('%s_CTD%03dS*.000',mcruise,stnlocal);
        cfg.dnpat = sprintf('%s_CTD%03dM*.000',mcruise,stnlocal);

    case 'check_sams'
        %make this display-dependent? (or session-dependent?)
        check_sal = 0;
        check_oxy = 0;
        check_sbe35 = 0;

                    case 'outputs'
        switch opt2
            case 'summary'
                snames = {'nsal' 'noxy' 'nnut' 'nco2'};
                sgrps = {{'botpsal'} {'botoxy'} {'silc' 'phos' 'nitr'} {'dic' 'talk'}};
            case 'exch'
                ns = 9; 
                expocode = '74EQ20240703';
                sect_id = 'OSNAP/EEL';
                submitter = 'OCPNOCYLF'; %group institution person
                common_headstr = {'#SHIP: RRS Discovery';...
                    '#Cruise DY181; UK-OSNAP/Extended Ellet Line 2024';...
                    '#Region: subpolar north Atlantic';...
                    ['#EXPOCODE: ' expocode];...
                    '#DATES: 20240703 - 20240728';...
                    '#Chief Scientist: K. Burmeister (SAMS) and T. Dotto (NOC)';...
                    '#Supported by grants from the UK Natural Environment Research Council.'}; %***
                if strcmp(in.type,'ctd')
                    headstring = {['CTD,' datestr(now,'yyyymmdd') submitter]};
                    headstring = [headstring; common_headstr;
                        {sprintf('#%d stations with 24-place rosette',ns);...
                        '#CTD: Who - Y. Firing (NOC); Status - preliminary.';...
                        %'#The CTD PRS; TMP; SAL; OXY data are all calibrated and good.';...
                        '# DEPTH_TYPE   : COR';...
                        '# DEPTH_TYPE   : rosette depth from CTDPRS + CTD altimeter range to bottom, or speed of sound-corrected ship-mounted bathymetric echosounder'...
                        }];
                else
                    headstring = {['BOTTLE,' datestr(now,'yyyymmdd') submitter]};
                    headstring = [headstring; common_headstr;
                        {sprintf('#%d stations with 24-place rosette',ns);...
                        '#CTD: Who - Y. Firing (NOC); Status - preliminary';...
                        '#Notes: Includes CTDSAL, CTDOXY, CTDTMP';...
                        %'#The CTD PRS; TMP; SAL; OXY data are all calibrated and good.';...
                        '# DEPTH_TYPE   : rosette depth from CTDPRS + CTD altimeter range to bottom';...
                        '#Salinity: Who - Y. Firing (NOC); Status - preliminary; SSW batch P165***.';...
                        '#Oxygen: Who - R. Abell (SAMS); Status - preliminary.';...
                        '#Nutrients: Who - R. Abell (SAMS); Status - preliminary.';...
                        '#DIC and Talk: Who - C. Johnson (SAMS); Status - preliminary.';...
                        '#***';...
                        }];
                end
        end

end

