switch opt1
    case 'botpsal'
        switch opt2
            case 'sal_parse'
                cellT = 21;
                ssw_k15 = 0.99986;
                calcsal = 1;
            case 'sal_calc'
                sal_off = [
                    000 0
                    001 0
                    002 0
                    003 0
                    004 2
                    005 2
                    ];
                sal_off(:,1) = sal_off(:,1)+999e3;
                sal_off(:,2) = sal_off(:,2)*1e-5;
                sal_off_base = 'sampnum_list';
        end


    case 'castpars'
        switch opt2
            case 's_choice'
                s_choice = 2;
                stns_alternate_s = []; % none yet
            case 'o_choice'
                o_choice = 2; %use sensor 2
                stns_alternate_o = []; % none yet
        end
    case 'ctd_proc'
        switch opt2
            case 'raw_corrs'
                co.oxyhyst433847.H1 = -.043;
                co.oxyhyst433847.H2 = 5000;
                co.oxyhyst433847.H3 = [
                    -10 200
                    1000 200
                    1001 1000
                    2000 1000
                    2001 2000
                    9000 2000
                    ];
                co.oxyhyst432831.H1 = -.043;
                co.oxyhyst432831.H2 = 5000;
                co.oxyhyst432831.H3 = [
                    -10 500
                    1000 500
                    1001 3000
                    2000 3000
                    2001 3000
                    9000 3000
                    ];
            case 'ctd_cals'
                co.docal.temp = 0;
                co.docal.cond = 0;
                co.docal.oxygen = 0;
                co.calstr.temp.sn034383.dy174 = 'dcal.temp = d0.temp + interp1([-10 6000],1*[-18 -18]/1e4,d0.press);';
                co.calstr.temp.sn034383.msg = 'temp s/n 4383 adjusted by -1.8 mdeg to agree with SBE35 on stations 1 to 7';
                co.calstr.temp.sn035780.dy174 = 'dcal.temp = d0.temp + interp1([-10 6000],1*[12 12]/1e4,d0.press);';
                co.calstr.temp.sn035780.msg = 'temp s/n 5780 adjusted by +1.2 mdeg to agree with SBE35 on stations 1 to 7';
                shape = [0 0 0 0 0 0 0 0];
                co.calstr.cond.sn043874.dy174 = 'dcal.cond = d0.cond.*(1 + interp1([-10 0 500 1500 6000 7000 8000 9000],([-30 -30 -30 0 0 0 0 0]+shape)/1e4,d0.press)/35;';
                co.calstr.cond.sn043874.msg = 'cond s/n 3874 adjusted to agree with bottle salinity up to station 4';
                co.calstr.cond.sn044143.dy174 = 'dcal.cond = d0.cond.*(1 + interp1([-10 0 1500 2000 5000 6000 7000 8000],([0 0 40 50 40 40  40 40]+shape)/1e4,d0.press))/35);';
                co.calstr.cond.sn044143.msg = 'cond s/n 4143 adjusted to agree with bottle salinity up to station 4';
%                 co.calstr.oxygen.sn433847.dy174 = 'dcal.oxygen = d0.oxygen.*interp1([-10      0   600  1300   2000  3000  5000   6000],[1.000 1.000 1.012  1.016 1.027 1.042 1.050 1.050 ],d0.press);';
%                 co.calstr.oxygen.sn433847.msg = 'upcast oxygen s/n 3847 adjusted to agree with XX samples, after applying hysteresis correction; up/down difference after hysteresis correction is of order (1 umol/kg)';
%                 co.calstr.oxygen.sn432831.dy174 = 'dcal.oxygen = d0.oxygen.*interp1([-10     0   400  1000  1500 2000  5000  6000],[1.030 1.030 1.035 1.022 1.034 1.042 1.070 1.070],d0.press);';
%                 co.calstr.oxygen.sn432831.msg = 'upcast oxygen s/n 2831 adjusted to agree with XX samples, after applying hysteresis correction; up/down difference after hysteresis correction is of order (1 umol/kg)';
% pp =          [-10      0   800    2000   3500  4000  ];
% ff =    0.0+1*[1.055 1.055 1.035  1.042  1.052 1.052 ];
        end


    case 'botoxy'
        switch opt2
            case 'oxy_files'
                ofiles = {'DY174_Oxygen_Calculation.xlsx'};
                hcpat = {'Niskin';'Bottle'};
                chrows = 1:2;
                chunits = 3;
                sheets = 1:100;
                calcoxy = 0;
            case 'oxy_parse'

                ds_xls = ds_oxy;
                clear ds_oxy

                ds_oxy.sampnum = ds_xls.niskin_bottle + ds_xls.cast_number*100;
                ds_oxy.fix_temp = ds_xls.fixing_temp;
                ds_oxy.conc_o2 = ds_xls.c_o2_umol_per_l;
                ds_oxy.flag = 2+0*ds_oxy.sampnum;
                kbad = find(isnan(ds_oxy.sampnum));
%                 kbad = [kbad(:)' [1:15]];
                kbad = unique(kbad);
                ds_oxy.sampnum(kbad) = [];
                ds_oxy.fix_temp(kbad) = [];
                ds_oxy.flag(kbad) =[];
                ds_oxy.conc_o2(kbad) = [];
%             case 'oxy_calc'
%                 ds_oxy.vol_std = repmat(5,size(ds_oxy.sampnum));
%                 ds_oxy.vol_blank = repmat(-0.00808333,size(ds_oxy.sampnum));
%                 ds_oxy.vol_titre_std = repmat(0.4540,size(ds_oxy.sampnum));
%                 ds_oxy.vol_blank(ds_oxy.statnum>=28 | ds_oxy.statnum==26) = -0.00854167;
%                 ds_oxy.vol_titre_std(ds_oxy.statnum>=28 | ds_oxy.statnum==26) = 0.4241;
%                 ds_oxy.vol_blank(ds_oxy.statnum>=177) = -0.00691667;
%                 ds_oxy.vol_titre_std(ds_oxy.statnum>=177) = 0.4264;
%                 vol_reag_tot = 0.997*2;
%             case 'oxy_flags'
%                 %dispensers fixed around 9
%                 ii = find(d.statnum<9);
%                 d.botoxya_flag(ii) = max(d.botoxya_flag(ii),4);
%                 d.botoxyb_flag(ii) = max(d.botoxyb_flag(ii),4);
%                 %tubing size fixed around 14 or 15 (14 and 15 profiles look
%                 %okay)
%                 ii = find(d.statnum<14);
%                 d.botoxya_flag(ii) = max(d.botoxya_flag(ii),3);
%                 d.botoxyb_flag(ii) = max(d.botoxyb_flag(ii),3);
%                 %tm-clean samples taken with too-stiff tube
%                 ii = find(ismember(d.statnum,[32 40 47 54 61]));
%                 d.botoxya_flag(ii) = max(d.botoxya_flag(ii),4);
%                 d.botoxyb_flag(ii) = max(d.botoxyb_flag(ii),4);
%                 %duplicates where based on comparison with ctd profile we
%                 %think one is bad or questionable
%                 d.botoxya_flag(ismember(d.sampnum,[1504 6811])) = 4;
%                 d.botoxya_flag(ismember(d.sampnum,[1624 2913])) = 3;
%                 d.botoxya_per_l(d.botoxya_flag==4) = NaN;
%                 d.botoxyb_flag(ismember(d.sampnum,[1512 17915])) = 3;
%                 d.botoxyb_per_l(d.botoxyb_flag==4) = NaN;
%                 %duplicates that differ but not clear which is better
%                 ii = find(abs(d.botoxya_per_l-d.botoxyb_per_l)>=1 & d.botoxya_flag==2 & d.botoxyb_flag==2);
%                 d.botoxya_flag(ii) = 3; d.botoxyb_flag(ii) = 3;
%                 %marked as bad but looks okay
%                 d.botoxya_flag(d.sampnum==2320) = 2;
%                 %outliers
%                 d.botoxya_flag(ismember(d.sampnum,[2122])) = 3;
        end

    case 'sbe35'
        switch opt2
            case 'sbe35file'
                sbe35file = sprintf('%s_*.asc', upper(mcruise));
                stnind = [7:9];
        end


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
                default_navstream = 'posmv_gpgga';
                default_hedstream = 'posmv_pashr';
                default_attstream = 'posmv_pashr';
            case 'rvdas_database'
                RVDAS.machine = '192.168.65.51';
                RVDAS.jsondir = '/data/pstar/mounts/mnt_cruise_data/Ship_Systems/Data/RVDAS/Sensorfiles/'; %original
                RVDAS.user = 'sciguest';
                RVDAS.database = ['"' upper(MEXEC_G.MSCRIPT_CRUISE_STRING) '"'];
        end
    
    case 'uway_proc'
        switch opt2
            case 'excludestreams'
                uway_excludes = [uway_excludes;'autosal';'ranger2usbl2'];
            case 'tsg_avedits'
                check_tsg = 1;
            case 'bathy_grid'
                %load bathymetry data into xbathy, ybathy, zbathy
        end

    case 'mfir_01'
        switch opt2
            case 'niskins'
                % 10L bottles on frame
                % numbers 1:2:23
                % serial nos
                niskin_barcodes = [ % 250003034 etc
                     1 3034 % position 1 has niskin barcode 250003034
                     3 3036
                     5 3038
                     7 3040
                     9 3042
                    11 3044
                    13 3046
                    15 3048
                    17 3050
                    19 3052
                    21 3054
                    23 3056
                    ];
                % on stations >= 5, some or all even positions were fired in order to collect extra
                % primary/secondary sensor pair measurements and SBE35 data
                % use bottle number = 0 and bottle flag = 9 for those
                % events
                niskin_barcodes_empty = [
                     2 -9
                     4 -9
                     6 -9
                     8 -9
                    10 -9
                    12 -9
                    14 -9
                    16 -9
                    18 -9
                    20 -9
                    22 -9
                    24 -9
                    ];
                niskin_barcodes = [niskin_barcodes ; niskin_barcodes_empty];
                niskin_barcodes = sortrows(niskin_barcodes,1);

                niskin_pos = niskin_barcodes(:,1);
                niskin_number = niskin_barcodes(:,2);
            case 'botflags'
                k_empty = find(niskin_number == -9); % positions with no bottle
                [~,kposempty,~] = intersect(position,k_empty); % index of empty places in set of positions that have appeared in .bl file
                niskin_flag(kposempty) = 9;
                switch stnlocal
                    case 1
                        niskin_flag(position==23) = 4; %not closed correctly
                    case 2
                        niskin_flag(position==23) = 4; %not closed correctly
                    case 4
                        niskin_flag(position==1) = 4; %not closed correctly
                        niskin_flag(position==11) = 4; %not closed correctly
                    otherwise
                end

        end

            case 'outputs'
        switch opt2
            case 'summary'
                snames = {'nsal' 'noxy' 'nnut' 'nco2'};
                sgrps = {{'botpsal'} {'botoxy'} {'silc' 'phos' 'nitr'} {'dic' 'talk'}};
            case 'exch'
                n12 = 13; %***
                expocode = '740H20240328';
                sect_id = 'RAPID-East';
                submitter = 'OCPNOCBAK'; %group institution person
                common_headstr = {'#SHIP: RRS Discovery';...
                    '#Cruise DY174; RAPID moorings';...
                    '#Region: Eastern North Atlantic (subtropical)';...
                    ['#EXPOCODE: ' expocode];...
                    '#DATES: 20240328 - 20240403';...
                    '#Chief Scientist: B. Moat (NOC)';...
                    '#Supported by grants from the UK Natural Environment Research Council.'};
                if strcmp(in.type,'ctd')
                    headstring = {['CTD,' datestr(now,'yyyymmdd') submitter]};
                    headstring = [headstring; common_headstr;
                        {sprintf('#%d stations with 12-place rosette',n12);...
                        '#CTD: Who - B. King (NOC); Status - preliminary.';...
                        %'#The CTD PRS; TMP; SAL; OXY data are all calibrated and good.';...
                        '# DEPTH_TYPE   : COR';...
                        '# DEPTH_TYPE   : rosette depth from CTDPRS + CTD altimeter range to bottom, or speed of sound-corrected ship-mounted bathymetric echosounder'...
                        }];
                else
                    headstring = {['BOTTLE,' datestr(now,'yyyymmdd') submitter]};
                    headstring = [headstring; common_headstr;
                        {sprintf('#%d stations with 12-place rosette',n12);...
                        '#CTD: Who - B. King (NOC); Status - preliminary';...
                        '#Notes: Includes CTDSAL, CTDOXY, CTDTMP';...
                        %'#The CTD PRS; TMP; SAL; OXY data are all calibrated and good.';...
                        '# DEPTH_TYPE   : rosette depth from CTDPRS + CTD altimeter range to bottom';...
                        '#Salinity: Who - B. King (NOC); Status - preliminary; SSW batch P***.';...
                        '#Oxygen: Who - S. Trace-Kleeberg (NOC); Status - preliminary.';...
                        }];
                end
        end

end

