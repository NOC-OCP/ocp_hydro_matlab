%cruise-specific options for sd025

switch opt1

    case 'setup'
        switch opt2
            case 'time_origin'
                MEXEC_G.MDEFAULT_DATA_TIME_ORIGIN = [2023 1 1 0 0 0];
        end

    case 'ship'
        switch opt2
            case 'rvdas_database'
                RVDAS.machine = 'sdl-rvdas-s1.sda.bas.ac.uk';
                %local(ly) mounted directory in this case (legwork)
                RVDAS.jsondir = '/local/users/pstar/mounts/public/data_management/documentation/json_sensor_files/';
                RVDAS.user = 'rvdas_ro';
                RVDAS.database = ['"' '20210321' '"'];
            case 'datasys_best'
                default_navstream = 'gnss_seapath_320_2';
                default_hedstream = 'heading_seapath_320_2';
        end

    case 'castpars'
        switch opt2
            case 'oxy_align'
                oxy_end = 1;
            case 'cast_groups'
                testcasts = [3 7 11:12]; %***dips too short to process?
                ticasts = [3 7 11:24 31:32 36 40 45:47 50 54 57 59 61 63 68 76 161:167]; %Ti frame
                racasts = [37 38 39 41 setdiff(48:65,ticasts)]; %for Radium
                shortcasts = [3 7 11 12 13 37 38 39 41 48 51:53 67]; %no altimeter bottom depth / no LADCP BT
            case 'nnisk'
                if ismember(stnlocal,[12 45 64 67 70 72:74 77 79 80 82 83 85:156 157:160 162:167])
                    nnisk = 0;
                elseif ismember(stnlocal,[13:21 23 42:44 46])
                    nnisk = 12;
                end
        end

    case 'mctd_01'
        switch opt2
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
        switch opt2
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
                elseif ismember(stnlocal,ticasts) && stnlocal>23
                    %sensor 2 is bad
                    castopts.badtemp2.temp2 = [-2 40; NaN NaN];
                    castopts.badtemp2.cond2 = [-2 40; NaN NaN];
                end
                if ismember(stnlocal,[31 42 43 64])
                    castopts.rangelim.cond1 = [27 34];
                    castopts.rangelim.cond2 = [27 34];
                end
                if ismember(stnlocal,[43 64]) %***still need hand editing
                    castopts.despike.press = [3 2 2];
                    castopts.despike.temp1 = [1 0.1];
                    castopts.despike.temp2 = [1 1 0.1 0.1];
                    castopts.despike.cond1 =[0.5 0.5 0.05 0.05];
                    castopts.despike.cond2 = [0.5 0.5 0.05 0.05];
                    castopts.despike.oxygen_sbe1 = [3 2 2 1 1];
                    castopts.despike.oxygen_sbe2 = [3 2 2 1 1];
                end
            case 'raw_corrs'
                if ismember(stnlocal,ticasts) && stnlocal>23
                    %recalculate oxygen2 using temp1 and cond1 
                    castopts.dooxy2V = 1; 
                    %and coefficients corresponding to oxygen sensor 2 from
                    %xmlcon (should parse from header in future***)
                    castopts.oxy2Vcoefs.Soc = 5.7890e-1;
                    castopts.oxy2Vcoefs.Voff = -0.5201;
                    castopts.oxy2Vcoefs.A = -4.1247e-3;
                    castopts.oxy2Vcoefs.B = 1.5900e-4;
                    castopts.oxy2Vcoefs.C = -2.8246e-6;
                    castopts.oxy2Vcoefs.D0 = 2.5826e+0;
                    castopts.oxy2Vcoefs.D1 = 1.92634e-4;
                    castopts.oxy2Vcoefs.D2 = -4.64803e-2;
                    castopts.oxy2Vcoefs.E = 3.6000e-2;
                    castopts.oxy2Vcoefs.Tau20 = 1.3200;
                end
        end

    case 'mfir_01'
        switch opt2
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
                %3 = leak (clear or confirmed after sampling), 4 = misfire, 7 = possible issue
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
                        niskin_flag(ismember(position,[2 11 14])) = 3 ;
                        % 5, 8, 10, 16 24 only leaking when top opened
                        niskin_flag(ismember(position,[5 8 10 16 17 18 24])) = 7 ; % bottle cop sheet says 'little dribble'
                        niskin_flag(position==21) = 4 ;
                    case 9
                        niskin_flag(ismember(position,[23])) = 3 ; %23: cable stuck in tap
                        niskin_flag(position==21) = 4 ;
                        niskin_flag(ismember(position, [2 8 16 18])) = 7 ;
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
                        niskin_flag(~ismember(position,[12 21])) = 3 ; % top valve open/no valve
                        niskin_flag(position==21) = 4 ;
                    case 28
                        niskin_flag(ismember(position,[2 8 16])) = 7 ; % from bottom
                    case 29
                        niskin_flag(ismember(position,[1 16 18 20 21 24])) = 7 ;
                        niskin_flag(position==2) = 7 ; % valve pushed in, 'dodgy'
                        niskin_flag(ismember(position,[4 5])) = 7 ; % screw loose
                    case 30
                        niskin_flag(position==2) = 9 ; % open
                        niskin_flag(position==18) = 7 ; % leaking when top valve released
                    case 32
                        niskin_flag(position==2) = 3 ;
                        niskin_flag(position==12) = 9 ; % top slightly open
                        niskin_flag(position==19) = 7 ; % avoid for particles, tap has an issue
                    case 33
                        niskin_flag(position==21) = 7 ; % at bottom
                    case 35
                        niskin_flag(ismember(position,[1 2])) = 7 ; % 'thin stream on opening'
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
                        niskin_flag(position==18) = 7 ; % 'slow leak'
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
                        niskin_flag(ismember(position,[2 4 8 10 16])) = 3 ; % open at top
                    case 48
                        niskin_flag(ismember(position,[18 22])) = 4 ; % did not fire
                    case 49
                        niskin_flag(ismember(position,[8 21])) = 7 ; % little leak at the bottom
                    case 50
                        niskin_flag(ismember(position,[6 8 10 24])) = 9 ; % empty/open/did not fire
                        niskin_flag(position==12) = 3 ; % not closed at top
                    case 51
                        niskin_flag(ismember(position,[8 21])) = 3 ;
                    case 53
                        niskin_flag(position==21) = 3 ;
                    case 54
                        niskin_flag(position==2) = 7 ; % seems to be open, not fully closed. cannot pressurise
                        niskin_flag(position==12) = 7 ; % could not pressurise
                        niskin_flag(position==14) = 7 ; % released pressure and leaking from bottom
                    case 55
                        niskin_flag(position==7) = 7 ; % once opened at top
                        niskin_flag(ismember(position,[21 24])) = 7 ; % small drip

                end
        end

    case 'check_sams'
        check_sal = 80; %start plotting sample readings from this station
        check_oxy = 1;
        check_sbe35 = 1;

    case 'sbe35'
        switch opt2
            case 'sbe35file'
                sbe35file = sprintf('%s_*_sbe35.asc', upper(mcruise));
                stnind = [7:9];
            case 'sbe35_flags'
                %get rid of some extra (bad) lines (based on inspection of
                %the files and in some cases comparison to .bl files)
                t(t.sampnum==100,:) = [];
                ii = find(t.sampnum==2504); t(ii(1),:) = [];
                ii = find(t.sampnum==2822); t(ii(1),:) = [];
                ii = find(t.sampnum==4101); t(ii(2),:) = [];
                ii = find(t.sampnum==4401); t(ii(1),:) = [];
                ii = find(t.sampnum==4801); t(ii(1),:) = [];
                ii = find(t.sampnum==5318); t(ii(2),:) = [];
        end

    case 'botoxy'
        switch opt2
            case 'oxy_files'
                ofiles = {'oxygen_calculation_newflasks_sd025.xlsx'};
                hcpat = {'Niskin';'Bottle'};
                chrows = 1:2;
                chunits = 3;
                sheets = 1:80;
            case 'oxy_parse'
                ii = find(strcmp('conc_o2',oxyvarmap(:,1)));
                oxyvarmap(ii,:) = []; %don't rename, recalculate
            case 'oxy_calc'
                ds_oxy.vol_blank = repmat(-0.0081,size(ds_oxy.sampnum));
                ds_oxy.vol_titre_std = repmat(0.4540,size(ds_oxy.sampnum));
                ds_oxy.vol_blank(ds_oxy.statnum>=28 | ds_oxy.statnum==26) = -0.0085;
                ds_oxy.vol_titre_std(ds_oxy.statnum>=28 | ds_oxy.statnum==26) = 0.4241;
                ds_oxy.vol_std = repmat(5,size(ds_oxy.sampnum));
                vol_reag_tot = 0.997*2;
            case 'oxy_flags'
                %tm-clean samples taken with too-stiff tube (?)
                ii = find(ismember(d.statnum,[32 40 47 54 61]));
                d.botoxya_flag(ii) = max(d.botoxya_flag(ii),4);
                d.botoxyb_flag(ii) = max(d.botoxyb_flag(ii),4);
                %duplicates where based on comparison with ctd profile we
                %think one is bad or questionable
                d.botoxya_flag(ismember(d.sampnum,[1504 6811])) = 4;
                d.botoxya_flag(ismember(d.sampnum,[1624 2913])) = 3;
                d.botoxya_per_l(d.botoxya_flag==4) = NaN;
                d.botoxyb_flag(ismember(d.sampnum,[1512])) = 3;
                d.botoxyb_per_l(d.botoxyb_flag==4) = NaN;
                %duplicates that differ but not clear which is better
                ii = find(abs(d.botoxya_per_l-d.botoxyb_per_l)>1 & d.botoxya_flag==2 & d.botoxyb_flag==2);
                d.botoxya_flag(ii) = max(d.botoxya_flag(ii),3);
                d.botoxyb_flag(ii) = max(d.botoxyb_flag(ii),3);
        end

    case 'botpsal'
        switch opt2
            case 'sal_parse'
                cellT = 21;
                ssw_k15 = 0.99986;
            case 'sal_calc'
                sal_off = [008 -3; 009 +1; ...
                    010 -2; 011 +1; 012 +0; 013 -0; ...
                    014 -4; 015 -3; 016 -2; 017 -2; 018 -3; 019 -2; 020 -2; ...
                    021 -1; 022 +1; ...
                    023 -5; 024 -1; ...
                    025 -6; 026 -3; 027 -6; ...
                    028 -4; 029 -4; 030 -1; ...
                    031 -2; 032 -2; 033 -2; 034 +0; ...
                    035 -2; 036 -0; ... 
                    037 -4; 038 -3; ... 
                    039 -6; 040 -6; ... 
                    041 -6; 042 -5; ... %missed standards numbers (no skipped standards/sheets)
                    047 -5; 048 -8; ... %very large spread on 48, but it's -8 for the next run too; flag all between 47 and 48?
                    049 -8; 050 -8; ... %flag these for temperature being too high?
                    99 NaN %just to make sure we don't interpolate across the two machines!
                    101 0; 102 -1; 103 0 %very large spread/excluded 2 from 101 and 1 from 103***
                    ];
                sal_off(:,1) = sal_off(:,1)+999e3;
                sal_off(:,2) = sal_off(:,2)*1e-5;
                sal_off_base = 'sampnum_list';
            case 'sal_flags'
                %all flags now based on stdev or number of readings,
                %calculated in msal_01, but display some before running
                %through checks: 
                s3 = 5e-5; s4 = 1e-4;
                a = [ds_sal.sample_1 ds_sal.sample_2 ds_sal.sample_3 ds_sal.sample_4];
                as = m_nanstd(a,2);
                disp('will be bad:')
                disp(ds_sal.sampnum(as>s4))
        end

    case 'best_station_depths'
        switch opt2
            case 'bestdeps'
                %second column is water depth (from ea640 or ctd operator
                %logsheet)
                replacedeps = [3 164; 4 164; 7 667; 8 959; ...
                    11 2641; 12 2640; ...
                    13 3025; 14 3021; ...
                    31 3473; 33 3459; 34 3460; ...
                    37 3179; 38 3178; ...
                    39 3049; 40 3049; 41 3048; ...
                    48 2729; 49 2730; ...
                    51 2562; 52 2562; 53 2563; ...
                    56 999; ...
                    64 2820; 65 2819; ...
                    77 440];
        end

    case 'batchactions'
        switch opt2
            case 'output_for_others'
                pdir = '~/mounts/public/scientific_work_areas/hydrography/casts/';
                n = 1; [s(n),~] = system(['rsync -au ~/cruise/data/ctd/ctd*24hz.nc ' pdir 'ctd_24hz/']);
                n = n+1; [s(n),~] = system(['rsync -au ~/cruise/data/ctd/ctd*2db.nc ' pdir 'ctd_2dbar/']);
                n = n+1; [s(n),~] = system(['rsync -au ~/cruise/data/ctd/sam_sd025_all.nc ' pdir]);
                n = n+1; [s(n),~] = system(['rsync -au ~/cruise/data/collected_files/station_summary* ' pdir]);
                n = n+1; [s(n),~] = system(['rsync -au ~/cruise/data/collected_files/740H* ' pdir]);
                if sum(s)>0; warning('some or all syncing failed'); end
        end

    case 'outputs'
        switch opt2
            case 'ladcp'
                if stnlocal>=85 && stnlocal<=88
                    cfg.stnstr = '085_088';
                elseif stnlocal>=89 && stnlocal<=156
                    cfg.stnstr = '089_156';
                end
            case 'exch'
                n0 = 95;
                n12 = 14;
                n24 = 167-1-n0-n12;
                expocode = '74JC20230131';
                sect_id = 'SR1b';
                submitter = 'OCPNOCYLF'; %group institution person
                common_headstr = {'#SHIP: RRS Sir David Attenborough';...
                    '#Cruise SD025; Polar Science Trials';...
                    '#Region: Eastern subpolar North Atlantic';...
                    ['#EXPOCODE: ' expocode];...
                    '#DATES: 20230131 - 20230320';...
                    '#Chief Scientist: S. Fielding (BAS), K. Hendry (BAS)';...
                    '#Supported by grants from the UK Natural Environment Research Council.'};
                if strcmp(in.type,'ctd')
                    headstring = {['CTD,' datestr(now,'yyyymmdd') submitter]};
                    headstring = [headstring; common_headstr;
                        {sprintf('#%d stations with 12-place rosette, %d stations with 24-place rosette, %d stations without bottles',n12,n24,n0);...
                        '#CTD: Who - Y. Firing; Status - uncalibrated.';...
                        %'#The CTD PRS; TMP; SAL; OXY data are all calibrated and good.';...
                        '# DEPTH_TYPE   : COR';...
                        %'# DEPTH_TYPE   : rosette depth from CTDPRS + LADCP or CTD altimeter range to bottom, or speed of sound corrected ship-mounted bathymetric echosounding'...
                        }];
                else
                    headstring = {['BOTTLE,' datestr(now,'yyyymmdd') submitter]};
                    headstring = [headstring; common_headstr;
                        {sprintf('#%d stations with 12-place rosette, %2d stations with 24-place rosette',n12,n24);...
                        '#CTD: Who - Y. Firing; Status - uncalibrated';...
                        '#Notes: Includes CTDSAL, CTDOXY, CTDTMP';...
                        %'#The CTD PRS; TMP; SAL; OXY data are all calibrated and good.';...
                        %'# DEPTH_TYPE   : rosette depth from CTDPRS + LADCP or CTD altimeter range to bottom'...
                        '#Salinity: Who - Y. Firing; Status - preliminary; SSW batch P165.';...
                        '#Oxygen: Who - I Seguro; Status - preliminary.';...
                        '#Nutrients: Who - M. Woodward; Status - not yet analysed';...
                        '#Carbon: Who - D. Pickup and X. Shi; Status - not yet analysed';...
                        '#Chlorophyll: Who - A. Belcher; Status - not yet analysed';...
                        '#POC, POM: Who - G. Dallolmo; Status - not yet analysed';...
                        }];
                end
                vars_rename = {'CTDTURB' 'CTDBETA650_124'}; %confirmed 650; probably 124? 
            case 'grid'
                switch section
                    case 'sr1b'
                        kstns = [2 5 6 8 9 10 14:21 23:25 27:30 32 35 42:46];
                        mgrid.zpressgrid = [0 5 25 50 75 100 175 250 375 500 625 750 875 1000 1250 1500 1750 2000 2250 2500 2750 3000 3250 3500 3750 4000 4250 4500 4750]';
                    case 'tm'
                        kstns = [32 36 40 47 50 54 57 59 63];
                        mgrid.zpressgrid = [0 5 25 50 75 100 175 250 375 500 625 750 875 1000 1250 1500 1750 2000 2250 2500 2750 3000 3250 3500]';
                    case 'picbox'
                    case 'picyo'
                    case 'profiles_only'
                        %kstns = [1:3 5:167]; %must specify because of skipped station (what about 26/77?)
                        kstns = [1 2 5 6 8:12 14:30 32:76 78:167];
                        %ctd_regridlist = {}; %already done
                end
        end

    case 'ladcp_proc'
        if contains(cfg.stnstr,'_')
            [dd,hd] = mloadq(fullfile(mgetdir('ctd'),sprintf('dcs_%s_%03d',mcruise,stnlocal)),'time_start time_end ');
            p.time_start_force = round(datevec((dd.time_start-120)/86400+datenum(hd.data_time_origin)));
            p.time_end_force = round(datevec((dd.time_end+120)/86400+datenum(hd.data_time_origin)));
        end

    case 'calibrations'
        switch opt2
            case 'ctd_cals'
                castopts.docal.temp = 0;
                castopts.docal.cond = 0;
                castopts.docal.oxygen = 0;

                % temperature sensors
                if ~ismember(stnlocal,ticasts) && stnlocal<=84%***
                    castopts.calstr.temp1.sd025 = 'dcal.temp1 = (d0.temp1 - (-0.0056847)) / 1.0001 ;' ; %2191
                    castopts.calstr.temp2.sd025 = 'dcal.temp2 = (d0.temp2 - 0.0074999) / 1.004 ;' ; %
                else
                    % ???
                end

                % conductivity sensors
                if ismember(stnlocal,ticasts)
                    castops.calstr.cond1.sd025 = 'dcal.cond1 = (d0.cond1 - (-0.30117)) / 1.0088 ;' ;
                    castops.calstr.cond2.sd025 = 'dcal.cond2 = (d0.cond2 - (-0.44008)) / 1.0128 ;' ;
                else
                    castops.calstr.cond1.sd025 = 'dcal.cond1 = (d0.cond1 - (-0.87593)) / 1.0261 ;' ;
                    castops.calstr.cond2.sd025 = 'dcal.cond2 = (d0.cond2 - (-0.77686)) / 1.0223 ;' ;
                end

                % oxygen sensors
                if ismember(stnlocal,[6 8 9:10 25:30 33:35 37:39 41:44 48 49 51:53 55 56:2:62 65 66 69 71 75 78 81 84])
                    castops.calstr.oxygen2.sd025 = 'dcal.oxygen2 = (d0.oxygen2 - 6.1865) / 0.80215 ;' ;
                end % sensor 2291
                if ismember(stnlocal,[1 2 5 6 8 9])
                    castops.calstr.oxygen1.sd025 = 'dcal.oxygen1 = (d0.oxygen1 - (-3.8767)) / 1.412 ;' ;
                end % sensor 242
                % skipped sensor 4244 for now
                if ismember(stnlocal,[13:24 31 32 36 40 46 47 50 54 57:2:63 68 76 161 167])
                    castops.calstr.oxygen2.sd025 = 'dcal.oxygen2 = (d0.oxygen2 - (-3.5495)) / 0.98412 ;' ;
                end % sensor 4250
                if ismember(stnlocal,[3 7 11 13:24 31 32 36 40 46 47 50 54 57:2:63 68 76 161 167])
                    castops.calstr.oxygen1.sd025 = 'dcal.oxygen1 = (d0.oxygen1 - (-0.10704)) / 0.95246 ;' ;
                end % sensor 4252
                if ismember(stnlocal,[10 25:30 33:35 37:39 41:44 48 49 51:53 55 56 58:2:62 65 66 69 71 75 78 81 84])
                    castops.calstr.oxygen1.sd025 = 'dcal.oxygen1 = (d0.oxygen1 - (-3.9425)) / 1.1566 ;' ;
                end % sensor 620, only for when it was in position 1


        end
end
