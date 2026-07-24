switch opt1
    
    case 'setup'
        switch opt2
            case 'time_origin'
                MEXEC_G.MDEFAULT_DATA_TIME_ORIGIN = [2026 1 1 0 0 0];
            case 'minit'
                if stn == 25.1
                    stn_string = '025';
                end
        end

    case 'ctd_proc'
        switch opt2
            case 'ctdfiles'
                cnvfile = fullfile(MEXEC_G.MDIRLIST.M_CTD_CNV,[upper(mcruise) '_' stn_string '.cnv']);
            case 'rawedit_auto'
                co.rangelim.press = [-1.25 4000]; %edit out larger spikes
                co.rangelim.cond = [0 100];
                co.rangelim.temp = [0 100];
                co.rangelim.oxy = [0 500];
            case 'cast_split_comb'
                if stn==25.1
                    otfile_appendto = fullfile(MEXEC_G.MDIRLIST.M_CTD,'ctd_ce26008_025_cnv.nc');
                    %cast_scan_offset = [65.1 65 81192]; %this cast, cast to append to, scan offset
                end
            case 'ctd_raw_extra'
                if stn==25
                    %data from cast 25 in two cnv files, so ctd_process
                    %runs this after msbe_01_load(25) to combine before the rest of
                    %processing
                    msbe_01_load(25.1);
                    otfile = fullfile(MEXEC_G.MDIRLIST.M_CTD_CNV,'ctd_ce26008_025_cnv.nc'); 
                    getpos_for_ctd(otfile, 1, 'write');
                    mfir_01_load(25.1);
                end
        end

    case 'nisk_proc'
        switch opt2
            case 'blfilename'
                if stn==65.1
                    blinfile = fullfile(MEXEC_G.MDIRLIST.M_CTD_BOT,sprintf('%s_025b.bl',upper(mcruise)));
                else
                    blinfile = fullfile(MEXEC_G.MDIRLIST.M_CTD_BOT,sprintf('%s_%s.bl',upper(mcruise),stn_string));
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

end



