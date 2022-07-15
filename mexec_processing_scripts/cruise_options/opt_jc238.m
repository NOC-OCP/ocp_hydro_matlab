switch scriptname
    
    case 'castpars'
        switch oopt
            case 'nnisk'
                nnisk = 12;
            case 'oxy_align'
                if ismember(stnlocal,[2 3]) %add stations finished by dougal here
                    oxy_end = 1;
                end
        end

    case 'batchactions'
        switch oopt
            case 'output_for_others'
                syncfrom = '/local/users/pstar/jc238/mcruise/data/collected_files/';
                syncto = '/local/users/pstar/mounts/public/JC238/ctd_sam_uway_collected_files/';
                system(['rsync -au ' syncfrom ' ' syncto]);
        end

    case 'mctd_01'
        switch oopt
            case 'cnvfilename'
                if redoctm
                    cnvfile = sprintf('%s_CTD_%03d.cnv', upper(mcruise), stnlocal);
                else
                    cnvfile = sprintf('%s_CTD_%03d_align_ctm.cnv', upper(mcruise), stnlocal);
                end
            case 'ctdvars'
                ctdvars_add = {'ph','ph','number'};
        end

    case 'mctd_02'
        switch oopt
            case 'rawedit_auto'
                if stnlocal==3
                   castopts.badscans.transmittance = [0 inf]; %instrument went bad pretty much the cast
                end
        end

    case 'mfir_01'
        switch oopt
            case 'blinfile'
                blinfile = fullfile(root_botraw,sprintf('%s_CTD_%03d.bl', upper(mcruise), stnlocal));
            case 'nispos'
                niskc = [1:2:23]';
                %niskn = [9002 8149 9006:2:9024]'; %25000NNNN
            case 'botflags'
                %Niskin flags: 2 = good, 3 leaking, 4 misfire [wire did not
                %release], 7 unknown problem [for further investigation], 9 not sampled
                switch stnlocal
                    case 1
                        niskin_flag(position==1) = 7; %questionable tap
                    otherwise
                end
        end

    case 'best_station_depths'
        switch oopt
            case 'bestdeps'
                % only for stations where we can't use ctd+altimeter
                % replacedeps = [cast_number depth]
                % replacedeps = [
                %    1 1090
                %    2 2100];
                % etc. 
        end

    case 'mout_exch'
        switch oopt
            case 'woce_expo'
                expocode = '740H20220712';
                sect_id = 'Ellet Line, OSNAP-East';
                submitter = 'OCPNOCYLF'; %group institution person
            case 'woce_ctd_headstr'
                headstring = {['CTD,' datestr(now,'yyyymmdd') submitter];...
                    '#SHIP: RRS James Cook';...
                    '#Cruise JC238; OSNAP East (Rockall Trough to Iceland Basin)';...
                    '#Region: Eastern subpolar North Atlantic';...
                    ['#EXPOCODE: ' expocode];...
                    '#DATES: 20220712 - 20220801';...
                    '#Chief Scientist: B. Moat, NOC';...
                    '#Supported by grants from the UK Natural Environment Research Council for the OSNAP program (grant no. ***).';...
                    '#*** stations with 12-place rosette';...
                    '#CTD: Who - Y. Firing; Status - uncalibrated';...
%                    '#The CTD PRS; TMP; SAL; OXY data are all calibrated and good.';...
                    '# DEPTH_TYPE   : COR';...
                    };
            case 'woce_sam_headstr'
                headstring = {['BOTTLE,' datestr(now,'yyyymmdd') submitter];... 
                    '#SHIP: RRS James Cook';...
                    '#Cruise JC238; OSNAP East (Rockall Trough to Iceland Basin)';...
                    '#Region: Eastern subpolar North Atlantic';...
                    ['#EXPOCODE: ' expocode];...
                    '#DATES: 20220712 - 20220801';...
                    '#Chief Scientist: B. Moat, NOC';...
                    '#Supported by grants from the UK Natural Environment Research Council for the OSNAP program (grant no. ***).';...
                    '#*** stations with 12-place rosette';...
                    '#CTD: Who - Y. Firing; Status - uncalibrated';...
                    '#Notes: Includes CTDSAL, CTDOXY, CTDTMP';...
%                    '#The CTD PRS; TMP; SAL; OXY data are all calibrated and good.';...
                    '#Salinity: Who - Y. Firing; Status - not yet analysed';...
                    '#Oxygen: Who - S. Beith; Status - not yet analysed';...
                    '#Nutrients: Who - ***; Status - not yet analysed';...
                    '#Carbon: Who - ***; Status - not yet analysed';...
                    };
        end

                %%%%%%%%%% mday_01_fcal %%%%%%%%%%
    case 'mday_01_fcal'
        switch oopt
            case 'uway_factory_cal'
                switch abbrev
                    case 'surfmet'
%                         sensors_to_cal={'fluo';'trans';'parport';'tirport';'parstarboard';'tirstarboard'};
%                         sensorcals={
%                             'y=(x1-0.078)*13.5'; % fluorometer: s/n WS3S-134 cal 14 Jul 2020
%                             'y=(x1-0.058)/(4.625-0.058)*100' %transmissometer: s/n CST-1132PR cal 24 Jun 2019
%                             'y=x1/1.015' % port PAR: s/n 28556 cal 3 Sep 2019
%                             'y=x1/1.073' % port TIR: 047463 cal 6 Jun 2019
%                             'y=x1/0.9860' % stb PAR: s/n 28558 cal 3 Sep 2019
%                             'y=x1/1.158'}; % stb TIR: 047362 cal 6 Jun 2019
%                         % the surfmet instrument box is outputting in V*1e-5 for PAR/TIR already
%                         sensorunits={'ug/l';'percent';'W/m2';'W/m2';'W/m2';'W/m2'};
                end
        end
        %%%%%%%%%% end mday_01_fcal %%%%%%%%%%

end
