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
            case 'ctd_cals'
                co.docal.temp = 1;
                co.docal.cond = 1;
                co.docal.oxygen = 1;
                co.calstr.temp.sn4023.ce17007 = 'dcal.temp = d0.temp + d0.press*1.2e-7;';
                co.calstr.temp.sn4023.msg = 'cal for temp1, sensor 4023 based on comparison with 934 SBE35 samples';
                co.calstr.temp.sn4927.ce17007 = 'dcal.temp = d0.temp + 1e-4; dcal.temp(d0.press>2000) = d0.temp(d0.press>2000)-(d0.press(d0.press>2000)-2000)*1.5e-7;';
                co.calstr.temp.sn4927.msg = 'cal for temp2, sensor 4927 based on comparison with 934 SBE35 samples';
                co.calstr.cond.sn2764.ce17007 = 'dcal.cond = d0.cond.*(1 - (1e-4*(d0.dday-125) + 3e-7*(d0.press-2000))/35);';
                co.calstr.cond.sn2764.msg = 'cal for cond2, sensor 2764 based on comparison with 1135 salinity samples (753 deep/low gradient)';
                co.calstr.cond.sn3480.ce17007 = 'dcal.cond = d0.cond.*(1 - (2e-7*(d0.press-1000) + 2e-4*(d0.dday-132))/35);';
                co.calstr.cond.sn3480.msg = 'cal for cond1, sensor 3480 based on comparison with 1135 salinity samples (753 deep/low gradient)';
                co.calstr.oxygen.sn1416.ce17007 = 'dcal.oxygen = d0.oxygen.*(1.066-exp(-d0.press/1600)*.03);';
                co.calstr.oxygen.sn1416.msg = 'cal for oxygen1, sensor 1416 based on comparison with 1110 oxygen samples (776 deep/low gradient)';
                co.calstr.oxygen.sn3339.ce17007 = 'dcal.oxygen = d0.oxygen;';
                co.calstr.oxygen.sn3339.msg = 'no calibration data for stations 1-3 oxygen1, sensor 3339';
            case 'interp2db'
                pg = [.5:1:6e3]'; %1 dbar for this cruise rather than 2
                g2opts.int = [-.5 .5];
        end

    case 'sbe35'
        switch opt2
            case 'sbe35file'
                sbe35file = sprintf('%s_*.txt', upper(mcruise));
            case 'sbe35_flags'
                %get rid of some extra (bad) lines (based on inspection of
                %the file and comparison to .bl files)
                ii = find(t.sampnum==2301); t(ii(1:2),:) = [];
        end

    case 'check_sams'
        check_oxy = 0;
        check_sal = 0;
        calcoxy = 0; %already calculated, titre parameters not supplied
        calcsal = 0; %already calculated, conductivity ratio and temperature not supplied

    case 'botpsal'
        switch opt2
            case 'sal_files'
                root_sal = fullfile(mgetdir('M_CTD'),'BOTTLE_DATA');
                salfiles = dir(fullfile(root_sal,'CE17007_Bottle_Data_with_Metadata.xlsx'));
                salfiles = {salfiles.name};
                hcpat = {'Cast'};
            case 'sal_parse'
                ds_sal.statnum = str2num(cell2mat(cellfun(@(x) x(9:11), ds_sal.cast, 'UniformOutput', false)));
                ds_sal.sampnum = ds_sal.statnum*100+ds_sal.niskin;
                ds_sal.salinity = ds_sal.bench_salinity;
                ds_sal.salinity(ds_sal.salinity<-900) = NaN;
                ds_sal.flag = 2+zeros(size(ds_sal.salinity));
                ds_sal.flag(isnan(ds_sal.salinity)) = 9;
                ds_sal.flag(ismember(ds_sal.sampnum,[201 401 404 724 917 1210 1218 1219 1309 1310 1311 1312 1313 1319 1320 1321 1401])) = 4;
                ds_sal.flag(ismember(ds_sal.sampnum,[1314 1315])) = 3;
                sal_adj_comment = 'salinity from spreadsheet, no information on standardisation';
        end

    case 'botoxy'
        switch opt2
            case 'oxy_files'
                root_oxy = fullfile(mgetdir('M_CTD'),'BOTTLE_DATA');
                ofiles = dir(fullfile(root_oxy,'CE17007_Bottle_Data_with_Metadata.xlsx'));
                ofiles = {ofiles.name};
                hcpat = {'Cast'};
                chrows = 1;
                chunits = [];
                sheets = 1;
            case 'oxy_parse'
                ds_oxy.statnum = str2num(cell2mat(cellfun(@(x) x(9:11), ds_oxy.cast, 'UniformOutput', false)));
                ds_oxy.sampnum = ds_oxy.statnum*100+ds_oxy.niskin;
                ds_oxy.botoxy_umol_per_kg = ds_oxy.winkler_do_umol_per_kg;
                ds_oxy.flag = 2+zeros(size(ds_oxy.botoxy_umol_per_kg));
                ds_oxy.flag(isnan(ds_oxy.botoxy_umol_per_kg)) = 9;
                ds_oxy.flag(ismember(ds_oxy.sampnum,[2025])) = 4;
                ds_oxy.flag(ismember(ds_oxy.sampnum,[2207 4108 4614 3049 2615 2841 5410 5509 5807 5820 6012])) = 3;
                ds_oxy.flag(ismember(ds_oxy.statnum,[27])) = 4;
        end

    case 'outputs'
        switch opt2
            case 'summary'
                snames = {'nsal' 'noxy'};
                sgrps = {{'botpsal'} {'botoxy'}};
            case 'exch'
                n24 = 54;
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
                        '#CTD: Who - ???? (MI) and Participant-22; Status - final.';...
                        '#The CTD PRS; TMP; SAL data are all calibrated and good';...
                        'CTD OXY data STNNBRs 1-3 are uncalibrated; CTD OXY data STNNBRs 4-66 are calibrated and good.'}];
                else
                    headstring = {['BOTTLE,' datestr(now,'yyyymmdd') submitter]};
                    headstring = [headstring; common_headstr;
                        {sprintf('#%d stations with 24-place rosette',n24);...
                        '#CTD: Who - ???? (MI) and Participant-22 (NOC); Status - final';...
                        '#Notes: Includes CTDSAL, CTDOXY, CTDTMP';...
                        '#The CTD PRS; TMP; SAL; data are all calibrated and good; CTD OXY data from STNNBRs 4-66 are calibrated and good.';...
                        '#Salinity: Who - ???? (MI); Status - final; SSW batch ????.';...
                        '#Oxygen: Who - ???? (MI); Status - final.';...
                        }];
                end
        end

end