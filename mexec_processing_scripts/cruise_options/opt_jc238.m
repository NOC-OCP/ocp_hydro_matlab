switch scriptname
    
    case 'castpars'
        switch oopt
            case 'nnisk'
                nnisk = 12;
            case 'oxy_align'
                if ismember(stnlocal,[2 3 5:8 11:13 17:18 25:26 33]) %add stations where CTD was not turned off before pumps switched off here
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
                elseif stnlocal==19
                    castopts.despike.cond1 = [0.2 0.1];
                    castopts.despike.cond2 = [0.2 0.1];
                end
        end

    case 'mctd_03'
        switch oopt
            case 's_choice'
                s_choice = 2;
            case 'o_choice'
                o_choice = 2;
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
                    case 17
                        niskin_flag(position==9) = 4; %misfire
                    case 23
                        niskin_flag(position==9) = 4; %misfire         
                    case 28
                        niskin_flag(position==12) = 9; %bottle fired but not attached 
                    case 30
                        niskin_flag(position==3) = 7; %possible leak but we might have opened the tap first
                    otherwise
                end
        end

    case 'best_station_depths'
        switch oopt
            case 'bestdeps'
                % only for stations where we can't use ctd+altimeter
                % replacedeps = [cast_number depth]
                %replacedeps = [
                %   1 1088];
        end

    case 'mout_exch'
        switch oopt
            case 'woce_expo'
                expocode = '740H20220712';
                sect_id = 'Ellet Line -- OSNAP-East';
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
            case 'woce_vars_exclude'
                %use this space to calculate sigma0 (for sam file only)
                if isfield(d,'upsal')
                    d.upden = sw_pden(d.upsal,d.utemp,d.upress,0);
                end
                %if isfield(d,'botpsal')
                %    d.pden = sw_pden(d.botpsal,d.utemp,d.upress,0);
                %end
        end

                %%%%%%%%%% mday_01_fcal %%%%%%%%%%
    case 'mday_01_fcal'
        switch oopt
            case 'uway_factory_cal'
                switch abbrev
                    case 'surfmet'
%                         sensors_to_cal={'fluo';'trans';'parport';'tirport';'parstarboard';'tirstarboard'};
                         sensors_to_cal={'parport';'tirport';'parstarboard';'tirstarboard'};
                         sensorcals={
%                             'y=(x1-0.078)*13.5'; % fluorometer: s/n WS3S-134 cal 14 Jul 2020
%                             'y=(x1-0.058)/(4.625-0.058)*100' %transmissometer: s/n CST-1132PR cal 24 Jun 2019
                             'y=x1/1.059' % port PAR: s/n 28559 cal 23 Mar 2021
                             'y=x1/1.134' % port TIR: 994132 cal 6 Apr 2021
                             'y=x1/1.016' % stb PAR: s/n 28560 cal 23 Mar 2021
                             'y=x1/1.065'}; % stb TIR: 047463 cal 18 Aug 2021
%                         % the surfmet instrument box is outputting in V*1e-5 for PAR/TIR already
%                         sensorunits={'ug/l';'percent';'W/m2';'W/m2';'W/m2';'W/m2'};
                         sensorunits={'W/m2';'W/m2';'W/m2';'W/m2'};
                end
        end
        %%%%%%%%%% end mday_01_fcal %%%%%%%%%%

    case 'msal_01'
        switch oopt
            case 'sal_files'
                salfiles = dir(fullfile(root_sal, ['JC238_*.csv']));
                salfiles = {salfiles.name};
            case 'sal_parse'
                cellT = 24;
                ssw_batch = 'P165';
                ssw_k15 = 0.99986;
            case 'sal_calc'
                sal_off = [
                    1 1
                    2 3
                    3 3 %3 is a repeat from same bottle as 2; using value from 2
                    4 2
                    5 0
                    6 2
                    7 2 %7 is a repeat from same bottle as 6; using value from 6
                    8 2
                    9 -1
                    10 2
                    11 2 %11 is a repeat from same bottle as 10; using value from 10
                    12 2
                    13 -3
                    14 1
                    15 3
                    16 0
                    17 2
                    18 1];
                sal_off(:,1) = sal_off(:,1)+999000;
                sal_off(:,2) = sal_off(:,2)*1e-5;
                sal_adj_comment = ['Bottle salinities adjusted using SSW batch P165'];
        end

    case 'moxy_01'
        switch oopt
            case 'oxy_files'
                ofiles = {'Winkler_Calculation_Spreadsheet_JC238_2022.xlsx'};
                hcpat = {'CTD cast no.'};
                chrows = 1;
                chunits = [];
            case 'oxy_parse'
                oxyvarmap = {
                    'statnum',       'ctd_cast_no'
                    'position',      'niskin_bot_no'
                    'vol_blank',     'blank_titre_mls_calculated_under_blank_calculation_tab'
                    'vol_std',       'std_vol_mls'
                    'vol_titre_std', 'std_titre_mls'
                    'fix_temp',      'fixing_temp_c'
                    'sample_titre',  'sample_titre_mls'
                    'flag',          'flag'
                    'oxy_bottle'     'do_sample_bot_no'
                    'bot_vol_tfix'   'bot_vol_at_tfix_mls'
                    'conc_o2',       'c_o2_umol_per_l'};
            case 'oxy_calc'
                if statnum<=99
                    mol_std = 0.0030073;
                end
        end

        %%%%%%%%%% mfir_03 %%%%%%%%%%
    case 'mfir_03'
        switch oopt
            case 'fir_fill'
                firmethod = 'medint';
                firopts.int = [-1 120]; %average over 5 s to match .ros file used in BASproc
                firopts.prefill = 48;
        end
        %%%%%%%%%% end mfir_03 %%%%%%%%%%
        
                
        %%%%%%%%%% mctd_checkplots %%%%%%%%%%
    case 'mctd_checkplots'
        switch oopt
            case 'plot_saltype'
                saltype = 'asal';
        end
        %%%%%%%%%% end mctd_checkplots %%%%%%%%%%
                
        
        %%%%%%%%%% populate_station_depths %%%%%%%%%%
    case 'populate_station_depths'
        switch oopt
            case 'depth_source'
                depth_source = {'ladcp' 'ctd'};
        end
        %%%%%%%%%% end populate_station_depths %%%%%%%%%%
        
        %%%%%%%%%% msec_grid %%%%%%%%%%
    case 'msec_grid'
        switch oopt
            case 'sections_to_grid'
	    sections = {'osnapeall'};
            case 'sec_stns_grids'
                switch section
                    case 'osnapeall'
                        kstns = [2:29];
                end
            case 'ctd_regridlist'
                ctd_regridlist = [ctd_regridlist 'fluor' 'ph'];
        end

end
