switch scriptname

    case 'm_setup'
        switch oopt
            case 'time_origin'
                MEXEC_G.MDEFAULT_DATA_TIME_ORIGIN = [2023 1 1 0 0 0];
            case 'setup_datatypes'
                skipunderway = 0;
        end

    case 'castpars'
        switch oopt
            case 'oxy_align'
                oxy_end = 1;
            case 'cast_groups'
                testcasts = [3 4 7 11:12]; %***dips too short to process?
                ticasts = [3 4 7 11:24 31:32 36 40 45:47 50 54 57 59 61 63 68 76]; %Ti frame
                racasts = [37 38 39 41 setdiff(48:65,ticasts)]; %for Radium
                shortcasts = [3 4 7 11 12 13 37 38 39 41 48 51:53 67]; %no altimeter bottom depth / no LADCP BT
            case 'nnisk'
                if ismember(stnlocal,[12 45])
                    nnisk = 0;
                elseif ismember(stnlocal,[13:21 23 46])
                    nnisk = 12;
                end
            case 'ctdsens_groups'
                crhelp_str = {'ctdsens is a structure with fields corresponding to the CTD sensors e.g.'
                    'temp1, oxygen1, temp2, etc. (temp1 applies to both temp1 and cond1); '
                    'their values are 2xN cell arrays listing stations and corresponding sensor/serial number, '
                    'in case one or more sensors was changed during the cruise.'
                    'all default to [1:999] in the first row and 1 in the second (no change of sensors), '
                    'but, for example, you could set ctdsens.oxygen1 = [1:30; [ones(1,8) ones(2,22)];'
                    'if the CTD1 oxygen sensor was changed between stations 8 and 9.'};
                a = [1:999; ones(1,999)];
                ctdsens.temp1 = [[1 2 5 6 8 9]; 2191];
                ctdsens.oxygen1 = [[1 2 5 6 8 9]; 0242];
                ctdsens.temp2 = [[1 2 5 6 8 9]; 5649];
                ctdsens.oxygen2 = [[1 2 5]; 0620, [6 8 9]; 2291];
                ctdsens.fluor = a;
                ctdsens.transmittance = a;
        end

    case 'mctd_01'
        switch oopt
            case 'redoctm'
                redoctm = 1;
            case 'cnvfilename'
                if ismember(stnlocal,ticasts)
                    cnvfile = sprintf('%s_%03d_Ti.cnv',upper(mcruise),stnlocal);
                else
                    cnvfile = sprintf('%s_%03d_SS.cnv',upper(mcruise),stnlocal);
                end
                cnvfile = fullfile(mgetdir('M_CTD_CNV'),cnvfile);
            case 'ctdvars'
                ctdvars_add = {};
            case 'absentvars'
        end

    case 'mctd_02'
        switch oopt
            case 'rawedit_auto'
                if ismember(stnlocal,[10 31 42 43 44 48 49 51:53 55:56 58 64])
                    %large spikes: SS cable problem (10) and cable and/or SBE9 problem(s)
                    a = [-2 8000];
                    b = [-2 40; NaN NaN];
                    castopts.badpress.press = a;
                    castopts.badpress.temp1 = a;
                    castopts.badpress.temp2 = a;
                    castopts.badtemp1.temp1 = b; castopts.badtemp1.cond1 = b; castopts.badtemp1.oxygen_sbe1 = b;
                    castopts.badtemp2.temp2 = b; castopts.badtemp2.cond2 = b; castopts.badtemp2.oxygen_sbe2 = b;
                elseif ismember(stnlocal,ticasts) && stnlocal>=23
                    %sensor 2 is bad
                    castopts.badtemp2.temp2 = [-2 40; NaN NaN];
                    castopts.badtemp2.cond2 = [-2 40; NaN NaN];
                end
                if ismember(stnlocal,[31 42 43 64])
                    castopts.rangelim.cond1 = [27 34];
                    castopts.rangelim.cond2 = [27 34];
                end
                if ismember(stnlocal,[43 64])
                    castopts.despike.press = [3 2 2];
                    castopts.despike.temp1 = [1 0.1];
                    castopts.despike.temp2 = [1 1 0.1 0.1];
                    castopts.despike.cond1 =[0.5 0.5 0.05 0.05];
                    castopts.despike.cond2 = [0.5 0.5 0.05 0.05];
                    castopts.despike.oxygen_sbe1 = [3 2 2 1 1];
                    castopts.despike.oxygen_sbe2 = [3 2 2 1 1];
                    %castopts.despike.'transmittance' 0.3 0.2 0.2
                    %castopts.despike. 'fluor' 0.2 0.1 0.1
                    %castopts.despike. 'turbidityV' 0.05 0.05 0.05%***
                    %castopts.despike.'pressure_temp' 0.1 0.1 0.1
                end
        end

    case 'mfir_01'
        switch oopt
            case 'blinfile'
                blinfile = fullfile(root_botraw,sprintf('%s_%03d_',upper(mcruise),stnlocal));
                if ismember(stnlocal,ticasts)
                    blinfile = [blinfile 'Ti.bl'];
                else
                    blinfile = [blinfile 'SS.bl'];
                end
            case 'nispos'
                if nnisk == 12
                    niskc = [2:2:24]';
                    niskn = [2:2:24]';
                end
            case 'botflags'
                %3 = leak (confirmed after sampling), 4 = misfire, 7 = possible issue
                %(unclear, investigate further), 9 = no samples
                switch stnlocal
                    case 2 % CTD number
                        niskin_flag(ismember(position,[2 11 16])) = 4 ;
                        niskin_flag(ismember(position,[20 21 22 23 24])) = 3 ;
                    case 5
                        niskin_flag(ismember(position,[1 2 4 5 7 8 10 15 16 21 22 24])) = 3 ;
                        niskin_flag(position==1) = 4 ;
                    case 6
                        niskin_flag(ismember(position,[2 5 8 16 17])) = 3 ;
                        niskin_flag(position==21) = 4 ;
                    case 8
                        niskin_flag(ismember(position,[2 5 8 10 11 14 16 24])) = 3 ;
                        % 5, 8, 10, 16 24 only leaking when top opened
                        niskin_flag(ismember(position,[17 18])) = 7 ; % bottle cop sheet says 'little dribble'
                        niskin_flag(position==21) = 4 ;
                    case 9
                        niskin_flag(ismember(position,[2 8 16 18])) = 3 ;
                        niskin_flag(position==21) = 4 ;
                        niskin_flag(position==23) = 7 ; % cable stuck in tap
                    case 10
                        niskin_flag(position==2) = 7 ;
                    case 11
                        niskin_flag(position==3) = 7 ; % came off frame
                        niskin_flag(position==10) = 7 ; % gets stuck
                    case 15
                        niskin_flag(ismember(position,[2 6])) = 9;
                        niskin_flag(ismember(position,[12 20])) = 7; %possible leaks
                    case 16
                        niskin_flag(ismember(position,[2 6 8 16])) = 9; %did not close
                    case 17
                        niskin_flag(ismember(position,[2])) = 9; %did not close (presumably this is what leaking at top means)
                        niskin_flag(ismember(position,[6 16])) = 3;
                    case 18
                        niskin_flag(ismember(position,[6 8 18])) = 9;
                    case 19
                        niskin_flag(ismember(position,[8 18])) = 9;
                        niskin_flag(ismember(position,[10])) = 3;
                        niskin_flag(ismember(position,[24])) = 7; %fired on the fly?
                    case 20
                        niskin_flag(~ismember(position,[4 20 22 24])) = 9; % :(
                    case 21
                        niskin_flag(position==6) = 3; % log sheet says open from the bottom - assume that means its also leaking
                        niskin_flag(position==24) = 3 ;
                        niskin_flag(ismember(position,[12 16])) = 7 ; % top open
                    case 22
                        niskin_flag(position==2) = 4 ;
                        niskin_flag(position==6) = 3 ;
                        niskin_flag(position==16) = 7 ; % leaking at top. top open when exiting water
                    case 23
                        niskin_flag(ismember(position,[2 4 6 14])) = 3 ; % 2 and 6 fell off frame after exiting water
                        niskin_flag(position==12) = 7 ; % partially open at top
                    case 24
                        niskin_flag(ismember(position,[6 8 10 14 18 20 22 24])) = 4 ;
                    case 25
                        niskin_flag(ismember(position,[2 8 10])) = 3 ;
                        niskin_flag(ismember(position,[17 22 24])) = 7 ; % leaking once open
                        niskin_flag(position==21) = 4 ;
                    case 26
                        niskin_flag(ismember(position,[2 8 16 17 23 24])) = 3 ; % wire caught in 23
                        niskin_flag(position==21) = 4 ;
                    case 27
                        niskin_flag(~ismember(position,[12 21])) = 7 ; % top valve open/no valve
                        niskin_flag(position==21) = 4 ;
                    case 28
                        niskin_flag(ismember(position,[2 8 16])) = 3 ; % from bottom
                    case 29
                        niskin_flag(ismember(position,[1 16 18 20 21 24])) = 3 ;
                        niskin_flag(position==2) = 7 ; % valve pushed in, 'dodgy'
                        niskin_flag(ismember(position,[4 5])) = 7 ; % screw loose
                    case 30
                        niskin_flag(position==2) = 9 ; % open
                        niskin_flag(position==18) = 3 ; % leaking when top valve released
                    case 32
                        niskin_flag(position==2) = 3 ;
                        niskin_flag(position==12) = 9 ; % top slightly open
                        niskin_flag(position==19) = 7 ; % avoid for particles, tap has an issue
                    case 33
                        niskin_flag(position==21) = 3 ; % at bottom
                    case 35
                        niskin_flag(ismember(position,[1 2])) = 3 ; % 'thin stream on opening'
                        niskin_flag(position==21) = 3 ; %'bottom seepage'
                    case 36
                        niskin_flag(ismember(position,[6 8])) = 3 ;
                        niskin_flag(ismember(position,[10 20 22])) = 9 ; % open
                    case 37
                        niskin_flag(ismember(position,[8 21])) = 3 ;
                    case 38
                        niskin_flag(ismember(position,[18 21])) = 3 ;
                    case 39
                        niskin_flag(position==13) = 3 ; % 'total leak'
                        niskin_flag(position==18) = 3 ; % 'slow leak'
                    case 40
                        niskin_flag(ismember(position,[2 14])) = 3 ;
                        niskin_flag(ismember(position,[8 10 24])) = 9 ; % open/empty
                    case 41
                        niskin_flag(ismember(position,[5 18])) = 3 ; % 'leaking on release'
                        niskin_flag(position==21) = 3 ;
                    case 44
                        niskin_flag(ismember(position,[18 23])) = 3 ;  % O-ring?
                    case 46
                        niskin_flag(ismember(position,[18 22])) = 3 ; % open at bottom
                        niskin_flag(ismember(position,[2 4 8 10 16])) = 7 ; % open at top
                    case 48
                        niskin_flag(ismember(position,[18 22])) = 4 ; % did not fire
                    case 49
                        niskin_flag(ismember(position,[8 21])) = 3 ; % little leak at the bottom
                    case 50
                        niskin_flag(ismember(position,[6 8 10 24])) = 9 ; % empty/open/did not fire
                        niskin_flag(position==12) = 7 ; % not closed at top
                    case 51
                        niskin_flag(ismember(position,[8 21])) = 3 ;
                    case 53
                        niskin_flag(position==21) = 3 ;
                    case 54
                        niskin_flag(position==2) = 7 ; % seems to be open, not fully closed. cannot pressurise
                        niskin_flag(position==12) = 7 ; % could not pressurise
                        niskin_flag(position==14) = 7 ; % released pressure and leaking from bottom
                    case 55
                        niskin_flag(position==7) = 3 ; % once opened at top
                        niskin_flag(ismember(position,[21 24])) = 3 ; % small drip

                end
        end

    case 'msbe35_01'
        switch oopt
            case 'sbe35file'
                sbe35file = sprintf('%s_*_sbe35.asc', upper(mcruise));
                stnind = [7:9];
            case 'sbe35flags'
                %get rid of some extra lines (based on inspection of the
                %files and in some cases comparison to .bl files)
                t(t.sampnum==100,:) = [];
                ii = find(t.sampnum==2504); t(ii(1),:) = [];
                ii = find(t.sampnum==2822); t(ii(1),:) = [];
                ii = find(t.sampnum==4101); t(ii(2),:) = [];
                ii = find(t.sampnum==4401); t(ii(1),:) = [];
                ii = find(t.sampnum==4801); t(ii(1),:) = [];
                ii = find(t.sampnum==5318); t(ii(2),:) = [];
                sbe35_check = 1;
        end

    case 'moxy_01'
        switch oopt
            case 'oxy_files'
                ofiles = {'oxygen_calculation_newflasks_sd025.xlsx'};
                hcpat = {'Niskin';'Bottle'};
                chrows = 1:2;
                chunits = 3;
                sheets = 1:50;
            case 'oxy_parse'
                oxyvarmap = {
                    'statnum',       'cast_number'
                    'position',      'niskin_bottle'
                    'vol_blank',     'blank_titre'
                    'vol_std',       'std_vol'
                    'vol_titre_std', 'standard_titre'
                    'fix_temp',      'fixing_temp'
                    'sample_titre',  'sample_titre'
                    'flag',          'flag'
                    'oxy_bottle'     'bottle_no'
                    'date_titre',    'dnum'
                    'bot_vol_tfix'   'botvol_at_tfix'};
                %'conc_o2',       'c_o2_'}; %don't rename, recalculate
                fillstat = 1;
            case 'oxy_calc'
                %cal_temp = 25;
                ds_oxy.vol_blank = repmat(-0.0081,size(ds_oxy.sampnum));
                ds_oxy.vol_titre_std = repmat(0.4540,size(ds_oxy.sampnum));
                ds_oxy.vol_blank(ds_oxy.statnum>=28 | ds_oxy.statnum==26) = -0.0085;
                ds_oxy.vol_titre_std(ds_oxy.statnum>=28 | ds_oxy.statnum==26) = 0.4241;
                ds_oxy.vol_std = repmat(5,size(ds_oxy.sampnum));
                vol_reag_tot = 0.997*2;
            case 'oxy_flags'
                %clean samples with too-stiff tube
                ii = find(ismember(d.statnum,[32 40 47 54 61]));
                d.botoxya_flag(ii) = max(d.botoxya_flag(ii),4);
                d.botoxyb_flag(ii) = max(d.botoxyb_flag(ii),4);
                %d.botoxyc_flag(ii) = max(d.botoxyc_flag(ii),4); %there are
                %none
                %differing replicates (also compare to ctd to see if one
                %stands out as good and one bad, before chosing final
                %flags)
                ii = find(abs(d.botoxya_per_l-d.botoxyb_per_l)>1);
                d.botoxya_flag(ii) = max(d.botoxya_flag(ii),3);
                d.botoxyb_flag(ii) = max(d.botoxyb_flag(ii),3);
        end

        %1924 psal, 1918, 1920, 1922 bottle
    case 'msal_01'
        switch oopt
            case 'sal_parse'
                cellT = 21;
                ssw_k15 = 0.99986;
            case 'sal_calc'
                sal_off = [008 -3
                    009 +1
                    010 -2
                    011 +0
                    012 +0
                    013 -0
                    014 -5
                    015 -2
                    016 -2
                    017 -2
                    018 NaN
                    019 -2
                    020 -2
                    021 -1
                    022 +1
                    023 -5
                    024 -1
                    025 -6
                    026 -2
                    027 -6
                    028 -4
                    029 -4
                    030 -1
                    031 -1
                    032 NaN
                    033 -2
                    034 +0
                    035 -2 % very large spread
                    036 -0
                    50 NaN %make sure we don't interpolate across these!
                    101 0 %very large spread
                    102 -1
                    103 0 %very large spread
                    ];
                sal_off(:,1) = sal_off(:,1)+999e3;
                sal_off(:,2) = sal_off(:,2)*1e-5;
                sal_off_base = 'sampnum_list';
            case 'sal_sample_inspect'
                plotss = 1;
            case 'sal_flags'
                ds_sal.flag(ismember(ds_sal.sampnum,[817 912 913 1708 1720 ...
                    1902 2104 2110 2220 2404 3016 3018 3019 3020 3204 3509 3601 ...
                    3619 4707 4016])) = 3;
                ds_sal.flag(ismember(ds_sal.sampnum,[820 901 918 1620 2910 ...
                    2920 3017 3021 3210 4712 4715])) = 4;
        end

    case 'best_station_depths'
        switch oopt
            case 'bestdeps'
                %second column is water depth (from ea640 or ctd operator
                %logsheet)
                replacedeps = [3 164
                    4 164
                    7 667
                    8 959
                    11 2641
                    12 2640
                    13 3025
                    14 3021
                    %15 3865
                    31 3473
                    33 3459
                    34 3460
                    37 3179
                    38 3178
                    39 3049
                    40 3049
                    41 3048
                    48 2729
                    49 2730
                    51 2562
                    52 2562
                    53 2563
                    56 999
                    64 2820
                    65 2819
                    77 440];
        end

    case 'batchactions'
        switch oopt
            case 'output_for_others'
                pdir = '~/mounts/public/scientific_work_areas/physics/processed_data_hydro/';
                n = 1; [s(n),~] = system(['rsync -au ~/cruise/data/ctd/ctd*24hz.nc ' pdir 'ctd_24hz/']);
                n = n+1; [s(n),~] = system(['rsync -au ~/cruise/data/ctd/ctd*2db.nc ' pdir 'ctd_2dbar/']);
                n = n+1; [s(n),~] = system(['rsync -au ~/cruise/data/ctd/sam_sd025_all.nc ' pdir]);
                n = n+1; [s(n),~] = system(['rsync -au ~/cruise/data/collected_files/ ' pdir '/collected_files/']);
                if sum(s)>0; warning('some or all syncing failed'); end
        end

    case 'mout_exch'
        switch oopt
            case 'woce_expo'
                expocode = '74JC20230131';
                sect_id = 'SR1b';
                submitter = 'OCPNOCYLF'; %group institution person
                common_headstr = {'#SHIP: RRS Sir David Attenboroug';...
                    '#Cruise SD025; Polar Science Trials';...
                    '#Region: Eastern subpolar North Atlantic';...
                    ['#EXPOCODE: ' expocode];...
                    '#DATES: 20230131 - 20230320';...
                    '#Chief Scientist: S. Fielding (BAS)';...
                    '#Supported by grants from the UK Natural Environment Research Council.'};
            case 'woce_ctd_headstr'
                headstring = {['CTD,' datestr(now,'yyyymmdd') submitter]};
                headstring = [headstring; common_headstr;
                    {'#NN stations with 12-place rosette, NN stations with 12-place Ti rosette, NN stations with 24-place Ti rosette';...
                    '#CTD: Who - Y. Firing; Status - uncalibrated.';...
                    %'#The CTD PRS; TMP; SAL; OXY data are all calibrated and good.';...
                    '# DEPTH_TYPE   : COR';...
                    %'# DEPTH_TYPE   : rosette depth from CTDPRS + LADCP or CTD altimeter range to bottom, or speed of sound corrected ship-mounted bathymetric echosounding'...
                    }];
            case 'woce_sam_headstr'
                headstring = {['BOTTLE,' datestr(now,'yyyymmdd') submitter]};
                headstring = [headstring; common_headstr;
                    {'#NN stations with 12-place rosette';...
                    '#CTD: Who - Y. Firing; Status - uncalibrated';...
                    '#Notes: Includes CTDSAL, CTDOXY, CTDTMP';...
                    %'#The CTD PRS; TMP; SAL; OXY data are all calibrated and good.';...
                    %'# DEPTH_TYPE   : rosette depth from CTDPRS + LADCP or CTD altimeter range to bottom'...
                    '#Salinity: Who - Y. Firing; Status - preliminary; SSW batch P165.';...
                    '#Oxygen: Who - I Seguro Requejo; Status - preliminary.';...
                    '#Nutrients: Who - M. Woodward; Status - not yet analysed';...
                    '#Carbon: Who - D. Pickup and X. Shi; Status - not yet analysed';...
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

    case 'msec_grid'
        switch oopt
            case 'sections_to_grid'
                sections = {'sr1b' 'tm' 'picyo'};
            case 'sec_stns_grids'
                switch section
                    case 'sr1b'
                        kstns = [2 5 6 8 9 10 14:21 23:25 27:30 32 35 42:46];
                        zpressgrid = [0 5 25 50 75 100 175 250 375 500 625 750 875 1000 1250 1500 1750 2000 2250 2500 2750 3000 3250 3500 3750 4000 4250 4500 4750]';
                    case 'tm'
                        kstns = [32 36 40 47 50 54 57 59 63];
                        zpressgrid = [0 5 25 50 75 100 175 250 375 500 625 750 875 1000 1250 1500 1750 2000 2250 2500 2750 3000 3250 3500]';
                    case 'picbox'
                    case 'picyo'
                end
            case 'sam_gridlist'
                sam_gridlist = {'botoxy'};
        end

    case 'ladcp'
        switch oopt
            case 'ladcp_castpars'
                if stnlocal>=85 && stnlocal<=88
                    cfg.stnstr = '085_088';
                elseif stnlocal>=89 && stnlocal<=156
                    cfg.stnstr = '089_156';
                end
                if contains(cfg.stnstr,'_')
                    [dd,hd] = mloadq(fullfile(mgetdir('ctd'),sprintf('dcs_%s_%03d',mcruise,stnlocal)),'time_start time_end ');
                    p.time_start_force = round(datevec((dd.time_start-120)/86400+datenum(hd.data_time_origin)));
                    p.time_end_force = round(datevec((dd.time_end+120)/86400+datenum(hd.data_time_origin)));
                end
        end

end
