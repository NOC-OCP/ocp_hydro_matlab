%shortcasts = 2; %no altimeter bottom depth/no LADCP BT

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
                RVDAS.jsondir = '/data/pstar/mounts/links/mnt_cruise_data/Ship_Systems/Data/RVDAS/sensorfiles/'; %original
                RVDAS.database = ['"' upper(MEXEC_G.MSCRIPT_CRUISE_STRING) '"'];
                RVDAS.loginfile = '/data/pstar/plocal/rvdas_addr';
            case 'rvdas_streams'
                tablesource = 'mrtables_edited';
        end

    case 'uway_proc'
        switch opt2
            case 'excludestreams'
            case 'bathy_grid'
                %for background, load gridded bathymetry into xbathy, ybathy, zbathy
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
                if stn==10
                    cnvfile = fullfile(cdir,sprintf('%s_CTD%04d.cnv',upper(mcruise),stn)); %try stainless first
                end
            case 'blfilename'
                blinfile = fullfile(root_botraw,sprintf('%s_CTD%03d.bl', upper(mcruise), stn));
                if stn==10
                    blinfile = fullfile(root_botraw,sprintf('%s_CTD%04d.bl', upper(mcruise), stn));
                end
            case 'rawedit_auto'
        end

    case 'mfir_01'
        switch opt2
            case 'botflags'
                if stn==6
                    niskin_flag(ismember(position,[11 21])) = 9;
                elseif stn==36
                    niskin_flag(position==11) = 3; %***leaked
                elseif stn==51
                    niskin_flag(position==11) = 3; %maybe leaking (on recovery, not obviously after), still sampled
                end
        end

    case 'ladcp_proc'
        cfg.rawdir = fullfile(mgetdir('ladcp'),'rawdata');
        yos = [10 33];
        if stn>=yos(1) && stn<=yos(2)
            cfg.uppat = sprintf('%s_CTD%03d-%03dS*.000',upper(mcruise),yos(1),yos(2));
            cfg.dnpat = sprintf('%s_CTD%03d-%03dM*.000',upper(mcruise),yos(1),yos(2));
        else
            cfg.uppat = sprintf('%s_CTD%03dS*.000',upper(mcruise),stn);
            cfg.dnpat = sprintf('%s_CTD%03dM*.000',upper(mcruise),stn);
            if stn==45
                cfg.dnpat = 'DY181_CTD45M.000';
            end
        end
        cfg.p.vlim = 4; %rather than ambiguity vel, match this to LV
        %code for yo-yo cast
        if stn>=yos(1) && stn<=yos(2)
            [dd,hd] = mloadq(fullfile(mgetdir('ctd'),sprintf('dcs_%s_%03d',mcruise,stnlocal)),'time_start time_end ');
            dd.dnum_start = m_commontime(dd,'time_start',hd,'datenum');
            dd.dnum_end = m_commontime(dd,'time_end',hd,'datenum');
            cfg.p.time_start_force = round(datevec(dd.dnum_start-2/60/24));
            cfg.p.time_end_force = round(datevec(dd.dnum_end+2/60/24));
        end

    case 'check_sams'
        %make this display-dependent? (or session-dependent?)
        check_sal = 0;
        check_oxy = 1;
        check_sbe35 = 1;

    case 'botpsal'
        switch opt2
            case 'sal_files'                
                salfiles = dir(fullfile(root_sal, ['autosal_' mcruise '_*.csv'])); 
                salfiles = {salfiles.name};
            case 'sal_parse'
                cellT = 21;
                ssw_k15 = 0.99993;
                calcsal = 1;
                ssw_batch = 'P168';
            case 'sal_calc'
                sal_off = [
                    000 -.5
                    001 -1
                    002 -1
                    003 -2
                    004 0
                    005 1.5
                    006 2
                    007 7 %***check T
                    009 -3 % No standard labelled 008
                    010 -1.5
                    011 -1.5
                    012 -2.5
                    013 -6
                    014 -2
                    015 -5
                    016 2
                    017 2
                    018 1
                    019 1
                    020 -2
                    ];
                sal_off(:,1) = sal_off(:,1)+999e3;
                sal_off(:,2) = sal_off(:,2)*1e-5;
                sal_off_base = 'sampnum_list'; 
        end

    case 'botoxy'
        switch opt2
            case 'oxy_files'
                ofiles = {fullfile(root_oxy,'Winkler Calculation Spreadsheet.xlsx')};
                iih = 8;
                hcpat = {'Latitude'};
                chrows = 1; chunits = [];
                            case 'oxy_parse'
                calcoxy = 0;
                varmap.statnum = {'ctd_cast_no'};
                varmap.position = {'niskin_bot_no'};
                varmap.fix_temp = {'fixing_temp_c'};
                varmap.conc_o2 = {'c_o2_umol_per_l'};
            case 'oxy_flags'
                %botoxya 103, 113, 509
                %botoxyb 509, 4021?
                %botoxyc 4013, 
                %both/all 3: 513, 4017


        end

    case 'outputs'
        switch opt2
            case 'summary'
                snames = {'nsal' 'noxy' 'nnut' 'nco2'};
                sgrps = {{'botpsal'} {'botoxy'} {'silc' 'phos' 'nitr'} {'dic' 'talk'}};
            case 'exch'
                ns = 9;
                expocode = '74EQ20240703';
                sect_id = 'OSNAP-EEL';
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

    case 'batchactions'
        switch opt2
            case 'output_for_others'
                pdir = '/data/pstar/mounts/public/DY181/Science/CTD_bottle_data';
                clear s
                syncs = {sprintf('%s/collected_files/station_summary* %s/',MEXEC_G.mexec_data_root,pdir);...
                    sprintf('%s/collected_files/74EQ* %s/',MEXEC_G.mexec_data_root,pdir);...
                    sprintf('%s/ctd/ctd*2db.nc %s/ctd_2db/',MEXEC_G.mexec_data_root,pdir)};
                for no = 1:length(syncs)
                    try
                        [s(no),~] = system(['rsync -rlu ' syncs{no}]);
                    catch
                        [s(no),~] = system(['cp -R ' syncs{no}]);
                    end
                end
                if sum(s)>0; warning('some or all syncing failed'); end
        end

end

