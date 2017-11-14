% this script sets defaults for various options in other scripts
% then calls the cruise-specific options script (opt_cruise) to make any changes
% and warns if expected options have not been set

cruise = MEXEC_G.MSCRIPT_CRUISE_STRING;

%%%%%%%%%% defaults, by script %%%%%%%%%%
switch scriptname


   %%%%%%%%%% ctd_evaluate_sensors %%%%%%%%%%
   case 'ctd_evaluate_sensors'
      switch oopt
         case {'tsensind','csensind','osensind'}
            sensind = {1:length(d.statnum)}; %default: no sensors changed out
      end
   %%%%%%%%%% end ctd_evaluate_sensors %%%%%%%%%%


   %%%%%%%%%% cond_apply_cal %%%%%%%%%%
   case 'cond_apply_cal'
      condout = cond;
   %%%%%%%%%% end cond_apply_cal %%%%%%%%%%

   %%%%%%%%%% oxy_apply_cal %%%%%%%%%%
   case 'oxy_apply_cal'
      oxyout = oxyin;
   %%%%%%%%%% end oxy_apply_cal %%%%%%%%%%

   %%%%%%%%%% temp_apply_cal %%%%%%%%%%
   case 'temp_apply_cal'
      tempout = tempin;
   %%%%%%%%%% end temp_apply_cal %%%%%%%%%%

   %%%%%%%%%% fluorcal %%%%%%%%%%
   case 'fluorcal'
      fluorout = fluor;
   %%%%%%%%%% end fluorcal %%%%%%%%%%

   %%%%%%%%%% numoxy %%%%%%%%%%
   case 'numoxy'
      numoxy = 1;
   %%%%%%%%%% end numoxy %%%%%%%%%%


   %%%%%%%%%% mbot_01 %%%%%%%%%%
   case 'mbot_01'
      switch oopt
         case 'infile'
	    %infile = [root_botcnv '/bot_' cruise '_' stn_string '.csv'];
	    infile = [root_botcnv '/bot_' cruise '_01.csv'];
      end
   %%%%%%%%%% end mbot_01 %%%%%%%%%%


   %%%%%%%%%% mcchdo_01 %%%%%%%%%%
   case 'mcchdo_01'
      switch oopt
         case 'expo'
            expocode = 'unknown';
            sect_id = 'unknown';
	     case 'outfile'
	         outfile = expocode;
     	 case 'headstr'
	         headstring = [];
       end
   %%%%%%%%%% end mcchdo_01 %%%%%%%%%%


   %%%%%%%%%% mcchdo_02 %%%%%%%%%%
   case 'mcchdo_02'
      switch oopt
         case 'expo'
            expocode = 'unknown';
            sect_id = 'unknown';
	 case 'outfile'
	       outfile = expocode;
      	 case 'headstr'
	       headstring = []; 
       end
   %%%%%%%%%% end mcchdo_02 %%%%%%%%%%


   %%%%%%%%%% mday_01_clean_av %%%%%%%%%%
   case 'mday_01_clean_av'
      %set cruise-specific calibration or editing actions
   %%%%%%%%%% end mday_01_clean_av %%%%%%%%%%
    
   %%%%%%%%%% mbot_00 %%%%%%%%%%
   case 'mbot_00' %information about niskin bottle numbers
      nis = 1:24; % default situation. bottles numbered 1 to 24 in position 1 to 24
      % default is not to change flag
   %%%%%%%%%% end mbot_00 %%%%%%%%%%


   %%%%%%%%%% mbot_01 %%%%%%%%%%
   case 'mbot_01' %information about bottle firing
      switch oopt
         case 'infile'
            infile1 = [root_bot '/bot_' cruise '_' 01 '.csv']; %default is a concatenated bottle-firing file
	 case 'botflags'
	    bottle_qc_flag = 2+zeros(size(statnum));
	    %optionally change bottle quality flags (i.e. if bottle didn't close properly)
      end
   %%%%%%%%%% end mbot_01 %%%%%%%%%%

   %%%%%%%%%% mctd_02a %%%%%%%%%%
   case 'mctd_02a'
      switch oopt
         case 'corraw' %edits to be applied to raw file (see di346)
      end
   %%%%%%%%%% end mctd_02a %%%%%%%%%%
   
   %%%%%%%%%% mctd_02b %%%%%%%%%%
   case 'mctd_02b'
      switch oopt
         case 'hyst'
            hyst_var_string = 'oxygen_sbe time press';
            hyst_pars = [-0.033 5000 1450]; %sbe default
            hyst_pars_string = sprintf('%f,%f,%f',hyst_pars(1),hyst_pars(2),hyst_pars(3));
            hyst_execute_string = ['y = mcoxyhyst(x1,x2,x3,' hyst_pars_string ')'];
	        oxy1name = 'oxygen';
      end
   %%%%%%%%%% end mctd_02b %%%%%%%%%%


   %%%%%%%%%% mctd_03 %%%%%%%%%%
   case 'mctd_03'
      switch oopt
         %optionally edit files using mcalib2--may be used to edit out bad scans or replace primary with secondary sensor values for set of bad scans
         %variable oopt specifies which file ('24hz', '1hz', 'psal')
         %default: no edits
         case '24hz'
	 case '1hz'
	 case 'psal'
	 case 's_choice'
	    s_choice = 1;
	    alternate = [];
	 case 'o_choice'
	    o_choice = 0; %not set unless there are two oxygen sensors
      end
   %%%%%%%%%% end mctd_03 %%%%%%%%%%


   %%%%%%%%%% mctd_04 %%%%%%%%%%
   case 'mctd_04'
      %switch oopt
      %   case 'pretreat'
      %end
   %%%%%%%%%% end mctd_04 %%%%%%%%%%
   

   %%%%%%%%%% mctd_checkplots %%%%%%%%%%
   case 'mctd_checkplots'
      switch oopt
         case 'pf1'
	    pf1.ylist = 'press temp psal oxygen';
	 case 'sdata1'
	    sdata = d{ks}.psal1; sdata2 = d{ks}.psal2; tis = 'psal'; sdata = d{ks}.psal;
	 case 'odata1'
	    odata1 = d{ks}.oxygen; odata2 = odata1;
      end
   %%%%%%%%%% end mctd_checkplots %%%%%%%%%%


   %%%%%%%%%% mctd_rawshow %%%%%%%%%%
   case 'mctd_rawshow'
      switch oopt
	 case 'pshow5'
	    pshow5.ylist = 'temp1 temp2 cond1 cond2 press oxygen';
	 case 'pshow2'
	    pshow2.ylist = 'pressure_temp press oxygen_sbe sbeoxyV ';
            %pshow2.ylist = 'pressure_temp press sbeox0Mm_slash_Kg ';
	 case 'pshow4'
            clear pshow4
	    pshow4.ncfile.name = infile1;
	    pshow4.xlist = 'time';
	    pshow4.ylist = 'latitude longitude';
	    pshow4.startdc = startdc;
	    pshow4.stopdc = stopdc;
   end
   %%%%%%%%%% end mctd_rawshow %%%%%%%%%%


   %%%%%%%%%% mctd_rawedit %%%%%%%%%%
   case 'mctd_rawedit'
      switch oopt
	      case 'badscans' %optionally edit bad scans out of raw data
	       case 'pshow1'
            pshow1.ylist = 'temp1 temp2 cond1 cond2 press oxygen_sbe';
            %pshow1.ylist = 'temp1 temp2 cond1 cond2 press sbeox0Mm_slash_Kg';
      end
   %%%%%%%%%% end mctd_rawedit %%%%%%%%%%


   %%%%%%%%%% mcfc_02 %%%%%%%%%%
   case 'mcfc_02'
      switch oopt
         case 'infile1'
         case 'cfclist'
      end
   %%%%%%%%%% end mcfc_02 %%%%%%%%%%


   %%%%%%%%%% mdcs_03 %%%%%%%%%%
   case 'mdcs_03'
      switch oopt
         case 'vstring' %default: single oxygen sensor
	    vstring1 = 'scan press psal1 psal2 oxygen cond1 cond2 temp1 temp2 time/';
	    vstring2 = 'scan press psal1 psal2 oxygen cond1 cond2 temp1 time/';
      end
   %%%%%%%%%% end mdcs_03 %%%%%%%%%%


   %%%%%%%%%% mfir_03 %%%%%%%%%%
   case 'mfir_03'
     fillstr = 'f';
   %%%%%%%%%% end mfir_03 %%%%%%%%%%


   %%%%%%%%%% mwin_01 %%%%%%%%%%
   case 'mwin_01'
      time_window = [-600 800];
   %%%%%%%%%% end mwin_01 %%%%%%%%%%


   %%%%%%%%%% mwin_03 %%%%%%%%%%
   case 'mwin_03'
      fix_string = [];
   %%%%%%%%%% end mwin_03 %%%%%%%%%%


   %%%%%%%%%% moxy_01 %%%%%%%%%%
   case 'moxy_01'
      switch oopt
         case 'oxycsv'
	       infile = [root_oxy '/oxy_' cruise '_' stn_string '.csv'];
	     case 'oxybotnisk'
	    %sometimes necessary to translate between bottle rows in the oxygen spreadsheet and Niskin places (see e.g. opt_jc145)
	     case 'flags'
      end
   %%%%%%%%%% end moxy_01 %%%%%%%%%%
	    
   %%%%%%%%%% moxy_ccalc %%%%%%%%%%
   case 'moxy_ccalc'
      switch oopt
         case 'oxypars'
	    lab_temp = 24; % lab temp (deg. C) (default)
            cal_temp = 20; % calibration temp (deg. C) for flasks
            vol_reag1 = 1; % MnCl2 vol (mL) (default)
            vol_reag2 = 1; % NaOH/NaI vol (mL) (default)
            mol_O2_reag = 0.5*7.6e-8; % mol/mL of dissolved oxygen in pickling reagents
            vol_std = 10;           % volume (mL) standard KIO3
            mol_std = 1.667*1e-6;   % molarity (mol/mL) of standard KIO3
            std_react_ratio = 6;       % # Na2S2O3/ KIO3 (mol/mol)
            sample_react_ratio = 1./4; % # O2/Na2S2O3 (mol/mol)
	 case 'blstd' %no defaults, blank and standard titre volumes are cruise-specific
	 case 'botvols'
	    fname_bottle = ['BOTTLE_OXY/bottle_vols.csv'];
      end
   %%%%%%%%%% end moxy_ccalc %%%%%%%%%%


   %%%%%%%%%% msal_01 %%%%%%%%%%
   case 'msal_01'
      switch oopt
         case 'salcsv'
	    sal_csv_file = ['sal_' cruise '_01.csv'];
	 case 'cellT'
	    %set cellT if it is not in database
	 case 'offset'
	    %set offset if standards or offset are not in database
	 case 'flag'
	    %set bottle/bottle reading flags
	 case 'indata'
	    %handle stations with no salts
	 case 'sstdagain'
	    sstdagain = 0; %default is to only run msal_standardise_avg once
      end
   %%%%%%%%%% end msal_01 %%%%%%%%%%


   %%%%%%%%%% msal_standardise_avg %%%%%%%%%%
   case 'msal_standardise_avg'
      switch oopt
         case 'std2use'
	    std2use = ones(length(ds_sal.r1),3);
	    doplot = 1;
         case 'sam2use'
	    sam2use = ones(size(sams));
	    salbotqf = 2+ones(length(iisam),1);
	    doplot = 1;
      end
   %%%%%%%%%% end msal_standardise_avg %%%%%%%%%%
   

   %%%%%%%%%% msbe35_01 %%%%%%%%%%
   case 'msbe35_01'
      switch oopt
         case 'flag'
      end
   %%%%%%%%%% end msbe35_01 %%%%%%%%%%


   %%%%%%%%%% msim_plot %%%%%%%%%%
   case 'msim_plot'
      switch oopt
         case 'sbathy'
	    bfile = '/local/users/pstar/cruise/data/tracks/s_atlantic';
      end
   %%%%%%%%%% end msim_plot %%%%%%%%%%

   %%%%%%%%%% msim_plot %%%%%%%%%%
   case 'mem120_plot'
      switch oopt
         case 'sbathy'
	    bfile = '/local/users/pstar/cruise/data/tracks/s_atlantic';
      end
   %%%%%%%%%% end mem120_plot %%%%%%%%%%


   %%%%%%%%%% mtsg_01 %%%%%%%%%%
   case 'mtsg_01'
      switch oopt
         case 'salcsv'
	    sal_csv_file = ['sal_' cruise '_01.csv'];
	 case 'cellT'
	    %set cellT if it is not in database
	 case 'offset'
	    %set offset if standards or offset are not in database
	 case 'flag'
	    %set bottle/bottle reading flags
	 case 'indata'
	    %handle stations with no salts
	 case 'sstdagain'
	    sstdagain = 0; %default is to only run msal_standardise_avg once
      end
   %%%%%%%%%% end mtsg_01 %%%%%%%%%%


   %%%%%%%%%% mtsg_bottle_compare %%%%%%%%%%
   case 'mtsg_bottle_compare'
      switch oopt
         case 'dbbad'
            %optionally NaN some of the db.salinity_adj points
	 case 'sdiff'
            sdiffsm = filter_bak(ones(1,21),sdiff); % harsh filter to determine smooth adjustment
      end
   %%%%%%%%%% end mtsg_bottle_compare %%%%%%%%%%


   %%%%%%%%%% mtsg_cleanup %%%%%%%%%%
   case 'mtsg_cleanup'
      switch oopt
         case 'kbadlims'
            %kbadlims = [t1 t2]; %bad from t1 to t2 (matlab datenum form)
	 case 'vout'
	    %can modify kbadall here, for all variables or selected variables
      end
   %%%%%%%%%% end mtsg_cleanup %%%%%%%%%%
   
   %%%%%%%%%% tsgsal_apply_cal %%%%%%%%%%
   case 'tsgsal_apply_cal'
      salout = salin;
   %%%%%%%%%% end tsgsal_apply_cal %%%%%%%%%%


   %%%%%%%%%% populate_station_depths %%%%%%%%%%
   case 'populate_station_depths'
      switch oopt
         case 'fnin'
	    fnin = [root_ctddep '/station_depths_' cruise '.txt'];
            a2 = load(fnin);
            stns = a2(:,1);
            deps = a2(:,2);
	    fnot = [root_ctddep '/station_depths_' cruise '.mat'];
	 case 'bestdeps'
      end
   %%%%%%%%%% end populate_station_depths %%%%%%%%%%


   %%%%%%%%%% smallscript %%%%%%%%%%
   case 'smallscript'
      switch oopt
         case 'klist'
      end
   %%%%%%%%%% end smallscript %%%%%%%%%%


   %%%%%%%%%% station_summary %%%%%%%%%%
   case 'station_summary'
      switch oopt
         case 'optsams'
	    snames = {}; sgrps = {}; sashore = []; %see opt_jr302
         case 'stnmiss'
	    stnmiss = []; %this is only for processed stations numbered between 1 and 900 that you don't want to include in the summary
	 case 'cordep'
	    cordep(k) = h1.water_depth_metres;
	 case 'comments'
            comments = cell(size(stnall));
	 case 'altdep'
	 case 'varnames'
            varnames={'statnum' 'time_start' 'time_bottom' 'time_end' 'lat' 'lon' 'cordep' 'maxd' 'minalt' 'resid' 'maxw' 'maxp' 'ndpths' 'nsal'}; %these probably won't change, but in any case the first 6 should always be the same
	    varnames = [varnames snames']; %if snames has been set in opt_cruise, this will incorporate it
            varunits = {'number' 'seconds' 'seconds' 'seconds' 'degrees' 'degrees' 'metres' 'metres' 'metres' 'metres' 'metres' 'dbar' 'number' 'number'};
            varunits = [varunits  repmat({'number'},1,length(snames)) ];
      end
   %%%%%%%%%% end station_summary %%%%%%%%%%

   %%%%%%%%%% vmadcp_proc %%%%%%%%%%
   case 'vmadcp_proc'
      switch oopt
         case 'aa0_75' %set approximate/nominal instrument angle
	    ang = 0; amp = 1;
	 case 'aa0_150' %set approximate/nominal instrument angle
	    ang = 0; amp = 1; 
         case 'aa75' %refined additional rotation and amplitude corrections based on btm/watertrk
	    ang = 0;
	    amp = 1; 
	 case 'aa150' %refined additional rotation and amplitude corrections based on btm/watertrk
	    ang = 0;
	    amp = 1; 
      end
   %%%%%%%%%% end vmadpc_proc %%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%
end




%%%%%%%%%% set options specific to this cruise %%%%%%%%%%
if exist(['opt_' cruise])==2
   eval(['opt_' cruise]);
else
   disp(['opt_' cruise ' not found; may need to be created to set cruise-specific options'])
end
%%%%%%%%%%%%%%%%%%%%





%%%%%%%%%% warning for unset options %%%%%%%%% ***
switch scriptname

   %%%%%%%%%% cond_apply_cal %%%%%%%%%%
   case 'cond_apply_cal'
      if ~exist('off') & ~exist('fac'); warning(['no cond cal set for sensor ' sensor]); end
   %%%%%%%%%% end cond_apply_cal %%%%%%%%%%

   %%%%%%%%%% tsgsal_apply_cal %%%%%%%%%%
   case 'tsgsal_apply_cal'
      if ~exist('off'); warning(['no salinity cal set for TSG']); end
   %%%%%%%%%% end cond_apply_cal %%%%%%%%%%
   
   %%%%%%%%%% temp_apply_cal %%%%%%%%%%
   case 'temp_apply_cal'
      if ~exist('tempadj'); warning(['no temp cal set for sensor ' sensor]); end
   %%%%%%%%%% end temp_apply_cal %%%%%%%%%%
   
   %%%%%%%%%% oxy_apply_cal %%%%%%%%%%
   case 'oxy_apply_cal'
      if ~exist('alpha') & ~exist('beta'); warning(['no oxy cal set']); end
   %%%%%%%%%% end cond_apply_cal %%%%%%%%%%

   %%%%%%%%%% fluor_apply_cal %%%%%%%%%%
   case 'fluor_apply_cal'
      if ~exist('fac') & ~exist('expco'); warning(['no fluor cal set']); end
   %%%%%%%%%% end cond_apply_cal %%%%%%%%%%
   

   %%%%%%%%%% mcfc_02 %%%%%%%%%%
   case 'mcfc_02'
      switch oopt
         case 'infile1'
	    if ~exist('infile1'); error(['must define infile for mcfc_02']); end
	 case 'cfclist'
	    if ~exist('cfclist'); error(['must define cfclist for mcfc_02']); end
      end
   %%%%%%%%%% end mcfc_02 %%%%%%%%%%

   %%%%%%%%%% msal_01 %%%%%%%%%%
   case 'msal_01'
      msg1 = ['You must set up a cruise specific case in this code,'];
      msg2 = ['in which you set the correct bath temperature and required adjustment to guildline values.'];
      msg3 = ['Follow jr302 as an example'];
      switch oopt
         case 'cellT'
            if ~sum(strcmp('cellT', ds_sal.Properties.VarNames))
               fprintf(2,'%s\n',msg1,msg2,msg3)
               error(['offset and cell temperature must be set for cruise ' cruise])
            end
	 case 'offset'
	    if ~sum(strcmp('offset', ds_sal.Properties.VarNames))
               fprintf(2,'%s\n',msg1,msg2,msg3)
               error(['offset and cell temperature must be set for cruise ' cruise])
            end
      end
   %%%%%%%%%% end msal_01 %%%%%%%%%%

%   %%%%%%%%%% mtsg_01 %%%%%%%%%%
%   case 'mtsg_01'
%      if ~exist('bath_temperature') | ~exist('adj') | max(size(adj)-size(sampnum))+max(size(bath_temperature)+size(sampnum))~=0
%         msg1 = ['You must set up a cruise specific case in this code,'];
%         msg2 = ['in which you set the correct bath temperature and required adjustment to guildline values.'];
%         msg3 = ['Follow jr302 as an example'];
%         fprintf(2,'%s\n',msg1,msg2,msg3)
%	 error(['adj and bath temperature must be set for cruise ' cruise])
%      end
%   %%%%%%%%%% end mtsg_01 %%%%%%%%%%

   %%%%%%%%%% sal_standardise_avg %%%%%%%%%%
   case 'msal_standardise_avg'
      switch oopt
         case 'std2use'
	    if ~exist('std2use'); disp('set autosal standards readings to use for this cruise'); keyboard; end
         case 'sam2use'
	    if ~exist('sam2use'); disp('set salinity sample readings to use for this cruise'); keyboard; end
      end
   %%%%%%%%%% end sal_standardise_avg %%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%
end
