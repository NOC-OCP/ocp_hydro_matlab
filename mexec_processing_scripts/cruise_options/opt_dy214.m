switch opt1
    case 'setup'
        switch opt2
            case 'time_origin'
                MEXEC_G.MDEFAULT_DATA_TIME_ORIGIN = [2026 1 1 0 0 0];
        end

    case 'ctd_proc'
        switch opt2
            case 'redoctm'
                redoctm = 1;
            case 'cnvfilename'
                cnvfile = fullfile(cdir,sprintf('DY181_CTD%s.cnv', stn_string));
            case 'rawedit_auto' % -----> only if repeated spikes or out of range
                % to see with [dr,hr] = mload('/data/pstar/cruise/data/ctd/ctd_dy204_008_raw_cleaned','/'); plot(dr.scan,dr.cond2,'.-')
                if stn==1
                    co.badscan.cond2 = [1.3625 1.3825]*1e4; 
                    co.badscan.temp2 = co.badscan.cond2;
                    co.badscan.oxygen_sbe2 = co.badscan.cond2;
                end
        end

             case 'nisk_proc'
        switch opt2
            case 'blfilename'
                blinfile = fullfile(root_botraw,sprintf('DY181_CTD%s.bl', stn_string));
            case 'niskins'
                niskin_pos = [1:2:23]';
                niskin_number = niskin_pos;
        end

            case 'sbe35'
        switch opt2
            case 'sbe35file'
                sbe35file = 'DY181_SBE35_CTD*.asc';
        end

            case 'botpsal'
        switch opt2
            case 'sal_files'
                salfiles = dir(fullfile(root_sal, 'autosal_dy181_*.csv')); 
            case 'sal_parse'
                cellT = 21;
                ssw_k15 = 0.99993;
                calcsal = 1;
                ssw_batch = 'P168';
                                salin_off = [000 -.5; 001 -1.5; 003 -2; ... %10th am
                    004 0; 005 1.5; 007 7; ... %11th pm
                    009 -3; 010 -1; 012 -2.5; ... %12th am
                    013 -6; 014 -2; ... %12th pm
                    015 -5; 016 2; 018 1; 020 -2; ... %14th am
                    021 -7.5; 022 -2; ... %14th pm
                    023 1.5; 026 1; 027 2.5; 029 1; ... %17th am 024, 025 9.5 suspicious, maybe old
                    % samples on 19th run without standards
                    % samples on 20th run without standards
                    031 -1; 036 -1; ... %21st am
                    037 -3.5; 038 4; 039 -1; ... %21st PM.  %***!
                    % 040 offset -8 (seems very big)
                    041 0.5; 042 -1.5; 043 -1; 045 1.5; ...
                    046 0.5; 047 2; ...%23rd 17:31-18;34
                    048 -4.5; 049 -5; 051 -6; ...
                    052 -5.5; 053 -4; ...
                    054.5 -4; ... % Last good vaule. 054 flagged 998 as out and not new.
                    055 3; ... % This was run on the secondary salinometer after a leak in the first.
                    056 -1; 057 1; 059 3; ... % Back to primary salinometer.
                    % analysed 26 PM and 27 AM
                    060 1; 061 2.5; 063 2.5; ...
                    % 064 -9; HUGE offset...
                    065 2.5; %066 3; ... %not sure if 066 was a new bottle or not
                    067 2.5; ... % using constant value %067 -8
                    ];
                salin_off(:,1) = salin_off(:,1)+999e3;
                salin_off(:,2) = salin_off(:,2)*1e-5;
                salin_off_base = 'sampnum_list'; 
        end

            case 'botoxy'
        switch opt2
            case 'oxy_files'
                ofiles = dir(fullfile(root_oxy,'*.xlsx'));
                iih = 8;
                hcpat = {'Longitude'};
                chrows = 1; chunits = [];
            case 'oxy_parse'
                %niskin 7015 is listed but was not fired; exclude rows now
                ii70 = find(ds_oxy.ctd_cast_no==70);
                ii71 = find(ds_oxy.ctd_cast_no==71);
                ii15 = find(ds_oxy.niskin_bot_no==15);
                ds_oxy(ii15(ii15>ii70 & ii15<ii71),:) = [];
                calcoxy = 0;
                varmap.statnum = {'ctd_cast_no'};
                varmap.position = {'niskin_bot_no'};
                varmap.fix_temp = {'fixing_temp_c'};
                varmap.conc_o2 = {'c_o2_umol_per_l'};
            case 'oxy_calc'
                vol_reag_tot = 2.0397;
        end

            case 'check_sams'
        %make this display-dependent? (or session-dependent?)
        check_sal = inf;

            case 'ladcp_proc'
        min_nvmadcpprf = 4; %throws a warning if number of vmADCP profiles within an LADCP cast is less than this
        min_nvmadcpbin = 3; %masks depths with number of valid bins less than this
        min_nvmadcpbin_refl = 3; %throws a warning if number of good profiles at any depth in the watertrack reference layer is less than this
        cfg.rawdir = fullfile(mgetdir('ladcp'),'rawdata');
            cfg.uppat = sprintf('DY181_CTD%03dS*.000',stn);
            cfg.dnpat = sprintf('DY181_CTD%03dM*.000',stn);

end