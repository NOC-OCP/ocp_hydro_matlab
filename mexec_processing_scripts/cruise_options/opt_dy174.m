switch opt1
    case 'botpsal'
        switch opt2
            case 'sal_files'
                salfiles = dir(fullfile(root_sal, ['autosal_' mcruise '_*.csv'])); salfiles = {salfiles.name};
            case 'sal_parse'
                cellT = 21;
                ssw_k15 = 0.99986;
                calcsal = 1;
                ssw_batch = 'P165';
            case 'sal_calc'
                sal_off = [
                    000 0
                    001 0
                    002 0
                    003 0
                    004 2
                    005 2
                    006 3
                    007 3
                    008 2
                    009 2
                    010 4
                    011 3
                    012 4
                    013 4
                    014 5
                    015 6
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
            case 'bestdeps'
                iscor = 1;
                xducer_offset = 0; %to be added
                replacedeps = [
                    1 3598    % em122
                    6 1419    % em122
                    ];
                replacealt = [
                    %                     0 90 % noted on ctd deck unit log; didn't approach closer than 90, so bad values occur close to bottom of cast
                    %                     1 51 % noted on ctd deck unit log; altimeter was noisy, so bad values less than 50 could be selected as 'good'
                    ];

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
                co.docal.temp = 1;
                co.docal.cond = 1;
                co.docal.oxygen = 1;
                co.calstr.temp.sn034383.dy174 = 'dcal.temp = d0.temp + interp1([-10 6000],1*[-15 -15]/1e4,d0.press);';
                co.calstr.temp.sn034383.msg = 'temp s/n 4383 adjusted by -1.5 mdeg to agree with SBE35; median of depths > 2500 dbar on stations 1 to 10';
                co.calstr.temp.sn035780.dy174 = 'dcal.temp = d0.temp + interp1([-10 6000],1*[15 15]/1e4,d0.press);';
                co.calstr.temp.sn035780.msg = 'temp s/n 5780 adjusted by +1.5 mdeg to agree with SBE35; median of depths > 2500 dbar on stations 1 to 10';
                co.calstr.cond.sn043874.dy174 = 'statshape = interp1([1 12],[0 -20],[1:12]); dcal.cond = d0.cond.*(1 + (interp1([1 2 3 4 5 6 7 8 9 10 11 12],( [0 0 0 0 0 0 0 0 0 0 0 0] + statshape)/1e4,d0.statnum) + interp1([-10 0 500 1000 1500 3000 4000],[-24 -24 -11 2 12 4 4]/1e4,d0.press))/35);';
                co.calstr.cond.sn043874.msg = 'cond s/n 3874 adjusted to agree with bottle salinity up to station 10';
                co.calstr.cond.sn044143.dy174 = 'statshape = interp1([1 12],[0 -20],[1:12]); dcal.cond = d0.cond.*(1 + (interp1([1 2 3 4 5 6 7 8 9 10 11 12],( [30 45 45 40 32 30 35 35 38 38 38 38] + statshape)/1e4,d0.statnum) + interp1([-10 0 500 1000 1500 3000 4000],[-30 -30 -10 3 13 1 1]/1e4,d0.press))/35);';
                co.calstr.cond.sn044143.msg = 'cond s/n 4143 adjusted to agree with bottle salinity up to station 10';
                co.calstr.oxygen.sn433847.dy174 = 'dcal.oxygen = d0.oxygen.*interp1([-10      0   800    2000   3500  4000 ],[1.055 1.055 1.035  1.042  1.052 1.052],d0.press).*interp1([0  3 4 100],[1.003 1.003  1.0 1.0],d0.statnum);';
                co.calstr.oxygen.sn433847.msg = 'upcast oxygen s/n 3847 adjusted to agree with 60 samples, after applying hysteresis correction; up/down difference after hysteresis correction is of order (1 umol/kg)';
                co.calstr.oxygen.sn432831.dy174 = 'dcal.oxygen = d0.oxygen.*interp1([-10      0   800    1500   3000  4000 ],[1.007 1.007 1.004  1.015  1.030 1.035],d0.press);';
                co.calstr.oxygen.sn432831.msg = 'upcast oxygen s/n 2831 adjusted to agree with 60 samples, after applying hysteresis correction; up/down difference after hysteresis correction is of order (1 umol/kg)';
        end


    case 'botoxy'
        switch opt2
            case 'oxy_files'
                ofiles = {'DY174_Oxygen_Calculation.xlsx'};
                %hcpat = {'Niskin';'Bottle'};
                %chrows = 1:2;
                %chunits = 3;
                hcpat = {'Bottle';'Number'}; %Flag is on 2nd line so start here
                chrows = 1;
                chunits = 2;
                calcoxy = 0;
            case 'oxy_parse'
                varmap.niskin = {'bottle'};
                varmap.statnum = {'number'};
                varmap.fix_temp = {'temp'};
                varmap.conc_o2 = {'umol_per_l'};
                %             case 'oxy_calc'
                %                 ds_oxy.vol_std = ds_oxy.vol;
                %                 ds_oxy.vol_blank = repmat(mean([-0.0015 -0.0015 0.000833333 0 -0.0015 -0.000666667]),size(ds_oxy.sampnum));
                %                 ds_oxy.vol_titre_std = repmat(mean([0.4580 0.4581 0.4599 0.4589 0.4588 0.4588]),size(ds_oxy.sampnum));
                %                 vol_reag_tot = 2;
            case 'oxy_flags'
                %d.botoxya_flag(d.sampnum==105) = 4;
                %d.botoxya_flag(d.sampnum==111) = 2; %initially bad because of incorrect bottle vol, now fixed
                %d.botoxya_flag(ismember(d.sampnum,[919 1001])) = 3; %sample b looks more consistent with average offset from CTD
                %d.botoxya_flag(d.sampnum==515) = 4;
%               %  d.botoxya_flag(d.sampnum==219) = 3; % questionable. OK on
%               %  further inspection, strong gradients and wake effects
%               %  d.botoxya_flag(d.sampnum==419) = 3;
                %d.botoxya_flag(ismember(d.sampnum,[407 807])) = 3; %replicates differ by >1umol/kg, not clear which is better
                %d.botoxyb_flag(ismember(d.sampnum,[407 807])) = 3; %replicates differ by >1umol/kg, not clear which is better
        end

    case 'sbe35'
        switch opt2
            case 'sbe35file'
                sbe35file = sprintf('%s_*.asc', upper(mcruise));
                stnind = [7:9]; % index in file name of where the station number can be found. File name eg = DY174_001.asc, so index is 7:9
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
            case 'ship_data_sys_names'
                tsgpre = 'sbe45';
                root_tsg = fullfile(mgetdir(tsgpre),'met','ocn'); %tsgpre not listed in mgetdir so defaults to data base directgory
                tsgfn = fullfile(root_tsg,['surf_combined_' mcruise]);
        end

    case 'uway_proc'
        switch opt2
            case 'excludestreams'
                uway_excludes = [uway_excludes;'autosal';'ranger2usbl2'];
            case 'tsg_avedits'
                check_tsg = 1;
            case 'tsg_cals'
                clear uo
                uo.docal.salinity = 1;
                uo.calstr.salinity.pl.dy174 = 'dcal.salinity = d0.salinity - 0.028;'; % single offset from 20 bottle samples over 5 days for the whole of the short cruise
            case 'bathy_grid'
                %load gridded bathymetry data into xbathy, ybathy, zbathy
                %to use as background for editing plot
        end

    %case 'check_sams'
    %    check_sal = 1; %plot individual salinity readings
    %    check_oxy = 1; %step through mismatched oxygen replicates
    %    check_sbe35 = 1; %display bad sbe35 lines (may error later if they are present and not flagged)

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
                n12 = 11; %***
                expocode = '74EQ20240328';
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
                        {sprintf('#%d stations with 24-place rosette with 12 bottles',n12);...
                        '#CTD: Who - B. King (NOC); Status - final.';...
                        %'#The CTD PRS; TMP; SAL; OXY data are all calibrated and good.';...
                        '# DEPTH_TYPE   : COR';...
                        '# DEPTH_TYPE   : rosette depth from CTDPRS + CTD altimeter range to bottom, or speed of sound-corrected ship-mounted bathymetric echosounder'...
                        }];
                else
                    headstring = {['BOTTLE,' datestr(now,'yyyymmdd') submitter]};
                    headstring = [headstring; common_headstr;
                        {sprintf('#%d stations with 24-place rosette with 12 bottles',n12);...
                        '#CTD: Who - B. King (NOC); Status - final';...
                        '#Notes: Includes CTDSAL, CTDOXY, CTDTMP';...
                        %'#The CTD PRS; TMP; SAL; OXY data are all calibrated and good.';...
                        '# DEPTH_TYPE   : rosette depth from CTDPRS + CTD altimeter range to bottom';...
                        '#Salinity: Who - B. King (NOC); Status - preliminary; SSW batch P165.';...
                        '#Oxygen: Who - S. Trace-Kleeberg (NOC); Status - final.';...
                        }];
                end
        end

end

