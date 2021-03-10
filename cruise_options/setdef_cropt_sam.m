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
    
        %%%%%%%%%% mbot_01 %%%%%%%%%%
    case 'mbot_01'
        switch oopt
            case 'nbotfile'
                crhelp_str = {'Sets output file to which to write information about Niskins from the .bl file'
                    'default: one file per station: [root_botcsv ''/bot_'' mcruise ''_'' stn_string ''.csv'']'};
                botfile = [root_botcsv '/' prefix1 stn_string '.csv'];
            case 'nispos'
                crhelp_str = {'niskin gives the bottle numbers (e.g. serial numbers, if known) for niskins in '
                    'carousel positions 1 through nnisk. defaults to [1:24].'};
                niskin = [1:24];
            case 'botflags'
                crhelp_str = {'Optional: edit niskin_flag, the vector of quality flags for Niskin bottle firing'
                    'for each station.'};
        end
        %%%%%%%%%% end mbot_01 %%%%%%%%%%
        
        %%%%%%%%%% msbe35_01 %%%%%%%%%%
    case 'msbe35_01'
        switch oopt
            case 'sbe35_datetime_adj'
                crhelp_str = {'Place to modify SBE35 file dates/times, as date is sometimes '
                    'not reset correctly before deployment'};
            case 'sbe35flag'
                crhelp_str = {'Place to modify flags (sbe35flag) on SBE35 temperature data'};
        end
        %%%%%%%%%% end msbe35_01 %%%%%%%%%%
        
        %%%%%%%%%% msal_01 %%%%%%%%%%
    case 'msal_01'
        switch oopt
            case 'salfiles'
                crhelp_str = {'salfiles is a list of files to load, defaults to '
                    'all sal_cruise_*.csv files in BOTTLE_SAL directory'};
                salfiles = struct2cell(dir([root_sal '/sal_' mcruise '_*.csv']));
                salfiles = salfiles(1,:);
            case 'salnames'
                crhelp_str = {'place to change fieldnames, combine fields, etc. after '
                    'loading'}; %per file
            case 'salflags'
                crhelp_str = {'Place to set flags on salinity bottles or readings.'};
            case 'sal_off'
                crhelp_str = {'sal_off sets salinity standard offsets (autosal units, additive) for ranges '
                    'of sampnum, or leave empty (default) to run msal_standardise_avg to calculate and plot.'
                    'Also must set sal_off_base to specify how to match them to samples. Optionally set '
                    'sal_adj_comment here to give information on how standards offsets were chosen (if'
                    'not chosen using msal_standardise_avg).'};
                sal_off = [];
                sal_off_base = '';
                sal_adj_comment = '';
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
        
        %%%%%%%%%% moxy_01 %%%%%%%%%%
    case 'moxy_01'
        switch oopt
            case 'oxy_files'
                crhelp_str = {'ofiles is a list of csv files containing oxygen data to be loaded;'
                    'defaults to all oxy_cruise_*.csv files in BOTTLE_OXY directory.'};
                ofpat = ['/oxy_' mcruise '_*.csv'];
ofiles = dir([root_oxy '/' ofpat]);
            case 'oxy_parse'
                crhelp_str = {'1) Variables to be passed to m_load_samin to identify column headers'
                    'and units: '
                    'hcpat, cell array (default {''Niskin'' ''Bottle'' ''Number''}) giving the'
                    '    contents of the header rows of an indicative column, and '
                    'chrows (default 2) giving the number of rows to combine for variable names,'
                    '    (e.g., for the default indicative column, ''niskin_bottle''), with additional'
                    '    rows if any forming the units (e.g., for the default indicative column, ''number''.'
                    'chunits (optional, default []), specifying which in any of the header rows contain units'
                    '2) mvar_fvar (no default) is an Nx2 cell array giving mapping from '
                    '    oxyfile column headers (as parsed by m_load_samin) in column 2 to '
                    '    variables used by moxy_01 in column 1: '
                    'sampnum, statnum, position (either sampnum or statnum and position '
                    '    required)'
                    'vol_blank, vol_std, vol_titre_std (optional, may be set in case ''oxy_std'' instead)'
                    'fix_temp, sample_titre (required)'
                    'botvol_at_tfix or botvol or botnum (at least one; if botvol_at_tfix is not included'
                    '    in csv files, include code under oopt = ''oxy_std'' case to compute from fix_temp and '
                    'botvol or botnum and a lookup table of bottle volumes)'
                    'n_o2, conc_o2 (optional, only include if you don''t want to recalculate '
                    '    from sample_titre)'
                    'flag, comment (optional).'};
                hcpat = {'Niskin' 'Bottle' 'Number'};
                chrows = 2;
                chunits = [];
            case 'oxy_parse_files'
                crhelp_str = {'Place to parse/store additional info from each file, for instance from header hs,'
                    'or to compute things from fields of ds, for instance looking up bottle volumes from bottle '
                    'numbers.'};
            case 'oxycalcpars'
                crhelp_str = {'Place to set oxygen titration parameters: '
                    'vol_reag_tot (for fixing reagents, default 2) '
                    'cal_temp (temperature at which flask volumes were calibrated, default 25), '
                    'mol_std, std_react_ratio, sample_react_ratio, mol_o2_reag (don''t change), '
                    'and optionally ds_oxy.vol_blank, ds_oxy.vol_titre_std, ds_oxy.vol_std, and'
                    'ds_oxy.bot_vol_tfix or ds_oxy.bot_vol (vol_reag_tot will be subtracted from bot_vol_tfix).'};
                vol_reag_tot = 2; % MnCl2 vol + NaOH/NaI vol (mL) (default)
                %below probably won't change
                cal_temp = 25; % calibration temp (deg. C) for flasks
                %below almost certainly won't change
                mol_std = 1.667*1e-6;   % molarity (mol/mL) of standard KIO3
                std_react_ratio = 6;       % # Na2S2O3/ KIO3 (mol/mol)
                sample_react_ratio = 1./4; % # O2/Na2S2O3 (mol/mol)
                mol_o2_reag = 0.5*7.6e-8; %mol/mL of dissolved oxygen in pickling reagents
            case 'oxyflags'
                crhelp_str = {'Place to change flags, ds_oxy.botoxya_flag, ds_oxy.botoxyb_flag.'};
        end
        %%%%%%%%%% end moxy_01 %%%%%%%%%%
        
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
        crhelp_str = {'set fnin, the file from which to load information on samples collected'
            'for analysis ashore;'
            'varnames (Mx1 cell array), a list of flag field names for sam_cruise_all file;'
            'sampnums (MxN cell array), lists of sample numbers, and'
            'flagvals (1xN vector), the values to assign to flag variables for these sets of sampnums.'
            'in most cases flagvals = 1 and sampnums has a single column. sampnums not specified default'
            'to 9, or 5 (not analysed) where bottle_qc_flag is 4 (bad).'};
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
        
                        
                
end
