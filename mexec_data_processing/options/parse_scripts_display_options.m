% help mode (when help_cropt set to 1) can be called three ways:
%
% 1) with empty opt1 and opt2, e.g.
%     >> help_cropt = 1; opt1 = ''; opt2 = ''; get_cropt
%       displays the full list of opt1s and opt2s in setdef_cropt
%
% 2) with opt1 but empty opt2, e.g.
%     >> help_cropt = 1; opt1 = 'mctd_02b'; opt2 = ''; get_cropt
%       displays the list of (opt1, opt2) pairs in mctd_02b.m:
%         opt1 = mfilename; opt2 = 'raw_corrs'; get_cropt
%         opt1 = 'castpars'; opt2 = 'oxyvars'; get_cropt
%         opt1 = mfilename; opt2 = 'oxyrev'; get_cropt
%         opt1 = mfilename; opt2 = 'oxyrev'; get_cropt
%         opt1 = mfilename; opt2 = 'oxyhyst'; get_cropt
%         opt1 = mfilename; opt2 = 'oxyhyst'; get_cropt
%         opt1 = mfilename; opt2 = 'turbVpars'; get_cropt
%       (mfilename gives the name of the current script, so in this example
%       is equivalent to opt1 = 'mctd_02b')
%     >> help_cropt = 1; opt1 = 'castpars'; opt2 = ''; get_cropt
%       (because there is no castpars.m) displays the list of scripts calling
%       get_cropt with opt1 = 'castpars', along with the opt2s used:
%         mbot_00.m:opt1 = 'castpars'; opt2 = 'nnisk'; get_cropt
%         mctd_02b.m:opt1 = 'castpars'; opt2 = 'oxyvars'; get_cropt
%         mctd_checkplots.m:opt1 = 'castpars'; opt2 = 'oxyvars'; get_cropt; nox = size(oxyvars,1);
%         mctd_rawshow.m:opt1 = 'castpars'; opt2 = 'oxyvars'; get_cropt; nox = size(oxyvars,1);
%
% 3) with opt1 and opt2, e.g.
%     >> help_cropt = 1; opt1 = 'mctd_03'; opt2 = 's_choice'; get_cropt
%       displays the corresponding help message from this case of setdef_cropt:
%         's_choice (default 1) sets the primary sensor for temperature and conductivity; '
%         'stns_alternate_s (default []) lists stations on which to use the other one. if there is '
%         'only one CTD, keep the default (1).'


if ~isunix
    clear help_cropt
    error('help mode uses grep and does not currently work on windows')

elseif ~exist('opt1','var') || isempty(opt1)
    %called to get list of opt1s and opt2s
    dm = which('m_setup'); dm = [dm(1:end-9) '/mexec_processing_scripts'];
    dc = pwd;
    try
        cd(dm);
        [st, slist] = system('grep case cruise_options/setdef_cropt_*.m | grep -v switch');
        cd(dc);
        more on
        disp('these are the opt1 and opt2 (the latter indented) with settings under get_cropt')
        disp(slist)
        more off
    catch me
        throw(me)
    end

elseif ~exist('opt2', 'var') || isempty(opt2)

    %called to get list of options for specific opt1
    f = which(opt1); %***

    if ~isempty(f) %show calls to get_cropt in m-file opt1.m
        [st, olist] = unix(['grep cropt ' f ]);
        disp(['calls to get_cropt in ' opt1 '.m:'])
        disp(olist)

    else %show calls to get_cropt with opt1 in all m-files in mexec_processing_scripts and subdirectories
        dm = which('m_setup'); dm = dm(1:end-9);
        dc = pwd;
        try
            cd(dm);
            [~, slist1] = unix(['grep ' opt1 ' *.m | grep opt2 | grep -v cruise_options']);
            [~, slist2] = unix(['grep ' opt1 ' */*.m | grep opt2 | grep -v cruise_options']);
            [~, slist3] = unix(['grep ' opt1 ' */*/*.m | grep opt2 | grep -v cruise_options']);
            cd(dc);
            disp(['mexec_processing_scripts that call get_cropt with opt1 = ''' opt1 ''':'])
            more on
            disp(slist1); disp(slist2); disp(slist3)
            more off
        catch me %just to avoid an error in the middle leaving us in the wrong directory
            throw(me)
        end
    end

else %called to get help message for specific opt1, opt2 pair

    %get help messages from setdef_cropt
    setdef_cropt_cast
    if exist('crhelp_str','var'); disp('defaults set in setdef_cropt_cast'); end
    setdef_cropt_sam
    if exist('crhelp_str','var'); disp('defaults set in setdef_cropt_sam'); end
    setdef_cropt_uway
    if exist('crhelp_str','var'); disp('defaults set in setdef_cropt_uway'); end
    setdef_cropt_other
    if exist('crhelp_str','var'); disp('defaults set in setdef_cropt_other'); end
    dm = which('m_setup'); dm = dm(1:end-9);
    dc = pwd;
    try
        cd(dm);
        [st, clist] = unix(['grep ' opt2 ' cruise_options/opt_*.m | grep case']);
        cd(dc)
        more on
        disp(['look in these files for examples of how to change default settings for opt1 = ''' opt1 '''; opt2 = ''' opt2 ''':'])
        disp(clist)
        more off
    catch me
        throw(me)
    end
    if exist('crhelp_str','var')
        disp(crhelp_str);
    else
        disp(['no help string for ' opt1 ', ' opt2 ' in setdef_cropt_*'])
    end

end

clear help_cropt %don't want this to persist

%********************

crhelp_str = {'shortcasts (default: []) is a list of statnums with non full depth casts '
    '(for which you would need to fill in depth in populate_station_depths,'
    'and wouldn''t bother with the BT constraint on LADCP processing, etc.).'
    'You can also set other groupings, for instance on sd025 ticasts lists casts on the Ti frame.'};
shortcasts = [];

switch opt1

    case 'mctd_01'
        switch opt2
            case 'redoctm'
                crhelp_str = {'redoctm defaults to 0 to generate raw file from .cnv file that had cell thermal mass correction'
                    'applied in SBE processing. set to 1 to instead generate raw file from pre-CTM file (to remove large spikes), '
                    'and subsequently apply ctm correction in mctd_02.'
                    'suf is the .cnv file suffix in either case (defaults ''_align_ctm'' or ''_align_noctm'')'};
            case 'cnvfilename'
                crhelp_str = {'cnvfile is the name of the .cnv file to read in'};
            case 'ctdvars'
                crhelp_str = {'ctdvarmap is a list of sbe variable names, corresponding mstar names,'
                    'and default units (only to be filled in if units are empty).'};
            case 'absentvars' % introduced new on jc191
                crhelp_str = {'absentvars (default {}) is a cell array of strings listing variables not present '
                    'for given station(s); if applicable should be set in opt_cruise for selected stations '
                    '(variables that are never present should be removed from ctd_renamelist.csv instead)'};
            case 'extracnv' %post-jc238
                crhelp_str = {'extracnv (default {}) is the name(s) of "extra" .cnv file(s) from which to read in'
                    'the added/edited/re-extracted parameters listed in extravars (default {})'};
        end


    case 'mctd_02'
        switch opt2
            case 'rawedit_auto'
                crhelp_str = {'Several types of edits to the raw data (_raw or _raw_noctm) to be '
                    'made by calling apply_autoedits. In order: '
                    ' '
                    'castopts.pumpsNaN.var1 = N gives the number of bad points N expected for variable var1'
                    '    after pumps come back on, e.g.'
                    'castopts.pumpsNaN.temp1 = 12; '
                    'castopts.pumpsNaN.cond1 = 12; '
                    'castopts.pumpsNaN.sbe_oxygen2 = 8*24'
                    ' '
                    'castopts.rangelim.var1 = [V1 V2] gives the range of acceptable values for variable var1, e.g.'
                    'castopts.rangelim.temp1 = [-2 40];'
                    ' '
                    'castopts.despike.var1 = [T1 ... Tn] gives the successive thresholds T1 to Tn for '
                    '    applying median despiking to variable var1, e.g.'
                    'castopts.despike.fluor = [0.3 0.2 0.2];'
                    ' '
                    'castopts.badscan.var1 = [S1_low S1_hi; ... SN_low SN_hi] gives 1 ... N ranges of scans'
                    '    over which to NaN variable var1 (inclusive);'
                    '    and/or you can specify in terms of times using'
                    'castopts.badtime.var1 = [t1_low t1_hi; ...]; etc.,'
                    '    and/or other variable(s), e.g. if you have connection problems leading to pressure and/or temperature spikes:'
                    'castopts.badpress.temp1 = [-1 8000; NaN NaN]; '
                    'castopts.badtemp1.cond1 = [-2 40; NaN NaN]; '
                    'castopts.badtemp1.oxygen1 = [-2 40; NaN NaN];'
                    '    NaNs temp1, cond1, oxygen1 when press is <-1 or >8000, or is NaN,'
                    '    and then cond1 and oxygen1 when temp1 is outside [-2 40] or is NaN '
                    ' '
                    'From sd025, pumpsNaN defaults to on; the rest default to off.'};
            case 'raw_corrs'
                crhelp_str = {'structure castopts contains:'
                    'flags for optional corrections to apply to the raw file (in this order): '
                    '  dooxyrev (default 0), if true, run moxyhyst_rev to undo the hysteresis '
                    '    correction applied in SBE processing, using parameters set in case ''oxyrev''; '
                    '  dooxyhyst (default 1), if true, run moxyhyst to apply a hysteresis correction, '
                    '    using parameters set below '
                    '    (note recommended path is to apply oxyhyst not in SBE processing but here, meaning'
                    '    it does not have to be undone before applying revised parameters here if indicated);'
                    '    note: if dooxyrev = 1 & dooxyhyst = 0, _24hz file will only have the oxygen_rev vars, not the ones '
                    '    that mctd_03 and subsequent processing stages are expecting (specified by second column of oxyvars '
                    '    set in opt1 = ''ctdpars''; opt2 = ''oxyvars'').'
                    '  doturbV (default 0), if true, convert from turbidity volts to turbidity again (to correct for '
                    '    precision problem), using parameters set below. '
                    '  oxyrev and oxyhyst, containing the parameters to pass to mcoxyhyst_rev and mcoxyhyst'
                    '    defaults to SBE values, but any of the 3 parameters could be a vector based on d.press;'
                    '    to use different parameters for sensor 1 and sensor 2, use cell arrays'
                    '  turbVpars, the scale factor and offset to convert from turbidity volts to turbidity'
                    '    (defaults to [3.343e-3 6.600e-2])'};
        end
        %%%%%%%%%% end mctd_02 %%%%%%%%%%

        %%%%%%%%%% mctd_03 %%%%%%%%%%
    case 'mctd_03'
        switch opt2
            case '1hz_interp'
                crhelp_str = {'maxfill24 sets maximum gap time (seconds, default: 0) to be filled by linear'
                    'interpolation before averaging 24hz to 1hz; maxfill1 sets maximum gap time (seconds, default: 2)'
                    'to be filled by linear interpolation after averging to 1 hz.'};
        end
        %%%%%%%%%% end mctd_03 %%%%%%%%%%

        %%%%%%%%%% mdcs_01 %%%%%%%%%%
    case 'mdcs_01'
        switch opt2
            case 'cast_divide'
                crhelp_str = {'set auto_start, auto_bot, auto_end (default 0, 1, 0) to overwrite'
                    'any values for cast start, bottom, end already in dcs file (if it exists);'
                    'optionally set kstart, kbot, kend (default []), indices in 1 hz file, to use those'
                    'instead of automatically detected values. The defaults mean that the first time'
                    'through all will be automatically detected, but if rerun after mdcs_03g, manual'
                    'selections for start and end will not be overwritten (change auto_bot to 0 too if'
                    'necessary to manually select cast bottom).'};
        end
        %%%%%%%%%% end mdcs_01 %%%%%%%%%%

        %%%%%%%%%% mctd_04 %%%%%%%%%%
    case 'mctd_04'
        switch opt2
            case 'doloopedit'
                crhelp_str = {'flag doloopedit (default 0) determines whether to apply automatic loop editing'
                    'using m_loopedit, and scalar ptol (default 0.08) sets the size of pressure loops to '
                    'ignore/tolerate if so.'};
            case 'interp2db'
                crhelp_str = {'maxfill2db determines maximum length of gaps in 2 dbar averaged data'
                    'to fill by linear interpolation (in dbar; default 0 though pre-dy113 default was inf).'};
        end
        %%%%%%%%%% end mctd_04 %%%%%%%%%%

        %%%%%%%%%% mfir_01 %%%%%%%%%%
    case 'mfir_01'
        switch opt2
            case 'blinfile'
            case 'nispos'
                crhelp_str = {'niskc gives the carousel positions and niskn the bottle numbers'
                    '(e.g. serial numbers, if known). length of both should = nnisk (set in castpars)'
                    'both default to [1:nnisk]''.'};
            case 'botflags'
                crhelp_str = {'Optional: edit niskin_flag, the vector of quality flags for Niskin bottle firing'
                    'for this station (use variable position to identify Niskins).'};
        end
        %%%%%%%%%% end mfir_01 %%%%%%%%%%

        %%%%%%%%%% mfir_03 %%%%%%%%%%
    case 'mfir_03'
        switch opt2
            case 'fir_fill'
                crhelp_str = {'firmethod and firopts determine how to get CTD data at Niskin firing times:'
                    'firmethod = ''medint'' to take median average over a scan interval around firing'
                    'scan set by firopts.int (e.g. default [-1 120] for just before to 5 s after); or'
                    'firmethod = ''linterp'' to linearly interpolate.'
                    'Additional fields of firopts set whether to fill gaps of any length (firopts.prefill = inf),'
                    'up to set length N (firopts.prefill = N; default 120), or not at all (firopts.prefill = 0)'
                    'by linear interpolation, before averaging or interpolating.'};
        end
        %%%%%%%%%% end mfir_03 %%%%%%%%%%

        %%%%%%%%%% mwin_01 %%%%%%%%%%
    case 'mwin_01'
        switch opt2
            case 'winchtime'
                crhelp_str = {'time_window = [time_start time_end] (default [-600 800] sets time range (s) '
                    'before/after cast time (which is determined from the ctd file) to look for winch data. '
                    'alternately, if winch_time_start and winch_time_end exist and are non-NaN, they give '
                    'the start and end times (matlab datenum form). they default to NaN.'};
        end
        %%%%%%%%%% end mwin_01 %%%%%%%%%%

        %%%%%%%%%% mwin_to_fir %%%%%%%%%%
    case 'mwin_to_fir'
        switch opt2
            case 'winch_fix'
                crhelp_str = {'Place to fix d.wireout'};
        end
        %%%%%%%%%% end mwin_to_fir %%%%%%%%%%

        %%%%%%%%%% mctd_checkplots %%%%%%%%%%
    case 'mctd_checkplots'
        switch opt2
            case 'plot_saltype'
                crhelp_str = {'set variable saltype (string) to choose whether to plot psal (default) or asal'};
        end
        %%%%%%%%%% end mctd_checkplots %%%%%%%%%%

        %%%%%%%%%% best_station_depths %%%%%%%%%%
    case 'best_station_depths'
        switch opt2
            case 'depth_recalc'
                crhelp_str = {'recalcdepth_stns (default []) lists stations for which to recalculate depths '
                    'even if they already have values in station_depths mat-file'};
            case 'depth_source'
                crhelp_str = {'depth_source (default: {''ladcp'', ''ctd''}) determines preferred method(s), '
                    'in order, for finding station depths. Other option is ''file''; if this is set, must also'
                    'specify fnintxt, the name of the ascii (csv or two-column text) file of [stations, depths].'};
            case 'bestdeps'
                crhelp_str = {'Place to edit those station depths that were not correctly filled in by '
                    'the chosen depmeth, either directly by editing bestdeps (a list of [station, depth]), '
                    'or by setting replacedeps, a list of [station, depth] only containing the pairs to edit.'
                    'Also can set stnmiss, a list of stations not to include in bestdeps list.'};
        end
        %%%%%%%%%% end best_station_depths %%%%%%%%%%

    case 'msbe35_01'
        switch opt2
            case 'sbe35file'
                crhelp_str = {'Filename pattern for SBE35 files (including wildcard) and indices for '
                    'finding station number in filename.'};
            case 'sbe35_datetime_adj'
                crhelp_str = {'Place to modify SBE35 file dates/times, as date is sometimes '
                    'not reset correctly before deployment. Only necessary if clock is far off.'};
            case 'sbe35flag'
                crhelp_str = {'Place to modify flags (t.flag, by t.sampnum) on SBE35 temperature data, and/or'
                    'remove spurious lines (leftovers in the wrong file) in table t by NaNing t.datnum or t.sampnum.'};
        end



        %%%%%%%%%% msal_01 %%%%%%%%%%
    case 'msal_01'
        switch opt2
            case 'sal_files'
                crhelp_str = {'salfiles is a list of files to load, defaults to '
                    'all sal_cruise_*.csv files in BOTTLE_SAL directory'};
            case 'sal_parse'
                crhelp_str = {'place to change fieldnames, combine fields, etc. after '
                    'loading; also to specify datform (default: ''dd/mm/yyyy'') and timform'
                    '(default: ''hh:mm:ss'') for converting date and time strings to datevec.'
                    'also a place to add information like cellT (bath temperature) or ssw_k15'
                    'if it is not a column in the file (or if it in the header, code to parse'
                    'it from salhead).'};
            case 'sal_flags'
                crhelp_str = {'Place to set flags on salinity bottles or readings: for bottles, change ds_sal.flag'
                    'based on ds_sal.sampnum. Note: sample flags: 1 not yet analysed, 2 good, 3 questionable,'
                    '4 bad, 5 not reported (?), 6 average of replicates, 9 not drawn.'
                    'For readings, NaN directly, or (default) search for files in ctd/BOTTLE_SAL/editlogs and apply previously selected'
                    'edits (gui to select more runs later in msal_01).'};
            case 'sal_calc'
                crhelp_str = {'sal_off sets salinity standard offsets (autosal units, additive, default []) for ranges'
                    'of sampnum, while sal_off_base (default ''sampnum_run'') to specify how to match them to samples.'
                    'Optionally, set sal_adj_comment here to give information on how standards offsets were chosen.'};
            case 'tsg_sampnum'
                crhelp_str = {'Place to parse tsg sampnum (default: same as sampnum read in from file'
                    'and dnum (datenum) from sampnum (default: either yyyymmddHHMM, or if sampnum<0, -jjjHHMM)'
                    'where jjj is yearday)'};
        end
        %%%%%%%%%% end msal_01 %%%%%%%%%%

        %%%%%%%%%% moxy_01 %%%%%%%%%%
    case 'moxy_01'
        switch opt2
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
                    '    in csv files, include code under opt2 = ''oxy_std'' case to compute from fix_temp and '
                    'botvol or botnum and a lookup table of bottle volumes)'
                    'n_o2, conc_o2 (optional, only include if you don''t want to recalculate '
                    '    from sample_titre)'
                    'flag, comment (optional).'};
            case 'oxy_parse'
                crhelp_str = {'Place to parse/store additional info from each file, for instance from header hs,'
                    'or to compute things from fields of ds, for instance looking up bottle volumes from bottle '
                    'numbers, or to specify mapping between file and mstar variable names in cell array oxyvarmap '
                    '(first column: mstar names, second column: names in file), or to set fillstat to call'
                    'fill_samdata_statnum to fill in missing station numbers on rows 2:N (default 0).'};
            case 'oxy_calc'
                crhelp_str = {'Place to set oxygen titration parameters required if you want to calculate conc_o2 '
                    '(rather than reading it in): '
                    'vol_reag_tot (for fixing reagents, no default, set to 0 if your bot_vol_tfix has already accounted for this) '
                    'cal_temp (temperature at which flask volumes were calibrated, no default), '
                    'mol_std, std_react_ratio, sample_react_ratio, mol_o2_reag (don''t change), '
                    'and optionally ds_oxy.vol_blank, ds_oxy.vol_titre_std, ds_oxy.vol_std, and'
                    'ds_oxy.bot_vol_tfix or ds_oxy.bot_vol (vol_reag_tot will be subtracted from bot_vol_tfix).'};
                %below almost certainly won't change
            case 'oxy_flags'
                crhelp_str = {'Place to change flags, ds_oxy.botoxya_flag, ds_oxy.botoxyb_flag.'};
        end
        %%%%%%%%%% end moxy_01 %%%%%%%%%%

    case 'moxy_to_sam'
        switch opt2
            case 'use_oxy_repl'
                crhelp_str = {'Set use_oxy_repl (default: 1) to 0 to not average replicates, 1 to average duplicates,'
                    'or 2 to average duplicates or triplicates'};
        end



        %%%%%%%%%% mnut_01 %%%%%%%%%%
    case 'mnut_01'
        switch opt2
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
        switch opt2
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


        %%%%%%%%%% mcfc_01 %%%%%%%%%%
    case 'mcfc_01'
        switch opt2
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
        switch opt2
            case 'cfclist'
                cfcinlist = 'sf6 sf6_flag cfc11 cfc11_flag cfc12 cfc12_flag f113 f113_flag ccl4 ccl4_flag';
                cfcotlist = cfcinlist;
            case 'flags'
                %change flags here
        end
        %%%%%%%%%% end mcfc_02 %%%%%%%%%%

        %%%%%%%%%% msam_ashore_flag %%%%%%%%%%
    case 'msam_ashore_flag'
        switch opt2
            case 'shore_sam_types'
                crhelp_str = {'If not already set in workspace, set samtypes'
                    '(default {}), a cell array list of sampletypes collected'
                    'for later analysis, e.g. samtypes = {''nut'', ''co2''};'
                    'or if there is only one you could instead set e.g. samtype = ''nut'';'
                    'If neither is set, script will prompt for a single samtype.'};
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
        %%%%%%%%%% end msam_ashore_flag %%%%%%%%%%

        %%%%%%%%%% msam_checkbottles_02 %%%%%%%%%%
    case 'checkbottles_02'
        switch opt2
            case 'section'
                %set section name corresponding to the gridded file to plot
                %anomalies from
            case 'docals'
        end
        %%%%%%%%%% end msam_checkbottles_02 %%%%%%%%%%


    case 'miso_01'
        switch opt2
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
        switch opt2
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
        end

        %%%%%%%%%% ship (not a script) %%%%%%%%%%


        %%%%%%%%%% bathy (not a script) %%%%%%%%%%
    case 'bathy'
        switch opt2
            case 'bathy_grid'
                crhelp_str = {'load gridded bathymetry into top.lon, top.lat, top.depth,'
                    'for use by mbathy_edit_av'};
        end
        %%%%%%%%%% end bathy (not a script) %%%%%%%%%%


        %%%%%%%%%% uway_daily_proc %%%%%%%%%%
    case 'uway_daily_proc'
        switch opt2
            case 'excludestreams'
                crhelp_str = {'uway_excludes lists streams to skip and uway_excludep lists '
                    'patterns (in stream names) to skip. Defaults depend on ship data system.'};
                crhelp_str = {'umtypes lists types of underway files to combine'
                    'Default is {''bathy'' ''tsgsurfmet''}, to interpolate the swath centre'
                    'beam depth into the single-beam file, and vice versa; and to'
                    'add the tsg (and for rvdas windsonic) variables into the surfmet file,'
                    '(re)calculating salinity from conductivity and housing temperature.'};
                umtypes = {'bathy' 'tsgsurfmet'};
        end
        %%%%%%%%%% end uway_daily_proc %%%%%%%%%%

        %%%%%%%%%% mday_01_clean_av %%%%%%%%%%
    case 'mday_01_clean_av'
        switch opt2
            case 'pre_edit_uway'
                crhelp_str = {'place to do specific edits like patching in data from another source'};
        end
        %%%%%%%%%% end mday_01_clean_av %%%%%%%%%%

        %%%%%%%%%% mday_01_fcal %%%%%%%%%%
    case 'mday_01_clean_append'
        % set non-cruise-specific calibration or editing actions
        switch opt2
            case 'uway_factory_cal'
                crhelp_str = {'this is a place to include factory calibration coefficients to'
                    'be applied to underway sensors: sensorcals is a structure giving'
                    'calibration equations, as strings, for each variable e.g. '
                    'sensorcals.fluo = ''y=(x1-0.082)*04.9;'';'
                    'sensorunits gives the corresponding units for data once the cals have been applied.'
                    'xducer_offset gives the depth of the transducer for converting e.g.'
                    'multib_t to multib (if not present; if multib already exists it will not be overwritten).'
                    'both sensors_to_cal (and sensorcals and sensorunits) and xducer_offset'
                    'should be set within a switch-case on abbrev. there are no default settings'};
        end
        %%%%%%%%%% end mday_01_fcal %%%%%%%%%%

        %%%%%%%%%% mtsg_bottle_compare %%%%%%%%%%
    case 'mtsg_bottle_compare'
        switch opt2
            case 'tsg_usecal'
                crhelp_str = {'If usecal has not been set before calling mtsg_bottle_compare,'
                    'set here (default 0) to determine whether to inspect the calibrated (1) or'
                    'uncalibrated (0) salinities.'};
            case 'tsg_badsal'
                crhelp_str = {'Place to NaN some of the bottle salinity points.'};
            case 'tsg_timebreaks'
                crhelp_str = {'tbreak (default []) is vector of datenums of break points for'
                    'the calibration e.g. when the TSG was cleaned'};
            case 'tsg_sdiff'
                crhelp_str = {'sc1 (default 0.5) and sc2 (default 0.02) are thresholds to use'
                    'for successive smoothing of bottle-tsg differences by removing outliers.'};
        end
        %%%%%%%%%% end mtsg_bottle_compare %%%%%%%%%%

        %%%%%%%%%% mtsg_medav_clean_cal %%%%%%%%%%
    case 'mtsg_medav_clean_cal'
        switch opt2
            case 'tsg_edits'
                crhelp_str = {'Edits to one or more tsg variables: '
                    'tsgedits.pumpsNaN.var1 = N gives the number of bad points N expected for variable var1'
                    '    after pumps come back on;'
                    'tsgedits.badtimes.var1 = [t1_low t1_hi; ... tN_low tN_hi] gives 1 ... N ranges of times'
                    '    over which to NaN variable var1 (inclusive);'
                    'tsgedits.rangelim.var1 = [V1 V2] gives the range of acceptable values for variable var1;'
                    'tsgedits.despike.var1 = [T1 ... Tn] gives the successive thresholds T1 to Tn for '
                    '    applying median despiking to variable var1.'
                    'e.g.:'
                    'tsgedits.pumpsNaN.temp_housing_raw = 120; %takes 2 minutes to flow through'
                    'tsgedits.pumpsNaN.conductivity_raw = 120; '
                    'tsgedits.badtimes.conductivity_raw = [-10 1e3; 5.5e5 5.6e5]; %start of cruise and TSG cleaning'
                    'tsgedits.badtimes.temp_housing_raw = [-10 1e3; 5.5e5 5.6e5]; '
                    'tsgedits.despike.fluor = [0.3 0.2 0.2];'
                    'All default to not set (no action).'};
            case 'tsgcals'
                crhelp_str = {'Set calibration functions to be applied to tsg variables, if'
                    'corresponding flags are set to true. See help for mctd_02, ctdcals (in setdef_cropt_uway.m).'};
        end
        %%%%%%%%%% end mtsg_medav_clean_cal %%%%%%%%%%

    case 'setup'
        switch opt2
            case 'time_origin'
                crhelp_str = {'Set MEXEC_G.MDEFAULT_DATA_TIME_ORIGIN, 6-element vector [yyyy mm dd HH MM SS],'
                    'usually the start of the cruise year'};
            case 'setup_datatypes'
                crhelp_str = {'Set use_ix_ladcp to ''yes'' (default) if you are collecting '
                    'LADCP data and want to add LDEO IX scripts to the path; set to '
                    '''query'' if you are processing both LADCP and mooring data on this '
                    'cruise, so that m_setup will ask which to add to path (due to repeated'
                    'filenames); set to ''no'' to never add.'};
        end

        %%%%%%%%%% batchactions (not a script) %%%%%%%%%%
    case 'batchactions'
        switch opt2
            case 'output_for_others'
                crhelp_str = {'additional actions after operating on ctd or sam files'
                    'for instance to sync the resulting files'
                    'to a shared drive accessible by e.g. chemistry team'};
        end
        %%%%%%%%%% batchactions (not a script) %%%%%%%%%%


        %%%%%%%%%% station_summary %%%%%%%%%%
    case 'station_summary'
        switch opt2
            case 'sum_stn_list'
                crhelp_str = {'stnmiss (default []) is a list of CTD station numbers that have '
                    'been processed but that are to be excluded from the summary;'
                    'stnadd (default []) is a list of stations without processed CTD data that '
                    'are to be included.'};
            case 'sum_varsams'
                crhelp_str = {'Place to set or select from vars, a list of station/ctd variables, their '
                    'units, fill values, and formats for printing to table (see code for defaults); '
                    'snames (default {''nsal''} a list of variable groups to count,'
                    'sgrps (default {{''sal''}}), a list of the corresponding variable names.'
                    'For samples analysed ashore, elements of snames should end in _shore.'};
            case 'sum_extras'
                crhelp_str = {'Place to add columns before or after the existing ones, for instance'
                    'for event numbers or station names, or comments. Add the names to vars either '
                    'at the start or end, and set the corresponding variables as cell arrays.'};
            case 'sum_edit'
                crhelp_str = {'Place to edit cordep, the vector of corrected depths for the set of stations'
                    'to be processed (default is to get from _psal file header), and/or minalt, the minimum '
                    'altimeter distance above bottom (set to -9 for did not detect the bottom));'
                    'also to set times for stations with no ctd cast.'};
            case 'sum_special_print'
                crhelp_str = {'Code for printing special cases, by default lat and lon in degrees minutes'
                    'format, and start, bottom, and end times as yy/mm/dd HHMM.'};
        end
        %%%%%%%%%% end station_summary %%%%%%%%%%


        %%%%%%%%%% mout_exch %%%%%%%%%%
    case 'mout_exch'
        switch opt2
            case 'woce_expo'
                crhelp_str = {'information for header of exchange-format csv files: '
                    'expocode and sect_id (defaults: ''unknown'' and empty, respectively)'};
            case 'woce_ctd_flags'
                crhelp_str = {'optional: change flag variables ctdflag (temp, sal), ctoflag (oxygen), '
                    'ctdfflag (fluor) from default of 2 where data present, 9 otherwise'};
            case 'woce_vars_exclude'
                crhelp_str = {'vars_exclude_ctd and vars_exclude_sam are lists of mstar variable names'
                    'to exclude from woce exchange-format output files for submission to cchdo, even if '
                    'they are in ctd/sam files and in lists set in m_cchdo_vars_list.m. '
                    'Defaults: vars_exclude_ctd = {}, vars_exclude_sam = {}.'};
            case 'woce_file_flagonly'
                crhelp_str = {'varsexclude is a cell array listing variables to NaN before printing to'
                    'exchange-format csv files (default: {})'};
            case 'woce_ctd_headstr'
                crhelp_str = {'optional headstring is a cell array of strings to add to header of '
                    'exchange-format csv file of ctd data (default: empty)'};
            case 'woce_sam_headstr'
                crhelp_str = {'optional headstring is a cell array of strings to add to header of '
                    'exchange-format csv file of sample data (default: empty)'};
        end
        %%%%%%%%%% end mout_exch %%%%%%%%%%

        %%%%%%%%%% msec_grid %%%%%%%%%%
    case 'msec_grid'
        switch opt2
            case 'sections_to_grid'
                crhelp_str = {'sections (cell array) contains a list of all sections to grid for this cruise'};
            case 'sec_stns_grids'
                crhelp_str = {'Use switch-case on section to set kstns (1xN, default 1:99):'
                    'list of stations (on this cruise) for each section;'
                    'xstatnumgrid and zpressgrid for maphsec (default [], if left empty they'
                    'will be looked up in msec_grid based on section, or set to maphsec defaults).'};
            case 'ctd_regridlist'
                crhelp_str = {'ctd_regridlist is a cell array list of CTD variables to be gridded;'
                    'default is temp, psal, potemp, oxygen. If empty, gridded CTD data will'
                    'be loaded from existing grid_ file and only bottle data will be remapped.'};
            case 'sam_gridlist'
                crhelp_str = {'sam_gridlist is a cell array list of bottle variables to be gridded;'
                    'default is botpsal, botoxy.'};
        end

        %%%%%%%%%% msec_plot_contrs %%%%%%%%%%
    case 'msec_plot_contrs'
        switch opt2
            case 'add_station_depths'
                crhelp_str = {'station_depth_width (default 0), if greater than 0, gives linewidth '
                    'for adding station depths to contour plots.'};
            case 'add_bottle_depths'
                crhelp_str = {'bottle_depth_size (default 0), if greater than 0, gives markersize '
                    'for adding bottle positions to contour plots.'};
        end
        %%%%%%%%%% end msec_plot_contrs %%%%%%%%%%

        %%%%%%%%%% set_clev_col %%%%%%%%%%
    case 'set_clev_col'
        switch opt2
            case 'samfn'

        end
        %%%%%%%%%% end set_clev_col %%%%%%%%%%

    case 'ladcp'
        switch opt2
            case 'ladcp_castpars'
                crhelp_str = {'place to change parameters for IX ladcp processing that are set in'
                    '(or can be set in) ix_cast_params as fields of (existing) structure p,'
                    'for instance: '
                    'p.ambiguity (ambiguity velocity), p.vlim (velocity limits), '
                    'p.btrk_mode (bottom track mode), p.up_sn and p.do_sn (instrument serial'
                    'numbers), etc.'};
            case 'ctd_1hz_format'
                crhelp_str = {'name, f.ctd, for text file of 1Hz '
                    'CTD data (e.g. for IX LADCP processing)'};
            case 'sadcp_file'
            case 'is_uplooker'
                crhelp_str = {'isul (default 1) sets whether there is an uplooking as well as a'
                    'downlooking LADCP'};
        end
        %%%%%%%%%% end ladcp %%%%%%%%%%

    case 'codas_to_mstar'
        switch opt2
            case 'codas_file'
        end


    case 'mrvdas_ingest'
        switch opt2
            case 'rvdas_skip'
                crhelp_str = {'Determine which tables and variables are listed in mrtables_from_json and'
                    'therefore read into mexec processing, by adding to or modifying:'
                    'table_skip: list of tables (id in the json files; also json file prefixes) to not load at all'
                    '  (e.g. air2sea_gravity)'
                    'msg_skip: list of messages (name or [talkId messageId]) to never read in from any '
                    '  instrument (e.g. GPDTM)'
                    'sentence_skip: list of instrument-message combinations ([id talkId messageId])'
                    '  not to read in (often because they duplicate other messages from the same '
                    '  instrument, e.g. phins_att_pixsepositi),'
                    'pat_skip: list of patterns, variables containing any of which will never be read in'
                    '  (e.g. unitsOf),'
                    'var_skip: list of variables to never be read in from any table/message'
                    '  (e.g. speedknots),'
                    'sentence_var_skip: list of instrument_message_variable combinations to not read in'
                    '  (e.g. sbe45_nanan_soundVelocity).'
                    'All are case-insensitive.'
                    'Defaults in msg_skip include datum, time zone, and satellite status,'
                    'defaults in json_skip include gravimeters, USBL, and (depending on the ship)'
                    'skipperlog and/or chernikeef E/M log,'
                    'defaults in sentence_skip are ship-dependent and include many phins messages on DY';
                    'defaults in pat_skip and var_skip include units, flags, and satellite-status related fields,'
                    'and there are no defaults for sentence_var_skip.'};
        end

        %things that have defaults
switch opt1

    case 'castpars'
        %parameters (often used by multiple scripts), related to CTD/LADCP casts
        switch opt2
            case 'minit'
                crhelp_str = {'queries for stn if not set, makes stn_string (default: 3-digit form of stn)'
                    'for filenames and moves stn to stnlocal'};
                if ~exist('stn', 'var')
                    stn = input('type stn number ');
                end
                stnlocal = stn; clear stn
                stn_string = sprintf('%03d',stnlocal);
            case 'nnisk'
                crhelp_str = 'nnisk (default: 24) is number of Niskins on rosette. can be station-dependent.';
                nnisk = 24;
            case 'oxyvars'
                crhelp_str = {'oxyvars (default: {''oxygen_sbe1''; ''oxygen_sbe2''}) is a cell array listing the name(s) of ';
                    'oxygen variables in raw file (first column) and 24hz file (second, don''t change this). If you only have ';
                    'one oxygen sensor, keep just the first row; if you change ctd_renamelist.csv, change the first ';
                    'column accordingly.'};
                oxyvars = {'oxygen_sbe1' 'oxygen1'; 'oxygen_sbe2' 'oxygen2'};
            case 'oxy_align'
                crhelp_str = {'oxy_align (default 6) is the number of seconds by which oxygen has been shifted in'
                    'SBE processing. Set oxy_end (default 0) to 1 if you are selecting end of cast (in mdcs_03g)'
                    'based on T, S rather than oxygen'};
                oxy_align = 6;
                oxy_end = 0;
            case 'ctdsens_groups'
                crhelp_str = {'sg is a structure with fields corresponding to the CTD sensors e.g.'
                    'temp1, oxygen1, temp2, etc. default is to load from a .mat file generated by get_sensor_groups.m.'
                    'their values are Nx2 cell arrays listing stations and corresponding sensor/serial number, '
                    'in case one or more sensors was changed during the cruise.'};
                sgfile = fullfile(mgetdir('ctd'),'sensor_groups.mat');
            case 's_choice'
                crhelp_str = {'s_choice (default 1) sets the primary sensor for temperature and conductivity; '
                    'stns_alternate_s (default []) lists stations on which to use the other one. if there is '
                    'only one CTD, keep the default (1).'};
                s_choice = 1;
                stns_alternate_s = [];
            case 'o_choice'
                crhelp_str = {'o_choice (default 1) sets the primary sensor for oxygen; '
                    'stns_alternate_o (default []) lists stations on which to use the other one.'
                    'if there is only one oxygen sensor, keep the default (1).'};
                o_choice = 1;
                stns_alternate_o = [];
        end

    case 'calibration'
        switch opt2
            case 'ctd_cals'
                crhelp_str = {'Set calibration functions to be applied to variables in _24hz file, if '
                    'corresponding flags are set to true. '
                    'Functions are set in castopts.calstr, a structure whose fields are sensors (e.g. cond1, oxygen2),'
                    'each of which itself has two fields: the cruise name containing the calibration function as a string'
                    'e.g. ''dcal.cond1 = d0.cond1.*(1+4e-4*d0.statnum)/35;'','
                    'and ''msg'' a string containing information to be added to the file header along with'
                    'the calibration function, e.g. ''using bottle salinities from stations 1-40 only''.'
                    'Flags are set in structure docal, containing temp, cond, oxygen, fluor, transmittance.'
                    'All default to 0 (no calibration).'};
                castopts.docal.temp = 0;
                castopts.docal.cond = 0;
                castopts.docal.oxygen = 0;
                castopts.docal.fluor = 0;
                castopts.docal.transmittance = 0;
                if isfield(castopts,'calstr')
                    %no default
                    castopts = rmfield(castopts,'calstr');
                end
            case 'sensor_factory_cals'
                sensorcals = struct();
                xducer_offset = [];
            case 'tsg_cals'
                tsgopts.docal.temp = 0;
                tsgopts.docal.cond = 0;
                tsgopts.docal.fluor = 0;
                if isfield(tsgopts,'calstr')
                    %no default
                    tsgopts = rmfield(tsgopts,'calstr');
                end
        end

    case 'check_sams'
        crhelp_str = {'Flags for whether to display/plot comparisons or questionable sample readings.'};
        check_sal = 0; %or can be an integer >=1 to display starting at this station
        check_oxy = 0;
        check_sbe35 = 0;

    case 'ship'
        %parameters used by multiple scripts, related to ship underway data
        switch opt2
            case 'datasys_best'
                switch MEXEC_G.Mshipdatasystem
                    case 'techsas'
                        uway_torg = datenum([1899 12 30 0 0 0]); % techsas time origin as a matlab datenum
                        uway_root = fullfile(MEXEC_G.mexec_data_root, 'techsas', 'netcdf_files_links');
                        if ismac; uway_root = [uway_root '_mac']; end
                    case 'scs'
                        uway_torg = 0; % mexec parsing of SCS files converts matlab datenum, so no offset required
                        uway_root = fullfile(MEXEC_G.mexec_data_root, 'scs_raw'); % scs raw data on logger machine
                        uway_sed = fullfile(MEXEC_G.mexec_data_root, 'scs_sed'); % scs raw data on logger machine
                        uway_mat = fullfile(MEXEC_G.mexec_data_root, 'scs_mat'); % local directory for scs converted to matlab
                    case 'rvdas'
                        uway_torg = 0; % mrvdas parsing returns matlab dnum. No offset required.
                end
            case 'ship_data_sys_names'
                crhelp_str = {'Datasystem- (and possibly ship-) specific list of mexec directory names '
                    'for tsg file (tsgpre) and surfmet file (metpre).'};
                switch MEXEC_G.Mshipdatasystem
                    case 'rvdas'
                        tsgpre = 'tsg';
                        metpre = 'surfmet';
                    case 'techsas'
                        tsgpre = 'tsg';
                        metpre = 'met';
                    case 'scs'
                        tsgpre = 'oceanlogger';
                        metpre = 'met';
                end
            case 'rvdas_database'
                RVDAS.csvroot = fullfile(MEXEC_G.mexec_data_root, 'rvdas', 'rvdas_csv_tmp');
            case 'rvdas_form'
                crhelp_str = {'If use_cruise_views = 1 (default 0), prepend string view_name'
                    '(default lower(MEXEC_G.MSCRIPT_CRUISE_STRING)) to names from the json files.'
                    'Set npre, the number of prefixes (separated by underscores) in '
                    'rvdas table names which are not part of the instrument name, e.g.'
                    'with npre=1, ''anemometer_ft_technologies_ft702lt_wimwv'' the instrument'
                    'name would be ft_technologies_ft702lt'};
                switch MEXEC_G.Mship
                    case 'sda'
                        use_cruise_views = 1;
                        view_name = lower(MEXEC_G.MSCRIPT_CRUISE_STRING);
                        npre = 1;
                    otherwise
                        npre = 0;
                end
        end

    case 'uway_proc'
        switch opt2
            case 'avtime'
                crhelp_str = {'Number of seconds over which to average nav, met, and tsg measurements'
                    'in appended files.'};
                avnav = 30;
                avmet = 60;
                avtsg = 60;
            case 'comb_uvars'
        end

    case 'outputs'
        switch opt2
            case 'grid'
                kstns = 1:99;
                xstatnumgrid = [];
                zpressgrid = [];
                ctd_regridlist  = {'temp' 'psal' 'potemp' 'oxygen'};
                sam_gridlist = {'botpsal' 'botoxy'};
            case 'ladcp'
                f.ctd = fullfile(root_out, 'ctd', ['ctd.' stn_string '.02.asc']);
                %ctdh = sprintf('year day (%d), press (dbar), temp (degC90), psal (psu), lat, lon');
                f.ctd_header_lines      = 1;
                f.ctd_fields_per_line	= 6;
                f.ctd_time_base = 1;
                f.ctd_time_field = 1;
                f.ctd_pressure_field	= 2;
                f.ctd_temperature_field = 3;
                f.ctd_salinity_field	= 4;
                f.nav                   = f.ctd;
                f.nav_header_lines	= f.ctd_header_lines;
                f.nav_fields_per_line	= f.ctd_fields_per_line;
                f.nav_time_base = f.ctd_time_base;
                f.nav_time_field	= f.ctd_time_field;
                f.nav_lat_field 	= 5;
                f.nav_lon_field 	= 6;
                root_out = mgetdir('M_LADCP');
                f.sadcp = fullfile(mgetdir('M_LADCP'),'SADCP',['os75nb_' mcruise '_' cfg.stnstr '_for_ladcp.mat']);
            case 'exch'
                expocode = 'unknown';
                sect_id = '';
                vars_exclude_ctd = {}; %changed jc238 from {'fluor' 'transmittance'};
                vars_exclude_sam = {};
                varsexclude = {};
            case 'plot'
                station_depth_width = 0;
                bottle_depth_size = 0;

        end

end

end