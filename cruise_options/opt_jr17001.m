switch scriptname

   %%%%%%%%%% ctd_evaluate_sensors %%%%%%%%%%
   case 'ctd_evaluate_sensors'
      switch oopt
         case {'tsensind','csensind','osensind'}
	        sensind = {find(d.statnum >= 1 & d.statnum <= 999)};
      end
   %%%%%%%%%% end ctd_evaluate_oxygen %%%%%%%%%%

   %%%%%%%%%% temp_apply_cal %%%%%%%%%%
   case 'temp_apply_cal'
      switch sensor
         case 1
	    tempadj = 4.41e-3 - 1.3e-4*stn;
	    tempout = temp+tempadj;
	 case 2
	    tempadj = 6.86e-3 - 1.9e-4*stn;
	    tempout = temp+tempadj;
      end
   %%%%%%%%%% end temp_apply_cal %%%%%%%%%%
   
   %%%%%%%%%% cond_apply_cal %%%%%%%%%%
   case 'cond_apply_cal'
      switch sensor
         case 1
	       off = interp1([0 700 5000], [0.001 -0.0005 -0.001], press) + 7e-3 -3e-4*stn;
	       fac = off/35 + 1;
	       condadj = 0;
	 case 2
	    off = interp1([0 400 5000], [0.0005 0.001 -0.001], press) + 2.5e-3 -1e-4*stn;
	    fac = off/35 + 1;
	    condadj = 0;
      end
      condout = cond.*fac;
      condout = condout+condadj;
   %%%%%%%%%% end cond_apply_cal %%%%%%%%%%

   %%%%%%%%%% oxy_apply_cal %%%%%%%%%%
   case 'oxy_apply_cal'
      alpha = 1.05 + 4.4e-4*stn; 
      beta = -0.15 + 17e-4*press;
      oxyout = alpha.*oxyin + beta;
% %%oxyout = (oxyin - beta)./alpha; %use this line to undo the one above
   %%%%%%%%%% end oxy_apply_cal %%%%%%%%%%
   

   %%%%%%%%%% populate_station_depths %%%%%%%%%%
   case 'populate_station_depths'
      switch oopt
        case 'fnin'
           depmeth = 3;
	 case 'bestdeps'
         bestdeps(13,2) = 3707;
         bestdeps(14,2) = 3763;
         bestdeps(15,2) = 3719;
         bestdeps(16,2) = 3706;
         bestdeps(17,2) = 3548;
         bestdeps(18,2) = 3194;
      end
   %%%%%%%%%% end populate_station_depths %%%%%%%%%%

   %%%%%%%%%% mbot_01 %%%%%%%%%%
   case 'mbot_01'
      switch oopt
         case 'infile'
	  %  infile = [root_botcnv '/log_samp_jr16002_all.txt'];
         case 'botflags'
      %      bottle_qc_flag(isnan(ds_sample.oxy_bot) & isnan(ds_sample.d18O_bot) & strcmp('NaN',ds_sample.sal_bot)) = 9;
      end
   %%%%%%%%%% end mbot_01 %%%%%%%%%%


   %%%%%%%%%% mout_cchdo_sam %%%%%%%%%%
   case 'mout_cchdo_sam'
      switch oopt
         case 'expo'
	    expocode = '74JC20171121';
            sect_id = 'SR1b';
	 case 'outfile'
	    outfile = [MEXEC_G.MEXEC_DATA_ROOT '/collected_files/sr1b_' expocode '_ct1/sr1b_' expocode];
	 case 'headstr'
            headstring = {['BOTTLE,' datestr(now,'yyyymmdd') 'OCPNOCYLF'];...
	    '#SHIP: James Clark Ross';...
	    '#Cruise JR17001; SR1B';...
	    '#Region: Western Antarctic Peninsula and Drake Passage';...
	    ['#EXPOCODE: ' expocode];...
	    '#DATES: 20171121 - 20161221';...
	    '#Chief Scientist: D. Barnes, BAS';...
	    '#Supported by NERC National Capability NE/N018095/1 (ORCHESTRA) and NERC/CONICYT NE/P003087/1 (ICEBERGS)';...
	    '#44 stations with 24-place rosette';...
	    '#CTD: Who - Y. Firing; Status - final';...
	    '#Notes: Includes CTDSAL, CTDOXY, SBE35';...
	    '#The CTD PRS;  TMP;  SAL; OXY data are all calibrated and good.';...
	    '#Flags in bottle file set to good for all existing values';...
	    '#CTD files also contain CTDXMISS, CTDFLUOR';...
	    '#Salinity: Who - Y. Firing; Status - final';...
	    '#Notes:';...
	    '#Oxygen: Who - Y. Firing; Status - final';...
	    '#Notes:';...
	    '#These data should be acknowledged with: "Data were collected and made publicly available by the International Global Ship-based Hydrographic Investigations Program (GO-SHIP; http://www.go-ship.org/) with National Capability funding from the UK Natural Environment Research Council to the National Oceanography Centre."'};
      end
   %%%%%%%%%% end mout_cchdo_sam %%%%%%%%%%

   %%%%%%%%%% mout_cchdo_ctd %%%%%%%%%%
   case 'mout_cchdo_ctd'
      switch oopt
         case 'expo'
	        expocode = '74JC20171121';
            sect_id = 'SR1b';
	 case 'outfile'
	    outfile = [MEXEC_G.MEXEC_DATA_ROOT '/collected_files/sr1b_' expocode];
	 case 'headstr'
	    headstring = {['CTD,' datestr(now,'yyyymmdd') 'OCPNOCYLF'];...
	    '#SHIP: James Clark Ross';...
	    '#Cruise JR17001; SR1B';...
	    '#Region: Western Antarctic Peninsula and Drake Passage';...
	    ['#EXPOCODE: ' expocode];...
	    '#DATES: 20171121 - 20161221';...
	    '#Chief Scientist: D. Barnes, BAS';...
	    '#Supported by NERC National Capability NE/N018095/1 (ORCHESTRA) and NERC/CONICYT NE/P003087/1 (ICEBERGS)';...
	    '#44 stations with 24-place rosette';...
	    '#CTD: Who - Y. Firing; Status - final';...
	    '#Notes: Includes CTDSAL, CTDOXY, SBE35';...
	    '#The CTD PRS;  TMP;  SAL; OXY data are all calibrated and good.';...
	    '# DEPTH_TYPE   : COR';...
   	    '#These data should be acknowledged with: "Data were collected and made publicly available by the International Global Ship-based Hydrographic Investigations Program (GO-SHIP; http://www.go-ship.org/) with National Capability funding from the UK Natural Environment Research Council to the National Oceanography Centre."'};
      end
   %%%%%%%%%% end mout_cchdo_ctd %%%%%%%%%%


   %%%%%%%%%% mctd_rawedit %%%%%%%%%%
   case 'mctd_rawedit'
      switch oopt
         case 'autoeditpars'
            if stnlocal == 1
	       doscanedit = 1;
	       sevars = {'cond2'};
               sestring = {'y = x1; y(x2 >= 6070 & x2 <=8500) = NaN;'};
            elseif stnlocal == 13
	       doscanedit = 1;
               sevars = {'cond2'};
               sestring = {'y = x1; y(x2 >= 3e4 & x2 <= 5.9e4) = NaN;'};
           end
      end
   %%%%%%%%%% end mctd_rawedit %%%%%%%%%%


   %%%%%%%%%% moxy_01 %%%%%%%%%%
   case 'moxy_01'
      switch oopt
         case 'oxycsv'
	    infile = 'ctd/BOTTLE_OXY/log_oxy_jr17001_all.txt';
	  case 'flags'
          if stnlocal==14; botoxyflaga(2) = 3; botoxyflagb(2) = 3; %duplicate values very close but also very much larger than ctd value; suspect bad niskin
          elseif stnlocal==29; botoxyflaga(1) = 3;
          elseif stnlocal==31; botoxyflaga(4) = 3;
          elseif stnlocal==10; botoxyflaga(14) = 3;
          elseif stnlocal==19; botoxyflaga(6) = 3;
          %below bottles had possible miniscule bubble, but readings look fine
          %elseif stnlocal==7; botoxyflaga(14) = 3; 
          %elseif stnlocal==29; botoxyflaga([5 11]) = 3; 
          %elseif stnlocal==33; botoxyflagb(9) = 3;
          %elseif stnlocal==34; botoxyflaga(24) = 3;
          %elseif stnlocal==38; botoxyflaga(21) = 3;
          %elseif stnlocal==39; botoxyflaga(14) = 3;
          %elseif stnlocal==42; botoxyflaga(2) = 3;
          end
      end
   %%%%%%%%%% end moxy_01 %%%%%%%%%%

   %%%%%%%%%% moxy_ccalc %%%%%%%%%%
   case 'moxy_ccalc'
      switch oopt
         case 'oxypars'
	    lab_temp = 21; % lab temp (deg. C) (an approx average)31
	    vol_reag1 = mean([0.99 0.99 1.00]); %dispenser A (Mn(II)Cl)
	    vol_reag2 = mean([0.99 0.98 0.98 0.98]); %dispenser D
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
            vol_titre_std = 0.9097;
         case 'botvols'
            fname_bottle = 'ctd/BOTTLE_OXY/flask_vols.csv';
            ds_bottle = dataset('File', fname_bottle, 'Delimiter', ',');
            mb = max(ds_bottle.bot_num); a = NaN+zeros(mb, 1);
            a(ds_bottle.bot_num) = ds_bottle.bot_vol;
            obot_vol = a(ds_oxy.oxy_bot); %mL
      end
   %%%%%%%%%% end moxy_01y %%%%%%%%%%


   %%%%%%%%%% msal_01 %%%%%%%%%%
   case 'msal_01'
      switch oopt
          case 'flag'
              if stnlocal==14
                  flag(position==2) = 3;
              elseif stnlocal==17
                  flag(position==1) = 3;
              elseif stnlocal==22
                  flag(position==6) = 3;
              elseif stnlocal==30
                  flag(position==10) = 3;
              end
      end
   %%%%%%%%%% end msal_01 %%%%%%%%%%


   %%%%%%%%%% msal_standardise_avg %%%%%%%%%%
   case 'msal_standardise_avg'
      switch oopt
         case 'salcsv'
	        sal_csv_file = 'log_sal_jr17001_all.txt';
         case 'cellT'
            ds_sal.cellT = 24+zeros(length(ds_sal.station_day),1);
         case 'std2use'
            std2use([1 3 17],1) = 0;
            std2use([6],3) = 0;
            doplot = 0;
         case 'sam2use'
            sam2use([24 228 339], 1) = 0;
            sam2use([21], 2) = 0;
            sam2use([212], 3) = 0;
	        doplot = 0;
      end
   %%%%%%%%%% end msal_standardise_avg %%%%%%%%%%


   %%%%%%%%%% msbe35_01 %%%%%%%%%%
   case 'msbe35_01'
      switch oopt
  %       case 'flag'
  %          % these might have been closed too quickly for a good reading
   %         sbe35flag(isnan(sbe35temp)) = 9;
    %        if stnlocal==22
     %           sbe35flag(position == 9) = 4;
      %      end
       %     if stnlocal == 24
        %        sbe35flag(position == 6 | position ==9) = 4;
         %   end
      end
   %%%%%%%%%% end msbe35_01 %%%%%%%%%%
   

   %%%%%%%%%% mtsg_cleanup %%%%%%%%%%
   case 'mtsg_cleanup'
      switch oopt
         case 'kbadlims'
	        kbadlims = [
             datenum([2017 11 18 00 00 00]) datenum([2017 11 21 22 45 00]) % start of cruise
             datenum([2017 11 27 05 48 00]) datenum([2017 11 27 10 58 00]) % rough weather
             datenum([2017 11 27 14 05 00]) datenum([2017 11 27 16 05 00]) % rough weather
             datenum([2017 11 29 05 56 00]) datenum([2017 11 29 10 59 00])
             datenum([2017 11 29 14 07 00]) datenum([2017 11 29 16 08 00])
             datenum([2017 12 02 00 33 00]) datenum([2017 12 09 11 17 00]) % sea ice
             datenum([2017 12 09 21 18 00]) datenum([2017 12 10 19 02 00]) % sea ice
             datenum([2017 12 11 21 24 00]) datenum([2017 12 12 19 12 00])
             datenum([2017 12 16 14 01 00]) datenum([2017 12 16 16 44 00]) 
             datenum([2017 12 17 14 00 00]) datenum([2017 12 17 00 34 00]) 
             datenum([2017 12 19 15 24 00]) datenum([2017 12 22 00 00 00]) %end of cruise
            ];
      end
   %%%%%%%%%% end mtsg_cleanup %%%%%%%%%%


   %%%%%%%%%% tsgsal_apply_cal %%%%%%%%%%
    case 'tsgsal_apply_cal'
       switch oopt
          case 'saladj'
             off = -0.0031;
             salout = salin+off;
      end
   %%%%%%%%%% end tsgsal_apply_cal %%%%%%%%%%


   %%%%%%%%%% smallscript %%%%%%%%%%
   case 'smallscript'
      switch oopt
         case 'klist'
	    klist = [1:7 9:44];
      end
   %%%%%%%%%% end smallscript %%%%%%%%%%


   %%%%%%%%%% station_summary %%%%%%%%%%
   case 'station_summary'
      switch oopt
     	 case 'comments'
            comments = cell(44,1);
            comments{1} = 'test';
            comments([2:7 9:14]) = {'ICEBERGS'};
            comments(15:18) = {'ORCHESTRA gliders'};
            comments(19:24) = {'MT'};
            comments(25:44) = {'ORCHESTRA SR1b'};
         case 'optsams'
	        snames = {'noxy'}; sgrps = {'oxy' 'botoxya'}; sashore = 0;
      end
   %%%%%%%%%% end station_summary %%%%%%%%%%


end
