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
                     handedit = 1; %edit raw bathy
                     vars_to_ed = h.fldnam(cellfun(@(x) contains(x,'dep'), h.fldnam));
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
                     vars_to_ed = {'tempdk', 'temph', 'conductivity', 'tempr', 'flow', 'fluo', 'trans'};
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
                %if stn==2
                %    %reconverted from .hex using correct
                %    %XMLCON/coefficients
                %    cnvfile = fullfile(cdir,'DY186_CTD002b.cnv');
                %else
                   cnvfile = fullfile(cdir,sprintf('%s_CTD%s.cnv', upper(mcruise), stn_string));
                %end
            case 'raw_corrs' % -----> if change the hystherisis coef
            case 'rawedit_auto' % -----> only if repeated spikes or out of range
            case 'ctd_cals' % -----> to apply calibration
                co.docal.temp = 1;
                co.docal.cond = 1;
                co.docal.oxygen = 1;
                co.calstr.temp.sn34593.dy186 = 'dcal.temp = d0.temp + interp1([-10 6000],1*[10 -13]/1e4,d0.press);';
                co.calstr.temp.sn34593.msg = 'temp s/n 34593 adjusted from +1 mdeg at surface to -1.3 mdeg at 6000m to agree with SBE35. Fit to 26/80 data points';
                co.calstr.temp.sn34712.dy186 = 'dcal.temp = d0.temp + interp1([-10 6000],1*[15 15]/1e4,d0.press);';
                co.calstr.temp.sn34712.msg = 'temp s/n 34712 adjusted by +1.5 mdeg to agree with SBE35. Fit to 26/80 data points';
                co.calstr.cond.sn42571.dy186 = 'dcal.cond = d0.cond.*(1+ (interp1([2 9],[-1e-3 1e-3],d0.statnum) + interp1([-10 1500 5000],[-2e-3 0.5e-3 -3e-3],d0.press))/35);';
                co.calstr.cond.sn42571.msg = 'cond s/n 42571 adjusted to agree with bottle salinity up to station 8 (42 good comparison points) SSW batch P167';
                co.calstr.cond.sn43054.dy186 = 'dcal.cond = d0.cond.*(1+ (interp1([-10 2000 5000],[-2.5e-3 -1.5e-3 -3e-3],d0.press) + interp1([1 12],[0 0],d0.statnum))/35);';
                co.calstr.cond.sn43054.msg = 'cond s/n 43054 adjusted to agree with bottle salinity up to station 8 (42 good comparison points) SSW batch P167';
                co.calstr.oxygen.sn431882.dy186 = 'dcal.oxygen = d0.oxygen.*interp1([-10      0   2000    5000 ],[1.045 1.045 1.075 1.09],d0.press).*interp1([2 9],[1.0 1.0],d0.statnum);';
                co.calstr.oxygen.sn431882.msg = 'oxygen s/n 1882 adjusted to agree with 77 points for stations 2 to 9 as compared with upcast after default hysterisis correction.';
                co.calstr.oxygen.sn432722.dy186 = 'dcal.oxygen = d0.oxygen.*interp1([-10      0   1500    3000  5000 ],[1.06 1.06 1.080 1.100  1.100 ],d0.press);';
                co.calstr.oxygen.sn432722.msg = 'oxygen s/n 2722 adjusted to agree with 77 points for stations 2 to 9  as compared with upcast after default hysterisis correction.';
            case 'sensor_choice' % -----> if we choose to use sensor 2 instead of sensor 1 for some or all of the stations
            case 'bestdeps' % ------> if not full depth (can add later)
                %depth_source = {'ctd','bathy'};
                replacedeps = [2 3453; %interpolated from multibeam
                    3 4572;
                    4 3844;
                    5 4623;
                    7 4178;
                    8 4831;
                    9 4115];
                iscor = 1;
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
                %k_empty = find(niskin_number == -9); % positions with no bottle (cast 2) -- though these are excluded by msbe35_to_sam anyway so these lines may not be necessary
                %[~,kposempty,~] = intersect(position,k_empty); % index of empty places in set of positions that have appeared in .bl file
                %niskin_flag(kposempty) = 9;
                switch stnlocal
                    case 3
                        niskin_flag(position==11) = 4; %not closed correctly
                    case 5
                        niskin_flag(position==15) = 4; %not closed correctly
                    case 6
                        niskin_flag(position==11) = 4; %not closed correctly
                    otherwise
                end
        end

    case 'sbe35'
        switch opt2
            case 'sbe35file'
                sbe35file = 'CTD_*.asc';
            case 'sbe35_parse'
                %deal with file containing multiple stations' data
                if strcmp(file_list{kf},'CTD_010203.asc') %statnum is last 3 chars before ".", so in this case incorrectly interpreted as 203
                    m = t.statnum==203; 
                    t.statnum(m) = 2; %no bottles fired on 1 as it was aborted
                    m = t.statnum==2 & t.datnum>datenum(2024,12,11,18,0,0);
                    t.statnum(m) = 3; 
                    %not sure why but there are some bn=0 lines, which we
                    %can't use anyway, so exclude
                    m = t.bn==0;
                    t(m,:) = [];
                end
        end

        %%%%%%%%%%%%%%%%% bottle samples %%%%%%%%%%%%%%%%%%%%%%%
    case 'botpsal'
        switch opt2
            case 'sal_files'
                salfiles = dir(fullfile(root_sal, ['autosal_' mcruise '_*.csv'])); 
            case 'sal_parse'
                cellT = 21; % Temperature of the bath
                ssw_k15 = 0.99988;
                calcsal = 1;                ssw_batch = 'P167';
            case 'sal_calc'
                 salin_off = [000 -3; 001 -6; ... 
                     002 -4; 003 -2; ... 
                     004 0; 005 -7; ... 
                     006 0; 007 -1; ...
                     008 -1; 009 -2; 009.1 -2; %009.1 is to apply to last 4 samples run right after 009
                     ];
                 salin_off(:,1) = salin_off(:,1)+999e3;
                 salin_off(:,2) = salin_off(:,2)*1e-5;
                 %last 4 samples (only 4 in last crate) were run
                 %immediately following the last full crate and standard
                 %999009, therefore no standard was run at the very end;
                 %to use a constant offset for the last 4, put in 009.1
                 %with same value as 009 in salin_off, then add a row with
                 %a runtime just after the last sample so that the
                 %interpolation will apply the constant. (only runtime and
                 %sampnum are used for this row as it appears to be a
                 %standards row) 
                 ds_sal = [ds_sal; ds_sal(end,:)];
                 ds_sal.runtime(end) = max(ds_sal.runtime)+5/60/24; ds_sal.sampnum(end) = 999000+salin_off(end,1);
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
                ofiles = dir(fullfile(root_oxy,'DY186_oxy*.xls'));
                hcpat = {'Bottle';'Number'}; %Flag is on 2nd line so start here
                chrows = 1;
                chunits = 2;
            case 'oxy_parse'
                calcoxy = 1;
                varmap.position = {'bottle_number'};
                m = ds_oxy.bottle_number==24; ds_oxy.bottle_number(m) = 1;
                varmap.fix_temp = {'temp_c'};
                varmap.vol_blank = {'titre_mls'};
                varmap.vol_titre_std = {'titre_mls_1'};
                varmap.sample_titre = {'titre_mls_2'};
                varmap.vol_std = {'vol_mls'};
                varmap.bot_vol_tfix = {'at_tfix_mls'};
                varmap.statnum = {'number'};
                d = cellstr(ds_oxy.number);
                ds_oxy.number = cellfun(@(x) str2double(x(4:end)), d);
                ds_oxy.flag = [];
                %will need to replace 24 with 1 probably based on oxygen
                %sampling log (it is using bottle label rather than bottle
                %position)
            case 'oxy_calc'
                % vol_reag_tot = 2.0397;
            case 'oxy_flags'
                %sampnum, a flag, b flag, c flag
                flr = [315 3 2 9; ... %a is lower than all
                      ];
        end


    case 'check_sams'
        check_oxy = 1; %step through mismatched oxygen replicates
        check_sal = 0; %step through each station's conductivity ratio readings
        check_sbe35 = 1; %probably not neeeded


        %%%%%%%%%%%%%%%%%%%%%% outputs and summaries %%%%%%%%%%%%%%%%%%%%%%
    case 'outputs'
        switch opt2
            case 'summary'
                snames = {'nsal' 'noxy'};
                sgrps = {{'botpsal'} {'botoxy'}};
            case 'exch'
                n12 = 8; 
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
                        '#CTD: Who - T. Petit (NOC); Status - final.';...
                        '#The CTD PRS; TMP; SAL; OXY data are all calibrated and good.';...
                        '# DEPTH_TYPE   : COR';...
                        '# DEPTH_TYPE   : water depth from CTDPRS + CTD altimeter range to bottom (station 6), or speed of sound-corrected ship-mounted bathymetric echosounder'...
                        }];
                else
                    headstring = {['BOTTLE,' datestr(now,'yyyymmdd') submitter]};
                    headstring = [headstring; common_headstr;
                        {sprintf('#%d stations with 24-place rosette with 12 bottles',n12);...
                        '#CTD: Who - T. Petit (NOC); Status - final';...
                        '#Notes: Includes CTDSAL, CTDOXY, CTDTMP';...
                        '#The CTD PRS; TMP; SAL; OXY data are all calibrated and good.';...
                        '# DEPTH_TYPE   : COR';...
                        '# DEPTH_TYPE   : water depth from CTDPRS + CTD altimeter range to bottom (station 6), or speed of sound-corrected ship-mounted bathymetric echosounder';...
                        '#Salinity: Who - T. Petit (NOC); Status - final; SSW batch P167.';...
                        '#Oxygen: Who - M. de la Fuente Ruiz (Liege); Status - final.';...
                        }];
                end
        end

end

