%code that applies to multiple scripts
repeat_casts = [%Ra (or other) ctd, sr1b main section full-depth ctd
    %11 01;
    01 11;
    02 10;
    24 25;
    28 27; 29 27; 30 27;
    33 32; 34 32; 35 32;
    37 36; 38 36; 39 36;
    41 40; 42 40; 43 40;
    45 22; 46 22; 47 22; 48 22;
    49 20; 50 20; 51 20; 52 20; 53 20; 54 20;
    55 18; 56 18;
    57 15; 58 15;
    59 12; 60 12; 61 12;
    62 10; 63 10; 64 10;
    65 08; 66 08; 67 08;
    68 05; 69 05; 70 05;
    71 04];

switch scriptname
    
    %%%%%%%%%% mctd_01 %%%%%%%%%%
    case 'mctd_01'
        switch oopt
            case 'redoctm'
                if ismember(stnlocal, [15])
                    redoctm = 1;
                end
        end
        %%%%%%%%%% end mctd_01 %%%%%%%%%%
        
        %%%%%%%%%% mctd_02a %%%%%%%%%%
    case 'mctd_02a'
        switch oopt
            case 'prectm_rawedit'
                revars = {'press' -3 8000 %range edit
                    'temp1' -3 10
                    'temp2' -3 10
                    'cond1' 25 60
                    'cond2' 25 60
                    'transmittance' 50 101
                    'oxygen_sbe1' 0 500
                    'fluor' 0 1
                    };
                dsvars = {'press' 3 2 2 %despike
                    };
                ovars = {'oxygen_sbe1'};
        end
        %%%%%%%%%% end mctd_02a %%%%%%%%%%
        
        %%%%%%%%%% mctd_rawedit %%%%%%%%%%
    case 'mctd_rawedit'
        switch oopt
            case 'rawedit_auto'
                if ismember(stnlocal, [29 36 39 40:43])
                    revars = {'press' -1.495 8000 %range edit
                        'temp1' -3 10
                        'temp2' -3 10
                        'cond1' 25 60
                        'cond2' 25 60
                        'transmittance' 50 110
                        'oxygen_sbe1' 0 500
                        'fluor' 0 1
                        };
                end
        end
        %%%%%%%%%% end mctd_rawedit %%%%%%%%%%
        
        %%%%%%%%%% mctd_03 %%%%%%%%%%
    case 'mctd_03'
        switch oopt
            case 's_choice' %this applies to both t and c
                s_choice = 2; %need to use sensor 2 for 36:39, but also, oxygen was plumbed into ctd2
        end
        %%%%%%%%%% end mctd_03 %%%%%%%%%%
        
        %%%%%%%%%% mctd_04 %%%%%%%%%%
    case 'mctd_04'
        switch oopt
            case 'doloopedit'
                doloopedit = 1;
            case 'interp_2db' %this applies to both t and c
                interp_2db = 0; %reprocess as on dy113
        end
        %%%%%%%%%% end mctd_04 %%%%%%%%%%
        
        %%%%%%%%%% mbot_00 %%%%%%%%%%
    case 'mbot_00' %information about niskin bottle numbers
        switch oopt
            case 'nispos'
                %numbers of the niskins in order of 1 to 24
                nis_spare = 25; nis_12 = 26;
                %original niskin 19 lost on cast 23, replaced with spare
                if stnlocal>=24 & stnlocal<=44; nis = [nis(1:18) nis_spare nis(20:24)]; end
                %spare doesn't close due to frame, replaced with 12 L
                if stnlocal>=45; nis = [nis(1:18) nis_12 nis(20:24)]; end
        end
        %%%%%%%%%% end mbot_00 %%%%%%%%%%
        
        %%%%%%%%%% mfir_01 %%%%%%%%%%
        %transferred from mbot_01, and flag numbers updated to correctly
        %map to WOCE 3 = leaking, 4 = did not trip correctly, 9 = samples
        %not drawn, 20220624
    case 'mfir_01'
        switch oopt
            case 'botflags'
                %[station niskin]
                flag3 = [1 4; 3 9; 5 24; 5 16; 5 21; 5 24; 7 7; 8 21;
                    9 22; 11 24; 12 10; 12 22; 13 2; 13 21; 15 1; 15 11; 15 15; 15 23; 15 24;
                    16 1; 18 12; 18 21; 20 7; 20 11; 20 15;
                    22 17; 25 7; 25 11; 25 12; 25 21; 25 24; 26 21; 26 12; 26 7;
                    27 12; 27 23; 32 12; 32 21; 32 24; 34 7; 35 7;
                    41 24; 50 15; 45 16; 45 21; 45 24;
                    57 5; 58 24; 58 7]; % possibly leaking or questionable based on visual
                flag3 = [flag3; 1 1; 5 9; 9 7; 13 2; 15 15; 27 15; 31 09; 32 07]; %possibly bad (leaking) bottle based on analysed S,O,nuts,carbon
                flag3 = [flag3; 17 4]; %possibly bad (leaking) bottle based on analysed cfcs
                flag4 = [2 8; 3 8; 3 10; 4 12; 4 14; 4 15; 4 17; 5 7; 5 11; 5 12; 5 14; 5 15; 5 17; 8 13;
                    10 8; 10 10; 11 08; 11 21; 14 21; 14 24; 15 7; 15 12; 15 21; 16 7; 16 11; 16 12; 16 24;
                    17 7; 17 12; 17 21; 17 24; 18 10; 19 11; 19 12; 20 12; 20 22; 21 12; 21 21; 21 24;
                    22 12; 22 24; 23 12; 23 21; 23 24; 25 19; 26 24; 27 24; 31 7; 31 21; 32 24; 33 7; 33 12;
                    36 10; 36 12; 36 19; 36 24; 37 7; 37 10; 37 19; 40 10; 40 19; 40 21; 40 24; 41 9; 41 19;
                    44 7; 44 10; 44 12; 44 19; 44 21; 44 24; 45 15; 47 7]; % empty or end caps clearly not seated or bad based on sample values: revise some or all to 3? or 9?
                flag4 = [flag4; 9 7]; %bad bottle based on analysed S,O,nuts,co2: revise to 3?
                flag4 = [13 24; 33 10; 33 19; 33 24; 34 10; 34 19; 34 24; 35 10; 35 19; 35 24; 36 24;
                    38 10; 38 19; 39 10; 39 19; 39 24; 57 10; 58 8]; %did not fire (line not released), revised from 9 20220624
                flag9 = [flag9; 23 19]; % broken (lost) bottle, no samples
                niskin_flag(flag3(:,1)==stnlocal & ismember(position,flag3(:,2))) = 3;
                niskin_flag(flag4(:,1)==stnlocal & ismember(position,flag4(:,2))) = 4;
                niskin_flag(flag9(:,1)==stnlocal & ismember(position,flag9(:,2))) = 9;
                iif = find(flag3(:,1)==stnlocal); if ~isempty(iif); niskin_flag(ismember(position,flag3(iif,2))) = 3; end
                iif = find(flag4(:,1)==stnlocal); if ~isempty(iif); niskin_flag(ismember(position,flag4(iif,2))) = 4; end
                iif = find(flag9(:,1)==stnlocal); if ~isempty(iif); niskin_flag(ismember(position,flag9(iif,2))) = 9; end
        end
        %%%%%%%%%% end mfir_01 %%%%%%%%%%
        
        %%%%%%%%%% mfir_03 %%%%%%%%%%
    case 'mfir_03'
        switch oopt
            case 'fir_fill'
                avi_opt = [0 121/24]-1/24; %average just like in sbe .ros file (reprocess as on dy113)
        end
        %%%%%%%%%% end mfir_03 %%%%%%%%%%
        
        
        %%%%%%%%%% populate_station_depths %%%%%%%%%%
    case 'populate_station_depths'
        switch oopt
            case 'depth_source'
                depth_source = {'ladcp' 'ctd'}; %get from LADCP data
            case 'bestdeps'
                bestdeps(bestdeps(:,1)==11,2) = 4789;
                bestdeps(repeat_casts(:,1),2) = bestdeps(repeat_casts(:,2),2);
        end
        %%%%%%%%%% end populate_station_depths %%%%%%%%%%
        
        %%%%%%%%%% msal_01 %%%%%%%%%%
    case 'msal_01'
        switch oopt
            case 'salfile'
                sal_mat_file = ['sal_' mcruise '_01.mat'];
            case 'salflags'
                if ismember(stnlocal, [14])
                    flag(:) = 3; %all offset the same amount after cal applied, think standardisation might be off
                end
        end
        %%%%%%%%%% end msal_01 %%%%%%%%%%
        
        %%%%%%%%%% msal_standardise_avg %%%%%%%%%%
    case 'msal_standardise_avg'
        switch oopt
            case 'salcsv'
                d = dir(fullfile(root_sal, 'JR18002_sal*.csv'));
                d = struct2cell(d); sal_csv_files = d(1,:)';
            case 'check_sal_runs'
                check_sal_runs = 0;
                calc_offset = 1;
                plot_all_stations = 0;
            case 'k15'
                sswb = 160; %ssw batch
                msal_ssw
                ds_sal.K15 = zeros(size(ds_sal.sampnum));
                ds_sal.K15(iistd) = ssw_batches(ssw_batches(:,1)==sswb,2)/2;
            case 'cellT'
                ds_sal.cellT = 24+zeros(length(ds_sal.sampnum),1);
            case 'std2use'
                std2use([2 13 44],1) = 0;
                std2use([34 45],2) = 0;
                std2use([4 23 33],3) = 0;
                std2use(16:17,:) = 0;
                %qstd = [999001 999001.5];
                %[c,ia,ib] = intersect(ds_sal.sampnum,qstd);
                %std2use(ia,:) = 0;
            case 'fillstd'
                %xoff =
            case 'sam2use'
                sam2use([2,7,9,10,36,38,82,92,94,119,196,219,364,385,519,525,542,549],1) = 0;
                sam2use([25,78,88,296,436],2) = 0;
                sam2use([6,8,368,513,368,540,592,629],3) = 0;
                qsam = [317200000];
                [c,ia,ib] = intersect(ds_sal.sampnum(iisam),qsam); salbotqf(ia) = 3;
                %actually it's the standard that is questionable below, but we don't have another one to use
                ia = find(ds_sal.station_day==18 | ds_sal.station_day==12); salbotqf(ia) = 3;
            case 'fillstd'
                %***missing standards?
        end
        %%%%%%%%%% msal_standardise_avg %%%%%%%%%%
        
        %%%%%%%%%% moxy_01 %%%%%%%%%%
    case 'moxy_01'
        switch oopt
            case 'oxycsv'
                infile = fullfile(root_oxy, ['Cast_' stn_string '.csv']);
            case 'oxysampnum'
                ds_oxy.statnum = ds_oxy.Cast;
                ds_oxy.niskin = ds_oxy.Niskin;
                ds_oxy.sampnum = ds_oxy.statnum*100+ds_oxy.niskin;
                ds_oxy.oxy_bot = ds_oxy.Bottle;
                ds_oxy.bot_vol = ds_oxy.Bottle_vol0x2E;%Vol_;
                ds_oxy.vol_blank = ds_oxy.Blank;
                ds_oxy.vol_std = ds_oxy.Std;
                ds_oxy.vol_titre_std = ds_oxy.Standard;
                ds_oxy.oxy_temp = ds_oxy.Fixing_temp0x2E;%Temp_;
                ds_oxy.oxy_titre = ds_oxy.Sample;
                ds_oxy.mol_std = ds_oxy.Iodate_M;
                ds_oxy.nO2 = ds_oxy.n0x28O20x29;%_O2_;
                ds_oxy.conc_O2 = ds_oxy.C0x28O20x29;%_O2_;
            case 'oxyflags'
                if statnum==19; ds_oxy.flag(ds_oxy.flag==2) = 3; end
        end
        %%%%%%%%%% end moxy_01 %%%%%%%%%%
        
        %%%%%%%%%% moxy_ccalc %%%%%%%%%%
    case 'moxy_ccalc'
        switch oopt
            case 'oxypars'
                vol_reag1 = 1.0067;%mean([1.00 1.00 1.00]); %*** 0.999?
                vol_reag2 = 1.033;%mean([1.00 1.00 1.00]); %***
            case 'blstd'
                vol_std = ds_oxy.vol_std;
                %vol_titre_std = ds_oxy.vol_titre_std;
                %vol_blank = ds_oxy.vol_blank;
                if stnlocal<=23; vol_titre_std = 0.46323; else; vol_titre_std = 0.46392; end
                vol_blank = [1 0.00758; 2 0.00958; 3 0.00350; 4 0.00550; 5 0.00308; 6 0.00467;
                    7 0.00150; 8 0.00688; 9 0.00583; 10 0.00133; 11 0.00650; 12 0.00242;
                    13 0.00500; 14 0.00763; 15 0.00683; 16 0.00483; 17 0.00558; 18 0.00717;
                    19 0.00383; 20 0.00342; 21 0.00317; 22 0.00808; 23 0.00933; 25 0.00367;
                    26 0.00308; 27 0.00158; 31 0.00533; 32 0.00558; 36 0.00425; 40 0.00500;
                    44 0.00642; 45 0.00717; 50 0.00550];
                vol_blank = vol_blank(vol_blank(:,1)==stnlocal,2);
                mol_std = ds_oxy.mol_std*1e-3;
                %why are loaded and calculated off by 0.5, and what about
                %stations 20-27?
            case 'botvols'
                obot_vol = ds_oxy.bot_vol;
                if 0
                    fname_bottle = 'ctd/BOTTLE_OXY/flask_vols.csv';
                    ds_bottle = dataset('File', fname_bottle, 'Delimiter', ',');
                    ds_bottle(isnan(ds_bottle.bot_num),:) = [];
                    mb = max(ds_bottle.bot_num); a = NaN+zeros(mb, 1);
                    a(ds_bottle.bot_num) = ds_bottle.bot_vol;
                    iig = find(~isnan(ds_oxy.oxy_bot) & ds_oxy.oxy_bot~=-999);
                    obot_vol = NaN+ds_oxy.oxy_bot; obot_vol(iig) = a(ds_oxy.oxy_bot(iig)); %mL
                end
            case 'compcalc'
                compcalc = 00; %***
        end
        %%%%%%%%%% end moxy_ccalc %%%%%%%%%%
        
        %%%%%%%%%% mnut_01 %%%%%%%%%%
    case 'mnut_01'
        switch oopt
            case 'nutcsv'
                infile = fullfile(root_nut, '74JC20181103.csv');
            case 'vars'
                vars = {
                    'position'     'number'     'BTLNBR'%'niskin'
                    'statnum'      'number'     'STNNBR'%'station'
                    'sio4'          'umol/kg'    'SILCAT'%'Si'
                    'sio4_flag'    'woceflag'   'SILCAT_FLAG_W'
                    'po4'           'umol/kg'    'PHSPHT'
                    'po4_flag'     'woceflag'   'PHSPHT_FLAG_W'
                    'no3'        'umol/kg'    'NITRAT'
                    'no3_flag'   'woceflag'    'NITRAT_FLAG_W'
                    'no2'           'umol/kg'    'NITRITE'
                    'no2_flag'           'woceflag'    'NITRITE_FLAG_W'
                    };
            case 'flags'
                flag0 = 9;
        end %T=25 for carbon, 20 for nuts?
        %%%%%%%%%% mnut_01 %%%%%%%%%%
        
        %%%%%%%%%% mco2_01 %%%%%%%%%%
    case 'mco2_01'
        switch oopt
            case 'infile'
                load(fullfile(root_co2, [mcruise '_alkalinity_hydro']));
                hydro.sampnum = hydro.stn*100 + hydro.nisk;
                indata1 = dataset('File', fullfile(root_co2, ['DIC_data.csv']), 'Delimiter', ',');
                indata1.sampnum = indata1.station*100 + indata1.niskin;
                indata.sampnum = unique([hydro.sampnum; indata1.sampnum]);
                indata.talk = NaN+indata.sampnum; indata.QF_talk = 9+zeros(size(indata.sampnum));
                indata.dic = NaN+indata.sampnum; indata.QF_dic = 9+zeros(size(indata.sampnum));
                [c,ia,ib] = intersect(hydro.sampnum, indata.sampnum);
                indata.talk(ib) = hydro.talk(ia); indata.QF_talk(ib) = hydro.QF_talk(ia);
                [c,ia,ib] = intersect(indata1.sampnum, indata.sampnum);
                indata.dic(ib) = indata1.dic(ia); indata.QF_dic(ib) = indata1.dic_flag(ia);
                indata.stn = floor(indata.sampnum/100); indata.nisk = indata.sampnum-indata.stn*100;
            case 'varnames' %capitalisation is important!
                varnames = {'statnum' 'stn'
                    'niskin'  'nisk'
                    'alk' 'talk'
                    'alk_flag' 'QF_talk'
                    'dic' 'dic'
                    'dic_flag' 'QF_dic'
                    };
        end
        %%%%%%%%%% end mco2_01 %%%%%%%%%%
        
        %%%%%%%%%% msam_ashore_flag %%%%%%%%%%
    case 'msam_ashore_flag'
        switch samtype
            case 'bgs'
                flagnames = {'del18o_bgs_flag'; 'del13c_bgs_flag'};
                fnin = [mgetdir('M_BOT_ISO') '/JR18002_O_and_C_isotope_sample_log.csv'];
                ds_iso = dataset('File',fnin,'Delimiter',','); %csv file including text comments
                ds_iso.sampnum = ds_iso.station*100+ds_iso.niskin;
                flagvals = 1; ii = find(ds_iso.sample>0);
                clear sampnums
                sampnums = {ds_iso.sampnum(ii)};
                sampnums(2,:) = sampnums(1,:);
                stations = floor(ds_iso.sampnum(ii)/100);
            case 'whoi'
                flagnames = {'del14c_whoi_flag'; 'del13c_whoi_flag'};
                fnin = [mgetdir('M_BOT_ISO') '/JR18002_14C_sample_log.csv'];
                ds_iso = dataset('File',fnin,'Delimiter',','); %csv file including text comments
                ds_iso.sampnum = ds_iso.cast*100+ds_iso.niskin;
                flagvals = 1;
                clear sampnums
                ii = find(~isnan(ds_iso.bottom_depth)); sampnums(1,1) = {ds_iso.sampnum(ii)};
                sampnums(2,:) = sampnums(1,:);
                stations = floor(ds_iso.sampnum(ii)/100);
            case 'cfc'
                flagnames = {'cfc11_flag','cfc12_flag','sf6_flag','f113_flag','ccl4_flag','sf5cf3_flag'};
                fnin = [mgetdir('M_BOT_CFC') '/Survey_summary.csv'];
                ds_iso = dataset('File',fnin,'Delimiter',',');
                ds_iso.sampnum = ds_iso.Station*100 + ds_iso.NISK;
                flagvals = [5 4]; clear sampnums
                ii = find(ds_iso.flag==5);
                sampnums = {ds_iso.sampnum(ii)};
                ii = find(ds_iso.flag==4);
                sampnums(:,2) = {ds_iso.sampnum(ii)};
                sampnums(2,:) = sampnums(1,:);
                sampnums(3,:) = sampnums(1,:);
                sampnums(4,:) = sampnums(1,:);
                sampnums(5,:) = sampnums(1,:);
                sampnums(6,:) = sampnums(1,:);
                stations = unique(ds_iso.Station);
        end
        %%%%%%%%%% end msam_ashore_flag %%%%%%%%%%
        
        %%%%%%%%%% msam_02b %%%%%%%%%%
    case 'msam_02b'
        switch oopt
            case 'nflags'
                nflagstr = 'y = x2; y(x1==4 & ismember(x2, [2 3 6])) = 4; y(x1==3 & ismember(x2, [2 3 6])) = 3; y(x1==9) = 9;'; %facilitate checking for importance of visually detected niskin leaks first
        end
        %%%%%%%%%% end msam_02b %%%%%%%%%%
        
        %%%%%%%%%% msam_checkbottles_02 %%%%%%%%%%
    case 'msam_checkbottles_02'
        switch oopt
            case 'section'
                section = 'sr1b';
                stns = [3:21 22 44 40 36 32 31 27 26 25 23]; %with earlier sr1b21
                stnlist = find(stns==stnlocal);
                if isempty(stnlist)
                    ii = find(repeat_casts(:,1)==stnlocal);
                    stnlist = repeat_casts(ii,2);
                end
                stnlist = stnlist-2:stnlist+2; stnlist(stnlist<1) = 1; stnlist(stnlist>length(stns)) = length(stns);
                stnlist = stns(stnlist); stnlist(3) = stnlocal;
            case 'docals'
                doocal = 0;
        end
        %%%%%%%%%% end msam_checkbottles_02 %%%%%%%%%%
        
        %%%%%%%%%% mtsg_01 %%%%%%%%%%
    case 'mtsg_01'
        switch oopt
            case 'flag'
                flag(ds_sal.sampnum>=313201500 & ds_sal.sampnum<=314010000) = 3;
        end
        %%%%%%%%%% end mtsg_01 %%%%%%%%%%
        
        %%%%%%%%%% tsgsal_apply_cal %%%%%%%%%%
    case 'tsgsal_apply_cal'
        switch oopt
            case 'saladj'
                salout = salin - 1.71e-3*time - 0.335;
        end
        %%%%%%%%%% end tsgsal_apply_cal %%%%%%%%%%
        
        %%%%%%%%%% temp_apply_cal %%%%%%%%%%
    case 'temp_apply_cal'
        switch sensor
            case 1
                tempout = temp*(1+1.6e-4) + interp1([0 800 5000],[.1 -.2 0],press)*1e-3 + 0.1e-4;
            case 2
                tempout = temp*(1+1.7e-4) + interp1([0 2000 5000],[-1 -1.3 -1.8],press)*1e-3 - 1e-5*stn + 2.8e-4;
        end
        %%%%%%%%%% end temp_apply_cal %%%%%%%%%%
        
        
        %%%%%%%%%% cond_apply_cal %%%%%%%%%%
    case 'cond_apply_cal'
        switch sensor
            case 1
                off = interp1([0 1800 5000], [-.8 -2 -1.5], press)*1e-3 + 0.6e-3;
            case 2
                off = interp1([0 1500 5000],[-1.8 -2.8 -4.5],press)*1e-3; %
        end
        fac = off/35 + 1;
        condadj = 0;
        condout = cond.*fac + condadj;
        %%%%%%%%%% cond_apply_cal %%%%%%%%%%
        
        %%%%%%%%%% oxy_apply_cal %%%%%%%%%%
    case 'oxy_apply_cal'
        alpha = interp1([0 5000]',[1.035 1.062]',press) + 0.3*1e-4*stn;
        beta = interp1([0 500 5000],[-1.4 0.5 -0.9],press);
        oxyout = alpha.*oxyin + beta;
        %%%%%%%%%% end oxy_apply_cal %%%%%%%%%%
        
        %%%%%%%%%% mout_cchdo_sam %%%%%%%%%%
    case 'mout_cchdo_sam'
        switch oopt
            case 'expo'
                expocode = '74JC20181103';
                sect_id = 'SR1b';
            case 'nocfc'
                nocfc = 1;
                d.cfc11(:) = NaN; d.cfc12(:) = NaN; d.f113(:) = NaN; d.ccl4(:) = NaN; d.sf6(:) = NaN; d.sf5cf3(:) = NaN;
            case 'outfile'
                outfile = fullfile(MEXEC_G.MEXEC_DATA_ROOT, 'collected_files', ['sr1b_' expocode]);
                %if nocfc; outfile = [outfile '_no_cfc_values']; end
            case 'headstr'
                headstring = {['BOTTLE,' datestr(now,'yyyymmdd') 'OCPNOCYLF'];... %the last field specifies group, institution, initials
                    '#SHIP: James Clark Ross';...
                    '#Cruise JR18002; SR1B';...
                    '#Region: Drake Passage';...
                    ['#EXPOCODE: ' expocode];...
                    '#DATES: 20181103 - 20181122';...
                    '#Chief Scientist: Y. Firing, NOC';...
                    '#Supported by NERC National Capability NE/N018095/1 (ORCHESTRA)';...% and NERC NE/P019064/1 (TICTOC)';...
                    '#44 stations with 24-place rosette';...
                    '#CTD: Who - Y. Firing; Status - final';...
                    '#Notes: Includes CTDSAL, CTDOXY, SBE35';...
                    '#The CTD PRS;  TMP;  SAL; OXY data are all calibrated and good.';...
                    '#Flags in bottle file set to good for all existing values';...
                    '#CTD files also contain CTDXMISS, CTDFLUOR';...
                    '#Salinity: Who - Y. Firing; Status - final';...
                    '#Notes:';...
                    '#Oxygen and Nutrients: Who - E. Mawji; Status - final';...
                    '#DIC and Talk: Who - P. Brown; Status - uncalibrated';...
                    '#CFCs and SF6: Who - M.J. Messias; Status - not yet reported';...
                    '#DEL14C: Who - R. Key; Status - not yet analysed';...
                    '#DEL13C and DEL18O: Who - M. Leng; Status - not yet analysed';...
                    '#Notes:';...
                    '#These data should be acknowledged with: "Data were collected and made publicly available by the international Global Ship-based Hydrographic Investigations Program (GO-SHIP; http://www.go-ship.org/) with National Capability funding from the UK Natural Environment Research Council to the National Oceanography Centre."'}; %and funding to BGS, and Exeter...
        end
        %%%%%%%%%% end mout_cchdo_sam %%%%%%%%%%
        
        %%%%%%%%%% mout_cchdo_ctd %%%%%%%%%%
    case 'mout_cchdo_ctd'
        switch oopt
            case 'expo'
                expocode = '74JC20181103';
                sect_id = 'SR1b';
            case 'outfile'
                outfile = fullfile(MEXEC_G.MEXEC_DATA_ROOT, 'collected_files', ['sr1b_' expocode '_ct1'], ['sr1b_' expocode]);
            case 'headstr'
                headstring = {['CTD,' datestr(now,'yyyymmdd') 'OCPNOCYLF'];...
                    '#SHIP: James Clark Ross';...
                    '#Cruise JR17001; SR1B';...
                    '#Region: Drake Passage';...
                    ['#EXPOCODE: ' expocode];...
                    '#DATES: 20181103 - 20181122';...
                    '#Chief Scientist: Y. Firing, NOC';...
                    '#Supported by NERC National Capability NE/N018095/1 (ORCHESTRA)';...
                    '#44 stations with 24-place rosette';...
                    '#CTD: Who - Y. Firing; Status - final';...
                    '#Notes: Includes CTDSAL, CTDOXY, SBE35';...
                    '#The CTD PRS;  TMP;  SAL; OXY data are all calibrated and good.';...
                    '# DEPTH_TYPE   : COR';...
                    '#These data should be acknowledged with: "Data were collected and made publicly available by the International Global Ship-based Hydrographic Investigations Program (GO-SHIP; http://www.go-ship.org/) with National Capability funding from the UK Natural Environment Research Council to the National Oceanography Centre."'};
        end
        %%%%%%%%%% end mout_cchdo_ctd %%%%%%%%%%
        
        
        
        %%%%%%%%%% mtsg_cleanup %%%%%%%%%%
    case 'mtsg_cleanup'
        switch oopt
            case 'kbadlims'
                kbadlims = [
                    datenum([2018 10 31 14 31 0]) datenum([2018 11 3 23 2 0]) % start of cruise
                    ];
                %             datenum([2017 11 27 05 48 00]) datenum([2017 11 27 10 58 00]) % rough weather
                %             datenum([2017 12 19 15 24 00]) datenum([2017 12 22 00 00 00]) %end of cruise
                %            ];
        end
        %%%%%%%%%% end mtsg_cleanup %%%%%%%%%%
        
        
        %%%%%%%%%% msec_run_mgridp %%%%%%%%%%
    case 'msec_run_mgridp'
        switch oopt
            case 'sections'
                sections = {'sr1b' 'sr1ba' 'sr1bb'};
            case 'ctd_regridlist'
                varlist = [varlist ' fluor transmittance'];
            case 'sec_stns'
                switch section
                    case 'sr1b'
                        kstns = [3:21 22 44 40 36 32 31 27 26 25 23]; %with earlier sr1b21
                    case 'sr1ba'
                        kstns = [3:10 1 12:21 22 44 40 36 32 31 27 26 25 23]; %with full depth sr1b9
                    case 'sr1bb'
                        kstns = [3:21 45 44 40 36 32 31 27 26 25 23]; %with later sr1b21
                end
            case 'sam_gridlist'
                varuselist.names = {'botoxy' 'totnit' 'phos' 'silc' 'dic' 'alk'};
        end
        %%%%%%%%%% end msec_run_mgridp %%%%%%%%%%
        
        
        %%%%%%%%%% station_summary %%%%%%%%%%
    case 'station_summary'
        switch oopt
            case 'sum_sams'
                snames = {'noxy'; 'nnut'; 'nco2'; 'ncfc'; 'no18s'; 'nradcs'}; %s suffix for variables not analysed on ship at all
                snames_shore = {'noxy_shore'; 'nnut_shore'; 'nco2_shore'; 'ncfc_shore'; 'no18'; 'nradc'};
                sgrps = { {'botoxy'} %list of oxy variables
                    {'silc' 'phos' 'totnit'} %list of nuts variables
                    {'dic' 'alk'} %list of co2 variables
                    {'cfc11' 'cfc12' 'f113' 'sf6' 'ccl4' 'sf5cf3'} %list of cfc variables
                    {'del18o_bgs'} % BGS del O 18
                    {'del13c_bgs' 'del13c_noc' 'del13c_whoi' 'del14c_whoi'} % All delC13  delC14 except BGS
                    };
                sashore = [0; 0; 0; 0; 1; 1]; %count samples partially analysed ashore
            case 'sum_comments' % set comments
                comments{1} = 'Test cast; aborted on upcast due to multiple shorts and wire slipping';
                comments{2} = 'Test cast for replacement wire; aborted on downcast due to weather';
                comments{3} = 'Start of SR1b section';
                comments{10} = 'Full depth repeat of cast 2';
                comments{11} = 'Partial depth (4350 m wire / 4750 msw), repeat of cast 1';
                comments{22} = 'Section broken after this cast to procede to Elephant Island due to weather';
                comments{45} = 'Repeat of cast 22 to join up SR1b section';
                ii = repeat_casts(:,1); ii = ii(~ismember(ii,[1 2 45])); comments(ii) = {'Ra cast'};
            case 'sum_edit' % impose start and end times not captured from CTD dcs files
                dne(1) = datenum(2018,11,06,01,30,00);
                cordep(2) = 5000; %from em122, not full depth cast
                cordep(11) = 4789; %from em122, not full depth cast
            case 'parlist'
                parlist = [' sal'; ' oxy'; ' nut'; ' car'; ' co2'; ' cfc'; ' ch4'];
            case 'sum_varnames'
                varnames={'statnum' 'time_start' 'time_bottom' 'time_end' 'lat' 'lon' 'cordep' 'maxd' 'minalt' 'resid' 'maxw' 'maxp' 'ndpths' 'nsal' 'noxy' 'nnut' 'nco2' 'ncfc' 'no18' 'nradc'};
                varunits={'number' 'seconds' 'seconds' 'seconds' 'degrees' 'degrees' 'metres' 'metres' 'metres' 'metres' 'metres' 'dbar' 'number' 'number' 'number' 'number' 'number' 'number' 'number' 'number'};
            case 'stnadd'
        end
        %%%%%%%%%% end station_summary %%%%%%%%%%
        
        
        %%%%%%%%%% mvad_01 %%%%%%%%%%
    case 'mvad_01'
        switch oopt
            case 'vmadcp_files'
                cname = 'enrproc007_029';
                fnin = [root_vmadcp '/' mcruise '_' oslocal '/adcp_pyproc/' cname '/' oslocal '/contour/' oslocal '.nc'];
                dataname = [oslocal '_' mcruise '_01'];
        end
        %%%%%%%%%% end mvad_01 %%%%%%%%%%
        
        
        
end
