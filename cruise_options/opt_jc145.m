switch scriptname

   %%%%%%%%%% mcchdo_02 %%%%%%%%%%
   case 'mcchdo_02'
      switch oopt
         case 'expo'
	    expocode = 'jc145';
            sect_id = 'RAPID_2017';
	 case 'outfile'
	    outfile = ['RAPID_jc145'];
      end
   %%%%%%%%%% end mcchdo_02 %%%%%%%%%%

   %%%%%%%%%% ctd_evaluate_sensors %%%%%%%%%%
   case 'ctd_evaluate_sensors'
      switch oopt
         case {'csensind','osensind'}
	    if sensnum==1 | sensnum==2
	       sensind(1,1) = {find(d.statnum<=6)}; %first CTD set (all sensors)
	       sensind(2,1) = {find(d.statnum>=7)}; %second CTD set (all sensors)
	    end
      end
   %%%%%%%%%% end ctd_evaluate_sensors %%%%%%%%%%

   %%%%%%%%%% cond_apply_cal %%%%%%%%%%
   case 'cond_apply_cal'
     switch stn
       case {1 2 3 4 5 6}
          switch sensor
            case 1
	      off = ( 0.03006 - 0.00934*press/1000 -0.00512*temp)/1000;
	    case 2
	      off = ( 0.06040 - 0.01482*press/1000 -0.00634*temp)/1000;
          end
       case {7 8 9 10 11 12 13 14 15 16 17 18 19 20 21 22 23 24 25}
          switch sensor
            case 1
	      off = (-0.02086 - 0.00732*press/1000 -0.00554*temp)/1000;
	    case 2
	      off = ( 0.02576 - 0.01267*press/1000 -0.00308*temp)/1000;
          end
      end
      fac = 1 + off;
      condout = cond.*fac;
   %%%%%%%%%% end cond_apply_cal %%%%%%%%%%

   %%%%%%%%%% tsgsal_apply_cal %%%%%%%%%%
   case 'tsgsal_apply_cal'
      %off = -0.0152; 
      off = (-0.0001/86400)*time-0.00763;
      salout = salin + off;
   %%%%%%%%%% end tsgsal_apply_cal %%%%%%%%%%

   %%%%%%%%%% oxy_apply_cal %%%%%%%%%%
   case 'oxy_apply_cal'
      switch sensor
         case 1
%      if stn<=23
%         alpha = 1.0427 - 4e-4*stn; 
%         beta = 3.1262 + 12e-4*press;
%      elseif stn>=24
%	 alpha = 1.3317 - 104e-4*stn;
%	 beta = 15.0859; %not enough samples (particularly as these are on cont. slope) to resolve pressure dependence
%      end
      end
%      oxyout = alpha.*oxyin + beta;
%      oxyout = (oxyin - beta)./alpha; %use this line to undo the one above
   %%%%%%%%%% end oxy_apply_cal %%%%%%%%%%
   
   %%%%%%%%%% numoxy %%%%%%%%%%
   case 'numoxy'
      numoxy = 2;
   %%%%%%%%%% end mctd_oxycal %%%%%%%%%%


   %%%%%%%%%% mctd_02b %%%%%%%%%%
   case 'mctd_02b'
      switch oopt
         case 'hyst'
	        hyst_var_string = 'oxygen_sbe1 time press';
	        hyst_var_string2 = 'oxygen_sbe2 time press';
	        hyst_pars  = [-0.0 5000 1450]; %  Std value is -0.033 but put = 0 to not apply
			hyst_pars_deep = [-0.0 4200 5000];
	        hyst_pars2 = [-0.0 5000 1450]; %  N
			hyst_pars_deep2 = [-0.0 4200 5000];
            hyst_pars_string = sprintf('[%f,%f,%f]',hyst_pars);
            hyst_pars_string2 = sprintf('[%f,%f,%f]',hyst_pars2);
            hyst_pars_deep_string = sprintf('[%f,%f,%f]',hyst_pars_deep);
            hyst_pars_deep_string2 = sprintf('[%f,%f,%f]',hyst_pars_deep2);
	        hyst_execute_string = ['y = mcoxyhyst_mod(x1,x2,x3,' hyst_pars_string  ',' hyst_pars_deep_string ')'];
	        hyst_execute_string2 = ['y = mcoxyhyst_mod(x1,x2,x3,' hyst_pars_string2  ',' hyst_pars_deep_string2 ')'];
	        oxy1name = 'oxygen1';
	        oxy2name = 'oxygen2';
%        case 'hyst'
%            hyst_var_string = 'oxygen_sbe1 time press';
%            hyst_var_string2 = 'oxygen_sbe2 time press';
%            hyst_pars = [-0.033 5000 1450]; %sbe default
%            hyst_pars = [ 0 5000 1450]; % NO CORRECTION
%               hyst_pars_string = sprintf('%f,%f,%f',hyst_pars(1),hyst_pars(2),hyst_pars(3));
%            hyst_pars2 = [0 5000 1450]; %  NO CORRECTION
%               hyst_pars_string2 = sprintf('%f,%f,%f',hyst_pars2(1),hyst_pars2(2),hyst_pars2(3));
%               hyst_execute_string = ['y = mcoxyhyst(x1,x2,x3,' hyst_pars_string  ')'];
%            oxy1name = 'oxygen1';
%            oxy2name = 'oxygen2';
      end
   %%%%%%%%%% end mctd_02b %%%%%%%%%%


   %%%%%%%%%% mctd_03 %%%%%%%%%%
   case 'mctd_03'
      switch oopt
         case 's_choice'
	        s_choice = 2; %use T,C 2
	        alternate = [1:6]; %stations on which to use the other sensor
	 case 'o_choice'
	        o_choice = 2; %use oxygen 2
	        alternate = []; %stations on which to use the other sensor
      end
   %%%%%%%%%% end mctd_03 %%%%%%%%%%


   %%%%%%%%%% mctd_checkplots %%%%%%%%%%
   case 'mctd_checkplots'
      switch oopt
         case 'pf1'
	    pf1.ylist = 'press temp asal oxygen';
	 case 'sdata'
	    sdata1 = d{ks}.asal1; sdata2 = d{ks}.asal2; tis = 'asal'; sdata = d{ks}.asal;
	 case 'odata'
	    odata1 = d{ks}.oxygen1; odata2 = d{ks}.oxygen2;
      end
   %%%%%%%%%% end mctd_checkplots %%%%%%%%%%
   

   %%%%%%%%%% mctd_rawshow %%%%%%%%%%
   case 'mctd_rawshow'
      switch oopt
	 case 'pshow5'
	    pshow5.ylist = 'temp1 temp2 cond1 cond2 press oxygen1 oxygen2';
	 case 'pshow2'
	    pshow2.ylist = 'press oxygen_sbe1 oxygen_sbe2';
	 case 'pshow4'
	    pshow4 = [];
      end
   %%%%%%%%%% end mctd_rawshow %%%%%%%%%%


   %%%%%%%%%% mctd_rawedit %%%%%%%%%%
   case 'mctd_rawedit'
      switch oopt
	 case 'pshow1'
            pshow1.ylist = 'temp1 temp2 cond1 cond2 press oxygen_sbe1 oxygen_sbe2';
      end
   %%%%%%%%%% end mctd_rawedit %%%%%%%%%%

   %%%%%%%%%% mdcs_03 %%%%%%%%%%
   case 'mdcs_03'
      switch oopt
         case 'vstring' %two oxygen sensors
	    vstring1 = 'scan press psal1 psal2 oxygen1 oxygen2 cond1 cond2 temp1 temp2 time/';
	    vstring2 = 'scan press psal1 psal2 oxygen1 oxygen2 cond1 cond2 temp1 time/';
      end
   %%%%%%%%%% end mdcs_03 %%%%%%%%%%


   %%%%%%%%%% moxy_01 %%%%%%%%%%
   case 'moxy_01'
      switch oopt
         case 'oxybotnisk'
	    	 ds_oxy.niskin = ds_oxy.botnum*2; %only even Niskins on the rosette
      end
   %%%%%%%%%% end moxy_01 %%%%%%%%%%


   %%%%%%%%%% msal_01 %%%%%%%%%%
   case 'msal_01'
      switch oopt
         case 'salcsv'
	        sal_csv_file = 'sal_jc145_01.csv';
	     case 'cellT'
	        ds_sal.cellT = 21+zeros(length(ds_sal.sampnum),1);
         case 'flag'
%	    if stnlocal==5
%	       flag(ismember(salbot,[18 20])) = 3; %questionable
%           end
	        doplot = 0;
	 case 'offset'
	        ds_sal.offset = zeros(length(ds_sal.sampnum),1);
	        ds_sal.offset(ismember(ds_sal.sampnum,[ 1:224])) = 0;
	        ds_sal.offset(ismember(ds_sal.sampnum,[ 300:1024])) = 0.000085;
	        ds_sal.offset(ismember(ds_sal.sampnum,[1100:2524])) = 0.000160;
         case 'sstdagain'
	        sstdagain = 0;
      end
   %%%%%%%%%% end msal_01 %%%%%%%%%%


   %%%%%%%%%% msal_standardise_avg %%%%%%%%%%
   case 'msal_standardise_avg'
      switch oopt
         case 'std2use'
%	       std2use  = zeros(25,1);
%	       std2use([1 2 3 10 11 25]) = 1; 
%	       doplot = 0;
         case 'sam2use'
            %sam2use(73,2) = 0; sam2use(91,1) = 0;
            %salbotqf([]) = 3;
	    doplot = 0;
      end
   %%%%%%%%%% end msal_standardise_avg %%%%%%%%%%


   %%%%%%%%%% msbe35_01 %%%%%%%%%%
   case 'msbe35_01'
%      switch oopt
%         case 'flag'
%            % these might have been closed too quickly for a good reading
%            sbe35flag(isnan(sbe35temp)) = 9;
%            if stnlocal==22
%                sbe35flag(position == 9) = 4;
%            end
%            if stnlocal == 24
%                sbe35flag(position == 6 | position ==9) = 4;
%            end
%            if stnlocal == 27
%                sbe35flag(position == 17) = 4;
%            end
%      end
   %%%%%%%%%% end msbe35_01 %%%%%%%%%%
   

   %%%%%%%%%% msim_plot %%%%%%%%%%
   case 'msim_plot'
      switch oopt
         case 'sbathy'
	    bfile = '/local/users/pstar/cruise/data/tracks/n_atlantic';
      end
   %%%%%%%%%% end msim_plot %%%%%%%%%%

   %%%%%%%%%% mem120_plot %%%%%%%%%%
   case 'mem120_plot'
      switch oopt
         case 'sbathy'
	    bfile = '/local/users/pstar/cruise/data/tracks/n_atlantic';
      end
   %%%%%%%%%% end mem120_plot %%%%%%%%%%


   %%%%%%%%%% msal_01 %%%%%%%%%%
   case 'mtsg_01'
      switch oopt
         case 'salcsv'
	    sal_csv_file = 'sal_jc145_01.csv';
	 case 'cellT'
	    ds_sal.cellT = 21+zeros(length(ds_sal.sampnum),1);
         case 'flag'
%	    flag(ismember(ds_sal.sampnum, [])) = 3; %questionable
	    doplot = 0;
         case 'sstdagain'
	    sstdagain = 1;
      end
   %%%%%%%%%% end mtsg_01 %%%%%%%%%%

   %%%%%%%%%% mtsg_cleanup %%%%%%%%%%
   case 'mtsg_cleanup'
      switch oopt
         case 'kbadlims'
	    kbadlims = [datenum([2017 02 09 15 45 00])  datenum([2017 02 21 14 10 00])
        datenum([2017 02 23 11 24 00])  datenum([2017 02 28 15 39 00])
        datenum([2017 03 27 11 32 00])  datenum([2017 03 28 07 04 00])
            ];
%         case 'vout'
%            %keep kbadall as-is
      end
   %%%%%%%%%% end mtsg_cleanup %%%%%%%%%%



    %%%%%%%%%% sal_standardise_avg %%%%%%%%%%
   case 'sal_standardise_avg'
      switch oopt
         case 'std2use'
	    std2use = ones(size(offs));
	    %keyboard %initially
%	    std2use(33:34, 1) = 0;
%            std2use(35, :) = 0;
         case 'sam2use'
	    sam2use = ones(size(sams)); salbotqf = 2+zeros(size(sams,1),1);
            %ii = find(ds_sal.station_day(iisam)<0); %these are for TSG
            %subplot(3,1,2:3); plot(ii, sams0(ii,1), 'o', ii, sams0(ii,2), 's', ii, sams0(ii,3), '<'); title('tsg'); keyboard
            %stnos = unique(ds_sal.station_day(ds_sal.station_day>0)); %plot for all CTDs
            %for no = 1:length(stnos)
            %   ii = find(ds_sal.station_day(iisam)==stnos(no));
            %   subplot(3,1,2:3); plot(ii, sams0(ii,1), 'o', ii, sams0(ii,2), 's', ii, sams0(ii,3), '<'); title(['ctd ' num2str(stnos(no))]); keyboard
            %end
            sam2use(73,2) = 0; sam2use(91,1) = 0;
            %salbotqf***
      end
   %%%%%%%%%% end sal_standardise_avg %%%%%%%%%%


   %%%%%%%%%% smallscript %%%%%%%%%%
   case 'smallscript'
      switch oopt
         case 'klist'
		   klist = 1:5;
	       klist = 7:16; %***
      end
   %%%%%%%%%% end smallscript %%%%%%%%%%


   %%%%%%%%%% station_summary %%%%%%%%%%
   case 'station_summary'
      switch oopt
         case 'optsams'
%	    snames = {'noxy'}; sgrps = {'oxy'}; 
            sashore = 0;
         case 'stnmiss'
	    stnmiss = [];
	 case 'comments'
            comments = cell(size(stnset));
      end
   %%%%%%%%%% end station_summary %%%%%%%%%%

   %%%%%%%%%% vmadcp_proc %%%%%%%%%%
   case 'vmadcp_proc'
      switch oopt
         case 'aa0_75' %set approximate/nominal instrument angle and amplitude
            ang = -10.0; amp = 1; 
         case 'aa0_150' %set approximate/nominal instrument angle and amplitude
            ang = -1.3; amp = 1;  %-1.3            ang = 0;
	    %if seq<6; ang = -0.2; else; ang = -0.1; end
	    amp = 1; 
         case 'aa150' %refined additional rotation and amplitude corrections based on btm/watertrk
            ang = 0;
	    amp = 1; 
      end
   %%%%%%%%%% end vmadpc_proc %%%%%%%%%%

end
