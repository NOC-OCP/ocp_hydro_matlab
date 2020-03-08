switch scriptname


   %%%%%%%%%% mbot_00 %%%%%%%%%%
   case 'mbot_00'
      if ~isempty(find([1:999] == stnlocal))
         nis = 1:24;
      end
      %if ~isempty(find([12] == stnlocal)); flag(17:24) = 3; end
      %if ~isempty(find([13] == stnlocal)); flag(17:24) = 3; end
      %if ~isempty(find([20] == stnlocal)); flag(17:24) = 3; end
      %if ~isempty(find([25] == stnlocal)); flag(9:24) = 3; end
      %if ~isempty(find([29] == stnlocal)); flag(9:24) = 3; end
      %if ~isempty(find([33] == stnlocal)); flag(20) = 3; flag(21) = 3; end
      %if ~isempty(find([35] == stnlocal)); flag(9:24) = 3; end   
   %%%%%%%%%% end mbot_00 %%%%%%%%%%

   %%%%%%%%%% mctd_02b %%%%%%%%%%
   case 'mctd_02b'
      switch oopt
         case 'oxyhyst'
            if ismember(stnlocal, 1:77)
               pars = {[-0.026 5000 1000]};
            elseif ismember(stnlocal, 78:300) %second grouping, hyst has changed
               pars = {[-0.022 5000 1000]};
            end
      end
   %%%%%%%%%% end mctd_02b %%%%%%%%%%

   %%%%%%%%%% mctd_03 %%%%%%%%%%
   case 'mctd_03'
      switch oopt
         case '24hz'
            if stnlocal == 143
               % remove some fouling on oxy, cond1 and temp1 on upcast and replace
               % with cond2 and temp2
               MEXEC_A.MARGS_IN = {
                  infile1
                  'y'
                  'oxygen'
                  'oxygen scan'
                  'y = x1; kbad = find(x2 >= 166024 & x2 <= 177940); y(kbad) = nan; ' % 820 to 507 dbars on upcast
                  ' '
                  ' '
                  'cond1'
                  'cond1 cond2 scan'
                  'y = x1; kbad = find(x3 >= 166024 & x3 <= 177940); y(kbad) = x2(kbad); ' 
                  ' '
                  ' '
                  'temp1'
                  'temp1 temp2 scan'
                  'y = x1; kbad = find(x3 >= 166024 & x3 <= 177940); y(kbad) = x2(kbad); '
                  ' '
                  ' '
                  ' '
                  };
               mcalib2
            end
      end
   %%%%%%%%%% end mctd_03 %%%%%%%%%%

   %%%%%%%%%% mfir_03 %%%%%%%%%%
   case 'mfir_03'
      if stnlocal == 143
         fillstr = 'k';
      else
         fillstr = 'f';
      end
   %%%%%%%%%% end mfir_03 %%%%%%%%%%

   %%%%%%%%%% mwin_01 %%%%%%%%%%
   case 'mwin_01'
      time_window = [-600 600]; % bak jr302 avoid catching unwanted data beyond gap on station 065 after power failure
      if(stnlocal == 65); time_window = [-600 300]; end
   %%%%%%%%%% end mwin_01 %%%%%%%%%%

   %%%%%%%%%% mwin_03 %%%%%%%%%%
   case 'mwin_03'
      fix_string = [];
      if stnlocal == 65
         % fix some winch wireout when winch data logging to SCS was off
         % after power outage
         fix_string = 'y(14:24) = [40 30 30 25 20 15 15 7 7 3 3];';
      end
   %%%%%%%%%% end mwin_03 %%%%%%%%%%


   %%%%%%%%%% msal_standardise_avg %%%%%%%%%%
   case 'msal_standardise_avg'
      switch oopt
         case 'flags'
            if stnlocal == 7; otdata([1 2 3 4 5],10) = 3; end % set some flags. measured on wrong scale ?
            if stnlocal == 8; otdata([1 2 3 4 5],10) = 3; end % set some flags
         case 'cellT'
            g_adj = [ % offset and bath temperature for each range of sample numbers, so the required values can be picked off with interpolation
            100 24 0
            2099 24 0
            2100 24 -1
            3099 24 -1
            3100 24 -2
            3299 24 -2
            3300 24 -3
            3699 24 -3
            3700 24 -4
            4099 24 -4
            4100 24 -5
            4699 24 -5
            4700 24 -6
            5499 24 -6
            5500 24 -7
            6099 24 -7
            6100 24 -8
            6399 24 -8
            6400 24 -9
            6599 24 -9
            6600 24 0 % other autosal
            6715 24 0
            6716 24 -9 % return to main autosal;
            7499 24 -9
            7500 24 -10
            7999 24 -10
            8000 24 -11
            9099 24 -11
            9100 24 -12
            14399 24 -12
            14400 24 -19
            15099 24 -19
            15100 24 -15
            16599 24 -15
            16600 24 -14 % stations analysed out of order while decision changed from -15 to -14
            16699 24 -14
            16700 24 -15
            16799 24 -15
            16800 24 -14
            16899 24 -14
            16900 24 -15
            16999 24 -15
            17000 24 -14
            17799 24 -14
            17800 24 -13
            19899 24 -13
            19900 24 -9
            20499 24 -9
            20500 24 -13
            23499 24 -13
            99999 24 -13 % boundaries refined at end of cruise
            ];
	    ds_sal.cellT = interp1(g_adj(:,1), g_adj(:,2), ds_sal.sampnum);
	 case 'offset'
     	    ds_sal.offset = interp1(g_adj(:,1), g_adj(:,3), ds_sal.sampnum);
      end
   %%%%%%%%%% end msal_standardise_avg %%%%%%%%%%

   %%%%%%%%%% mnut_01 %%%%%%%%%%
   case 'mnut_01'
      switch oopt
         case 'vars'
            varnames = {'position','statnum','sampnum','sio4','sio4_flag','po4','po4_flag','TP','TP_flag','TN','TN_flag','no3no2','no3no2_flag','no2','no2_flag','nh4','nh4_flag'};
            varunits = {'number','number','number','umol/l','woceflag','umol/l','woceflag','umol/l','woceflag','umol/l','woceflag','umol/l','woceflag','umol/l','woceflag','umol/l','woceflag'};
	 case 'badvals'
            no3no2(no3no2 == -999) = NaN; % flag is never -999; use 9 for sample not drawn.
            sio4(sio4 == -999) = NaN;
            po4(po4 == -999) = NaN;
            TN(TN == -999) = NaN;
            TP(TP == -999) = NaN;
            no2(no2 == -999) = NaN;
            nh4(nh4 == -999) = NaN;
      end
	 
   %%%%%%%%%% end mnut_01 %%%%%%%%%%

   %%%%%%%%%% mcfc_01 %%%%%%%%%%
   case 'mcfc_01'
      switch oopt
         case 'inputs'
            %list of variables and units in input, in output, and units
            %scale factor
            varsunits = {
                    'statnum'    'number'    'station' 'number'  1
                    'position'   'on.rosette' 'position' 'on.rosette' 1
                    'cfc12'      'mol/l'     'cfc12' 'pmol/l' 1e12
                    'cfc12_flag' 'woce_table_4.9' 'cfc12_flag' 'woce_table_4.9' 1
                    'cfc11'      'mol/l' 'cfc11' 'pmol/l' 1e12
                    'cfc11_flag' 'woce_table_4.9' 'cfc11_flag' 'woce_table_4.9' 1
                    'f113'       'mol/l' 'f113' 'pmol/l' 1e12
                    'f113_flag'  'woce_table_4.9' 'f113_flag'  'woce_table_4.9' 1
                    'ccl4'       'pmol/l' 'ccl4' 'pmol/l' 1
                    'ccl4_flag'  'woce_table_4.9' 'ccl4_flag'  'woce_table_4.9' 1
                    'sf6'        'mol/l' 'sf6' 'pmol/l' 1e12
                    'sf6_flag'   'woce_table_4.9' 'sf6_flag'   'woce_table_4.9' 1
                    };
       end
    %%%%%%%%%% end mcfc_01 %%%%%%%%%%

   %%%%%%%%%% mcfc_02 %%%%%%%%%%
   case 'mcfc_02'
      switch oopt
         case 'infile1'
	    infile1 = [root_cfc '/' prefix1 '01'];
	 case 'cfclist'
            cfcinlist = 'sf6 sf6_flag cfc11 cfc11_flag cfc12 cfc12_flag f113 f113_flag ccl4 ccl4_flag';
            cfcotlist = cfcinlist;
      end
   %%%%%%%%%% end mcfc_02 %%%%%%%%%%


   %%%%%%%%%% ctd_evaluate_sensors %%%%%%%%%%
   case 'ctd_evaluate_sensors'
      switch oopt
         case 'csensind'
	    if sensnum==1
               sensind = {find(d.statnum >= 1 & d.statnum <= 999 & d.upress > 1000)};   % first psal1
	    elseif sensnum==2
               sensind(1,1) = {find(d.statnum >= 1 & d.statnum <= 27)};   % first psal2
               sensind(2,1) = {find(d.statnum >= 28 & d.statnum <= 41)};   % second psal2
               sensind(3,1) = {find(d.statnum >= 42 & d.statnum <= 999 & d.upress > 1000)};   % third psal2
	    end
      end
   %%%%%%%%%% end ctd_evaluate_sensors %%%%%%%%%%

   %%%%%%%%%% end ctd_evaluate_oxygen %%%%%%%%%%
   case 'ctd_evaluate_oxygen'
      %%statnum rows 1:4296 are stations 1:179 set 1, rest are set2
      %set1=1:4296;
      %set2=4297:5616;
      %set1 = find(d.statnum<28); set2 = setdiff(1:length(d.statnum), set1);
   %%%%%%%%%% end ctd_evaluate_oxygen %%%%%%%%%%

   %%%%%%%%%% cond_apply_cal %%%%%%%%%%
   case 'cond_apply_cal'
      switch sensor
         case 1
            off1 = interp1([-10 0 1500 3500 8000],[0.0047 0.0047 0.0047 0.004 0.004],press);
            fac1 = off1/35 + 1;
            off2 = interp1([1 27 40 120 130 999],[0.0005 0.0005 -0.0002 -0.0002 -0.0007 -0.0007],stn);
            fac2 = off2/35 + 1;
            fac = fac1.*fac2;
            condadj = 0;
            condout = cond.*fac + condadj;
         case 2
            if ismember(stn, 1:27) %k21
               off =interp1([-10 0 500 1500 8000],[0.0035 0.0035 0.0035 0.0045 0.0045],press); % first secondary
               fac = off/35 + 1;
            elseif ismember(stn, 28:41) %k22
               statoffsets = [
                        28 0.0015
                        29 0.0015
                        30 0.0015
                        31 0.0015
                        32 0.0015
                        33 0.0015
                        34 0.0095
                        35 0.0095
                        36 0.0095
                        37 0.0095
                        38 0.0085
                        39 0.0085
                        40 0.0085
                        41 0.0085
                        ];
               kfind = find(statoffsets(:,1) == stn);
               if ~isempty(kfind)
                  off = statoffsets(kfind,2);
                  fac = off/35 + 1;
                end
             elseif ismember(stn, 42:999) % k23
                off1 =interp1([-10 0 2500 3500 8000],[0.0035 0.0035 0.003 0.003 0.003],press); % third secondary
                fac1 = off1/35 + 1;
                off2 = interp1([42 53 54 109 110 999],[0.002 0.002 0 0 0.0005 0.0005],stn);
                fac2 = off2/35 + 1;
                fac = fac1.*fac2;
             end
             condadj = 0;
             condout = cond.*fac;
             condout = condout+condadj;
      end
   %%%%%%%%%% end cond_apply_cal %%%%%%%%%%

   %%%%%%%%%% oxy_apply_cal %%%%%%%%%%
   case 'oxy_apply_cal'
      % dsam.uoxygen = 1.12*dsam.uoxygen + dsam.upress*7/3000; % nominal cal stns 1 and 2
      alpha = 1.06366;
      beta = 16.91;
      bin_press = [0 1000 3800];
      bin_offset = [-1 0 4];
      oxyadj = interp1(bin_press,bin_offset,press);
      oxy1=alpha*oxyin+beta;
      oxyout = oxy1+oxyadj;
   %%%%%%%%%% end oxy_apply_cal %%%%%%%%%%
   
   %%%%%%%%%% temp_apply_cal %%%%%%%%%%
   case 'temp_apply_cal'
      % initial t1 and t2 had small difference (about 0.4 mdeg)
      % but number 2 secondary had a 1.7 mdeg offset from first primary.
      % therefore adjust everything to agree with sbe35. Need to pursue
      % post-cruise cals.
      switch sensor
         case 1
            tempadj = -0.0009; % all stations
            tempout = temp+tempadj;
         case 2
            tempadj = nan;
            if stn <= 27
               tempadj = -0.0015; % initial temp2
            end
            if stn >= 28
               tempadj = +0.0009; % next temp2 stns 28 and after
            end
            tempout = temp+tempadj;
      end
   %%%%%%%%%% end temp_apply_cal %%%%%%%%%%


   %%%%%%%%%% mtsg_01 %%%%%%%%%%
   case 'mtsg_01'
      switch oopt
         case 'salcsv'
	    sal_csv_file = ['tsg_dy040_' stn_string '.csv_linux'];
	 case 'cellT'
            ds_sal.cellT = 24+zeros(length(ds_sal.station_day),1);
	 case 'offset'
            g_adj = [ % offset and bath temperature for each crate
                    1 24 0
                    2 24 -2
                    3 24 -7
                    4 24 -11
                    5 24 -12
                    6 24 -20
                    7 24 -15
                    8 24 -9
                    9 24 -13
                    99999 24 -13
                    ];
            ds_sal.offset = interp1(g_adj(:,1),g_adj(:,3),ds_sal.station_day);
      end
   %%%%%%%%%% end mtsg_01 %%%%%%%%%%
   
   %%%%%%%%%% mtsg_cleanup %%%%%%%%%%
   case 'mtsg_cleanup'
      switch oopt
         case 'kbadlims'
	    kbadlims = [
               %datenum([2013 01 01 00 00 00]) datenum([2013 03 18 14 51 00]) % start of cruise
               %datenum([2013 04 12 09 20 00]) datenum([2013 04 13 13 42 00])
               %datenum([2013 04 01 07 31 00]) datenum([2013 04 04 11 44 00])
               %datenum([2013 03 23 05 22 00]) datenum([2013 03 23 12 01 00])
               %datenum([2013 04 27 10 44 00]) datenum([2013 04 28 00 00 00]) % end of cruise
               datenum([]) datenum([])
             ];
      end
   %%%%%%%%%% end mtsg_cleanup %%%%%%%%%%

   %%%%%%%%%% mtsg_bottle_compare %%%%%%%%%%
   case 'mtsg_bottle_compare'
      switch oopt
         case 'sdiff'
	    clear sdiffsm
	    sc1 = 0.5; sc2 = 0.02;
      end
   %%%%%%%%%% end mtsg_bottle_compare %%%%%%%%%%

   %%%%%%%%%% tsgsal_apply_cal %%%%%%%%%%
   case 'tsgsal_apply_cal'
      switch oopt
         case 'saladj'
            botfile = ['ocl_' MEXEC_G.MSCRIPT_CRUISE_STRING '_01_medav_clean_botcompare']; 
            MARGS_STORE = MEXEC_A.MARGS_IN_LOCAL;
    	    [db hb] = mload(botfile,'/');
            MEXEC_A.MARGS_IN_LOCAL = MARGS_STORE; % put things back how they were !
            % same code as used to generate smoothed adjustment in
            % mtsg_bottle_compare
	    sc1 = 0.5; sc2 = 0.02;
            sdiff = db.salinity_adj-db.salinity;
            sdiffsm = filter_bak(ones(1,21),sdiff); % first filter
            res = sdiff - sdiffsm;
            sdiff(abs(res) > sc1) = nan;
            sdiffsm = filter_bak(ones(1,21),sdiff); % first filter
            res = sdiff - sdiffsm;
            sdiff(abs(res) > sc2) = nan;
            sdiffsm = filter_bak(ones(1,11),sdiff); % harsh filter to determine smooth adjustment
	    db.dn = datenum(hb.data_time_origin)+db.time/86400;
            dv = datevec(db.dn(1));
            decday = db.dn-datenum([dv(1) 1 1 0 0 0]);
	    adj = interp1([0 db.dn(:)' 1e10],[sdiffsm(1) sdiffsm(:)' sdiffsm(end)],dn); % extrapolate correction
            vout = salin+adj;
	 case 'plot'
            m_figure
            plot(decday,sdiff,'k+');
            hold on; grid on;
            plot(decday,sdiffsm,'r+-');
            xlabel('Decimal day; noon on 1 Jan = 0.5');
            ylabel('salinity difference PSS-78');
            title({MEXEC_G.MSCRIPT_CRUISE_STRING; 'Bottle minus TSG salinity differences'; 'Individual bottles and smoothed adjustment applied'});
	 end
   %%%%%%%%%% end tsgsal_apply_cal %%%%%%%%%%


   %%%%%%%%%% populate_station_depths %%%%%%%%%%
   case 'populate_station_depths'
      switch oopt
         case 'bestdeps'
            bestdeps(1) = 3024-2; % from CTD deck unit log. Not full depth cast
            bestdeps(20) = bestdeps(21); % shallow cast before 021
            bestdeps(25) = bestdeps(26); % shallow cast before 026
            bestdeps(29) = bestdeps(30); % shallow cast before 030
            bestdeps(34) = 3650-14; % from CTD deck unit log. Not full depth cast
            bestdeps(35) = bestdeps(36); % shallow cast before 036
            bestdeps(39) = bestdeps(40); % shallow cast before 036
            bestdeps(44) = bestdeps(45); % shallow cast before 045
            bestdeps(58) = bestdeps(59); % shallow cast before 059
            bestdeps(63) = 128; % shallow cast no ladcp
            bestdeps(64) = 145; % shallow cast no ladcp
            bestdeps(70) = 2442-25; % from CTD deck unit log. Not full depth cast
            bestdeps(109) = 145; % shallow cast no ladcp
            bestdeps(161) = 109; % from CTD deck unit log; no ladcp
            bestdeps(162) = 146; % shallow cast no ladcp
            bestdeps(163) = 227; % shallow cast no ladcp
            bestdeps(179) = bestdeps(180); % shallow cast before 180
            bestdeps(193) = bestdeps(194); % shallow cast before 194
            bestdeps(199) = 109; % from CTD deck unit log; no ladcp
            bestdeps(216:234) = [312 136 127 125 128 126 121 54 60 212 155 170 134 45 78 87 72 36 171 ]; % from CTD deck unit log; no ladcp
      end
   %%%%%%%%%% end populate_station_depths %%%%%%%%%%


   %%%%%%%%%% list_bot %%%%%%%%%%
   case 'list_bot'
      switch oopt
         case 'samadj'
            %dsam.uoxygen = 1.12*dsam.uoxygen + dsam.upress*7/3000; % nominal cal stns 1 and 2
            dsam.cruise = 302 + zeros(size(dsam.sampnum));
            hsam.fldnam = [hsam.fldnam {'cruise' 'lon' 'lat' 'bottom_dep' 'udepth' 'usig0'}];
            hsam.fldunt = [hsam.fldunt {'number' 'degreesE' 'degreesN' 'metres' 'metres' 'kg/m3'}];
	 case 'printmsg'
            msg = [datestr(now,31) ' jr302 CTD PSAL and Oxygen data calibrated' ];
            fprintf(1,'%s\n',msg);
            fprintf(fidout,'%s\n',msg);
      end
   %%%%%%%%%% end list_bot %%%%%%%%%%
   
   %%%%%%%%%% station_summary %%%%%%%%%%
    case 'station_summary'
        switch oopt
            case 'optsams'
                snames = {'noxy'; 'nnuts'; 'nco2'; 'ncfc'; 'nother'};
                sgrps = { {'oxy'} %list of oxy variables
                    {'silc' 'phos' 'totnit'} %list of nuts variables
                    {'dic' 'talk'} %list of co2 variables
                    {'cfc11' 'cfc12' 'f113' 'sf6' 'ccl4' 'sf5cf3' 'cfc13'} %list of cfc variables
                    {'ch4' 'no2'} %list of other variables
                    };
                sashore = [0; 1; 1; 1]; %count samples to be analysed ashore?
            case 'comments'
                ki = 3:53; comments(ki) = repmat({'OSNAP-W'}, length(ki), 1);
                ki = 3:16; comments(ki) = repmat({'OSNAP-W; shelf'}, length(ki), 1);
                ki = 54:62; comments(ki) = repmat({'A-B arc'}, length(ki), 1);
                ki = [62 71:76]; comments(ki) = repmat({'B-C arc'}, length(ki), 1);
                ki = [94:101]; comments(ki) = repmat({'C-D arc'}, length(ki), 1);
                ki = [41:53]; comments(ki) = repmat({'OSNAP-W; Line A'}, length(ki), 1);
                ki = [63:70]; comments(ki) = repmat({'Line B'}, length(ki), 1);
                ki = [101:109]; comments(ki) = repmat({'Line C'}, length(ki), 1);
                ki = [77:94]; comments(ki) = repmat({'OSNAP-E; Line D'}, length(ki), 1);
                ki = [110:160]; comments(ki) = repmat({'OSNAP-E'}, length(ki), 1);
                ki = [161:161]; comments(ki) = repmat({'OSNAP-E/EEL'}, length(ki), 1);
                ki = [162:198]; comments(ki) = repmat({'EEL'}, length(ki), 1);
                ki = [199:999]; comments(ki) = repmat({'OSNAP-E/EEL'}, length(ki), 1);
                comments{1} = 'Test station 1';
                comments{2} = 'Test station 2';
                comments{20} = 'Shallow; CH4/N2O only';
                comments{25} = 'Shallow; CH4/N2O only';
                comments{29} = 'Shallow; CH4/N2O only';
                comments{35} = 'Shallow; CH4/N2O only';
                comments{39} = 'Shallow; CH4/N2O only';
                comments{44} = 'Shallow; CH4/N2O only';
                comments{58} = 'Shallow; CH4/N2O only';
                comments{70} = 'Shallow; CH4/N2O only';
                comments{22} = 'Repeat of Test 2';
                comments{34} = 'CFC bottle blank; CFCs and O2 only';
                comments{41} = 'Offshore start of line A';
                comments{51} = 'No samples; taps open; repeated at 052';
                comments{53} = 'Inshore end of line A';
                comments{54} = 'Start A-B arc; No samples; CTD only; repeat of 041';
                comments{62} = 'End A-B arc';
                comments{63} = 'Inshore start of line B';
                comments{69} = 'Deepest station on line B';
                comments{71} = 'Start B-C arc';
                comments{76} = 'End B-C arc';
                comments{78} = 'Inshore start of line D';
                comments{77} = 'OSNAP-E; Line D';
                comments{94} = 'Branch to C-D arc';
                comments{101} = 'Offshore start of line C; repeat of 076';
                comments{109} = 'Inshore end of line C';
                comments{110} = 'OSNAP-E; repeat of 093';
                comments{111} = 'OSNAP-E; repeat of 094';
                comments{161} = 'OSNAP-E/EEL junction';
                comments{199} = 'OSNAP-E/EEL junction; repeat of 161';
                comments{234} = 'OSNAP-E/EEL final station';
            case 'parlist'
                parlist = [' sal'; ' oxy'; ' nut'; ' car'; ' co2'; ' cfc'; ' ch4'];
            case 'varnames'
                varnames={'statnum' 'time_start' 'time_bottom' 'time_end' 'lat' 'lon' 'cordep' 'maxd' 'minalt' 'resid' 'maxw' 'maxp' 'ndpths' 'nsal' 'noxy' 'nnut' 'nco2' 'nco2_shore' 'ncfc'};
                varunits={'number' 'seconds' 'seconds' 'seconds' 'degrees' 'degrees' 'metres' 'metres' 'metres' 'metres' 'metres' 'dbar' 'number' 'number' 'number' 'number' 'number' 'number' 'number'};
        end
        %%%%%%%%%% end station_summary %%%%%%%%%%

   %%%%%%%%%% mout_cchdo_ctd %%%%%%%%%%
   case 'mout_cchdo_ctd'
      switch oopt
         case 'expo'
            expocode = '74JC20140606';
            sect_id = 'AR07W/OSNAP_W/AR07E/OSNAP_E/AR28';
	 case 'outfile'
	    outfile = 'ar07_74JC20140606';
	 case 'headstr'
            headstring = ['# The CTD PRS;  TMP;  SAL;  OXY; data are all calibrated and good . '];
      end
   %%%%%%%%%% end mout_cchdo_ctd %%%%%%%%%%

   %%%%%%%%%% mout_cchdo_sam %%%%%%%%%%
   case 'mout_cchdo_sam'
      switch oopt
         case 'expo'
            expocode = '74JC20140606';
            sect_id = 'AR07W/OSNAP_W/AR07E/OSNAP_E/AR28';
	 case 'outfile'
	    outfile = 'ar07_74JC20140606';
      end
   %%%%%%%%%% end mout_cchdo_sam %%%%%%%%%%
   
   %%%%%%%%%% msec_run_mgridp %%%%%%%%%%
   case 'msec_run_mgridp'
      switch oopt
         case 'sections'
            sections = {'osnapwupper' 'osnapwall' 'osnapeupper' 'osnapeall' 'eelupper' 'eelall' 'linebupper' 'lineball' 'linecupper' 'linecall' 'arcupper' 'arcall'};
	 case 'gpars'
            gstart = 10; gstop = 4000; gstep = 20;
	 case 'kstns'
	    switch section
               case {'laball' 'labupper' 'osnapwall' 'osnapwupper'}
                  sstring = '[3:19 21:24 26:28 30:33 36:38 40:43 45 46 47 48 49 50 52 53]';
               case {'arcall' 'arcupper'}
                  sstring = '[54:57 59:62 71:76  100:-1:94]';
               case {'lineball' 'linebupper'}
                  sstring = '[63:70]';
               case {'linecall' 'linecupper'}
                  sstring = '[101:109]';
               case {'osnapeall' 'osnapeupper'}
                  sstring = '[78 77 79 80:94 112:161 199:234]';
               case {'eelall' 'eelupper'}
                  sstring = '[186:192 194:196 185:-1:180 178:-1:161 199:234]';
            end
      end
   %%%%%%%%%% end msec_run_mgridp %%%%%%%%%%


                %%%%%%%%%% m_maptracer %%%%%%%%%%
    case 'm_maptracer'
        switch oopt
            case 'kstatgroups'
                kstatgroups = {[1:19 21:99]};
        end
        %%%%%%%%%% end m_maptracer %%%%%%%%%%


        
end