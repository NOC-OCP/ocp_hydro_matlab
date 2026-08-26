
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
                    'truewind_truewind', ...
                    'ranger2usbl_psonlld', 'ctd_smctd', ...
                     ];
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
        switch opt2
           % oxy sensors - persistent primary-secondary offsets so
           % regular sensor changes:
            
           % Primary (Sensornum CTDnum):
           % 3836 [1 17];

           % Secondary (Sensornum CTDnum):
           % 2055 [1 2]; % offset 15
           % 2575 [3 14]; % Offset 10-15, noisy
           % 4580 [4:13 15 17]; % offset 15
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


            case 'ctdfiles'
                cnvfile = fullfile(MEXEC_G.MDIRLIST.M_CTD_CNV,...
                    sprintf('%s_CTD%s.cnv', upper(mcruise), stn_string));
            case 'redoctm'
                redoctm = 1;
            case 'niskfilename'            
                blinfile = fullfile(MEXEC_G.MDIRLIST.M_CTD_BOT,...
                    sprintf('%s_CTD%s.bl', upper(mcruise), stn_string));
            case 'rawshow'
                if ismember(stn,[1,2])
                    yl.cond = [40 50];yl.cond1=yl.cond;yl.cond2=yl.cond;
                    yl.press = [-2 150];
                    yl.temp = [15 25];
                    yl.fluor = [0 2];
                    yl.turbidity = [0 0.2];
                else 
                    yl.cond = [25 45];yl.cond1=yl.cond;yl.cond2=yl.cond;
                end
            case 'niskins'
                niskin_pos = 1:24;
                niskin_number = [2754:2774,2776:2778];
                % double check barcodes of the straight niskin numbers
                if ismember(stn,[1:4])
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
                    %
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
                end
        
        end
%%%%%%%%%%%%%%%%%%%% end ctd_proc %%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%  adcp_proc %%%%%%%%%%%%
case 'adcp_proc'
        cfg.rawdir = fullfile(MEXEC_G.MDIRLIST.M_LADCP,'rawdata');
        cfg.uppat = sprintf('%s_LADCP_%sS.000',upper(mcruise),cfg.stnstr);
        cfg.dnpat = sprintf('%s_LADCP_%sM.000',upper(mcruise),cfg.stnstr);
        
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
        end
%%%%%%%%%%%%%%%%%%%% end sbe35 %%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%% samp_proc %%%%%%%%%%   
case 'samp_proc'
        switch opt2
            case 'files'
                % uway_sample_log_file = fullfile(MEXEC_G.MDIRLIST.M_BOT,'uway_sample_log.csv');
                switch samtyp
                    case 'ulog'
                    case 'chl'
                    case 'oxy'
                        files = {fullfile(MEXEC_G.MDIRLIST.M_BOT_OXY,'Winkler Calculation Spreadsheet_DY214- 240826.xlsx')};
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
                            'flag','char','string';...
                            };  
                        sopts.VariableNames = ct(:,1)';
                        sopts.VariableTypes = ct(:,2)';
                        sopts.VariableUnits = ct(:,3)';
                        sopts.sheets = 1;
                    case 'sal'
                        % files = {dir(fullfile(MEXEC_G.MDIRLIST.M_BOT_SAL,'portasal*.csv')).name};
                        % files = cellfun(@(x) fullfile(MEXEC_G.MDIRLIST.M_BOT_SAL,x),files,'UniformOutput',false);
                    case 'nut'
                    case 'co2'
                    case 'cfc'
                    case 'doc'
                    case 'iso'
                end
            case 'parse'
                switch samtyp
                    case 'sal'
                        % ssw_k15 = 0.99983;
                        % ssw_batch = 'P169';
                    case 'oxy'
                        sdata.flag = 1+ones(size(sdata.statnum));
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
            case 'check'
                % checksam.sbe35 = 0;
                % checksam.sal = 1; %done
                checksam.oxy = 1; %done
                % checksam.chl = 0;
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
%%%%%%%%%%%%%%%%%%%% end samp_proc %%%%%%%%%%

end
