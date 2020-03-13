% this script sets defaults for various options in other scripts
% then calls the cruise-specific options script (opt_cruise) to make any changes
% and warns if expected options have not been set

mcruise = MEXEC_G.MSCRIPT_CRUISE_STRING;
shiptsg = {'cook' 'met_tsg'; 'discovery' 'met_tsg'; 'jcr' 'oceanlogger'};

%%%%%%%%%% defaults, by script %%%%%%%%%%


switch scriptname
    
    
    %%%%%%%%%% minit %%%%%%%%%%
    case 'minit'
        stn_string = sprintf('%03d',stn);
    %%%%%%%%%% end minit %%%%%%%%%%

    %%%%%%%%%% smallscript %%%%%%%%%%
    case 'smallscript' %this is just used to set the list of stations to run (in, for instance, smallscript_*)
        switch oopt
            case 'klist'
        end
        %%%%%%%%%% end smallscript %%%%%%%%%%
        
        
        %%%%%%%%%% mctd_01 %%%%%%%%%%
    case 'mctd_01'
        switch oopt
            case 'redoctm'
                redoctm = 0; %default: operate on _ctm.cnv file
        end
        %%%%%%%%%% end mctd_01 %%%%%%%%%%
        
        %%%%%%%%%% mctd_02a %%%%%%%%%%
    case 'mctd_02a'
        switch oopt
            case 'corraw'
                %edits to be applied to raw file (see di346)
                %and, if celltm is to be run, parameters for edits to apply first, and
                %list of oxygen variable names to apply align to
                %ovars, revars, dsvars, and pvars must be set if redoctm is ever true
                %see opt_jc159
                sevars = []; %default is not to scanedit (besides pumps off times)
                %even if redoing celltm
        end
        %%%%%%%%%% end mctd_02a %%%%%%%%%%
        
        %%%%%%%%%% mctd_02b %%%%%%%%%%
    case 'mctd_02b'
        switch oopt
            case 'calibs_to_do'
                dooxyhyst = 1;
                doturbV = 0;
            case 'oxyrev' %reverse oxy hyst correction. this only comes up if ismember(dooxyhyst,-1)
                var_strings = {'oxygen_sbe1 time press'};
                pars = {[-0.033 5000 1450]}; %sbe default parameters
                varnames = {'oxygen_sbe1_rev'};
                h = m_read_header(infile);
                if sum(strcmp('oxygen_sbe2',h.fldnam))
                    var_strings = [var_strings; 'oxygen_sbe2_rev time press'];
                    pars(2) = pars(1);
                    varnames = [varnames; 'oxygen2'];
                end
            case 'oxyhyst' %this only comes up if ismember(dooxyhyst,1)
                var_strings = {'oxygen_sbe1 time press'};
                pars = {[-0.033 5000 1450]}; %sbe default
                varnames = {'oxygen1'};
                h = m_read_header(infile);
                if sum(strcmp('oxygen_sbe2',h.fldnam))
                    var_strings = [var_strings; 'oxygen_sbe2 time press'];
                    pars(2) = pars(1);
                    varnames = [varnames; 'oxygen2'];
                end
            case 'turbV' %this only comes up if doturbV=1
                var_string = 'turbidityV';
                pars = [3.343e-3 6.600e-2]; %from XMLCON for BBRTD-182, calibration date 6 Mar 17
                varname = 'turbidity';
        end
        %%%%%%%%%% end mctd_02b %%%%%%%%%%
        
        %%%%%%%%%% mcoxyhyst %%%%%%%%%%
    case 'mcoxyhyst'
        %default is that hysteresis parameters are passed to the function as input arguments
        %%%%%%%%%% end mcoxyhyst %%%%%%%%%%
        
        %%%%%%%%%% mctd_03 %%%%%%%%%%
    case 'mctd_03'
        switch oopt
            %optionally edit files using mcalib2--may be used to edit out bad scans or replace primary with secondary sensor values for set of bad scans
            %variable oopt specifies which file ('24hz', '1hz', 'psal')
            %default: no edits
            case '24hz'
                if MEXEC_G.MDEFAULT_DATA_TIME_ORIGIN(1)<=2019 | strcmp(MEXEC_G.MSCRIPT_CRUISE_STRING,'jc191')
                    interp24 = 0; 
                else
                    interp24 = 1; maxgap = 12; %***
                end
            case 'psal'
            case 's_choice' %this applies to both t and c
                s_choice = 1;
                alternate = [];
            case 'o_choice'
                o_choice = 1;
                alternate = [];
        end
        %%%%%%%%%% end mctd_03 %%%%%%%%%%
        
        %%%%%%%%%% mctd_04 %%%%%%%%%%
    case 'mctd_04'
        switch oopt
            case 'pretreat'
            case 'doloopedit'
                doloopedit = 0;
                ptol = 0.08; %default is not to apply, but this would be the default value if you did
            case 'interp2db'
                if MEXEC_G.MDEFAULT_DATA_TIME_ORIGIN(1)<=2019 | strcmp(MEXEC_G.MSCRIPT_CRUISE_STRING,'jc191')
                    interp2db = 1; %filling gaps in 2dbar data used to be standard
                else
                    interp2db = 0; %don't think it should be anymore; instead fill gaps (of limited length) in 24 hz data before averaging
                end
        end
        %%%%%%%%%% end mctd_04 %%%%%%%%%%
        
        %%%%%%%%%% mdcs_03 %%%%%%%%%%
    case 'mdcs_03'
        switch oopt
            case 'vstring' %default: single oxygen sensor
                vstring1 = 'scan press psal1 psal2 oxygen cond1 cond2 temp1 temp2 time/';
                vstring2 = 'scan press psal1 psal2 oxygen cond1 cond2 temp1 time/';
        end
        %%%%%%%%%% end mdcs_03 %%%%%%%%%%
        
        %%%%%%%%%% mfir_01 %%%%%%%%%%
    case 'mfir_01' %information about bottle firing
        switch oopt
            case 'fixbl'
                %should only very rarely need to use this (see opt_jc159)
        end
        %%%%%%%%%% end mfir_01 %%%%%%%%%%
        
        %%%%%%%%%% mbot_00 %%%%%%%%%%
    case 'mbot_00' %information about niskin bottle numbers
        switch oopt
            case 'fixbl'
                %should only very rarely need to use this (see opt_jc159)
            case 'nispos'
                nis = 1:24; % default situation. bottles numbered 1 to 24 in position 1 to 24
        end
        %%%%%%%%%% end mbot_00 %%%%%%%%%%
        
        %%%%%%%%%% mfir_03 %%%%%%%%%%
    case 'mfir_03'
        fillstr = 'f'; %default is to fill in NaNs
        avi_opt = 0; %default is to linearly interpolate, not average
        %%%%%%%%%% end mfir_03 %%%%%%%%%%
        
        %%%%%%%%%% mwin_01 %%%%%%%%%%
    case 'mwin_01'
        time_window = [-600 800];
        winch_time_start = nan; % nans will force read of times from CTD file
        winch_time_end = nan;
        %%%%%%%%%% end mwin_01 %%%%%%%%%%
        
        %%%%%%%%%% mwin_03 %%%%%%%%%%
    case 'mwin_03'
        fix_string = [];
        %%%%%%%%%% end mwin_03 %%%%%%%%%%
        
        
        
        %%%%%%%%%% mctd_checkplots %%%%%%%%%%
    case 'mctd_checkplots'
        switch oopt
            case 'pf1'
                pf1.ylist = 'press temp psal oxygen';
            case 'sdata'
                sdata1 = d{ks}.psal1; sdata2 = d{ks}.psal2; tis = 'psal'; sdata = d{ks}.psal;
            case 'odata'
                odata1 = d{ks}.oxygen1; odata2 = odata1; odata = d{ks}.oxygen;
        end
        %%%%%%%%%% end mctd_checkplots %%%%%%%%%%
        
        %%%%%%%%%% mctd_rawshow %%%%%%%%%%
    case 'mctd_rawshow'
        switch oopt
            case 'pshow5'
                pshow5.ylist = 'temp1 temp2 cond1 cond2 press oxygen1';
            case 'pshow2'
                pshow2.ylist = 'pressure_temp press oxygen_sbe1 sbeoxyV1';
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
            case 'autoeditpars'
                doscanedit = 0; %optionally set bad scans to be edited out of raw data (see opt_jr16002)
                dorangeedit = 0; %optionally set good data ranges to edit out-of-range values (see opt_jc159)
                dodespike = 0; %optionally despike using median despiker
            case 'pshow1'
                pshow1.ylist = 'temp1 temp2 cond1 cond2 press oxygen_sbe1';
        end
        %%%%%%%%%% end mctd_rawedit %%%%%%%%%%
        
        
        %%%%%%%%%% msal_01 %%%%%%%%%%
    case 'msal_01'
        switch oopt
            case 'indata'
                sal_mat_file = ['sal_' mcruise '_01.mat'];
            case 'flags'
                %set bottle/bottle reading flags
        end
        %%%%%%%%%% end msal_01 %%%%%%%%%%
        
        %%%%%%%%%% msal_standardise_avg %%%%%%%%%%
    case 'msal_standardise_avg'
        switch oopt
            case 'salcsv'
                sal_csv_file = ['sal_' mcruise '_01.csv'];
                sal_mat_file = ['sal_' mcruise '_01.mat'];
            case 'offset'
                %set offset if standards or offset are not in database
            case 'check_sal_runs'
                calc_offset = 1; %default is to calculate offset from standards readings - 2*K15
                check_sal_runs = 1; %default is to plot standards and sample runs to compare before averaging
                plot_all_stations = 0;
            case 'k15'
                %no default for this
            case 'std2use'
                std2use = ones(size(offs));
            case 'fillstd'
                %by default, interpolate offsets between standards points just using index
                %(this works if there is a standard at the beginning and end of each crate)
                xoff = 1:length(ds_sal.sampnum);
                %can also fill in missing values in ds_sal.offset here
            case 'cellT'
                %set cellT if it is not in database
            case 'sam2use'
                sam2use = ones(size(sams));
                salbotqf = 2+zeros(length(iisam),1);
        end
        %%%%%%%%%% end msal_standardise_avg %%%%%%%%%%
        
        %%%%%%%%%% msbe35_01 %%%%%%%%%%
    case 'msbe35_01'
        switch oopt
            case 'flag'
        end
        %%%%%%%%%% end msbe35_01 %%%%%%%%%%
        
        %%%%%%%%%% moxy_01 %%%%%%%%%%
    case 'moxy_01'
        switch oopt
            case 'oxycsv'
                infile = [root_oxy '/oxy_' mcruise '_all.csv'];
            case 'sampnum_parse'
                %default is not to get into this branch, but some cruises may require cases to parse station and niskin numbers out of strings (see opt_jc159 mnut_01 for example)
            case 'oxybotnisk'
                %sometimes necessary to translate between bottle rows in the oxygen spreadsheet and Niskin places (see e.g. opt_jc145)
            case 'flags'
        end
        %%%%%%%%%% end moxy_01 %%%%%%%%%%
        
        %%%%%%%%%% moxy_ccalc %%%%%%%%%%
    case 'moxy_ccalc'
        switch oopt
            case 'oxypars'
                cal_temp = 25; % calibration temp (deg. C) for flasks
                vol_reag1 = 1; % MnCl2 vol (mL) (default)
                vol_reag2 = 1; % NaOH/NaI vol (mL) (default)
                mol_O2_reag = 0.5*7.6e-8; % mol/mL of dissolved oxygen in pickling reagents
                vol_std = 10;           % volume (mL) standard KIO3
                mol_std = 1.667*1e-6;   % molarity (mol/mL) of standard KIO3
                std_react_ratio = 6;       % # Na2S2O3/ KIO3 (mol/mol)
                sample_react_ratio = 1./4; % # O2/Na2S2O3 (mol/mol)
            case 'blstd' %no defaults, blank and standard titre volumes are cruise-specific
            case 'botvols'
                %no defaults, these might be in a separate file or in the same file
            case 'compcalc'
                compcalc = 1; %if there are pre-calculated concentrations and concentrations calculated by moxy_ccalc, pause to compare them
        end
        %%%%%%%%%% end moxy_ccalc %%%%%%%%%%
        
        %%%%%%%%%% msam_oxykg %%%%%%%%%%
    case 'msam_oxykg'
        iib = '[]'; %just have botoxy = botoxya, etc.
        %%%%%%%%%% end msam_oxykg %%%%%%%%%%
        
        %%%%%%%%%% mnut_01 %%%%%%%%%%
    case 'mnut_01'
        switch oopt
            case 'nutcsv'
                infile = [root_nut '/nut_' mcruise '_all.csv'];
            case 'sampnum_parse'
                %default is not to get into this branch, but some cruises may require cases to parse station and niskin numbers out of strings (see opt_jc159 mnut_01 for example)
            case 'vars'
                vars = {
                    'position'     'number'
                    'statnum'      'number'
                    'sampnum'      'number'
                    'sio4'         'umol/L'
                    'sio4_flag'    'woceflag'
                    'po4'          'umol/L'
                    'po4_flag'	  'woceflag'
                    'TP'           'umol/L'
                    'TP_flag'	  'woceflag'
                    'TN'           'umol/L'
                    'TN_flag'	  'woceflag'
                    'no3no2'       'umol/L'
                    'no3no2_flag'  'woceflag'
                    'no2'          'umol/L'
                    'no2_flag'	  'woceflag'
                    'nh4'          'umol/L'
                    'nh4_flag'	  'woceflag'
                    };
                vars(:,3) = vars(:,1);
            case 'flags'
        end
        %%%%%%%%%% end mnut_01 %%%%%%%%%%
        
        %%%%%%%%%% mco2_01 %%%%%%%%%%
    case 'mco2_01'
        switch oopt
            case 'infile'
                input_file_name = [root_co2 '/co2_' mcruise '_01.mat'];
            case 'varnames' %capitalisation is important!
                varnames = {'alk' 'TA'
                    'alk_flag' 'TAflag'
                    'dic' 'DIC'
                    'dic_flag' 'DICflag'
                    'sample_id' 'SAMPLE'
                    };
            case 'flags'
        end
        %%%%%%%%%% end mco2_01 %%%%%%%%%%
        
        %%%%%%%%%% mcfc_01 %%%%%%%%%%
    case 'mcfc_01'
        switch oopt
            case 'inputs'
                infile = [root_cfc '/cfc_' mcruise '_all.csv'];
                %set varsunits:
                %list of
                %invar inunits outvar outunits scale_factor
                %(see opt_jr302, opt_jc159)
        end
        %%%%%%%%%% end mcfc_01 %%%%%%%%%%
        
        %%%%%%%%%% mcfc_02 %%%%%%%%%%
    case 'mcfc_02'
        switch oopt
            case 'cfclist'
                cfcinlist = 'sf6 sf6_flag cfc11 cfc11_flag cfc12 cfc12_flag f113 f113_flag ccl4 ccl4_flag';
                cfcotlist = cfcinlist;
            case 'flags'
                %change flags here
        end
        %%%%%%%%%% end mcfc_02 %%%%%%%%%%

        %%%%%%%%%% mout_sam_csv %%%%%%%%%%
  case 'mout_sam_csv'
      switch oopt
          case 'morefields'
              fields0 = fields; 
              fields = [fields;
	  {'silc_per_kg',    'Si',               '(umol/kg)',  '%5.3f';...
	  'silc_flag',      'Si_flag',          '(woce)',    '%d';...
	  'phos_per_kg',    'P',               '(umol/kg)',  '%5.3f';...
	  'phos_flag',      'P_flag',           '(woce)',    '%d';...
	  'totnit_per_kg',  'NO3+NO2',          '(umol/kg)',  '%5.3f';...
	  'totnit_flag',    'NO3+NO2_flag',     '(woce)',    '%d';...
	  'no2_per_kg',     'NO2',              '(umol/kg)',  '%5.3f';...
	  'no2_flag',       'NO2_flag',         '(woce)',     '%d';...
      'alk',            'TAlk',             '(umol/kg)',  '%5.2f';...
      'alk_flag',       'TAlk_flag',        '(woce)',     '%d';...
      'dic',            'DIC',              '(umol/kg)',  '%5.2f';...
      'dic_flag',       'DIC_flag',         '(woce)',     '%d';...
      'cfc11_per_kg',   'CFC11',            '(pmol/kg)',  '%5.3f';...
      'cfc11_flag',     'CFC11_flag',       '(woce)',     '%d';...
      'cfc12_per_kg',   'CFC12',            '(pmol/kg)',  '%5.3f';...
      'cfc12_flag',     'CFC12_flag',       '(woce)',     '%d';...
      'f113_per_kg',    'F113',             '(pmol/kg)',  '%5.3f';...
      'f113_flag',      'F113_flag',        '(woce)',     '%d';...
      'ccl4_per_kg',    'CCL4',             '(pmol/kg)',  '%5.3f';...
      'ccl4_flag',      'CCL4_flag',        '(woce)',     '%d';...
      'sf6_per_kg',     'SF6',              '(fmol/kg)',  '%5.3f';...
      'sf6_flag',       'SF6_flag',         '(woce)',     '%d'}]; 
      end
          %%%%%%%%%% end mout_sam_csv %%%%%%%%%%

       %%%%%%%%%% msam_02b %%%%%%%%%%
case 'msam_02b'
switch oopt
case 'nflags'
   nflagstr = 'y = x2; y((x1==4 | x1==3) & ismember(x2, [2 3 6])) = 4; y(x1==9) = 9;';
end
    %%%%%%%%%% end msam_02b %%%%%%%%%%
 
        %%%%%%%%%% msam_checkbottles_02 %%%%%%%%%%
    case 'msam_checkbottles_02'
        switch oopt
            case 'section'
                %set section name corresponding to the gridded file to plot
                %anomalies from
            case 'docals'
                dotcal = 0; doccal = 0; doocal = 0; %default is not to apply calibrations
        end
        %%%%%%%%%% end msam_checkbottles_02 %%%%%%%%%%
        
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
        tempout = temp;
        %%%%%%%%%% end temp_apply_cal %%%%%%%%%%
        
        %%%%%%%%%% fluorcal %%%%%%%%%%
    case 'fluorcal'
        fluorout = fluor;
        %%%%%%%%%% end fluorcal %%%%%%%%%%
        
        
        %%%%%%%%%% populate_station_depths %%%%%%%%%%
    case 'populate_station_depths'
        switch oopt
            case 'fnin'
                fnin = [root_ctddep '/station_depths_' mcruise '.txt'];
                depmeth = 1; %load from two-column text file
            case 'bestdeps'
        end
        %%%%%%%%%% end populate_station_depths %%%%%%%%%%
        
        %%%%%%%%%% mbot_01 %%%%%%%%%%
    case 'mbot_01'
        switch oopt
            case 'infile'
                infile = [root_bot '/bot_' mcruise '_' stn_string '.csv'];
            case 'botflags'
                bottle_qc_flag = 2+zeros(size(statnum));
        end
        %%%%%%%%%% end mbot_01 %%%%%%%%%%
        
        %%%%%%%%%% m_daily_proc %%%%%%%%%%
    case 'm_daily_proc'
        switch oopt
           case 'exclude'
              if ~exist('uway_streams_proc_exclude'); uway_streams_proc_exclude = {'posmvtss'}; end
              if ~exist('uway_pattern_proc_exclude'); uway_pattern_proc_exclude = {'satinfo';'aux';'dps'}; end
           case 'bathycomb'
              bathycomb = 1;
           case 'allmat'
              allmat = 0;
           end
        %%%%%%%%%% end m_daily_proc %%%%%%%%%% 
        %%%%%%%%%% mday_01_clean_av %%%%%%%%%%
    case 'mday_01_clean_av'
        % set non-cruise-specific calibration or editing actions
        switch oopt
          case 'uway_apply_cal'
          switch abbrev
            case 'cnav'
                d = mload(infile, 'lat long');
                if max(mod(abs([d.lat(:);d.long(:)])*100,100))<=61
                    if std(d.lat)<.1 & std(d.lon)<.1 % ship hasn't moved much
                        warning('Cannot determine whether or not to apply cnav fix. Not applying.');
                        sensors_to_cal={};
                    else
                        mdocshow(scriptname, ['applying cnav fix to cnav_' mcruise '_d' day_string '_edt.nc']);
                        sensors_to_cal={'lat','long'};
                        sensorcals={'y=cnav_fix(x1)' 'y=cnav_fix(x1)'};
                        sensorunits={'/','/'}; % keep existing units
                    end
                else
                    mdocshow(scriptname, ['cnav fix not required for cnav_' mcruise '_d' day_string '_edt.nc']);
                    sensors_to_cal={};
                end
            otherwise
                sensors_to_cal={};
            end
          end
        %%%%%%%%%% end mday_01_clean_av %%%%%%%%%%
        
        %%%%%%%%%% msim_plot %%%%%%%%%%
    case 'msim_plot'
        switch oopt
            case 'sbathy'
                bfile = '/local/users/pstar/topo/s_atlantic';
        end
        %%%%%%%%%% end msim_plot %%%%%%%%%%
        
        %%%%%%%%%% mem120_plot %%%%%%%%%%
    case 'mem120_plot'
        switch oopt
            case 'sbathy'
                bfile = '/local/users/pstar/topo/s_atlantic';
        end
        %%%%%%%%%% end mem120_plot %%%%%%%%%%
        
        %%%%%%%%%% mtsg_01 %%%%%%%%%%
    case 'mtsg_01'
        switch oopt
            case 'indata'
                sal_mat_file = ['sal_' mcruise '_01.mat'];
            case 'flag'
                %set bottle/bottle reading flags
        end
        %%%%%%%%%% end mtsg_01 %%%%%%%%%%
        
        %%%%%%%%%% mtsg_bottle_compare %%%%%%%%%%
    case 'mtsg_bottle_compare'
        switch oopt
            case 'usecal'
               if ~exist('usecal'); usecal = 0; end
            case 'shiptsg'
                ii = find(strcmp(shiptsg(:,1),MEXEC_G.Mship));
                if length(ii)==1
                    prefix = (shiptsg{ii,2})
                else
                    error(['set tsg stream name for ' MEXEC_G.Mship ' at top of get_cropt.m to run ' scriptname])
                end
            case 'dbbad'
                %optionally NaN some of the db.salinity_adj points
            case 'sdiff'
                sc1 = 0.5; sc2 = 0.02; %thresholds used for smoothed series
        end
        %%%%%%%%%% end mtsg_bottle_compare %%%%%%%%%%
        
        %%%%%%%%%% mtsg_cleanup %%%%%%%%%%
    case 'mtsg_cleanup'
        switch oopt
            case 'kbadlims'
                kbadlims = [];
                %kbadlims = [t1 t2]; %bad from t1 to t2 (matlab datenum form)
            case 'editvars'
                %default: edit all ocean vars
                editvars = {'salinity','tstemp','sstemp','sstemp2','sampletemp','chlorophyll','trans','psal','fluo','cond','temp_m','temp_h','salin','fluor'};
            case 'moreedit'
                %can specify non-time-range based edits (see e.g. opt_jc069)
        end
        %%%%%%%%%% end mtsg_cleanup %%%%%%%%%%
       
        %%%%%%%%%% mtsg_findbad %%%%%%%%%%
    case 'mtsg_findbad'
        switch oopt
            case 'shiptsg'
                ii = find(strcmp(shiptsg(:,1),MEXEC_G.Mship));
                if length(ii)==1
                    abbrev = shiptsg{ii,2};
                else
                    error(['set tsg stream name for ' MEXEC_G.Mship ' at top of get_cropt.m to run ' scriptname])
                end
        end
        %%%%%%%%%% end mtsg_findbad %%%%%%%%%%
        
        %%%%%%%%%% mtsg_medav_clean_cal %%%%%%%%%
    case 'mtsg_medav_clean_cal'
        switch oopt
            case 'shiptsg'
                ii = find(strcmp(shiptsg(:,1),MEXEC_G.Mship));
                if length(ii)==1
                    prefix = shiptsg{ii,2};
                else
                    error(['set tsg stream name for ' MEXEC_G.Mship ' at top of get_cropt.m to run ' scriptname])
                end
        end
        %%%%%%%%%% end mtsg_medav_clean_cal %%%%%%%%%%
 
        %%%%%%%%%% tsgsal_apply_cal %%%%%%%%%%
    case 'tsgsal_apply_cal'
        switch oopt;
            case 'saladj'
                salout = salin;
        end
        %%%%%%%%%% end tsgsal_apply_cal %%%%%%%%%%
        
        
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
        
        
        %%%%%%%%%% list_bot %%%%%%%%%%
    case 'list_bot'
        switch oopt
            case 'samadj'
                dsam.lon = hctd.longitude + zeros(size(dsam.sampnum));
                dsam.lat = hctd.latitude + zeros(size(dsam.sampnum));
                dsam.bottom_dep = hctd.water_depth_metres + zeros(size(dsam.sampnum));
                dsam.udepth = sw_dpth(dsam.upress,dsam.lat);
                dsam.usig0 = sw_pden(dsam.upsal,dsam.utemp,dsam.upress,0);
            case 'printmsg'
        end
        %%%%%%%%%% end list_bot %%%%%%%%%%
        
        %%%%%%%%%% station_summary %%%%%%%%%%
    case 'station_summary'
        switch oopt
            case 'optsams'
                snames = {}; sgrps = {}; sashore = []; %see opt_jr302
            case 'stnmiss'
                stnmiss = []; %this is only for processed stations numbered between 1 and 900 that you don't want to include in the summary
            case 'cordep'
                cordep(k) = h2.water_depth_metres; % jc159 changed to h2, which is header from psal instead of 2db
            case 'comments'
                %             comments = cell(size(stnall));
                comments = cell(max(stnall),1); % bak fix jc159 30 March 2018; If stnall = [1 2 3 5] then size(stnall) is 4 but we need comments ot be of size 5 so we can prepare comments by station number rather than by index in stnall
            case 'altdep'
            case 'varnames'
                varnames={'statnum' 'time_start' 'time_bottom' 'time_end' 'lat' 'lon' 'cordep' 'maxd' 'minalt' 'resid' 'maxw' 'maxp' 'ndpths' 'nsal'}; %these probably won't change, but in any case the first 6 should always be the same
                varnames = [varnames snames']; %if snames has been set in opt_cruise, this will incorporate it
                varunits = {'number' 'seconds' 'seconds' 'seconds' 'deg min' 'deg min' 'metres' 'metres' 'metres' 'metres' 'metres' 'dbar' 'number' 'number'};
                varunits = [varunits  repmat({'number'},1,length(snames)) ];
        end
        %%%%%%%%%% end station_summary %%%%%%%%%%
        
        %%%%%%%%%% mout_cchdo_sam %%%%%%%%%%
    case 'mout_cchdo_sam'
        switch oopt
            case 'expo'
                expocode = 'unknown';
                sect_id = 'unknown';
            case 'nocfc'
                nocfc = 0;
            case 'outfile'
                outfile = expocode;
            case 'headstr'
                headstring = [];
        end
    %%%%%%%%%% end mout_cchdo_sam %%%%%%%%%%
        
    %%%%%%%%%% mout_cchdo_ctd %%%%%%%%%%
    case 'mout_cchdo_ctd'
        switch oopt
            case 'expo'
                expocode = 'unknown';
                sect_id = 'unknown';
            case 'outfile'
                outfile = [expocode '_ct1'];
            case 'headstr'
                headstring = [];
        end
    %%%%%%%%%% end mout_cchdo_ctd %%%%%%%%%%
        
    %%%%%%%%%% msec_run_mgridp %%%%%%%%%%
    case 'msec_run_mgridp'
        switch oopt
            case 'sections'
                %set list of all sections here, if not specified as an input (see opt_jr302)
            case 'gpars'
                gstart = []; gstop = []; gstep = []; %default grid range and spacing--can be set per cruise but is also specified by section name in msec_run_mgridp (or can be provided as an input argument)
            case 'varlist'
                varlist  = ['press temp psal potemp oxygen'];
            case 'kstns'
            case 'varuse'
        end
        %%%%%%%%%% end msec_run_mgridp %%%%%%%%%%

                %%%%%%%%%% m_maptracer %%%%%%%%%%
    case 'm_maptracer'
        switch oopt
            case 'kstatgroups'
                kstatgroups = {[1:999]};
        end
        %%%%%%%%%% end m_maptracer %%%%%%%%%%

        %%%%%%%%%% msam_ashore_flag %%%%%%%%%%
    case 'msam_ashore_flag'
        switch samtype
            %set sample numbers and flags to change (to 1, probably0 for 
            %samples to be run ashore
        end
        %%%%%%%%%% end msam_ashore_flag %%%%%%%%%%

        
    %%%%%%%%%% mvad_01 %%%%%%%%%%
    case 'mvad_01'
        switch oopt
            case 'files'
                datadir = [root_vmadcp '/mproc/dy113/' inst nbbstr '/contour'];
                fnin = [datadir '/' inst nbbstr '.nc'];
                dataname = [inst nbbstr '_' mcruise '_01'];
                %vmdas defaults
%                pre1 = [mcruise '_' inst '/adcp_pyproc/' mcruise '_enrproc/' inst nbbstr];
%                datadir = [root_vmadcp '/' pre1 '/contour'];
%                fnin = [datadir '/' inst nbbstr '.nc'];
%                dataname = [inst '_' mcruise '_01'];
        end
    %%%%%%%%%% end mvad_01 %%%%%%%%%%

        
end




%%%%%%%%%% set options specific to this cruise %%%%%%%%%%
if exist(['opt_' mcruise])==2
    eval(['opt_' mcruise]);
else
    disp(['opt_' mcruise ' not found; may need to be created to set cruise-specific options'])
end
%%%%%%%%%%%%%%%%%%%%





%%%%%%%%%% set unset options or warnings for unset options %%%%%%%%%
switch scriptname
    
    
    %%%%%%%%%% mcoxyhyst %%%%%%%%%%
    case 'mcoxyhyst'
        if length(H1in)==0 | length(H2in)==0 | length(H3in)==0
            warning('oxygen hysteresis parameters have not been set or supplied to mcoxyhyst; no correction will be applied')
        end
        %%%%%%%%%% end mcoxyhyst %%%%%%%%%%
        
        
        %%%%%%%%%% sal_standardise_avg %%%%%%%%%%
    case 'msal_standardise_avg'
        switch oopt
            case 'plot_stations'
                if ~exist('iistno'); iistno = [1:length(stnos)]; end
            case 'std2use'
                if ~exist('std2use'); disp('set autosal standards readings to use for this cruise'); keyboard; end
            case 'sam2use'
                if ~exist('sam2use'); disp('set salinity sample readings to use for this cruise'); keyboard; end
        end
        %%%%%%%%%% end sal_standardise_avg %%%%%%%%%%
        
        %%%%%%%%%% cond_apply_cal %%%%%%%%%%
    case 'cond_apply_cal'
        if ~exist('off') & ~exist('fac'); warning(['no cond cal set for sensor ' sensor]); end
        %%%%%%%%%% end cond_apply_cal %%%%%%%%%%
        
        %%%%%%%%%% tsgsal_apply_cal %%%%%%%%%%
    case 'tsgsal_apply_cal'
        switch oopt
            case 'saladj'
                if ~exist('salout'); warning(['no salinity cal set for TSG']); end
            case 'tempadj'
                if ~exist('tempout'); warning(['no temperature adjustment set for TSG']); end
        end
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
        
end
