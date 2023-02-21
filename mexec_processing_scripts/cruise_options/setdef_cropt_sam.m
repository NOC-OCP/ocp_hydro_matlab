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
    
        %%%%%%%%%% msbe35_01 %%%%%%%%%%
    case 'msbe35_01'
        switch oopt
            case 'sbe35file'
                crhelp_str = {'Filename pattern for SBE35 files (including wildcard) and indices for '
                    'finding station number in filename.'};
                sbe35file = sprintf('%s_SBE35_CTD*.asc', upper(mcruise));
                stnind = [-6:-4]; %end-6:end-4 e.g. dy113_SBE35_CTD_010.asc
            case 'sbe35_datetime_adj'
                crhelp_str = {'Place to modify SBE35 file dates/times, as date is sometimes '
                    'not reset correctly before deployment. Only necessary if clock is far off.'};
            case 'sbe35flag'
                crhelp_str = {'Place to modify flags (t.flag, by t.sampnum) on SBE35 temperature data, and/or'
                    'remove spurious lines (leftovers in the wrong file) in table t by NaNing t.datnum or t.sampnum.'
                    'set sbe35_check to 1 (default 0) to look for and inspect problem lines (duplicate sampnums or '
                    'mismatched station numbers and times.'};
                sbe35_check = 0;
        end
        %%%%%%%%%% end msbe35_01 %%%%%%%%%%
        
        %%%%%%%%%% msal_01 %%%%%%%%%%
    case 'msal_01'
        switch oopt
            case 'sal_files'
                crhelp_str = {'salfiles is a list of files to load, defaults to '
                    'all sal_cruise_*.csv files in BOTTLE_SAL directory'};
                salfiles = dir(fullfile(root_sal, ['sal_' mcruise '_*.csv']));
                salfiles = {salfiles.name};
                hcpat = {'sampnum'};
                chrows = 1;
                chunits = [];
                sheets = 1;
                iopts = struct([]);
            case 'sal_parse'
                crhelp_str = {'place to change fieldnames, combine fields, etc. after '
                    'loading; also to specify datform (default: ''dd/mm/yyyy'') and timform'
                    '(default: ''hh:mm:ss'') for converting date and time strings to datevec.'
                    'also a place to add information like cellT (bath temperature) or ssw_k15'
                    'if it is not a column in the file (or if it in the header, code to parse'
                    'it from salhead).'};
                datform = 'dd/mm/yyyy';
                timform = 'HH:MM:SS';
            case 'sal_sample_inspect'
                crhelp_str = {'Set plotss to 1 (default 0) to plot individual reading values for '
                    'salinity samples, to use to set flags below.'};
                plotss = 0; 
            case 'sal_flags'
                crhelp_str = {'Place to set flags on salinity bottles or readings: for bottles, change ds_sal.flag'
                    'based on ds_sal.sampnum. Note: sample flags: 1 not yet analysed, 2 good, 3 questionable,'
                '4 bad, 5 not reported (?), 6 average of replicates, 9 not drawn.'
                'For readings, NaN directly, or (default) search for files in ctd/BOTTLE_SAL/editlogs and apply previously selected'
                'edits (gui to select more runs later in msal_01).'};
                reapply_saledits = 1;
                edfile = fullfile(root_sal,'editlogs','bad_sal_readings');
            case 'sal_calc'
                crhelp_str = {'sal_off sets salinity standard offsets (autosal units, additive, default []) for ranges'
                    'of sampnum, while sal_off_base (default ''sampnum_run'') to specify how to match them to samples.'
                    'Optionally, set sal_adj_comment here to give information on how standards offsets were chosen.'};
                sal_off = [];
                sal_off_base = 'sampnum_run';
                sal_adj_comment = '';
            case 'tsg_sampnum'
                crhelp_str = {'Place to parse tsg sampnum (default: same as sampnum read in from file'
                    'and dnum (datenum) from sampnum (default: either yyyymmddHHMM, or if sampnum<0, -jjjHHMM)'
                    'where jjj is yearday)'};
                tsg.sampnum = dsu.sampnum;
                tsg.dnum = NaN+zeros(size(tsg.sampnum));
                ii = find(tsg.sampnum>0);
                if ~isempty(ii)
                    tsg.dnum(ii) = datenum(num2str(tsg.sampnum(ii)),'yyyymmddHHMM');
                end
                ii = find(tsg.sampnum<0);
                if ~isempty(ii)
                    s = num2str(-tsg.sampnum(ii));
                    jjj = str2num(s(:,1:3));
                    HH = str2num(s(:,4:5));
                    MM = str2num(s(:,6:7));
                    tsg.dnum(ii) = datenum(MEXEC_G.MDEFAULT_DATA_TIME_ORIGIN(1),1,1) + jjj-1 + (HH+MM/60)/24;
                end
        end
        %%%%%%%%%% end msal_01 %%%%%%%%%%
        
        %%%%%%%%%% moxy_01 %%%%%%%%%%
    case 'moxy_01'
        switch oopt
            case 'oxy_files'
                crhelp_str = {'ofiles is a structure like that generated by dir, with field name listing'
                    'csv files (found in root_oxy directory) containing oxygen data to be loaded;'
                    'defaults to all oxy_cruise_*.csv files in BOTTLE_OXY directory.'
                'Variables to be passed to load_samdata to identify column headers'
                    'and units: '
                    'hcpat, cell array (default {''Niskin'' ''Bottle'' ''Number''}) giving the'
                    '    contents of the header rows of an indicative column, and '
                    'chrows (default 1:2) giving the header rows to combine for variable names,'
                    '    (e.g., for the default indicative column, chrows = 1:2 produces ''niskin_bottle'')'
                    'chunits (optional, default []), specifying which in any of the header rows contain units'
                    '    (e.g. chunits = 3 in the example above gives units of ''number'').'
                    'oxyvarmap (no default) is an Nx2 cell array giving mapping from '
                    '    oxyfile column headers (as parsed by load_samdata) in column 2 to '
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
                ofpat = ['oxy_' mcruise '_*.csv'];
                ofiles = dir(fullfile(root_oxy, ofpat));
                ofiles = struct2cell(ofiles); ofiles = ofiles(1,:)';
                sheets = 1;
                hcpat = {'Niskin' 'Bottle' 'Number'};
                chrows = 1:2;
                chunits = 3;
            case 'oxy_parse'
                crhelp_str = {'Place to parse/store additional info from each file, for instance from header hs,'
                    'or to compute things from fields of ds, for instance looking up bottle volumes from bottle '
                    'numbers, or to specify mapping between file and mstar variable names in cell array oxyvarmap '
                    '(first column: mstar names, second column: names in file), or to set fillstat to call'
                    'fill_samdata_statnum to fill in missing station numbers on rows 2:N (default 0).'};
                oxyvarmap = {}; %default: don't rename anything
                fillstat = 0; %default: no need to fill in station numbers on some rows
            case 'oxy_calc'
                crhelp_str = {'Place to set oxygen titration parameters required if you want to calculate conc_o2 '
                    '(rather than reading it in): '
                    'vol_reag_tot (for fixing reagents, no default, set to 0 if your bot_vol_tfix has already accounted for this) '
                    'cal_temp (temperature at which flask volumes were calibrated, no default), '
                    'mol_std, std_react_ratio, sample_react_ratio, mol_o2_reag (don''t change), '
                    'and optionally ds_oxy.vol_blank, ds_oxy.vol_titre_std, ds_oxy.vol_std, and'
                    'ds_oxy.bot_vol_tfix or ds_oxy.bot_vol (vol_reag_tot will be subtracted from bot_vol_tfix).'};
                %below almost certainly won't change
                mol_std = 1.667*1e-6;   % molarity (mol/mL) of standard KIO3
                std_react_ratio = 6;       % # Na2S2O3/ KIO3 (mol/mol)
                sample_react_ratio = 1./4; % # O2/Na2S2O3 (mol/mol)
                mol_o2_reag = 0.5*7.6e-8; %mol/mL of dissolved oxygen in pickling reagents
            case 'oxy_flags'
                crhelp_str = {'Place to change flags, ds_oxy.botoxya_flag, ds_oxy.botoxyb_flag.'};
        end
        %%%%%%%%%% end moxy_01 %%%%%%%%%%
                
    case 'moxy_to_sam'
        switch oopt
            case 'use_oxy_repl'
                crhelp_str = {'Set use_oxy_repl (default: 1) to 0 to not average replicates, 1 to average duplicates,'
                    'or 2 to average duplicates or triplicates'};
                use_oxy_repl = 1;
        end
        
        %%%%%%%%%% mnut_01 %%%%%%%%%%
    case 'mnut_01'
        switch oopt
            case 'nutcsv'
                infile = fullfile(root_nut, ['nut_' mcruise '_all.csv']);
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
            case 'nutlabtemp'
                labtemp = 21;
        end
        %%%%%%%%%% end mnut_01 %%%%%%%%%%
        
        %%%%%%%%%% mpig_01 %%%%%%%%%%
    case 'mpig_01'
        switch oopt
            case 'pigcsv'
                infile = fullfile(root_pig, ['pig_' mcruise '_all.csv']);
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
                input_file_name = fullfile(root_co2, ['co2_' mcruise '_01.mat']);
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
                infile = fullfile(root_cfc, ['cfc_' mcruise '_all.csv']);
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
        switch oopt
            case 'shore_sam_types'
                crhelp_str = {'If not already set in workspace, set samtypes'
                    '(default {}), a cell array list of sampletypes collected'
                    'for later analysis, e.g. samtypes = {''nut'', ''co2''};'
                    'or if there is only one you could instead set e.g. samtype = ''nut'';'
                    'If neither is set, script will prompt for a single samtype.'};
                samtypes = {};
        end
        crhelp_str = {'Switching on sam_ashore_{sampletype} (e.g. sam_ashore_nut), set:'
            'fnin, a cell array list of csv or excel file(s) containing lists of '
            '  samples collected for a given sampletype,'
            'varmap, a Mx3 cell array whose first column is mexec names, second is'
            '  the corresponding variable names in the file being read in, and '
            '  third specifies (for flag fields) how to decode them: as ''flag'''
            '  (i.e. no decoding, use as-is) or as ''num_samples'' (i.e. anything >0'
            '  gets a flag of 1).'
            '  the mexec names must include either sampnum or statnum and position,'
            '  as well as the one or more {parameter}_flag variables to be written '
            '  for this sampletype (e.g. silc_flag, phos_flag, totnit_flag), '
            'fillstat (default 0), a flag setting whether statnum is blank in some'
            '  rows and needs to be filled in,'
            'do_empty_vars (default 0), a flag setting whether to also add columns'
            '  of NaNs as parameter (e.g. silc, phos, totnit) placeholders, in '
            'addition to the flags.'};
        do_empty_vars = 0;
        fillstat = 0;
        varmap = {};
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
        
                        
    case 'miso_01'
        switch oopt
            case 'iso_files'
                crhelp_str = {'set list of files, isofiles, from which to load isotope data (no default)'};
            case 'iso_parse'
                crhelp_str = {'Place to parse/store additional info from each file, for instance from header hs,'
                    'or to compute things from fields of ds, for instance looking up bottle volumes from bottle '
                    'numbers, or to specify mapping between file and mstar variable names in cell array isovarmap '
                    '(first column: mstar names, second column: names in file).'};            
            case 'iso_flags'
                crhelp_str = {'set flag fields in iso'};
        end
        
    case 'sam_all_make'
        switch oopt
            case 'sam_all_restart_steps'
                crhelp_str = {'If not already set in workspace, set:'
                    'sam_all_restart, a list of steps to be rerun: '
                    '  sam to delete sam_cruise_all.nc and start from scratch (default); '
                    '  fir to regenerate the fir files by running mfir_01, mfir_03, mwin_to_fir '
                    '    (default: skip; just run mfir_to_sam to paste existing into sam_cruise_all.nc);'
                    '  one or more parameters (default: ''sbe35'', ''sal'', ''oxy'') for which '
                    '    to run the corresponding m{parameter}_01 scripts; '
                    '  shore to run msam_ashore_flag (default: skip).'
                    'klist, list of stations for which to run fir and sbe35 steps (default [] --> prompt)'};
                sam_all_restart = {'sam', 'sbe35', 'sal', 'oxy'};
                klist = [];
        end
                
end
