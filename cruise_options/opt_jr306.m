switch scriptname

   %%%%%%%%%% mctd_senscal %%%%%%%%%%
   case 'mctd_senscal'
       switch oopt
           case 'condcal'
               if senslocal==1
                   calvars = {'cond1'};
                   calstr = '%s = %s.*(1-0.0007/35);';
                   calmsg = 'cond1 jr306';
               elseif senslocal==2
                   calvars = {'cond2' 'press'};
                   calstr = '%s = %s.*(1+(interp1([-10 0 3500 8000],[0.0020 0.0020  0.0005 0.0005],%s)-0.0007)/35);';
                   calmsg = 'cond2 jr306';
               end
      end
   %%%%%%%%%% end cond_apply_cal %%%%%%%%%%


   %%%%%%%%%% ctd_evaluate_sensors %%%%%%%%%%
   case 'ctd_evaluate_sensors'
      switch oopt
         case {'tsensind','csensind'}
	    sensind = {find(d.statnum>=1 & d.statnum<=999)};
      end
   %%%%%%%%%% end ctd_evaluate_sensors %%%%%%%%%%


   %%%%%%%%%% mout_cchdo_sam %%%%%%%%%%
   case 'mout_cchdo_sam'
      switch oopt
         case 'expo'
	    expocode = '74JC20150110';
            sect_id = 'SR1b';
         case 'outfile'
	    outfile = [MEXEC_G.MEXEC_DATA_ROOT '/collected_files/sr1b_' expocode];
	 case 'headstr'
            headstring = {['BOTTLE,' datestr(now,'yyyymmdd') 'OCPNOCYLF'];...
	    '#SHIP: James Clark Ross';...
	    '#Cruise JR306; SR1B';...
	    '#Region: Drake Passage; ~56W';...
	    ['#EXPOCODE: ' expocode];...
	    '#DATES: 20150110 - 20150120';...
	    '#Chief Scientist: B. King, NOCS';...
	    '#Supported by NERC National Capability';...
	    '#30 stations with 24-place rosette';...
	    '#CTD: Who - Y. Firing; Status - final';...
	    '#Notes: Includes CTDSAL, SBE35';...
	    '#The CTD PRS;  TMP;  SAL data are all calibrated and good.';...
	    '#Flags in bottle file set to good for all existing values';...
	    '#CTD files also contain CTDOXY, CTDXMISS, CTDFLUOR, CTDTURB';...
	    '#Salinity: Who - Y. Firing; Status - final';...
	    '#Notes:';...
	    '#These data should be acknowledged with: "Data were collected and made publicly available by the International Global Ship-based Hydrographic Investigations Program (GO-SHIP; http://www.go-ship.org/) with National Capability funding from the UK Natural Environment Research Council to the National Oceanography Centre."'};
      end
   %%%%%%%%%% end mout_cchdo_sam %%%%%%%%%%


   %%%%%%%%%% mout_cchdo_ctd %%%%%%%%%%
   case 'mout_cchdo_ctd'
      switch oopt
         case 'expo'
	    expocode = '74JC20150110';
            sect_id = 'SR1b';
         case 'outfile'
	    outfile = [MEXEC_G.MEXEC_DATA_ROOT '/collected_files/sr1b_' expocode '_ct1/sr1b_' expocode];
	 case 'headstr'
	    headstring = {['CTD,' datestr(now,'yyyymmdd') 'OCPNOCYLF'];...
	    '#SHIP: James Clark Ross';...
	    '#Cruise JR306; SR1B';...
	    '#Region: Drake Passage; ~56W';...
	    ['#EXPOCODE: ' expocode];...
	    '#DATES: 20150110 - 20150120';...
	    '#Chief Scientist: B. King, NOCS';...
	    '#Supported by NERC National Capability';...
	    '#30 stations with 24-place rosette';...
	    '#CTD: Who - Y. Firing; Status - final';...
	    '#Notes: The CTD PRS;  TMP;  SAL; data are all calibrated and good.';...
	    '# DEPTH_TYPE   : COR';...
    	    '#These data should be acknowledged with: "Data were collected and made publicly available by the International Global Ship-based Hydrographic Investigations Program (GO-SHIP; http://www.go-ship.org/) with National Capability funding from the UK Natural Environment Research Council to the National Oceanography Centre."'};
      end
   %%%%%%%%%% end mout_cchdo_ctd %%%%%%%%%%


   %%%%%%%%%% msal_standardise_avg %%%%%%%%%%
   case 'msal_standardise_avg'
      switch oopt
         case 'cellT'
	    ds_sal.cellT = repmat(24, size(ds_sal.station_day,1), 1);
	 case 'offset'
            g_adj = [ % offset (value to be added to guildline reading) for each range of sample numbers, so the required values can be picked off with interpolation
            100 -5
            599 -5
            600 -10
            1099 -10
            1100 -13
            1299 -13
            1300 -8
            1699 -8
            1700 -5
            1799 -5
            1800 -7
            1899 -7
            1900 -10
            1999 -10
            2000 -12
            2099 -12
            2100 -13
            2199 -13
            2200 -10
            2299 -10
            2300 -9
            2499 -9
            2500 -11
            2799 -11
            2800 -7
            3099 -7
            99999 -7
            ];
	    ds_sal.offset = interp1(g_adj(:,1), g_adj(:,2), ds_sal.sampnum);
      end
   %%%%%%%%%% end msal_standardise_avg %%%%%%%%%%

   %%%%%%%%%% msbe35_01 %%%%%%%%%%
   case 'msbe35_01'
      switch oopt
         case 'sbe35flag'
            % bottles not used for salinity samples closed on the fly in
            % quick succession
            if stnlocal == 3
                sbe35flag(position >= 11) = 4;
                sbe35flag(isnan(sbe35temp)) = 9;
            end
            if stnlocal == 7
                sbe35flag(position >= 11) = 4;
                sbe35flag(isnan(sbe35temp)) = 9;
            end
      end
   %%%%%%%%%% end msbe35_01 %%%%%%%%%%
   

   %%%%%%%%%% mtsg_01 %%%%%%%%%%
   case 'mtsg_01'
      bath_temperature = nan(size(index));
      adj = bath_temperature;
      g_adj = [ % offset and bath temperature for each crate, so the required values can be picked off with interpolation
          % this could be adapted to work on specific times, if you
          % wanted a different adjustment within a crate.
          1 24 -10
          2 24 -9
          99999 24 -13
          ];
      % bath temp 24 on jr306. You could set this different for different sampnums within a station
      for k = 1:length(index)
         bath_temperature(k) = interp1(g_adj(:,1),g_adj(:,2),stn); %  stn is crate number in this script
         adj(k) = interp1(g_adj(:,1),g_adj(:,3),stn);
      end
   %%%%%%%%%% mtsg_01 %%%%%%%%%%


   %%%%%%%%%% mtsg_cleanup %%%%%%%%%%
   case 'mtsg_cleanup'
      switch oopt
         case 'kbadlims'
            kbadlims = [
            %datenum([2013 01 01 00 00 00]) datenum([2013 03 18 14 51 00]) % start of cruise
            datenum([]) datenum([])
            ];
      end
   %%%%%%%%%% end mtsg_cleanup %%%%%%%%%%

   %%%%%%%%%% tsgsal_apply_cal %%%%%%%%%%
    case 'tsgsal_apply_cal'
       switch oopt
          case 'saladj'
             adj = 0.005;
             vout = salin+adj;
      end
   %%%%%%%%%% end tsgsal_apply_cal %%%%%%%%%%


end