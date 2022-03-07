switch scriptname

    case 'm_daily_proc'
        switch oopt
            case 'excludestreams'
                uway_excludes = {'singleb_t'};
        end
        
        case 'mday_01_fcal'
        switch oopt
            case 'uway_factory_cal'
                switch abbrev
                    case 'surfmet'
                        sensorcals.fluo = 'y=(x1-0.082)*04.9;'; % fluorometer: s/n WS3S-248 cal 24 Jun 2021
                        sensorcals.trans = 'y=(x1-0.004)/(4.700-0.004)*100;'; %transmissometer: s/n CST-1852PR cal 23 Mar 2021
                        sensorcals.parport = 'y=x1/0.9451;'; % port? PAR: s/n SKE510 28563 cal 23 Mar 2021
                        sensorcals.parstbd = 'y=x1/1.029;'; % stb? PAR: s/n SKE510 28562 cal 29 Mar 2021 %muV/Wm-2
                        sensorcals.tirport = 'y=x1/1.181;'; % port TIR: s/n 973135 cal 6 Apr 2021
                        sensorcals.tirstbd = 'y=x1/1.009;'; % stb TIR: s/n 962276 cal 18 Aug 2021
                        % the surfmet instrument box is outputting in V*1e-5 for PAR/TIR already***check this is true on dy as well
                        sensorunits.fluo = 'ug/l';
                        sensorunits.trans = 'percent';
                        sensorunits.parport = 'W/m2';
                        sensorunits.parstbd = 'W/m2';
                        sensorunits.tirport = 'W/m2';
                        sensorunits.tirstbd = 'W/m2';
                    case 'multib'
                        xducer_offset = 5;
                end
        end
        
    case 'mtsg_medav_clean_cal'
        switch oopt
            case 'tsg_badlims'
                kbadlims = [
%                     datenum(2022,1,1) + [-inf 39+19/24]; %start of cruise, TSG on during decimal day 39
                    datenum([2020 01 01 00 00 00]) datenum([2022 02 09 19 00 00]) % start of cruise
                    datenum([2022 02 10 08 58 00]) datenum([2022 02 10 09 05 00])
                    datenum([2022 02 21 13 18 00]) datenum([2022 02 21 13 27 00])
                    datenum([2022 03 04 12 38 00]) datenum([2023 01 01 00 00 00]) % end of TSG logging in international waters
                    ];
       case 'tsgcals'
tsgopts.docal.salinity = 1;
load(fullfile(root_dir,'sdiffsm'))
kbad = find(isnan(t+sdiffsm)); t(kbad) = []; sdiffsm(kbad) = [];
tsgopts.calstr.salinity.dy146 = 'dcal.salinity_cal = dnew.salinity_raw + interp1([-1e10; t; 1e10],sdiffsm([1 1:end end]),d.time);';
 end

        %%%%%%%%%% mtsg_bottle_compare %%%%%%%%%%
    case 'mtsg_bottle_compare'
        switch oopt
            case 'tsg_usecal'
                usecal = 1;
            case 'tsg_timebreaks'
                tbreak = [
%                     datenum([2021 2 20 12 30 00]) % pumps off Fl & Tr cleaned; TSG not cleaned
%                     datenum([2021 2 27 16 10 00]) % Fl, Tr and TSG cleaned. Day 058/1610
                    ];
            case 'tsg_sdiff'
                sc1 = 0.5; sc2 = 0.01; %thresholds to use for smoothed series
        end
        %%%%%%%%%% end mtsg_bottle_compare %%%%%%%%%%
 

    case 'castpars'
        switch oopt
            case 'nnisk'
                nnisk = 12;
            case 'oxy_align'
                oxy_end = 1;
        end

    case 'mfir_01'
        switch oopt
            case 'nispos'
                niskc = [1:2:23]';
                niskn = [9002 8149 9006:2:9024]'; %25000NNNN
            case 'botflags'
                switch stnlocal
                    case 2
                        niskin_flag(position==7) = 4; %not closed correctly
                    otherwise
                end
        end
        
    case 'msal_01'
        switch oopt
            case 'sal_off'
                sal_off = [
                    000 -1
                    001 -4
                    002 -6
                    003 -2
                    004 +3
                    005 +2
                    006 +3
                    007 -1
                    008 +4
                    009 +1
                    010 +1
                    011 +2
                    012 +1
                    013 +1
                    014 +2
                    015 +5
                    016 +6
                    017 +5
                    018 +6
                    019 +2
                    020 +6
                    021 +5
                    022 +5
                    023 +3
                    ];
                sal_off(:,1) = sal_off(:,1)+999e3;
                sal_off(:,2) = sal_off(:,2)*1e-5;
                sal_off_base = 'sampnum_run';
case 'tsgsampnum'
tsg.sampnum = dsu.sampnum;
tsg.dnum = datenum(num2str(tsg.sampnum),'yyyymmddHHMM');
        end

    case 'mctd_02'
        switch oopt
            case 'raw_corrs'
                castopts.oxyhyst.H1 = {-0.038 -0.033};
                castopts.oxyhyst.H2 = {5000    5000};
                castopts.oxyhyst.H3 = {4000   4000};
                h3tab1 =[
                    -10 500
                    2000 500
                    2001 3000
                    9000 3000
                    ];
                h3tab2 =[
                    -10 500
                    2000 500
                    2001 3000
                    9000 3000
                    ];

                castopts.oxyhyst.H3{1} = interp1(h3tab1(:,1),h3tab1(:,2),d.press);
                iib = find(isnan(d.press)); iig = find(~isnan(d.press));
                if ~isempty(iib); castopts.oxyhyst.H3{1}(iib) = interp1(iig,castopts.oxyhyst.H3{1}(iig),iib); end
                castopts.oxyhyst.H3{2} = interp1(h3tab2(:,1),h3tab2(:,2),d.press);
                iib = find(isnan(d.press)); iig = find(~isnan(d.press));
                if ~isempty(iib); castopts.oxyhyst.H3{2}(iib) = interp1(iig,castopts.oxyhyst.H3{2}(iig),iib); end
            case 'ctdcals'
                castopts.docal.temp = 1;
                castopts.docal.cond = 1;
                castopts.docal.oxygen = 1;

                castopts.calstr.temp1.dy146 = 'dcal.temp1 = d0.temp1 + interp1([-10 0 2000 4500 6000],[ 5  5  5 0 0]/1e4,d0.press);';
                castopts.calstr.temp2.dy146 = 'dcal.temp2 = d0.temp2 + interp1([-10 0 2000 4500 6000],[-4 -4 -4 4 4]/1e4,d0.press);';
                calms = 'from comparison with SBE35, stations 1-25 (all)';
                castopts.calstr.temp1.msg = calms;
                castopts.calstr.temp2.msg = calms;

                castopts.calstr.cond1.dy146 = 'dcal.cond1 = d0.cond1.*(1 + interp1([-10 0 500 1000 2000 3500 4500 8000],1*[-12 -12   0  10 18 4 -5 -5]/1e4,d0.press)/35);';
                castopts.calstr.cond2.dy146 = 'dcal.cond2 = d0.cond2.*(1 + interp1([-10 0 500 1000 2000 3500 4500 8000],1*[-35 -35 -17  -6  6 2 -5 -5]/1e4,d0.press)/35);';
                calms = 'from comparison with bottle salinity, stations 1-25 (all)';
                castopts.calstr.cond1.msg = calms;
                castopts.calstr.cond2.msg = calms;

                castopts.calstr.oxygen1.dy146 = ['dcal.oxygen1 = d0.oxygen1.*'...
                    'interp1([-10      0    1000    3000  5400   6000],[1.027 1.027  1.033   1.038 1.055 1.055],d0.press).*'...
                    'interp1([1 5 25],[0.988 1 1],d0.statnum);'];
                castopts.calstr.oxygen2.dy146 = ['dcal.oxygen2 = d0.oxygen2.*'...
                    'interp1([-10      0    1000    3000  5400   6000],[1.045 1.045  1.052   1.062 1.075 1.075],d0.press).*'...
                    'interp1([1 5 25],[.992  1 1],d0.statnum);'];
                calms = 'from comparison with bottle oxygens, stations 1-25 (all)';
                castopts.calstr.oxygen1.msg = calms;
                castopts.calstr.oxygen2.msg = calms;

        end
        %%%%%%%%%% mctd_03 %%%%%%%%%%
    case 'mctd_03'
        switch oopt
            case 's_choice'
                stns_alternate_s = [1:8 10:99]; % station 9 has a big gap on the secondary cells on downcast
            case 'o_choice'
                stns_alternate_o = [1:8 10:99];
        end
        %%%%%%%%%% end mctd_03 %%%%%%%%%%

    case 'moxy_01'
        switch oopt
            case 'oxy_files_parse'
                clear ofiles
                ofiles = {'oxygen_calculation_newflasks_dy146.xlsx'};
                sheets = 1:30; %ok if this is longer than number of data sheets
                chrows = 1:2;
                chunits = 3;
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
                    'bot_vol_tfix'   'botvol_at_tfix'
                    'conc_o2',       'c_o2_'}; %not including conc_o2, recalculating instead
            case 'oxycalcpars'
if 0
                [num,~,raw] = xlsread(fullfile(mgetdir('M_BOT_OXY'),'Logsheet-Blanks&Standards_DY146.xlsx'));
                num = [NaN+zeros(2,size(num,2)); num];
                ii1 = find(strncmp('After bubbles',raw(:,4),13));
                iib = find(strncmp('B',raw(1:size(num,1),1),1) & ~isnan(num(:,2)) & ~isnan(num(:,3))); 
                iib = iib(iib>ii1);
                bl = num(iib,2:5); %bll = raw(iib,1);
                bl_av = bl(:,1)-(bl(:,2)+bl(:,3))/2;
                bl_av(isnan(bl(:,3))) = NaN;
                bl(bl(:,4)==bl_av,4) = NaN;
                bl_av_all = bl(:,1)-m_nanmean(bl(:,2:4),2);
                bl_av_all(isnan(bl_av)) = NaN;
                gb = abs(round(bl_av_all*1e4)/10)<=4;
                blank = mean(bl_av_all(gb));
                iis = find(strncmp('S',raw(1:size(num,1),8),1) & ~isnan(num(:,9))); iis = iis(iis>ii1);
                st = num(iis,9); %stl = [raw(iis7,7); raw(iis8,8)];
                m = st<0.48 & st>=0.47;
                disp([blank sum(gb)/sum(~isnan(bl_av_all))*100 mean(st(m)) std(st(m))/mean(st(m)) sum(m)/sum(~isnan(st))*100])
    end
ds_oxy.blank_titre = repmat(0.003,size(ds_oxy.sampnum,1),1);
ds_oxy.std_titre = repmat(0.4735,size(ds_oxy.sampnum,1),1);            
ds_oxy.std_titre(ismember(ds_oxy.statnum,3:5)) = 0.4725;
ds_oxy.std_titre(ismember(ds_oxy.statnum,6:22)) = 0.475;
ds_oxy.std_titre(ismember(ds_oxy.statnum,23:25)) = 0.4765;
vol_reag_tot = 1.97;
case 'oxyflags'
m = ismember(d.sampnum,[109 201 209 211 605 1201]);
d.botoxya_flag(m) = max(d.botoxya_flag(m),3);
d.botoxyb_flag(m) = max(d.botoxyb_flag(m),3);
d.botoxyc_flag(m) = max(d.botoxyc_flag(m),3);
end

           %%%%%%%%%% best_station_depths %%%%%%%%%%
 case 'best_station_depths'
        switch oopt
            case 'depth_source'
                depth_source = {'ctd'};
            case 'bestdeps'
                %only for stations where we can't use ctd+altimeter
                replacedeps = [
                    1 4864 % from singleb bathy, interpolated onto bottom time from dcs
                    2 5042
                    3 5089
                    4 4993
                    5 4497
                    6 3009
                    7 1998
                    8 1441
                    9 2703
                    10 2763
                    11 2833
                    12 2906
                    13 2976
                    14 3088
                    15 3184
                    16 3235
                    17 3295
                    18 3333
                    19 3236
                    20 3153
                    21 1440
                    22 1439
                    23 1103
                    24 4442
                    25 4240
                    ];
        end

          %%%%%%%%%% station_summary %%%%%%%%%%
  case 'station_summary'
        switch oopt
            case 'sum_varsam'
                snames = {'nsal'; 'noxy'; 'nnut_shore'; 'nco2_shore'; 'nchl_shore'; 'ndoc_shore'}; %s suffix for variables not analysed on ship at all
                sgrps = { {'botpsal'}
                    {'botoxy'} %list of oxy variables
                    {'silc' 'phos' 'totnit'} %list of nuts variables
                    {'dic' 'alk' 'ph'} %list of co2 variables
                    {'botchla'} %
                    {'doc'} % 
                    };
        end


        %%%%%%%%%% msam_ashore_flag %%%%%%%%%%
    case 'msam_ashore_flag'
        switch oopt
            case 'sam_ashore_all'
                fnin = [mgetdir('M_BOT_ISO') '/dy146_ashore_samples_log.csv'];
                ds_shore = dataset('File',fnin,'Delimiter',','); %csv file including text comments
                ds_shore.sampnum = ds_shore.CTDCast*100+ds_shore.Niskin;
                varnames_fields = {
                    'silc' 'nuts_nsamp'
                    'phos' 'nuts_nsamp'
                    'totnit' 'nuts_nsamp'
                    'botchla' 'ph_nsamp'
                    'dic' 'dic_nsamp'
                    'doc' 'doc_nsamp'
                    'ph' 'ph_nsamp'
                    };
                flagvars = varnames_fields(:,1);
                flagvals = 1;
                sampnums = cell(length(flagvars),length(flagvals));
                for fno = 1:length(flagvars)
                    issamp = ds_shore.(varnames_fields{fno,2})>0;
                    sampnums(fno,1) = {ds_shore.sampnum(issamp)};
                end
        end
        %%%%%%%%%% end msam_ashore_flag %%%%%%%%%%
        
        %%%%%%%%%% mout_exch %%%%%%%%%%
    case 'mout_exch'
        switch oopt
            case 'woce_expo'
                expocode = '74EQ20220209';
                sect_id = 'RAPID-East';
            case 'woce_vars_exclude'
                vars_exclude_ctd = {};
                %vars_exclude_sam = {'upsal_flag'; 'uoxygen_flag'};
            case 'woce_ctd_headstr'
                headstring = {['CTD,' datestr(now,'yyyymmdd') 'OCPNOCYLF'];...
                    '#SHIP: Discovery';...
                    '#Cruise DY146; RAPID Eastern Boundary';...
                    '#Region: Eastern North Atlantic (subtropical)';...
                    ['#EXPOCODE: ' expocode];...
                    '#DATES: 20220209 - 20220309';...
                    '#Chief Scientist: D. G. Evans, NOC';...
                    %'#Supported by NERC National Capability NE/N018095/1 (ORCHESTRA)';...
                    '#25 stations with 12-place rosette';...
                    '#CTD: Who - B. King; Status - final';...
                    '#The CTD PRS; TMP; SAL; OXY data are all calibrated and good.';...
                    '# DEPTH_TYPE   : COR';...
                    %'#These data should be acknowledged with: "Data were collected and made publicly available by the international Global Ship-based Hydrographic Investigations Program (GO-SHIP; http://www.go-ship.org/) with National Capability funding from the UK Natural Environment Research Council to the National Oceanography Centre and the British Antarctic Survey."'};
                    };
            case 'woce_sam_headstr'
                headstring = {['BOTTLE,' datestr(now,'yyyymmdd') 'OCPNOCYLF'];... %the last field specifies group, institution, initials
                    '#SHIP: Discovery';...
                    '#Cruise DY146; RAPID Eastern Boundary';...
                    '#Region: Eastern North Atlantic (subtropical)';...
                    ['#EXPOCODE: ' expocode];...
                    '#DATES: 20220209 - 20220309';...
                    '#Chief Scientist: D. G. Evans, NOC';...
                    %'#Supported by NERC National Capability NE/N018095/1 (ORCHESTRA)';...
                    '#25 stations with 12-place rosette';...
                    '#CTD: Who - B. King; Status - final';...
                    '#Notes: Includes CTDSAL, CTDOXY, SBE35';...
                    '#The CTD PRS; TMP; SAL; OXY data are all calibrated and good.';...
                    '#Salinity: Who - B. King; Status - final';...
                    '#Oxygen: Who - Y. Firing and B. King; Status - final';...
                    '#Nutrients: Who - E. Mawji; Status - not yet analysed';...
                    '#Carbon: Who - P. Brown; Status - not yet analysed';...
                    %'#These data should be acknowledged with: "Data were collected and made publicly available by the international Global Ship-based Hydrographic Investigations Program (GO-SHIP; http://www.go-ship.org/) with National Capability funding from the UK Natural Environment Research Council to the National Oceanography Centre and the British Antarctic Survey."'};
                    };
        end
        %%%%%%%%%% end mout_cchdo %%%%%%%%%%


end
