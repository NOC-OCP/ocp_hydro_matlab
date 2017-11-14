switch scriptname

   %%%%%%%%%% cond_apply_cal %%%%%%%%
   case 'cond_apply_cal'
      switch sensor
         case 1
            fac  = 1;
            condadj = 0;
            if ismember(stn, 1:55)
               fac1 = 1 + 0.0025/35; % initial cal determined from ctd_evaluate_sensors_jr281
               off2 = interp1([-10 0 1500 6000],[0.0020 0.0020 0.0010 0.0010],press); % refinement
               fac2 = off2/35 + 1;
               fac = fac1.*fac2;
            end
            condout = cond.*fac;
            condout = condout+condadj;
         case 2
            fac = 1;
            condadj = 0;
            if ismember(stn, 1:55)
               fac1 = 1 + 0.0025/35; % initial cal determined from ctd_evaluate_sensors_jr281
               off2 = interp1([-10 0 1500 6000],[0.0010 0.0010 0.0010 0.0010],press); % refinement
               fac2 = off2/35 + 1;
               fac = fac1.*fac2;
            end
            condout = cond.*fac;
            condout = condout+condadj;
         otherwise
            fprintf(2,'%s\n','Should not enter this branch of cond_apply_cal !!!!!')
      end
   %%%%%%%%%% end cond_apply_cal %%%%%%%%


   %%%%%%%%%% ctd_evaluate_sensors %%%%%%%%
   case 'ctd_evaluate_sensors'
      switch oopt
         case 'csensind'
	    sensind = {find(d.statnum>=1 & d.statnum<=100)};
      end
   %%%%%%%%%% end ctd_evaluate_sensors %%%%%%%%


   %%%%%%%%%% mctd_02b %%%%%%%%
   case 'mctd_02b'
      switch oopt
         case 'hyst'
            hyst_pars = [-0.033 5000 1450]; %sbe default
            hyst_pars_string = sprintf('%f,%f,%f',hyst_pars(1),hyst_pars(2),hyst_pars(3));
            % bak on jr281, include option of not doing oxygen hysteresis, for exmaple
            % if it was applied in the datcnv, as was the case on jc054.
            hyst_execute_string = ['y = x1;'];
      end
   %%%%%%%%%% end mctd_02b %%%%%%%%


   %%%%%%%%% mctd_03 %%%%%%%%%
   case 'mctd_03'
      switch oopt
         case 's_choice'
	    s_choice = 2;
	    alternate = [];
      end
   %%%%%%%%% end mctd_03 %%%%%%%%%


%%%%%%%%%%%%%%%%%%
end