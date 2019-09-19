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
            case 'corraw'
                pvars = {'temp1' 12
                    'temp2' 12
                    'cond1' 12
                    'cond2' 12
                    'oxygen_sbe1' 8*24
                    };
                revars = {'press' -10 8000 %range edit
                    'temp1' -3 10
                    'temp2' -3 10
                    'cond1' 25 60
                    'cond2' 25 60
                    'transmittance' 50 101
                    'oxygen_sbe1' 0 500
                    'fluor' 0 1
                    };
                dsvars = {'press' 3 2 2}; %despike
                %    'temp1' 1 0.5 0.5
                %    'temp2' 1 0.5 0.5
                %    'cond1' 1 0.5 0.5
                %    'cond2' 1 0.5 0.5
                %    'oxygen_sbe1' 3 2 2
                %    'transmittance' 0.3 0.2 0.2
                %    'fluor' 0.2 0.1 0.1
                %    'turbidityV' 0.05 0.05 0.05%***
                %    'pressure_temp' 0.1 0.1 0.1
                %    };
                ovars = {'oxygen_sbe1'};
        end
        %%%%%%%%%% end mctd_02a %%%%%%%%%%
        
        %%%%%%%%%% mctd_03 %%%%%%%%%%
    case 'mctd_03'
        switch oopt
            case 's_choice' %this applies to both t and c
                s_choice = 2; %need to use sensor 2 for 36:39, but also, oxygen was plumbed into ctd2
        end
        %%%%%%%%%% end mctd_03 %%%%%%%%%%
        
        %%%%%%%%%% mbot_00 %%%%%%%%%%
    case 'mbot_00' %information about niskin bottle numbers
        switch oopt
            case 'nispos'
                %numbers of the niskins in order of 1 to 24
                nis = [1:24]; nis_spare = 25; nis_12 = 26;
                %original niskin 19 lost on cast 23, replaced with spare
                if stnlocal>=24; nis = [nis(1:18) nis_spare nis(20:24)]; end
                %spare doesn't close due to frame, replaced with 12 L
                if stnlocal>=45; nis = [nis(1:18) nis_12 nis(20:24)]; end
        end
        %%%%%%%%%% end mbot_00 %%%%%%%%%%

        %%%%%%%%%% mbot_01 %%%%%%%%%%
    case 'mbot_01'
        switch oopt
            case 'botflags'
                %[station niskin]
                flag3 = [1 1; 1 2; 1 3; 1 4; 2 12; 3 9; 5 24; 5 7; 5 11; 5 16; 5 21; 5 24; 
                    7 7; 7 11; 7 12; 7 13; 7 15; 7 16; 7 17; 7 19; 8 12; 8 21; 
                    9 10; 9 21; 9 22; 9 24; 10 21; 11 3; 11 24; 12 10; 12 22; 12 24; 13 2; 13 21; 
                    15 1; 15 11; 15 15; 15 23; 15 24; 16 1; 17 4; 18 12; 18 21; 18 24; 
                    19 7; 19 14; 19 15; 19 19; 20 7; 20 11; 20 14; 21 2; 21 7; 21 11; 21 15; 
                    22 11; 23 7; 23 11; 25 7; 25 11; 25 12; 25 21; 25 24; 26 21; 26 12; 26 7; 
                    27 7; 27 12; 27 23; 31 7; 31 23; 32 11; 32 12; 32 21; 32 24; 34 7; 35 7; 
                    36 11; 36 13; 36 17; 36 18; 40 4; 40 7; 40 14; 40 15; 41 24; 50 15; 45 9; 45 16; 45 21; 45 24;
                    57 5; 58 24; 58 7]; % possibly leaking or questionable based on visual
                flag3 = [flag3; 9 7; ]; %possibly bad bottle based on cfc values (prelim)
                flag4 = [2 8; 3 8; 3 10; 4 12; 4 14; 4 15; 4 17; 5 12; 5 14; 5 15; 5 17; 8 13; 10 8; 10 10; 
                    11 08; 11 21; 14 21; 14 24; 15 7; 15 12; 15 21; 16 7; 16 11; 16 12; 16 24; 
                    17 7; 17 12; 17 21; 17 24; 18 10; 19 11; 19 12; 20 12; 20 15; 20 22; 21 12; 21 21; 21 24; 
                    22 12; 22 17; 22 24; 23 12;23 21; 23 24; 25 19; 26 24; 27 24; 31 22; 32 24; 33 7; 33 12; 
                    36 10; 36 12; 36 19; 36 24; 37 7; 37 10; 37 19; 40 10; 40 19; 40 21; 40 24; 41 9; 41 19; 
                    44 7; 44 10; 44 12; 44 19; 44 21; 44 24; 45 15; 47 7]; % empty or end caps clearly not seated or bad based on sample values
                flag9 = [13 24; 33 10; 33 19; 33 24; 34 10; 34 19; 34 24; 35 10; 35 19; 35 24; 36 24; 
                    38 10; 38 19; 39 10; 39 19; 39 24; 57 10; 58 8]; %did not fire (line not released)
                flag4 = [flag4; 23 19]; % broken (lost) bottle 
                iif = find(flag3(:,1)==stnlocal); if length(iif)>0; bottle_qc_flag(flag3(iif,2)) = 3; end
                iif = find(flag4(:,1)==stnlocal); if length(iif)>0; bottle_qc_flag(flag4(iif,2)) = 4; end
                iif = find(flag9(:,1)==stnlocal); if length(iif)>0; bottle_qc_flag(flag9(iif,2)) = 9; end
        end
   %%%%%%%%%% end mbot_01 %%%%%%%%%%
        
        %%%%%%%%%% populate_station_depths %%%%%%%%%%
    case 'populate_station_depths'
        switch oopt
            case 'fnin'
                depmeth = 4; %get from LADCP data
            case 'bestdeps'
                ii = find(bestdeps(:,1)==2); bestdeps(ii,2) = 5000;
                ii = find(bestdeps(:,1)==11); bestdeps(ii,2) = 4789;
                cf = [27 32 36 40 45 51]; %full depth casts followed by 3 of Amber's
                for cno = 1:length(cf)
                   iif = find(bestdeps(:,1)==cf(cno)); ii = find(ismember(bestdeps(:,1),cf(cno)+[1 2 3])); bestdeps(ii,2) = bestdeps(iif,2);
                end
                %amber's casts repeating earlier sr1b sites
                iif = find(bestdeps(:,1)==51); ii = find(ismember(bestdeps(:,1),51-[1 2])); bestdeps(ii,2) = bestdeps(iif,2);
                iif = find(bestdeps(:,1)==18); ii = find(ismember(bestdeps(:,1),[55 56])); bestdeps(ii,2) = bestdeps(iif,2);
                iif = find(bestdeps(:,1)==15); ii = find(ismember(bestdeps(:,1),[57 58])); bestdeps(ii,2) = bestdeps(iif,2);
                iif = find(bestdeps(:,1)==12); ii = find(ismember(bestdeps(:,1),[59:61])); bestdeps(ii,2) = bestdeps(iif,2);
                iif = find(bestdeps(:,1)==10); ii = find(ismember(bestdeps(:,1),[62:64])); bestdeps(ii,2) = bestdeps(iif,2);
                iif = find(bestdeps(:,1)==08); ii = find(ismember(bestdeps(:,1),[65:67])); bestdeps(ii,2) = bestdeps(iif,2);
                iif = find(bestdeps(:,1)==05); ii = find(ismember(bestdeps(:,1),[68:70])); bestdeps(ii,2) = bestdeps(iif,2);
                iif = find(bestdeps(:,1)==03); ii = find(ismember(bestdeps(:,1),[71])); bestdeps(ii,2) = bestdeps(iif,2);
        end
        %%%%%%%%%% end populate_station_depths %%%%%%%%%%
        
        %%%%%%%%%% msal_01 %%%%%%%%%%
    case 'msal_01'
        switch oopt
            case 'indata'
                sal_mat_file = ['sal_' mcruise '_01.mat'];
          case 'flag'
              if ismember(stnlocal,[14 20])
                  flag(:) = 3; %all offset the same amount after cal applied, think standardisation might be off
              end %14, 9:19; 20, 14:20; 40, 1:23?
        end
        %%%%%%%%%% end msal_01 %%%%%%%%%%
        
        %%%%%%%%%% msal_standardise_avg %%%%%%%%%%
    case 'msal_standardise_avg'
        switch oopt
            case 'salcsv'
                d = dir([root_sal '/JR18002_sal*.csv']);
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
                std2use([13],1) = 0;
                std2use([34],2) = 0;
                std2use([4 33],3) = 0;
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
                infile = [root_oxy '/Cast_' stn_string '.csv'];
            case 'sampnum_parse'
                ds_oxy.statnum = ds_oxy.Cast;
                ds_oxy.niskin = ds_oxy.Niskin;
                ds_oxy.sampnum = ds_oxy.statnum*100+ds_oxy.niskin;
                ds_oxy.oxy_bot = ds_oxy.Bottle;
                ds_oxy.bot_vol = ds_oxy.Bottle_vol0x2E;
                ds_oxy.vol_blank = ds_oxy.Blank;
                ds_oxy.vol_std = ds_oxy.Std;
                ds_oxy.vol_titre_std = ds_oxy.Standard;
                ds_oxy.oxy_temp = ds_oxy.Fixing_temp0x2E;
                ds_oxy.oxy_titre = ds_oxy.Sample;
                ds_oxy.mol_std = ds_oxy.Iodate_M;
                ds_oxy.nO2 = ds_oxy.n0x28O20x29;
                ds_oxy.conc_O2 = ds_oxy.C0x28O20x29;
            case 'flags'
                if statnum==19; botoxyflaga(botoxyflaga==2) = 3; end
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
                if stnlocal==1; vol_blank = 0.00758; elseif stnlocal==2; vol_blank = 0.00958;
                elseif stnlocal==3; vol_blank = 0.00350; elseif stnlocal==4; vol_blank = 0.00550; 
                elseif stnlocal==5; vol_blank = 0.00308; elseif stnlocal==6; vol_blank = 0.00467; 
                elseif stnlocal==7; vol_blank = 0.00150; elseif stnlocal==8; vol_blank = 0.00688; 
                elseif stnlocal==9; vol_blank = 0.00583; elseif stnlocal==10; vol_blank = 0.00133;
                elseif stnlocal==11; vol_blank = 0.00650; elseif stnlocal==12; vol_blank = 0.00242;
                elseif stnlocal==13; vol_blank = 0.00500; elseif stnlocal==14; vol_blank = 0.00763; 
                elseif stnlocal==15; vol_blank = 0.00683; elseif stnlocal==16; vol_blank = 0.00483; 
                elseif stnlocal==17; vol_blank = 0.00558; elseif stnlocal==18; vol_blank = 0.00717; 
                elseif stnlocal==19; vol_blank = 0.00383; elseif stnlocal==20; vol_blank = 0.00342; 
                elseif stnlocal==21; vol_blank = 0.00317; elseif stnlocal==22; vol_blank = 0.00808; 
                elseif stnlocal==23; vol_blank = 0.00933; elseif stnlocal==25; vol_blank = 0.00367; 
                elseif stnlocal==26; vol_blank = 0.00308; elseif stnlocal==27; vol_blank = 0.00158; 
                elseif stnlocal==31; vol_blank = 0.00533; elseif stnlocal==32; vol_blank = 0.00558;
                elseif stnlocal==36; vol_blank = 0.00425; elseif stnlocal==40; vol_blank = 0.00500;
                elseif stnlocal==44; vol_blank = 0.00642; elseif stnlocal==45; vol_blank = 0.00717;
                elseif stnlocal==50; vol_blank = 0.00550;
                end
                mol_std = ds_oxy.mol_std*1e-3;
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
                compcalc = 1; %***
        end
        %%%%%%%%%% end moxy_ccalc %%%%%%%%%%

        %%%%%%%%%% mnut_01 %%%%%%%%%%
    case 'mnut_01'
        switch oopt
            case 'nutcsv'
                infile = [root_nut '/' upper(mcruise) '_nuts.csv'];
            case 'vars'
                vars = {
                    'position'     'number'     'niskin'
                    'statnum'      'number'     'station'
                    'sampnum'      'number'     'sampnum'
                    'sio4'          'umol/kg'    'Si'
                    %'sio4'         'umol/L'     'Si_COR'
                    %    		   'sio4'         'umol/L'     'SiCOR'
                    'sio4_flag'    'woceflag'   ''
                    'po4'           'umol/kg'    'P'
                    %'po4'          'umol/L'     'PO4_COR'
                    %		       'po4'          'umol/L'     'PO4COR'
                    'po4_flag'     'woceflag'   ''
                    'no3no2'        'umol/kg'    'NO30x2BNO2'
                    %'no3no2'       'umol/L'     'NO30x2BNO2_COR'
                    %	    	   'no3no2'       'umol/L'     'NO3_NO2COR'
                    'no3no2_flag'  'woceflag'   ''
                    'no2'           'umol/kg'    'NO2'
                    %'no2'          'umol/L'     'NO2_COR'
                    %		       'no2'          'umol/L'     'NO2COR'
                    'no2_flag'	  'woceflag'   ''
                    };
        end %T=25 for carbon, 20 for nuts?
       %%%%%%%%%% mnut_01 %%%%%%%%%%
        
        %%%%%%%%%% mco2_01 %%%%%%%%%%
    case 'mco2_01'
        switch oopt
            case 'infile'
                load([root_co2 '/' mcruise '_alkalinity_hydro']); 
                hydro.sampnum = hydro.stn*100 + hydro.nisk;
                indata1 = dataset('File', [root_co2 '/DIC_data.csv'], 'Delimiter', ',');
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
        end
        %%%%%%%%%% end msam_ashore_flag %%%%%%%%%%

        %%%%%%%%%% msam_checkbottles_02 %%%%%%%%%%
    case 'msam_checkbottles_02'
        switch oopt
            case 'section'
                section = 'sr1b';
                stns = [3:21 22 44 40 36 32 31 27 26 25 23]; %with earlier sr1b21
                stnlist = find(stns==stnlocal); 
                if length(stnlist)==0; error(['station ' num2str(stnlocal) ' not in section list']); 
                else; stnlist = stnlist-2:stnlist+2; stnlist(stnlist<1) = 1; stnlist(stnlist>length(stns)) = length(stns); stnlist = stns(stnlist); end
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
	    tempadj = interp1([0 2000 5000],[-1 -.2 -.55]*1e-3,press)+(2.83 -0.05*stn)*1e-3;
	    tempout = temp+tempadj;
	 case 2
	    tempadj = interp1([0 500 2000 5000],[-.5 -1.2 -1.5 -1.7]*1e-3,press) + .2e-3;
	    tempout = temp+tempadj;
      end
   %%%%%%%%%% end temp_apply_cal %%%% %interp1([0 800 6000], [1 0 -2]*1e-4, press).*stn);%%%%%%
   
       
          %%%%%%%%%% cond_apply_cal %%%%%%%%%%
    case 'cond_apply_cal'
        switch sensor
            case 1
                off = interp1([0 400 5000],[.8 -.4 -.8]*1e-3,press) -1.2e-5*stn + .2e-3;% -2.3e-4*stn;
                %off = 
            case 2
                off = interp1([0 500 5000],[-1.8 -3.4 -4.7]*1e-3,press); %
        end
        fac = off/35 + 1;
        condadj = 0;
        condout = cond.*fac + condadj;
        %%%%%%%%%% cond_apply_cal %%%%%%%%%%
        
        %%%%%%%%%% oxy_apply_cal %%%%%%%%%%
    case 'oxy_apply_cal'
        alpha = 1.03 + -2.5e-4*stn;
        beta = 3.8 + interp1([0 400 1750 5000],[.8 1 1.7 5.5],press);
        oxyout = alpha.*oxyin + beta;
        %%%%%%%%%% end oxy_apply_cal %%%%%%%%%%
        
 %%%%%%%%%% mout_cchdo_sam %%%%%%%%%%
   case 'mout_cchdo_sam'
      switch oopt
         case 'expo'
	    expocode = '74JC20181103';
            sect_id = 'SR1b';
	 case 'outfile'
	    outfile = [MEXEC_G.MEXEC_DATA_ROOT '/collected_files/sr1b_' expocode '_ct1/sr1b_' expocode];
	 case 'headstr'
            headstring = {['BOTTLE,' datestr(now,'yyyymmdd') 'OCPNOCYLF'];... %the last field specifies group, institution, initials
	    '#SHIP: James Clark Ross';...
	    '#Cruise JR18002; SR1B';...
	    '#Region: Drake Passage';...
	    ['#EXPOCODE: ' expocode];...
	    '#DATES: 20181103 - 20181122';...
	    '#Chief Scientist: Y. Firing, NOC';...
	    '#Supported by NERC National Capability NE/N018095/1 (ORCHESTRA) and NERC *** (TICTOC)';...
	    '#44 stations with 24-place rosette';...
	    '#CTD: Who - Y. Firing; Status - final';...
	    '#Notes: Includes CTDSAL, CTDOXY, SBE35';...
	    '#The CTD PRS;  TMP;  SAL; OXY data are all calibrated and good.';...
	    '#Flags in bottle file set to good for all existing values';...
	    '#CTD files also contain CTDXMISS, CTDFLUOR';...
	    '#Salinity: Who - Y. Firing; Status - final';...
	    '#Notes:';...
        '#Oxygen and Nutrients: Who - E. Mawji; Status - final';...
        '#DIC and Talk: Who - P. Brown; Status ';...
        '#CFCs and SF6: Who - M.J. Messias; Status ';...
        '#Notes:';...
        '#These data should be acknowledged with: "Data were collected and made publicly available by the international Global Ship-based Hydrographic Investigations Program (GO-SHIP; http://www.go-ship.org/) with National Capability funding from the UK Natural Environment Research Council to the National Oceanography Centre."'};
      end
   %%%%%%%%%% end mout_cchdo_sam %%%%%%%%%%

   %%%%%%%%%% mout_cchdo_ctd %%%%%%%%%%
   case 'mout_cchdo_ctd'
      switch oopt
         case 'expo'
	        expocode = '74JC20171121';
            sect_id = 'SR1b';
	 case 'outfile'
	    outfile = [MEXEC_G.MEXEC_DATA_ROOT '/collected_files/sr1b_' expocode];
	 case 'headstr'
	    headstring = {['CTD,' datestr(now,'yyyymmdd') 'OCPNOCYLF'];...
	    '#SHIP: James Clark Ross';...
	    '#Cruise JR17001; SR1B';...
	    '#Region: Drake Passage';...
	    ['#EXPOCODE: ' expocode];...
	    '#DATES: 20181103 - 20181122';...
	    '#Chief Scientist: Y. Firing, NOC';...
	    '#Supported by NERC National Capability NE/N018095/1 (ORCHESTRA) and NERC *** (TICTOC)';...
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
                sections = {'sr1b' 'sr1bb'};
            case 'varlist'
                varlist = [varlist ' fluor transmittance'];
            case 'kstns'
                switch section
                    case 'sr1b'
                        sstring = '[3:21 22 44 40 36 32 31 27 26 25 23]'; %with earlier sr1b21
                    case 'sr1bb'
                        sstring = '[3:21 45 44 40 36 32 31 27 26 25 23]'; %with later sr1b21
                end
            case 'varuse'
                %varuselist.names = {'botoxy' 'totnit_per_kg' 'phos_per_kg' 'silc_per_kg' 'dic' 'alk' 'cfc11'  'cfc12' 'f113' 'sf6' 'ccl4'};
                %varuselist.names = {'botoxy' 'totnit_per_kg' 'phos_per_kg' 'silc_per_kg' 'dic' 'alk' 'cfc11'  'cfc12' 'f113' 'sf6'};
                varuselist.names = {'botoxy' 'totnit' 'phos' 'silc' 'dic' 'alk'};
        end
        %%%%%%%%%% end msec_run_mgridp %%%%%%%%%%
        
        
        %%%%%%%%%% station_summary %%%%%%%%%%
    case 'station_summary'
        switch oopt
            case 'optsams'
                snames = {'noxy'; 'nnut'; 'nco2'; 'ncfc'; 'no18s'; 'nc13s'};
                snames_shore = {'nco2_shore'; 'ncfc_shore'; 'no18'; 'nc13'; 'nchl'}; % can use name without _shore, because all samples are analysed ashore microplastics***
                sgrps = { {'botoxy'} %list of oxy variables
                    {'silc' 'phos' 'totnit'} %list of nuts variables
                    {'dic' 'talk'} %list of co2 variables
                    {'cfc11' 'cfc12' 'f113' 'sf6' 'ccl4' 'sf5cf3' 'cfc13'} %list of cfc variables
                    {'del18o_bgs'} % BGS del O 18
                    {'del13c_bgs' 'del13c_noc' 'del13c_whoi' 'del14c_whoi'} % All delC13  delC14 except BGS
                    };
                sashore = [0; 1; 1; 1; 1; 1; 1; 1]; %count samples to be analysed ashore? % can't presently count botoxy_flag == 1
            case 'comments' % set comments
                comments{1} = 'Test cast; CTD and wire shorts';
                comments{2} = 'Test cast for replacement wire; not full depth';
                comments{3} = 'Start of SR1b section';
                comments{11} = 'Not full depth (wire limited to 4350, depth 4750 msw)';
            case 'alttimes' % impose start and end times not captured from CTD dcs files
            case 'altdep'
                cordep(2) = 5000; %from em122, not full depth cast
                cordep(11) = 4789; %from em122, not full depth cast
            case 'parlist'
                parlist = [' sal'; ' oxy'; ' nut'; ' car'; ' co2'; ' cfc'; ' ch4'];
            case 'varnames'
                varnames={'statnum' 'time_start' 'time_bottom' 'time_end' 'lat' 'lon' 'cordep' 'maxd' 'minalt' 'resid' 'maxw' 'maxp' 'ndpths' 'nsal' 'noxy' 'nnut' 'nco2' 'ncfc' 'no18' 'nc13' 'nchl'};
                varunits={'number' 'seconds' 'seconds' 'seconds' 'degrees' 'degrees' 'metres' 'metres' 'metres' 'metres' 'metres' 'dbar' 'number' 'number' 'number' 'number' 'number' 'number' 'number' 'number' 'number'};
            case 'stnmiss'
                stnmiss = [];
            case 'stnadd'
        end
        %%%%%%%%%% end station_summary %%%%%%%%%%
        
        
        %%%%%%%%%% mvad_01 %%%%%%%%%%
    case 'mvad_01'
        switch oopt
            case 'files'
                cname = 'enrproc007_029';
                pre1 = [mcruise '_' inst '/adcp_pyproc/' cname '/' inst nbbstr];
                datadir = [root_vmadcp '/' pre1 '/contour'];
                fnin = [datadir '/' inst 'nb.nc'];
                dataname = [inst '_' mcruise '_01'];
        end
        %%%%%%%%%% end mvad_01 %%%%%%%%%%
end
