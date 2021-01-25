switch scriptname
    
        %%%%%%%%%% castpars (not a script) %%%%%%%%%%
    case 'castpars'
        %parameters used by multiple scripts, related to CTD/LADCP casts
        switch oopt
            case 'oxyvars'
                oxyvars = {'oxygen_sbe1' 'oxygen1'; 'oxygen_sbe2' 'oxygen2'};
        end
        %%%%%%%%%% end castpars (not a script) %%%%%%%%%%

        %%%%%%%%%% mctd_03 %%%%%%%%%%
    case 'mctd_03'
        switch oopt
           case 'o_choice'
             o_choice = 2;
        end
        %%%%%%%%%% mctd_03 %%%%%%%%%%

   %%%%%%%%%% cond_apply_cal %%%%%%%%%%
   case 'cond_apply_cal'
	dayofctd = [ 0  0.2367  3.0511  3.2512  6.2113  7.5015  9.0772  9.1495     NaN 10.9127 ...
	       	14.1786 17.1828 18.0905 19.1022 19.1748 20.7742 22.5918 24.0163 25.0667 27.6084 ...
	       	29.2693 30.2729 30.4941 31.2266 31.4782 32.3032 33.2621 35.1690 35.3074];
        switch sensor
          case 1
	  	off = ( 0.10388 + 0.00170*(time/86400 + dayofctd(stn)) - 0.00847*press/1000 -0.00285*temp)/1000;
			condadj = 0;
	  case 2
	     	off = ( 0.01252 + 0.00104*(time/86400 + dayofctd(stn)) - 0.00324*press/1000 -0.00328*temp)/1000;
		switch stn
			case {1 2}
				condadj = 0.002;
			otherwise
				condadj = 0;
			end
           end
		
      fac = 1 + off;
      condout = cond.*fac + condadj;
   %%%%%%%%%% end cond_apply_cal %%%%%%%%%%
 
        %%%%%%%%%% mctd_checkplots %%%%%%%%%%
    case 'mctd_checkplots'
        switch oopt
            case 'plot_saltype'
                saltype = 'asal';
        end
        %%%%%%%%%% end mctd_checkplots %%%%%%%%%%
 
        %%%%%%%%%% moxy_01 %%%%%%%%%%
    case 'moxy_01'
        switch oopt
            case 'oxycsv'
                %infile = [root_oxy '/oxy_jc159_all.csv'];
                infile = [root_oxy '/' 'oxy_' mcruise '_' sprintf('%3.3i',stnlocal) '.csv'];
            case 'oxysampnum'
                %ds_oxy.niskin        = ds_oxy.botnum;
                ds_oxy.botoxya_per_l = ds_oxy.botoxya; 
                ds_oxy.botoxyb_per_l = ds_oxy.botoxyb;
                %ds_oxy.sampnum       = ds_oxy.statnum*100 + ds_oxy.niskin;
        end
   %%%%%%%%%% end moxy_01 %%%%%%%%%%
 
   %%%%%%%%%% mtsg_cleanup %%%%%%%%%%
     case 'mtsg_cleanup'
         switch oopt
             case 'kbadlims'
                 kbadlims = [datenum([2018 10 17 14 25 0]) datenum([2018 10 19 12 0 0]) % Las Palmas
                    datenum([2018 10 19 12 0 01]) datenum([2018 10 20 13 5 0]) % Las Palmas
                    datenum([2018 10 30 7 28 0]) datenum([2018 10 30 7 30 0])
                    datenum([2018 10 31 18 28 0]) datenum([2018 10 31 18 30 0])
                    datenum([2018 11 5 9 23 0]) datenum([2018 11 5 9 47 0])
                    datenum([2018 11 5 16 49 0]) datenum([2018 11 5 17 0 0])
                    datenum([2018 11 7 18 16 0]) datenum([2018 11 7 18 32 0]) % pump off for cleaning 
                    datenum([2018 11 11 17 33 0]) datenum([2018 11 12 11 35 0]) %pump off for repair work to pipes
                    datenum([2018 11 16 11 45 0]) datenum([2018 11 16 19 48 0]) % Turned off during the Nassau Port call
                    ]; 
             case 'editvars'
                 editvars = {'salinity','tstemp','sstemp','sstemp2','sampletemp','chlorophyll','trans','psal','fluo','cond','temp_m','temp_h','salin','fluor'};
         end
   %%%%%%%%%% end mtsg_cleanup %%%%%%%%%%
   
   
   %%%%%%%%%% tsgsal_apply_cal %%%%%%%%%%
     case 'tsgsal_apply_cal'
        off = (0.00089893/86400)*time - 0.3278;
        salout = salin + off;
   %%%%%%%%%% end tsgsal_apply_cal %%%%%%%%%%

   %%%%%%%%%% msal_standardise_avg %%%%%%%%%%
case 'msal_standardise_avg'
        switch oopt
            case 'check_sal_runs'
                check_sal_runs = 1;
                calc_offset = 1;
                plot_all_stations = 0;
            case 'k15'
                sswb = 161; %ssw batch
                msal_ssw
                ds_sal.K15 = zeros(size(ds_sal.sampnum));
                ds_sal.K15(iistd) = ssw_batches(ssw_batches(:,1)==sswb,2)/2;
            case 'cellT'
                ds_sal.cellT = 24+zeros(length(ds_sal.sampnum),1);
        end
        %%%%%%%%%% msal_standardise_avg %%%%%%%%%%

end
