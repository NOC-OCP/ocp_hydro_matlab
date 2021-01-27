switch scriptname

   %%%%%%%%%% cond_apply_cal %%%%%%%%%%
   case 'cond_apply_cal'
      s = (stn-1)/30;
      switch sensor
         case 1
	    off = (interp1([0 5000], [5.38 0.60], press) + -1.29*s)*1e-3;
            fac = off/35 + 1;
            condadj = 0;
         case 2
	    off = (interp1([0 5000], [2.48 -3.73], press) + -0.84*s)*1e-3;
            fac = off/35 + 1;
            condadj = 0;
      end
      condout = cond.*fac;
      condout = condout+condadj;
   %%%%%%%%%% end cond_apply_cal %%%%%%%%%%

   %%%%%%%%%% oxy_apply_cal %%%%%%%%%%
   case 'oxy_apply_cal'
      alpha = 1.0603 + 5e-4*stn;
      beta = 1.0384 + 7e-4*press;
      oxyout = alpha.*oxyin + beta;
   %%%%%%%%%% end oxy_apply_cal %%%%%%%%%%
   
   %%%%%%%%%% temp_apply_cal %%%%%%%%%%
   case 'temp_apply_cal'
      switch sensor
         case 1
	    tempadj = -0.0004;
	    tempout = temp+tempadj;
	 case 2
	    tempadj = -0.0008;
	    tempout = temp+tempadj;
      end
   %%%%%%%%%% end temp_apply_cal %%%%%%%%%%


   %%%%%%%%%% ctd_evaluate_sensors %%%%%%%%%%
   case 'ctd_evaluate_sensors'
      switch oopt
         case {'tsensind','csensind'}
            if sensnum==1; sensind = {find(d.statnum>=1 & d.statnum<=999)}; end
	    if sensnum==2; sensind = {find(d.statnum>=1 & d.statnum<=999 & d.statnum~=16)}; end %cond2 sensor bad on cast 16
      end
   %%%%%%%%%% end ctd_evaluate_sensors %%%%%%%%%%
   

   %%%%%%%%%% msal_standardise_avg %%%%%%%%%%
   case 'msal_standardise_avg'
      switch oopt
         case 'cellT'
            jr15003_sal_temp_off %script to generate g_adj from digitized logsheets jr15003_log_sal*.m
            ds_sal.cellT = interp1(g_adj(:,1), g_adj(:,2), ds_sal.sampnum);
	 case 'offset'
            ds_sal.offset = interp1(g_adj(:,1), g_adj(:,3), ds_sal.sampnum);
         case 'sam2use'
            sam2use([58 173],2:3) = 0;
	    sam2use([78 233],3) = 0;
	    sam2use([186 193 239 315],2) = 0;
            salbotqf([58 173 78 233 186 193 239 315]) = 3; %set these to "questionable"
      end
   %%%%%%%%%% end msal_standardise_avg %%%%%%%%%%


   %%%%%%%%%% mout_cchdo_ctd %%%%%%%%%%
   case 'mout_cchdo_ctd'
      switch oopt
         case 'expo'
	    expocode = '74JC20151217';
            sect_id = 'SR1b';
	 case 'outfile'
	    outfile = ['sr1b_' expocode'];
	 case 'headstr'
            headstring = ['# The CTD PRS;  TMP;  SAL; OXY data are all calibrated and good . '];
      end
   %%%%%%%%%% end mout_cchdo_ctd %%%%%%%%%%


   %%%%%%%%%% mout_cchdo_sam %%%%%%%%%%
   case 'mout_cchdo_sam'
      switch oopt
         case 'expo'
	    expocode = '74JC20151217';
            sect_id = 'SR1b';
	 case 'outfile'
	    outfile = ['sr1b_' expocode'];
      end
   %%%%%%%%%% end mout_cchdo_sam %%%%%%%%%%


   %%%%%%%%%% mtsg_cleanup %%%%%%%%%%
   case 'mtsg_cleanup'
      switch oopt
         case 'kbadlims'
	    kbadlims = [
            datenum([2015 12 14 00 00 00]) datenum([2015 12 18 11 15 22]) % start of cruise
            datenum([2015 12 26 12 00 00]) datenum([2016 01 02 00 00 00]) %rothera and ice
            ];
      end
   %%%%%%%%%% end mtsg_cleanup %%%%%%%%%%


   %%%%%%%%%% tsgsal_apply_cal %%%%%%%%%%
    case 'tsgsal_apply_cal'
       switch oopt
          case 'saladj'
             adj = 0.06;
             vout = salin+adj;
      end
   %%%%%%%%%% end tsgsal_apply_cal %%%%%%%%%%


   %%%%%%%%%% station_summary %%%%%%%%%%
   case 'station_summary'
      switch oopt
         case 'optsams'
	    snames = {'noxy'}; sgrps = {'oxy'}; sashore = 0;
      end
   %%%%%%%%%% end station_summary %%%%%%%%%%
   

end
