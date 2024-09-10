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
                o_choice = 2; %fin sensor

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
                salfiles = dir(fullfile(root_sal,['DY180*.csv'])); 
                salfiles = {salfiles.name};
            case 'sal_parse'
                cellT = 21;
                ssw_k15 = 0.99993;
                ssw_batch = 'P168';
            case 'sal_calc'
                sal_off = [000 -1.5; 005 -1.5]; %10th am
                sal_off(:,1) = sal_off(:,1)+999e3;
                sal_off(:,2) = sal_off(:,2)*1e-5;
                %sal_off_base = 'sampnum_list'; 
            case 'sal_flags'
                % 402 second sample is a low outlier
                % 1205 third sample is a low outlier
                % 2413 second and third samples are low and high outliers, respectively
                % 5209 second and third samples are low and high outliers, respectively
                % 5217 first sample is low outlier
                % 
%                 %too low (33-ish), maybe samples contaminated
%                 m = ismember(ds_sal.sampnum,[4807 4809 5713 5715 5801 5803 5805]);
%                 ds_sal.flag(m) = 4;
% m = ismember(ds_sal.sampnum,[6715 8810]); ds_sal.flag(m) = 3;
%                 %Missing salinometer analysis due to blockage
%                 none = ismember(ds_sal.sampnum, [9104 9105]);
%                 ds_sal.flag(none) = 5;
        end

    case 'botoxy'
        switch opt2
            case 'oxy_files'
                ofiles = dir(fullfile(root_oxy,'DY180_oxy_CTD*.xls'));
                ofiles = {ofiles.name}; 
                %hcpat = {'Niskin';'Bottle'};
                %chrows = 1:2;
                %chunits = 3;
                hcpat = {'Bottle';'Number'}; %Flag is on 2nd line so start here
                chrows = 1;
                chunits = 2;
            case 'oxy_parse'
                calcoxy = 1;
                varmap.position = {'bottle'};
                varmap.statnum = {'number'};
                varmap.fix_temp = {'temp'};
                varmap.conc_o2 = {'umol_per_l'};
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

