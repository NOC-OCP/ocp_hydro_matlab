switch scriptname
        %%%%%%%%%% mctd_03 %%%%%%%%%%
    case 'mctd_03'
        switch oopt
           case 's_choice'
             s_choice = 1;
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

        %%%%%%%%%% mctd_02b %%%%%%%%%%
    case 'mctd_02b'
        switch oopt
            case 'calibs_to_do'
                dooxyhyst = 1;
            case 'oxyhyst' %this only comes up if ismember(dohyst,1)
                var_strings = {'oxygen_sbe1 time press','oxygen_sbe2 time press'};
                pars = {[-0.033 5000 1450],[-0.033 5000 1450]}; %sbe default
                varnames = {'oxygen1','oxygen2'};
        end
        %%%%%%%%%% end mctd_02b %%%%%%%%%%
 
        %%%%%%%%%% mctd_checkplots %%%%%%%%%%
    case 'mctd_checkplots'
        switch oopt
            case 'pf1'
                pf1.ylist = 'press temp psal oxygen';
            case 'sdata'
                sdata1 = d{ks}.psal1; sdata2 = d{ks}.psal2; tis = 'psal'; sdata = d{ks}.psal;
            case 'odata'
                odata1 = d{ks}.oxygen1; odata2 = d{ks}.oxygen2; odata = d{ks}.oxygen;
        end
        %%%%%%%%%% end mctd_checkplots %%%%%%%%%%
 
        %%%%%%%%%% moxy_01 %%%%%%%%%%
    case 'moxy_01'
        switch oopt
            case 'oxycsv'
                %infile = [root_oxy '/oxy_jc159_all.csv'];
                infile = [root_oxy '/' 'oxy_' mcruise '_' sprintf('%3.3i',stnlocal) '.csv'];
            case 'oxybotnisk'
                %ds_oxy.niskin = ds_oxy.botnum; 
				ds_oxy.niskin = ds_oxy.sampnum-100*ds_oxy.statnum;
            case 'sampnum_parse'
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
            case 'std2use'
%                std2use([47 68 121],1) = 0;
%                std2use([50],2) = 0;
%                std2use([61],3) = 0;
            case 'sam2use'
%                sam2use(51,2) = 0;
%                sam2use([2587 2896],3) = 0;
            case 'fillstd'
                %add the start standard--can add it at the end because we'll
                %use time to interpolate
%                ds_sal.sampnum = [ds_sal.sampnum; 999000];
%                ds_sal.offset(end) = 0;
%                ds_sal.runtime(end) = ds_sal.runtime(1)-1/60/24; %put it 1 minute before sample 1
                %%machine was re-standardised before running stn 68
                %ds_sal.sampnum = [ds_sal.sampnum; 999097.5];
                %ds_sal.offset(end) = 4e-6;
                %ds_sal.runtime(end) = ds_sal.runtime(ds_sal.sampnum==6801)-1/60/24;
                %this half-crate had no standard at the end so use the one
                %from the beginning
%                if sum(ds_sal.sampnum==999111)
%                    ds_sal.sampnum = [ds_sal.sampnum; 999111.5];
%                    ds_sal.offset(end) = ds_sal.offset(ds_sal.sampnum==999111);
%                    ds_sal.runtime(end) = ds_sal.runtime(ds_sal.sampnum==7611)+1/60/24;
%                    %interpolate based on runtime
%                    xoff = ds_sal.runtime;
%                end
        end
        %%%%%%%%%% msal_standardise_avg %%%%%%%%%%

end
