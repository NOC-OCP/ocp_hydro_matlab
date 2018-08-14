switch scriptname

   %%%%%%%%%% cond_apply_cal %%%%%%%%%%
   case 'cond_apply_cal'
      switch sensor
         case 1
            fac  = 1;
            condadj = 0;
            if stn <= 37
               cbase = [
                        0 0.0037
                        6 0.0042
                        10 0.0042
                        17 0.0055
                        30 0.0062
                        36 0.0065
                        999 0.0065
                       ];
               fac = 1 + interp1(cbase(:,1),cbase(:,2),stn)/35; % determined from ctd_evaluate_sensors_jc069
            elseif stn >= 38 % replacement sensor
               cbase = [
                        0    -0.0020
                        1000 -0.0013
                        2000 -0.0011
                        4000  0.0002
                        8000  0.0002
                       ];
               fac = interp1(cbase(:,1),cbase(:,2),press);
               if stn >= 38 & stn <= 62
                  fac = fac + 0.0005;
               end
               fac = 1 + fac/35;
            end
            if stn > 999
               fac = 1;
               condadj = 0;
            end
            condout = cond.*fac;
            condout = condout+condadj;
         case 2
            condadj = 0;
            if stn < 20
               fac = 1 + 0.0032/35; % determined from ctd_evaluate_sensors_jc069
            elseif stn >= 20
               fac = 1 - 0.0008/35; % replacement sensor; This calibration still OK at stations up to 75
            end
            condout = cond*fac;
            condout = condout+condadj;
         otherwise
            fprintf(2,'%s\n','Should not enter this branch of cond_apply_cal !!!!!')
      end
   %%%%%%%%%% end cond_apply_cal %%%%%%%%%%

   %%%%%%%%%% fluor_apply_cal %%%%%%%%%%
   case 'fluor_apply_cal'
      fac = 2.15; expco = -1.21;
      fluorout = fac*(1-exp(expco*fluor)); % provided by Heather Bouman 17 March 2012 for all stations;
   %%%%%%%%%% end fluor_apply_cal %%%%%%%%%%


   %%%%%%%%%% mday_01_clean_av %%%%%%%%%%
   case 'mday_01_clean_av'
      switch abbrev
         case {'log_chf' 'chf'}
	    unix(['/bin/cp ' otfile '.nc wkfile '.nc'])
	    ee4 =[ -2.0000    5.9000    7.8800   20.0000];
	    vv4 = [-2.3338    2.9490    6.2769   16.6582];
            calstr = ['y = interp1([' sprintf('%2.4f ',ee4) '], [' sprintf('%2.4f ',vv4) '], x1);'];
	    MEXEC_A.MARGS_IN = {
   	       wkfile
	       otfile
	       '/'
	       'speedfa time'
	       calstr
	       'speedfa_cal'
	       'knots'
	       ' '
	    };
	    mcalc
      end
   %%%%%%%%%% end mday_01_clean_av %%%%%%%%%%


   %%%%%%%%%% mcfc_02 %%%%%%%%%%
   case 'mcfc_02'
      switch oopt
         case 'infile1'
	    infile1 = [root_cfc '/' prefix1 stn_string];
	 case 'cfclist'
            cfcinlist = 'sf6 sf6_flag cfc12 cfc12_flag cfc13 cfc13_flag sf5cf3 sf5cf3_flag';
            cfcotlist = cfcinlist;
      end
   %%%%%%%%%% end mcfc_02 %%%%%%%%%%


   %%%%%%%%%% mctd_03 %%%%%%%%%%
   case 'mctd_03'
      switch oopt
         case 's_choice'
            % sensors inherited frmo jc068; sensor 1 drifting slowly.
            % sensor 2 stable but offset;
            % sensor 2 swapped at station >= 20
            % replacement sensor SBE cal is almost spot on
            % sensor 2 stable before and after swapping.
            s_choice = 2; % default, 1 = primary
            alternate = []; % list of station numbers for which alternate is preferred
      end
   %%%%%%%%%% end mctd_03 %%%%%%%%%%

   %%%%%%%%%% mtsg_bottle_compare %%%%%%%%%%
   case 'mtsg_bottle_compare'
      switch oopt
         case 'dbbad'
            db.salinity_adj(10) = nan; % bad data point on jc069
      end
   %%%%%%%%%% end mtsg_bottle_compare %%%%%%%%%%


   %%%%%%%%%% mtsg_cleanup %%%%%%%%%%
   case 'mtsg_cleanup'
      switch oopt
         case 'kbadlims'
	    kbadlims = [
               0 datenum([2012 2 2 13 00 00]) % discard anything before pumps first on at start of cruise
               datenum([2012 2 18 08 00 00]) datenum([2012 2 18 16 00 00]) % stanley first time
               datenum([2012 2 21 12 00 00]) datenum([2012 2 24 12 00 00]) % stanley second time
               datenum([2012 3 31 0 0 0]) 1e10 % placeholder for end of cruise
               ];
         case 'moreedit'
	    if strcmp('salin', varinind)
	       vout(vout < 33) = NaN;
	    end
      end
   %%%%%%%%%% end mtsg_cleanup %%%%%%%%%%


   %%%%%%%%%% tsgsal_apply_cal %%%%%%%%%%
   case 'tsgsal_apply_cal'
      switch oopt
         case 'saladj'
            botfile = ['met_tsg_' MEXEC_G.MSCRIPT_CRUISE_STRING '_01_botcompare']; 
            MARGS_STORE = MEXEC_A.MARGS_IN_LOCAL;
   	    [db hb] = mload(botfile,'/');
       	    MEXEC_A.MARGS_IN_LOCAL = MARGS_STORE; % put things back how they were !
            db.salinity_adj(10) = nan; % bad bottle comparison
            sdiff = db.salinity_adj-db.salin;
            sdiffsm = filter_bak(ones(1,21),sdiff);
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
            title({MEXEC_G.MSCRIPT_CRUISE_STRING; 'Bottle minus TSG salinity differences'; 'Individual bottles and smoothed adjustment  applied'});
      end
   %%%%%%%%%% end tsgsal_apply_cal %%%%%%%%%%


   %%%%%%%%%% station_summary %%%%%%%%%%
   case 'station_summary'
      switch oopt
         case 'cordep'
            load('/local/users/pstar/jc069/data/station_depths/bestdeps'); cordep(k) = bestdeps(k);
	 case 'comments'
	    ki = 37; comments(ki) = repmat({'twoyo 1'}, length(ki), 1);
	    ki = 40:43; comments(ki) = repmat({'twoyo 2'}, length(ki), 1);
            ki = 44:47; comments(ki) = repmat({'towyo 3'}, length(ki), 1);
            ki = 48:51; comments(ki) = repmat({'towyo 4'}, length(ki), 1);
            ki = 52:55; comments(ki) = repmat({'towyo 5'}, length(ki), 1);
            ki = 56:59; comments(ki) = repmat({'towyo 6'}, length(ki), 1);
            ki = 60:62; comments(ki) = repmat({'towyo 7'}, length(ki), 1);
            ki = 76:78; comments(ki) = repmat({'towyo 8'}, length(ki), 1);
            ki = 79; comments(ki) = repmat({'Mooring site'}, length(ki), 1); 
            ki = 80:94; comments(ki) = repmat({'sr1b'}, length(ki), 1);
            ki = 95:100; comments(ki) = repmat({'A21'}, length(ki), 1);
         case 'parlist'
            parlist = [' sal'; ' cfc'];
	 case 'altdep'
            if ismember(k, [41 46 47 54 55 76 86 ]); minalt(k) = -9; resid(k) = -999; end % altimeter didn't find bottom
            if k == 50; minalt(k) = 65; resid(k) = maxd(k)+minalt(k)-cordep(k); end % altimeter height off taken from deck unit log sheet
            if k == 56; minalt(k) = 58; resid(k) = maxd(k)+minalt(k)-cordep(k); end % altimeter height off taken from deck unit log sheet
            if k == 73; minalt(k) = 95; resid(k) = maxd(k)+minalt(k)-cordep(k); end % altimeter height off taken from deck unit log sheet
	 end
   %%%%%%%%%% end station_summary %%%%%%%%%%

   %%%%%%%%%% msec_run_mgridp %%%%%%%%%%
   case 'msec_run_mgridp'
      switch oopt
         case 'sections'
            sections = {'sr1b'};
	 case 'gpars'
            gstart = 10; gstop = 5000; gstep = 20;
	 case 'kstns'
	    switch section
	       case 'sr1b'
	          sstring = '[80:89 91]';
	    end
	 case 'varuse'
            varuselist.names = {'cfc12' 'cfc13' 'sf6' 'sf5cf3'};
      end
   %%%%%%%%%% end msec_run_mgridp %%%%%%%%%%


   %%%%%%%%%% vmadcp_proc %%%%%%%%%%
   case 'vmadcp_proc'
      switch oopt
         case 'aa75'
	    ang = 0; amp = 1.00;
	 case 'aa150'
	    ang = 0; amp = 1.00;
      end
   %%%%%%%%%% end vmadcp_proc %%%%%%%%%%

end
