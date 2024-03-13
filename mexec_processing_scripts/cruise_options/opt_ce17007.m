switch opt1

    case 'setup'
        switch opt2
            case 'time_origin'
                MEXEC_G.MDEFAULT_DATA_TIME_ORIGIN = [2017 1 1 0 0 0];
            case 'setup_datatypes'
                use_ix_ladcp = 'no';
        end

    case 'castpars'
        switch opt2
            case 'oxyvars'
                oxyvars = {'oxygen_sbe1', 'oxygen1'};
            case 'oxy_align'
                if stnlocal>=62
                    oxy_end = 1; %truncate O oxy_align seconds before T, S
                end
        end
    
    case 'ctd_proc'
        switch opt2
            case 'redoctm'
                redoctm = 1;
            case 'cnvfilename'
                if stnlocal==23
                    let = 'c';
                    cnvfile = fullfile(mgetdir('M_CTD_CNV'),sprintf('%s_%03d%s.cnv',upper(mcruise),stnlocal,let));
                end
            case 'blfilename'
                if stnlocal==23
                    let = 'c';
                    blinfile = fullfile(mgetdir('M_CTD_CNV'),sprintf('%s_%03d%s.bl',upper(mcruise),stnlocal,let));
                end
            case 'rawshow'
                show1 = 0;
            case 'rawedit_auto'
                if stnlocal==52
                    %min(p) = -10, gsw will fall over, so NaN where p out of range
                    a = [-inf -2; 8000 inf];
                    co.badpress.press = a; co.badpress.temp1 = a; co.badpress.temp2 = a;
                end
                if stnlocal==31
                    co.badtemp1.temp1 = [-inf -2; 40 inf; NaN NaN];
                    co.badtemp1.cond1 = co.badtemp1.temp1; co.badtemp1.oxygen_sbe1 = co.badtemp1.temp1;
                elseif stnlocal==62
                    co.badtemp1.temp1 = [-inf -2; 13 inf; NaN NaN];
                    co.badtemp1.cond1 = co.badtemp1.temp1; co.badtemp1.oxygen_sbe1 = co.badtemp1.temp1;
                end
        end

    case 'check_sams'
        check_oxy = 1;
        check_sal = 1;

    case 'botpsal'
        switch opt2
            case 'sal_files'
                %in this case we have autosal and portasal files but will
                %load only autosal as "primary"
                salfiles = dir(fullfile(root_sal, ['autosal_' mcruise '_*.csv'])); 
                salfiles = {salfiles.name};
            case 'sal_parse'
                cellT = 27;                
                ssw_k15 = 0.99986;
            case 'sal_calc'
                sal_off = [
                    001 -5; 
                    002 -5;
                    006 -5;
                    007 -5;
                    008 -5;
                    ];
                sal_off(:,1) = sal_off(:,1)+999e3;
                sal_off(:,2) = sal_off(:,2)*1e-5;
        end
    case 'botoxy'
        switch opt2
            case 'oxy_files'
                ofiles = {'oxygen_calculation_newflasks2_en705.xlsx'};
                hcpat = {'Niskin';'Bottle'};
                chrows = 1:2;
                chunits = 3;
                sheets = 1:100;
            case 'oxy_parse'
                ii = find(strcmp('conc_o2',oxyvarmap(:,1)));
                oxyvarmap(ii,:) = []; %don't rename; force script to recalculate
            case 'oxy_calc'
                blanks = [.00325 .0025 .002 .003 .00325 .00325 .00225 .0035 .00275];
                %stds = [.4605; .458375; .4595];
                %stds_stns = {[2 4]; [0 1]; [5 7]};
                stds = [.4595]; stds_stns = {[0 1 2 4 5 7]};
                ds_oxy.vol_std = repmat(5,size(ds_oxy.sampnum));
                ds_oxy.vol_blank = repmat(mean(blanks),size(ds_oxy.sampnum));
                ds_oxy.vol_titre_std = ds_oxy.vol_std+NaN;
                for sno1 = 1:size(stds_stns,1)
                    m = ismember(ds_oxy.statnum,stds_stns{sno1});
                    if sum(m)
                        ds_oxy.vol_titre_std(m) = repmat(stds(sno1),sum(m),1);
                    end
                end
                vol_reag_tot = repmat(2.031,size(ds_oxy.sampnum));
            case 'oxy_flags'
                d.botoxya_flag(d.sampnum==009) = 4; %very high compared to CTD; bad sample?
                d.botoxya_flag(d.sampnum==115) = 4; %very high compared to replicate and CTD
                d.botoxyc_flag(d.sampnum==407) = 3; %a bit high compared to a and b; don't use for average
                d.botoxyb_flag(d.sampnum==509) = 3; %probably b is bad
                m = d.statnum==5; %mostly analysed with bubbles in thio tube; noisy
                d.botoxya_flag(m) = 3; d.botoxyb_flag(m) = max(d.botoxyb_flag(m),3);
                d.botoxyb_flag(d.sampnum==523) = 2; %analysed later after thio tube changed
        end

    case 'outputs'
        switch opt2
            case 'summary'
                snames = {'nsal' 'noxy'};
                sgrps = {{'botpsal'} {'botoxy'}};
            case 'exch'
                n24 = 66;
                expocode = '45CE20170000';
                sect_id = 'CE17007';
                submitter = 'DEMO'; %group institution person
                common_headstr = {'#SHIP: RV Celtic Explorer';...
                    '#Cruise CE17001';...
                    '#Region: North Atlantic';...
                    ['#EXPOCODE: ' expocode];...
                    '#DATES: 2017???? - 2017????';...
                    '#Chief Scientist: ???? (MI)'};
                if strcmp(in.type,'ctd')
                    headstring = {['CTD,' datestr(now,'yyyymmdd') submitter]};
                    headstring = [headstring; common_headstr;
                        {sprintf('#%d stations with 24-place rosette',n24);...
                        '#CTD: Who - ???? (MI) and Y. Firing (NOC); Status - final.';...
                        '#The CTD PRS; TMP; SAL; OXY data are all calibrated and good.';...
                        '# DEPTH_TYPE   : COR';...
                        '# DEPTH_TYPE   : rosette depth from CTDPRS + CTD altimeter range to bottom, or speed of sound-corrected ship-mounted bathymetric echosounder'...
                        }];
                else
                    headstring = {['BOTTLE,' datestr(now,'yyyymmdd') submitter]};
                    headstring = [headstring; common_headstr;
                        {sprintf('#%d stations with 24-place rosette',n24);...
                        '#CTD: Who - ???? (MI) and Y. Firing (NOC); Status - final';...
                        '#Notes: Includes CTDSAL, CTDOXY, CTDTMP';...
                        '#The CTD PRS; TMP; SAL; OXY data are all calibrated and good.';...
                        '# DEPTH_TYPE   : rosette depth from CTDPRS + CTD altimeter range to bottom';...
                        '#Salinity: Who - ???? (MI); Status - final; SSW batch ????.';...
                        '#Oxygen: Who - ???? (MI); Status - final.';...
                        }];
                end
        end

end