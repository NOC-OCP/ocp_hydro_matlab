shortcasts = [84 99];

switch opt1

    case 'setup'
        switch opt2
            case 'time_origin'
                MEXEC_G.MDEFAULT_DATA_TIME_ORIGIN = [2024 1 1 0 0 0];
            case 'setup_datatypes'
                use_ix_ladcp = 'query';

        end

    case 'ship'
        switch opt2
            case 'datasys_best'
                default_navstream = 'posmv_gpgga';
                default_hedstream = 'posmv_pashr';
                default_attstream = 'posmv_pashr';
            case 'rvdas_database'
                RVDAS.jsondir = '/data/pstar/mounts/links/mnt_cruise_data/Ship_Systems/Data/RVDAS/sensorfiles/'; %original
                RVDAS.database = ['"' upper(MEXEC_G.MSCRIPT_CRUISE_STRING) '"'];
                RVDAS.loginfile = '/data/pstar/plocal/rvdas_addr';
            case 'rvdas_skip'
                skips.sentence = [skips.sentence, 'surfmet_gpxsm', 'ranger2usbl_psonlld'];
        end

    case 'uway_proc'
        switch opt2
            case 'sensor_unit_conversions'
                switch abbrev
                    case 'surfmet'
                        so.docal.fluo = 1;
                        so.docal.trans = 1;
                        so.docal.parport = 1;
                        so.docal.parstarboard = 1;
                        so.docal.tirport = 1;
                        so.docal.tirstarboard = 1;
                        %specify with so.calstr.{variablename}.pl.{cruise}
                        so.calstr.fluo.pl.dy181 = 'dcal.fluo = 10.3*(d0.fluo-0.078);'; %or sf is nonlinear?***
                        so.instsn.fluo = 'WS3S134';
                        so.calunits.fluo = 'ug_per_l';
                        so.calstr.trans.pl.dy181 = 'dcal.trans = (d0.trans-0.017)/(4.699-0.017)*100;';
                        so.instsn.trans = 'CST-112R';
                        so.calunits.trans = 'percent';
                        so.calstr.parport.pl.dy181 = 'dcal.parport = d0.parport*(1e6/8.944);'; %***or 9.994? 
                        so.instsn.parport = 'SKE-510 28558';
                        so.calunits.parport = 'W_per_m2';
                        so.calstr.parstarboard.pl.dy181 = 'dcal.parstarboard = d0.parstarboard*(1e6/8.937);';
                        so.instsn.parstarboard = 'SKE-510 28561';
                        so.calunits.parstarboard = 'W_per_m2';
                        so.calstr.tirport.pl.dy181 = 'dcal.tirport = d0.tirport*(1e6/9.69);';
                        so.instsn.tirport = 'CMP-994133';
                        so.calunits.tirport = 'W_per_m2';
                        so.calstr.tirstarboard.pl.dy181 = 'dcal.tirstarboard = d0.tirstarboard*(1e6/11.31);';
                        so.instsn.tirstarboard = '994132';
                        so.calunits.tirstarboard = 'W_per_m2';
                end
            case 'rawedit'
                ts = (datenum(2024,7,3,15,40,0)-datenum(2024,1,1))*86400;
                if strcmp(abbrev,'sbe45')
                    uopts.badtime.temph = [-inf ts];
                    uopts.badtime.tempr = [-inf ts];
                    uopts.badtime.conductivity = [-inf ts];
                    uopts.badtime.salinity = [-inf ts];
                    uopts.badtime.soundvelocity = [-inf ts];
                elseif strcmp(abbrev,'surfmet')
                    uopts.badtime.fluo = [-inf ts];
                    uopts.badtime.trans = [-inf ts];
                end
                if sum(strcmp(streamtype,{'sbm','mbm'}))
                    handedit = 1; %edit raw bathy
                    vars_to_ed = munderway_varname('depvar',h.fldnam,1,'s');
                    vars_to_ed = union(vars_to_ed,munderway_varname('depsrefvar',h.fldnam,1,'s'));
                    vars_to_ed = union(vars_to_ed,munderway_varname('deptrefvar',h.fldnam,1,'s'));
                end
                if strcmp(abbrev,'ea640')
                    d = rmfield(d,'waterdepthfromsurface');
                    h.fldunt(strcmp('waterdepthfromsurface',h.fldnam)) = [];
                    h.fldnam(strcmp('waterdepthfromsurface',h.fldnam)) = [];
                end
            case 'tsg_cals'
                uo.docal.salinity = 1;
                uo.calstr.salinity.pl.dy181 = 'dcal.salinity = d0.salinity+interp1([184 209],[0.001 0.014],d0.dday);';
                uo.calstr.salinity.pl.msg = 'salinity adjusted by removing trend based on differences from 135 bottle salinities';
            case 'avedit'
                if strcmp(datatype,'ocean')
                    uopts.rangelim.flow = [1 2.5]; %***
                    uopts.badflow.temph = [NaN NaN];
                    uopts.badflow.tempr = [NaN NaN];
                    uopts.badflow.conductivity = [NaN NaN];
                    uopts.badtemph.conductivity = [NaN NaN];
                    uopts.badtemph.salinity = [NaN NaN];
                    uopts.badflow.fluo = [NaN NaN];
                    uopts.badflow.trans = [NaN NaN];
                    %vars_to_ed = {'flow'};
                    %vars_to_ed = {'temph','conductivity'};
                    vars_to_ed = {'salinity'};
                    vars_to_ed = {'tempr','temph'};
                elseif strcmp(datatype,'bathy')
                    vars_to_ed = {'waterdepth_mbm','waterdepth_sbm'};
                end
            case 'bathy_grid'
                %for background, load gridded bathymetry into xbathy, ybathy, zbathy
        end

    case 'ctd_proc'
        switch opt2
            case 'minit'
                if stn==65.1
                    stn_string = sprintf('%03dA',floor(stn)); %only used in mctd_01
                elseif stn==84
                    warning('no data from cast 84, skipping')
                    return
                end
            case 'redoctm'
                redoctm = 1;
            case 'cnvfilename'
                cnvfile = fullfile(cdir,sprintf('%s_CTD%s.cnv', upper(mcruise), stn_string));
                if stn==10
                    cnvfile = fullfile(cdir,sprintf('%s_CTD%04d.cnv', upper(mcruise), stn));
                end
            case 'cast_split_comb'
                if stn==65.1
                    otfile_appendto = fullfile(root_ctd,sprintf('ctd_%s_%03d_raw_noctm.nc',mcruise,floor(stn)));
                    cast_scan_offset = [65.1 65 81192]; %this cast, cast to append to, scan offset
                end
            case 'ctd_raw_extra'
                if stn==65
                    %data from cast 65 in two cnv files, so ctd_process
                    %runs this after mctd_01(65) to combine before the rest of 
                    %processing
                    msbe_01(65.1); 
                    otfile = fullfile(mgetdir('M_CTD'),'ctd_dy181_065_raw_noctm.nc'); getpos_for_ctd(otfile, 1, 'write');
                    mfir_01(65.1);
                end
            case 'header_edits'
                %typo in xmlcon oxygen2 s/n on many stations
                hreplace = {'serial';'oxygen';'422068';'432068'};
                m_fix_hdr(otfile, hreplace);
                if exist('otfile_appendto','var')
                    m_fix_hdr(otfile_appendto, hreplace);
                end
            case 'raw_corrs'
                co.oxyhyst432061.H1 = -0.03;
                co.oxyhyst432061.H2 = 7000;
                co.oxyhyst432061.H3 = 1450;
                co.oxyhyst432068.H1 = -0.033;
                co.oxyhyst432068.H2 = 6500;
                co.oxyhyst432068.H3 = 1450;
            case 'rawedit_auto'
                if stn==43
                    co.badscan.temp1 = [6.79e4 inf];
                    co.badscan.cond1 = co.badscan.temp1;
                    co.badscan.oxygen_sbe1 = co.badscan.temp1;
                elseif ismember(stn,[44 45])
                    co.badscan.oxygen_sbe2 = [-inf inf]; %steps, all questionable
                elseif stn==61
                    co.despike.cond1 = [0.02 0.02];
                    co.despike.cond2 = [0.02 0.02];
                elseif stn==88
                    co.badscan.cond1 = [9.198e4 inf]; %offset, probably resolves before surface but hard to say where
                elseif stn==98                         %CTD clogged with jellyfish
                    co.badscan.oxygen_sbe1 = [39200 inf];
                    co.badscan.temp1 = [39200 inf];
                    co.badscan.cond1 = [39200 inf];
                    co.badscan.cond2 = [11004 39421];
                end
            case 'ctd_cals'
                co.docal.temp = 1;
                co.docal.cond = 1;
                co.docal.oxygen = 1;
                co.calstr.temp.sn34116.dy181 = 'dcal.temp = d0.temp+interp1([1 101],[1e-3 0e-3],d0.statnum) - 5e-4 +interp1([0 3100],[1e-3 -0.8e-3],d0.press);';
                co.calstr.temp.sn34116.msg = 'SBE35 comparison, 180 low gradient points';
                co.calstr.temp.sn35838.dy181 = 'dcal.temp = d0.temp+interp1([0 3100],[1.8e-3 0.8e-3],d0.press) - 5e-4;';
                co.calstr.temp.sn35838.msg = 'SBE35 comparison, 181 low gradient points';
                co.calstr.cond.sn42580.dy181 = 'dcal.cond = d0.cond.*(1+interp1([0 3100],[-0.5e-3 -0.5e-3],d0.press)/35);';
                co.calstr.cond.sn42580.msg = 'bottle salinity comparison, 232 low gradient points';
                co.calstr.cond.sn43258.dy181 = 'dcal.cond = d0.cond.*(1+interp1([1 101],[-6e-3 -4e-3],d0.statnum)/35 + interp1([0 3100],[0 -1.5e-3],d0.press)/35);';
                co.calstr.cond.sn43258.msg = 'bottle salinity comparison, 249 low gradient points';
                co.calstr.oxygen.sn432061.dy181 = 'dcal.oxygen = d0.oxygen.*interp1([0 3100],[1.045 1.065],d0.press);';%interp1([0 101],[1.038 1.045],d0.statnum)+interp1([0 3100],[0 2.5],d0.press);';
                co.calstr.oxygen.sn432061.msg = 'comparison of upcast and density-matched downcast oxygen with 361 low-background-gradient samples';
                co.calstr.oxygen.sn432068.dy181 = 'dcal.oxygen = d0.oxygen.*interp1([0 3100],[1.035 1.045],d0.press).*interp1([1 52 53 79 80 101],[0.99 0.99 1.02 1.02 1 1],d0.statnum);';%interp1([0 101],[1.02 1.035],d0.statnum)+interp1([1 101],[2 0],d0.statnum)+interp1([0 3100],[-0.5 2],d0.press);';
                co.calstr.oxygen.sn432068.msg = 'comparison of upcast and density-matched downcast oxygen with 361 low-background-gradient samples';
            case 'sensor_choice'
                s_choice = 1; 
                o_choice = 1;
                if ismember(stn, [43 88 98])
                    s_choice = 2;
                    o_choice = 2;
                end
        end

    case 'nisk_proc'
        switch opt2
            case 'blfilename'
                blinfile = fullfile(root_botraw,sprintf('%s_CTD%s.bl', upper(mcruise), stn_string));
                if stn==10
                    blinfile = fullfile(root_botraw,sprintf('%s_CTD%04d.bl', upper(mcruise), stn));
                elseif stn==65.1
                    blinfile = fullfile(root_botraw,sprintf('%s_CTD%03dA.bl', upper(mcruise), floor(stn)));
                    stn_string = '065'; %for dataname
                end
            case 'botflags'
                if stn==6
                    niskin_flag(ismember(position,[11 21])) = 4;
                elseif stn==36
                    niskin_flag(position==11) = 3; %***leaked
                elseif stn==44
                    niskin_flag(position==15) = 3; %bad oxy and nuts
                elseif stn==51
                    niskin_flag(position==11) = 3; %maybe leaking (on recovery, not obviously after), still sampled
                elseif stn==64
                    niskin_flag(position==7) = 4; %latch did not release
                elseif stn==65.1
                    %no record for niskin 1 in .bl file due to computer
                    %problem; adding information from sbe35 file
                    position = [1; position];
                    niskin = [1; niskin];
                    niskin_flag = [1; niskin_flag];
                    scan = [-18932; scan]; %relative to start of 065A; will be adjusted
                elseif ismember(stn,[88 89])
                    niskin_flag(position==6) = 3; %leaking, although overridden by 9
                elseif stn==100
                    niskin_flag(ismember(position,[1 2 3])) = 3;
                end
                if stn<88
                    %these not-present Niskins were triggered, so there is an
                    %SBE35 measurement, but the niskin_flag itself should be 9
                    %for no sample drawn
                    niskin_flag(floor(position/2)==position/2) = 9;
                    %810, 3410, 3718, 6802, 7014, 7018
                end
            case 'niskins'
                niskin_number = [3034:3046 7131 3048:3057]';
                if stnlocal<88
                    niskin_number(2:2:end) = NaN; %no even Niskins for these stations
                end
        end

    case 'ladcp_proc'
        min_nvmadcpprf = 4; %throws a warning if number of vmADCP profiles within an LADCP cast is less than this
        min_nvmadcpbin = 3; %masks depths with number of valid bins less than this
        min_nvmadcpbin_refl = 3; %throws a warning if number of good profiles at any depth in the watertrack reference layer is less than this
        cfg.rawdir = fullfile(mgetdir('ladcp'),'rawdata');
        yos = [10 33];        
        if stn>=yos(1) && stn<=yos(2)
            cfg.uppat = sprintf('%s_CTD%03d-%03dS*.000',upper(mcruise),yos(1),yos(2));
            cfg.dnpat = sprintf('%s_CTD%03d-%03dM*.000',upper(mcruise),yos(1),yos(2));
        elseif stn==45
            cfg.uppat = 'DY181_CTD045S.000';
            cfg.dnpat = 'DY181_CTD45M.000';
        elseif stn==85
            cfg.uppat = 'DY181_CTD084-85S.000';
            cfg.dnpat = 'DY181_CTD084-85M.000';
        elseif stn==90
            %cfg.uppat = 'DY181_CTD090S.00*'; %001 files don't have header,
            %so concatenated files to _all.000 instead
            %cfg.dnpat = 'DY181_CTD090M.00*';
            cfg.uppat = 'DY181_CTD090S_all.000';
            cfg.dnpat = 'DY181_CTD090M_all.000';
        else
            cfg.uppat = sprintf('%s_CTD%03dS*.000',upper(mcruise),stn);
            cfg.dnpat = sprintf('%s_CTD%03dM*.000',upper(mcruise),stn);
        end
        cfg.p.vlim = 4; %rather than ambiguity vel, match this to LV
        %code for yo-yo cast
        if stn>=yos(1) && stn<=yos(2)
            [dd,hd] = mloadq(fullfile(mgetdir('ctd'),sprintf('dcs_%s_%03d',mcruise,stnlocal)),'time_start time_end ');
            dd.dnum_start = m_commontime(dd,'time_start',hd,'datenum');
            dd.dnum_end = m_commontime(dd,'time_end',hd,'datenum');
            cfg.p.time_start_force = round(datevec(dd.dnum_start-2/60/24));
            cfg.p.time_end_force = round(datevec(dd.dnum_end+2/60/24));
        end

    case 'check_sams'
        %make this display-dependent? (or session-dependent?)
        check_sal = 100;
        check_oxy = 1;
        check_nut = 1;
        check_sbe35 = 1;

    case 'sbe35'
        switch opt2
            case 'sbe35_parse'
                %deal with combined file(s)
                if strcmp(file_list{kf},'DY181_SBE35_CTD070_071.asc')
                    m = t.statnum==71 & t.datnum<datenum(2024,7,17,19,0,0);
                    t.statnum(m) = 70;
                end
        end

    case 'botpsal'
        switch opt2
            case 'sal_files'                
                salfiles = dir(fullfile(root_sal, ['autosal_' mcruise '_*.csv'])); 
            case 'sal_parse'
                cellT = 21;
                ssw_k15 = 0.99993;
                calcsal = 1;
                ssw_batch = 'P168';
            case 'sal_calc'
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
            case 'sal_flags'
                %too low (33-ish), maybe samples contaminated
                m = ismember(ds_sal.sampnum,[4807 4809 5713 5715 5801 5803 5805]);
                ds_sal.flag(m) = 4;
                m = ismember(ds_sal.sampnum,[6715 8810]); ds_sal.flag(m) = 3;
                %Missing salinometer analysis due to blockage
                none = ismember(ds_sal.sampnum, [9104 9105]);
                ds_sal.flag(none) = 5;
        end

    case 'botoxy'
        switch opt2
            case 'oxy_files'
                ofiles = dir(fullfile(root_oxy,'Winkler Calculation Spreadsheet_270724.xlsx'));
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
            case 'oxy_flags'
                %sampnum, a flag, b flag, c flag
                flr = [103 3 3 3; ... 
                       113 4 2 2; ... %a is the outlier
                       509 4 2 9; ... %duplicates only, a much higher than neighbours
                      4123 4 2 2; ... %a much lower than all
                      6621 4 2 2; ... %a is the outlier
                      7207 2 4 9; ...
                      7209 2 4 9; ...
                      7211 2 4 9; ...
                      7213 3 3 9; ...
                      7215 2 3 9; ...
                      7219 3 4 9; ...
                      7221 3 3 9; ...
                      7601 3 3 9; ...
                      7623 2 4 9; ...
                      ];
                [~,ifl,id] = intersect(flr(:,1),d.sampnum);
                d.botoxya_flag(id) = max(d.botoxya_flag(id),flr(ifl,2));
                d.botoxyb_flag(id) = max(d.botoxyb_flag(id),flr(ifl,3));
                d.botoxyc_flag(id) = max(d.botoxyc_flag(id),flr(ifl,4));
                % outliers relative to profile/CTD (not replicates)
                flag3 = [3617 3811 3817 4217 4219 ...
                    811 923 5507 5509 5511 5603 5609 5613 ...
                    8801 9405]';
                flag4 = [3501 3507 3509 3515 3603 3607 3715 ...
                    4207 4403 5603 ...
                    601 921 4401 4415 4915 5203 5601 7209 7403 7717 7719 ...
                    8803 8815 8817 8910 8911 8912 8913 8914 8915 8922 ...
                    9001 9013 9015 9021 ...
                    9113 9117 9121 9123 ...
                    9223 9319 9706]';
                %8802, 8804, 8810, 8812, 8816, 8822
                d.botoxya_flag(ismember(d.sampnum,flag4)) = 4;
                d.botoxya_flag(ismember(d.sampnum,flag3)) = 3;
                m = d.sampnum==8315;
                d.botoxya_flag(m) = 3; d.botoxyb_flag(m) = 3;
        end

    case 'botnut'
        switch opt2
            case 'nut_files'
                ncpat = '*240726.xlsx';
                hcpat = {'LAT'}; chrows = 1; chunits = 1;
            case 'nut_parse'
                varmap.position = {'niskin_btl_number'};
                %ds_nut.position = nan+ds_nut.statnum;
                %for no = 1:length(ds_nut.statnum)
                %    ii = strfind(ds_nut.statname_niskin{no},'BTL');
                %    if ~isempty(ii)
                %        ds_nut.position(no) = str2double(ds_nut.statname_niskin{no}(ii+[3:4]));
                %    end
                %end
                %ds_nut(isnan(ds_nut.position),:) = [];
            case 'nut_param_flag'
                %replicate differences
                dnew.silcb_flag(dnew.sampnum==4415) = 3; %very high
                %from profiles
                dnew.silca_flag(dnew.sampnum==4709) = 4; %low
        end

    case 'outputs'
        switch opt2
            case 'summary'
                snames = {'nsal' 'noxy' 'nnut' 'nco2_shore'};
                sgrps = {{'botpsal'} {'botoxy'} {'silc' 'phos' 'totnit'} {'dic' 'talk'}};
            case 'sam_shore'
               fnin = fullfile(mgetdir('M_CTD'),'BOTTLE_SHORE', 'DY181 Samples for Onshore Analysis - DIC.xlsx');
               varmap.statnum = {'CTDNumber'};
               varmap.position = {'Niskin'};
               varmap.dic = {'N_DICSamples'};
               varmap.talk = {'N_DICSamples'};
            case 'exch'
                ns = 100;
                expocode = '74EQ20240703';
                sect_id = 'OSNAP-EEL-AR28';
                submitter = 'OCPNOCYLF'; %group institution person
                common_headstr = {'#SHIP: RRS Discovery';...
                    '#Cruise DY181; UK-OSNAP/Extended Ellet Line 2024';...
                    '#Region: subpolar north Atlantic';...
                    ['#EXPOCODE: ' expocode];...
                    '#DATES: 20240703 - 20240728';...
                    '#Chief Scientist: K. Burmeister (SAMS); Co-Chief Scientist: T. Dotto (NOC)';...
                    '#Supported by grants NE/K010700/1 and NE/Y005473/1 (UK OSNAP), NE/T00858X/1 (UK OSNAP Decade), and NE/Y005589/1 (AtlantiS) from the UK Natural Environment Research Council.'}; 
                if strcmp(in.type,'ctd')
                    headstring = {['CTD,' datestr(now,'yyyymmdd') submitter]};
                    headstring = [headstring; common_headstr;
                        {sprintf('#%d stations with 24-place rosette',ns);...
                        '#CTD: Who - Y. Firing (NOC); Status - final.';...
                        '#The CTD PRS; TMP; SAL; OXY data are all calibrated and good.';...
                        '# DEPTH_TYPE   : COR';...
                        '# DEPTH_TYPE   : rosette depth from CTDPRS + CTD altimeter range to bottom, or speed of sound-corrected ship-mounted bathymetric echosounder'...
                        }];
                else
                    headstring = {['BOTTLE,' datestr(now,'yyyymmdd') submitter]};
                    headstring = [headstring; common_headstr;
                        {sprintf('#%d stations with 24-place rosette',ns);...
                        '#CTD: Who - Y. Firing (NOC); Status - final';...
                        '#Notes: Includes CTDSAL, CTDOXY, CTDTMP';...
                        '#The CTD PRS; TMP; SAL; OXY data are all calibrated and good.';...
                        '# DEPTH_TYPE   : rosette depth from CTDPRS + CTD altimeter range to bottom';...
                        '#Salinity: Who - Y. Firing (NOC); Status - final; SSW batch P168.';...
                        '#Oxygen: Who - R. Abell (SAMS); Status - final.';...
                        '#Nutrients: Who - R. Abell (SAMS); Status - preliminary.';...
                        '#DIC and Talk: Who - C. Johnson (SAMS); Status - not yet analysed.';...
                        }];
                end
            case 'section_for_station'
                if stnlocal>4 && stnlocal<88
                    sections = {'osnape_plus'};
                elseif stnlocal>=88
                    sections = {'eddy'};
                end
            case 'grid'
                sam_gridlist = {'botoxy' 'silc' 'phos' 'totnit'};
                mgrid.sdata_flag_accept = [2 3]; %***or just 2
                if contains(section,'osnape')
                    %this is everything that can be arranged by
                    %longitude, no repeats***
                    kstns = [35:39 42:45 47 46 48:63 87 86 64 85 65 83 82 69 80 81 68 79 78 67 71 72 77 76 75 74 73];
                    mgrid.xlim = 2; mgrid.zlim = 4;
                    if ~contains(section,'plus')
                        %this is the main section, at original spacing
                        kstns = kstns(kstns<78); %exclude the a/b stations
                    end
                elseif strcmp(section,'ibe')
                    %this is just the higher-resolution section in the IB,
                    %O18 to O23 and including the a/b stations between
                    kstns = [63 87 86 64 85 65 83 82 69 81 80 68 79 78 67];
                    mgrid.xlim = 2; mgrid.zlim = 4;
                elseif strcmp(section,'eddy')
                    %these are the eddy stations in order from W to E
                    kstns = 88:99;
                    mgrid.xlim = 2; mgrid.zlim = 4;
                elseif strcmp(section,'scotshelf')
                    mgrid.zpressgrid = [0 5 25 50 75 100 125 150 175 200 250 300];
                    kstns = [6:9 35:36];
                else
                    section = 'profiles_only';
                    %kstns = [1 2 10:33 3 4 5 40 41 66 70 100]; %test, dm, yo-yo, caldip, cal profile, argo 60N
                    kstns = 1:999; %useful to do profiles_only for all stations anyway (smooth in vertical)
                end
        end

    case 'batchactions'
        switch opt2
            case 'output_for_others'
                pdir = '/data/pstar/mounts/public/DY181/Science/CTD_bottle_data';
                syncs = {'%s/collected_files/station_summary* %s/';...
                         '%s/collected_files/74EQ* %s/';...
                         '%s/ctd/ctd*2db.nc %s/ctd_2db/';...
                         '%s/ctd/BOTTLE_SAL/autosal*.csv %s/BOTTLE_SAL/';...
                         '%s/ladcp/ix/DLUL_GPS_BT/processed/*.mat %s/ladcp/'};
                s = nan(length(syncs),1);
                for no = 1:length(syncs)
                    synclocs = sprintf(syncs{no},MEXEC_G.mexec_data_root,pdir);
                    try
                        [s(no),~] = system(['rsync -rlu ' synclocs]);
                    catch
                        [s(no),~] = system(['cp -R ' synclocs]);
                    end
                end
                if sum(s)>0; warning('some or all syncing failed'); end
        end

end

