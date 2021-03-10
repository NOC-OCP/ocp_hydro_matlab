switch scriptname
    
    %%%%%%%%%% castpars (not a script) %%%%%%%%%%
    case 'castpars'
        switch oopt
            case 'shortcasts'
                shortcasts = [1 2 6 7 11 14 17:29 61];
            case 'oxy_align'
                oxy_end = 1;
        end
        %%%%%%%%%% end castpars (not a script) %%%%%%%%%%
        
        
        %%%%%%%%%% mbot_01 %%%%%%%%%%
    case 'mbot_01'
        switch oopt
            case 'nispos'
                niskin = [9002 9003 8149 9005 9006 9007 9008 ...
                    9009 9010 8156 9012 9013 9014 9015 9016 9017 ...
                    9018 9019 9020 9021 9022 9023 9024 9025]; %25000NNNN
            case 'botflags'
                niskin_flag(ismember(statnum,[3 4 7 9 46 49]) & position==3) = 4; %bottom endcap not closed
                niskin_flag(ismember(statnum,[10 18 19 21 37 45 60 65 71 73 80]) & position==10) = 4; %did not seal or leaked
                niskin_flag(statnum==21 & position==9) = 4; %bottom end cap did not seal
                niskin_flag(ismember(sampnum, [5503 7416 8016])) = 3; %leaked from bottom end cap after sampling
        end
        %%%%%%%%%% end mbot_01 %%%%%%%%%%
        
        %%%%%%%%%% mctd_02b %%%%%%%%%%
    case 'mctd_02b'
        switch oopt
            case 'raw_corrs'
                tempcal = 1; 
                condcal = 1;
                oxygencal = 1;
            case 'oxyhyst'
                h3tab =[
                    -10 700
                    1000 700
                    1001 1000
                    2500 1000
                    2501 1450
                    9000 1450];
                H3 = interp1(h3tab(:,1),h3tab(:,2),d.press);
                iib = find(isnan(d.press)); iig = find(~isnan(d.press));
                H3(iib) = interp1(iig,H3(iig),iib); %***
            case 'ctdcals'
                    calstr = {
                        'dcal.temp1 = d0.temp1 - 0.001;'
                        'dcal.temp2 = d0.temp2 - 0.0005*d0.press/4000;'
                        };
                    calms = 'from comparison with SBE35, stations 1-65';
                    calmsg = {
                        'temp1 jc211' calms
                        'temp2 jc211' calms
                        };
                    % Original estimate
                    %    'dcal.cond1 = d0.cond1.*(1 + interp1([-10 0  4000  8000],(1.0*[0.0 0.0 -2.0 -4.0 ] - 0.5)/1e3,d0.press)/35);'
                    %    'dcal.cond2 = d0.cond2.*(1 + interp1([-10 0  4000  8000],(1.0*[0.0 0.0 -1.0 -2.0 ] + 1.2)/1e3,d0.press)/35);'
                    if stnlocal <= 74  % revised estimate, original estimate didnt quite get deep part correct
                        % the correction below combined the original
                        % estimate with a small tweak, and is the total
                        % adjustment to be applied
                        calstr = [calstr;
                            'dcal.cond1 = d0.cond1.*(1 + interp1([-10 0  2500  5000  8000],(1.0*[0.0 0.0 -1.25  -1.0  -1.0 ] - 0.5)/1e3,d0.press)/35);'
                            'dcal.cond2 = d0.cond2.*(1 + interp1([-10 0  2500  5000  8000],(1.0*[0.0 0.0 -0.625 +0.25 +0.25 ] + 1.2)/1e3,d0.press)/35);'
                            ];
                    else  % add 0.001 to cond1 for stns 75 and following
                        % at end of cruise, add a ramped adjustment that
                        % ramps up between stns 75 and 90. Need the calstr
                        % to start with dcal.cond1 or dcal.cond2.
                        calstr = [calstr;
                            'dcal.cond1 = []; stnfac = (min(stnlocal,90)-75)/(90-75); dcal.cond1 = d0.cond1.*(1 + (stnfac*interp1([-10 0  1000  5000],(1*[-1.5 -1.5 -0.5 -0.5] - 0.0)/1e3,d0.press) + interp1([-10 0  2500  5000  8000],(1.0*[0.0 0.0 -1.25  -1.0  -1.0 ] + 0.5)/1e3,d0.press))/35);'
                            'dcal.cond2 = []; stnfac = (min(stnlocal,90)-75)/(90-75); dcal.cond2 = d0.cond2.*(1 + (stnfac*interp1([-10 0  1000  5000],(1*[-1.0 -1.0 -0.5 -0.5] - 0.0)/1e3,d0.press) + interp1([-10 0  2500  5000  8000],(1.0*[0.0 0.0 -0.625 +0.25 +0.25 ] + 1.2)/1e3,d0.press))/35);'
                            ];
                    end
                    calms = 'from comparison with bottle salinities, stations 3-73';
                    calmsg = [calmsg;
                        {'cond1 jc211' calms}
                        {'cond2 jc211' calms}
                        ];
                    calstr = [calstr;
                        'dcal.oxygen1 = d0.oxygen1.*interp1([0 2000 4000 5000],[1.03 1.04 1.043 1.042],d0.press);'
                        'dcal.oxygen2 = d0.oxygen2.*interp1([0 1500 4000 5000],[1.03 1.043 1.051 1.05],d0.press);'
                        ];
                    calms = 'from comparison with bottle oxygens, stations 3-39 and 62-95';
                    calmsg = [calmsg;
                        {'oxygen1 jc211' calms}
                        {'oxygen2 jc211' calms}
                        ];
        end
        %%%%%%%%%% end mctd_02b %%%%%%%%%%
        
        %%%%%%%%%% mctd_03 %%%%%%%%%%
    case 'mctd_03'
        switch oopt
            case 's_choice'
                stns_alternate_s = 74;
            case 'o_choice'
                stns_alternate_o = [63 74];
        end
        %%%%%%%%%% end mctd_03 %%%%%%%%%%
        
        %%%%%%%%%% mctd_rawedit %%%%%%%%%%
    case 'mctd_rawedit'
        switch oopt
            case 'rawedit_auto'
                revars = {'press' -1.495 8000
                    };
                if stnlocal==74
                    sevars = {'temp1' 1.13987e5 inf
                        'cond1' 1.13987e5 inf
                        'oxygen_sbe1' 1.13945e5 inf};
                elseif stnlocal==90
                    sevars = {'cond2' 88906 inf};
                elseif stnlocal==91
                    sevars = {'cond2' 83600 inf};
                end
        end
        %%%%%%%%%% end mctd_rawedit %%%%%%%%%%
        
        %%%%%%%%%% mfir_03 %%%%%%%%%%
    case 'mfir_03'
        switch oopt
            case 'fir_fill'
                %avi_opt = [0 121/24]-1/24; %average over 5 s to match .ros file used in BASproc
        end
        %%%%%%%%%% end mfir_03 %%%%%%%%%%
        
        %%%%%%%%%% msbe35_01 %%%%%%%%%%
    case 'msbe35_01'
        switch oopt
            case 'sbe35_datetime_adj'
                iibt = find(statnum<=10); %time was right but date was wrong for first 10 CTDs
                datnum(iibt) = datnum(iibt)+11;
        end
        %%%%%%%%%% end msbe35_01 %%%%%%%%%%
        
        %%%%%%%%%% msal_01 %%%%%%%%%%
    case 'msal_01'
        switch oopt
            case 'sal_off'
                sal_off = [
                    900  2
                    901  1
                    902  0
                    903 -1
                    904 -2
                    905  1
                    906 -2
                    907 -3
                    908 -4
                    909 -4
                    910 -4 % don't use the -7 suggested by the standard
                    911 -3
                    912  1
                    913 -1
                    914  0
                    915  1
                    916  1
                    917  1
                    918 -2
                    919 -2
                    920 -1
                    921  3
                    922  3
                    923  3
                    924  2
                    925  0
                    926  6
                    927  6
                    928  3
                    929  3
                    930  6
                    931  3
                    932  3
                    933  8
                    934  5
                    935  3
                    936  6
                    937  3
                    938  1
                    939  3
                    940  3
                    941  2
                    942  0
                    943  6
                    944 -3
                    945 -5
                    946 +2
                    947 +0
                    948 -2
                    949 +2
                    950 -2
                    951 -3
                    952 +2
                    953 -3
                    954 -5
                    955 -5
                    956 -1
                    957 -3
                    958 -5
                    959 +1
                    960 -6
                    961 -7
                    962 -2
                    963 -8
                    964 -9
                    ];
                sal_off(:,1) = sal_off(:,1)+999e3;
                sal_off(:,2) = sal_off(:,2)*1e-5;
                sal_off_base = 'sampnum_run';
        end
        %%%%%%%%%% end msbe35_01 %%%%%%%%%%
        
        %%%%%%%%%% moxy_01 %%%%%%%%%%
    case 'moxy_01'
        switch oopt
            case 'oxy_parse'
                chunits = 3;
                mvar_fvar = {
                    'statnum',       'cast_number'
                    'position',      'niskin_bottle'  
                    'vol_blank',     'blank_titre'   
                    'vol_std',       'std_vol'        
                    'vol_titre_std', 'standard_titre'
                    'fix_temp',      'fixing_temp'  
                    'sample_titre',  'sample_titre'   
                    'flag',          'flag' 
                    'oxy_bottle'     'bottle_no'
                    'bot_vol',       'bot_vol'
                    'date_titre',    'dnum'
                    }; %not including bot_vol_tfix or conc_o2, recalculating instead
            case 'oxy_parse_files'
                %extra flags for inter-machine comparison***temporary
                if sum(strcmp('notes',ds.Properties.VarNames))
                    ii = find(strncmp('ABC',ds.notes,3));
                    if length(ii)>0; ds.flag(ii) = ds.flag(ii)+10; end
                    ii = find(strncmp('CUSTARD',ds.notes,7));
                    if length(ii)>0; ds.flag(ii) = ds.flag(ii)+20; end
                end
                %analysis date and time (start)
                iic = strfind(hs.header,',');
                iia = strfind(hs.header, 'Analysis Date, '); iia = iic(iic>=iia(1));
                dat = hs.header(iia(1)+1:iia(2)-1); dat = replace(dat,whitespacePattern,'');
                iia = strfind(hs.header, 'Analysis Time, '); iia = iic(iic>=iia(1));
                tim = hs.header(iia(1)+1:iia(2)-1);
                if length(tim)>4
                    if isempty(str2num(tim(1:4)))
                        tim = tim([1 2 4 5]);
                    else
                        tim = tim(1:4);
                    end
                end
                ds.dnum = repmat(datenum([dat ' ' tim],'dd/mm/yy HHMM'),length(ds.cast_number),1);
                %bottle volumes
                ds_vol = dataset('File',[root_oxy '/flask_vols.csv'],'Delimiter',',');
                [~,ia,ib] = intersect(ds.bottle_no, ds_vol.Oxygen_bottle);
                ds.bot_vol = NaN+ds.bottle_no;
                ds.bot_vol(ia) = ds_vol.Vol(ib);
            case 'oxycalcpars'
                vol_reag_tot = 1.99;
                ds_oxy.vol_std(:) = 5;
                %load all blanks and standards records, average over runs
                %storing weights for later averaging
                ds_obs = dataset('File',[root_oxy '/log_blanks_standards.csv'],'Delimiter',',');
                ds_obs.blanks = NaN+ds_obs.reag_batch; ds_obs.stds = ds_obs.blanks;
                ds_obs.ns = zeros(size(ds_obs.stds)); ds_obs.nb = ds_obs.ns;
                for rno = 1:size(ds_obs,1)
                    data = str2num(ds_obs.data{rno});
                    ds_obs.dday(rno) = datenum([str2num(ds_obs.datevec{rno}) 0]) - datenum(2021,1,1);
                        switch ds_obs.type{rno}
                            case 'bl'
                                ds_obs.blanks(rno) = data(1)-mean(data(2:3));
                                ds_obs.nb(rno) = 2;
                            case 'std5'
                                ds_obs.stds(rno) = mean(data);
                                ds_obs.ns(rno) = length(data);
                            case 'stdc'
                                b = regress(data(2,:)',[ones(size(data,2),1) data(1,:)']);
                                ds_obs.blanks(rno) = b(1);
                                ds_obs.nb(rno) = size(data,2);
                                ds_obs.stds(rno) = b(2)*5;
                                ds_obs.ns(rno) = size(data,2);
                        end
                end
                %carpenter method better than standard-curve according to
                %go-ship manual. blanks on custard machine were bad (very
                %high), also most blanks run by epa were high (to a lesser
                %extent), likely under-stirred. assuming standards (and
                %samples) on custard machine were okay. 
                usevalb = strcmp('abc',ds_obs.machine_method) & ~strncmp('bad',ds_obs.comment,3) & strcmp(ds_obs.analyst,'ylf') & strcmp('bl',ds_obs.type);
                ds_obs.nb(usevalb==0) = 0; 
                usevals = ~strncmp('bad',ds_obs.comment,3) & strcmp('std5',ds_obs.type); %assuming standards (and samples) were good on both machines
                ds_obs.ns(usevals==0) = 0;
                %average over good standards for each batch of titrant.
                %for blanks, use average good values from abc because
                %reagents were made up all together, or apply different
                %blanks on different days to stations where this is
                %possible?
                dday_stn = [35 3; 50 40; 54 60; 65 100];
                for tno = 1:size(dday_stn,1)-1
                    iis = find(ds_oxy.statnum>=dday_stn(tno,2) & ds_oxy.statnum<dday_stn(tno+1,2));
                    iit = find(ds_obs.dday>=dday_stn(tno,1) & ds_obs.dday<dday_stn(tno+1,1) & ds_obs.nb>0);
                    ds_oxy.vol_blank(iis) = sum(ds_obs.blanks(iit).*ds_obs.nb(iit))/sum(ds_obs.nb(iit));
                    iit = find(ds_obs.dday>=dday_stn(tno,1) & ds_obs.dday<dday_stn(tno+1,1) & ds_obs.ns>0);
                    ds_oxy.vol_titre_std(iis) = sum(ds_obs.stds(iit).*ds_obs.ns(iit))/sum(ds_obs.ns(iit));
                end
                %ds_oxy.vol_titre_std(ds_oxy.statnum>=40 & ds_oxy.statnum<60) = ds_oxy.vol_titre_std(1);
                a = ds_oxy.vol_blank(ds_oxy.statnum==40);
                ds_oxy.vol_blank(ds_oxy.statnum<40) = a(1);
                ds_obs.blanks(strncmp('bad',ds_obs.comment,3)) = NaN;
                ds_obs.stds(strncmp('bad',ds_obs.comment,3)) = NaN;
            case 'oxyflags'
                %adjust back
                d.botoxya_flag(d.botoxya_flag>20) = d.botoxya_flag(d.botoxya_flag>20)-20;
                d.botoxyb_flag(d.botoxyb_flag>20) = d.botoxyb_flag(d.botoxyb_flag>20)-20;
                d.botoxya_flag(d.botoxya_flag>10) = d.botoxya_flag(d.botoxya_flag>10)-10;
                d.botoxyb_flag(d.botoxyb_flag>10) = d.botoxyb_flag(d.botoxyb_flag>10)-10;
                %duplicates differ by too much (>1 umol/L and they were run
                %on the same machine)
                iibd = [2003 6202 7904]; 
                d.botoxya_flag(ismember(d.sampnum,iibd)) = 3;
                d.botoxyb_flag(ismember(d.sampnum,iibd)) = 3;
                %questionable based on ctd comparison, although it could be samples are okay just in high gradient areas                %they're just in high gradient areas
                iiq = [401 409 413 801 805 1406 2809 3212 3815 7014 7812 9002];
                d.botoxya_flag(ismember(d.sampnum,iiq)) = 3; 
                %weird standards values, and bottle values are offset
                %relative to others
                iib = [2809 3113 3212];
                d.botoxya_flag(ismember(d.sampnum,iib) | (d.statnum>=40 & d.statnum<60)) = 4;
                %1406 possible bad niskin?
        end
        %%%%%%%%%% end moxy_01 %%%%%%%%%%
        

        %%%%%%%%%% mday_01_clean_av %%%%%%%%%%
    case 'mday_01_clean_av'
        switch oopt
            case 'pre_edit_uway'
                %on day 37-38 there was a 3-hour rvdas outage; patching
                %major streams with techsas data
                if day==37
                    tfill = 1;
                elseif day==38
                    tfill = 2;
                end
                if ismember(day,[37 38])
                    get_techsas_for_rvdas_gap
                end
        end
        %%%%%%%%%% end mday_01_clean_av %%%%%%%%%%
        
        %%%%%%%%%% mday_01_fcal %%%%%%%%%%
    case 'mday_01_fcal'
        switch oopt
            case 'uway_factory_cal'
                switch abbrev
                    case 'surfmet'
                        sensors_to_cal={'fluo';'trans';'parport';'tirport';'parstarboard';'tirstarboard'};
                        sensorcals={
                            'y=(x1-0.078)*13.5'; % fluorometer: s/n WS3S-134 cal 14 Jul 2020
                            'y=(x1-0.058)/(4.625-0.058)*100' %transmissometer: s/n CST-1132PR cal 24 Jun 2019
                            'y=x1/1.015' % port PAR: s/n 28556 cal 3 Sep 2019
                            'y=x1/1.073' % port TIR: 047463 cal 6 Jun 2019
                            'y=x1/0.9860' % stb PAR: s/n 28558 cal 3 Sep 2019
                            'y=x1/1.158'}; % stb TIR: 047362 cal 6 Jun 2019
                        % the surfmet instrument box is outputting in V*1e-5 for PAR/TIR already
                        sensorunits={'ug/l';'percent';'W/m2';'W/m2';'W/m2';'W/m2'};
                end
        end
        %%%%%%%%%% end mday_01_clean_av %%%%%%%%%%
        
        %%%%%%%%%% bathy (not a script) %%%%%%%%%%
    case 'bathy'
        switch oopt
            case 'bathy_grid'
                bfile = '/local/users/pstar/jc211/mcruise/data/bathy/gebco2014_jc211.mat';
                load(bfile); disp(bfile)
                clear top
                top.lon = gebco_jc211.lon;
                top.lat = gebco_jc211.lat;
                top.depth = gebco_jc211.depth;
        end
        %%%%%%%%%% end bathy (not a script) %%%%%%%%%%
        
        
        
        %%%%%%%%%% populate_station_depths %%%%%%%%%%
    case 'populate_station_depths'
        switch oopt
            case 'depth_source'
                depth_source = {'ladcp' 'ctd' 'bathy'}; %load from two-column text file, then fill with ctd press+altimeter, then with ea600
            case 'bestdeps'
                %                 replacedeps = [17 NaN];
            case 'depth_recalc'
                recalcdepth_stns = 1:999;
                stnmiss = [501 502];
        end
        %%%%%%%%%% end populate_station_depths %%%%%%%%%%
        
        %%%%%%%%%% msam_ashore_flag %%%%%%%%%%
    case 'msam_ashore_flag'
        switch oopt
            case 'sam_ashore_all'
                fnin = [mgetdir('M_BOT_ISO') '/jc211_ashore_samples_log.csv'];
                ds_iso = dataset('File',fnin,'Delimiter',','); %csv file including text comments
                ds_iso.sampnum = ds_iso.CTDCast*100+ds_iso.Niskin;
                varnames_fields = {'del18o' 'd18o_sample_number'
                    'silc' 'nuts_nsamp'
                    'phos' 'nuts_nsamp'
                    'totnit' 'nuts_nsamp'
                    'nh4' 'nuts_nsamp'
                    'del30si' 'siiso_nsamp'
                    'botchla' 'Chl_nsamp'};
                varnames = varnames_fields(:,1);
                flagvals = 1;
                for fno = 1:size(varnames_fields,1)
                    ii = find(ds_iso.(varnames_fields{fno,2})>0);
                    sampnums(fno,1) = {ds_iso.sampnum(ii)};
                end
                %POM, lugols?***
        end
        %%%%%%%%%% end msam_ashore_flag %%%%%%%%%%

        %%%%%%%%%% station_summary %%%%%%%%%%
    case 'station_summary'
        switch oopt
            case 'sum_stn_list'
                stnmiss = [501 502];
            case 'sum_varsams'
                snames = {'nsal'; 'noxy'; 'nnut_shore'; 'no18_shore'; 'nnis_shore'; 'npom_shore'; 'nchl_shore'};
                sgrps = {{'botpsal'} % salt
                    {'botoxya'} % oxygen
                    {'silc','phos','totnit','nh4'} % BAS nutrients
                    {'del18o'} % BGS del O 18
                    {'del30si'} % BAS silicate isotopes
                    {'lugols' 'pom'} % BAS POM and lugols samples, whatever those are
                    {'botchla'}}; % BAS chlorophyll
            case 'sum_extras'
                ewidth = 4; nwidth = 10; % each width must allow for one space to follow
                eventhead = [repmat(' ',1,ewidth) 'Ev '];  % event number and header are right justified in width ewidth
                eventhead = eventhead(end-ewidth+1:end);
                namehead = ['Waypoint' repmat(' ',1,nwidth)]; % waypoint name and header are left justified in width nwidth, with a space after, but truncated to nwidth
                namehead = [namehead(1:nwidth-1) ' '];
                namehead = namehead(1:nwidth);
                vars = [
                    {'eventnum' 'number' NaN eventhead 'special'}
                    {'statname' '' ' ' namehead 'special'} %***
                    vars
                    %{'comments' '' NaN 'Comments' '%s'}
                    ];
                [eventnum,statnamecell] = parse_ctd_event_name(stnall); % jc211, BAS western core box events
                statname = repmat(' ',length(stnall),nwidth);
            case 'sum_special_print'
                if strcmp(vars{cno,1},'eventnum')
                    svar = [repmat(' ',1,ewidth) sprintf('%03d ',eventnum(k))];
                    svar = svar(end-ewidth+1:end);
                elseif strcmp(vars{cno,1},'statname')
                    svar = [statnamecell{k} repmat(' ',1,nwidth)];
                    svar = svar(1:nwidth);
                    statname(k,:) = svar; %save
                end
        end
        %%%%%%%%%% end station_summary %%%%%%%%%%
        
        %%%%%%%%%% batchactions (not a script) %%%%%%%%%%
    case 'batchactions'            
        switch oopt
        end
        %%%%%%%%%% batchactions (not a script) %%%%%%%%%%
        
        %%%%%%%%%% set_cast_params_cfgstr %%%%%%%%%%
    case 'set_cast_params_cfgstr'
        switch oopt
            case 'ladcpopts' 
                p.ambiguity = 3.3;
                p.vlim = 3.3;
                p.down_sn = 24466;
                if stn < 61
                    p.up_sn = 24465;
                else
                    p.up_sn = 15288;
                end
                p.ctdmaxlag=10; % our times are really closely synced - as long as we use the correct time reference!
%                 ps.shear_weightmin=0.1; % default is 0.1 - EPA testing 20210224
%                 ps.shear_stdf = 5; % default is 2 - EPA testing 20210224
        end
        %%%%%%%%%% end set_cast_params_cfgstr %%%%%%%%%%
        
        %%%%%%%%%% mtsg_cleanup %%%%%%%%%%
    case 'mtsg_cleanup'
        switch oopt
            case 'tsg_badlims'
                kbadlims = [
                    datenum([2021 01 01 00 00 00]) datenum([2021 02 02 17 20 00]) % tsg flow off at start of cruise; TSG cleaned
                    datenum([2021 02 12 14 00 00]) datenum([2021 02 12 14 23 00]) % tsg flow off for cleaning Fl,Tr
                    datenum([2021 02 20 12 20 00]) datenum([2021 02 20 12 37 00]) % tsg flow off for cleaning Fl,Tr
                    datenum([2021 02 27 15 55 00]) datenum([2021 02 27 16 25 00]) % tsg flow off for cleaning Fl,Tr, TSG
                    datenum([2021 03 07 10 30 00]) datenum([2021 03 31 00 00 00]) % pumps off end of cruise
                    ];
        end
        %%%%%%%%%% end mtsg_cleanup %%%%%%%%%%
        
        %%%%%%%%%% mtsg_bottle_compare %%%%%%%%%%
    case 'mtsg_bottle_compare'
        switch oopt
            case 'tsg_usecal'
                usecal = 1;
            case 'tsg_timebreaks'
                tbreak = [
                    datenum([2021 2 20 12 30 00]) % pumps off Fl & Tr cleaned; TSG not cleaned
                    datenum([2021 2 27 16 10 00]) % Fl, Tr and TSG cleaned. Day 058/1610                  
                    ];
            case 'tsg_sdiff'
                sc1 = 0.5; sc2 = 0.01; %thresholds to use for smoothed series
        end
        %%%%%%%%%% end mtsg_bottle_compare %%%%%%%%%%
        
        %%%%%%%%%% tsgsal_apply_cal %%%%%%%%%%
    case 'tsgsal_apply_cal'
        switch oopt
            case 'tsgsaladj'
                root_tsg = mgetdir('tsg');
                fnsm = [root_tsg '/sdiffsm.mat'];
                if exist(fnsm,'file') ~= 2
                    t = [-1e9 ; 1e9];
                    sdiffsm = [0 ; 0];
                    save(fnsm,'t','sdiffsm')
                end
                if time==1 & salin==1
                    salout = 1;
                else
                    load([root_tsg '/sdiffsm'])
                    kbad = find(isnan(t+sdiffsm)); % bak jc211 remove any points where t or sdiffsm are nan
                    t(kbad) = [];
                    sdiffsm(kbad) = [];
                    salout = salin + interp1([-1e10 t(:)' 1e10],[sdiffsm(1) sdiffsm(:)' sdiffsm(end)],time/86400); % interpolate/extrapolate correction                end
                end
        end % check this
        %%%%%%%%%% end tsgsal_apply_cal %%%%%%%%%%
        
                %%%%%%%%%% msec_run_mgridp %%%%%%%%%%
    case 'msec_run_mgridp'
        switch oopt
            case 'sections'
                sections = {'sr1b' 'a23'};
            case 'ctd_regridlist'
                ctd_regridlist = [ctd_regridlist ' fluor transmittance'];
            case 'sec_stns'
                switch section
                    case 'sr1b'
                        kstns = [66:95];
                    case 'a23'
                        kstns = [36:65];
                end
            case 'varuse'
                varuselist.names = {'botpsal' 'botoxy'};
        end
        %%%%%%%%%% end msec_run_mgridp %%%%%%%%%%
        
        
        %%%%%%%%%% msec_plot_contrs %%%%%%%%%%
    case 'msec_plot_contrs'
        switch oopt
            case 'add_station_depths'
                crhelp_str = {'station_depth_width (default 0), if greater than 0, gives linewidth '
                    'for adding station depths to contour plots.'};
                station_depth_width = 0;
            case 'add_bottle_depths'
                crhelp_str = {'bottle_depth_size (default 0), if greater than 0, gives markersize '
                    'for adding bottle positions to contour plots.'};
                bottle_depth_size = 3;
        end
        %%%%%%%%%% end msec_plot_contrs %%%%%%%%%%

        %%%%%%%%%% mout_cchdo %%%%%%%%%%
    case 'mout_cchdo'
        switch oopt
            case 'woce_vars_exclude'
                vars_exclude_ctd = {};
            case 'woce_ctd_headstr'
                headstring = {['CTD,' datestr(now,'yyyymmdd') 'POGBASEPA'];...
                    '#SHIP: James Cook';...
                    '#Cruise JC211; SR1B and A23';...
                    '#Region: Drake Passage, Weddell Sea, Scotia Sea';...
                    ['#EXPOCODE: ' expocode];...
                    '#DATES: 20210202 - 20210307';...
                    '#Chief Scientist: E. P. Abrahamsen, BAS';...
                    '#Supported by NERC National Capability NE/N018095/1 (ORCHESTRA)';...
                    '#100 stations with 24-place rosette';...
                    '#Notes: PI for SR1B section (66-95): Y. Firing; PI for A23 section (36-65): E. P. Abrahamsen';...
                    '#CTD: Who - B. King and Y. Firing; Status - final';...
                    '#The CTD PRS; TMP; SAL; OXY data are all calibrated and good.';...
                    '# DEPTH_TYPE   : COR';...
                    '#These data should be acknowledged with: "Data were collected and made publicly available by the international Global Ship-based Hydrographic Investigations Program (GO-SHIP; http://www.go-ship.org/) with National Capability funding from the UK Natural Environment Research Council to the National Oceanography Centre and the British Antarctic Survey."'};
            case 'woce_sam_headstr'
                headstring = {['BOTTLE,' datestr(now,'yyyymmdd') 'POGBASEPA'];... %the last field specifies group, institution, initials
                    '#SHIP: James Cook';...
                    '#Cruise JC211; SR1B and A23';...
                    '#Region: Drake Passage, Weddell Sea, Scotia Sea';...
                    ['#EXPOCODE: ' expocode];...
                    '#DATES: 20210202 - 20210307';...
                    '#Chief Scientist: E. P. Abrahamsen, BAS';...
                    '#Supported by NERC National Capability NE/N018095/1 (ORCHESTRA)';... %***and wcb/poets
                    '#100 stations with 24-place rosette';...
                    '#Notes: PI for SR1B section (66-95): Y. Firing; PI for A23 section (36-65): E. P. Abrahamsen';...
                    '#CTD: Who - B. King and Y. Firing; Status - not yet calibrated';...
                    '#Notes: Includes CTDSAL, CTDOXY, SBE35';...
                    '#The CTD PRS; TMP; SAL; OXY data are all calibrated and good.';...
                    '#Salinity: Who - A. Marzocchi and B. King; Status - final';...
                    '#Notes: bottle salinity from stations 3-100 used for CTD calibration';...
                    '#Oxygen: Who - Y. Firing; Status - final';...
                    '#Notes: bottle oxygen from stations 3-39 and 60-95 used for CTD calibration';...
                    '#Notes: bottle oxygen stations 40-59 bad due to questionable titrant standardisation';...
                    '#Nutrients: Who - C. Liszka; Status - not yet analysed';...
                    '#DELO18: Who - M. Leng; Status - not yet analysed';...
                    '#Nutrient isotopes: Who - S. Fielding/K. Hendry; Status - not yet analysed';...
                    '#POM: Who - G. Stowasser - not yet analysed';...
                    '#Chlorophyll: Who - C. Liszka; Status - not yet analysed';...
                    '#These data should be acknowledged with: "Data were collected and made publicly available by the international Global Ship-based Hydrographic Investigations Program (GO-SHIP; http://www.go-ship.org/) with National Capability funding from the UK Natural Environment Research Council to the National Oceanography Centre and the British Antarctic Survey."'};
        end
        %%%%%%%%%% end mout_cchdo %%%%%%%%%%
        
end