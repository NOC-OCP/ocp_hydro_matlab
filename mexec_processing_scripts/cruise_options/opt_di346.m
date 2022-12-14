switch scriptname
    
    
    %%%%%%%%%% mday_01_clean_av %%%%%%%%%%
    case 'mday_01_clean_av'
        switch oopt
            case 'uway_apply_cal'
                switch abbrev
                    case 'surfmet'
                        if ~exist([otfile '.nc'])
                            copyfile(m_add_nc(infile), m_add_nc(otfile));
                        end
                        % CALIBRATION
                        A = -1.17483;
                        B = 1.00152;
                        [d h] = mload(otfile,'press',' ');
                        [dt ht] = mload(otfile,'time',' ');
                        time_p = getfield(dt, 'time');
                        data_raw = getfield(d, 'press');
                        data_calib = A + B.*data_raw;
                        % CORRECT FOR HEIGHT OF MOUNTED BAROMETER ABOVE SEA LEVEL
                        % Assume hydrostatic (dw/dz ~ 0)  dp/dz = -rho*g = -pg/RT
                        % and well mixed BL ==> T = const between sfc and estimated z
                        % then Pz = Psfc*exp(-z*g/Rd*T) ==>  Psfc = Pz/exp(-z/H)
                        % where z =  height of mounting ~ 16.10m on di346
                        Rd = 287.05;
                        g = 9.81;
                        % pickup temperature on mast from surfmet data
                        dir_T = fullfile(MEXEC_G.MEXEC_DATA_ROOT, 'met', 'surfmet');
                        ncfileT.name = [dir_T 'met_' cruise '_d' daystr '_' MEXEC.status '.nc'];
                        [dT1 hT1] = mload([ncfileT.name],'airtemp',' ');
                        T_today = getfield(dT1, 'airtemp');
                        [dt1 ht1] = mload([ncfileT.name],'time',' ');
                        time_today = getfield(dt1, 'time');
                        % Assume temperature is mixed to a constant profile in the surface layer
                        % over a period of n minutes. Here 30mins is assumed reasonable
                        % (both the nocturnal and daytime ABL are to be smoothed. bad for nocturnal?)
                        % Apply n minute median despiking to airtemp data and use smoothed
                        % T(t) profile in the P correction.
                        n = 60; % smoothing period in minutes
                        Tsmooth = met_median(T_today,time_today,day,n); % call function to smooth airtemp profile
                        T_smoothed = Tsmooth.T_smoothed;
                        % efolding height
                        H = (Rd.*(T_smoothed+273.15))/g;                 % T IN KELVIN
                        z = 16.10*ones(size(H,1),size(H,2));
                        data_zcorrect = data_calib.*(1/exp(-z/H));
                        % SAVE CORRECTED DATA TO 'calib_.nc' FILE
                        MEXEC_A.MARGS_IN = {otfile 'time_p' 'data_zcorrect' ' ' ' ' '8' '0' 'time' 'seconds' 'press_zcorrected' 'mb' ' ' ' '}
                        msave;
                    case 'surflight'
                        % pyranometer
                        PPAR_SCALE = 11.04;   % micro volts per W/m/m
                        SPAR_SCALE = 10.53;   % micro volts per W/m/m
                        PTIR_SCALE = 9.60;    % micro volts per W/m/m
                        STIR_SCALE = 9.76;    % micro volts per W/m/m
                        % -------------
                        % convert volts
                        % -------------
                        MEXEC_A.MARGS_IN = {
                            otfile
                            'y'
                            'ppar'
                            'y = x*0.01104'
                            'ppar_calc'
                            'W/m^2'
                            'spar'
                            'y = x*0.01053'
                            'spar_calc'
                            'W/m^2'
                            'ptir'
                            'y = x*0.00960'
                            'ptir_calc'
                            'W/m^2'
                            'stir'
                            'y = x*0.00976'
                            'stir_calc'
                            'W/m/m'
                            ' '
                            };
                        mcalib
                end
        end
        %%%%%%%%%% end mday_01_clean_av %%%%%%%%%%
        
        
        %%%%%%%%%% mout_cchdo_sam %%%%%%%%%%
    case 'mout_cchdo_sam'
        switch oopt
            case 'headstr'
                headstring = ['# There are 12 instances of the bottle quality flag being set to 10. '];
                headstring = [headstring 'These correspond to cases where there was something anomalous '];
                headstring = [headstring 'about the bottle closure. The samples are believed to be good. '];
                headstring = [headstring 'In 9 of these cases the shallowest bottle was at 5 metres depth and'];
                headstring = [headstring 'appeared to have closed normally. The CFC sampler reported that a dribble '];
                headstring = [headstring 'leaked out of the bottom tap when it was pushed in even though the top vent was still closed. '];
        end
        %%%%%%%%%% end mout_cchdo_sam %%%%%%%%%%
        
        
        %%%%%%%%%% mctd_02a %%%%%%%%%%
    case 'mctd_02a'
        switch oopt
            case 'absentvars'
                % adcp, fluor and trans off for some stations greater than 6000 metres
                stn_list = [64 200 65 66 67 68 69 ];
                if ismember(stnlocal, stn_list)
                    absentvars = {'fluor' 'transmittance'};
                end
        end
        %%%%%%%%%% end mctd_02a %%%%%%%%%%
        
        %%%%%%%%%% mctd_02b %%%%%%%%%%
    case 'mctd_02b'
        % di346 oxygen hysteresis reworked by GDM.
        % for stations up to  and including 064, apply sbe_reverse first
        % Then apply forwards hysteresis adjustment with GDM's preferred parameters
        switch oopt
            case 'raw_corrs'
                if ismember(stnlocal, [1:64])
                    %reverse sbe processing correction first (using default parameters), then apply custom correction
                    dooxyrev = -1; dooxyhyst = 1;
                end
            case 'oxyhyst'
                if ismember(stnlocal, 1:36)
                    H1 = -0.037; H2 = 5000; H3 = 1450; %custom pars for first oxygen sensor on this cruise
                elseif ismember(stnlocal, 200);
                    H1 = -0.035; H2 = 5000; H3 = 2000;
                elseif ismember(stnlocal, 37:500)
                    H1 = -0.028; H2 = 5000; H3 = 2500; %custom pars for second oxygen sensor on this cruise
                end
        end
        %%%%%%%%%% end mctd_02b %%%%%%%%%%
        
        %%%%%%%%%% mctd_03 %%%%%%%%%%
    case 'mctd_03'
        switch oopt
            case 's_choice'
                stns_alternate_s = [1:49]; % list of station numbers for which secondary is preferred
        end
        %%%%%%%%%% end mctd_03 %%%%%%%%%%
        
        %%%%%%%%%% mctd_04 %%%%%%%%%%
    case 'mctd_04'
        switch oopt
            case 'pre_2_treat'
                if stnlocal==12
                    copystr={[sprintf('%d',round(dcstart)) ' 721'];['740 ' sprintf('%d',round(dcbot))]}; %remove wake cycles before making 2db
                end
        end
        %%%%%%%%%% end mctd_04 %%%%%%%%%%
        
        %%%%%%%%%% mdcs_01 %%%%%%%%
    case 'mdcs_01'
        switch oopt
            case 'kbot'
                if stnlocal==81
                    kbot = 5574;
                end
        end
        %%%%%%%%%% end mdcs_01 %%%%%%%%
        
        
        %%%%%%%%%% msec_run_mgridp %%%%%%%%%%
    case 'msec_run_mgridp'
        switch oopt
            case 'sections'
                sections = {'fc' '24n'};
            case 'sec_stns'
                switch section
                    case 'fc'
                        kstns = 2:13;
                    case '24n'
                        kstns = [14:16 18 17 19:135];
                end
        end
        %%%%%%%%%% end msec_run_mgridp %%%%%%%%%%
        
        
        %%%%%%%%%% m_maptracer %%%%%%%%%%
    case 'm_maptracer'
        switch oopt
            case 'kstatgroups'
                kstatgroups = {[2:13] [14:200]};
        end
        %%%%%%%%%% end m_maptracer %%%%%%%%%%
        
        
        %%%%%%%%%%%%%%%%%%
end