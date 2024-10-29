switch opt1

    case 'setup'
        switch opt2
            case 'setup_datatypes'
                use_ix_ladcp = 1;
            case 'time_origin'
                MEXEC_G.MDEFAULT_DATA_TIME_ORIGIN = [2024 1 1 0 0 0];
            case 'mdirlist'
                MEXEC_G.MDIRLIST{strcmp('M_BOT_SAL',MEXEC_G.MDIRLIST(:,1)),2} = fullfile('ctd','BOTTLE_SAL','AUTOSAL','Autosal Data');
        end

    case 'ship'
        switch opt2
            case 'datasys_best'
                default_navstream = 'posmv_gpgga';
                default_hedstream = 'posmv_pashr';
                default_attstream = 'posmv_pashr';
            case 'rvdas_database'
                RVDAS.machine = '192.168.65.51';
                %RVDAS.jsondir = '/data/pstar/mounts/mnt_cruise_data/Ship_Systems/Data/RVDAS/Sensorfiles/'; %original
                RVDAS.user = 'rvdas';
                RVDAS.database = ['"' upper(MEXEC_G.MSCRIPT_CRUISE_STRING) '"'];
        end

    case 'uway_proc'
        switch opt2
            case 'excludestreams'
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
                cnvfile = fullfile(cdir,sprintf('%s_CTD%03dS.cnv',upper(mcruise),stn)); %try stainless first
                if ~exist(cnvfile,'file')
                    cnvfile = fullfile(cdir,sprintf('%s_CTD%03dT.cnv',upper(mcruise),stn)); %try Ti
                end
            case 'ctd_cals'
                co.docal.cond = 1;
                co.docal.oxygen = 1;
                co.calstr.cond.sn44065.dy180 = 'dcal.cond = d0.cond.*(1-0.005/35);';
                co.calstr.cond.sn44065.msg = 'calibration for cond 04c-4065 (cond1) based on N samples from M casts';
                co.calstr.cond.sn44138.dy180 = 'dcal.cond = d0.cond.*(1-0.008/35);';
                co.calstr.cond.sn44138.msg = 'calibration for cond 04c-4138 (cond2) based on N samples from M casts';
                co.calstr.oxygen.sn2722.dy180 = 'dcal.oxygen = d0.oxygen.*interp1([0 1100],[1 1.005],d0.press).*interp1([1 52],[1.05 1.07],d0.statnum);';
                co.calstr.oxygen.sn2722.msg = 'calibration for oxy 2722 (oxygen1) based on N samples from M casts';
                co.calstr.oxygen.sn431882.dy180 = 'dcal.oxygen = d0.oxygen.*interp1([0 1100],[1 1.005],d0.press).*interp1([1 52],[1.020 1.030],d0.statnum);'; %1.025
                co.calstr.oxygen.sn431882.msg = 'calibration for oxy 43-1882 (oxygen2) based on N samples from M casts';
                %c1 042156, c2 043873, o1 430619, o2 0862 (what about o1 on
                %cast1?), o2 0709 (cast 2 5 10 16)
            case 'rawedit_auto'
                if stnlocal==35
                    co.rangelim.press = [-1 8000];
                end
        end

    case 'nisk_proc'
        switch opt2
            case 'blfilename'
                blinfile = fullfile(root_botraw,sprintf('%s_CTD%03dS.bl', upper(mcruise), stn));
                if ~exist(blinfile,'file')
                    blinfile = fullfile(root_botraw,sprintf('%s_CTD%03dT.bl', upper(mcruise),stn));
                end
        end

    case 'ladcp_proc'
        cfg.uppat = sprintf('%s_LADCP_CTD%03dS*.000',upper(mcruise),stnlocal);
        cfg.dnpat = sprintf('%s_LADCP_CTD%03dM*.000',upper(mcruise),stnlocal);
        cfg.rawdir = fullfile(mgetdir('ladcp'),'rawdata');
        cfg.p.vlim = 4; %rather than ambiguity vel, match this to LV

    case 'check_sams'
        %make this display-dependent? (or session-dependent?)
        check_sal = 0;
        check_oxy = 1;
        check_sbe35 = 0;

    case 'botpsal'
        switch opt2
            case 'sal_files'                
                salfiles = dir(fullfile(root_sal,'DY180*.csv')); 
            case 'sal_parse'
                cellT = 21;
                ssw_k15 = 0.99993;
                ssw_batch = 'P168';
            case 'sal_calc'
                salin_off = -1.5e-5; %constant
            case 'sal_flags'
                % 402 second sample is a low outlier
                % 1205 third sample is a low outlier
                % 2413 second and third samples are low and high outliers, respectively
                % 5209 second and third samples are low and high outliers, respectively
                % 5217 first sample is low outlier
                % 
                m = ismember(ds_sal.sampnum,[1403 1406 1408 1501]);
                ds_sal.flag(m) = 4;
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
                ns = 10; nt = 10;
                expocode = '74EQ20240522';
                sect_id = 'Bio-Carbon';
                submitter = 'OCPNOCYLF'; %group institution person
                common_headstr = {'#SHIP: RRS Discovery';...
                    '#Cruise DY180; Bio Carbon spring';...
                    '#Region: subpolar north Atlantic';...
                    ['#EXPOCODE: ' expocode];...
                    '#DATES: 20240522 - 20240628';...
                    '#Chief Scientist: S. Henson (NOC)';...
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

