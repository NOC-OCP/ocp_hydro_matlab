
%shortcasts = 2; %no altimeter bottom depth/no LADCP BT

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
        end

    case 'uway_proc'
        switch opt2
            case ['sensor_unit_conversions' ...
                    '' ...
                    '' ...
                    '']
                if strcmp(abbrev,'ea640')
                    d.waterdepth = d.waterdepthtransducer + d.transduceroffset;
                    [~,ia,ib] = intersect(h.fldnam,{'waterdepthfromtransducer','transduceroffset'});
                    dats = {'fldnam','fldunt','alrlim','uprlim','absent','num_absent','dimsset','dimrows','dimcols'};
                    for no = 1:length(dats)
                        h.(dats{no})(ia) = [];
                    end
                end
            case 'bathy_grid'
                %for background, load gridded bathymetry into xbathy, ybathy, zbathy
        end

    case 'ctd_proc'
        switch opt2
            case 'minit'
                if stn==65.1
                    stn_string = sprintf('%03dA',floor(stn)); %only used in mctd_01
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
                    %ctd_all_part1 should run this after mctd_01(65) and
                    %before rest of processing
                    ctd_raw_extra = ['mctd_01(65.1); ' ...
                        'otfile = fullfile(mgetdir(''M_CTD''),''ctd_dy181_065_raw_noctm.nc''); ' ...
                        'getpos_for_ctd(otfile, 1, ''write''); ' ...
                        'mfir_01(65.1);'];
                end
            case 'header_edits'
                %typo in xmlcon oxygen2 s/n on many stations
                hreplace = {'serial';'oxygen';'422068';'432068'};
                m_fix_hdr(otfile, hreplace);
                if exist('otfile_appendto','var')
                    m_fix_hdr(otfile_appendto, hreplace);
                end
            case 'oxy_align'
                oxy_end = 1; %truncate oxygen oxy_align s before T,C
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
                end
            case 'ctd_cals'
                co.docal.temp = 0;
                co.docal.cond = 0;
                co.docal.oxygen = 0;
                co.calstr.temp.sn34116.dy181 = 'dcal.temp = d0.temp+interp1([184 203],[1e-3 -1e-3],d0.dday);';
                co.calstr.temp.sn34116.msg = 'SBE35 comparison, 482 total points, 109 deep/low gradient points';
                co.calstr.temp.sn35838.dy181 = 'dcal.temp = d0.temp+1e-3;';
                co.calstr.temp.sn35838.msg = 'SBE35 comparison, 494 total points, 110 deep/low gradient points';
                co.calstr.cond.sn42580.dy181 = 'dcal.cond = d0.cond.*(1-1e-3/35);';
                co.calstr.cond.sn42580.msg = '341 bottle salinities (106 deep/low gradient)';
                co.calstr.cond.sn43258.dy181 = 'dcal.cond = d0.cond.*(1-6e-3/35);';
                co.calstr.cond.sn43258.msg = '353 bottle salinities (107 deep/low gradient)';
                co.calstr.oxygen.sn432061.dy181 = 'dcal.oxygen = d0.oxygen.*interp1([0 100],[1.038 1.058],d0.statnum);';
                co.calstr.oxygen.sn432061.msg = 'upcast oxygen s/n 432061 adjusted to agree with 146 samples';
                co.calstr.oxygen.sn432068.dy181 = 'dcal.oxygen = d0.oxygen.*1.025;';%interp1([0 51 70 80 85],[1.025 1.02 1.05 1.04 1.04],d0.statnum);';
                co.calstr.oxygen.sn432068.msg = 'upcast oxygen s/n 432068 adjusted to agree with 142 samples';
            case 'sensor_choice'
                s_choice = 2; %CTD2 is on the vane and is smoother (better) especially when AHC not on
                if stn<=50 || stnlocal>79 %or 74?
                    o_choice = 2;
                else
                    o_choice = 1; 
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
                %elseif stn==70
                    %niskin_flag(position==15) = 4; %latch did not release,
                    %but based on .bl file this is because it was 14 that
                    %was triggered instead (no bottle on 14)
                end
                %these not-present Niskins were triggered, so there is an
                %SBE35 measurement, but the niskin_flag itself should be 9
                %for no sample drawn
                niskin_flag(floor(position/2)==position/2) = 9;
                %810, 3410, 3718, 6802, 7014, 7018
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
        check_sal = 1;
        check_oxy = 1;
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
                salfiles = {salfiles.name};
            case 'sal_parse'
                cellT = 21;
                ssw_k15 = 0.99993;
                calcsal = 1;
                ssw_batch = 'P168';
            case 'sal_calc'
                sal_off = [000 -.5; 001 -1; 002 -1; 003 -2; ... %10th am
                    004 0; 005 1.5; 006 2; 007 7; ... %11th pm
                    009 -3; 010 -1.5; 011 -1.5; 012 -2.5; ... %12th am
                    013 -6; 014 -2; ... %12th pm
                    015 -5; 016 2; 017 2; 018 1; 019 1; 020 -2; ... %14th am
                    021 -7.5; 022 -2; ... %14th pm
                    023 1.5; 026 1; 027 2; 028 2; 029 1; ... %17th am 024, 025 9.5 suspicious, maybe old
                    % samples on 19th run without standards
                    % samples on 20th run without standards
                    031 -1; 036 -1; ... %21st am
                    ];
                sal_off(:,1) = sal_off(:,1)+999e3;
                sal_off(:,2) = sal_off(:,2)*1e-5;
                sal_off_base = 'sampnum_list'; 
            case 'sal_flags'
                %too low (33-ish), maybe samples contaminated
                m = ismember(ds_sal.sampnum,[4807 4809 5713 5801 5803 5805]);
                ds_sal.botpsal_flag(m) = 4;
        end

    case 'botoxy'
        switch opt2
            case 'oxy_files'
                ofiles = {fullfile(root_oxy,'Winkler Calculation Spreadsheet_220724.xlsx')};
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
                flag3 = [3617 3811 ...
                    811 923 5507 5509 5511 5609 5613]';
                flag4 = [3501 3507 3509 3515 3603 3607 3715 ...
                    4207 4403 5603 ...
                    601 921 4401 4415 4915 5203 5601 7209 7717 7719]';
                d.botoxya_flag(ismember(d.sampnum,flag4)) = 4;
                d.botoxya_flag(ismember(d.sampnum,flag3)) = 3;
                m = d.sampnum==8315;
                d.botoxya_flag(m) = 3; d.botoxyb_flag(m) = 3;
        end

    case 'botnut'
        switch opt2
            case 'nut_files'
                ncpat = '240721*.xlsx';
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
        end

    case 'outputs'
        switch opt2
            case 'summary'
                snames = {'nsal' 'noxy' 'nnut' 'nco2'};
                sgrps = {{'botpsal'} {'botoxy'} {'silc' 'phos' 'nitr'} {'dic' 'talk'}};
            case 'exch'
                ns = 9;
                expocode = '74EQ20240703';
                sect_id = 'OSNAP-EEL-AR28';
                submitter = 'OCPNOCYLF'; %group institution person
                common_headstr = {'#SHIP: RRS Discovery';...
                    '#Cruise DY181; UK-OSNAP/Extended Ellet Line 2024';...
                    '#Region: subpolar north Atlantic';...
                    ['#EXPOCODE: ' expocode];...
                    '#DATES: 20240703 - 20240728';...
                    '#Chief Scientist: K. Burmeister (SAMS) and T. Dotto (NOC)';...
                    '#Supported by grants from the UK Natural Environment Research Council.'}; %***
                if strcmp(in.type,'ctd')
                    headstring = {['CTD,' datestr(now,'yyyymmdd') submitter]};
                    headstring = [headstring; common_headstr;
                        {sprintf('#%d stations with 24-place rosette',ns);...
                        '#CTD: Who - Y. Firing (NOC); Status - preliminary.';...
                        %'#The CTD PRS; TMP; SAL; OXY data are all calibrated and good.';...
                        '# DEPTH_TYPE   : COR';...
                        '# DEPTH_TYPE   : rosette depth from CTDPRS + CTD altimeter range to bottom, or speed of sound-corrected ship-mounted bathymetric echosounder'...
                        }];
                else
                    headstring = {['BOTTLE,' datestr(now,'yyyymmdd') submitter]};
                    headstring = [headstring; common_headstr;
                        {sprintf('#%d stations with 24-place rosette',ns);...
                        '#CTD: Who - Y. Firing (NOC); Status - preliminary';...
                        '#Notes: Includes CTDSAL, CTDOXY, CTDTMP';...
                        %'#The CTD PRS; TMP; SAL; OXY data are all calibrated and good.';...
                        '# DEPTH_TYPE   : rosette depth from CTDPRS + CTD altimeter range to bottom';...
                        '#Salinity: Who - Y. Firing (NOC); Status - preliminary; SSW batch P168.';...
                        '#Oxygen: Who - R. Abell (SAMS); Status - preliminary.';...
                        '#Nutrients: Who - R. Abell (SAMS); Status - preliminary.';...
                        '#DIC and Talk: Who - C. Johnson (SAMS); Status - not yet analysed.';...
                        '#***';...
                        }];
                end
            case 'grid'
                sam_gridlist = {'botoxy' 'silc' 'phos' 'totnit'};
                mgrid.sdata_flag_accept = [2 3]; %***or just 2
                switch section
                    case 'osnape'
                        kstns = [35:39 42:45 47 46 48:65 69 68 71 72 77 76 75 74 73];
                        %should 67 be in here? 
                        mgrid.xlim = 2; mgrid.zlim = 4;
                    case 'osnape_plus'
                        kstns = [82 81 80 79 78];
                        %station names in order: 20b, 21a, 21b, 22a, 22b 
                        mgrid.xlim = 2; mgrid;zlim = 4;
                    case 'scotshelf'
                        mgrid.zpressgrid = [0 5 25 50 75 100 125 150 175 200 250 300];
                        kstns = [6:9 35:36];
                    case 'profiles_only'
                        kstns = [1:3 10:33]; %test, dm, yo-yo
                        kstns = 1:999;
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

