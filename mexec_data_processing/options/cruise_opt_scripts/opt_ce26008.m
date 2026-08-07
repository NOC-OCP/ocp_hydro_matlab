%cast 42 aborted and not converted or processed
%other aborted casts that can be processed: 1, 

switch opt1
    
    case 'setup'
        switch opt2
            case 'time_origin'
                MEXEC_G.MDEFAULT_DATA_TIME_ORIGIN = [2026 1 1 0 0 0];
            case 'm_stn_string'
                if stn == 25.1
                    stn_string = '025b';
                end
        end

    case 'ctd_proc'
        switch opt2
            case 'ctdfiles'
                cnvfile = fullfile(MEXEC_G.MDIRLIST.M_CTD_CNV,[upper(mcruise) '_' stn_string '.cnv']);
            case 'ctd_raw_extra'
                if stn==22
                    %add time since it was not exported
                    extravars = {'time'; 'seconds since 2026-07-28 15:41:17'};
                    extrasource = {'d.time = d0.scan/24+0;'};
                end
            case 'cast_split_comb'
                comb_stns = [25.1 25 154152];
            case 'header_edits'
                h.comment = replace(h.comment,'PSO: Caroline Cusack','PSO: Yvonne Firing');
                m_write_header(otfiles{1},h);
            case 'rawedit_auto'
                %use rangelim first to exclude very large spikes
                co.rangelim.press = [-1.25 3300]; 
                co.rangelim.cond = [3 5];
                co.rangelim.temp = [-2 18];
                co.rangelim.oxy = [120 300];
                co.rangelim.turbidity = [0 1];
                co.rangelim.fluor = [0 8];
                %then despike with 2 repetitions of a 12-scan median
                %despiker
                co.despike.press = [2 12; 2 12]; %avg 1m/s so 2 dbar/0.5 s is large
                co.despike.temp1 = [0.5 12; 0.5 12];
                co.despike.cond1 = [0.02 12; 0.02 12]; 
                co.despike.oxy1 = [3 12; 3 12];
                co.despike.temp2 = co.despike.temp1;
                co.despike.cond2 = co.despike.cond1;
                co.despike.oxy2 = co.despike.oxy1;
                %mask some bad scan ranges
                if stnlocal==39
                    co.badscan.oxy1 = [4.92 17.602]*1e4; 
                end
                %then mask all on CTD whenever P is bad
                co.badpress.temp1 = [NaN NaN];
                co.badpress.temp2 = [NaN NaN];
                co.badpress.cond1 = [NaN NaN];
                co.badpress.cond2 = [NaN NaN];
                co.badpress.oxy1 = [NaN NaN];
                co.badpress.oxy2 = [NaN NaN];
                %when there is a pressure spike, everything is likely to be
                %bad
                co.badpress.turbidity = [NaN NaN];
                co.badpress.transmittance = [NaN NaN];
                co.badpress.fluor = [NaN NaN];
                co.badpress.par = [NaN NaN];
            case 'raw_corrs'
                co.oxy_align = 0; %0 until we check oxygen hysteresis
            case 'rawshow'
                yl.temp = [0 18]; yl.cond = [3 5]; yl.oxy = [120 300];
                yl.press = [-1 3200];
                yl.press = [-1 ceil(d.press(ddcs.dc24_bot)/100)*100+10];
                yl.fluor = [0 8];
                if stnlocal>40
                    yl.temp = [-2 10]; yl.cond = [2.5 4.5]; yl.oxy = [200 380];
                    yl.fluor = [0 4];
                end
                yl.temp1 = yl.temp; yl.temp2 = yl.temp; 
                yl.cond1 = yl.cond; yl.cond2 = yl.cond;
                yl.oxy1 = yl.oxy; yl.oxy2 = yl.oxy;
            case 'sensor_choice'
                ts_choice = 2;
                o_choice = 2;
            case 'niskfilename'
                blinfile = fullfile(MEXEC_G.MDIRLIST.M_CTD_BOT,sprintf('%s_%s.bl',upper(mcruise),stn_string));
            case 'botflags'
                niskin_flag(position==3) = 4; %latch does not release
                f = readtable(fullfile(MEXEC_G.MDIRLIST.M_CTD,'niskin_flags_logged_ce26008.csv'),'Delimiter',',');
                f = f(f.statnum==stnlocal,:);
                [~,ia,ib] = intersect(position,f.position,'stable');
                niskin_flag(ia) = f.niskin_flag(ib);
        end


    case 'sbe35'
        switch opt2
            case 'sbe35files'
                sbe35in = fullfile(MEXEC_G.MDIRLIST.M_SBE35,sprintf('%s_*.txt', upper(mcruise)));
                %stnind is indices in filename sbe35file normally
                %containing the station number; use negative to indicate
                %distance from end e.g. [-6:-4] for dy113_SBE35_CTD_010.asc
                stnind = -6:-4;
            case 'sbe35_parse'
                %deal with combined file(s)
                if strcmp(file_list{kf},'CE26008_002_003.txt')
                    m = t.datnum<datenum(2026,7,24,10,0,0);
                    t.statnum(m) = 2;
                elseif strcmp(file_list{kf},'CE26008_005_006_007.txt')
                    m = t.datnum<datenum(2026,7,25,5,0,0);
                    t.statnum(m) = 5;
                    m = t.statnum==7 & t.datnum<datenum(2026,7,25,9,0,0);
                    t.statnum(m) = 6;
                end
        end

    case 'samp_proc'
        switch opt2
            case 'files'
                uway_sample_log_file = fullfile(MEXEC_G.MDIRLIST.M_BOT,'uway_sample_log.csv');
                switch samtyp
                    case 'ulog'
                    case 'chl'
                    case 'oxy'
                        files = {fullfile(MEXEC_G.MDIRLIST.M_BOT_OXY,'20260728_Oxygen_concentration_calculation_worksheet_2025.xlsx')};
                        sopts.numhead = 9; 
                        ct = {'statnum','double';...
                            'position','double';...
                            'd','char';...
                            'botno','char';...
                            'botvol25','double';...
                            'blank_titre','double';...
                            'vol_std','double';...
                            'std_titre','double';...
                            'fix_temp','double';...
                            'bot_vol_tfix','double';...
                            'sample_titre','double';...
                            'iodatemol','double';...
                            'n_o2','double';...
                            'conc_o2','double';...
                            'notes','char'};  
                        sopts.VariableNames = ct(:,1)';
                        sopts.VariableTypes = ct(:,2)';
                        sopts.sheets = 1:15;
                    case 'sal'
                        files = dir(fullfile(MEXEC_G.MDIRLIST.M_BOT_SAL,'portasal*.csv'));
                    case 'nut'
                    case 'co2'
                    case 'cfc'
                    case 'doc'
                    case 'iso'
                end
            case 'parse'
                switch samtyp
                    case 'sal'
                        ssw_k15 = 0.99983;
                        ssw_batch = 'P169';
                    case 'oxy'
                        sdata.flag = 1+ones(size(sdata.statnum));
                        m = ~cellfun('isempty',sdata.notes);
                        sdata.flag(m) = 5; %not reported
                        sdata.sample_titre(m) = NaN;
                        sdata.conc_o2(m) = NaN;
                        sdata.sampnum = sdata.statnum*100+sdata.position;
                        sdata(:,ismember(sdata.Properties.VariableNames,{'botno','botvol25','notes','statnum','position'})) = [];
                end
            case 'calc'
                switch samtyp
                    case 'sal'
                        %salin_off = -1.5e-5; %constant
                    case 'oxy'
                end
            case 'check'
                checksam.sbe35 = 0;
                checksam.sal = 1; %done
                checksam.oxy = 1; %done
                checksam.chl = 0;
            case 'flags' %flags before replicate averaging and after replicate averaging***
                switch samtyp
                    case 'sal'
                        % m = ismember(ds_sal.sampnum,[1403 1406 1408 1501]);
                        % ds_sal.flag(m) = 4;
                    case 'oxy'
                        %sampnum, a flag, b flag, c flag
                        % flr = [...
                        %     %2703 3 3 9; ...
                        %     ];
                        % [~,ifl,id] = intersect(flr(:,1),d.sampnum);
                        % d.botoxya_flag(id) = max(d.botoxya_flag(id),flr(ifl,2));
                        % d.botoxyb_flag(id) = max(d.botoxyb_flag(id),flr(ifl,3));
                        % d.botoxyc_flag(id) = max(d.botoxyc_flag(id),flr(ifl,4));
                        % % outliers relative to profile/CTD (not replicates)
                        % flag4 = [1207 ]';
                        % d.botoxya_flag(ismember(d.sampnum,flag4)) = 4;
                        % flag4b = [1501 ]; %both a and b high, maybe bad niskin closure
                        % d.botoxya_flag(ismember(d.sampnum,flag4b)) = 4;
                        % d.botoxyb_flag(ismember(d.sampnum,flag4b)) = 4;
                end
        end

    case 'adcp_proc'
        cfg.rawdir = fullfile(MEXEC_G.MDIRLIST.M_LADCP,'rawdata');
        cfg.uppat = sprintf('UL%s00*s.000',cfg.stnstr);
        cfg.dnpat = sprintf('DL%s00*m.000',cfg.stnstr);
        if stnlocal==6
            cfg.uppat = sprintf('UL%s00*m.000',cfg.stnstr);
            cfg.dnpat = sprintf('DL%s00*s.000',cfg.stnstr);
        %elseif stnlocal==2
        %    cfg.uppat = 'UL001001s.000';
        %    cfg.dnpat = 'DL001001m.000';
        %    cfg.f.ctd = fullfile(MEXEC_G.MDIRLIST.M_LADCP, 'ctd', ['ctd.' stn_string '.02.asc']);
        end
        %set magnetic declination here, rather than using either of the two
        %options built in to LDEO_IX/loadnav
        %[p, f, ext] = fileparts(cfg.f.ctd); y0 = MEXEC_G.MDEFAULT_DATA_TIME_ORIGIN(1);
        a = {dbstack(2).file}; 
        if ~strcmp(a{1},'mout_1hzasc.m') %bash script uses the output of mout_1hzasc so don't want to try to call this before that
            mdfile = fullfile(MEXEC_G.MDIRLIST.M_LADCP,'magdec.txt');
            if ~exist(mdfile,'file')
                fprintf(1,'in terminal, run the following:\nbash /data/pstar/programs/repos_github/mexec_exec/run_pyIGRF.sh\nthen enter to continue (here)')
                pause
            end
            md = load(mdfile);
            if ~sum(md==stnlocal)
                fprintf(1,'in terminal, run the following:\nbash /data/pstar/programs/repos_github/mexec_exec/run_pyIGRF.sh\nthen enter to continue (here)')
                pause
                md = load(mdfile);
            end
            ii = find(md==stnlocal); 
            if isempty(ii)
                warning('no mag dec for %s',stn_string)
            else
                ii = ii(1);
                cfg.p.drot = md(ii+1);
                fprintf(1,'using mag dec %f for %s',cfg.p.drot,stn_string)
            end
        end

    case 'uway_proc'
        switch opt2
            case 'scs_skip'
                skip = [skip, {'elg','ZDA','VBW','Ship-Speed-Log','uway.csv'}];%***need to add VBW to nmea and nmeau in load_uway_ascii.m (also for ship-speed-log)
            case 'scs_nmea_custom'
                if strncmp(files{fno},'Fluor',5)
                    vn = {'date','time','fluo_msg'};
                    vu = {'mm/dd/yyyy','HH:MM:SS.SSS','special'};
                    delim = ',';
                    inform = 'ddMMyyyy HHmmss';
                elseif strncmp(files{fno},'SBE21',5)
                    vn = {'datetime','psal','temp','m0','m1','sspd'};
                    vu = {'MM/dd/yyyy,HH:mm:ss.SSS,','psu','degrees C','unknown','unknown','m/s'};
                    delim = []; %fixed width, no delim
                    inform = 'MM/dd/yyyy,HH:mm:ss.SSS,';
                end
            case 'uway_ascii_parse'
                m = strcmp(t.Properties.VariableNames,'fluo_msg');
                if sum(m)
                    t.fluo = cellfun(@(x) str2double(x(strfind(x,'=')+1:end)), t.fluo_msg);
                    t.Properties.VariableUnits{strcmp(t.Properties.VariableNames,'fluo')} = 'unknown';
                end
            case 'tstep_save'
                stepfreq_force = 1; %subsample to 1 Hz before saving
            case 'uway_load_extra'
                disp('loading the CE_DefaultUnderwayLog*.elg files')
                f = dir(fullfile(MEXEC_G.mexec_data_root,'scs_ascii','scs_events_descriptions','CE_DefaultUnderwayLog*.elg'));
                d = {f(cellfun(@(x) x>153,{f.bytes})).folder};
                f = {f(cellfun(@(x) x>153,{f.bytes})).name};
                uway_extra = readtable(fullfile(d{1},f{1}),'FileType','delimitedtext');
                for no = 2:length(f)
                    uway_extra = [uway_extra; readtable(fullfile(d{no},f{no}),'FileType','delimitedtext')];
                end
                uway_extra.DateTime = uway_extra.Date+uway_extra.Time; uway_extra = uway_extra(:,3:end);
                uway_extra.SeapathLatitude = cellfun(@(x) str2double(x(1:end-1)),uway_extra.SeapathLatitude);
                uway_extra.SeapathLongitude = cellfun(@(x) -str2double(x(1:end-1)),uway_extra.SeapathLongitude);
                save(fullfile(MEXEC_G.MDIRLIST.M_UWAY_RAW,'..','uway_scs_10s'),'uway_extra')
     
        end

    case 'outputs'
        switch opt2
            case 'summary'
                snames = {'nsal' 'noxy' 'nnut' 'nco2'};
                sgrps = {{'botpsal'} {'botoxy'} {'silc' 'phos' 'totnit'} {'dic' 'talk' 'ph'}};
            % case 'sam_shore'
            %     fnin = fullfile(mgetdir('M_CTD'),'BOTTLE_SHORE', 'DY181 Samples for Onshore Analysis - DIC.xlsx');
            %     varmap.statnum = {'CTDNumber'};
            %     varmap.position = {'Niskin'};
            %     varmap.dic = {'N_DICSamples'};
            %     varmap.talk = {'N_DICSamples'};
            case 'exch'
                ns = 35;
                expocode = '54CE20260723';
                sect_id = 'AR7E; AR07E';
                submitter = 'OCPNOCYLF'; %group institution person
                common_headstr = {'#SHIP: RV Celtic Explorer';...
                    '#Cruise CE26008; GO-SHIP AR7E 2026';...
                    '#Region: subpolar north Atlantic';...
                    ['#EXPOCODE: ' expocode];...
                    '#DATES: 20260723 - 20260811';...
                    '#Chief Scientist: Y. Firing (NOC); Co-Chief Scientist: M. Clark (NOC)';...
                    '#Supported by ...'};
                    if strcmp(params.in,'ctd')
                    headstring = {['CTD,' datestr(now,'yyyymmdd') submitter]};
                    headstring = [headstring; common_headstr;
                        {sprintf('#%d stations with 24-place rosette',ns);...
                        % '#CTD: Who - Y. Firing (NOC); Status - final.';...
                        % '#The CTD PRS; TMP; SAL; OXY data are all calibrated and good.';...
                        % '# DEPTH_TYPE   : COR';...
                        % '# DEPTH_TYPE   : rosette depth from CTDPRS + CTD altimeter range to bottom, or speed of sound-corrected ship-mounted bathymetric echosounder'...
                        }];
                    else
                        headstring = {['BOTTLE,' datestr(now,'yyyymmdd') submitter]};
                        headstring = [headstring; common_headstr;
                            {sprintf('#%d stations with 24-place rosette',ns);...
                        % '#CTD: Who - Y. Firing (NOC); Status - final';...
                        % '#Notes: Includes CTDSAL, CTDOXY, CTDTMP';...
                        % '#The CTD PRS; TMP; SAL; OXY data are all calibrated and good.';...
                        % '# DEPTH_TYPE   : rosette depth from CTDPRS + CTD altimeter range to bottom';...
                        % '#Salinity: Who - Y. Firing (NOC); Status - final; SSW batch P168.';...
                        % '#Oxygen: Who - R. Abell (SAMS); Status - final.';...
                        % '#Nutrients: Who - R. Abell (SAMS); Status - preliminary.';...
                        % '#DIC and Talk: Who - C. Johnson (SAMS); Status - not yet analysed.';...
                        }];
                end
            case 'section_for_station'
                if stnlocal>=4 && stnlocal<88
                    sections = {'ar7e'};
                end
            case 'grid'
                sam_gridlist = {'botoxy' 'silc' 'phos' 'totnit' 'botpsal'};
                mgrid.sdata_flag_accept = [2 3]; %***or just 2
                if contains(section,'ar7e')
                    kstns = [4:50];
                    mgrid.xlim = 2; mgrid.zlim = 4;
                else
                    section = 'profiles_only';
                    kstns = 1:999; %useful to do profiles_only for all stations anyway (smooth in vertical)
                end
        end


end



