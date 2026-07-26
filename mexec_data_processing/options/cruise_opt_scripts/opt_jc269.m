switch opt1

    case 'setup'
        switch opt2
            case 'setup_datatypes'
                use_ix_ladcp = 1;
            case 'time_origin'
                MEXEC_G.MDEFAULT_DATA_TIME_ORIGIN = [2024 1 1 0 0 0];
            case 'mdirlist'
%                MEXEC_G.MDIRLIST{strcmp('M_BOT_SAL',MEXEC_G.MDIRLIST(:,1)),2} = fullfile('ctd','BOTTLE_SAL','AUTOSAL','Autosal Data');
        end

    case 'ship'
        switch opt2
            case 'datasys_best'
                default_navstream = 'posmv_gpgga';
                default_hedstream = 'posmv_pashr';
                default_attstream = 'posmv_pashr';
            case 'rvdas_database'
%                RVDAS.machine = '192.168.65.51';
%                %RVDAS.jsondir = '/data/pstar/mounts/mnt_cruise_data/Ship_Systems/Data/RVDAS/Sensorfiles/'; %original
%                RVDAS.user = 'rvdas';
%                RVDAS.database = ['"' upper(MEXEC_G.MSCRIPT_CRUISE_STRING) '"'];
        end

    case 'castpars'
        switch opt2
            case 'minit' 
               %Ti vs SS for stn_string? or don't need this because it's
               %sequential numbering and handled with cnvfilename? do need
               %it for e.g. vmadcp station av***
            case 's_choice'
                s_choice = 2; %fin sensor
            case 'o_choice'
                o_choice = 2; %fin sensor, also more consistency in Ti O sensor

        end

    case 'ctd_proc'
        switch opt2
            case 'redoctm'
                redoctm = 1;
            case 'cnvfilename'
                cnvfile = fullfile(cdir,sprintf('%s_CTD_%03dS.cnv',upper(mcruise),stn)); %try stainless first
                if ~exist(cnvfile,'file')
                    cnvfile = fullfile(cdir,sprintf('%s_CTD_%03dT.cnv',upper(mcruise),stn)); %try Ti
                end
            case 'ctd_cals'
                co.docal.cond = 0;
                co.docal.oxygen = 0;
                %co.calstr.cond.sn44065.dy180 = 'dcal.cond = d0.cond.*(1-0.005/35);';
                %co.calstr.cond.sn44065.msg = 'calibration for cond 04c-4065 (cond1) based on N samples from M casts';
            case 'rawedit_auto'
                if stn==1
                    co.badscan.temp2 = [4.95e4 7.9e4];
                    co.badscan.cond2 = co.badscan.temp2;
                    co.badscan.oxygen_sbe2 = [0 2.9e4; co.badscan.temp2];
                elseif stn==3
                    co.badscan.temp2 = [4.75e4 7.8e4];
                    co.badscan.cond2 = co.badscan.temp2;
                    co.badscan.oxygen_sbe2 = [1.8e4 2.7e4; co.badscan.temp2];
                elseif stn==4
                    co.badscan.oxygen_sbe1 = [1.4026e5 Inf];
                    co.badscan.oxygen_sbe2 = co.badscan.oxygen_sbe1;
                elseif stn==6
                    co.rangelim.cond1 = [34 40];
                    co.rangelim.cond2 = co.rangelim.cond1;
                    co.badscan.oxygen_sbe1 = [1.3922e5 Inf];
                    co.badscan.oxygen_sbe2 = co.badscan.oxygen_sbe1;
                elseif stn==7
                    co.badscan.oxygen_sbe1 = [1.303e5 Inf];
                    co.badscan.oxygen_sbe2 = co.badscan.oxygen_sbe1;

                    % elseif ismember(stn,[44 45])
                %     co.badscan.oxygen_sbe2 = [-inf inf]; %steps, all questionable
                % elseif stn==61
                %     co.despike.cond1 = [0.02 0.02];
                %     co.despike.cond2 = [0.02 0.02];
                % elseif stn==88
                %     co.badscan.cond1 = [9.198e4 inf]; %offset, probably resolves before surface but hard to say where
                % elseif stn==98                         %CTD clogged with jellyfish
                %     co.badscan.oxygen_sbe1 = [39200 inf];
                %     co.badscan.temp1 = [39200 inf];
                %     co.badscan.cond1 = [39200 inf];
                %     co.badscan.cond2 = [11004 39421];
                end
        end

    case 'nisk_proc'
        switch opt2
            case 'blfilename'
                blinfile = fullfile(root_botraw,sprintf('%s_CTD_%03dS.bl', upper(mcruise), stn));
                if ~exist(blinfile,'file')
                    blinfile = fullfile(root_botraw,sprintf('%s_CTD_%03dT.bl', upper(mcruise),stn));
                end
        end

    case 'ladcp_proc'
        cfg.uppat = sprintf('%s_LADCP_CTD%03dS*.000',upper(mcruise),stnlocal);
        cfg.dnpat = sprintf('%s_LADCP_CTD%03dM*.000',upper(mcruise),stnlocal);
        cfg.rawdir = fullfile(mgetdir('ladcp'),'rawdata');
        cfg.p.vlim = 4; %rather than ambiguity vel, match this to LV

    case 'check_sams'
        %make this display-dependent? (or session-dependent?)
        check_sal = 1;
        check_oxy = 1;
        check_sbe35 = 0;

    case 'botpsal'
        switch opt2
            case 'sal_files'                
                salfiles = dir(fullfile(root_sal,'JC269*.csv')); 
            case 'sal_parse'
                cellT = 21;
                ssw_k15 = 0.99993;
                ssw_batch = 'P168';
            case 'sal_calc'
            case 'sal_flags'
        end

    case 'botoxy'
        switch opt2
            case 'oxy_files'
                ofiles = dir(fullfile(root_oxy,'DY180_oxy_CTD*.xls'));
                %hcpat = {'Niskin';'Bottle'};
                %chrows = 1:2;
                %chunits = 3;
                hcpat = {'Bottle';'Number'}; %Flag is on 2nd line so start here
                chrows = 1;
                chunits = 2;
            case 'oxy_parse'
                calcoxy = 1;
                labT = [];
                varmap.statnum = {'number'};
                varmap.position = {'bottle_number'};
                varmap.vol_blank = {'titre_mls'};
                varmap.vol_std = {'vol_mls'};
                varmap.vol_titre_std = {'titre_mls_1'};
                varmap.fix_temp = {'temp_c'};
                varmap.bot_vol_tfix = {'at_tfix_mls'};
                varmap.sample_titre = {'titre_mls_2'};
            case 'oxy_flags'
                %sampnum, a flag, b flag, c flag
                flr = [1201 3 3 9; ... 
                       2703 3 3 9; ... 
                       2707 2 2 4; ...
                       3903 9 3 4; ...
                       3906 3 3 9; ...
                       4403 2 2 4; ...
                       5203 3 4 4; ... % to be further evaluated later
                       5223 2 2 2; ...
                      ];
                [~,ifl,id] = intersect(flr(:,1),d.sampnum);
                d.botoxya_flag(id) = max(d.botoxya_flag(id),flr(ifl,2));
                d.botoxyb_flag(id) = max(d.botoxyb_flag(id),flr(ifl,3));
                d.botoxyc_flag(id) = max(d.botoxyc_flag(id),flr(ifl,4));
                % outliers relative to profile/CTD (not replicates)
                flag4 = [1207 2716 2720 2722 2724 2705 3909 5206 5210 5214 5216 5218]';
                d.botoxya_flag(ismember(d.sampnum,flag4)) = 4;
                flag4b = [1501 2720]; %both a and b high, maybe bad niskin closure
                d.botoxya_flag(ismember(d.sampnum,flag4b)) = 4;
                d.botoxyb_flag(ismember(d.sampnum,flag4b)) = 4;
        end

    case 'outputs'
        switch opt2
            case 'summary'
                snames = {'nsal' 'noxy' 'nnut' 'nco2'};
                sgrps = {{'botpsal'} {'botoxy'} {'silc' 'phos' 'nitr'} {'dic' 'talk'}};
            case 'exch'
                ns = 10; nt = 10; %***
                expocode = '740H20240904'; %***
                sect_id = 'Bio-Carbon';
                submitter = 'COPNOCAP'; %group institution person
                common_headstr = {'#SHIP: RRS James Cook';...
                    '#Cruise JC269; Bio Carbon autumn';...
                    '#Region: subpolar north Atlantic';...
                    ['#EXPOCODE: ' expocode];...
                    '#DATES: 202409** - 202410**';...
                    '#Chief Scientist: M. Moore (University of Southampton)';...
                    '#Supported by grants from the UK Natural Environment Research Council.'}; %***
                if strcmp(in.type,'ctd')
                    headstring = {['CTD,' datestr(now,'yyyymmdd') submitter]};
                    headstring = [headstring; common_headstr;
                        {sprintf('#%d stations with 24-place stainless-steel rosette',ns);...
                        sprintf('#%d stations with 24-place trace metal clean rosette',nt);...
                        '#CTD: Who - Y. Firing and T. Petit (NOC); Status - preliminary.';...
                        %'#The CTD PRS; TMP; SAL; OXY data are all calibrated and good.';...
                        '# DEPTH_TYPE   : COR';...
                        '# DEPTH_TYPE   : rosette depth from CTDPRS + CTD altimeter range to bottom, or speed of sound-corrected ship-mounted bathymetric echosounder'...
                        }];
                else
                    headstring = {['BOTTLE,' datestr(now,'yyyymmdd') submitter]};
                    headstring = [headstring; common_headstr;
                        {sprintf('#%d stations with 24-place stainless-steel rosette',ns);...
                        sprintf('#%d stations with 24-place trace metal clean rosette',nt);...
                        '#CTD: Who - Y. Firing and T. Petit (NOC); Status - preliminary';...
                        '#Notes: Includes CTDSAL, CTDOXY, CTDTMP';...
                        %'#The CTD PRS; TMP; SAL; OXY data are all calibrated and good.';...
                        '# DEPTH_TYPE   : rosette depth from CTDPRS + CTD altimeter range to bottom';...
                        '#Salinity: Who - Y. Firing (NOC); Status - preliminary; SSW batch P165***.';...
                        '#Oxygen: Who - E. Mawji (NOC); Status - preliminary.';...
                        '#Nutrients: Who - E. Mawji (NOC); Status - preliminary.';...
                        '#DIC and Talk: Who - ??? (NOC); Status - preliminary.';...
                        '#***';...
                        }];
                end
        end

end

