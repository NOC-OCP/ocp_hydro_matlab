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
    
    %%%%%%%%%% castpars (not a script) %%%%%%%%%%
    case 'castpars'
        %parameters used by multiple scripts, related to CTD/LADCP casts
        switch oopt
            case 'klist'
                crhelp_str = {'klist_exc (default: []) lists casts with no CTD to exclude from klist for ';
                    'batch processing scripts'};
                klist_exc = [];
            case 'nnisk'
                crhelp_str = 'nnisk (default: 24) is number of Niskins on rosette. can be station-dependent.';
                nnisk = 24;
            case 'oxyvars'
                crhelp_str = {'oxyvars (default: {''oxygen_sbe1''; ''oxygen_sbe2''}) is a cell array listing the name(s) of ';
                    'oxygen variables in raw file (first column) and 24hz file (second, don''t change this). If you only have ';
                    'one oxygen sensor, keep just the first row; if you change templates/ctd_renamelist.csv, change the first ';
                    'column accordingly.'};
                oxyvars = {'oxygen_sbe1' 'oxygen1';
                    'oxygen_sbe2' 'oxygen2'};
            case 'oxy_align'
                crhelp_str = {'oxy_align (default 6) is the number of seconds by which oxygen has been shifted in'
                    'SBE processing. Set oxy_end (default 0) to 1 to remove this many seconds before end of cast '
                    'selected in mdcs_03g.'};
                oxy_align = 6;
                oxy_end = 0;
            case 'shortcasts'
                crhelp_str = {'shortcasts (default: []) is a list of statnums with non full depth casts '
                    '(for which you would need to fill in depth in populate_station_depths,'
                    'and wouldn''t bother with the BT constraint on LADCP processing, etc.)'};
                shortcasts = [];
            case 'ctdsens_groups'
                crhelp_str = {'ctdsens_groups is a structure with fields corresponding to the CTD sensors e.g.'
                    'temp1, cond1, oxygen1, temp2, etc.; their values are Nx1 cell arrays listing stations '
                    'for a given sensor/serial number, in case one or more sensors was changed during the cruise.'
                    'all default to {1:999}, but, for instance, you could set ctdsens_groups.oxygen1 = {1:30 31:70} '
                    'if the CTD1 oxygen sensor was changed between stations 30 and 31.'}; 
                    ctdsens_groups.temp1 = {1:999};
                    ctdsens_groups.cond1 = {1:999};
                    ctdsens_groups.oxygen1 = {1:999};
                    ctdsens_groups.temp2 = {1:999};
                    ctdsens_groups.cond2 = {1:999};
                    ctdsens_groups.oxygen2 = {1:999};
                    ctdsens_groups.fluor = {1:999};
                    ctdsens_groups.transmittance = {1:999};
        end
        %%%%%%%%%% end castpars (not a script) %%%%%%%%%%
        
        
        %%%%%%%%%% minit %%%%%%%%%%
    case 'minit'
        switch oopt
            case 'stn_string'
                crhelp_str = 'stn_string (default: three-digit form of station number stn) is for filenames';
                stn_string = sprintf('%03d',stn);
        end
        %%%%%%%%%% end minit %%%%%%%%%%
                
        %%%%%%%%%% mctd_01 %%%%%%%%%%
    case 'mctd_01'
        switch oopt
            case 'redoctm'
                crhelp_str = {'redoctm defaults to 0 to generate raw file from .cnv file that had cell thermal mass correction'
                    'applied in SBE processing. set to 1 to instead generate raw file from pre-CTM file (to remove large spikes), '
                    'and subsequently apply ctm correction in mctd_02a.'
                    'suf is the .cnv file suffix in either case (defaults ''_align_ctm'' or ''_align_noctm'')'};
                redoctm = 0;
        end
        %%%%%%%%%% end mctd_01 %%%%%%%%%%
        
        %%%%%%%%%% mctd_02a %%%%%%%%%%
    case 'mctd_02a'
        switch oopt
            case 'ctdvars' %***not updating past opt_cruise files (yet)
                crhelp_str = {'Place to put additional (ctdvars_add) or replacement (ctdvars_replace)'
                    'triplets of SBE variable name, mstar variable name, mstar variable units to '
                    'supplement those in templates/ctd_renamelist.csv. Default is both empty.'};
                ctdvars_replace = {};
                ctdvars_add = {};
            case 'absentvars' % introduced new on jc191
                crhelp_str = {'absentvars (default {}) is a cell array of strings listing variables not present '
                    'for given station(s); if applicable should be set in opt_cruise for selected stations '
                    '(variables that are never present should be removed from templates/ctd_renamelist.csv instead)'};
                absentvars = {}; %default: don't skip any variables
            case 'prectm_rawedit'
                crhelp_str = {'edits to the raw data to be made before applying the cell thermal mass correction '
                    '(that is, branch will be entered only if mctd_01 set redoctm to 1 and generated a _noctm raw file): '
                    'pvars is a cell listing variables to NaN when pumps are off, with the second column '
                    'of the cell array setting the number of bad scans expected after pumps come back on; '
                    'sevars is a list of variables for which to edit out scans between the limits given by the second '
                    'and third columns, inclusive (can use -inf or +inf); '
                    'revars is a list of variables to NaN values out of the ranges given by the 2nd (lower limits) '
                    'and 3rd (upper limits) columns of the array; '
                    'dsvars is a list of variables to despike using m_median_despike, with thresholds given columns 2:end;'
                    'ovars is a list of oxygen variables to which to apply alignment correction (*** all of them presumably?)'
                    'all default to empty (no automatic edits at this stage) '
                    'however, if redoctm is true, it is presumably because you want to use at least one of '
                    'pvars, sevars, revars, dsvars to edit the raw data before reapplying the cell thermal mass correction'};
                pvars = {};
                sevars = [];
                revars = {};
                dsvars = {};
                ovars = {}; %***specify in mctd_01 and here that the redoctm branch goes back before align too?***
        end
        %%%%%%%%%% end mctd_02a %%%%%%%%%%
        
        %%%%%%%%%% mctd_02b %%%%%%%%%%
    case 'mctd_02b'
        switch oopt
            case 'raw_corrs'
                crhelp_str = {'flags for optional corrections to apply to the raw file (in this order): '
                    'dooxyrev (default 0), if true, run moxyhyst_rev to undo the hysteresis '
                    'correction applied in SBE processing, using parameters set in case ''oxyrev''; '
                    'dooxyhyst (default 1), if true, run moxyhyst to apply a hysteresis correction, '
                    'using parameters set in case ''oxyhyst'' '
                    '(note recommended path is to apply oxyhyst not in SBE processing but here, meaning'
                    'it does not have to be undone before applying revised parameters here if indicated);'
                    'note: if dooxyrev = 1 & dooxyhyst = 0, _24hz file will only have the oxygen_rev vars, not the ones '
                    'that mctd_03 and subsequent processing stages are expecting (specified by second column of oxyvars '
                    'set in scriptname = ''ctdpars''; oopt = ''oxyvars'').'
                    'doturbV (default 0), if true, convert from turbidity volts to turbidity again (to correct for '
                    'precision problem), using parameters set in case ''turbVpars''. '
                    'Structure docal has fields temp, cond, oxygen, fluor, transmittance, all default to 0, set to'
                    '1 to apply calibrations specified under ''ctdcals'' below to these sensor types.'};
                dooxyrev = 0;
                dooxyhyst = 1;
                doturbV = 0;
                docal.temp = 0; docal.cond = 0; docal.oxygen = 0; docal.fluor = 0; docal.transmittance = 0;
            case 'oxyrev'
                crhelp_str = {'sets three parameters to pass to mcoxyhyst_rev; defaults to standard SBE processing values.'};
                H1 = -0.033;
                H2 = 5000;
                H3 = 1450;
            case 'oxyhyst'
                crhelp_str = {'sets three parameters to pass to mcoxyhyst; defaults to standard SBE processing values.'
                    'H1, H2, H3 can each be scalar, or you can use d.press to make any/all a vector dependent on pressure; '
                    'they can also be set differently for e.g. oxygen_sbe1 and oxygen_sbe2.'};
                H1 = -0.033;
                H2 = 5000;
                H3 = 1450;
                H_0 = [H1 H2 H3];
            case 'turbVpars'
                crhelp_str = {'sets scale factor and offset to apply to turbidity volts to convert to turbidity, '
                    'defaults to the values from XMLCON for BBRTD-182, calibration date 6 Mar 17 (see your XMLCON file)'};
                turbVpars = [3.343e-3 6.600e-2]; %from XMLCON for BBRTD-182, calibration date 6 Mar 17
            case 'ctdcals'
                crhelp_str = {'Set calibration functions to be applied to variables in _24hz file, if '
                    'corresponding docal flags were set in ''raw_corrs'' case above. Use '
                    'calstr, a cell array (Nx1) of strings expressing the calibration functions between '
                    'fields in d0 and calibrated fields in dcal, e.g.:'
                    'calstr = {''dcal.temp1 = d0.temp1 - 1.2e-4*d0.statnum;''};'
                    'and calmsg, a cell array (Nx2) whose rows correspond to calstr, with the first column '
                    'set to contain the varible to be calibrated, then a space, then the cruise name '
                    '(lower case) -- this is used as a partial check against copy-pasting code from a '
                    'previous cruise and accidentally applying the wrong calibration -- the second '
                    'column of calmsg optionally contains a string about how/when the calibration '
                    'function was selected, e.g. calmsg = {''temp1 jc211'' ''based on comparison with SBE35 from stations 1-30''}.'};
                calstr = {}; calmsg = {};
        end
        %%%%%%%%%% end mctd_02b %%%%%%%%%%
        
        %%%%%%%%%% mctd_03 %%%%%%%%%%
    case 'mctd_03'
        switch oopt
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
            case '24hz_edit'
                crhelp_str = {'for each row of cell array badscans24 ({''variable'' scanlo scanhi}, default {}), '
                    'NaN variable between scanlo and scanhi (inclusive); '
                    'for each row of switchscans24 (same form and default), paste secondary sensor values for '
                    'that variable into primary sensor variable between scanlo and scanhi (inclusive). if you '
                    'list cond you must also list temp and vice versa. if the switchscans24 variable has only one '
                    'sensor, it is ignored.'};
                badscans24 = {};
                switchscans24 = {};
            case '24hz_interp'
                crhelp_str = {'flag interp24 sets whether to interpolate over gaps in 24 hz data; if 1, variable '
                    'maxgap (default: 12) is required to set maximum number of missing scans to fill. interp24 defaults to 0 for '
                    'pre-dy113 cruises, jc191/192, and dy120/129, and 1 for dy113, jc211, and subsequent cruises'};
                if MEXEC_G.MDEFAULT_DATA_TIME_ORIGIN(1)<=2019 | sum(strcmp(MEXEC_G.MSCRIPT_CRUISE_STRING,{'jc191';'jc192';'dy120';'dy129'}))
                    interp24 = 0;
                else
                    interp24 = 1; maxgap = 12;
                end
            case '1hz_interp'
                crhelp_str = {'flag interp1hz sets whether to interpolate over gaps in 1 hz data (in _psal file): '
                    'defaults to 0; if 1, you must also specificy maxgap1 to interpolate gaps up to maxgap1 points.'};
                interp1hz = 0;
        end
        %%%%%%%%%% end mctd_03 %%%%%%%%%%
        
        %%%%%%%%%% mdcs_01 %%%%%%%%%%
    case 'mdcs_01'
        switch oopt
            case 'kbot'
                crhelp_str = {'kbot sets the index of the bottom; it defaults to the first index where '
                    'p==max(p), where p is pressure from the 1hz _psal file.'};
                kbot = min(find(d1.press==max(d1.press)));
        end
        %%%%%%%%%% end mdcs_01 %%%%%%%%%%
        
        %%%%%%%%%% mctd_04 %%%%%%%%%%
    case 'mctd_04'
        switch oopt
            case 'pre_2_treat'
                crhelp_str = {'edit data (24 hz data including derived variables) in dvars file before averaging '
                    'to 2 dbar. this has generally been done by modifying copystr (see prevous opt_cruise file for examples).'};
            case 'doloopedit'
                crhelp_str = {'flag doloopedit (default 0) determines whether to apply automatic loop editing'
                    'using m_loopedit, and scalar ptol (default 0.08) sets the size of pressure loops to '
                    'ignore/tolerate if so.'};
                doloopedit = 0;
                ptol = 0.08; %default is not to apply, but this would be the default value if you did
            case 'interp2db'
                crhelp_str = {'flag interp2db determines whether to fill gaps in 2 dbar averaged data or not. for cruises '
                    'before 2020, and for jc191/192 and dy120/129 it defaulted to 1; for dy113 and subsequent cruises it defaults '
                    'to 0, as short gaps are instead filled in 24hz data (and large gaps shouldn''t be filled)'};
                if MEXEC_G.MDEFAULT_DATA_TIME_ORIGIN(1)<=2019 | sum(strcmp(MEXEC_G.MSCRIPT_CRUISE_STRING,{'jc191','jc192','dy120','dy129'}))
                    interp2db = 1; %filling gaps in 2dbar data used to be standard
                else
                    interp2db = 0;
                end
        end
        %%%%%%%%%% end mctd_04 %%%%%%%%%%

        %%%%%%%%%% mfir_01 %%%%%%%%%%
    case 'mfir_01'
        switch oopt
            case 'fixbl'
                crhelp_str = {'place to edit information about the bottle positions if it was wrong '
                    'in the .bl and/or .btl file(s). rarely needed.'};
        end
        %%%%%%%%%% end mfir_01 %%%%%%%%%%
        
        %%%%%%%%%% mfir_03 %%%%%%%%%%
    case 'mfir_03'
        switch oopt
            case 'fir_fill'
                crhelp_str = {'fillstr determines how many NaNs to fill in 1hz data before interpolation '
                    'to bottle firing scans: ''f'' or inf for any number, 0 or ''k'' for not at all, or '
                    'an integer (as a string, e.g. ''10'') to fill that number of points (seconds). '
                    'if avi_opt==0, linearly interpolate to bottle firing scan; if avi_opt is a tuple, '
                    'it specifies the window of scans relative to firing scan over which to'
                    'compute the median. Note scans are 24-hz. Defaults are inf and 0.'};
                    %***default fill any length gap???
                fillstr = inf;
                avi_opt = 0; 
        end
        %%%%%%%%%% end mfir_03 %%%%%%%%%%
        
        %%%%%%%%%% mwin_01 %%%%%%%%%%
    case 'mwin_01'
        switch oopt
            case 'winchtime'
                crhelp_str = {'time_window = [time_start time_end] (default [-600 800] sets time range (s) '
                    'before/after cast time (which is determined from the ctd file) to look for winch data. '
                    'alternately, if winch_time_start and winch_time_end exist and are non-NaN, they give '
                    'the start and end times (matlab datenum form). they default to NaN.'};
                time_window = [-600 800];
                winch_time_start = nan;
                winch_time_end = nan;
        end
        %%%%%%%%%% end mwin_01 %%%%%%%%%%
        
        %%%%%%%%%% mwin_to_fir %%%%%%%%%%
    case 'mwin_to_fir'
        switch oopt
            case 'winch_fix'
                crhelp_str = {'Place to fix d.wireout'};
        end
        %%%%%%%%%% end mwin_to_fir %%%%%%%%%%
        
        %%%%%%%%%% mctd_checkplots %%%%%%%%%%
    case 'mctd_checkplots'
        switch oopt
            case 'plot_saltype'
                crhelp_str = {'set variable saltype (string) to choose whether to plot psal (default) or asal'};
                saltype = 'psal';
        end
        %%%%%%%%%% end mctd_checkplots %%%%%%%%%%
        
        %%%%%%%%%% mctd_rawedit %%%%%%%%%%
    case 'mctd_rawedit'
        switch oopt
            case 'rawedit_auto'
                crhelp_str = {'edits to the raw (or raw_cleaned, if file already exists) data to be made before '
                    'running the mctd_rawedit GUI to choose additional edits: '
                    'oxy_end sets number of seconds to NaN off the end of the oxygen records, if you selected the '
                    'end of the cast based on temperature and conductivity instead (default: 0); '
                    'sevars is a list of variables for which to edit out scans between the limits given by the second '
                    'and third columns, inclusive (can use -inf or +inf); '
                    'revars is a list of variables to NaN values out of the ranges given by the 2nd (lower limits) '
                    'and 3rd (upper limits) columns of the array; '
                    'dsvars is a list of variables to despike using m_median_despike, with thresholds given columns 2:end;'
                    'all default to empty (no automatic edits at this stage).'};
                oxy_end = 0;
                pvars = {};
                sevars = {};
                revars = {};
                dsvars = {};
        end
        %%%%%%%%%% end mctd_rawedit %%%%%%%%%%
        
        %%%%%%%%%% populate_station_depths %%%%%%%%%%
    case 'populate_station_depths'
        switch oopt
            case 'depth_recalc'
                crhelp_str = {'recalcdepth_stns (default []) lists stations for which to recalculate depths '
                    'even if they already have values in station_depths mat-file'};
                recalcdepth_stns = [];
            case 'depth_source'
                crhelp_str = {'depth_source (default: {''file'', ''ctd''}) determines preferred method(s), '
                    'in order, for finding station depths. Other option is ''ladcp''. If one of the methods '
                    'is ''file'', fnintxt specifies name of ascii (csv or two-column text) file of [stations, depths].'};
                depth_source = {'file', 'ctd'}; %load from two-column text file, then fill with ctd press+altimeter
                fnintxt = [mgetdir('M_CTD_DEP') '/station_depths_' mcruise '.txt'];
            case 'bestdeps'
                crhelp_str = {'Place to edit those station depths that were not correctly filled in by '
                    'the chosen depmeth, either directly by editing bestdeps (a list of [station, depth]), '
                    'or by setting replacedeps, a list of [station, depth] only containing the pairs to edit.'
                    'Also can set stnmiss, a list of stations not to include in bestdeps list.'};
                replacedeps = [];
                stnmiss = [];
        end
        %%%%%%%%%% end populate_station_depths %%%%%%%%%%
        
        
        %%%%%%%%%% ctd_evaluate_sensors %%%%%%%%%%
    case 'ctd_evaluate_sensors'
        switch oopt
            case {'tsensind','csensind','osensind'}
                %***
                sensind = {1:length(d.statnum)}; %default: no sensors changed out
        end
        %%%%%%%%%% end ctd_evaluate_sensors %%%%%%%%%%
        
        
end
