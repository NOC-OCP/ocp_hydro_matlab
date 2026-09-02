
switch opt1

    case 'setup'
        switch opt2
            case 'time_origin'
                MEXEC_G.MDEFAULT_DATA_TIME_ORIGIN = [2026 1 1 0 0 0];
        end

    case 'shipuway'
        switch opt2
            case 'rvdas_database'
                RVDAS.loginfile = '/data/plocal/rvdas_addr';
        end

%%%%%%%%%%%%%%%%%%%% uway_proc %%%%%%%%%%    
    case 'uway_proc'
        switch opt2
            case 'datasys_best'
                default_navstream = 'posmv_gpgga';
                default_hedstream = 'posmv_pashr';
                default_attstream = 'posmv_pashr';
            case 'rvdas_skip'
                % %usbl not used, wamos not used
                % %don't need to read ctd depth through rvdas
                % %can read surfmet variables from nudam instead
                % skips.sentence_pat = [skips.sentence_pat, ...
                %     'usbl', 'wamos', 'ctuopd', 'surfmet'];
                % %below tables are present but have 0 data (return COPY 0)
                skips.sentence = [skips.sentence, ...
                    'truewind_truewind','metocean_QC' ...
                    'ranger2usbl_psonlld', 'ctd_smctd', ...
                    'metocean_TEST','metocean_TEST_QC','samos_QC',...
                    'samos_TEST','samos_TEST_QC','truewind_QC',...
                    'truewind_TEST','truewind_TEST_QC',...
                     ];
            case 'avedit'
                switch datatype
                    %tried adding nav data but it's not showing plots yet
                    case 'nav'
                        %handedit = 1;
                        vars_to_ed.g1 = {{'heading_av_corrected','heading','head_gyr'}};%{{'roll'},{'pitch'},{'heave'},{'dum_e'},...
                            %{'dum_n'},{'heading'},{'smg'},{'cmg'},{'distrun'}};
                        %yl.roll = [-5 5];
                        %yl.pitch = [-5 5];
                        %yl.heave = [-5 5];
                        %yl.dum_e = [-5 5];
                        %yl.dum_n = [-5 5];
                        yl.heading_av_corrected = [0 360];
                        yl.heading = [0 360];
                        yl.head_gyr = [0 360];
                        %yl.smg = [-5 5];
                        %yl.cmg = [-5 5];
                        %yl.distrun = [-5 5];
                    case 'bathy'
                        vars_to_ed.g1 = {{'waterdepthfromsurface_sbm'},{'waterdepth_mbm'}};
                        yl.waterdepthfromsurface_sbm = [-2 3100];
                        yl.waterdepth_mbm = [-100 3000];
                    case 'atmos'
                        vars_to_ed.g1={{'press'},{'airtemp'},{'humidity'},...
                            {'truwind_spd','truwind_e','truwind_n'},...
                            {'ptir','ppar','stir','spar'}};
                        yl.press = [0 1050];
                        yl.airtemp = [-10 30];
                        yl.ppar = [0 1e5];
                        yl.spar = yl.ppar;
                        yl.ptir = yl.ppar;
                        yl.stir = yl.ppar;
                    case 'ocean'
                        yl.tempr = yl.temph;
                        yl.conductivity = [-5 50];
                        yl.salinity = yl.psal;
                        yl.soundvelocity = [0 1600];
                        yl.trans = [0 50];
                        yl.flow = [0 2];
                        vars_to_ed.g1 = {{'temph','tempr','tempdk'}, {'conductivity'}, {'salinity'},{'soundvelocity'}};
                        vars_to_ed.g2 = {{'temph'},{'fluo'},{'flow'},{'trans','transmittance'}};
                end
        end
%%%%%%%%%%%%%%%%%%%% end uwau_proc %%%%%%%%%%

%%%%%%%%%%%%%%%%%%%% bathy (not a script) %%%%%%%%%%
        % not sure if needed for DY214
    % case 'bathy'
    %     switch opt2
    %         case 'bathy_grid'
    %             crhelp_str = {'load gridded bathymetry into top.lon, top.lat, top.depth,'
    %                 'for use by mbathy_edit_av'};
    %     end
%%%%%%%%%%%%%%%%%%%%  end bathy (not a script) %%%%%%%%%%

%%%%%%%%%%%%%%%%%%%% ctd_proc %%%%%%%%%%%%
    case 'ctd_proc'
        % part 1 not printing acdp files
        switch opt2
           % oxy sensors - persistent primary-secondary offsets so
           % regular sensor changes:
           % CTD 25: primary sensor started aligning with secondary sensor
           % (smaller offset)
           % CTD 28: secondary showed very little variability on downcast,
           % primary fine on downcast, but big difference during upcast. 
           % John and Finn have notes
        
           % Primary (Sensornum CTDnum):
           % 3836 [1 17];

           % Secondary (Sensornum CTDnum):
           % 2055 [1 2]; % offset 15
           % 2575 [3 14]; % Offset 10-15, noisy
           % 4580 [4:13 15 17 20 24]; % offset 15
           % 2540 [16]; % Offset ~25!


           % to do - station 3 auto de spiking conductivity and 
           % fluorescence
           % todo: 004 despiking of conductivity and transmittance 
           % 005 spikes in cond, trns anf fluor
           % todo: 009 despiking of conductivity, fluor and transmittance 
           % todo: 011 despiking of transmittance 
           % todo: 013 despiking of transmittance 
           % todo: 013 despiking of transmittance.  
           %           + issue with oxy sensor being very noisy on the way
           %           up.
           %           also, one of the oxy sensor was affected when 
           %           surfacing before the automatically detected time 
           %           cutoff. 
           % todo: 015 oxygen and conductivity on primary sensor affected
           %           by something during a small bit of the descent
           %           (around 1000m depth). Correction needed. 
           %           also, despiking of transmittance needed.
           % todo: 018 transmittance and fluorence needs despiking 
           % todo: 019 conductivity 1 and transmittance needs despiking
           % todo: 028 spike on transmittance 3.8 
           % todo: 030 spiking in transmittance - unusually large number of
           % data points, felt weird to remove that many so have left it
           % todo: 030 primary oxygen sensor has a section of bad data


            case 'ctdfiles'
                cnvfile = fullfile(MEXEC_G.MDIRLIST.M_CTD_CNV,...
                    sprintf('%s_CTD%s.cnv', upper(mcruise), stn_string));
            case 'redoctm'
                redoctm = 1;
            case 'niskfilename'            
                blinfile = fullfile(MEXEC_G.MDIRLIST.M_CTD_BOT,...
                    sprintf('%s_CTD%s.bl', upper(mcruise), stn_string));
            case 'header_edits'
            h.comment = replace(h.comment,'PSO: Tiago Dotto','PSO: Kristin Burmeister');
            m_write_header(otfiles{1},h);
            case 'raw_corrs'
                co.oxy_align = 0; %0 until we check oxygen hysteresis
            case 'rawedit_auto'
                %use rangelim first to exclude very large %skspikes
                % co.rangelim.press = [-1.25 3300];
                % co.rangelim.cond1 = [30 50]; % our measurements are in mS/cm
                % co.rangelim.temp1 = [-2 18]; 
                % if ismember(stnlocal,[1,2]) %
                %     co.rangelim.temp1 = [-2 25];
                % end
                % co.rangelim.oxy2 = [150 350]; % very broad
                % co.rangelim.temp2 = co.rangelim.temp1;
                % co.rangelim.cond2 = co.rangelim.cond1;
                % co.rangelim.oxy1 = co.rangelim.oxy2;
                % co.rangelim.turbidity = [0 1];
                % co.rangelim.fluor = [0 8];
                % co.rangelim.transmittance = [0 100];
                % co.rangelim.turbidity = [0 1];
                % %co.rangelim.par = [0 100];
                % %then despike with 2 repetitions of a 12-scan median
                % %despiker
                % co.despike.press = [2 12; 2 12]; %avg 1m/s so 2 dbar/0.5 s is large
                % co.despike.temp1 = [0.5 12; 0.5 12];
                % co.despike.cond1 = [0.02 12; 0.02 12];
                % co.despike.oxy1 = [3 12; 3 12];
                % co.despike.temp2 = co.despike.temp1;
                % co.despike.cond2 = co.despike.cond1;
                % co.despike.oxy2 = co.despike.oxy1;
                % %so many spikes it's not worth cleaning in some sensore 
                if ismember(stnlocal,[3 28]) %
                    co.badscan.oxy1 = [-inf inf]; %so many spikes it's not worth cleaning
                end
                if ismember(stnlocal,[3])
                    co.badscan.oxy2 = [-inf inf];
                end
                % %then mask all on CTD whenever P is bad
                % co.badpress.temp1 = [NaN NaN];
                % co.badpress.temp2 = [NaN NaN];
                % co.badpress.cond1 = [NaN NaN];
                % co.badpress.cond2 = [NaN NaN];
                % co.badpress.oxy1 = [NaN NaN];
                % co.badpress.oxy2 = [NaN NaN];
                % co.badpress.turbidity = [NaN NaN];
                % co.badpress.transmittance = [NaN NaN];
                % co.badpress.fluor = [NaN NaN];
            case 'rawshow'
                repars = rmfield(repars,'g2'); %don't edit fluo etc.
                yl.press = [-1 3200];
                yl.press = [-1 ceil(d.press(ddcs.dc24_bot)/100)*100+10];
                yl.fluor = [0 8]; yl.par = [0 40];
		if stn = 1
                    yl.temp = [15 25];
                end
                if ismember(stn,[1,2])
                    yl.cond = [40 50];
                    yl.press = [-2 170];
                    yl.fluor = [0 2];
                    yl.turbidity = [0 0.2];
                else 
                    yl.cond = [25 45];
                end
                yl.temp1 = yl.temp; yl.temp2 = yl.temp; 
                yl.cond1 = yl.cond; yl.cond2 = yl.cond;
                yl.oxy1 = yl.oxy; yl.oxy2 = yl.oxy;
            case 'niskins'
                niskin_pos = 1:24;
                niskin_number = [2754:2774,2776:2778];
                % double check barcodes of the straight niskin numbers
                if ismember(stn,[1:4 18:44])
                    niskin_pos = niskin_pos(1:2:end);
                    niskin_number = niskin_number(1:2:end);
                end
            case 'botflags'
                switch stnlocal % station number
                    % DY214
                    % Add a new case for the station if a problem with the
                    % bottle occured after the ctd came up (M3). These are
                    % the bottle flags:
                    % 1: no info; 2: no problems noted; 3: leaking;
                    % 4: did not trip correctly; 5: not reported;
                    % 7: unknown problem; 9: samples not drawn
                    
                    % If you are unsure about syntax add a comment.
                    % Example:
                    % todo: For station 4, bottle 9 and 11 leaked
                    case 4
                        niskin_flag(ismember(position,[9 11])) = 3; % bottles leaked
                    case 6
                        niskin_flag(ismember(position,[3])) = 3; % bottles leaked
                    case 9 
                        niskin_flag(ismember(position,2)) = 9; % bottle leaked and was not sampled              
                        niskin_flag(ismember(position,18)) = 3; % bottle leaked   
                        niskin_flag(ismember(position,[2 6 8 10 18 20 22])) = 9; % samples not drawn; backup bottles
                    case 10
                        niskin_flag(ismember(position,[1 6])) = 3; % bottle leaked
                    case 12
                        niskin_flag(ismember(position,[2 4 6 8 10 12 14 16 18 20 22])) = 9; % samples not drawn; backup bottles
                    case 13
                        niskin_flag(ismember(position,[2 4 6 8 10 12 14 16 18 20 22 24])) = 9; % samples not drawn; backup bottles
                    case 14
                        niskin_flag(ismember(position,[6 8 10 12 14 16])) = 9; % samples not drawn; backup bottles
                    case 15
                        niskin_flag(ismember(position,22)) = 3; % bottle leaked  
                        niskin_flag(ismember(position,[2 4 6 8 10 12 14 16 18 20 22 24])) = 9; % samples not drawn; backup bottles
                    case 16
                        niskin_flag(ismember(position,[2 4 6 8 10 12 14 16 18 20 22 24])) = 9; % samples not drawn; backup bottles
                    case 17
                        niskin_flag(ismember(position,[2 4 6 8 10 12 14 16])) = 9; % samples not drawn; backup bottles
                    case 18 
                        niskin_flag(ismember(position,[3 7 11 15 19])) = 9; % samples not drawn; backup bottles
                    case 20
                        niskin_flag(ismember(position,[3 7])) = 9; % samples not drawn; backup bottles
                    case 23
                        niskin_flag(ismember(position, [3])) = 9; % samples not drawn; backup bottles
                    case 24
                        niskin_flag(ismember(position, [3 7 11 15])) = 9; % samples not drawn; backup bottles
                    case 25
                        niskin_flag(ismember(position, [3 7 11 15])) = 9; % samples not drawn; backup bottles
                        niskin_flag(ismember(position,17)) = 9; % bottle leaked (spout not reset); samples not drawn 
                    case 26
                        niskin_flag(ismember(position, [3 7 11 15 19 23])) = 9; % samples not drawn; backup bottles
                    case 31
                        niskin_flag(ismember(position, [3 7])) = 9; % samples not drawn; backup bottles
                    case 32
                        niskin_flag(ismember(position, [3 7 11 15])) = 9; % samples not drawn; backup bottles
                    case 33
                        niskin_flag(ismember(position, [3 7 11 15])) = 9; % samples not drawn; backup bottles
                    case 39
                        niskin_flag(ismember(position, [3])) = 9; % samples not drawn; backup bottles
                    case 40 
                        niskin_flag(ismember(position, [1])) = 3; % bottle leaked
                    case 46
                        niskin_flag(ismember(position, [1])) = 3; % bottle leaked, still drew salt and DO
                end
        
        end
%%%%%%%%%%%%%%%%%%%% end ctd_proc %%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%  adcp_proc %%%%%%%%%%%%
case 'adcp_proc'
        cfg.rawdir = fullfile(MEXEC_G.MDIRLIST.M_LADCP,'rawdata');
        cfg.uppat = sprintf('%s_LADCP_%sS.000',upper(mcruise),cfg.stnstr);
        cfg.dnpat = sprintf('%s_LADCP_%sM.000',upper(mcruise),cfg.stnstr);
        SADCP_inst = 'os75nb';
        cfg.f.sadcp = fullfile(MEXEC_G.MDIRLIST.M_VMADCP, 'mproc', [SADCP_inst '_' mcruise '_ctd_' stn_string '_forladcp.mat']);
        %set magnetic declination here, rather than using either of the two
        %options built in to LDEO_IX/loadnav
        %[p, f, ext] = fileparts(cfg.f.ctd); y0 = MEXEC_G.MDEFAULT_DATA_TIME_ORIGIN(1);

        %from CE26008 - however pyIGRF is not install - so I do not use it
        %at the moment
        %%%
        % a = {dbstack(2).file}; 
        % if ~strcmp(a{1},'mout_1hzasc.m') %bash script uses the output of mout_1hzasc so don't want to try to call this before that
        %     mdfile = fullfile(MEXEC_G.MDIRLIST.M_LADCP,'magdec.txt');
        %     if ~exist(mdfile,'file')
        %         fprintf(1,'in terminal, run the following:\nbash /data/pstar/programs/repos_github/mexec_exec/run_pyIGRF.sh\nthen enter to continue (here)')
        %         pause
        %     end
        %     md = load(mdfile);
        %     if ~sum(md==stnlocal)
        %         fprintf(1,'in terminal, run the following:\nbash /data/pstar/programs/repos_github/mexec_exec/run_pyIGRF.sh\nthen enter to continue (here)')
        %         pause
        %         md = load(mdfile);
        %     end
        %     ii = find(md==stnlocal); 
        %     if isempty(ii)
        %         warning('no mag dec for %s',stn_string)
        %     else
        %         ii = ii(1);
        %         cfg.p.drot = md(ii+1);
        %         fprintf(1,'using mag dec %f for %s',cfg.p.drot,stn_string)
        %     end
        % end
%%%%%%%%%%%%%%%%%%%%  end adcp_proc %%%%%%%%%%%%        

%%%%%%%%%%%%%%%%%%%%  sbe35 %%%%%%%%%%%%
    case 'sbe35'
        switch opt2
            case 'sbe35files'
                sbe35in = fullfile(MEXEC_G.MDIRLIST.M_SBE35,...
                    sprintf('CTD_*.asc')); % not station specific
                stnind = -6:-4; % index in file name of where the station number can be found.
                %stnind is indices in filename sbe35file normally
                %containing the station number; use negative to indicate
                %distance from end e.g. [-6:-4] for dy113_SBE35_CTD_010.asc
            case 'sbe35_parse'
                %deal with combined file(s)
                % copied below form opt_ce26008.m
                % if strcmp(file_list{kf},'CE26008_002_003.txt')
                %     m = t.datnum<datenum(2026,7,24,10,0,0);
                %     t.statnum(m) = 2;
                % elseif strcmp(file_list{kf},'CE26008_005_006_007.txt')
                %     m = t.datnum<datenum(2026,7,25,5,0,0);
                %     t.statnum(m) = 5;
                %     m = t.statnum==7 & t.datnum<datenum(2026,7,25,9,0,0);
                %     t.statnum(m) = 6;
                % end
            case 'restartsam'
            pd = mexec_file_locations('procfiles','samp');    
            %delete sam_*_all file
            if exist(pd.samc,'file')
                warning('deleting sam file: %s in 1 s',pd.samc)
                pause(1)
                delete(pd.samc)
            end
            % find which stations have bottle firing files
            pfir = mexec_file_locations('procfiles','fir')
            d = dir(sprintf(pfir.firfile,'*'));
            % Extract 3-digit blocks directly and convert to numbers
            [~, namesWithoutExt] = cellfun(@fileparts, {d.name}, 'UniformOutput', false);
            stns = cellfun(@(x) split(x, '_'), namesWithoutExt, 'UniformOutput', false);
            stns = cellfun(@(x) str2double(x{3}), stns);
            stns = stns(:)';
            for stn = stns
                %re-run to freshly add CTD data to sam file
                mfir_to_sam(stn)
            end
            %add serial numbers (already saved in .mat file)
            get_sensor_groups(stns,'samonly')

        end
%%%%%%%%%%%%%%%%%%%% end sbe35 %%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%% samp_proc %%%%%%%%%%   
case 'samp_proc'
        switch opt2
            % case 'sal_files'
            %         files = {dir(fullfile(MEXEC_G.MDIRLIST.M_BOT_SAL,'DY214*.csv')).name};
            %         files = cellfun(@(x) fullfile(MEXEC_G.MDIRLIST.M_BOT_SAL,x),files,'UniformOutput',false);
            %         sopts.numhead = 9;
                    
            case 'files'
                % uway_sample_log_file = fullfile(MEXEC_G.MDIRLIST.M_BOT,'uway_sample_log.csv');
                switch samtyp
                    case 'ulog'
                    case 'chl'
                    case 'oxy'
                        files = {fullfile(MEXEC_G.MDIRLIST.M_BOT_OXY,...
                        'Winkler Calculation Spreadsheet_DY214- 29_08_2026_v3.xlsx')};
                        sopts.numhead = 8;
                        % below from CE26008, above not working - need to
                        % edit, more
                        ct = {'date','char','string';...
                            'statnum','double','number';...
                            'station','char','string';...
                            'latitude','char','degreeN';...
                            'longitude','char','degreeW';...
                            'd','double','m';...
                            'position','double','number';...
                            'samno','double','number';...
                            'sampler','char','string';...
                            'botno','double','number';...
                            'botvol20','double','mls';...
                            'blank_titre','double','mls';...
                            'OSIL_std','char','string';...
                            'vol_std','double','mls';...
                            'std_titre','double','mls';...
                            'fix_temp','double','degc';...
                            'bot_vol_tfix','double','mls';...
                            'sample_titre','double','mls';...
                            'analysed_by','char','string';...
                            'iodatemol','double','M';...
                            'n_o2','double','moles';...
                            'conc_o2_ml','double','mg_per_l';...
                            'conc_o2','double','umol_per_l';...
                            'flag','double','number';...
                            };  
                        sopts.VariableNames = ct(:,1)';
                        sopts.VariableTypes = ct(:,2)';
                        sopts.VariableUnits = ct(:,3)';
                        sopts.sheets = 1;
                    case 'sal'
                        files = {dir(fullfile(MEXEC_G.MDIRLIST.M_BOT_SAL,'DY214*.csv')).name};
                        files = cellfun(@(x) fullfile(MEXEC_G.MDIRLIST.M_BOT_SAL,x),files,'UniformOutput',false);
                        sopts.numhead = 9;
                   
                    case 'nut'
                    case 'co2'
                    case 'cfc'
                    case 'doc'
                    case 'iso'
                end
            case 'oxy_to_sam'
                % dbot = splitvars(dbot, {'botoxy', 'botoxy_flag', 'botoxy_temp'});

            case 'parse'
                switch samtyp
                    case 'sal'
                        % ssw_k15 = 0.99983;
                        % ssw_batch = 'P169';case 'sal_parse'
                        cellT = 21;
                        ssw_k15 = 0.99993;
                        calcsal = 1;
                        ssw_batch = 'P170';
                    case 'oxy'
                        m = isnan(sdata.flag);
                        sdata.flag(m) = 5; %not reported
                        sdata.sample_titre(m) = NaN;
                        sdata.conc_o2(m) = NaN;
                        sdata.sampnum = sdata.statnum*100+sdata.position;
                        sdata(:,ismember(sdata.Properties.VariableNames,{'botno','botvol20','flags','statnum','position'})) = [];
                end
            case 'calc'
                switch samtyp
                    case 'sal'
                        %salin_off = -1.5e-5; %constant
                    case 'oxy'
                end
            case 'redoctm'
                redoctm = 1;
            case 'check'
                % checksam.sbe35 = 0;
                checksam.sal = 1; %done
                checksam.oxy = 1; %done
                % checksam.chl = 0;
            case 'flags' %flags before replicate averaging and after replicate averaging***
                switch samtyp
                    case 'sal'
                        check_sal=1
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
%%%%%%%%%%%%%%%%%%%% end samp_proc %%%%%%%%%%

end
