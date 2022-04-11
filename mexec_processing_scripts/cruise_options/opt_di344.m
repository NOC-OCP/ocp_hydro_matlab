switch scriptname
    
    %%%%%%%%%% mday_01_clean_av %%%%%%%%%%
    case 'mday_01_clean_av'
        switch oopt
            case 'uway_apply_cal'
                if strcmp(abbrev,'surfmet')
                    scals = {'press' 'y = -1.17 + 1.00152*x';'/'
                        'ppar','y = 0 + (10/11.04)*x','W/m2',
                        'spar','y = 0 + (10/10.53)*x','W/m2',
                        'ptir','y = 0 + (10/9.60)*x','W/m2',
                        'stir','y = 0 + (10/9.76)*x','W/m2'};
                    sensors_to_cal = scals(:,1); sensorcals = scals(:,2); sensorunits = scals(:,3);
                    % D344 calibrations for air pressure and light sensors
                    % Vaisala pressure transmitter, model PTB100A, s/n S3610008
                    % Calib cert: N0C00437P, 23-Feb-2009
                    % y=-1.17483+1.00152*press
                    % Skye sPAR, s/n 28556, 12-Feb-2009; 10.53 microV/W/m2
                    % Skye pPAR, s/n 28557, 12-Feb-2009; 11.04 microV/W/m2
                    % Kipp&Zonen sTIR, s/n 962301, 19-Feb-2009; 9.76 microV/W/m2
                    % Kipp&Zonen pTIR, s/n 994133, 23-June-2008; 9.60 microV/W/m2
                end
        end
        %%%%%%%%%% mday_01_clean_av %%%%%%%%%%
        
end