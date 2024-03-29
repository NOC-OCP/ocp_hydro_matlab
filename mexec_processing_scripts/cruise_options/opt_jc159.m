switch scriptname
    
        %%%%%%%%%% castpars %%%%%%%%%%
    case 'castpars'
        switch oopt
            case 'klist'
                klist_exc = [1 2 27 28 59]; %stations 1 and 2 were swivel tests; 27 and 28 aborted; 59 no samples
        end
        %%%%%%%%%% end castpars %%%%%%%%%%
        
        
        %%%%%%%%%% mctd_01 %%%%%%%%%%
    case 'mctd_01'
        switch oopt
            case 'redoctm'
                if ismember(stnlocal, [52 53 58 60 66 69 74 77 81 90])
                    redoctm = 1;
                end
        end
        %%%%%%%%%% end mctd_01 %%%%%%%%%%
        
        %%%%%%%%%% mctd_02a %%%%%%%%%%
    case 'mctd_02a'
        switch oopt
            case 'prectm_rawedit'
                %pvars is a list of variables to NaN when pumps are off, with the
                %second column setting the number of additional scans after the
                %pumps come back on to also NaN
                pvars = {'temp1' 12
                    'temp2' 12
                    'cond1' 12
                    'cond2' 12
                    'oxygen_sbe1' 8*24
                    };
                revars = {'press' -10 8000
                    'temp1' -2 32
                    'temp2' -2 32
                    'cond1' 25 60
                    'cond2' 25 60
                    'transmittance' 50 100
                    'oxygen_sbe1' 0 400
                    'fluor' 0 0.5
                    };
                dsvars = {'press' 3 2 2
                    'temp1' 1 0.5 0.5
                    'temp2' 1 0.5 0.5
                    'cond1' 1 0.5 0.5
                    'cond2' 1 0.5 0.5
                    'oxygen_sbe1' 3 2 2
                    'transmittance' 0.3 0.2 0.2
                    'fluor' 0.2 0.1 0.1
                    'turbidityV' 0.05 0.05 0.05%***
                    'pressure_temp' 0.1 0.1 0.1
                    };
                if ~ismember(stnlocal, [74 90]); dsvars = dsvars(:,1:2); end
                ovars = {'oxygen_sbe1'};
        end
        %%%%%%%%%% end mctd_02a %%%%%%%%%%
        
        %%%%%%%%%% mctd_02b %%%%%%%%%%
    case 'mctd_02b'
        switch oopt
            case 'raw_corrs'
                doturbV = 1;
co.turbVpars = [3.343e-3 6.600e-2]; %from XMLCON for BBRTD-182, calibration date 6 Mar 17
        end
        %%%%%%%%%% end mctd_02b %%%%%%%%%%
        
        %%%%%%%%%% mctd_03 %%%%%%%%%%
    case 'mctd_03'
        switch oopt
            case 's_choice' %this applies to both t and c
                s_choice = 2;
        end
        %%%%%%%%%% end mctd_03 %%%%%%%%%%
        
        %%%%%%%%%% mfir_01 %%%%%%%%%%
    case 'mfir_01' %information about bottle firing
        switch oopt
            case 'fixbl'
                if stnlocal==74; position(21) = 21; end
                %the .bl and .btl files say 2 but they're wrong (this was when
                %the termination was failing)
                %fix this here to prevent overwriting the good values
                %corresponding to when bottle 2 was actually fired
        end
        %%%%%%%%%% end mfir_01 %%%%%%%%%%
        
        %%%%%%%%%% mfir_03 %%%%%%%%%%
    case 'mfir_03'
        switch oopt
            case 'fir_fill'
                fillstr = '10'; %max gap length to fill is 10 s
        end
        %%%%%%%%%% end mfir_03 %%%%%%%%%%
        
        %%%%%%%%%% mbot_00 %%%%%%%%%%
    case 'mbot_00' %information about niskin bottle numbers
        switch oopt
            case 'nispos'
                %inventory/serial numbers of the niskins in order of 1 to 24
                nis = [5977, 6406, 6407, 6408, 6409, 6410, 6411, 6412, 6413,...
                    6414, 6415, 6416, 6417, 6418, 6419, 6420, 1122, 6692, 1098,...
                    6428, 6425, 6426, 6427, 1086]; nis_spare = [1077];
                % 18 and 19 were switched from stn51 (and relabelled, so the
                %physical labels on the bottles still correspond to position
                %on the rosette)
                %spare niskin (was labelled "18" but it's a different one so
                %calling it 25) in position 1 from stn 101 so that CFCs can sparge
                %the original bottle 1
                %after stn 103 original 1 was put back in place, spare was moved to
                %position 2, and original 2 was taken for sparging
                if stnlocal>=51 & stnlocal<101; nis = nis([1:17 19 18 20:24])
                elseif stnlocal>=101 & stnlocal<104; nis = [nis_spare nis([2:17 19 18 20:24])];
                elseif stnlocal>=104; nis = [nis(1) nis_spare nis([3:17 19 18 20:24])];
                end
        end
        %%%%%%%%%% end mbot_00 %%%%%%%%%%
        
        %%%%%%%%%% mwin_01 %%%%%%%%%%
    case 'mwin_01'
        % stations 1, 2, 27, 28 have winch data for swivel tests but no ctd files
        switch stnlocal
            case 1
                winch_time_start = [2018 3 1 12 30 0]; % first swivel test
                winch_time_end = [2018 3 1 14 33 0];
            case 2
                winch_time_start = [2018 3 1 14 48 0]; % second swivel test
                winch_time_end = [2018 3 1 16 35 0];
            case 27
                winch_time_start = [2018 3 7 12 54 0]; % aborted CTD
                winch_time_end = [2018 3 7 13 40 0];
            case 28
                winch_time_start = [2018 3 7 22 12 0]; % aborted CTD
                winch_time_end = [2018 3 7 22 34 0];
        end
        
        %%%%%%%%%% end mwin_01 %%%%%%%%%%
        
        %%%%%%%%%% mwin_to_fir %%%%%%%%%%
    case 'mwin_to_fir'
        switch oopt
            case 'winch_fix'
                % jc159: when winch is switched from auto control to manual control
                % for recovery, usually around 100 metres, the winch telemetry is
                % off for a few seconds and techsas records a zero, which sometimes
                % shows up as zero wireout at the bottle closure time. This option
                % first introduced on jr302
                switch stnlocal
                    case 5
                        d.wireout(14:15) = d.wireout(13); % use existing bottle wireout to ensure they match exactly
                    case 6
                        d.wireout(18) = d.wireout(17);
                    case 15
                        d.wireout(18) = d.wireout(19);
                    case 16
                        d.wireout(20) = [100]; % nominal
                end
        end
        %%%%%%%%%% end mwin_to_fir %%%%%%%%%%
        
        
        %%%%%%%%%% mctd_checkplots %%%%%%%%%%
    case 'mctd_checkplots'
        switch oopt
            case 'plot_saltype'
                saltype = 'asal';
        end
        %%%%%%%%%% end mctd_checkplots %%%%%%%%%%
        
        %%%%%%%%%% mctd_rawedit %%%%%%%%%%
    case 'mctd_rawedit'
        switch oopt
            case 'rawedit_auto'
                if stnlocal==90
                    dsvars = {'oxygen_sbe1' 2
                        'transmittance' 0.2
                        'fluor' 0.2
                        'turbidityV' 0.05
                        };
                end
        end
        %%%%%%%%%% end mctd_rawedit %%%%%%%%%%
        
        %%%%%%%%%% list_bot %%%%%%%%%%
    case 'list_bot'
        switch oopt
            case 'samadj'
                dsam.cruise = 159 + zeros(size(dsam.sampnum));
                hsam.fldnam = [hsam.fldnam {'cruise' 'lon' 'lat' 'bottom_dep' 'udepth' 'usig0' 'ugamma_n'}];
                hsam.fldunt = [hsam.fldunt {'number' 'degreesE' 'degreesN' 'metres' 'metres' 'kg/m3' 'gamma'}];
            case 'printmsg'
                msg = [datestr(now,31) ' jc159 CTD PSAL and Oxygen data uncalibrated' ];
                %msg = [datestr(now,31) ' dy040 CTD PSAL and Oxygen data preliminary calibration' ]; %dy040 elm 26 Dec 2015
                %msg = [datestr(now,31) ' dy040 CTD PSAL and Oxygen data final end of cruise calibration' ]; %dy040 elm 20 jan 2016 oxy data up to 139; salts up to 135
                fprintf(1,'%s\n',msg);
                fprintf(fidout,'%s\n',msg);
        end
        %%%%%%%%%% list_bot %%%%%%%%%%
        
        %%%%%%%%%% populate_station_depths %%%%%%%%%%
    case 'populate_station_depths'
        switch oopt
            case 'depth_source'
                depmeth = {'file' 'ctd'}; %get from text file generated by LADCP basic proc
                fnintxt = '/local/users/pstar/cruise/data/ladcp/ix/bdeps.txt';
            case 'bestdeps'
                replacedeps = [9 2522;
                    27 5063; %aborted cast
                    28 5063; %aborted cast (same station)
                    33 5300;
                    41 5708;
                    63 4419;
                    77 4972;
                    78 5244;
                    89 5200;
                    124 3624;
                    125 204];
        end
        %%%%%%%%%% end populate_station_depths %%%%%%%%%%
        
        %%%%%%%%%% mbot_01 %%%%%%%%%%
    case 'mbot_01'
        switch oopt
            case 'botflags'
                %stn nis
                flag3 = [3 9; 6 5; 7 9; 26 5; 36 9; 57 15;... %leaking (clearly) %3716, 4513, 5117
                    98 5; 98 6; 98 12; 98 21; 103 19]; %caps were loose, so probably some leaking..?
                flag4 = [4 9; 4 2; 8 22; 9 22; 13 20; 16 1; 32 18; 43 8; 43 16; 48 3; 48 13; 49 16; 74 9; 74 21; 74 22; 74 23; 74 24; 76 9; 80 6; 83 7; 89 16; 112 7; 113 7; 114 10;... %from logsheet
                    90 4; 90 8; %pumps off when bottle fired, so we don't know t, s
                    41 16; 32 16; 17 13; 18 9; 16 9; 39 13; 47 17; 37 16; 52 22; 97 6; 98 1]; %did not trip correctly (i.e. CTD thought it tripped but it obviously closed at the wrong depth)
                flag9 = [114 17; 114 22; ...
                    115 3; 115 6; 115 9; 115 12; 115 14; 115 15; 115 17; 115 18; 115 20; 115 21; 115 23; 115 24; ...
                    116 16; 116 19; 116 21; 116 23; 116 24; ...
                    117 20; 117 22; 117 24; ...
                    122 10; 122 12];
                iif = find(flag3(:,1)==stnlocal); if length(iif)>0; bottle_qc_flag(flag3(iif,2)) = 3; end
                iif = find(flag4(:,1)==stnlocal); if length(iif)>0; bottle_qc_flag(flag4(iif,2)) = 4; end
                iif = find(flag9(:,1)==stnlocal); if length(iif)>0; bottle_qc_flag(flag9(iif,2)) = 9; end
                if ismember(stnlocal, [27 28 59 125]); bottle_qc_flag(:) = 9; end
        end
        %%%%%%%%%% end mbot_01 %%%%%%%%%%
        
        
        %%%%%%%%%% msal_01 %%%%%%%%%%
    case 'msal_01'
        switch oopt
            case 'salflags'
                flag(ismember(sampnum,[3123 5620 8122 9209])) = 3;
                flag4 = [0308 1916 3513 3716 ...
                    4002 4117 4513 5117 5118 5222 5415 5416 5417 6101 6522 ...
                    7101 7118 7204 7308 7309 7320 7802 7811 7813 7902 ...
                    8007 8008 8102 8523 8816 8701];
                flag(ismember(sampnum,flag4)) = 4;
                flag(sampnum==10823) = 5;
                
        end
        %%%%%%%%%% end msal_01 %%%%%%%%%%
        
        %%%%%%%%%% msal_standardise_avg %%%%%%%%%%
    case 'msal_standardise_avg'
        switch oopt
            case 'check_sal_runs'
                check_sal_runs = 0;
                calc_offset = 1;
                plot_all_stations = 0;
            case 'k15'
                sswb = 161; %ssw batch
                msal_ssw
                ds_sal.K15 = zeros(size(ds_sal.sampnum));
                ds_sal.K15(iistd) = ssw_batches(ssw_batches(:,1)==sswb,2)/2;
            case 'cellT'
                ds_sal.cellT = 21+zeros(length(ds_sal.sampnum),1);
            case 'std2use'
                std2use([47 68 121],1) = 0;
                std2use([50],2) = 0;
                std2use([61],3) = 0;
            case 'sam2use'
                sam2use(51,2) = 0;
                sam2use([2587 2896],3) = 0;
            case 'fillstd'
                %add the start standard--can add it at the end because we'll
                %use time to interpolate
                ds_sal.sampnum = [ds_sal.sampnum; 999000];
                ds_sal.offset(end) = 0;
                ds_sal.runtime(end) = ds_sal.runtime(1)-1/60/24; %put it 1 minute before sample 1
                %%machine was re-standardised before running stn 68
                %ds_sal.sampnum = [ds_sal.sampnum; 999097.5];
                %ds_sal.offset(end) = 4e-6;
                %ds_sal.runtime(end) = ds_sal.runtime(ds_sal.sampnum==6801)-1/60/24;
                %this half-crate had no standard at the end so use the one
                %from the beginning
                if sum(ds_sal.sampnum==999111)
                    ds_sal.sampnum = [ds_sal.sampnum; 999111.5];
                    ds_sal.offset(end) = ds_sal.offset(ds_sal.sampnum==999111);
                    ds_sal.runtime(end) = ds_sal.runtime(ds_sal.sampnum==7611)+1/60/24;
                    %interpolate based on runtime
                    xoff = ds_sal.runtime;
                end
        end
        %%%%%%%%%% msal_standardise_avg %%%%%%%%%%
        
        %%%%%%%%%% moxy_01 %%%%%%%%%%
    case 'moxy_01'
        switch oopt
            case 'oxycsv'
                infile = fullfile(root_oxy, [upper(mcruise) '_oxy_' num2str(stnlocal) '.csv']);
            case 'oxysampnum'
                ds_oxy.statnum = ds_oxy.cast;
                ds_oxy.oxy_bot = ds_oxy.bottle;
                ds_oxy.bot_vol = ds_oxy.bottle_vol0x2e;
                ds_oxy.vol_blank = ds_oxy.blank;
                ds_oxy.vol_std = ds_oxy.std;
                ds_oxy.vol_titre_std = ds_oxy.standard;
                ds_oxy.oxy_temp = ds_oxy.fixing_temp0x2e;
                ds_oxy.oxy_titre = ds_oxy.sample;
                ds_oxy.mol_std = ds_oxy.iodate_m;
                ds_oxy.nO2 = ds_oxy.n0x28O20x29;
                ds_oxy.concO2 = ds_oxy.c0x28O20x29;
            case 'oxyflags'
                flags3 = [0308 1405 1415 2101 2103 3222 4201 4513 4804 ...
                    5110 5614 5716 5717 5718 5816 6316 6612 6910 ...
                    7103 7321 7322 8513];
                flags4 = [0406 0523 0601 2106 2311 2320 2322 2323 3004 3023 ...
                    3217 3506 3915 4115 4121 4203 4707 4720 4724 4810 4811 ...
                    5023 5123 5222 5313 5402 5605 5616 5712 6005 6011 6014 6101 6124 ...
                    8124 10917 10904 11022 11023 11213 12020];
                ds_oxy.flag(ismember(ds_oxy.sampnum, flags3)) = 3;
                ds_oxy.flag(ismember(ds_oxy.sampnum, flags4)) = 4;
                if ismember(stnlocal, [9:11 24 34 44]) %standardisation probably wrong
                    %due to bubbles in line; earlier set flags to 3 but now say 4
                    ds_oxy.flag(ds_oxy.flag<=4) = 4;
                end
        end
        %%%%%%%%%% end moxy_01 %%%%%%%%%%
        
        %%%%%%%%%% moxy_ccalc %%%%%%%%%%
    case 'moxy_ccalc'
        switch oopt
            case 'oxypars'
                vol_reag1 = mean([1.00 1.01 1.01]);
                vol_reag2 = mean([1.04 1.03 1.03 1.03]);
            case 'blstd'
                vol_std = ds_oxy.vol_std;
                vol_titre_std = ds_oxy.vol_titre_std;
                vol_blank = ds_oxy.vol_blank;
                mol_std = ds_oxy.mol_std*1e-3;
            case 'botvols'
                obot_vol = ds_oxy.bot_vol; %***also check volumes?
                if 0
                    fname_bottle = 'ctd/BOTTLE_OXY/flask_vols.csv';
                    ds_bottle = dataset('File', fname_bottle, 'Delimiter', ',');
                    ds_bottle(isnan(ds_bottle.bot_num),:) = [];
                    mb = max(ds_bottle.bot_num); a = NaN+zeros(mb, 1);
                    a(ds_bottle.bot_num) = ds_bottle.bot_vol;
                    iig = find(~isnan(ds_oxy.oxy_bot) & ds_oxy.oxy_bot~=-999);
                    obot_vol = NaN+ds_oxy.oxy_bot; obot_vol(iig) = a(ds_oxy.oxy_bot(iig)); %mL
                end
            case 'compcalc'
                compcalc = 0; %if stnlocal>=30; compcalc = 1; end %***should just check again with up to date precise volumes
        end
        %%%%%%%%%% end moxy_ccalc %%%%%%%%%%
        
        %%%%%%%%%% mnut_01 %%%%%%%%%%
    case 'mnut_01'
        switch oopt
            case 'sampnum_parse'
                stncol = ds_nut.METH;
                ds_nut.sampnum = zeros(size(stncol));
                b = zeros(size(stncol));
                forms = {'st'; 'sta'; 'stn'}; %station number may be preceded by any of these (or their upper case versions)
                for no = 1:length(forms)
                    b = b + strncmpi([forms{no} stn_string], stncol, length(forms{no})+length(stn_string)); %may be a 3-digit station number
                    b = b + strncmpi([forms{no} num2str(stnlocal)], stncol, length(forms{no})+length(num2str(stnlocal))); %or may be a variable-digit station number
                end
                iig = find(b>0);
                for no = 1:length(iig)
                    %station and niskin can be separated by - or space
                    ii = strfind(stncol{iig(no)}, '-'); if length(ii)==0; ii = strfind(stncol{iig(no)}, ' '); end
                    %sample may or may not have a trailing letter
                    nisk = str2num(stncol{iig(no)}(ii+1:end)); if isempty(nisk); nisk = str2num(stncol{iig(no)}(ii+1:end-1)); end
                    ds_nut.sampnum(iig(no)) = stnlocal*100 + nisk;
                end
                ds_nut.station = floor(ds_nut.sampnum/100);
                ds_nut.niskin = ds_nut.sampnum-floor(ds_nut.sampnum/100)*100;
            case 'vars'
                vars = {
                    'position'     'number'     'niskin'
                    'statnum'      'number'     'station'
                    'sampnum'      'number'     'sampnum'
                    'sio4'         'umol/L'     'Si_COR'
                    %    		   'sio4'         'umol/L'     'SiCOR'
                    'sio4_flag'    'woceflag'   ''
                    'po4'          'umol/L'     'PO4_COR'
                    %		       'po4'          'umol/L'     'PO4COR'
                    'po4_flag'     'woceflag'   ''
                    'no3no2'       'umol/L'     'NO30x2BNO2_COR'
                    %	    	   'no3no2'       'umol/L'     'NO3_NO2COR'
                    'no3no2_flag'  'woceflag'   ''
                    'no2'          'umol/L'     'NO2_COR'
                    %		       'no2'          'umol/L'     'NO2COR'
                    'no2_flag'	  'woceflag'   ''
                    };
            case 'flags'
                flags4 = [12001 12004];
                silc_flag(ismember(sampnum, flags4)) = 4;
                phos_flag(ismember(sampnum, flags4)) = 4;
                totnit_flag(ismember(sampnum, flags4)) = 4;
                no2_flag(ismember(sampnum, flags4)) = 4;
        end
        %%%%%%%%%% end mnut_01 %%%%%%%%%%
        
        %%%%%%%%%% miso_01 %%%%%%%%%%
    case 'miso_01'
        switch oopt
            case 'files'
                files{1} = fullfile(root_iso, ['jc159_13c_dic_whcorrected.csv']);
                files{2} = fullfile(root_iso, ['SampleResults_2018112_withStationNumbersCorrected.csv']);
                files{3} = fullfile(root_iso, ['A095_740H20180228_no_cfc_values_hy_with_d18o.csv']);
            case 'vars'
                vars{1} = {
                    'statnum'      'number'     'x0xEF0xBB0xBFStation'
                    'position'     'number'     'Niskin'
                    'del13c_bgs' 'per_mil' 'd13C';
                    'del13c_bgs_flag' 'woceflag' 'junk'};
                vars{2} = {
                    'statnum'      'number'    'Station'
                    'position'     'number'    'Niskin'
                    'del13c_whoi'  'per_mil' 'd13C'
                    'del14c_whoi'  'per_mil' 'D14C'
                    %'dic_whoi' 'mmol_per_kg' 'DIC Conc (mmol/kg)'
                    'del14c_whoi_flag' 'woceflag' 'flag'
                    'del13c_whoi_flag' 'woceflag' 'flag'};
                vars{3} = {
                    'statnum'    'number'    'STNNBR'
                    'position'   'number'    'SAMPNO'
                    'del18o_bgs'      'per_mil' 'BOT_O0x2D18'
                    'del18o_bgs_flag' 'per_mil' 'BOT_O0x2D18_FLAG'};
            case 'flags'
                del18o_bgs(del18o_bgs<-990) = NaN;
                del18o_bgs_flag(isnan(del18o_bgs) & ismember(del18o_bgs_flag, [2 3])) = 4;
        end
        %%%%%%%%%% end miso_01 %%%%%%%%%%
        
        %%%%%%%%%% miso_02 %%%%%%%%%%
    case 'miso_02'
        switch oopt
            case 'vars'
                cvars = 'del13c_bgs del13c_bgs_flag del13c_whoi del13c_whoi_flag del14c_whoi del14c_whoi_flag'
        end
        %%%%%%%%%% end miso_02 %%%%%%%%%%
        
        %%%%%%%%%% mco2_01 %%%%%%%%%%
    case 'mco2_01'
        switch oopt
            case 'infile'
                load(fullfile(root_co2, [mcruise '_alkalinity_hydro'])); indata = hydro;
                indata1 = load(fullfile(root_co2, [mcruise '_dic_hydro'])); indata1 = indata1.hydro;
                indata1.talk = NaN+indata1.dic; indata1.talk(1:length(indata.talk)) = indata.talk;
                indata1.QF_talk = NaN+zeros(size(indata1.QF_dic));
                indata1.QF_talk(1:length(indata.QF_talk)) = indata.QF_talk;
                indata = indata1;
            case 'varnames' %capitalisation is important!
                varnames = {'statnum' 'stn'
                    'niskin'  'nisk'
                    'alk' 'talk'
                    'alk_flag' 'QF_talk'
                    'dic' 'dic'
                    'dic_flag' 'QF_dic'
                    };
            case 'flags'
                flag3a = [0307 0308 0702 0703 0706 0707 0801 0802 0807 ...
                    0905 0906 1007 1101 1102 1104 1105 1211 1212 1503 ...
                    1701 1702 1801 1802 3513 3820];
                flag4a = [1012 1107 1109 1203 1204 1205 1206 1208 1507 1619 ...
                    2203 2221 5117];
                flag3d = [8616];
                flag4d = [1203 1507 1519 2203 2221 3518 3521 3820 ...
                    4012 4924 5117 5603 6406];
                alk_flag(ismember(sampnum, flag3a)) = 3;
                alk_flag(ismember(sampnum, flag4a)) = 4;
                dic_flag(ismember(sampnum, flag3d)) = 3;
                dic_flag(ismember(sampnum, flag4d)) = 4;
        end
        %%%%%%%%%% end mco2_01 %%%%%%%%%%
        
        %%%%%%%%%% mcfc_01 %%%%%%%%%%
    case 'mcfc_01'
        switch oopt
            case 'inputs'
                %list of variables and units in input, and in output, and
                %scale factors
                varsunits = {
                    'station'    'number'  'station'  'number'    1
                    'niskin'     'number'  'position' 'on.rosette' 1
                    'sf6mole' 'mol/l' 'sf6'        'fmol/l' 1e15
                    'sf6flag'   'woce_table_4.9' 'sf6_flag'   'woce_table_4.9' 1
                    'f11mole'      'mol/l' 'cfc11' 'pmol/l' 1e12
                    'f11flag' 'woce_table_4.9' 'cfc11_flag' 'woce_table_4.9' 1
                    'f12mole'      'mol/l'  'cfc12' 'pmol/l'    1e12
                    'f12flag' 'woce_table_4.9' 'cfc12_flag' 'woce_table_4.9' 1
                    'f113mole' 'mol/l' 'f113'       'pmol/l' 1e12
                    'f113flag'  'woce_table_4.9' 'f113_flag'  'woce_table_4.9' 1
                    'ccl4mole' 'mol/l' 'ccl4'       'pmol/l' 1e12
                    'ccl4flag'  'woce_table_4.9' 'ccl4_flag'  'woce_table_4.9' 1
                    };
                % bak post jc159 on bakmac; new file from M-J passed over
                % at LHR
                infile = fullfile(root_cfc, 'cfc_' mcruise '_all.txt']);
                
        end
        %%%%%%%%%% end mcfc_01 %%%%%%%%%%
        
        %%%%%%%%%% mcfc_02 %%%%%%%%%%
    case 'mcfc_02'
        switch oopt
            case 'cfclist'
                cfcinlist = 'sf6 sf6_flag cfc11 cfc11_flag cfc12 cfc12_flag f113 f113_flag ccl4 ccl4_flag';
                cfcotlist = cfcinlist;
        end
        %%%%%%%%%% end mcfc_02 %%%%%%%%%%
        
        %%%%%%%%%% msam_checkbottles_02 %%%%%%%%%%
    case 'msam_checkbottles_02'
        switch oopt
            case 'section'
                section = '24s';
            case 'docals'
                doocal = 0;
        end
        %%%%%%%%%% end msam_checkbottles_02 %%%%%%%%%%
        
        %%%%%%%%%% msam_checkbottles_01 %%%%%%%%%%
    case 'msam_checkbottles_01'
        switch oopt
            case 'section'
                section = '24s';
            case 'docals'
                doocal = 0;
        end
        %%%%%%%%%% end msam_checkbottles_01 %%%%%%%%%%
        
        %%%%%%%%%% msam_ashore_flag %%%%%%%%%%
    case 'msam_ashore_flag'
        switch samtype
            case 'chl'
                fnin = [mgetdir('M_BOT_CHL') '/Sample_log_Phyto_Chibo_sampnum.csv'];
                d_chl = load(fnin); %this is just three columns of numbers
                flagnames = {'botchla_flag'};
                flagvals = [1];
                sampnums = unique(d_chl(:,3));
                stations = floor(sampnums/100);
                sampnums = {unique(d_chl(:,3))};
            case {'bgs' 'whoi'}
                if strcmp(samtype, 'bgs')
                    flagnames = {'del18o_bgs_flag'; 'del13c_bgs_flag'};
                elseif strcmp(samtype, 'whoi')
                    flagnames = {'del14c_whoi_flag'; 'del13c_whoi_flag'};
                end
                fnin = [mgetdir('M_BOT_ISO') '/sample_log_' samtype '.csv'];
                ds_iso = dataset('File',fnin,'Delimiter',','); %csv file including text comments
                ds_iso.sampnum = ds_iso.Station*100+ds_iso.Niskin;
                flagvals = unique(ds_iso.flag);
                for no = 1:length(flagvals)
                    sampnums(1, no) = {ds_iso.sampnum(find(ds_iso.flag==flagvals(no)))};
                end
                sampnums(2,:) = sampnums(1,:);
                stations = floor(ds_iso.sampnum/100);
            case 'imp'
                fnin = [mgetdir('M_BOT_ISO') '/sample_log_imp.csv'];
                ds_iso = dataset('File',fnin,'Delimiter',','); %csv file including text comments
                ds_iso.sampnum = ds_iso.Station*100+ds_iso.Niskin;
                ds_iso.flag = ones(size(ds_iso.sampnum)); ds_iso.flag(isnan(ds_iso.BagNum)) = 9;
                flagnames = {'del14c_imp_flag'; 'del13c_imp_flag'};
                flagvals = unique(ds_iso.flag);
                for no = 1:length(flagvals)
                    sampnums(1, no) = {ds_iso.sampnum(find(ds_iso.flag==flagvals(no)))};
                end
                sampnums(2,:) = sampnums(1,:);
                stations = floor(ds_iso.sampnum/100);
            case 'cfc' %for these, change flags of 9 to 1 where cfc11 and cfc12 flag is 2, 3, or 4 (all quantities analysed for all cfc vars, but not all calibrated/analyses received yet)
                flagnames = {'sf6_flag'; 'ccl4_flag'; 'f113_flag'};
                flagvals = [1];
                a = {fullfile(root_sam, ['sam_' mcruise '_all'])
                    'sampnum'
                    'cfc11_flag'
                    'cfc12_flag'};
                a = [a; flagnames; '0'];
                MEXEC_A.MARGS_IN = a; [d,h] = mload;
                stations = [];
                for no = 1:length(flagnames)
                    ii = find(d.cfc11_flag<=4 & d.cfc12_flag<=4 & getfield(d,flagnames{no})==9);
                    sampnums(no,:) = {d.sampnum(ii)};
                    stations = [stations; floor(d.sampnum(ii)/100)];
                end
        end
        %%%%%%%%%% end msam_ashore_flag %%%%%%%%%%
        
        
        
        %%%%%%%%%% mctd_senscal %%%%%%%%%%
    case 'mctd_senscal'
        switch oopt
            case 'condcal'
                if senslocal==1
                    calvars = {'cond1' 'press'};
                    calstr = '%s = %s.*(1 + interp1([0 1500 6000], [1 1 0]*1e-3, press)/35);';
                    calmsg = 'cond1 jc159';
                elseif senslocal==2
                    calvars = {'cond2' 'press'};
                    calstr = '%s = %s.*(1 + interp1([0 1500 3000 6000], [-1.6 0.8 -0.7 -2.2]*1e-3, press)/35);';
                    calmsg = 'cond2 jc159';
                end
            case 'oxygencal'
                calvars = {'oxygen' 'press' 'statnum' 'press'};
                calstr = '%s = %s.*(1.036 + interp1([0 800 6000], [1 0 -2]*1e-4, %s).*%s)';
                calstr = [calstr ' + interp1([0 400 1250 2000 3000 4000 6000], [-2.7 0.25 2.75 5.6 7.5 8 7.1], %s);'];
        calmsg = 'oxygen jc159';
        end
        %%%%%%%%%% mctd_senscal %%%%%%%%%%
        
        %%%%%%%%%% oxy_apply_cal %%%%%%%%%%
    case 'oxy_apply_cal'
        alpha = (1.036 + interp1([0 800 6000], [1 0 -2]*1e-4, press).*stn);
        beta = interp1([0 400 1250 2000 3000 4000 6000], [-2.7 0.25 2.75 5.6 7.5 8 7.1], press);
        oxyout = alpha.*oxyin + beta;
        %%%%%%%%%% end oxy_apply_cal %%%%%%%%%%
        
        %%%%%%%%%% tsgsal_apply_cal %%%%%%%%%%
    case 'tsgsal_apply_cal'
        switch oopt
            case 'saladj'
                if time==1 & salin==1; salout = 1; else
                    load(fullfile(root_tsg, 'sdiffsm'))
                    salout = salin + interp1([0 t(:)' 1e3],[sdiffsm(1) sdiffsm(:)' sdiffsm(end)],time/86400); % interpolate/extrapolate correction                end
                end
                %%%%%%%%%% end tsgsal_apply_cal %%%%%%%%%%
        end % check this
        
        %%%%%%%%%% msim_plot %%%%%%%%%%
    case 'msim_plot'
        switch oopt
            case 'sbathy'
                bfile = '/local/users/pstar/topo/GMRTv3_5_201802200908topo.mat';
        end
        %%%%%%%%%% end msim_plot %%%%%%%%%%
        
        %%%%%%%%%% mem120_plot %%%%%%%%%%
    case 'mem120_plot'
        switch oopt
            case 'sbathy'
                bfile = '/local/users/pstar/topo/GMRTv3_5_201802200908topo.mat';
        end
        %%%%%%%%%% end mem120_plot %%%%%%%%%%
        
        %%%%%%%%%% mtsg_01 %%%%%%%%%%
    case 'mtsg_01'
        switch oopt
            case 'flag'
                %	    flag(ismember(ds_sal.sampnum, [])) = 3; %questionable
        end
        %%%%%%%%%% end mtsg_01 %%%%%%%%%%
        
        %%%%%%%%%% mtsg_bottle_compare %%%%%%%%%%
    case 'mtsg_bottle_compare'
        switch oopt
            case 'dbbad'
                %	    db.salinity_adj(72) = NaN; %bad comparison point
            case 'sdiff'
                sc1 = 0.02;
                sc2 = 5e-3;
        end
        %%%%%%%%%% end mtsg_bottle_compare %%%%%%%%%%
        
        %%%%%%%%%% mtsg_cleanup %%%%%%%%%%
    case 'mtsg_cleanup'
        switch oopt
            case 'kbadlims' %times when pumps off
                kbadlims = {
                    datenum([2018 02 23 00 00 00])  datenum([2018 02 28 22 22 00]) 'all' %start of cruise
                    datenum([2018 03 07 13 18 00])  datenum([2018 03 07 13 47 00]) {'psal' 'fluo' 'cond' 'temp_h'} % spike in cond, assume affects all pumped readings?
                    datenum([2018 03 14 14 24 00])  datenum([2018 03 14 15 00 00]) {'psal' 'fluo' 'cond' 'temp_h'} % spike in cond
                    datenum([2018 03 21 16 42 00])  datenum([2018 03 21 17 14 00]) {'psal' 'fluo' 'cond' 'temp_h'} % spike in cond
                    datenum([2018 03 28 15 21 00])  datenum([2018 03 28 16 06 00]) {'psal' 'cond'}
                    datenum([2018 04 02 18 00 00])  datenum([2018 04 03 14 54 00]) 'all' %walvis bay 1
                    datenum([2018 4 6 12 17 0]) datenum([2018 4 6 14 51 0]) 'all' %walvis bay 2
                    datenum([2018 4 8 5 11 0]) datenum([2018 4 15 0 0 0]) 'all' %end
                    %hobnobs are for cheesecake
                    };
        end
        %%%%%%%%%% end mtsg_cleanup %%%%%%%%%%
        
        
        %%%%%%%%%% mout_cchdo %%%%%%%%%%
    case 'mout_cchdo'
        switch oopt
            case 'expo'
                expocode = '740H20180228';
                sect_id = 'A09.5_24S';
            case 'woce_file_flagonly'
                varsexclude = {'cfc11' 'cfc12' 'f113' 'ccl4' 'sf6' 'sf5cf3'};
            case 'woce_file_pre'
                prefix = fullfile(MEXEC_G.MEXEC_DATA_ROOT, 'collected_files', ['A095_' expocode]);
                if length(varsexclude)>0
                    prefix = [prefix '_no_cfc_values'];
                end
            case 'woce_headstr_sam'
                headstring = {['BOTTLE,' datestr(now,'yyyymmdd') 'OCPNOCBAK'];...
                    '#SHIP: James Cook';...
                    '#Cruise JC159; A09.5 24S';...
                    '#Region: South Atlantic';...
                    ['#EXPOCODE: ' expocode];...
                    '#DATES: 20180228 - 20180410';...
                    '#Chief Scientist: B. King, NOC';...
                    '#Supported by NERC NE/N018095/1 (ORCHESTRA) and NERC NE/P019064/1 (TICTOC)';...
                    '#121 stations with 24-place rosette';...
                    '#CTD: Who - Y. Firing; Status - final';...
                    '#Notes: Includes CTDSAL, CTDOXY';...
                    '#The CTD PRS;  TMP;  SAL; OXY data are all calibrated and good.';...
                    '#Salinity: Who - J. Benson; Status - final';...
                    '#Notes: bottle salinity from stations 3-85 used for CTD calibration';...
                    '#Oxygen and Nutrients: Who - E. Mawji; Status - final';...
                    '#Notes: bottle oxygen from stations 35-123 used for CTD calibration';...
                    '#DIC and Talk: Who - P. Brown; Status - final';...
                    '#CFCs and SF6: Who - M.J. Messias; Status - uncalibrated, proprietary ';...
                    'C14/13: Who: A. McNichol; Status - final (data rcd 2019/03/11 from J. Lester)';...
                    'C13, O18: Who: M. Leng; Status - final';...
                    '#Notes:';...
                    '#These data should be acknowledged with: "Data were collected and made publicly available by the international Global Ship-based Hydrographic Investigations Program (GO-SHIP; http://www.go-ship.org/) with funding from the UK Natural Environment Research Council to the National Oceanography Centre and the University of Exeter."'};
            case 'woce_headstr_ctd'
                headstring = {['CTD,' datestr(now,'yyyymmdd') 'OCPNOCBAK'];...
                    '#SHIP: James Cook';...
                    '#Cruise JC159; A09.5 24S';...
                    '#Region: South Atlantic';...
                    ['#EXPOCODE: ' expocode];...
                    '#DATES: 20180228 - 20180410';...
                    '#Chief Scientist: B. King, NOC';...
                    '#Supported by NERC NE/N018095/1 (ORCHESTRA)';...
                    '#121 stations with 24-place rosette';...
                    '#CTD: Who - Y. Firing; Status - final';...
                    '#Notes: Includes CTDSAL, CTDOXY';...
                    '#The CTD PRS;  TMP;  SAL; OXY data are all calibrated and good.';...
                    '#DEPTH_TYPE   : COR';...
                    '#These data should be acknowledged with: "Data were collected and made publicly available by the international Global Ship-based Hydrographic Investigations Program (GO-SHIP; http://www.go-ship.org/) with National Capability funding from the UK Natural Environment Research Council to the National Oceanography Centre."'};
        end
        %%%%%%%%%% end mout_cchdo %%%%%%%%%%
        
        %%%%%%%%%% msec_run_mgridp %%%%%%%%%%
    case 'msec_run_mgridp'
        switch oopt
            case 'sections'
                sections = {'24s' 'bc'};
            case 'ctd_regridlist'
                varlist = [varlist ' fluor transmittance turbidity'];
            case 'sec_stns'
                switch section
                    case '24s'
                        kstn = [4:26 29:32 34:88 90:113 122:-1:114]; % 1,2,3 tests; 27:28 aborted, 33 and 89 bottle blank
                    case 'bc'
                        kstn = [4:15];
                    case 'ben'
                        kstn = [123:-1:114];
                end
            case 'sam_gridlist'
                varuselist.names = {'botoxy' 'totnit_per_kg' 'phos_per_kg' 'silc_per_kg' 'dic' 'alk' 'cfc11'  'cfc12' 'f113' 'sf6' 'ccl4'};
                varuselist.names = {'botoxy' 'totnit_per_kg' 'phos_per_kg' 'silc_per_kg' 'dic' 'alk' 'cfc11'  'cfc12' 'f113' 'sf6'};
                %varuselist.names = {'botoxy' 'totnit' 'phos' 'silc' 'dic' 'alk'};
        end
        %%%%%%%%%% end msec_run_mgridp %%%%%%%%%%
        
        %%%%%%%%%% m_maptracer %%%%%%%%%%
    case 'm_maptracer'
        switch oopt
            case 'kstatgroups'
                kstatgroups = {3 [4:999]};
        end
        %%%%%%%%%% end m_maptracer %%%%%%%%%%
        
        
        %%%%%%%%%% station_summary %%%%%%%%%%
    case 'station_summary'
        switch oopt
            case 'sum_sams'
                snames = {'noxy'; 'nnut'; 'nco2'; 'ncfc'; 'no18s'; 'nc13s'; 'nchls'}; % Use s suffix for variable to count number on ship for o18 c13 chl, which will be zero
                snames_shore = {'noxy_shore'; 'nnut_shore'; 'nco2_shore'; 'ncfc_shore'; 'no18'; 'nc13'; 'nchl'}; % can use name without _shore, because all samples are analysed ashore
                sgrps = { {'botoxy'} %list of oxy variables
                    {'silc' 'phos' 'totnit'} %list of nuts variables
                    {'dic' 'talk'} %list of co2 variables
                    {'cfc11' 'cfc12' 'f113' 'sf6' 'ccl4' 'sf5cf3' 'cfc13'} %list of cfc variables
                    {'del18o_bgs'} % BGS del O 18
                    {'del13c_imp' 'del14c_imp' 'del13c_whoi' 'del14c_whoi'} % All delC13  delC14 except BGS
                    {'botchla'}
                    };
                sashore = [0; 1; 1; 1; 1; 1; 1]; %count samples to be analysed ashore? % can't presently count botoxy_flag == 1
            case 'sum_comments' % set comments
                comments{1} = 'Test station with swivel; no CTD';
                comments{2} = 'Test station with swivel; no CTD';
                comments{3} = 'Test station with CTD';
                comments{4} = 'Start of section';
                comments{26} = 'Termination OK';
                comments{27} = 'Aborted; CTD termination failed';
                comments{28} = 'Aborted; CTD termination failed';
                comments{29} = 'New termination CTD 1';
                comments{33} = 'CFC bottle blanks';
                comments{35} = 'Second oxygen sensor added';
                comments{49} = 'End use CTD 1';
                comments{50} = 'Start use Deep Tow';
                comments{74} = 'Termination failing, station OK';
                comments{75} = 'New Termination Deep Tow';
                comments{89} = 'CFC bottle blanks';
                comments{90} = 'Bad electrical connection';
                comments{91} = 'New Termination Deep Tow';
                comments{98} = 'End use Deep Tow';
                comments{99} = 'CTD 1 until 105';
                comments{106} = 'Deep Tow until 113';
                comments{113} = 'Last before Walvis Bay';
                comments{114} = 'Top of slope; CTD 1 until 121';
                comments{122} = 'Last in section; Deep Tow until 124';
                comments{123} = 'Repeat of 113';
                comments{124} = 'Shallow station for bulk surface water';
                comments{125} = 'Test station for video recording; CTD 1';
            case 'sum_edit'
                cordep(1) = 2859; maxw(1) = 2500.1; % cordep from station 3
                cordep(2) = 2859; maxw(2) = 2500.1; % cordep from station 3
                cordep(27) = 5063; maxw(27) = 661.5; % cordep from station 29
                cordep(28) = 5063; maxw(28) = 125.0; % cordep from station 29
                cordep(63) = 4419; % from CTD + alt; ladcp IX estimate is poor.
                cordep(77) = 4972; % from CTD + alt; ladcp IX estimate is poor.
                cordep(78) = 5244; % from CTD + alt; ladcp IX estimate is poor.
                cordep(124) = 3624; % from em122; 10m dip for surface bulk water samples
                cordep(125) = 204; % from em122; 10m dip for go-pro video of bottles closing
                minalt(42) = 42; % altimeter had pings to small values but CTD was about 42 off bottom
                minalt(54) = 83; % from LADCP; No good reading from altimeter.
                dns(1) = datenum([2018 03 01 12 35 00]); % Swivel test; times from winch data
                dnb(1) = datenum([2018 03 01 13 39 00]);
                dne(1) = datenum([2018 03 01 14 33 00]);
                dns(2) = datenum([2018 03 01 14 48 00]); % Swivel test; times from winch data
                dnb(2) = datenum([2018 03 01 15 45 00]);
                dne(2) = datenum([2018 03 01 16 34 00]);
                dne(27) = datenum([2018 03 07 13 38 00]);
                dne(28) = datenum([2018 03 07 22 31 00]);
                lat(1) =  -23.74599;
                lon(1) =  -40.31568;
                lat(2) =  -23.74601;
                lon(2) =  -40.31571;
            case 'parlist'
                parlist = [' sal'; ' oxy'; ' nut'; ' car'; ' co2'; ' cfc'; ' ch4'];
            case 'sum_varnames'
                varnames={'statnum' 'time_start' 'time_bottom' 'time_end' 'lat' 'lon' 'cordep' 'maxd' 'minalt' 'resid' 'maxw' 'maxp' 'ndpths' 'nsal' 'noxy' 'nnut' 'nco2' 'ncfc' 'no18' 'nc13' 'nchl'};
                varunits={'number' 'seconds' 'seconds' 'seconds' 'degrees' 'degrees' 'metres' 'metres' 'metres' 'metres' 'metres' 'dbar' 'number' 'number' 'number' 'number' 'number' 'number' 'number' 'number' 'number'};
            case 'sum_stn_list'
                stnadd = [1 2 ]; % force add of these stations to station list
        end
        %%%%%%%%%% end station_summary %%%%%%%%%%
        
        
        %%%%%%%%%% mvad_01 %%%%%%%%%%
    case 'mvad_01'
        switch oopt
            case 'files'
                if oslocal==150
                    cname = 'os150_enr_017_054';
                elseif oslocal==75
                    cname = 'os75_enr_002_041';
                end
                pre1 = [mcruise '_' inst '/adcp_pyproc/' cname '/' inst nbbstr];
                datadir = fullfile(root_vmadcp, pre1, 'contour');
                fnin = fullfile(datadir, [cname '.nc']);
                dataname = [inst '_' mcruise '_01'];
                %*** station 123?
        end
        %%%%%%%%%% end mvad_01 %%%%%%%%%%
        
end
