%cast 42 aborted and not converted or processed

switch opt1
    
    case 'setup'
        switch opt2
            case 'time_origin'
                MEXEC_G.MDEFAULT_DATA_TIME_ORIGIN = [2026 1 1 0 0 0];
            case 'minit'
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
            case 'rawedit_auto'
                %use rangelim first
                co.rangelim.press = [-1.25 3300]; 
                co.rangelim.cond = [3 5];
                co.rangelim.temp = [-2 18];
                co.rangelim.oxy = [120 300];
                co.rangelim.turbidity = [0 1];
                co.rangelim.fluor = [0 8];
                %then despike
                co.despike.press = [10 10];
                co.despike.temp1 = [1 1]; co.despike.cond1 = [0.2 0.2]; co.despike.oxy1 = [10 10];
                co.despike.temp2 = [1 1]; co.despike.cond2 = [0.2 0.2]; co.despike.oxy2 = [10 10];
            case 'raw_corrs'
                a = {dbstack(2).file};
                if strcmp(a{1},'msbe_02_edcal.m')
                    %apply here, don't need otherwise
                    %CTD is switched on while on deck for the
                    %transmissivity blanking exercise
                    iid = 1:60*24;
                    checked = [6 1];
                    if max(d.press(iid))>0.3 && ~checked(checked(:,1)==stnlocal)
                        keyboard
                    else
                        co.dpoff = -median(d.press(iid),'omitnan');
                        fprintf(1,'pre-cast p offset: %f\n',co.dpoff)
                    end
                end
            case 'cast_divide'
                force_auto.end = 1;
            case 'rawshow'
                yl.temp = [-2 18]; yl.cond = [3 5]; yl.oxy = [120 300];
                yl.press = [-1 3200];
                yl.press = [-1 ceil(d.press(ddcs.dc24_bot)/100)*100+10];
                yl.fluor = [0 8];
            case 'niskfilename'
                blinfile = fullfile(MEXEC_G.MDIRLIST.M_CTD_BOT,sprintf('%s_%s.bl',upper(mcruise),stn_string));
            case 'botflags'
                niskin_flag(position==3) = 4; %latch does not release
                if stnlocal==2
                    niskin_flag(ismember(position,[17 23])) = 3; %leaked
                elseif stnlocal==6
                    niskin_flag(position==16) = 3; %leaked
                elseif stnlocal==7
                    niskin_flag(position==16) = 3; %leaked
                    %niskin 17 chl & hplc sampled before nuts, doc, salt
                elseif stnlocal==10
                    niskin_flag(position==5) = 3; %leaked? dnf? %note on n17 but still sampled for everything?
                elseif stnlocal==18
                    niskin_flag(position==16) = 3; %leaked
                elseif stnlocal>=24 && stnlocal<=26
                    niskin_flag(position==13) = 4; %didn't close
                elseif stnlocal==12
                    niskin_flag(position==12) = 3; %leaking
                elseif stnlocal==30
                    niskin_flag(position==13 | position==14) = 3; %didn't close fully (bottom) but still sampled?
                elseif stnlocal==37
                    niskin_flag(position==11 | position==17) = 3; %leaking a little? not enough water for last planned samples
                elseif stnlocal==41
                    niskin_flag(ismember(position,[6 14 16 20])) = 3; %possibly leaking, check
                end
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
                switch samtyp
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
                        salfiles = dir(fullfile(MEXEC_G.MDIRLIST.M_BOT_SAL,'portasal*.csv'));
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
                checksam.sbe35 = 1;
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
        end
        %set magnetic declination here, rather than using either of the two
        %options built in to LDEO_IX/loadnav
        %[p, f, ext] = fileparts(cfg.f.ctd); y0 = MEXEC_G.MDEFAULT_DATA_TIME_ORIGIN(1);
        a = {dbstack(2).file};
        if ~strcmp(a{1},'mout_1hzasc.m')
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
            ii = find(md==stnlocal); ii = ii(1);
            cfg.p.drot = md(ii+1);
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
                    kstns = [4:35];
                    mgrid.xlim = 2; mgrid.zlim = 4;
                else
                    section = 'profiles_only';
                    kstns = 1:999; %useful to do profiles_only for all stations anyway (smooth in vertical)
                end
        end


end



