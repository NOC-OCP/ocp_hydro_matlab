switch scriptname
    
    %%%%%%%%%% castpars (not a script) %%%%%%%%%%
    case 'castpars'
        switch oopt
            case 'oxyvars'
                oxyvars = {'sbeox0Mm_slash_Kg' 'oxygen1'};
        end
        %%%%%%%%%% end castpars (not a script) %%%%%%%%%%
        
        %%%%%%%%% cond_apply_cal %%%%%%%%%
    case 'cond_apply_cal'
        switch sensor
            case 1
                fac  = 1; % Do nothing on this sensor, which is uncalibrated
                condadj = 0;
                condout = cond.*fac;
                condout = condout+condadj;
            case 2
                fac = 1;
                condadj = 0;
                if ismember(stn, 1:55) % k21
                    fac1 = 1 + 0.0000/35; % initial cal determined from ctd_evaluate_sensors_jr281
                    off2 = interp1([-10 0  1500 8000],[0.0013 0.0013  0.0003 0.0003],press); % refinement
                    fac2 = off2/35 + 1;
                    fac = fac1.*fac2;
                end
                condout = cond.*fac;
                condout = condout+condadj;
            otherwise
                fprintf(2,'%s\n','Should not enter this branch of cond_apply_cal !!!!!')
        end
        %%%%%%%%% end cond_apply_cal %%%%%%%%%
        
        
        %%%%%%%%%% ctd_evaluate_sensors %%%%%%%%
    case 'ctd_evaluate_sensors'
        switch oopt
            case 'csensind'
                sensind = {find(d.statnum>=1 & d.statnum<=100)};
        end
        %%%%%%%%%% end ctd_evaluate_sensors %%%%%%%%
        
        
end