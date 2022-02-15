switch scriptname

    case 'm_daily_proc'
        switch oopt
            case 'excludestreams'
                uway_excludes = {'singleb_t'};
        end
        
        case 'mday_01_fcal'
        switch oopt
            case 'uway_factory_cal'
                switch abbrev
                    case 'surfmet'
                        sensorcals.fluo = 'y=(x1-0.082)*04.9;'; % fluorometer: s/n WS3S-248 cal 24 Jun 2021
                        sensorcals.trans = 'y=(x1-0.004)/(4.700-0.004)*100;'; %transmissometer: s/n CST-1852PR cal 23 Mar 2021
                        sensorcals.parport = 'y=x1/0.9451;'; % port? PAR: s/n SKE510 28563 cal 23 Mar 2021
                        sensorcals.parstbd = 'y=x1/1.029;'; % stb? PAR: s/n SKE510 28562 cal 29 Mar 2021 %muV/Wm-2
                        sensorcals.tirport = 'y=x1/1.181;'; % port TIR: s/n 973135 cal 6 Apr 2021
                        sensorcals.tirstbd = 'y=x1/1.009;'; % stb TIR: s/n 962276 cal 18 Aug 2021
                        % the surfmet instrument box is outputting in V*1e-5 for PAR/TIR already***check this is true on dy as well
                        sensorunits.fluo = 'ug/l';
                        sensorunits.trans = 'percent';
                        sensorunits.parport = 'W/m2';
                        sensorunits.parstbd = 'W/m2';
                        sensorunits.tirport = 'W/m2';
                        sensorunits.tirstbd = 'W/m2';
                    case 'multib'
                        xducer_offset = 5;
                end
        end
        
    case 'mtsg_medav_clean_cal'
        switch oopt
            case 'tsg_badlims'
                kbadlims = datenum(2022,1,1) + [-inf 39+19/24]; %start of cruise, TSG on during decimal day 39
        end
        
    case 'mbot_01'
        switch oopt
            case 'nispos'
                niskin = [9002 8149 9006:2:9024]; %25000NNNN
            case 'botflags'
                %niskin_flag(ismember(statnum,[3 4 7 9 46 49]) & position==3) = 4; %bottom endcap not closed
                %niskin_flag(ismember(statnum,[10 18 19 21 37 45 60 65 71 73 80]) & position==10) = 4; %did not seal or leaked
                %niskin_flag(statnum==21 & position==9) = 4; %bottom end cap did not seal
                %niskin_flag(ismember(sampnum, [5503 7416 8016])) = 3; %leaked from bottom end cap after sampling
        end

end
