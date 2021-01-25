% this script is called by get_cropt to set defaults for
% parameters/variables used by other scripts,
% before calling opt_cruise to set cruise-specific parameters if applicable
%
% see get_cropt help
%
% options are specified by switch-case through two
% variables:
%     scriptname (usually the name of the calling script)
%     oopt (another string, which for ease of searching should be
%         kept unique, not reused under different scriptnames)


switch scriptname
    
        %%%%%%%%%% batchscript_sams %%%%%%%%%%
    case 'smallscript_sams' %***batchscript, oopt
        crhelp_str = []; %***
        dodcs24 = 0; doucav = 0; rmvars = {}; addvars = {}; %default is not to rerun
        %%%%%%%%%% end batchscript_sams %%%%%%%%%%
        
                
        %%%%%%%%%% msal_01 %%%%%%%%%%
    case 'msal_01'
        switch oopt
            case 'salfile'
                sal_mat_file = ['sal_' mcruise '_01.mat'];
            case 'salflags'
                %set bottle/bottle reading flags
        end
        
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
            case 'sbe35flag'
                crhelp_str = {'place to modify flags on SBE35 temperature data'};
        end
        %%%%%%%%%% end msbe35_01 %%%%%%%%%%
        
        %%%%%%%%%% moxy_01 %%%%%%%%%%
    case 'moxy_01'
        switch oopt
            case 'oxycsv'
                infile = [root_oxy '/oxy_' mcruise '_all.csv'];
            case 'oxysampnum'
                %make sure there are at least two of statnum, niskin, sampnum
                %and that if there is sampnum, it is (statnum*100 + niskin)
            case 'oxyconccalc'
                oxyconccalc = 1; %default: calculate from other fields
                %set to 0 to use from file
            case 'oxyflags'
                %list sampnums to get flags of 3 or 4
                flags3 = [];
                flags4 = [];
                %could also set flags explicitly
            otherwise
                warning(['oopt ' oopt ' not in get_cropt for ' scriptname])
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
        
        %%%%%%%%%% msam_nutkg %%%%%%%%%%
    case 'msam_nutkg'
        switch oopt
            case 'labtemp'
                labtemp = 21;
        end
        %%%%%%%%%% end msam_nutkg %%%%%%%%%%
        
        %%%%%%%%%% mpig_01 %%%%%%%%%%
    case 'mpig_01'
        switch oopt
            case 'pigcsv'
                infile = [root_pig '/pig_' mcruise '_all.csv'];
            case 'sampnum_parse'
                %default is not to get into this branch, but some cruises may require cases to parse station and niskin numbers out of strings (see opt_jc159 mpig_01 for example)
            case 'vars'
                vars = {
                    'position'     'number'
                    'statnum'      'number'
                    'sampnum'      'number'
                    };
                vars(:,3) = vars(:,1);
            case 'flags'
        end
        %%%%%%%%%% end mpig_01 %%%%%%%%%%
        
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
        
        %%%%%%%%%% msam_ashore_flag %%%%%%%%%%
    case 'msam_ashore_flag'
        switch samtype
            %set sample numbers and flags to change (to 1, probably0 for
            %samples to be run ashore
        end
        %%%%%%%%%% end msam_ashore_flag %%%%%%%%%%
        
        
        
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
        
                        
        %%%%%%%%%% station_summary %%%%%%%%%%
    case 'station_summary'
        switch oopt
            case 'optsams'
                snames = {'nsal'}; 
                sgrps = {{'sal'}}; 
                sashore = [0]; 
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
                
                
end
