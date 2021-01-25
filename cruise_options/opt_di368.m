switch scriptname

   %%%%%%%%%% cond_apply_cal %%%%%%%%%%
   case 'cond_apply_cal'
      switch sensor
         case 1
            fac = 1-1.4976e-5;
            bin_press = [-10 0 2000 4500 10000];
            bin_offset = [0.0008 0.0008 0.0018 0 0];    
            condadj = interp1(bin_press,bin_offset,press);
            condout = cond*fac;
            condout = condout+condadj;
         case 2
            %                 fac = 1-1.1193e-4; % initial estimate
            %                 bin_press = [-10 0 1500 4500 10000];
            %                 bin_offset = [0.0035 0.0035 0.002 0 0];
            fac = 1-7.108e-5;
            bin_press = [-10 0 3500 5500 10000];
            bin_offset = [0.001 0.001 0.001 -0.0005  -0.0005];
            condadj = interp1(bin_press,bin_offset,press);
            condadj2 = -0.0018 + 5.8e-5*stn; % small station dependence from polyfit to residuals deeper than 1900
            condout = cond*fac;
            condout = condout+condadj+condadj2;
	 otherwise
            fprintf(2,'%s\n','Should not enter this branch of cond_apply_cal !!!!!')
	 end
   %%%%%%%%%% end cond_apply_cal %%%%%%%%%%

   %%%%%%%%%% oxy_apply_cal %%%%%%%%%%
   case 'oxy_apply_cal'
      gamma=8.251e-4;
      alpha=1.0533;
      beta=-5.22;
      bin_press = [-10 1000 1500 2500 4000 5500 10000];
      bin_offset = [-1 0.5 -0.5 0.9 1.0 -0.5 -0.5];
      oxyadj = interp1(bin_press,bin_offset,press);
      fac1=1+gamma*(stn-3);
      oxy1=oxyin.*fac1;
      oxy2=alpha*oxy1+beta;
      oxyout = oxy2+oxyadj;
      if stn == 1 % station 1 sensor was bad and unrecoverable. may have drifted before it failed. insufficient bottles to calibrate with confidence.
         oxyout = nan+oxyout;
      end
      if stn == 2
         oxyout = oxyout-1; % needs one micromol extra offset to come into line with bottle
      end
   %%%%%%%%%% end oxy_apply_cal %%%%%%%%%%


   %%%%%%%%%% mout_cchdo_sam %%%%%%%%%%
   case 'mout_cchdo_sam'
      switch oopt
         case 'expo'
            expocode = '74DI368_1';
            sect_id = 'A16N2011';
	 case 'outfile'
	    outfile = 'a16n2011';
      end
   %%%%%%%%%% end mout_cchdo_sam %%%%%%%%%%

   %%%%%%%%%% mout_cchdo_ctd %%%%%%%%%%
   case 'mout_cchdo_ctd'
      switch oopt
         case 'expo'
            expocode = '74DI368_1';
            sect_id = 'A16N2011';
	 case 'outfile'
	    outfile = 'a16n2011';
      end
   %%%%%%%%%% end mout_cchdo_ctd %%%%%%%%%%


   %%%%%%%%%% mctd_03 %%%%%%%%%%
   case 'mctd_03'
      switch oopt
                   case 's_choice'
            stns_alternate_s = [5]; % psal fouled on station 5 upcast. temp bad on station 2; plumbing disconnected
          case '24hz_edit'
              if stnlocal==2
                              % chop some bad scans from oxygen downcast 
                  badscans24 = {'oxygen' 179124 179316}; %previously these were cut out at _psal stage
              end
        case '1hz_interp'
         if stnlocal==2
             interp1hz = 1; maxgap1 = floor((179316-179124)/24)+1;
         end
      end
   %%%%%%%%%% end mctd_03 %%%%%%%%%%
   
   %%%%%%%%%% mctd_04 %%%%%%%%%%
   case 'mctd_04'
     switch oopt
        case 'pre_2_treat'
           if stnlocal==7
              % use upcast; downcast has bad data in oxygen and psal; probably ingested grolly
              kf = find(d.statnum == stnlocal);
              dcstart = d.dc_bot(kf);
              dcend = d.dc_end(kf);
              copystr = {[sprintf('%d',round(dcstart)) ' ' sprintf('%d',round(dcend))]};
          end
      end
   %%%%%%%%%% end mctd_04 %%%%%%%%%%
   
   %%%%%%%%%% msec_run_mgridp %%%%%%%%%%
   case 'msec_run_mgridp'
      switch oopt
         case 'varuse'
	    varuselist.names = {'botoxy'};
      end
   %%%%%%%%%% end msec_run_mgridp %%%%%%%%%%



%%%%%%%%%%%%%%%%%%
end
