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
        %parameters (often used by multiple scripts), related to CTD/LADCP casts
        switch oopt
            case 'minit'
                crhelp_str = {'stn_string (default: 3-digit form of stn) for filenames'
                    'and moves stn to stnlocal'};
                if ~exist('stn', 'var')
                    stn = input('type stn number ');
                end
                stnlocal = stn; clear stn
                stn_string = sprintf('%03d',stnlocal);
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
                    'one oxygen sensor, keep just the first row; if you change ctd_renamelist.csv, change the first ';
                    'column accordingly.'};
                oxyvars = {'oxygen_sbe1' 'oxygen1';
                    'oxygen_sbe2' 'oxygen2'};
            case 'oxy_align'
                crhelp_str = {'oxy_align (default 6) is the number of seconds by which oxygen has been shifted in'
                    'SBE processing. Set oxy_end (default 0) to 1 if you are selecting end of cast (in mdcs_03g)'
                    'based on T, S rather than oxygen'};
                oxy_align = 6;
                oxy_end = 0;
            case 'shortcasts'
                crhelp_str = {'shortcasts (default: []) is a list of statnums with non full depth casts '
                    '(for which you would need to fill in depth in populate_station_depths,'
                    'and wouldn''t bother with the BT constraint on LADCP processing, etc.)'};
                shortcasts = [];
            case 'ctdsens_groups'
                                crhelp_str = {'ctdsens is a structure with fields corresponding to the CTD sensors e.g.'
                    'temp1, oxygen1, temp2, etc. (temp1 applies to both temp1 and cond1); '
                    'their values are 2edit setdexN cell arrays listing stations and corresponding sensor/serial number, '
                    'in case one or more sensors was changed during the cruise.'
                    'all default to [1:999] in the first row and 1 in the second (no change of sensors), '
                    'but, for example, you could set ctdsens.oxygen1 = [1:30; [ones(1,8) ones(2,22)];'
                    'if the CTD1 oxygen sensor was changed between stations 8 and 9.'};
                a = [1:999; ones(1,999)];
                ctdsens.temp1 = a;
                ctdsens.oxygen1 = a;
                ctdsens.temp2 = a;
                ctdsens.oxygen2 = a;
                ctdsens.fluor = a;
                ctdsens.transmittance = a;
        end
        %%%%%%%%%% end castpars (not a script) %%%%%%%%%%
        
        %%%%%%%%%% mctd_01 %%%%%%%%%%
    case 'mctd_01'
        switch oopt
            case 'redoctm'
                crhelp_str = {'redoctm defaults to 0 to generate raw file from .cnv file that had cell thermal mass correction'
                    'applied in SBE processing. set to 1 to instead generate raw file from pre-CTM file (to remove large spikes), '
                    'and subsequently apply ctm correction in mctd_02a.'
                    'suf is the .cnv file suffix in either case (defaults ''_align_ctm'' or ''_align_noctm'')'};
                redoctm = 0;
            case 'cnvfilename'
                crhelp_str = {'cnvfile is the name of the .cnv file to read in'};
                if redoctm
                    cnvfile = sprintf('%s_%03d.cnv', upper(mcruise), stnlocal);
                else
                    cnvfile = sprintf('%s_%03d_align_CTM.cnv', upper(mcruise), stnlocal);
                end
                cnvfile = fullfile(mgetdir('M_CTD_CNV'),cnvfile);
            case 'ctdvars'
                crhelp_str = {'ctdvarmap is a list of sbe variable names, corresponding mstar names,'
                    'and default units (only to be filled in if units are empty).'};
                ctdvarmap = {'prDM','press','dbar'
                    't090C','temp1','degc90'
                    't190C','temp2','degc90'
                    'altM','altimeter','meters'
                    'ptempC','pressure_temp','degc90'
                    'timeS','time','seconds'
                    'scan','scan','number'
                    'pumps','pumps','pump_status'
                    'latitude','latitude','degrees'
                    'longitude','longitude','degrees'
                    'c0mS_slash_cm','cond1','mS/cm'
                    'c1mS_slash_cm','cond2','mS/cm'
                    'sbeox0V','sbeoxyV1','volts'
                    'sbox0Mm_slash_Kg','oxygen_sbe1','umol/kg'
                    'sbeox1V','sbeoxyV2','volts'
                    'sbox1Mm_slash_Kg','oxygen_sbe2','umol/kg'
                    'T2_minus_T190C','t2_minus_t1','degc90'
                    'C2_minus_C1mS_slash_cm','c2_minus_c1','mS/cm'
                    'flECO_minus_AFL','fluor','mg/m^3'
                    'flC','fluor','ug/l'
                    'wetCDOM','fluor_cdom','mg/m^3'
                    'xmiss','transmittance','percent'
                    'CStarTr0','transmittance','percent'
                    'transmittance','transmittance','percent'
                    'CStarAt0','attenuation','1/m'
                    'turbWETbb0','turbidity','m^-1/sr'
                    'par','par_up','umol photons/m^2/sec'
                    'par1','par_dn','umol photons/m^2/sec'};
            case 'absentvars' % introduced new on jc191
                crhelp_str = {'absentvars (default {}) is a cell array of strings listing variables not present '
                    'for given station(s); if applicable should be set in opt_cruise for selected stations '
                    '(variables that are never present should be removed from ctd_renamelist.csv instead)'};
                absentvars = {}; %default: don't skip any variables
            case 'extracnv' %post-jc238
                crhelp_str = {'extracnv (default {}) is the name(s) of "extra" .cnv file(s) from which to read in'
                    'the added/edited/re-extracted parameters listed in extravars (default {})'};
                extracnv = {};
                extravars = {};
        end
        %%%%%%%%%% end mctd_01 %%%%%%%%%%

        %%%%%%%%%% mctd_02 %%%%%%%%%%
    case 'mctd_02'
        switch oopt
            case 'rawedit_auto'
                crhelp_str = {'Edits to the raw (or raw_cleaned, if that file already exists) data'
                    'to be made in mctd_02 (calling apply_autoedits):'
                    'castopts.pumpsNaN.var1 = N gives the number of bad points N expected for variable var1'
                    '    after pumps come back on;'
                    'castopts.badscans.var1 = [S1_low S1_hi; ... SN_low SN_hi] gives 1 ... N ranges of scans'
                    '    over which to NaN variable var1 (inclusive);'
                    '    and/or you can specify in terms of times using'
                    'castopts.badtimes.var1 = [t1_low t1_hi; ...]; etc.'
                    'castopts.rangelim.var1 = [V1 V2] gives the range of acceptable values for variable var1;'
                    'castopts.despike.var1 = [T1 ... Tn] gives the successive thresholds T1 to Tn for '
                    '    applying median despiking to variable var1.'
                    'e.g.:'
                    'castopts.pumpsNaN.temp1 = 12; '
                    'castopts.pumpsNaN.cond1 = 12; '
                    'castopts.pumpsNaN.sbe_oxygen2 = 8*24'
                    'castopts.rangelim.press = [-10 8000];'
                    'castopts.despike.fluor = [0.3 0.2 0.2];'
                    'All default to not set (no action).'};
                if exist('castopts','var')
                    if isfield(castopts,'pumpsNaN'); castopts = rmfield(castopts,'pumpsNaN'); end
                    if isfield(castopts,'badscans'); castopts = rmfield(castopts,'badscans'); end
                    if isfield(castopts,'rangelim'); castopts = rmfield(castopts,'rangelim'); end
                    if isfield(castopts,'despike'); castopts = rmfield(castopts,'despike'); end
                end
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
                    '    set in scriptname = ''ctdpars''; oopt = ''oxyvars'').'
                    '  doturbV (default 0), if true, convert from turbidity volts to turbidity again (to correct for '
                    '    precision problem), using parameters set below. '
                    '  oxyrev and oxyhyst, containing the parameters to pass to mcoxyhyst_rev and mcoxyhyst'
                    '    defaults to SBE values, but any of the 3 parameters could be a vector based on d.press;'
                    '    to use different parameters for sensor 1 and sensor 2, use cell arrays'
                    '  turbVpars, the scale factor and offset to convert from turbidity volts to turbidity'
                    '    (defaults to [3.343e-3 6.600e-2])'};
                castopts.dooxyrev = 0;
                castopts.dooxyhyst = 1;
                castopts.doturbV = 0;
                if isfield(castopts,'oxyrev'); castopts = rmfield(castopts,'oxyrev'); end
                castopts.oxyrev.H1 = -0.033;
                castopts.oxyrev.H2 = 5000;
                castopts.oxyrev.H3 = 1450;
                if isfield(castopts,'oxyhyst'); castopts = rmfield(castopts,'oxyhyst'); end
                castopts.oxyhyst.H1 = -0.033;
                castopts.oxyhyst.H2 = 5000;
                castopts.oxyhyst.H3 = 1450;
                castopts.H_0 = [castopts.oxyhyst.H1 castopts.oxyhyst.H2 castopts.oxyhyst.H3]; %this line stores defaults for later reference; don't change!
                castopts.turbVpars = [3.343e-3 6.600e-2]; %from XMLCON for BBRTD-182, calibration date 6 Mar 17
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
        end
        %%%%%%%%%% end mctd_02 %%%%%%%%%%
        
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
            case '1hz_interp'
                crhelp_str = {'maxfill24 sets maximum gap time (seconds, default: 0) to be filled by linear'
                    'interpolation before averaging 24hz to 1hz; maxfill1 sets maximum gap time (seconds, default: 2)'
                    'to be filled by linear interpolation after averging to 1 hz.'};
                maxfill24 = 0;
                maxfill1 = 2;
        end
        %%%%%%%%%% end mctd_03 %%%%%%%%%%
        
        %%%%%%%%%% mdcs_01 %%%%%%%%%%
    case 'mdcs_01'
        switch oopt
            case 'kbot'
                crhelp_str = {'place to overwriteedit setde kbot, the index of the bottom of cast'
                    '(defaults to max(press))'};
        end
        %%%%%%%%%% end mdcs_01 %%%%%%%%%%
        
        %%%%%%%%%% mctd_04 %%%%%%%%%%
    case 'mctd_04'
        switch oopt
            case 'doloopedit'
                crhelp_str = {'flag doloopedit (default 0) determines whether to apply automatic loop editing'
                    'using m_loopedit, and scalar ptol (default 0.08) sets the size of pressure loops to '
                    'ignore/tolerate if so.'};
                doloopedit = 0;
                ptol = 0.08; %default is not to apply, but this would be the default value if you did
                spdtol = 0.24; %default value from SBE program
            case 'interp2db'
                crhelp_str = {'maxfill2db determines maximum length of gaps in 2 dbar averaged data'
                    'to fill by linear interpolation (in dbar; default 0 though pre-dy113 default was inf).'};
                maxfill2db = 0;
        end
        %%%%%%%%%% end mctd_04 %%%%%%%%%%
        
        %%%%%%%%%% mfir_01 %%%%%%%%%%
    case 'mfir_01'
        switch oopt
            case 'blinfile'
                blinfile = fullfile(root_botraw,sprintf('%s_%03d.bl', upper(mcruise), stnlocal));
            case 'nispos'
                crhelp_str = {'niskc gives the carousel positions and niskn the bottle numbers'
                    '(e.g. serial numbers, if known). length of both should = nnisk (set in castpars)'
                    'both default to [1:nnisk]''.'};
                niskc = [1:nnisk]';
                niskn = [1:nnisk]';
            case 'botflags'
                crhelp_str = {'Optional: edit niskin_flag, the vector of quality flags for Niskin bottle firing'
                    'for this station (use variable position to identify Niskins).'};
        end
        %%%%%%%%%% end mfir_01 %%%%%%%%%%
        
        %%%%%%%%%% mfir_03 %%%%%%%%%%
    case 'mfir_03'
        switch oopt
            case 'fir_fill'
                crhelp_str = {'firmethod and firopts determine how to get CTD data at Niskin firing times:'
                    'firmethod = ''medint'' to take median average over a scan interval around firing'
                    'scan set by firopts.int (e.g. default [-1 120] for just before to 5 s after); or'
                    'firmethod = ''linterp'' to linearly interpolate.'
                    'Additional fields of firopts set whether to fill gaps of any length (firopts.prefill = inf),'
                    'up to set length N (firopts.prefill = N; default 120), or not at all (firopts.prefill = 0)'
                    'by linear interpolation, before averaging or interpolating.'};
                firmethod = 'medint';
                clear firopts;
                firopts.int = [-1 120];
                firopts.prefill = 24*5; %fill gaps up to 5 s first
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
        
                        
    case 'mctd_addvars'
        switch oopt
            case 'newvars'
                crhelp_str = {'list of (SBE) names for variables newly added to varlists/ctd_renamelist.csv,'
                    'to be added to _raw and _raw_cleaned files'};
                newvars = {};
        end
        
                     %%%%%%%%%% best_station_depths %%%%%%%%%%
    case 'best_station_depths'
        switch oopt
            case 'depth_recalc'
                crhelp_str = {'recalcdepth_stns (default []) lists stations for which to recalculate depths '
                    'even if they already have values in station_depths mat-file'};
                recalcdepth_stns = [];
            case 'depth_source'
                crhelp_str = {'depth_source (default: {''ladcp'', ''ctd''}) determines preferred method(s), '
                    'in order, for finding station depths. Other option is ''file''; if this is set, must also'
                    'specify fnintxt, the name of the ascii (csv or two-column text) file of [stations, depths].'};
                depth_source = {'ladcp', 'ctd'}; %ladcp if present, then fill with ctd press+altimeter
            case 'bestdeps'
                crhelp_str = {'Place to edit those station depths that were not correctly filled in by '
                    'the chosen depmeth, either directly by editing bestdeps (a list of [station, depth]), '
                    'or by setting replacedeps, a list of [station, depth] only containing the pairs to edit.'
                    'Also can set stnmiss, a list of stations not to include in bestdeps list.'};
                replacedeps = [];
                stnmiss = [];
        end
        %%%%%%%%%% end best_station_depths %%%%%%%%%%
        
        
end
