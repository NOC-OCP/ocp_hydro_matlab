switch scriptname

   %%%%%%%%%% smallscript %%%%%%%%%%
   case 'smallscript'
      switch oopt
         case 'klist'
             klist = [3:150]; %stations 1 and 2 were swivel tests, not CTDs
      end
   %%%%%%%%%% end smallscript %%%%%%%%%%
   
   
   %%%%%%%%%% mbot_00 %%%%%%%%%%
   case 'mbot_00'
      if ismember(stnlocal, 1:12)
         nis = 1:24;
      elseif ismember(stnlocal, 13:32)
         nis = 1:24;
         nis(20) = 25;
      elseif ismember(stnlocal, 33:48)
         nis = 1:24;
         nis([20 13 24]) = [25 24 26];
      elseif ismember(stnlocal, 49:115)
         nis = 1:24;
         nis([20 13 6 23 24]) = [25 24 23 6 26];
      elseif ismember(stnlocal, 116:999)
         nis = 1:24;
         nis([6 13 15 20 23 24])  = [23 24 26 25 6 15];
      end
   %%%%%%%%%% end mbot_00 %%%%%%%%%%

   %%%%%%%%%% mctd_02a %%%%%%%%%%
   case 'mctd_02a'
      switch oopt
         case 'corraw'
	    if ismember(stnlocal, [75 76 77 78 79 80]);
               % for these stations on this cruise we set fluor and trans to
               % absent; also turbidity on dy040; bak 30 dec 2015
               MEXEC_A.MARGS_IN = {infile; 'y'; ...
                  'fluor'; 'y = x+nan'; ' '; ' '; ...
                  'turbidity'; 'y = x+nan'; ' '; ' '; ...
                  'transmittance'; 'y = x+nan'; ' '; ' '; ...
                  ' '};
               mcalib
            end
	    if ismember(stnlocal, [39 51 54 87 91 98]) %stations that need edits before celltm
	       dorangeedit = 1;
               revars = {'press' -100 7000
	              'temp1' 0 40
		      'temp2' 0 40
		      'cond1' 32 60
		      'cond2' 32 60
		      'oxygen_sbe1' 120 260
		      'oxygen_sbe2' 120 260
		      };
               ovars = {'oxygen_sbe1'; 'oxygen_sbe2'};
	    end
        end
   %%%%%%%%%% end mctd_02a %%%%%%%%%%

   %%%%%%%%%% mctd_02b %%%%%%%%%%
   case 'mctd_02b'
      switch oopt
         case 'oxyhyst'
	    var_strings = {'oxygen_sbe1 time press'};
	    pars = [NaN NaN NaN]; %depth-varying parameters are set in mcoxyhyst case
	    varnames = {'oxygen1'};
      end
   %%%%%%%%%% end mctd_02b %%%%%%%%%%

   %%%%%%%%%% mcoxyhyst %%%%%%%%%%
   case 'mcoxyhyst'
      switch sensor
         case 1 % primary, all stations so far
            H1 = -0.045 + zeros(size(D));
            H2 = 5000 + zeros(size(D));
            h3tab = [
	       -10 300
              1000 300
              1001 1000
              2000 1000
              2001 1200
              3000 1200
              3001 2000
              4000 2000
              4001 3500
              5000 3500
              5001 4000
              7000 4000];% final version 18th January 2016 dy040 elm and bak
            H3 = interp1(h3tab(:,1),h3tab(:,2),press);
         case 2 % secondary
            H1 = -0.045 + zeros(size(D));
            H2 = 5000 + zeros(size(D));
            h3tab =[
               -10 300
              1000 300
              1001 900
              2000 900
              2001 2000
              3000 2000
              3001 3000
              4000 3000
              4001 3900
              5000 3900
              7000 5000
              ];% final version 18th January 2016 dy040 elm and bak
            H3 = interp1(h3tab(:,1),h3tab(:,2),press);
      end
   %%%%%%%%%% end mcoxyhyst %%%%%%%%%%

   %%%%%%%%%% mctd_03 %%%%%%%%%%
   case 'mctd_03'
      switch oopt
         case '24hz'
            % pumps tripping out, now fixed more generally in mctd_scanedit
            % called from ctd_all_part1 just after mctd_02a.
            if stn_local == 1
               MEXEC_A.MARGS_IN = {
               infile1
               'y'
               'cond1'
               'cond1 scan'
               'y = x1; kbad = find(x2 >= 73600 & x2 <= 75400); y(kbad) = nan; ' % power loss at bottom of cast; pumps went off;
               ' '
               ' '
               'cond2'
               'cond2 scan'
               'y = x1; kbad = find(x2 >= 73600 & x2 <= 75400); y(kbad) = nan; ' % power loss at bottom of cast
               ' '
               ' '
               'temp1'
               'temp1 scan'
               'y = x1; kbad = find(x2 >= 73600 & x2 <= 75400); y(kbad) = nan; ' % power loss at bottom of cast
               ' '
               ' '
               'temp2'
               'temp2 scan'
               'y = x1; kbad = find(x2 >= 73600 & x2 <= 75400); y(kbad) = nan; ' % power loss at bottom of cast
               ' '
               ' '
               'oxygen1'
               'oxygen1 scan'
               'y = x1; kbad = find(x2 >= 73600 & x2 <= 75400); y(kbad) = nan; ' % power loss at bottom of cast
               ' '
               ' '
               'oxygen2'
               'oxygen2 scan'
               'y = x1; kbad = find(x2 >= 73600 & x2 <= 75400); y(kbad) = nan; ' % power loss at bottom of cast
               ' '
               ' '
               'oxygen_sbe1'
               'oxygen_sbe1 scan'
               'y = x1; kbad = find(x2 >= 73600 & x2 <= 75400); y(kbad) = nan; ' % power loss at bottom of cast
               ' '
               ' '
               'oxygen_sbe2'
               'oxygen_sbe2 scan'
               'y = x1; kbad = find(x2 >= 73600 & x2 <= 75400); y(kbad) = nan; ' % power loss at bottom of cast
               ' '
               ' '
               ' '
               };
               mcalib2
	    end
      end
   %%%%%%%%%% end mctd_03 %%%%%%%%%%

   %%%%%%%%%% mwin_01 %%%%%%%%%%
   case 'mwin_01'
      time_window = [-600 600];
      if stnlocal == 6; time_window = [-600 5400]; end % bak dy040 station 6 CTD file truncated near bottom after lost comms
   %%%%%%%%%% end mwin_01 %%%%%%%%%%

   %%%%%%%%%% mctd_checkplots %%%%%%%%%%
   case 'mctd_checkplots'
      switch oopt
         case 'pf1'
	    pf1.ylist = 'press temp asal oxygen';
	 case 'sdata'
	    sdata1 = d{ks}.asal1; sdata2 = d{ks}.asal2; tis = 'asal'; sdata = d{ks}.asal;
	 case 'odata'
	    odata1 = d{ks}.oxygen;
      end
   %%%%%%%%%% end mctd_checkplots %%%%%%%%%%

   %%%%%%%%%% mctd_rawshow %%%%%%%%%%
   case 'mctd_rawshow'
      switch oopt
	 case 'pshow5'
	    pshow5.ylist = 'temp1 temp2 cond1 cond2 press oxygen';
	 case 'pshow2'
	    pshow2.ylist = 'press oxygen_sbe';
	 case 'pshow4'
	    pshow4 = [];
      end
   %%%%%%%%%% end mctd_rawshow %%%%%%%%%%

   %%%%%%%%%% mctd_rawedit %%%%%%%%%%
   case 'mctd_rawedit'
      switch oopt
         case 'autoeditpars'
            sevars = {'temp1' 'temp2' 'cond1' 'cond2' 'sbeoxyV' 'sbeox1V' 'oxygen_sbe1' 'oxygen_sbe2'};
	    if stnlocal==91 %pumps off for a range of scans
	       doscanedit = 1;
	       sestring = repmat({'y = x1; y(x2>=19540 & x2<=23400) = NaN;'}, length(sevars), 1);
	    elseif stnlocal==87 %CTD landed on bottom
	       doscanedit = 1;
	       sestring = repmat({'y = x1; y(x2>=111527 & x2<=121593) = NaN;'}, length(sevars), 1);
	    elseif stnlocal==39 %pumps off for a range of scans
	       doscanedit = 1;
	       sestring = repmat({'y = x1; y(x2>=23500 & x2<=25300) = NaN;'}, length(sevars), 1);
	    end
	 case 'pshow1'
            pshow1.ylist = 'temp1 temp2 cond1 cond2 press oxygen_sbe';
      end
   %%%%%%%%%% end mctd_rawedit %%%%%%%%%%


   %%%%%%%%%% msal_standardise_avg %%%%%%%%%%
   case 'msal_standardise_avg'
      switch oopt
         case 'cellT'
            g_adj = [ % offset and bath temperature for each range of sample numbers, so the required values can be picked off with interpolation
            %             100 24 0
            %             99999 24 0 % boundaries refined at end of cruise
            100 24 4
            2699 24 4
            2700 24 6
            2999 24 6 
            3000 24 5
            3099 24 5
            3100 24 6
            3199 24 6
            3200 24 5
            3299 24 5
            3300 24 2
            3799 24 2
            3900 24 3
            4099 24 3
            4100 24 4
            4499 24 4
            4500 24 3
            4899 24 3
            4900 24 4
            5799 24 4
            5800 24 5
            6699 24 5
            6700 24 0
            7399 24 0
            7400 24 1
            9199 24 1
            9200 24 2
            11599 24 2
            11600 24 4
            12499 24 4
            12500 24 0
            12799 24 0
            12800 24 -2
            13099 24 -2
            13100 24 -2
            13999 24 -2
            50200 24 2
            50299 24 2
            ];
            % bath temp 24 on dy040. You could set this different for different sampnums within a station
            ds_sal.cellT = interp1(g_adj(:,1), g_adj(:,2), ds_sal.sampnum);
         case 'offset'
     	    ds_sal.offset = interp1(g_adj(:,1), g_adj(:,3), ds_sal.sampnum);
      end
   %%%%%%%%%% end msal_standardise_avg %%%%%%%%%%
   
   %%%%%%%%%% moxy_01 %%%%%%%%%%
   case 'moxy_01'
      switch oopt
         case 'oxycsv'
	    infile = 'ctd/BOTTLE_OXY/log_oxy_jc159_all.txt';
      end
   %%%%%%%%%% end moxy_01 %%%%%%%%%%

   %%%%%%%%%% moxy_ccalc %%%%%%%%%%
   case 'moxy_ccalc'
      switch oopt
         case 'oxypars'
	        lab_temp = 25; % lab temp (deg. C) (an approx average)31
	        vol_reag1 = 1; %vol_reag1 = mean([0.99 0.99 1.00]); %dispenser A (Mn(II)Cl)
	        vol_reag2 = 1; %vol_reag2 = mean([0.99 0.98 0.98 0.98]); %dispenser D
	 case 'blstd'
	    %these could vary by day
	    %dsbs = dataset('File', 'ctd/BOTTLE_OXY/log_oxy_jr17001_blstd.txt', 'Delimiter', ',');
            %d = unique(dsbs.date);
            %[d, ia, ib] = intersect(d, ds_oxy.date);
            %for no = 1:length(d)
            %   ii = find(dsbs.date==d(no));
            %   bl(no) = nanmean(dsbs.blank1(ii) - nanmean([dsbs.blank2(ii) dsbs.blank3(ii)],2));
            %   st(no) = nanmean(dsbs.standard(ii));
            %end
            %for no = 1:length(ds_oxy.date)
            %   ii = find(d==ds_oxy.date(no));
            %   vol_blank(no) = bl(ii);
            %   vol_titre_std(no) = st(ii);
            %end
            %but in this case, with one thiosulfate batch, we use one value (average excluding initial erroneous runs)
            vol_blank = 0.0182;
            vol_titre_std = 0.4573;
         case 'botvols'
            fname_bottle = 'ctd/BOTTLE_OXY/flask_vols.csv';
      end
   %%%%%%%%%% end moxy_01y %%%%%%%%%%

   %%%%%%%%%% mnut_01 %%%%%%%%%%
   case 'mnut_01'
      switch oopt
         case 'vars'
            varnames = {'position','statnum','sampnum','sio4','sio4_flag','po4','po4_flag','no3no2','no3no2_flag','nh4','nh4_flag'};
            varunits = {'number','number','number','umol/l','woceflag','umol/l','woceflag','umol/l','woceflag','umol/l','woceflag'};
	 case 'badvals'
            no3no2(no3no2 == -999) = NaN; % flag is never -999; use 9 for sample not drawn.
            sio4(sio4 == -999) = NaN;
            po4(po4 == -999) = NaN;
            nh4(nh4 == -999) = NaN;
            no3no2 = no3no2*1.06; % adjustment to agree with CRMs
            sio4 = sio4*1.18; % adjustment to agree with CRMs
            po4 = po4*1.01; % adjustment to agree with CRMs
      end
   %%%%%%%%%% end mnut_01 %%%%%%%%%%


   %%%%%%%%%% ctd_evaluate_sensors %%%%%%%%%%
   case 'ctd_evaluate_sensors'
      switch oopt
         case 'csensind'
	    if sensnum==1
               sensind = {find(d.statnum >= 1 & d.statnum <= 999)};   % first psal1
	    elseif sensnum==2
               sensind(1,1) = {find(d.statnum >= 1 & d.statnum <= 37)};   % first psal2
               sensind(2,1) = {find(d.statnum >= 38 & d.statnum <= 999)};   % second psal2
	    end
      end
   %%%%%%%%%% end ctd_evaluate_sensors %%%%%%%%%%

   %%%%%%%%%% temp_apply_cal %%%%%%%%%%
   case 'temp_apply_cal'
      % first temp2 sensor had 0.002 difference with temp1
      % temp2 and cond2 swapped after station 37; secodn temp2 agreed with temp1
      % therefore add 0.002 to temp2 up to and including station 37;
      % this also appeared to move psal2 closer to bottles and closer to psal1, which was further evidence
      % that temp2 had an offset.
      switch sensor
         case 1 % temp1
            tempadj =0; % all stations
            tempout = temp+tempadj;
         case 2 % temp2
            tempadj = nan;
            if stn <= 37
               tempadj = 0.002; % initial temp2 up to stn 37
            end
            if stn >= 38
               tempadj = 0; % next temp2 stns 38 and after
            end
            tempout = temp+tempadj;
         otherwise
            fprintf(2,'%s\n','Should not enter this branch of temp_apply_cal !!!!!')
      end
   %%%%%%%%%% end temp_apply_cal %%%%%%%%%%
   
   %%%%%%%%%% cond_apply_cal %%%%%%%%%%
   case 'cond_apply_cal'
      switch sensor
         case 1
            off1 = interp1([-10 0 1000 2000 4000 4500 5000 8000],[-0.00375 -0.00375 -0.00175 -0.0018 -0.0028 -0.0029 -0.003 -0.003],press);%k11
            fac1 = off1/35 + 1;
            off2 = interp1([-10 0 1000 1500  2000 4000 4500 5000 8000],[0 0 0 +0.0005 0.0005 0 0 0 0],press);% elm and bak 14th January 2016 - refinement to inital cal
            fac2 = off2/35 + 1;
            fac = fac1.*fac2;
	    condadj = 0;
	 case 2
            if ismember(stn, 1:37); %k21
               off1 = interp1([-10 0 1000 2000 4000 5000 8000],[-0.0005 -0.0005 -0.002 -0.0025 -0.004 -0.004 -0.004],press);
               fac = off1/35 + 1;
            elseif ~ismember(stn, 38:999); %k22
               off1 = interp1([-10 0 500 1000 4000 5000 6000 8000],[-0.004 -0.004 -0.005 -0.0025 -0.003 -0.0025 -0.0015 -0.0015],press);%k22
               % sensor 2 has a modest residual (order 0.001) compared with sensor 1
               % and bottles; this is left uncorrected. we regard the
               % primary S as the data to be reported. bak and elm 14
               % jan 2016 after examining stations up to 120.
               fac = off1/35 + 1;
            end
            condadj = 0;
         end
         condout = cond.*fac;
         condout = condout+condadj;
   %%%%%%%%%% end cond_apply_cal %%%%%%%%%%

   %%%%%%%%%% oxy_apply_cal %%%%%%%%%%
   case 'oxy_apply_cal'
      switch sensor
         case 1 % primary sensor calibration to stn 58
	    sens1_param_x = [-10 0 1000 2000 3000 4000 5000 8000];
            sens1_param_y = [1.055 1.055 1.057 1.069 1.077 1.083 1.09 1.09];
            sens1_cor = interp1(sens1_param_x,sens1_param_y,press);
            %refined calibration after improved hysteresis and revised
            %oxygen bottles; worked out after station 137. 19 jan 2016.
            [fac1_x,fac1_y] = meshgrid([1 20 40 60 90 150],[-10 500 1500 3500 7000]);
            fac1_z =[
                    0.991    1.000    1.000    1.000     1.014    1.020
                    0.991    1.000    1.000    1.000     1.014    1.020
                    0.991    0.999    0.999    1.005     1.013    1.018
                    0.998    0.998    0.998    1.001     1.008    1.013
                    0.992    0.996    1.001    1.001     1.006    1.006
                    ];
            corr_fac1 = nan(size(press));
            Igd = find(~isnan(press));
            corr_fac1(Igd) = interp2(fac1_x,fac1_y,fac1_z,stn,press(Igd));
            oxyout = oxyin.*sens1_cor.*corr_fac1;
        case 2 % secondary sensor calibration to stn 58
            sens2_param_x = [-10 0 1000 2000 3000 4000 5000 8000];
            sens2_param_y = [1.07 1.07 1.067 1.08 1.091 1.101 1.11 1.11];
            sens2_cor = interp1(sens2_param_x,sens2_param_y,press);
            %refined calibration after improved hysteresis and revised
            %oxygen bottles; worked out after station 137. 19 jan 2016.
            [fac2_x,fac2_y] = meshgrid([1 20 40 60 90 150],[-10 500 1500 3500 7000]);
            fac2_z =[
                    0.993    1.000    1.000     1.000    1.012    1.019
                    0.993    1.000    1.000     1.000    1.012    1.019
                    0.993    1.002    1.002     1.005    1.012    1.017
                    1.000    1.000    1.000     1.001    1.007    1.012
                    1.000    1.000    1.000     1.001    1.003    1.003
		    ];
            corr_fac2 = nan(size(press));
            Igd = find(~isnan(press));
            corr_fac2(Igd) = interp2(fac2_x,fac2_y,fac2_z,stn,press(Igd));
            oxyout = oxyin.*sens2_cor.*corr_fac2;
      end
   %%%%%%%%%% end oxy_apply_cal %%%%%%%%%%


   %%%%%%%%%% populate_station_depths %%%%%%%%%%
   case 'populate_station_depths'
      switch oopt
         case 'bestdeps'
            bestdeps(2) = 43; % shallow cast, no LADCP;  depth from CTD+altimeter
            bestdeps(3) = 100; % shallow cast, no LADCP;  depth from CTD+altimeter
            bestdeps(4) = 144; % shallow cast, no LADCP;  depth from CTD+altimeter
            bestdeps(6) = 387; % shallow cast, no LADCP;  depth from CTD+altimeter
            bestdeps(10) = 758; % no LADCP in rosette;  depth from CTD+altimeter
            bestdeps(22) = 687; % shallow cast, no LADCP;  depth from CTD+altimeter
            bestdeps(23) = 618; % shallow cast, no LADCP;  depth from CTD+altimeter
            bestdeps(24) = 484; % shallow cast, no LADCP;  depth from CTD+altimeter
            bestdeps(26) = 1268; % LADCP failed to detect bottom; depth from CTD+altimeter
            bestdeps(75) = 6117; % depth > 6000m no LADCP;  depth from CTD+altimeter
            bestdeps(76) = 5972; % depth > 6000m no LADCP;  depth from CTD+altimeter
            bestdeps(77) = 6465; % depth > 6000m no LADCP;  depth from CTD+altimeter
            bestdeps(78) = 6011; % depth > 6000m no LADCP;  depth from CTD+altimeter
            bestdeps(79) = 5256; % depth > 6000m no LADCP;  depth from CTD+altimeter
            bestdeps(80) = 5832; % depth > 6000m no LADCP;  depth from CTD+altimeter
            bestdeps(84) = 4933; % LADCP failed to detect bottom; depth from CTD+altimeter
            bestdeps(91) = 2908; % LADCP failed to detect bottom; depth from CTD+altimeter
            bestdeps(101) = 5219; % unclear bottom on ea640; depth from em122
            bestdeps(110) = 6340; % depth > 6000; CTD stopped at 6000; depth from ea640/em122
            bestdeps(123) = 5295; % CFC bottle blank; stopped 200 off; depth from ea640/em122
      end	    
   %%%%%%%%%% end populate_station_depths %%%%%%%%%%
   
   %%%%%%%%%% list_bot %%%%%%%%%%
   case 'list_bot'
      switch oopt
         case 'samadj'
            %dsam.uoxygen = 1.12*dsam.uoxygen + dsam.upress*7/3000; % nominal cal stns 1 and 2
            dsam.cruise = 040 + zeros(size(dsam.sampnum));
            gamn = gamma_n(dsam.upsal,dsam.utemp,dsam.upress,hctd.longitude,hctd.latitude);
            dsam.ugamma_n = gamn;
            hsam.fldnam = [hsam.fldnam {'cruise' 'lon' 'lat' 'bottom_dep' 'udepth' 'usig0' 'ugamma_n'}];
            hsam.fldunt = [hsam.fldunt {'number' 'degreesE' 'degreesN' 'metres' 'metres' 'kg/m3' 'gamma'}];
	 case 'printmsg'
            %msg = [datestr(now,31) ' dy040 CTD PSAL and Oxygen data uncalibrated' ];
            %msg = [datestr(now,31) ' dy040 CTD PSAL and Oxygen data preliminary calibration' ]; %dy040 elm 26 Dec 2015
            msg = [datestr(now,31) ' dy040 CTD PSAL and Oxygen data final end of cruise calibration' ]; %dy040 elm 20 jan 2016 oxy data up to 139; salts up to 135
            fprintf(1,'%s\n',msg);
            fprintf(fidout,'%s\n',msg);
      end
   %%%%%%%%%% end list_bot %%%%%%%%%%


   %%%%%%%%%% msim_plot %%%%%%%%%%
   case 'msim_plot'
      switch oopt
         case 'sbathy'
	        file = '/local/users/pstar/cruise/data/topo/n_atlantic';
      end
   %%%%%%%%%% end msim_plot %%%%%%%%%%

   %%%%%%%%%% mem120_plot %%%%%%%%%%
   case 'mem120_plot'
      switch oopt
         case 'sbathy'
	        bfile = '/local/users/pstar/cruise/data/topo/n_atlantic';
      end
   %%%%%%%%%% end mem120_plot %%%%%%%%%%

   %%%%%%%%%% mtsg_01 %%%%%%%%%%
   case 'mtsg_01'
      switch oopt
         case 'salcsv'
	    sal_csv_file = ['tsg_dy040_' stn_string '.csv_linux'];
	 case 'cellT'
	    ds_sal.cellT = 24+zeros(length(ds_sal.station_day),1);
	 case 'offset'
	     g_adj = [ % offset and bath temperature for each crate
                     1 24 4
                     2 24 3
                     3 24 4
                     4 24 0
                     5 24 1
                     6 24 2
                     7 24 2
                     8 24 4
                     9 24 -2
                     10 24 -2
                     99999 24 -2
                     ];
            offset = interp1(g_adj(:,1),g_adj(:,3),ds_sal.station_day); %***should be crate
      end
   %%%%%%%%%% end mtsg_01 %%%%%%%%%%
   

   %%%%%%%%%% mtsg_bottle_compare %%%%%%%%%%
   case 'mtsg_bottle_compare'
      switch oopt
         case 'dbbad'
	    db.salinity_adj(17) = NaN; %bad comparison point
	    db.salinity_adj(43) = NaN; %bad comparison point
	 case 'sdiff'
            % introduce break point at day 350 when the TSG was cleaned
            idx1=db.decday<350;
            idx2=db.decday>=350;
            sdiffsm = nan(size(sdiff));
            res = nan(size(sdiff));
            % correction for data prior to day 350
            sdiffsm(idx1) = filter_bak_median(21,sdiff(idx1)); % first filter
            res(idx1) = sdiff(idx1) - sdiffsm(idx1);
            sdiff(idx1 & abs(res) > 0.02) = nan;
            sdiffsm(idx1) = filter_bak_median(41,sdiff(idx1)); % second filter
            res(idx1) = sdiff(idx1) - sdiffsm(idx1);
            % correction for data after day 350
            sdiffsm(idx2) = filter_bak_median(21,sdiff(idx2)); % first filter
            res(idx2) = sdiff(idx2) - sdiffsm(idx2);
            sdiff(idx2 & abs(res) > 0.02) = nan;
            sdiffsm(idx2) = filter_bak_median(41,sdiff(idx2)); % second filter
            res(idx2) = sdiff(idx2) - sdiffsm(idx2);
      end
   %%%%%%%%%% end mtsg_bottle_compare %%%%%%%%%%

   %%%%%%%%%% mtsg_cleanup %%%%%%%%%%
   case 'mtsg_cleanup'
      switch oopt
         case 'kbadlims' %times when pumps off
            kbadlims = [
%              datenum([2013 01 01 00 00 00]) datenum([2013 03 18 14 51 00]) % start of cruise
               datenum([]) datenum([])
            ];
            end
      end
   %%%%%%%%%% end mtsg_cleanup %%%%%%%%%%

   %%%%%%%%%% tsgsal_apply_cal %%%%%%%%%%
   case 'tsgsal_apply_cal'
      switch oopt
         case 'saladj'
	    % simple offset so far
            botfile = ['met_tsg_' MEXEC_G.MSCRIPT_CRUISE_STRING '_01_medav_clean_botcompare']; 
            MARGS_STORE = MEXEC_A.MARGS_IN_LOCAL;
            [db hb] = mload(botfile,'/');
            MEXEC_A.MARGS_IN_LOCAL = MARGS_STORE; % put things back how they were !
            % determine dates
    	    db.dn = datenum(hb.data_time_origin)+db.time/86400;
            dv = datevec(db.dn(1));
            decday = db.dn-datenum([dv(1) 1 1 0 0 0]);
            % same code as used to generate smoothed adjustment in mtsg_bottle_compare
            sdiff = db.salinity_adj-db.salin;
            % introduce break point at day 350 when the TSG was cleaned
            idx1=decday<350;
            idx2=decday>=350;
            sdiffsm = nan(size(sdiff));
            res = nan(size(sdiff));
            % now determine corrections, not in a loop so different filters can
            % potentially be applied to each section
            % correction for data prior to day 350
            %sdiffsm(idx1) = filter_bak(ones(1,21),sdiff(idx1)); % first filter
            sdiffsm(idx1) = filter_bak_median(21,sdiff(idx1)); % first filter
            res(idx1) = sdiff(idx1) - sdiffsm(idx1);
            sdiff(idx1 & abs(res) > 0.02) = nan;
            %sdiffsm(idx1) = filter_bak(ones(1,21),sdiff(idx1)); % second filter
            sdiffsm(idx1) = filter_bak_median(41,sdiff(idx1)); % second filter
            res(idx1) = sdiff(idx1) - sdiffsm(idx1);
            % correction for data after day 350
            %sdiffsm(idx2) = filter_bak(ones(1,21),sdiff(idx2)); % first filter
            sdiffsm(idx2) = filter_bak_median(21,sdiff(idx2)); % first filter
            res(idx2) = sdiff(idx2) - sdiffsm(idx2);
            sdiff(idx2 & abs(res) > 0.02) = nan;
            %sdiffsm(idx2) = filter_bak(ones(1,41),sdiff(idx2)); % second filter
            sdiffsm(idx2) = filter_bak_median(41,sdiff(idx2)); % second filter
            res(idx2) = sdiff(idx2) - sdiffsm(idx2);
            adj = interp1([0 db.dn(:)' 1e10],[sdiffsm(1) sdiffsm(:)' sdiffsm(end)],dn); % extrapolate correction
            salout = salin+adj;
      end
%%%%%%%%%% end tsgsal_apply_cal %%%%%%%%%%


   %%%%%%%%%% mout_cchdo_sam %%%%%%%%%%
   case 'mout_cchdo_sam'
      switch oopt
         case 'expo'
	    expocode = '74EQ20151206';
            sect_id = 'A05';
	 case 'outfile'
	    outfile = [MEXEC_G.MEXEC_DATA_ROOT '/collected_files/a05_' expocode];
	 case 'headstr'
            headstring = {['BOTTLE,' datestr(now,'yyyymmdd') 'OCPNOCBAK'];...
	    '#SHIP: Discovery';...
	    '#Cruise DY040; A05';...
	    '#Region: North Atlantic';...
	    ['#EXPOCODE: ' expocode];...
	    '#Chief Scientist: B. King, NOC';...
	    '#These data should be acknowledged with: "Data were collected and made publicly available by the International Global Ship-based Hydrographic Investigations Program (GO-SHIP; http://www.go-ship.org/) with funding from the UK Natural Environment Research Council to the National Oceanography Centre."'};
      end
   %%%%%%%%%% end mout_cchdo_sam %%%%%%%%%%

   %%%%%%%%%% mout_cchdo_ctd %%%%%%%%%%
   case 'mout_cchdo_ctd'
      switch oopt
         case 'expo'
	    expocode = '74EQ20151206';
            sect_id = 'A05';
	 case 'outfile'
	    outfile = [MEXEC_G.MEXEC_DATA_ROOT '/collected_files/a05_' expocode];
	 case 'headstr'
	    headstring = {['CTD,' datestr(now,'yyyymmdd') 'OCPNOCBAK'];...
	    '#SHIP: Discovery';...
	    '#Cruise DY040; A05';...
	    '#Region: North Atlantic';...
	    ['#EXPOCODE: ' expocode];...
	    '#Chief Scientist: B. King, NOC';...
   	    '#These data should be acknowledged with: "Data were collected and made publicly available by the International Global Ship-based Hydrographic Investigations Program (GO-SHIP; http://www.go-ship.org/) with funding from the UK Natural Environment Research Council to the National Oceanography Centre."'};
      end
   %%%%%%%%%% end mout_cchdo_ctd %%%%%%%%%%

   %%%%%%%%%% msec_run_mgridp %%%%%%%%%%
   case 'msec_run_mgridp'
      switch oopt
         case 'sections'
            sections = {'fs27n' 'fs27n2' '24n'};
	 case 'gpars'
            gstart = 10; gstop = 4000; gstep = 20; % dy040
	 case 'kstns'
	    switch section
	       case 'fs72n'
	          sstring = '[2:5 7:15]';
	       case 'fs72n2'
	          sstring = '16:24';
	       case '24n'
	          sstring = '[25:37 39:62 64:122 124:145]'; %38 is repeat; 63 &123 are CFC bottle blank
            end
	 case 'varuse'
            %varuselist.names = {'botoxy' 'totnit' 'phos' 'silc' 'dic' 'alk' 'cfc11'  'cfc12' 'f113' 'sf6' 'ccl4'};
            varuselist.names = {'botoxy' 'totnit' 'phos' 'silc' 'dic' 'alk'};
      end
   %%%%%%%%%% end msec_run_mgridp %%%%%%%%%%


   %%%%%%%%%% vmadcp_proc %%%%%%%%%%
   case 'vmadcp_proc'
      switch oopt
         case 'aa0_75' %set approximate/nominal instrument angle and amplitude
            ang = -10.0; amp = 1; 
         case 'aa0_150' %set approximate/nominal instrument angle and amplitude
            ang = -1.3; amp = 1;  %-1.3            ang = 0;
	    %if seq<6; ang = -0.2; else; ang = -0.1; end
	    amp = 1; 
         case 'aa150' %refined additional rotation and amplitude corrections based on btm/watertrk
            ang = 0;
	    amp = 1; 
      end
   %%%%%%%%%% end vmadpc_proc %%%%%%%%%%


end
