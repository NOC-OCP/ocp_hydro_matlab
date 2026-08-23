
switch opt1

    case 'setup'
        switch opt2
            case 'time_origin'
                MEXEC_G.MDEFAULT_DATA_TIME_ORIGIN = [2026 1 1 0 0 0];
        end

    case 'shipuway'
        switch opt2
            case 'rvdas_database'
                RVDAS.loginfile = '/data/plocal/rvdas_addr';
        end

%%%%%%%%%%%%%%%%%%%% uway_proc %%%%%%%%%%    
    case 'uway_proc'
        switch opt2
            case 'datasys_best'
                default_navstream = 'posmv_gpgga';
                default_hedstream = 'posmv_pashr';
                default_attstream = 'posmv_pashr';
            case 'rvdas_skip'
                % %usbl not used, wamos not used
                % %don't need to read ctd depth through rvdas
                % %can read surfmet variables from nudam instead
                % skips.sentence_pat = [skips.sentence_pat, ...
                %     'usbl', 'wamos', 'ctuopd', 'surfmet'];
                % %below tables are present but have 0 data (return COPY 0)
                skips.sentence = [skips.sentence, ...
                    'truewind_truewind', ...
                    'ranger2usbl_psonlld', 'ctd_smctd', ...
                     ];
        end
%%%%%%%%%%%%%%%%%%%% end uwau_proc %%%%%%%%%%

%%%%%%%%%%%%%%%%%%%% bathy (not a script) %%%%%%%%%%
        % not sure if needed for DY214
    % case 'bathy'
    %     switch opt2
    %         case 'bathy_grid'
    %             crhelp_str = {'load gridded bathymetry into top.lon, top.lat, top.depth,'
    %                 'for use by mbathy_edit_av'};
    %     end
%%%%%%%%%%%%%%%%%%%%  end bathy (not a script) %%%%%%%%%%

%%%%%%%%%%%%%%%%%%%% nisk_proc %%%%%%%%%%%%
    case 'nisk_proc'
            
            end
%%%%%%%%%%%%%%%%%%%% end nisk_proc %%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%% ctd_proc %%%%%%%%%%%%
    case 'ctd_proc'
        switch opt2
           % to do - station 3 auto de spiking conductivity and 
           % fluorescence
           % todo: 004 despiking of conductivity and transmittance 
            case 'ctdfiles'
                cnvfile = fullfile(MEXEC_G.MDIRLIST.M_CTD_CNV,...
                    sprintf('%s_CTD%s.cnv', upper(mcruise), stn_string));
            case 'redoctm'
                redoctm = 1;
            case 'niskfilename'            
                blinfile = fullfile(MEXEC_G.MDIRLIST.M_CTD_BOT,...
                    sprintf('%s_CTD%s.bl', upper(mcruise), stn_string));
            case 'rawshow'
                if ismember(stn,[1,2])
                    yl.cond = [40 50];yl.cond1=yl.cond;yl.cond2=yl.cond;
                    yl.press = [-2 150];
                    yl.temp = [15 25];
                    yl.fluor = [0 2];
                    yl.turbidity = [0 0.2];
                else 
                    yl.cond = [25 45];yl.cond1=yl.cond;yl.cond2=yl.cond;
                end
            case 'niskins'
                niskin_pos = 1:24;
                niskin_number = [2754:2775,2777,2779];
                % double check barcodes of the straight niskin numbers
                if ismember(stn,[1:4])
                    niskin_pos = niskin_pos(1:2:end);
                    niskin_number = niskin_barcodes(1:2:end,2);
                end
            case 'botflags'
                switch stnlocal
                % DY214
                % Add a new case for the station if a problem with the
                % bottle occured after the ctd came up (M3). These are
                % the bottle flags:
                % 1: no info; 2: no problems noted; 3: leaking;
                % 4: did not trip correctly; 5: not reported;
                % 7: unknown problem; 9: samples not drawn
                %
                % If you are unsure about syntax add a comment.
                % Example:
                % todo: For station 4, bottle 9 and 11 leaked
                    case 4
                        niskin_flag(ismember(position,[9 11])) = 3; % bottles leaked
                    
                end
        
        end
%%%%%%%%%%%%%%%%%%%% end ctd_proc %%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%  adcp_proc %%%%%%%%%%%%
case 'adcp_proc'
        cfg.rawdir = fullfile(MEXEC_G.MDIRLIST.M_LADCP,'rawdata');
        cfg.uppat = sprintf('%s_LADCP_%sS.000',upper(mcruise),cfg.stnstr);
        cfg.dnpat = sprintf('%s_LADCP_%sM.000',upper(mcruise),cfg.stnstr);
        
        %set magnetic declination here, rather than using either of the two
        %options built in to LDEO_IX/loadnav
        %[p, f, ext] = fileparts(cfg.f.ctd); y0 = MEXEC_G.MDEFAULT_DATA_TIME_ORIGIN(1);

        %from CE26008 - however pyIGRF is not install - so I do not use it
        %at the moment
        %%%
        % a = {dbstack(2).file}; 
        % if ~strcmp(a{1},'mout_1hzasc.m') %bash script uses the output of mout_1hzasc so don't want to try to call this before that
        %     mdfile = fullfile(MEXEC_G.MDIRLIST.M_LADCP,'magdec.txt');
        %     if ~exist(mdfile,'file')
        %         fprintf(1,'in terminal, run the following:\nbash /data/pstar/programs/repos_github/mexec_exec/run_pyIGRF.sh\nthen enter to continue (here)')
        %         pause
        %     end
        %     md = load(mdfile);
        %     if ~sum(md==stnlocal)
        %         fprintf(1,'in terminal, run the following:\nbash /data/pstar/programs/repos_github/mexec_exec/run_pyIGRF.sh\nthen enter to continue (here)')
        %         pause
        %         md = load(mdfile);
        %     end
        %     ii = find(md==stnlocal); 
        %     if isempty(ii)
        %         warning('no mag dec for %s',stn_string)
        %     else
        %         ii = ii(1);
        %         cfg.p.drot = md(ii+1);
        %         fprintf(1,'using mag dec %f for %s',cfg.p.drot,stn_string)
        %     end
        % end
%%%%%%%%%%%%%%%%%%%%  end adcp_proc %%%%%%%%%%%%        

%%%%%%%%%%%%%%%%%%%%  sbe35 %%%%%%%%%%%%
    case 'sbe35'
        switch opt2
            case 'sbe35files'
                sbe35in = fullfile(MEXEC_G.MDIRLIST.M_SBE35,...
                    sprintf('CTD_%s.asc', stn_string));
                stnind = -6:-4; % index in file name of where the station number can be found.
                %stnind is indices in filename sbe35file normally
                %containing the station number; use negative to indicate
                %distance from end e.g. [-6:-4] for dy113_SBE35_CTD_010.asc
            case 'sbe35_parse'
                %deal with combined file(s)
                % copied below form opt_ce26008.m
                % if strcmp(file_list{kf},'CE26008_002_003.txt')
                %     m = t.datnum<datenum(2026,7,24,10,0,0);
                %     t.statnum(m) = 2;
                % elseif strcmp(file_list{kf},'CE26008_005_006_007.txt')
                %     m = t.datnum<datenum(2026,7,25,5,0,0);
                %     t.statnum(m) = 5;
                %     m = t.statnum==7 & t.datnum<datenum(2026,7,25,9,0,0);
                %     t.statnum(m) = 6;
                % end
        end
%%%%%%%%%%%%%%%%%%%% end sbe35 %%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%% msal_01 %%%%%%%%%%
    case 'msal_01'
        switch opt2
            case 'sal_files'
                %salfiles is a list of files to load, defaults to 
                % all sal_cruise_*.csv files in BOTTLE_SAL directory
            case 'sal_parse'
                % crhelp_str = {'place to change fieldnames, combine fields, etc. after '
                %     'loading; also to specify datform (default: ''dd/mm/yyyy'') and timform'
                %     '(default: ''hh:mm:ss'') for converting date and time strings to datevec.'
                %     'also a place to add information like cellT (bath temperature) or ssw_k15'
                %     'if it is not a column in the file (or if it in the header, code to parse'
                %     'it from salhead).'};
            case 'sal_flags'
                % crhelp_str = {'Place to set flags on salinity bottles or readings: for bottles, change ds_sal.flag'
                %     'based on ds_sal.sampnum. Note: sample flags: 1 not yet analysed, 2 good, 3 questionable,'
                %     '4 bad, 5 not reported (?), 6 average of replicates, 9 not drawn.'
                %     'For readings, NaN directly, or (default) search for files in ctd/BOTTLE_SAL/editlogs and apply previously selected'
                %     'edits (gui to select more runs later in msal_01).'};
            case 'sal_calc'
                % crhelp_str = {'sal_off sets salinity standard offsets (autosal units, additive, default []) for ranges'
                %     'of sampnum, while sal_off_base (default ''sampnum_run'') to specify how to match them to samples.'
                %     'Optionally, set sal_adj_comment here to give information on how standards offsets were chosen.'};
            case 'tsg_sampnum'
                % crhelp_str = {'Place to parse tsg sampnum (default: same as sampnum read in from file'
                %     'and dnum (datenum) from sampnum (default: either yyyymmddHHMM, or if sampnum<0, -jjjHHMM)'
                %     'where jjj is yearday)'};
        end
%%%%%%%%%%%%%%%%%%%% end msal_01 %%%%%%%%%%


%%%%%%%%%%%%%%%%%%%% moxy_01 %%%%%%%%%%
    case 'moxy_01'
        switch opt2
            case 'oxy_files'
                % crhelp_str = {'ofiles is a structure like that generated by dir, with field name listing'
                %     'csv files (found in root_oxy directory) containing oxygen data to be loaded;'
                %     'defaults to all oxy_cruise_*.csv files in BOTTLE_OXY directory.'
                %     'Variables to be passed to load_samdata to identify column headers'
                %     'and units: '
                %     'hcpat, cell array (default {''Niskin'' ''Bottle'' ''Number''}) giving the'
                %     '    contents of the header rows of an indicative column, and '
                %     'chrows (default 1:2) giving the header rows to combine for variable names,'
                %     '    (e.g., for the default indicative column, chrows = 1:2 produces ''niskin_bottle'')'
                %     'chunits (optional, default []), specifying which in any of the header rows contain units'
                %     '    (e.g. chunits = 3 in the example above gives units of ''number'').'
                %     'oxyvarmap (no default) is an Nx2 cell array giving mapping from '
                %     '    oxyfile column headers (as parsed by load_samdata) in column 2 to '
                %     '    variables used by moxy_01 in column 1: '
                %     'sampnum, statnum, position (either sampnum or statnum and position '
                %     '    required)'
                %     'vol_blank, vol_std, vol_titre_std (optional, may be set in case ''oxy_std'' instead)'
                %     'fix_temp, sample_titre (required)'
                %     'botvol_at_tfix or botvol or botnum (at least one; if botvol_at_tfix is not included'
                %     '    in csv files, include code under opt2 = ''oxy_std'' case to compute from fix_temp and '
                %     'botvol or botnum and a lookup table of bottle volumes)'
                %     'n_o2, conc_o2 (optional, only include if you don''t want to recalculate '
                %     '    from sample_titre)'
                %     'flag, comment (optional).'};
            case 'oxy_parse'
                % crhelp_str = {'Place to parse/store additional info from each file, for instance from header hs,'
                %     'or to compute things from fields of ds, for instance looking up bottle volumes from bottle '
                %     'numbers, or to specify mapping between file and mstar variable names in cell array oxyvarmap '
                %     '(first column: mstar names, second column: names in file), or to set fillstat to call'
                %     'fill_samdata_statnum to fill in missing station numbers on rows 2:N (default 0).'};
            case 'oxy_calc'
                % crhelp_str = {'Place to set oxygen titration parameters required if you want to calculate conc_o2 '
                %     '(rather than reading it in): '
                %     'vol_reag_tot (for fixing reagents, no default, set to 0 if your bot_vol_tfix has already accounted for this) '
                %     'cal_temp (temperature at which flask volumes were calibrated, no default), '
                %     'mol_std, std_react_ratio, sample_react_ratio, mol_o2_reag (don''t change), '
                %     'and optionally ds_oxy.vol_blank, ds_oxy.vol_titre_std, ds_oxy.vol_std, and'
                %     'ds_oxy.bot_vol_tfix or ds_oxy.bot_vol (vol_reag_tot will be subtracted from bot_vol_tfix).'};
                %below almost certainly won't change
            case 'oxy_flags'
                % crhelp_str = {'Place to change flags, ds_oxy.botoxya_flag, ds_oxy.botoxyb_flag.'};
        end
%%%%%%%%%%%%%%%%%%%% end moxy_01 %%%%%%%%%%

%%%%%%%%%%%%%%%%%%%% moxy_to_sam %%%%%%%%%%
    case 'moxy_to_sam'
        switch opt2
            case 'use_oxy_repl'
                % crhelp_str = {'Set use_oxy_repl (default: 1) to 0 to not average replicates, 1 to average duplicates,'
                %     'or 2 to average duplicates or triplicates'};
        end
%%%%%%%%%%%%%%%%%%%% end moxy_to_sam %%%%%%%%%%

%%%%%%%%%%%%%%%%%%%% msam_ashore_flag %%%%%%%%%%
    case 'msam_ashore_flag'
        switch opt2
            case 'shore_sam_types'
                % crhelp_str = {'If not already set in workspace, set samtypes'
                %     '(default {}), a cell array list of sampletypes collected'
                %     'for later analysis, e.g. samtypes = {''nut'', ''co2''};'
                %     'or if there is only one you could instead set e.g. samtype = ''nut'';'
                %     'If neither is set, script will prompt for a single samtype.'};
        end
        % crhelp_str = {'Switching on sam_ashore_{sampletype} (e.g. sam_ashore_nut), set:'
        %     'fnin, a cell array list of csv or excel file(s) containing lists of '
        %     '  samples collected for a given sampletype,'
        %     'varmap, a Mx3 cell array whose first column is mexec names, second is'
        %     '  the corresponding variable names in the file being read in, and '
        %     '  third specifies (for flag fields) how to decode them: as ''flag'''
        %     '  (i.e. no decoding, use as-is) or as ''num_samples'' (i.e. anything >0'
        %     '  gets a flag of 1).'
        %     '  the mexec names must include either sampnum or statnum and position,'
        %     '  as well as the one or more {parameter}_flag variables to be written '
        %     '  for this sampletype (e.g. silc_flag, phos_flag, totnit_flag), '
        %     'fillstat (default 0), a flag setting whether statnum is blank in some'
        %     '  rows and needs to be filled in,'
        %     'do_empty_vars (default 0), a flag setting whether to also add columns'
        %     '  of NaNs as parameter (e.g. silc, phos, totnit) placeholders, in '
        %     'addition to the flags.'};
%%%%%%%%%%%%%%%%%%%% end msam_ashore_flag %%%%%%%%%%

%%%%%%%%%%%%%%%%%%%% msam_checkbottles_02 %%%%%%%%%%
    case 'checkbottles_02'
        switch opt2
            case 'section'
                %set section name corresponding to the gridded file to plot
                %anomalies from
            case 'docals'
        end
%%%%%%%%%%%%%%%%%%%% end msam_checkbottles_02 %%%%%%%%%%

%%%%%%%%%%%%%%%%%%%% end sam_all_make %%%%%%%%%%
    case 'sam_all_make'
        switch opt2
            case 'sam_all_restart_steps'
                % crhelp_str = {'If not already set in workspace, set:'
                %     'sam_all_restart, a list of steps to be rerun: '
                %     '  sam to delete sam_cruise_all.nc and start from scratch (default); '
                %     '  fir to regenerate the fir files by running mfir_01, mfir_03, mwin_to_fir '
                %     '    (default: skip; just run mfir_to_sam to paste existing into sam_cruise_all.nc);'
                %     '  one or more parameters (default: ''sbe35'', ''sal'', ''oxy'') for which '
                %     '    to run the corresponding m{parameter}_01 scripts; '
                %     '  shore to run msam_ashore_flag (default: skip).'
                %     'klist, list of stations for which to run fir and sbe35 steps (default [] --> prompt)'};
        end
%%%%%%%%%%%%%%%%%%%% end sam_all_make %%%%%%%%%%   

end
