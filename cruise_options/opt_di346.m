switch scriptname


   %%%%%%%%%% mday_01_clean_av %%%%%%%%%%
   case 'mday_01_clean_av'
      switch abbrev
         case 'surfmet'
            if ~exist([otfile '.nc'])
               unix(['/bin/cp ' infile '.nc ' otfile '.nc']);
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
	    dir_T = [MEXEC_G.MEXEC_DATA_ROOT '/met/surfmet/'];
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
   %%%%%%%%%% end mday_01_clean_av %%%%%%%%%%

    
   %%%%%%%%%% mcchdo_01 %%%%%%%%%%
   case 'mcchdo_01'
      switch oopt
         case 'headstr'
            headstring = ['# There are 12 instances of the bottle quality flag being set to 10. '];
            headstring = [headstring 'These correspond to cases where there was something anomalous '];
            headstring = [headstring 'about the bottle closure. The samples are believed to be good. '];
            headstring = [headstring 'In 9 of these cases the shallowest bottle was at 5 metres depth and'];
            headstring = [headstring 'appeared to have closed normally. The CFC sampler reported that a dribble '];
            headstring = [headstring 'leaked out of the bottom tap when it was pushed in even though the top vent was still closed. '];
      end
   %%%%%%%%%% end mcchdo_01 %%%%%%%%%%


   %%%%%%%%%% mctd_02a %%%%%%%%%%
   case 'mctd_02a'
      switch oopt
         case 'corraw'
            % adcp, fluor and trans off for some stations greater than 6000 metres
            stn_list = [64 200 65 66 67 68 69 ];
            kmat = find(stn_list == stnlocal);
            if ~isempty(kmat)
            % for these stations on this cruise we set fluor and trans to absent
            MEXEC_A.MARGS_IN = {
               infile
               'y'
               'fluor'
               'y = x+nan'
               ' '
               ' '
               'transmittance'
               'y = x+nan'
               ' '
               ' '
               ' '
            };
            mcalib
      end
   %%%%%%%%%% end mctd_02a %%%%%%%%%%

   %%%%%%%%%% mctd_02b %%%%%%%%%%
   case 'mctd_02b'
      switch oopt
         case 'hyst'
            stn_list = [1:64]; 
            if ismember(stnlocal, stn_list)
               % for these stations on this cruise; 
               infile = [infile '_o2reverse'];
               hyst_var_string = 'oxygen_sbe_reverse time press';
            end
            stn_list = [37:500];% second oxygen sensor
            stn_list_first = [1:36]; % second oxygen sensor
            if ismember(stnlocal, stn_list)
               % for these stations on this cruise; 
               hyst_pars = [-0.028 5000 2500];
            end
            if ismember(stnlocal, stn_list_first)
               % for these stations on this cruise; 
               hyst_pars = [-0.037 5000 1450];
            end
            if ismember(stnlocal, 200);
               % for these stations on this cruise; 
               hyst_pars = [-0.035 5000 2000];
            end
            hyst_pars_string = sprintf('%f,%f,%f',hyst_pars(1),hyst_pars(2),hyst_pars(3));
            hyst_execute_string = ['y = mcoxyhyst(x1,x2,x3,' hyst_pars_string ')'];
      end
   %%%%%%%%%% end mctd_02b %%%%%%%%%%
   
   %%%%%%%%%% mctd_03 %%%%%%%%%%
   case 'mctd_03'
      switch oopt
         case 's_choice'
	    s_choice = 1; % default, 1 = primary
            alternate = [1:49]; % list of station numbers for which secondary is preferred
      end
   %%%%%%%%%% end mctd_03 %%%%%%%%%%
   
   %%%%%%%%%% mctd_04 %%%%%%%%%%
   case 'mctd_04'
     switch oopt
        case 'pretreat'
	   if stnlocal==12
              copystr={[sprintf('%d',round(dcstart)) ' 721'];['740 ' sprintf('%d',round(dcbot))]}; %remove wake cycles before making 2db
	   end
      end
   %%%%%%%%%% end mctd_04 %%%%%%%%%%


%%%%%%%%%%%%%%%%%%
end