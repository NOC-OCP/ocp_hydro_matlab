switch opt1

    %%%%%%%%%%%%%%%%%%%%%% setup and config %%%%%%%%%%%%%%%%%%%%%%%%
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
                RVDAS.jsondir = ''; %no "original" on shared drive, copy is already in cruise/data/rvdas/json_files
                RVDAS.loginfile = '/data/pstar/plocal/rvdas_addr'; %contains credentials, address, and database, e.g. postgresql://user:passwd@ip.ad.re.ss/DY186
            case 'rvdas_skip'
                %skips.sentence = [skips.sentence, 'surfmet_gpxsm', 'ranger2usbl_psonlld'];
        end


        %%%%%%%%%%%%%%%%%%%%%%%% basic processing %%%%%%%%%%%%%%%%%%%%%%
    case 'uway_proc' 
        switch opt2
            case 'sensor_unit_conversions'
                %manufacturer/factory cals
                switch abbrev
                    case 'surfmet'
                        so.docal.fluo = 1;
                        so.docal.trans = 1;
                        so.docal.parport = 1;
                        so.docal.parstarboard = 1;
                        so.docal.tirport = 1;
                        so.docal.tirstarboard = 1;
                        %specify with so.calstr.{variablename}.pl.{cruise}
                        so.calstr.fluo.pl.dy186 = 'dcal.fluo = 10.3*(d0.fluo-0.078);'; %or sf is nonlinear?***
                        so.instsn.fluo = 'WS3S134';
                        so.calunits.fluo = 'ug_per_l';
                        so.calstr.trans.pl.dy186 = 'dcal.trans = (d0.trans-0.004)/(4.701-0.004)*100;';
                        so.instsn.trans = 'CST-114PR';
                        so.calunits.trans = 'percent';
                        so.calstr.parport.pl.dy186 = 'dcal.parport = d0.parport*(1e6/10.26);';
                        so.instsn.parport = 'SKE-510 48927';
                        so.calunits.parport = 'W_per_m2';
                        so.calstr.parstarboard.pl.dy186 = 'dcal.parstarboard = d0.parstarboard*(1e6/10.54);';
                        so.instsn.parstarboard = 'SKE-510 28556';
                        so.calunits.parstarboard = 'W_per_m2';
                        so.calstr.tirport.pl.dy186 = 'dcal.tirport = d0.tirport*(1e6/9.69);';
                        so.instsn.tirport = 'CMP-994133';
                        so.calunits.tirport = 'W_per_m2';
                        so.calstr.tirstarboard.pl.dy186 = 'dcal.tirstarboard = d0.tirstarboard*(1e6/11.31);';
                        so.instsn.tirstarboard = '994132';
                        so.calunits.tirstarboard = 'W_per_m2';
                end
            case 'rawedit'
                if ismember(abbrev,{'sbe45','surfmet'})
                    %cut off start (and eventually end) when TSG bad
                    %because underway seawater supply pumps off
                    badtimes = [-inf (datenum(2024,12,11,17,20,0)-datenum(2024,1,1))*86400];
                    if strcmp(abbrev,'sbe45')
                        tsgpumpvars = {'temph','tempr','conductivity','salinity','soundvelocity'};
                    else
                        tsgpumpvars = {'fluo','trans'};
                    end
                elseif strcmp(abbrev,'ea640')
                %     d = rmfield(d,'waterdepthfromsurface');
                %     h.fldunt(strcmp('waterdepthfromsurface',h.fldnam)) = [];
                %     h.fldnam(strcmp('waterdepthfromsurface',h.fldnam)) = [];
                end
                if sum(strcmp(streamtype,{'sbm','mbm'}))
                %     handedit = 1; %edit raw bathy
                %     vars_to_ed = munderway_varname('depvar',h.fldnam,1,'s');
                %     vars_to_ed = union(vars_to_ed,munderway_varname('depsrefvar',h.fldnam,1,'s'));
                %     vars_to_ed = union(vars_to_ed,munderway_varname('deptrefvar',h.fldnam,1,'s'));
                end
            case 'tsg_avedits' 
                check_tsg = 1;
            case 'tsg_cals'
                clear uo
                uo.docal.salinity = 0;
                %uo.calstr.salinity.pl.dy186 = '';
                %uo.calstr.salinity.pl.msg = '';
            case 'avedit'
                if strcmp(datatype,'ocean')
                     flowlims = [1 2.5]; %nominal range of good enough flow on this ship; tsgpumpvars will be naned when flow outside this range
                     tsgpumpvars = {'temph','tempr','conductivity','salinity','fluo','trans','soundvelocity'};
                     %variables to edit by hand (GUI): 
                %     %vars_to_ed = {'flow'};
                %     %vars_to_ed = {'temph','conductivity'};
                %     vars_to_ed = {'salinity'};
                %     vars_to_ed = {'tempr','temph'};
                elseif strcmp(datatype,'bathy')
                %     vars_to_ed = {'waterdepth_mbm','waterdepth_sbm'};
                end
        end


    case 'ctd_proc'
        switch opt2
            case 'redoctm'
                redoctm = 1;
            case 'cnvfilename'
                cnvfile = fullfile(cdir,sprintf('%s_CTD%s.cnv', upper(mcruise), stn_string));
            case 'raw_corrs' % -----> if change the hystherisis coef
            case 'rawedit_auto' % -----> only if repeated spikes or out of range
            case 'ctd_cals' % -----> to apply calibration
                % co.docal.temp = 0;
                % co.docal.cond = 0;
                % co.docal.oxygen = 0;
                % co.calstr.temp.sn034383.dy174 = 'dcal.temp = d0.temp + interp1([-10 6000],1*[-15 -15]/1e4,d0.press);';
                % co.calstr.temp.sn034383.msg = 'temp s/n 4383 adjusted by -1.5 mdeg to agree with SBE35; median of depths > 2500 dbar on stations 1 to 10';
                % co.calstr.temp.sn035780.dy174 = 'dcal.temp = d0.temp + interp1([-10 6000],1*[15 15]/1e4,d0.press);';
                % co.calstr.cond.sn043874.dy174 = 'dcal.cond = d0.cond.*(1+ (interp1([1 12],[0 -2e-3],d0.statnum) + interp1([-10 1500 4000],[-2e-3 1e-3 0],d0.press))/35);';
                % %dcal.cond = d0.cond.*(1 + (interp1([1 12],[0 -20]/1e4,d0.statnum) + interp1([-10 0 500 1000 1500 3000 4000],[-24 -24 -11 2 12 4 4]/1e4,d0.press))/35);';
                % co.calstr.cond.sn043874.msg = 'cond s/n 3874 adjusted to agree with bottle salinity up to station 12';
                % co.calstr.cond.sn044143.dy174 = 'dcal.cond = d0.cond.*(1+ (interp1([-10 2000 4000],[1e-3 4e-3 3e-3],d0.press) + interp1([1 12],[1e-3 -1e-3],d0.statnum))/35);';
                % %statshape = interp1([1 12],[0 -20],[1:12]); dcal.cond = d0.cond.*(1 + (interp1(1:12,( [30 45 45 40 32 30 35 35 38 38 38 38] + statshape)/1e4,d0.statnum) + interp1([-10 0 500 1000 1500 3000 4000],[-30 -30 -10 3 13 1 1]/1e4,d0.press))/35);';
                % co.calstr.cond.sn044143.msg = 'cond s/n 4143 adjusted to agree with bottle salinity up to station 12';
                % co.calstr.oxygen.sn433847.dy174 = 'dcal.oxygen = d0.oxygen.*interp1([-10      0   800    2000   3500  4000 ],[1.055 1.055 1.035  1.042  1.052 1.052],d0.press).*interp1([0  3 4 100],[1.003 1.003  1.0 1.0],d0.statnum);';
                % co.calstr.oxygen.sn433847.msg = 'upcast oxygen s/n 3847 adjusted to agree with 60 samples, after applying hysteresis correction; up/down difference after hysteresis correction is of order (1 umol/kg)';
                % co.calstr.oxygen.sn432831.dy174 = 'dcal.oxygen = d0.oxygen.*interp1([-10      0   800    1500   3000  4000 ],[1.007 1.007 1.004  1.015  1.030 1.035],d0.press);';
                % co.calstr.oxygen.sn432831.msg = 'upcast oxygen s/n 2831 adjusted to agree with 60 samples, after applying hysteresis correction; up/down difference after hysteresis correction is of order (1 umol/kg)';
            case 'sensor_choice' % -----> if we choose to use sensor 2 instead of sensor 1 for some or all of the stations
            case 'bestdeps' % ------> if not full depth (can add later)
        end

         
    case 'nisk_proc'
        switch opt2
            case 'niskins'
                niskin_barcodes = [ 
                     1 3057 % position 1 has niskin barcode 250003057 because it is niskin 24 
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
                niskin_pos = niskin_barcodes(:,1);
                niskin_number = niskin_barcodes(:,2);
            case 'blfilename'
                blinfile = fullfile(root_botraw,sprintf('%s_CTD%s.bl', upper(mcruise), stn_string));
            case 'botflags'
                % k_empty = find(niskin_number == -9); % positions with no bottle
                % [~,kposempty,~] = intersect(position,k_empty); % index of empty places in set of positions that have appeared in .bl file
                % niskin_flag(kposempty) = 9;
                % switch stnlocal
                %     case 1
                %         niskin_flag(position==23) = 4; %not closed correctly
                %     case 4
                %         niskin_flag(position==1) = 4; %not closed correctly
                %         niskin_flag(position==11) = 4; %not closed correctly
                %     otherwise
                % end
        end


        %%%%%%%%%%%%%%%%% bottle samples %%%%%%%%%%%%%%%%%%%%%%%
    case 'botpsal'
        switch opt2
            case 'sal_files'
                %salfiles = dir(fullfile(root_sal, ['autosal_' mcruise '_*.csv'])); 
            case 'sal_parse'
                cellT = 21; % Temperature of the bath
                % ssw_k15 = 0.99993;
                calcsal = 1;
                % ssw_batch = 'P168';
            case 'sal_calc'
                % salin_off = [000 -.5; 001 -1.5; 003 -2; ... %10th am
                %     004 0; 005 1.5; 007 7; ... %11th pm
                %     009 -3; 010 -1; 012 -2.5; ... %12th am
                %     ];
                % salin_off(:,1) = salin_off(:,1)+999e3;
                % salin_off(:,2) = salin_off(:,2)*1e-5;
                % salin_off_base = 'sampnum_list'; 
            case 'sal_flags'
                % %too low (33-ish), maybe samples contaminated
                % m = ismember(ds_sal.sampnum,[4807 4809 5713 5715 5801 5803 5805]);
                % ds_sal.flag(m) = 4;
                % m = ismember(ds_sal.sampnum,[6715 8810]); ds_sal.flag(m) = 3;
                % %Missing salinometer analysis due to blockage
                % none = ismember(ds_sal.sampnum, [9104 9105]);
                % ds_sal.flag(none) = 5;
        end


    case 'botoxy'
        switch opt2
            case 'oxy_files'
                %ofiles = dir(fullfile(root_oxy,'DY186_Oxygen_Calculation.xlsx'));
                hcpat = {'Bottle';'Number'}; %Flag is on 2nd line so start here
                chrows = 1;
                chunits = 2;
            case 'oxy_parse'
                calcoxy = 1;
                varmap.position = {'bottle'};
                varmap.statnum = {'number'};
                varmap.fix_temp = {'temp'};
                varmap.conc_o2 = {'umol_per_l'};
                %will need to replace 24 with 1 probably based on oxygen
                %sampling log (it is using bottle label rather than bottle
                %position)
            case 'oxy_calc'
                % vol_reag_tot = 2.0397;
            case 'oxy_flags'
                %sampnum, a flag, b flag, c flag
                % flr = [103 3 3 3; ... 
                %        113 4 2 2; ... %a is the outlier
                %        509 4 2 9; ... %duplicates only, a much higher than neighbours
                %       4123 4 2 2; ... %a much lower than all
                %       6621 4 2 2; ... %a is the outlier
                %       7207 2 4 9; ...
                %       7623 2 4 9; ...
                %       ];
                % [~,ifl,id] = intersect(flr(:,1),d.sampnum);
                % d.botoxya_flag(id) = max(d.botoxya_flag(id),flr(ifl,2));
                % d.botoxyb_flag(id) = max(d.botoxyb_flag(id),flr(ifl,3));
                % d.botoxyc_flag(id) = max(d.botoxyc_flag(id),flr(ifl,4));
                % % outliers relative to profile/CTD (not replicates)
                % flag3 = [3617 3811 3817 4217 4219 ...
                %     8801 9405]';
                % flag4 = [3501 3507 3509 3515 3603 3607 3715 ...
                %     9223 9319 9706]';
                % %8802, 8804, 8810, 8812, 8816, 8822
                % d.botoxya_flag(ismember(d.sampnum,flag4)) = 4;
                % d.botoxya_flag(ismember(d.sampnum,flag3)) = 3;
                % m = d.sampnum==8315;
                % d.botoxya_flag(m) = 3; d.botoxyb_flag(m) = 3;
        end


    case 'sbe35'
        switch opt2
            case 'sbe35file'
                %sbe35file = sprintf('%s_*.asc', upper(mcruise));
                %stnind = [7:9]; % index in file name of where the station number can be found. File name eg = DY174_001.asc, so index is 7:9
        end


    case 'check_sams'
        check_oxy = 1; %step through mismatched oxygen replicates
        check_sal = 1; %step through each station's conductivity ratio readings
        check_sbe35 = 1; %probably not neeeded


        %%%%%%%%%%%%%%%%%%%%%% outputs and summaries %%%%%%%%%%%%%%%%%%%%%%
    case 'outputs'
        switch opt2
            case 'summary'
                snames = {'nsal' 'noxy'};
                sgrps = {{'botpsal'} {'botoxy'}};
            case 'exch'
                n12 = 12; 
                expocode = '74EQ20241211';
                sect_id = 'RAPID-West';
                submitter = 'OCPNOCTP'; %group institution person
                common_headstr = {'#SHIP: RRS Discovery';...
                    '#Cruise DY186; RAPID moorings';...
                    '#Region: Western North Atlantic (subtropical)';...
                    ['#EXPOCODE: ' expocode];...
                    '#DATES: 20241211 - 20241219';...
                    '#Chief Scientist: B. Moat (NOC) and T. Petit (NOC)';...
                    '#Supported by RAPID-Evolution (grant NE/Y003551/1) from the UK Natural Environment Research Council.'};
                if strcmp(in.type,'ctd')
                    headstring = {['CTD,' datestr(now,'yyyymmdd') submitter]};
                    headstring = [headstring; common_headstr;
                        {sprintf('#%d stations with 24-place rosette with 12 bottles',n12);...
                        '#CTD: Who - T. Petit (NOC); Status - preliminary.';...
                        %'#The CTD PRS; TMP; SAL; OXY data are all calibrated and good.';...
                        '# DEPTH_TYPE   : COR';...
                        '# DEPTH_TYPE   : rosette depth from CTDPRS + CTD altimeter range to bottom, or speed of sound-corrected ship-mounted bathymetric echosounder'...
                        }];
                else
                    headstring = {['BOTTLE,' datestr(now,'yyyymmdd') submitter]};
                    headstring = [headstring; common_headstr;
                        {sprintf('#%d stations with 24-place rosette with 12 bottles',n12);...
                        '#CTD: Who - T. Petit (NOC); Status - preliminary';...
                        '#Notes: Includes CTDSAL, CTDOXY, CTDTMP';...
                        %'#The CTD PRS; TMP; SAL; OXY data are all calibrated and good.';...
                        '# DEPTH_TYPE   : rosette depth from CTDPRS + CTD altimeter range to bottom';...
                        '#Salinity: Who - T. Petit (NOC); Status - preliminary; SSW batch P***.';...
                        '#Oxygen: Who - ; Status - preliminary.';...
                        }];
                end
        end

end

