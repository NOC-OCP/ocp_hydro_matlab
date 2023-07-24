switch opt1

    case 'setup'
        switch opt2
            case 'time_origin'
                MEXEC_G.MDEFAULT_DATA_TIME_ORIGIN = [2023 1 1 0 0 0];
            case 'setup_datatypes'
                use_ix_ladcp = 'no';
        end

    case 'ship'
        switch opt2
            case 'datasys_best'
                default_navstream = 'posfur';
                default_hedstream = 'hdtgyro';
                default_attstream = 'abxtwo';
        end


    case 'castpars'
        switch opt2
            case 'nnisk'
                nnisk = 24; % There are 12 niskins numbers 1:2:23; If y
            case 's_choice'
                stns_alternate_s = []; % none yet
            case 'o_choice'
                o_choice = 2; %use sensor 2
                %stns_alternate_o = [];
            case 'bestdeps'
                iscor = 1; 
                xducer_offset = 0; %to be added
                replacedeps = [
%                     0 970     % CTD+alt
                    1 4302    % CTD+alt
                    2 4301    % CTD+alt
                    3 1403    % corrected echo sounder
                    4 1481    % corrected echo sounder
                    5 1513    % corrected echo sounder
                    6 4990    % corrected echo sounder
                    7 4993    % corrected echo sounder
                    ];
                replacealt = [
%                     0 90 % noted on ctd deck unit log; didn't approach closer than 90, so bad values occur close to bottom of cast
                    1 51 % noted on ctd deck unit log; altimeter was noisy, so bad values less than 50 could be selected as 'good'
                    2 51 % noted on ctd deck unit log; altimeter was noisy, so bad values less than 50 could be selected as 'good'
                    3 nan % didn't approach to within altimeter range
                    4 nan % didn't approach to within altimeter range
                    5 nan % didn't approach to within altimeter range
                    6 nan % didn't approach to within altimeter range
                    7 nan % didn't approach to within altimeter range
                    ];
        end

    case 'mfir_01'
        switch opt2
            case 'botflags'
                if stnlocal==5
                    niskin_flag(position==5) = 4; %misfire or late closure; very warm
                end
        end

    case 'ctd_proc'
        switch opt2
            case 'cnvfilename'
                cnvfile = fullfile(mgetdir('M_CTD_CNV'),sprintf('%s_%03d.cnv',mcruise,stnlocal));
            case 'raw_corrs'
                co.oxyhyst1230.H1 = -.043; co.oxyhyst1230.H2 = 5000;
                co.oxyhyst1230.H3 = [
                    -10 2000
                    1000 2000
                    1001 3000
                    2000 3000
                    2001 3000
                    3000 3000
                    3001 3000
                    9000 3000
                    ];
                co.oxyhyst1648.H1 = -.073; co.oxyhyst1648.H2 = 5000;
                co.oxyhyst1648.H3 = [
                    -10 500
                    1000 500
                    1001 2000
                    2000 2000
                    2001 2000
                    3000 2000
                    3001 6000
                    9000 6000
                    ];
            case 'ctd_cals'
                co.docal.temp = 1;
                co.docal.cond = 1;
                co.docal.oxygen = 1;
                co.calstr.temp.sn4333.en705 = 'dcal.temp = d0.temp + interp1([0 6000],[0 0],d0.press);';
                co.calstr.temp.sn4333.msg = 'temp s/n 4333 no adjustment';
                co.calstr.temp.sn4126.en705 = 'dcal.temp = d0.temp + interp1([-10 0 5000 6000],1*[0 0 25 25]/1e4,d0.press);';
                co.calstr.temp.sn4126.msg = 'temp s/n 4126 adjusted to agree with s/n 4333; s/n 4333 had no residual shape with bottle salinity';
                co.calstr.cond.sn2459.en705 = 'dcal.cond = d0.cond.*(1 + -7e-4)/35);';
                co.calstr.cond.sn2459.msg = 'cond s/n 2459 adjusted by -0.0007 uniform in the vertical';
                co.calstr.cond.sn1749.en705 = 'dcal.cond = d0.cond.*(1 + interp1([-10 0 300 800 1200 2000 5000 6000],([-50 -50 0 25 20 20 35 35]-7)/1e4,d0.press)/35);';
                co.calstr.cond.sn1749.msg = 'cond s/n 1749 adjusted to agree with s/n 2459 at 72 bottle stops';
                co.calstr.oxygen.sn1230.en705 = 'dcal.oxygen = d0.oxygen.*interp1([-10      0   600  1300   2000  3000  5000   6000],[1.000 1.000 1.012  1.016 1.027 1.042 1.050 1.050 ],d0.press);';
                co.calstr.oxygen.sn1230.msg = 'upcast oxygen s/n 1230 adjusted to agree with 71 samples, after applying hysteresis correction; up/down difference after hysteresis correction is of order (1 umol/kg)';
                co.calstr.oxygen.sn1648.en705 = 'dcal.oxygen = d0.oxygen.*interp1([-10     0   400  1000  1500 2000  5000  6000],[1.030 1.030 1.035 1.022 1.034 1.042 1.070 1.070],d0.press);';
                co.calstr.oxygen.sn1648.msg = 'upcast oxygen s/n 1648 adjusted to agree with 71 samples, after applying hysteresis correction; up/down difference after hysteresis correction is of order (1 umol/kg)';
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
                n12 = 7;
                expocode = '32EV20230716';
                sect_id = 'RAPID-West';
                submitter = 'OCPNOCBAK'; %group institution person
                common_headstr = {'#SHIP: RV Endeavor';...
                    '#Cruise EN705; RAPID moorings';...
                    '#Region: Western North Atlantic (subtropical)';...
                    ['#EXPOCODE: ' expocode];...
                    '#DATES: 20230716 - 20230724';...
                    '#Chief Scientist: W. Johns (U Miami)';...
                    '#Co-Chief Scientist: B. Moat (NOC)';...
                    '#Supported by grants from the UK Natural Environment Research Council.'};
                if strcmp(in.type,'ctd')
                    headstring = {['CTD,' datestr(now,'yyyymmdd') submitter]};
                    headstring = [headstring; common_headstr;
                        {sprintf('#%d stations with 12-place rosette',n12);...
                        '#CTD: Who - B. King (NOC); Status - final.';...
                        '#The CTD PRS; TMP; SAL; OXY data are all calibrated and good.';...
                        '# DEPTH_TYPE   : COR';...
                        '# DEPTH_TYPE   : rosette depth from CTDPRS + CTD altimeter range to bottom, or speed of sound-corrected ship-mounted bathymetric echosounder'...
                        }];
                else
                    headstring = {['BOTTLE,' datestr(now,'yyyymmdd') submitter]};
                    headstring = [headstring; common_headstr;
                        {sprintf('#%d stations with 12-place rosette',n12);...
                        '#CTD: Who - B. King (NOC); Status - final';...
                        '#Notes: Includes CTDSAL, CTDOXY, CTDTMP';...
                        '#The CTD PRS; TMP; SAL; OXY data are all calibrated and good.';...
                        '# DEPTH_TYPE   : rosette depth from CTDPRS + CTD altimeter range to bottom';...
                        '#Salinity: Who - B. King (NOC); Status - final; SSW batch P165.';...
                        '#Oxygen: Who - Y. Firing (NOC); Status - final.';...
                        }];
                end
        end

    case 'uway_proc'
        switch opt2
            case 'sbe21'
                badtimes = [datenum(2023,1,1) datenum(2023,7,1);
                    datenum(2023,7,26) datenum(2023,7,31)];
                badtimes = m_commontime(badtimes,'datenum',h);
                uopts.badtime.cond = badtimes;
                uopts.badtime.housingtemp = badtimes;
                uopts.badtime.psal = badtimes;
                uopts.badtime.fluor1 = badtimes;
                uopts.badtime.fluor2 = badtimes;
            case 'sbe45'
                badtimes = [
                    datenum(2023,7,14,0,0,0) datenum(2023,7,16,18,0,0)
                    datenum(2023,7,16,21,55,0) datenum(2023,7,17,16,0,0)
                    datenum(2023,7,24,14,50,0)  datenum(2023,7,31,0,0,0)
                    ];
                badtimes = m_commontime(badtimes,'datenum',h);
                uopts.badtime.cond = badtimes;
                uopts.badtime.housingtemp = badtimes;
                uopts.badtime.psal = badtimes;
        end

end