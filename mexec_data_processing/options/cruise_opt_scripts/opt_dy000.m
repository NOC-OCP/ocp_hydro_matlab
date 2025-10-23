switch scriptname
    
            %%%%%%%%%% mctd_01 %%%%%%%%%%
    case 'mctd_01'
        switch oopt
            case 'redoctm'
                if ismember(stnlocal,7:16)
                    redoctm = 1;
                end
        end
        %%%%%%%%%% end mctd_01 %%%%%%%%%%
        
                %%%%%%%%%% mctd_02a %%%%%%%%%%
    case 'mctd_02a'
        switch oopt
            case 'prectm_rawedit'
                 %pvars is a list of variables to NaN when pumps are off, with the
                %second column setting the number of additional scans after the
                %pumps come back on to also NaN
                pvars = {'temp1' 12
                    'temp2' 12
                    'cond1' 12
                    'cond2' 12
                    'oxygen_sbe1' 8*24
                    };
                revars = {'press' -10 8000
                    'temp1' -2 32
                    'temp2' -2 32
                    'cond1' 25 60
                    'cond2' 25 60
                    'transmittance' 50 100
                    'oxygen_sbe1' 0 400
                    'fluor' 0 0.5
                    };
                dsvars = {'press' 3 2 2
                    'temp1' 1 0.5 0.5
                    'temp2' 1 0.5 0.5
                    'cond1' 1 0.5 0.5
                    'cond2' 1 0.5 0.5
                    'oxygen_sbe1' 3 2 2
                    'transmittance' 0.3 0.2 0.2
                    'fluor' 0.2 0.1 0.1
                    'turbidityV' 0.05 0.05 0.05%***
                    'pressure_temp' 0.1 0.1 0.1
                    };
                dsvars = {'press' 3 2 2
                    'temp1' 1 0.5 0.5
                    'temp2' 1 0.5 0.5
                    'cond1' 1 0.5 0.5
                    'cond2' 1 0.5 0.5
                    'oxygen_sbe1' 3 2 2
                    'transmittance' 0.3 0.2 0.2
                    'fluor' 0.2 0.1 0.1
                    'pressure_temp' 0.1 0.1 0.1
                    };
        end
        
            %%%%%%%%%% castpars (not a script) %%%%%%%%%%
    case 'castpars'
        %parameters used by multiple scripts, related to CTD/LADCP casts
        switch oopt
            case 'oxyvars'
                oxyvars = {'oxygen_sbe1' 'oxygen1'};
        end

end