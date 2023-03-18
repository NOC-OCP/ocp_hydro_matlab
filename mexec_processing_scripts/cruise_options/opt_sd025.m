%cruise-specific options for sd025
testcasts = [3 4 7 11:12]; %***dips too short to process?
ticasts = [3 4 7 11:24 31:32 36 40 45:47 50 54 57 59 61 63 68 76 161:174]; %Ti frame
racasts = [37 38 39 41 setdiff(48:65,ticasts)]; %for Radium
shortcasts = [3 4 7 11 12 13 37 38 39 41 48 51:53 67 175 178 180]; %no altimeter bottom depth / no LADCP BT
shallowcasts = [3 4 7 10 11:13 77 171]; %too shallow to process ladcp, or (cast 10) missing too much CTD

switch opt1

    case 'setup'
        switch opt2
            case 'time_origin'
                MEXEC_G.MDEFAULT_DATA_TIME_ORIGIN = [2023 1 1 0 0 0];
        end

    case 'ship'
        switch opt2
            case 'rvdas_database'
                RVDAS.machine = 'sdl-rvdas-s1.sda.bas.ac.uk';
                %local(ly) mounted directory in this case (legwork)
                RVDAS.jsondir = '/local/users/pstar/mounts/public/data_management/documentation/json_sensor_files/';
                RVDAS.user = 'rvdas_ro';
                RVDAS.database = ['"' '20210321' '"'];
            case 'datasys_best'
                default_navstream = 'gnss_seapath_320_2';
                default_hedstream = 'attitude_seapath_320_2_heading';
        end

    case 'castpars'
        switch opt2
            case 'oxy_align'
                oxy_end = 1;
            case 'nnisk'
                if ismember(stnlocal,[12 45 64 67 70 72:74 77 79 80 82 83 85:160 162:166 169:174])
                    nnisk = 0;
                elseif ismember(stnlocal,[13:21 23 42:44 46])
                    nnisk = 12;
                end
            case 'o_choice'
                stns_alternate_o = [1 2 5 6 8 9];
        end

    case 'ctd_proc'
        switch opt2
            case 'redoctm'
                redoctm = 1;
            case 'cnvfilename'
                if ismember(stnlocal,ticasts)
                    cnvfile = sprintf('%s_%03d_Ti.cnv',upper(mcruise),stnlocal);
                else
                    cnvfile = sprintf('%s_%03d_SS.cnv',upper(mcruise),stnlocal);
                end
                cnvfile = fullfile(mgetdir('M_CTD_CNV'),cnvfile);
            case 'cast_split'
                if stnlocal==3
                    %this file contains 3 and 4
                    otfiles = {otfile; fullfile(mgetdir('ctd'),sprintf('ctd_%s_%03d_raw_noctm.nc',mcruise,4))};
                    cast_scan_ranges = [1 20276; 20277 47077];
                end
            case 'rawedit_auto'
                if ismember(stnlocal,[10 31 42 43 44 48 49 51:53 55:56 58 64])
                    %large spikes: SS cable problem (10) and cable and/or SBE9 problem(s)
                    a = [-inf -2; 8000 inf];
                    b = [-inf -2; 40 inf; NaN NaN];
                    co.badpress.press = a; co.badpress.temp1 = a; co.badpress.temp2 = a;
                    co.badtemp1.temp1 = b; co.badtemp1.cond1 = b; co.badtemp1.oxygen_sbe1 = b;
                    co.badtemp2.temp2 = b; co.badtemp2.cond2 = b; co.badtemp2.oxygen_sbe2 = b;
                elseif ismember(stnlocal,ticasts) && stnlocal>23
                    %sensor 2 is bad
                    co.badtemp2.temp2 = [-inf -2; 40 inf; NaN NaN];
                    co.badtemp2.cond2 = co.badtemp2.temp2;
                    co.badtemp2.oxygen_sbe2 = co.badtemp2.temp2;
                end
                if ismember(stnlocal,[31 42 43 64])
                    co.rangelim.cond1 = [27 34];
                    co.rangelim.cond2 = [27 34];
                end
                if ~ismember(stnlocal,ticasts) && stnlocal<=35
                    %bad coefficients for transmittance/attenuation on SS rosette
                    co.rangelim.transmittance = [50 110];
                    co.rangelim.attenuation = [-0.5 5];
                end
                if ismember(stnlocal,[43 64]) %***still need hand editing
                    co.despike.press = [3 2 2];
                    co.despike.temp1 = [1 0.1];
                    co.despike.temp2 = [1 1 0.1 0.1];
                    co.despike.cond1 =[0.5 0.5 0.05 0.05];
                    co.despike.cond2 = [0.5 0.5 0.05 0.05];
                    co.despike.oxygen_sbe1 = [3 2 2 1 1];
                    co.despike.oxygen_sbe2 = [3 2 2 1 1];
                end
                if stnlocal==177 %cond2 went bad (and is used for oxygen2)
                    co.badscan.cond2 = [1.58588e5 inf];
                    co.badscan.oxygen_sbe2 = [1.58588e5 inf];
                elseif stnlocal==178 %not changed yet, still bad
                    co.badscan.cond2 = [-inf inf];
                    co.badscan.oxygen_sbe2 = [-inf inf];
                end
            case 'raw_corrs'
                co.oxyhyst0620.H1 = -.028; co.oxyhyst0620.H2 = 4000;
                co.oxyhyst0620.H3 = [-10 800; 2000 800; 2001 2400; 6000 2400];
                co.oxyhyst2291.H1 = -.037; co.oxyhyst2291.H2 = 5000;
                co.oxyhyst2291.H3 = [-10 500; 1500 500; 1501 1200; 3000 1200; 3001 1500; 6000 1500];
                co.oxyhyst4250.H1 = -.033; co.oxyhyst4250.H2 = 5000;
                co.oxyhyst4250.H3 = [-10 600; 2500 600; 2501 1450; 6000 1450];
                co.oxyhyst4252.H1 = -.025; co.oxyhyst4252.H2 = 4200;
                co.oxyhyst4252.H3 = [-10 800; 3000 800; 3001 1450; 6000 1450];
                %                 if ismember(stnlocal,ticasts) && stnlocal>23
                %                     %recalculate oxygen2 using temp1 and cond1
                %                     %*** for this to work, must smooth dV/dt***
                %                     co.dooxy2V = 1;
                %                     %and coefficients corresponding to oxygen sensor 2 from
                %                     %xmlcon (should parse from header in future***)
                %                     co.oxy2Vcoefs.Soc = 5.7890e-1;
                %                     co.oxy2Vcoefs.Voff = -0.5201;
                %                     co.oxy2Vcoefs.A = -4.1247e-3;
                %                     co.oxy2Vcoefs.B = 1.5900e-4;
                %                     co.oxy2Vcoefs.C = -2.8246e-6;
                %                     co.oxy2Vcoefs.D0 = 2.5826e+0;
                %                     co.oxy2Vcoefs.D1 = 1.92634e-4;
                %                     co.oxy2Vcoefs.D2 = -4.64803e-2;
                %                     co.oxy2Vcoefs.E = 3.6000e-2;
                %                     co.oxy2Vcoefs.Tau20 = 1.3200;
                %                 end
            case 'ctd_cals'
                co.docal.temp = 1;
                co.docal.cond = 1;
                co.docal.oxygen = 1;
                %stainless
                co.calstr.temp.sn2191.sd025 = 'dcal.temp = d0.temp + interp1([0 6000],[-1.1e-3 -2.3e-3],d0.press) - 3e-4;';
                co.calstr.temp.sn2191.msg = 'temp s/n 2191 calibrated based on comparison with 489/960 SBE35 measurements';
                co.calstr.temp.sn5649.sd025 = 'dcal.temp = d0.temp + interp1([0 6000],[0.2e-3 -0.9e-3],d0.press) - 2e-4;';
                co.calstr.temp.sn5649.msg = 'temp s/n 5649 calibrated based on comparison with 489/960 SBE35 measurements';
                co.calstr.cond.sn3248.sd025 = 'dcal.cond = d0.cond.*(1 + interp1([0 6000],[0.5e-3 1e-3],d0.press)/35);';
                co.calstr.cond.sn3248.msg = 'cond s/n 3248 calibrated based on comparison with 41/51 bottle samples';
                co.calstr.cond.sn3488.sd025 = 'dcal.cond = d0.cond.*(1 + interp1([0 6000],[0.2e-3 -4.4e-3],d0.press)/35);';
                co.calstr.cond.sn3488.msg = 'cond s/n 3488 calibrated based on comparison with 122/189 bottle samples';
                co.calstr.cond.sn3491.sd025 = 'dcal.cond = d0.cond.*(1 + interp1([0 4000 6000],[-4e-3 -5e-3 -3e-3],d0.press)/35);';
                co.calstr.cond.sn3491.msg = 'cond s/n 3491 calibrated based on comparison with 188/269 bottle samples';
                %oxygen.sn242 only 4 comparison points
                co.calstr.oxygen.sn0620.sd025 = 'dcal.oxygen = d0.oxygen.*(interp1([0 1000 6000],[0.875 0.887 0.90],d0.press) + interp1([30 70],[-8e-3 8e-3],d0.dday));';
                co.calstr.oxygen.sn0620.msg = 'oxygen s/n 620 calibrated based on comparison between 97/140 bottle samples and gamma_n-matched downcast';
                co.calstr.oxygen.sn2291.sd025 = 'dcal.oxygen = d0.oxygen.*(1.22 + interp1([0 500 4000 6000],[0e-2 0.5e-2 2e-2 1e-2],d0.press));';
                co.calstr.oxygen.sn2291.msg = 'oxygen s/n 2291 calibrated based on comparison with 95/145 bottle samples and gamma_n-matched downcast';
                %Ti: no SBE35 on Ti frame, so no cal for 6572 (temp1) or 6685, 6674 (temp2)
                co.calstr.cond.sn4876.sd025 = 'dcal.cond = d0.cond.*(1 + interp1([0 2500 6000],[2e-3 -3e-3 -3e-3],d0.press)/35 + interp1([-2 9],[1.5e-3 -3e-3],d0.temp)/35);';
                co.calstr.cond.sn4876.msg = 'cond s/n 4876 calibrated based on comparison with 140/184 bottle samples';
                co.calstr.cond.sn4918.sd025 = 'dcal.cond = d0.cond.*(1 + interp1([0 6000],[3e-3 -4e-3],d0.press)/35);';
                co.calstr.cond.sn4918.msg = 'cond s/n 3248 calibrated based on comparison with 70/90 bottle samples';
                %oxygen.sn4244 no good cal data
                co.calstr.oxygen.sn4250.sd025 = 'dcal.oxygen = d0.oxygen.*(interp1([0 6000],[1.03 1.07],d0.press));';
                co.calstr.oxygen.sn4250.msg = 'oxygen s/n 4250 calibrated based on comparison with 39/61 bottle samples and gamma_n-matched downcast';
                co.calstr.oxygen.sn4252.sd025 = 'dcal.oxygen = d0.oxygen.*(interp1([-2 3 20],[1.085 1.055 1.03],d0.temp)) ;' ;
                %co.calstr.oxygen.sn4252.sd025 = 'dcal.oxygen = d0.oxygen.*(interp1([0 6000],[1.05 1.085],d0.press));';
                co.calstr.oxygen.sn4252.msg = 'oxygen s/n 4252 calibrated based on comparison with 53/89 bottle samples and gamma_n-matched downcast';
                %co.calstr.oxygen.sn4252.msg = 'oxygen s/n 4252 calibrated based on comparison between 24/77 bottle samples and gamma_n-matched downcast';
end

    case 'mfir_01'
        switch opt2
            case 'blinfile'
                if stnlocal==4 %ctd wasn't stopped and restarted, has been split in mctd_01, so 003.bl is actually for cast 004
                    blinfile = fullfile(root_botraw,sprintf('%s_%03d_',upper(mcruise),3));
                elseif stnlocal~=3
                    blinfile = fullfile(root_botraw,sprintf('%s_%03d_',upper(mcruise),stnlocal));
                end
                if ismember(stnlocal,ticasts)
                    blinfile = [blinfile 'Ti.bl'];
                else
                    blinfile = [blinfile 'SS.bl'];
                end
            case 'nispos'
                if nnisk == 12
                    niskc = [2:2:24]';
                    niskn = [2:2:24]';
                end
            case 'botflags'
                %3 = leak, 4 = misfire, 7 = possible leak (unclear,
                %investigate further), 9 = no samples (can remove from list
                %once confirmed there were no sample values loaded)
                switch stnlocal
                    case 2 % CTD number
                        niskin_flag(ismember(position,[2 11 16])) = 4 ;
                        %niskin_flag(ismember(position,[20 21 22 23 24])) = 7 ;
                    case 6
                        niskin_flag(ismember(position, [2 8])) = 3;
                        niskin_flag(position==21) = 4 ;
                    case 8
                        niskin_flag(ismember(position,[2 14])) = 3 ;
                        niskin_flag(position==21) = 4 ;
                    case 9
                        niskin_flag(ismember(position,[2])) = 3 ; %23: cable stuck in tap
                        niskin_flag(position==[21 23]) = 4 ;
                    case 10
                        niskin_flag(position==2) = 4 ; %from sample data, looks like it might have closed shallower
                    case 15
                        %niskin_flag(ismember(position,[12 20])) = 7; %possible leaks
                    case 19
                        niskin_flag(ismember(position,[24])) = 4; %fired on the fly? salt and nuts definitely bad
                    case 22
                        %niskin_flag(position==7) = 3; %leaking from handle. nuts look fine
                    case 23
                        niskin_flag(ismember(position,[2 4 6 12 14])) = 3 ; 
                    case 24
                        niskin_flag(ismember(position,[6 8 10 14 18 20 22 24])) = 4 ;
                    case 25
                        niskin_flag(ismember(position,[2])) = 3 ;
                        niskin_flag(position==21) = 4 ;
                    case 26
                        niskin_flag(position==2) = 3; %bad nuts and botoxytemp, could be closed shallow or could be leaked
                        niskin_flag(position==21) = 4 ;
                    case 27
                        niskin_flag(~ismember(position,[13 23])) = 3 ; % top valve open/no valve
                    case 28
                        niskin_flag(position==2) = 3; %bad nuts, hard to see as misfire, probably leak
                    case 29
                        %niskin_flag(ismember(position,[1])) = 7 ;
                        %niskin_flag(position==2) = 7 ; % valve pushed in, 'dodgy'
                        %niskin_flag(ismember(position,[4])) = 7 ; % screw loose
                    case 32
                        niskin_flag(position==2) = 3 ;
                    case 35
                        niskin_flag(ismember(position,[1 2])) = 3 ; % 'thin stream on opening', silc suspicious
                        niskin_flag(position==21) = 3 ; %'bottom seepage'
                    case 39
                        niskin_flag(position==13) = 3 ; % 'total leak'
                    case 40
                        niskin_flag(ismember(position,[18 19 20 21])) = 3 ; %nuts suspicious?
                    case 41
                        niskin_flag(position==21) = 3 ;
                    case 44
                        niskin_flag(ismember(position,[18 23])) = 3 ;  % O-ring?
                    case 46
                        niskin_flag(ismember(position,[18 22])) = 3 ; % open at bottom
                        niskin_flag(ismember(position,[2 4 8 10 16])) = 3 ; % open at top
                    case 48
                        niskin_flag(ismember(position,[22])) = 4 ; % did not fire
                    case 51
                        niskin_flag(ismember(position,[8 21])) = 3 ;
                    case 53
                        niskin_flag(position==21) = 3 ;
                    case 54
                        niskin_flag(position==12) = 3 ; % cannot pressurise, and nuts suspicious
                    case 55
                        %niskin_flag(position==1) = 7; %nuts maybe suspicious? hard to tell as no other points this stn (though nuts drawn on 7,8,14,15,20,22)***
                        %niskin_flag(position==7) = 7 ; % once opened at top
                    case 57
                        niskin_flag(ismember(position,[13 22 23])) = 3 ; % open at the top
                    case 60
                        niskin_flag(ismember(position,[6 12])) = 3 ;
                    case 75 %***not plotted by checkbottles_02
                        %niskin_flag(ismember(position,[8 9 13 22])) = 7 ; % from tap
                        niskin_flag(position==1) = 3;
                    case 78 %***not plotted by checkbottles_02
                        niskin_flag(position==21) = 3 ;
                    case 81
                        niskin_flag(ismember(position,[21 23 24])) = 3 ;
                    case 176
                        niskin_flag(ismember(position,[21])) = 3 ;
                        %niskin_flag(position==2) = 7;
                    case 179
                        niskin_flag(position==8) = 3; %leak: water flowing
                        %niskin_flag(ismember(position,[5 14])) = 7; %possible leak; thin stream when tap pushed in
                    case 181
                        %niskin_flag(ismember(position,[16 24])) = 7; %continuous drip from bottom after opening
                end
        end

    case 'check_sams'
        check_sal = 170; %start plotting sample readings from this station
        check_oxy = 1; %done
        check_sbe35 = 1;

    case 'sbe35'
        switch opt2
            case 'sbe35file'
                sbe35file = sprintf('%s_*_sbe35.asc', upper(mcruise));
                stnind = [7:9];
            case 'sbe35_flags'
                %get rid of some extra (bad) lines (based on inspection of
                %the files and in some cases comparison to .bl files)
                t(t.sampnum==100,:) = [];
                ii = find(t.sampnum==2504); t(ii(1),:) = [];
                ii = find(t.sampnum==2822); t(ii(1),:) = [];
                ii = find(t.sampnum==4101); t(ii(2),:) = [];
                ii = find(t.sampnum==4401); t(ii(1),:) = [];
                ii = find(t.sampnum==4801); t(ii(1),:) = [];
                ii = find(t.sampnum==5318); t(ii(2),:) = [];
        end

    case 'botoxy'
        switch opt2
            case 'oxy_files'
                ofiles = {'oxygen_calculation_newflasks_sd025_4.xlsx'};
                hcpat = {'Niskin';'Bottle'};
                chrows = 1:2;
                chunits = 3;
                sheets = 1:100;
            case 'oxy_parse'
                ii = find(strcmp('conc_o2',oxyvarmap(:,1)));
                oxyvarmap(ii,:) = []; %don't rename, recalculate
            case 'oxy_calc'
                ds_oxy.vol_std = repmat(5,size(ds_oxy.sampnum));
                ds_oxy.vol_blank = repmat(-0.00808333,size(ds_oxy.sampnum));
                ds_oxy.vol_titre_std = repmat(0.4540,size(ds_oxy.sampnum));
                ds_oxy.vol_blank(ds_oxy.statnum>=28 | ds_oxy.statnum==26) = -0.00854167;
                ds_oxy.vol_titre_std(ds_oxy.statnum>=28 | ds_oxy.statnum==26) = 0.4241;
                ds_oxy.vol_blank(ds_oxy.statnum>=177) = -0.00691667;
                ds_oxy.vol_titre_std(ds_oxy.statnum>=177) = 0.4264;
                vol_reag_tot = 0.997*2;
            case 'oxy_flags'
                %dispensers fixed around ctd9
                ii = find(d.statnum<9); 
                d.botoxya_flag(ii) = max(d.botoxya_flag(ii),4);
                d.botoxyb_flag(ii) = max(d.botoxyb_flag(ii),4);
                %tubing size fixed around 14 or 15 (14 and 15 profiles look
                %okay)
                ii = find(d.statnum<14); 
                d.botoxya_flag(ii) = max(d.botoxya_flag(ii),3);
                d.botoxyb_flag(ii) = max(d.botoxyb_flag(ii),3);
                %tm-clean samples taken with too-stiff tube
                ii = find(ismember(d.statnum,[32 40 47 54 61]));
                d.botoxya_flag(ii) = max(d.botoxya_flag(ii),4);
                d.botoxyb_flag(ii) = max(d.botoxyb_flag(ii),4);
                %duplicates where based on comparison with ctd profile we
                %think one is bad or questionable
                d.botoxya_flag(ismember(d.sampnum,[1504 6811])) = 4;
                d.botoxya_flag(ismember(d.sampnum,[1624 2913])) = 3;
                d.botoxya_per_l(d.botoxya_flag==4) = NaN;
                d.botoxyb_flag(ismember(d.sampnum,[1512 17915])) = 3;
                d.botoxyb_per_l(d.botoxyb_flag==4) = NaN;
                %duplicates that differ but not clear which is better
                ii = find(abs(d.botoxya_per_l-d.botoxyb_per_l)>=1 & d.botoxya_flag==2 & d.botoxyb_flag==2);
                d.botoxya_flag(ii) = 3; d.botoxyb_flag(ii) = 3;
                %marked as bad but looks okay
                d.botoxya_flag(d.sampnum==2320) = 2;
                %outliers
                d.botoxya_flag(ismember(d.sampnum,[2122])) = 3;
        end

    case 'botpsal'
        switch opt2
            case 'sal_parse'
                cellT = 21;
                ssw_k15 = 0.99986;
            case 'sal_calc'
                sal_off = [008 -3; 009 +1; ...
                    010 -2; 011 +1; 012 +0; 013 -0; ...
                    014 -4; 015 -3; 016 -2; 017 -2; 018 -3; 019 -2; 020 -2; ...
                    021 -1; 022 +1; ...
                    023 -5; 024 -1; ...
                    025 -6; 026 -3; 027 -6; ...
                    028 -4; 029 -4; 030 -1; ...
                    031 -2; 032 -2; 033 -2; 034 +0; ...
                    035 -2; 036 -0; ... 
                    037 -4; 038 -3; ... 
                    039 -6; 040 -6; ... 
                    041 -6; 042 -5; ... %missed standards numbers (no skipped standards/sheets)
                    047 -5; 048 -8; ... %very large spread on 48, but it's -8 for the next run too; flag all between 47 and 48?
                    049 -8; 050 -8; ... %flag these for temperature being too high?
                    051 -20; 052 -20; ... %temperature fixed but clearly there has been significant drift in standardisation
                    053 -20; 054 -18; ...
                    055 +15; 056 +16; ... %temperature problems again: 17.6 C. restandardised before this to 1.99989 (mistake)
                    057 +20; 058 +22; ... %temperature problems again: 18.8 C
                    059 -2; 060 +3; 061 +1; ... %restandardised before this to 1.99972
                    062 -2; 063 -1; ...
                    064 -1; 065 +2; ...
                    99 NaN %just to make sure we don't interpolate across the two machines!
                    101 0; 102 -1; 103 0 %very large spread/excluded 2 from 101 and 1 from 103***
                    ];
                sal_off(:,1) = sal_off(:,1)+999e3;
                sal_off(:,2) = sal_off(:,2)*1e-5;
                sal_off_base = 'sampnum_list';
            case 'sal_flags'
                ii = find(ds_sal.sampnum==999047):find(ds_sal.sampnum==999050);
                ds_sal.flag(ii) = 3;
                ii = find(ds_sal.sampnum==999051):find(ds_sal.sampnum==999054);
                ds_sal.flag(ii) = 3;
                ii = find(ds_sal.sampnum==999055):find(ds_sal.sampnum==999058);
                ds_sal.flag(ii) = 3;
                %outliers?
                ds_sal.flag(ismember(ds_sal.sampnum,[1002 1902 1904 2122 3515 3516 4713 6618 6619 6622])) = 3;
        end

    case 'botnut'
        switch opt2
            case 'nut_parse_flag'
                for no = 1:size(ds_nut,1)
                    a = ds_nut.ctdbot(no);
                    a = replace(replace(a{1},'CTD',''),'BOT','');
                    ii = strfind(a,'_');
                    if length(ii)<3; ii(3) = length(a)+1; end
                    s = str2double(a(ii(1)+1:ii(2)-1))*100 + str2double(a(ii(2)+1:ii(3)-1));
                    ds_nut.sampnum(no) = s;
                end
                m = strncmpi('suspect',ds_nut.comment,7);
                ds_nut.flag(m) = 3;
                %outliers in 2 or 3 parameters
                m = ismember(ds_nut.sampnum,[904 1520 2519 2915 2916 4018 4019 4020 4021]);
                ds_nut.flag(m) = 3;
                %niskins at same depths different
                m = ismember(ds_nut.sampnum,[16701 16702 16704 16706 16708 16709]);
                ds_nut.flag(m) = 3;
            case 'nut_param_flag'
                %outliers in individual parameters
                m = ismember(dnew.sampnum,[1504 1706 1816 1902 1904 2503 2603 2903 2917 2918 6216]);
                dnew.silca_flag(m) = 3;
                m = ismember(dnew.sampnum,[2221 2421 2622 2819 2821 3221 4201 6619 6622 7523 8413 16123 16124 16716 16717]);
                dnew.phosa_flag(m) = 3; dnew.phosb_flag(2421) = 3;
                m = ismember(dnew.sampnum,[2509 2518 3308 3312 3314 3315 3318 3319 3321 6201 5901 5902 5904 16103 16812 16823 16824]);
                dnew.totnita_flag(m) = 3; dnew.nitritea_flag(m) = 3; %***
        end

    case 'best_station_depths'
        switch opt2
            case 'bestdeps'
                iscor = 0; %these are depths from ea640 not em122, and have not had corrections applied***except when they're from other ctd?
                xducer_offset = 0; %to be added
                replacedeps = [3 164; 4 164; 7 667; 8 959; ...
                    11 2641; 12 2640; ...
                    13 3025; 14 3021; ...
                    31 3473; 33 3459; 34 3460; ...
                    37 3179; 38 3178; ...
                    39 3049; 40 3049; 41 3048; ...
                    45 593;
                    48 2729; 49 2730; ...
                    51 2562; 52 2562; 53 2563; ...
                    56 999; ...
                    64 2820; 65 2819; ...
                    77 440; ...
                    175 3386; ...
                    178 5300; 180 5600];
        end

    case 'batchactions'
        switch opt2
            case 'output_for_others'
                pdir = '~/mounts/public/scientific_work_areas/hydrography/casts/';
                clear s
                n = 1; [s(n),~] = system(['rsync -au --delete ~/cruise/data/ctd/ctd*24hz.nc ' pdir 'ctd_24hz/']);
                n = n+1; [s(n),~] = system(['rsync -au --delete ~/cruise/data/ctd/ctd*2db.nc ' pdir 'ctd_2dbar/']);
                n = n+1; [s(n),~] = system(['rsync -au ~/cruise/data/ctd/sam_sd025_all.nc ' pdir]);
                n = n+1; [s(n),~] = system(['rsync -au ~/cruise/data/collected_files/station_summary* ' pdir]);
                n = n+1; [s(n),~] = system(['rsync -au --delete ~/cruise/data/collected_files/74JC* ' pdir]);
                if sum(s)>0; warning('some or all syncing failed'); end
        end

    case 'outputs'
        switch opt2
            case 'ladcp'
                if stnlocal>=85 && stnlocal<=88
                    cfg.stnstr = '085_088';
                elseif stnlocal>=89 && stnlocal<=156
                    cfg.stnstr = '089_156';
%                elseif stnlocal==175
%                    cfg.p.timoff =  0.02083 ; %days
                end
            case 'exch'
                n0 = 14;
                n12 = 100;
                n24 = 181-1-n0-n12;
                expocode = '74JC20230131';
                sect_id = 'SR1b';
                submitter = 'OCPNOCYLF'; %group institution person
                common_headstr = {'#SHIP: RRS Sir David Attenborough';...
                    '#Cruise SD025; Polar Science Trials';...
                    '#Region: Eastern subpolar North Atlantic';...
                    ['#EXPOCODE: ' expocode];...
                    '#DATES: 20230131 - 20230320';...
                    '#Chief Scientist: S. Fielding (BAS), K. Hendry (BAS)';...
                    '#Supported by grants from the UK Natural Environment Research Council.'};
                if strcmp(in.type,'ctd')
                    headstring = {['CTD,' datestr(now,'yyyymmdd') submitter]};
                    headstring = [headstring; common_headstr;
                        {sprintf('#%d stations with 12-place rosette; %d stations with 24-place rosette; %d stations without bottles',n12,n24,n0);...
                        '#CTD: Who - Y. Firing; Status - final.';...
                        '#The CTD PRS; TMP; SAL; OXY data are all calibrated and good.';...
                        '# DEPTH_TYPE   : COR';...
                        '# DEPTH_TYPE   : rosette depth from CTDPRS + LADCP or CTD altimeter range to bottom, or speed of sound-corrected ship-mounted bathymetric echosounder'...
                        }];
                else
                    headstring = {['BOTTLE,' datestr(now,'yyyymmdd') submitter]};
                    headstring = [headstring; common_headstr;
                        {sprintf('#%d stations with 12-place rosette; %2d stations with 24-place rosette',n12,n24);...
                        '#CTD: Who - Y. Firing (NOC); Status - final';...
                        '#Notes: Includes CTDSAL, CTDOXY, CTDTMP';...
                        '#The CTD PRS; TMP; SAL; OXY data are all calibrated and good.';...
                        '# DEPTH_TYPE   : rosette depth from CTDPRS + LADCP or CTD altimeter range to bottom';...
                        '#Salinity: Who - Y. Firing; Status - final; SSW batch P165.';...
                        '#Oxygen: Who - I Seguro (UEA); Status - final.';...
                        '#Nutrients: Who - M. Woodward (PML) and E. Mawji (NOC); Status - preliminary';...
                        '#Carbon: Who - D. Pickup and D. Bakker (UEA); Status - not yet analysed '; ...
                        '#Carbon isotopes: Who - X. Shi and Y. Wu (Ximeng University); Status - not yet analysed'; ...
                        '#Chlorophyll: Who - A. Belcher (BAS); Status - not yet analysed';...
                        '#POC, POM: Who - G. Dallolmo and G. Stowasser (BAS); Status - not yet analysed';...
                        }];
                end
                vars_rename = {'CTDTURB' 'CTDBETA650_124'}; %confirmed 650; probably 124? 
            case 'grid'
                sam_gridlist = {'botoxy' 'silc' 'phos' 'totnit'};
                switch section
                    case 'sr1b'
                        kstns = [5 6 8 9 10 14:21 23:30 32 35 42:46]; % 11 is also at DP6. 22 at DP14.
                        mgrid.zpressgrid = [0 5 25 50 75 100 175 250 375 500 625 750 875 1000 1250 1500 1750 2000 2250 2500 2750 3000 3250 3500 3750 4000 4250 4500 4750]';
                        mgrid.xlim = 2; mgrid.zlim = 4;
                    case 'tm' %the line that branches off sr1b to the east
                        kstns = [32 36 40 47 50 54 57 59 63] ; % 61 68 76 161: trace metals also sampled
                        mgrid.zpressgrid = [0 5 25 50 75 100 175 250 375 500 625 750 875 1000 1250 1500 1750 2000 2250 2500 2750 3000 3250 3500]';
                    case 'picbox'
                        kstns = [68:70 72 71 73:75 79:83];
                    case 'kgb'
                        kstns = [167 162 174 163 173 164 166]; %165 just before 166
                        mgrid.xstatnumgrid = [kstns; [1 2 4 5 6 7 9]];
                    case 'ab'
                        kstns = 168:172;
                    case 'profiles_only'
                        kstns = [1 2 5 6 8:12 14:30 32:76 78:181]; %ignore very shallow ones***
                        %mgrid.x = [20 21 22 23];
                end
        end

    case 'ladcp_proc'
        if contains(cfg.stnstr,'_')
            [dd,hd] = mloadq(fullfile(mgetdir('ctd'),sprintf('dcs_%s_%03d',mcruise,stnlocal)),'time_start time_end ');
            dd.dnum_start = m_commontime(dd,'time_start',hd,'datenum');
            dd.dnum_end = m_commontime(dd,'time_end',hd,'datenum');
            cfg.p.time_start_force = round(datevec(dd.dnum_start-2/60/24));
            cfg.p.time_end_force = round(datevec(dd.dnum_end+2/60/24));
        end
        minps = [15 11; 17 19; 19 14; 23 12; 42 14; 45 18; 65 10];
        if ismember(stnlocal,minps(:,1))
            cfg.p.cut = minps(minps(:,1)==stnlocal,2)+1;
        end

    case 'uway_proc'
        switch opt2
            case 'tsg_avedits'
                minflow = 400;
%         check_tsg = 1;
            case 'tsg_cals'
                clear uo
                uo.docal.salinity = 1;
                uo.calstr.salinity.pl.sd025 = 'dcal.salinity = d0.salinity - (-8.1657e-4*d0.time/86400 + 0.0178);';
            case 'sensor_unit_conversions'
                if contains(abbrev,'sonic')
%                     sensors_to_cal={'fluo';'trans';'parport';'tirport';'parstarboard';'tirstarboard'};
%                     sensorcals={
%                         'y=(x1-0.055)*16.3'; % fluorometer: s/n WS3S-246 cal 13 Jan 2022
%                         'y=(x1-0.058)/(4.707-0.058)*100' %transmissometer: s/n CST-112R cal 14 Mar 2021
%                         'y=x1/1.059' % port PAR: s/n 28559 cal 23 Mar 2021
%                         'y=x1/1.134' % port TIR: 994132 cal 6 Apr 2021
%                         'y=x1/1.016' % stb PAR: s/n 28560 cal 23 Mar 2021
%                         'y=x1/1.065'}; % stb TIR: 047463 cal 18 Aug 2021
%                     %                         % the surfmet instrument box is outputting in V*1e-5 for PAR/TIR already
%                     sensorunits={'ug/l';'percent';'W/m2';'W/m2';'W/m2';'W/m2'};
                end
        end

    case 'msam_ashore_flag'
        switch opt2
            case 'sam_ashore_clean'
                fnin = {fullfile(mgetdir('M_BOT_ISO'),'CTD_bottle_cop_clean.xlsx')};...
                varmap = {'statnum' 'CTDCastNumber' ' '
                    'position' 'PositionNumber' ' '
                    'dic_flag' 'DIC' 'num_samples'
                    'd13dic_flag' 'd13DIC' 'num_samples'
                    'silc_flag' 'Nuts' 'num_samples'
                    'phos_flag' 'Nuts' 'num_samples'
                    'totnit_flag' 'Nuts' 'num_samples'
                    'botchl_flag' 'Chl' 'num_samples'
                    'd30si_flag' 'd30Si' 'num_samples'
                    'poc_flag' 'POC' 'num_samples'
                    'pom_flag' 'POM' 'num_samples'
                    'fe_flag' 'Dfe' 'num_samples'};
                do_empty_vars = 1;
                fillstat = 0;
            case 'sam_ashore_unclean'
                    fnin = {fullfile(mgetdir('M_BOT_ISO'),'CTD_bottle_cop_unclean.xlsx')};
                varmap = {'statnum' 'CTDCastNumber' ' '
                    'position' 'Position' ' '
                    'dic_flag' 'DIC' 'num_samples'
                    'd13dic_flag' 'd13DIC' 'num_samples'
                    'silc_flag' 'Nuts' 'num_samples'
                    'phos_flag' 'Nuts' 'num_samples'
                    'totnit_flag' 'Nuts' 'num_samples'
                    'botchl_flag' 'Chl' 'num_samples'
                    'd30si_flag' 'd30Si' 'num_samples'
                    'poc_flag' 'POC' 'num_samples'
                    'pom_flag' 'POM' 'num_samples'
                    'fe_flag' 'Dfe' 'num_samples'};
                do_empty_vars = 1;
                fillstat = 0;
            case 'shore_samlog_edit'
                %different names for the same thing, or we otherwise want
                %to combine
                st.d30Si = st.d30Si + st.BSi; %***
        end

end
