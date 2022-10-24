switch scriptname

    case 'castpars'
        switch oopt
            case 'nnisk'
                nnisk = 12;
            case 'oxy_align'
                if ismember(stnlocal,[2 3 5:8 11:13 17:18 25:26 33 37 40 41]) %add stations where CTD was not turned off before pumps switched off here
                    oxy_end = 1;
                end
            case 'shortcasts'
                shortcasts = 42;
        end

    case 'm_setup'
        switch oopt
            case 'setup_datatypes'
                use_ix_ladcp = 'query';
        end
        
    case 'ship'
        switch oopt
            case 'default_nav'
                MEXEC_G.default_hedstream = 'attsea'; %posmv was 4 degrees out most of the trip
        end

    case 'batchactions'
        switch oopt
            case 'output_for_others'
                syncfrom = '/local/users/pstar/jc238/mcruise/data/collected_files/';
                syncto = '/local/users/pstar/mounts/public/JC238/ctd_sam_uway_collected_files/';
                system(['rsync -au ' syncfrom ' ' syncto]);
        end

    case 'mctd_01'
        switch oopt
            case 'cnvfilename'
                if redoctm
                    cnvfile = sprintf('%s_CTD_%03d.cnv', upper(mcruise), stnlocal);
                else
                    cnvfile = sprintf('%s_CTD_%03d_align_ctm.cnv', upper(mcruise), stnlocal);
                end
            case 'ctdvars'
                ctdvars_add = {'ph','ph','number'};
        end

    case 'mctd_02'
        switch oopt
            case 'rawedit_auto'
                if stnlocal==3
                   castopts.badscans.transmittance = [0 inf]; %instrument went bad pretty much the whole cast
                elseif stnlocal==19
                    %needed cleaning
                    castopts.despike.cond1 = [0.2 0.1];
                    castopts.despike.cond2 = [0.2 0.1];
                elseif stnlocal==38
                    %caught a fish
                    castopts.badscans.temp1 = [135900 inf];
                    castopts.badscans.cond1 = [135900 inf];
                    castopts.badscans.oxygen_sbe1 = [135900 inf];
                end
            case 'raw_corrs'
                castopts.oxyhyst.H2 = {6000 6000};
                castopts.oxyhyst.H3 = {1800 2000};
            case 'ctd_cals'
                %calibration strings below for testing; not final; do not
                %apply to ctd files
                castopts.docal.temp = 1;
                castopts.docal.cond = 1;
                castopts.docal.oxygen = 1;

                castopts.calstr.temp1.jc238 = 'dcal.temp1 = d0.temp1 + interp1([-10 1000 3100],[0.7 0.9 -1.7]*1e-3,d0.press);';
                castopts.calstr.temp2.jc238 = 'dcal.temp2 = d0.temp2 - 2e-5*d0.statnum + interp1([-10 1300 3100],[1.5 1.4 0.2]*1e-3,d0.press) + 2e-4;';
                calms = 'from comparison with SBE35, stations 1-41,43-44 (all)';
                castopts.calstr.temp1.msg = calms;
                castopts.calstr.temp2.msg = calms;

                castopts.calstr.cond1.jc238 = 'dcal.cond1 = d0.cond1.*(1 - (5.5e-5*d0.statnum + interp1([-10 2300 3100],[-1 -1 4]*1e-4,d0.press))/35);';
                castopts.calstr.cond2.jc238 = 'dcal.cond2 = d0.cond2.*(1 - (5e-5*d0.statnum + interp1([-10 1300 3100],[1.5 -0.2 -0.3]*1e-3,d0.press))/35);';
                calms = 'from comparison with bottle salinity, stations 1-41,43 (all)';
                castopts.calstr.cond1.msg = calms;
                castopts.calstr.cond2.msg = calms;

                castopts.calstr.oxygen1.jc238 = 'dcal.oxygen1 = d0.oxygen1.*interp1([-10 600 3100],[1.04 1.04 1.06],d0.press) + interp1([1 32 36 40 44],[-2 0 2 -2 1],d0.statnum);';
                castopts.calstr.oxygen2.jc238 = 'dcal.oxygen2 = d0.oxygen2.*(1.025+1.2e-4*d0.statnum + interp1([-10 400 3100],[-0.9 -0.25 2.7]*1e-2,d0.press));';% + interp1([-10 2000 3100],[1 3.5 9],d0.press);';
                calms = 'from comparison with bottle oxygens, stations 3-9,11,13-41,43';
                castopts.calstr.oxygen1.msg = calms;
                castopts.calstr.oxygen2.msg = calms;

        end

    case 'mctd_03'
        switch oopt
            case 's_choice'
                s_choice = 2;
            case 'o_choice'
                o_choice = 2;
        end

    case 'mfir_01'
        switch oopt
            case 'blinfile'
                blinfile = fullfile(root_botraw,sprintf('%s_CTD_%03d.bl', upper(mcruise), stnlocal));
            case 'nispos'
                niskc = [1:2:23]';
                niskn = [6914:2:6936]'; %26000NNNN
                if stnlocal>41
                    niskn(1) = [6915]; %bottle 1 leaked, switched out
                end
            case 'botflags'
                %Niskin flags: 2 = good, 3 leaking, 4 misfire [wire did not
                %release], 7 unknown problem [for further investigation], 9 not sampled
                switch stnlocal
                    case 1
                        niskin_flag(position==1) = 3; %questionable tap and oxy looks bad so suspect leak
                    case 4
                        niskin_flag(position==9) = 4; %most likely misfire based on sample and botoxytemp (looks like it closed around 600)
                    case 17
                        niskin_flag(position==9) = 4; %misfire
                    case 23
                        niskin_flag(position==9) = 4; %misfire         
                    case 28
                        niskin_flag(position==12) = 9; %bottle fired but not attached 
                    case 30
                        %niskin_flag(position==3) = 7; %visual: possible
                        %leak but we might have opened the tap first.
                        %inspection of samples: looks fine, so revised to
                        %default good
                    case 41
                        niskin_flag(position==1) = 3; %definite leak
                    otherwise
                end
        end

    case 'best_station_depths'
        switch oopt
            case 'bestdeps'
                % only for stations where we can't use ctd+altimeter
                % replacedeps = [cast_number depth]
                replacedeps = [
                   1 1088
                   42 2989];
        end

    case 'station_summary'
        switch oopt
            case 'sum_varsams'
                snames = {'nsal' 'noxy' 'nnut_shore' 'nco2_shore'};
                sgrps = {{'botpsal'}
                    {'botoxy'}
                    {'silc'}
                    {'dic'}};
        end

    case 'mout_exch'
        switch oopt
            case 'woce_expo'
                expocode = '740H20220712';
                sect_id = 'Ellet Line -- OSNAP-East';
                submitter = 'OCPNOCYLF'; %group institution person
                common_headstr = {'#SHIP: RRS James Cook';...
                    '#Cruise JC238; OSNAP East (Rockall Trough to Iceland Basin)';...
                    '#Region: Eastern subpolar North Atlantic';...
                    ['#EXPOCODE: ' expocode];...
                    '#DATES: 20220712 - 20220801';...
                    '#Chief Scientist: B. Moat (NOC) and K. Burmeister (SAMS)';...
                    '#Supported by grants from the UK Natural Environment Research Council for the OSNAP (grant no. NE/K010875/1; NE/K010875/2; NE/T008938/1) and CLASS (grant no. NE/R015953/1) programs and from the EU Horizon 2020 program to iAtlantic (grant no. 210522255).'};
            case 'woce_ctd_headstr'
                headstring = {['CTD,' datestr(now,'yyyymmdd') submitter]};
                headstring = [headstring; common_headstr;
                    {'#44 stations with 12-place rosette';...
                    '#CTD: Who - Y. Firing; Status - final.';...
                    '#The CTD PRS; TMP; SAL; OXY data are all calibrated and good.';...
                    '# DEPTH_TYPE   : COR';...
                    %'# DEPTH_TYPE   : rosette depth from CTDPRS + LADCP or CTD altimeter range to bottom, or speed of sound corrected ship-mounted bathymetric echosounding'...
                    }];
            case 'woce_sam_headstr'
                headstring = {['BOTTLE,' datestr(now,'yyyymmdd') submitter]};
                headstring = [headstring; common_headstr;
                    {'#42 stations with 12-place rosette';...
                    '#CTD: Who - Y. Firing; Status - final';...
                    '#Notes: Includes CTDSAL, CTDOXY, CTDTMP';...
                    '#The CTD PRS; TMP; SAL; OXY data are all calibrated and good.';...
                    %'# DEPTH_TYPE   : rosette depth from CTDPRS + LADCP or CTD altimeter range to bottom'...
                    '#Salinity: Who - Y. Firing; Status - final; SSW batch P165.';...
                    '#Oxygen: Who - S. Beith; Status - final.';...
                    '#Nutrients: Who - C. Johnson and R. Tuerena; Status - not yet analysed';...
                    '#Carbon: Who - N. Allison; Status - not yet analysed';...
                    }];
            case 'woce_vars_exclude'
                vars_exclude_ctd = {'ph'}; %cal is no good in current version
                %rename CTDTURB to be more specific (so, the whole list should be in
                %cropt?)
                m = strcmp('CTDTURB',vars(:,1));
                if sum(m)
                    vars{m,1} = 'CTDBETA650_124';
                end
                m = strcmp('CTDTURB_FLAG_W',vars(:,1));
                if sum(m)
                    vars{m,1} = 'CTDBETA650_124_FLAG_W';
                end
                %use this space to calculate sigma0 (for sam file only)
                %if isfield(d,'upsal')
                %    d.upden = sw_pden(d.upsal,d.utemp,d.upress,0);
                %end
                %if isfield(d,'botpsal')
                %    d.pden = sw_pden(d.botpsal,d.utemp,d.upress,0);
                %end
                vars_exclude_sam = {'uph'};
        end

                %%%%%%%%%% mday_01_fcal %%%%%%%%%%
    case 'mday_01_fcal'
        switch oopt
            case 'uway_factory_cal'
                switch abbrev
                    case 'surfmet'
                         sensors_to_cal={'fluo';'trans';'parport';'tirport';'parstarboard';'tirstarboard'};
                         sensorcals={
                             'y=(x1-0.055)*16.3'; % fluorometer: s/n WS3S-246 cal 13 Jan 2022    
                             'y=(x1-0.058)/(4.707-0.058)*100' %transmissometer: s/n CST-112R cal 14 Mar 2021
                             'y=x1/1.059' % port PAR: s/n 28559 cal 23 Mar 2021
                             'y=x1/1.134' % port TIR: 994132 cal 6 Apr 2021
                             'y=x1/1.016' % stb PAR: s/n 28560 cal 23 Mar 2021
                             'y=x1/1.065'}; % stb TIR: 047463 cal 18 Aug 2021
%                         % the surfmet instrument box is outputting in V*1e-5 for PAR/TIR already
                         sensorunits={'ug/l';'percent';'W/m2';'W/m2';'W/m2';'W/m2'};
                end
        end
        %%%%%%%%%% end mday_01_fcal %%%%%%%%%%

    case 'mtsg_medav_clean_cal'
        switch oopt
            case 'tsg_edits'
                badtimes = [datenum(2022,7,1) datenum(2022,7,12,14,6,0)
                    datenum(2022,7,28,12,28,0) datenum(2022,7,28,17,20,0)];
                badtimes = (badtimes-datenum(MEXEC_G.MDEFAULT_DATA_TIME_ORIGIN))*86400;
                tsgedits.badtimes.conductivity_raw = badtimes;
                tsgedits.badtimes.salinity_raw = badtimes;
                tsgedits.badtimes.temph_raw = badtimes;

                %badtimes = [datenum(2022,7,27,12,30,0) datenum(2022,7,27,17,15,0)];
                %tsgedits.badtimes.conductivity_raw = badtimes;
                %tsgedits.badtimes.salinity_raw = badtimes;
                %tsgedits.badtimes.temph_raw = badtimes;
                
                %if day>=209
                %    tsgedits.despike.conductivity = [1 0.5];
                %end
            case 'tsgcals'
                tsgopts.docal.salinity = 1;
                load(fullfile(root_dir,'sdiffsm'))
                kbad = find(isnan(t+sdiffsm)); t(kbad) = []; sdiffsm(kbad) = [];
                tsgopts.calstr.salinity.jc238 = 'dcal.salinity_cal = dnew.salinity_raw + interp1([-1e10; t; 1e10],sdiffsm([1 1:end end]),d.time);';

        end

    case 'msal_01'
        switch oopt
            case 'sal_files'
                salfiles = dir(fullfile(root_sal, ['JC238*.csv']));
                salfiles = {salfiles.name};
                clear iopts; iopts.datetimeformat = 'dd/MM/uuuu'; %***for NMF files
            case 'sal_parse'
                cellT = 24;
                ssw_batch = 'P165';
                ssw_k15 = 0.99986;
            case 'sal_calc'
                sal_off = [
                    1 1
                    2 3
                    3 3 %3 is a repeat from same bottle as 2; using value from 2
                    4 2
                    5 0
                    6 2
                    7 2 %7 is a repeat from same bottle as 6; using value from 6
                    8 2
                    9 -1
                    10 2
                    11 2 %11 is a repeat from same bottle as 10; using value from 10
                    12 2
                    13 -3
                    14 1
                    15 3
                    16 0
                    17 2
                    18 1
                    19 0
                    20 1
                    21 1
                    22 -1
                    23 -2
                    24 3
                    25 -3
                    26 -1
                    27 -3
                    28 0
                    29 -2
                    30 -1
                    31 -3
                    32 -2
                    33 -3
                    34 -2
                    35 -1
                    36 -1];
                sal_off(:,1) = sal_off(:,1)+999000;
                sal_off(:,2) = sal_off(:,2)*1e-5;
                sal_adj_comment = ['Bottle salinities adjusted using SSW batch P165'];
        end

    case 'moxy_01'
        switch oopt
            case 'oxy_files'
                ofiles = {'Winkler_Calculation_Spreadsheet_JC238_2022.xlsx'};
                hcpat = {'CTD cast no.'};
                chrows = 1;
                chunits = [];
            case 'oxy_parse'
                oxyvarmap = {
                    'statnum',       'ctd_cast_no'
                    'position',      'niskin_bot_no'
                    'vol_blank',     'blank_titre_mls_calculated_under_blank_calculation_tab'
                    'vol_std',       'std_vol_mls'
                    'vol_titre_std', 'std_titre_mls'
                    'fix_temp',      'fixing_temp_c'
                    'sample_titre',  'sample_titre_mls'
                    'flag',          'flag'
                    'oxy_bottle'     'do_sample_bot_no'
                    'bot_vol_tfix'   'bot_vol_at_tfix_mls'
                    'conc_o2',       'c_o2_umol_per_l'};
            case 'oxy_flags'
                % a few more outliers (others flagged in input .xlsx file)
                d.botoxya_flag(ismember(d.sampnum,[1223 2301 2303 2815 2819 2901 3219])) = 4;
                % these stations are low compared to CTDs, throughout the
                % water column. not sure why (they weren't all analysed in
                % a row or with the same standard/blank different from
                % others), but it doesn't appear to be a function of
                % watermass 
                m = ismember(d.statnum,[7 9:13]);
                d.botoxya_flag(m) = max(3,d.botoxya_flag(m));
                d.botoxyb_flag(m) = max(3,d.botoxyb_flag(m));
                d.botoxyc_flag(m) = max(3,d.botoxyc_flag(m));
        end

        %%%%%%%%%% mfir_03 %%%%%%%%%%
    case 'mfir_03'
        switch oopt
            case 'fir_fill'
                firmethod = 'medint';
                firopts.int = [-1 120]; %average over 5 s to match .ros file used in BASproc
                firopts.prefill = 48;
        end
        %%%%%%%%%% end mfir_03 %%%%%%%%%%
        
                
        %%%%%%%%%% mctd_checkplots %%%%%%%%%%
    case 'mctd_checkplots'
        switch oopt
            case 'plot_saltype'
                saltype = 'asal';
        end
        %%%%%%%%%% end mctd_checkplots %%%%%%%%%%
                
                
        %%%%%%%%%% msec_grid %%%%%%%%%%
    case 'msec_grid'
        switch oopt
            case 'sections_to_grid'
	    sections = {'osnape' 'ungridded'};
            case 'sec_stns_grids'
                      zpressgrid = [0 5 25 50 75 100 175 250 375 500 625 750 875 1000 1250 1500 1750 2000 2250 2500 2750 3000]';  
                switch section
                    case 'osnape'
                      kstns = [5:8 4 10:25 27 26 28:32 35:39 43 40 41];
                    case 'ungridded'
                      kstns = [1:41 43];
                end
            case 'ctd_regridlist'
                ctd_regridlist = [ctd_regridlist 'fluor' 'ph'];
        end

    case 'msam_ashore_flag'
        switch oopt
            case 'shore_sam_types'
                samtypes = {'nut', 'co2'};
            case 'sam_ashore_nut'
                fnin = {fullfile(mgetdir('M_BOT_ISO'),'Nutrient_Tube_Numbers.xlsx')};
                varmap = {'statnum' 'CTDCastNo_' ' '
                    'position' 'NiskinBottleNo_' ' '
                    'silc_flag' 'No_OfNutrientSamples' 'num_samples'
                    'phos_flag' 'No_OfNutrientSamples' 'num_samples'
                    'totnit_flag' 'No_OfNutrientSamples' 'num_samples'};
                do_empty_vars = 1;
                fillstat = 1;
            case 'sam_ashore_co2'
                fnin = {fullfile(mgetdir('M_BOT_ISO'),'Carbon_Bottle_Names.xlsx')};
                varmap = {'statnum' 'CTDCastNo_' ' '
                    'position' 'NiskinBottleNo_' ' '
                    'dic_flag' 'CarbonSamplesNo_' 'num_samples'
                    'alk_flag' 'CarbonSamplesNo_' 'num_samples'};
                do_empty_vars = 1;
                fillstat = 1;
        end
        
    case 'sam_all_make'
        switch oopt
            case 'sam_all_restart_flag'
                sam_all_restart = {'sam','sbe35','sal','oxy','shore'};
                klist = [1:41 43:44];
        end
        
    case 'ix_cast_params'
        switch oopt
            case 'ladcpopts'
                if isfield(cfg,'pdir_root') && ~strcmp(cfg.pdir_root,'processed')
                    %SPIKES
                    % 	maximum value for abs(V-error) velocity
                    p.elim = 0.3;
                    % 	maximum value for horizontal velocity
                    % p=setdefv(p,'vlim',2.5);
                    % 	minimum value for %-good
                    p.pglim = 50;
                    %	maximum value for W difference between the mean W and actual
                    %        W(z) for each profile.
                    p.wlim = 0.10;
                    p.edit_spike_filter=0;
                    p.edit_spike_filter_max_curv=2;
                    
                end
        end
        
            case 'codas_to_mstar'
        switch oopt
            case 'codas_file'
                fnin = fullfile(root_vmadcp, 'spprocessing', 'JC238_merged', 'proc', [inst '.uvship'], 'contour', [inst '_merged_uvship.nc']);
        end
        
end
