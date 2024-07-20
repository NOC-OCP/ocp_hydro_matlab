
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
            case 'excludestreams'
            case 'bathy_grid'
                %for background, load gridded bathymetry into xbathy, ybathy, zbathy
        end

    case 'castpars'
        switch opt2
            case 'minit'
                if stn==65.1
                  stn_string = sprintf('%03dA',floor(stn)); %only used in mctd_01
                end
            case 'oxy_align'
                oxy_end = 1; %truncate oxygen oxy_align s before T,C
            case 's_choice'
                s_choice = 1; %fin sensor
            case 'o_choice'
                o_choice = 1; %fin sensor

        end

    case 'ctd_proc'
        switch opt2
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
                    ctd_raw_extra = ['mctd_01(65.1); ...' ...
                        'otfile = fullfile(mgetdir(''M_CTD''),''ctd_dy181_065_raw_noctm.nc''); ...' ...
                        'getpos_for_ctd(otfile, 1, ''write''); ...' ...
                        'mfir_01(65.1);'];
                end
            case 'rawedit_auto'
                if stn==61
                    co.despike.cond1 = [0.02 0.02];
                    co.despike.cond2 = [0.02 0.02];
                end
            case 'ctd_cals'
                co.docal.temp = 0;
                co.docal.cond = 0;
                co.docal.oxygen = 0;
                %co.calstr.temp.sn34116.dy181 = 'dcal.temp = d0.temp';
                %co.calstr.temp.sn34116.msg = '';
                %co.calstr.temp.sn35838.dy181 = 'dcal.temp = d0.temp';
                %co.calstr.temp.sn35838.msg = '';
                co.calstr.cond.sn42580.dy181 = 'dcal.cond = d0.cond.*(1-2e-3/35)';
                co.calstr.cond.sn42580.msg = 'prelim';
                co.calstr.cond.sn43258.dy181 = 'dcal.cond = d0.cond.*(1-8e-3/35)';
                co.calstr.cond.sn43258.msg = 'prelim';
                co.calstr.oxygen.sn432061.dy181 = 'dcal.oxygen = d0.oxygen.*1.04;';
                co.calstr.oxygen.sn432061.msg = 'upcast oxygen s/n 432061 adjusted to agree with 146 samples';
                co.calstr.oxygen.sn432068.dy181 = 'dcal.oxygen = d0.oxygen.*1.025;';
                co.calstr.oxygen.sn432068.msg = 'upcast oxygen s/n 432068 adjusted to agree with 142 samples';
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
                elseif stn==70
                    niskin_flag(position==15) = 4; %latch did not release
                end
        end

    case 'ladcp_proc'
        cfg.rawdir = fullfile(mgetdir('ladcp'),'rawdata');
        yos = [10 33];
        min_nvmadcpprf = 4; %throws a warning if number of vmADCP profiles within an LADCP cast is less than this
        min_nvmadcpbin = 3; %masks depths with number of valid bins less than this
        min_nvmadcpbin_refl = 3; %throws a warning if number of good profiles at any depth in the watertrack reference layer is less than this
        
        if stn>=yos(1) && stn<=yos(2)
            cfg.uppat = sprintf('%s_CTD%03d-%03dS*.000',upper(mcruise),yos(1),yos(2));
            cfg.dnpat = sprintf('%s_CTD%03d-%03dM*.000',upper(mcruise),yos(1),yos(2));
        else
            cfg.uppat = sprintf('%s_CTD%03dS*.000',upper(mcruise),stn);
            cfg.dnpat = sprintf('%s_CTD%03dM*.000',upper(mcruise),stn);
            if stn==45
                cfg.dnpat = 'DY181_CTD45M.000';
            end
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
        check_sal = 0;
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
                sal_off = [
                    000 -.5
                    001 -1
                    002 -1
                    003 -2
                    004 0
                    005 1.5
                    006 2
                    007 7 %***check T
                    009 -3 % No standard labelled 008
                    010 -1.5
                    011 -1.5
                    012 -2.5
                    013 -6
                    014 -2
                    015 -5
                    016 2
                    017 2
                    018 1
                    019 1
                    020 -2
                    021 -7.5
                    022 -2
                    023 1.5
                    %024 9.5 %suspicious maybe bad (old?)
                    %025 9.5 %suspicious maybe bad (a few minutes later)
                    026 1 %this one was 45 min after 025, back to "normal"
                    027 2
                    028 2
                    029 1
                    ];
                sal_off(:,1) = sal_off(:,1)+999e3;
                sal_off(:,2) = sal_off(:,2)*1e-5;
                sal_off_base = 'sampnum_list'; 
        end

    case 'botoxy'
        switch opt2
            case 'oxy_files'
                ofiles = {fullfile(root_oxy,'summary_150724.xlsx')};
                iih = 8;
                hcpat = {'Date'};
                chrows = 1; chunits = [];
                            case 'oxy_parse'
                calcoxy = 0;
                varmap.statnum = {'ctd_cast_no_1'};
                varmap.position = {'niskin_bot_no'};
                varmap.fix_temp = {'fixing_temp_c'};
                varmap.conc_o2 = {'c_o2_umol_per_l'};
            case 'oxy_flags'
                d.botoxya_flag(ismember(d.sampnum,[103 113 509 4123])) = 3;
                d.botoxyb_flag(ismember(d.sampnum,[4021])) = 3;
                d.botoxyc_flag(ismember(d.sampnum,[4013])) = 3;
                d.botoxya_flag(d.sampnum==4123) = 4; %maybe typo? check
                bads = ismember(d.sampnum,[3501 3507 3509 3515 3603 3607 3811 4207 5019]);
                d.botoxya_flag(bads) = max(d.botoxya_flag(bads),4);
                d.botoxyb_flag(bads) = max(d.botoxyb_flag(bads),4);
                d.botoxyc_flag(bads) = max(d.botoxyc_flag(bads),4);
                %check in more detail (botoxy vs ctd): 517
                %not sure (vs ctd, check gradient again): 3517, 3617, 3817, 4915
                %why is ctd profile in mctd_evaluate_sensors not having
                %testcal applied? and why on 48 is it apparently applied to
                %2up but not to 1hz?
        end

    case 'botnut'
        switch opt2
            case 'nut_files'
                hcpat = {'Depth'}; chrows = 1; chunits = 1;
            case 'nut_parse'
                ds_nut.position = nan+ds_nut.statnum;
                for no = 1:length(ds_nut.statnum)
                    ii = findstr('BTL',ds_nut.statname_niskin{no});
                    if ~isempty(ii)
                        ds_nut.position(no) = str2double(ds_nut.statname_niskin{no}(ii+[3:4]));
                    end
                end
                ds_nut(isnan(ds_nut.position),:) = [];
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
                        kstns = [35:39 42:45 47 46 48:65 69 68 71];
                        mgrid.xlim = 2; mgrid.zlim = 4;
                    case 'scotshelf'
                        mgrid.zpressgrid = [0 5 25 50 75 100 125 150 175 200 250 300];
                        kstns = [6:9 35:36];
                    case 'profiles_only'
                        kstns = [1:3 10:33]; %test, dm, yo-yo
                end
        end

    case 'batchactions'
        switch opt2
            case 'output_for_others'
                pdir = '/data/pstar/mounts/public/DY181/Science/CTD_bottle_data';
                syncs = {'%s/collected_files/station_summary* %s/';...
                         '%s/collected_files/74EQ* %s/';...
                         '%s/ctd/ctd*2db.nc %s/ctd_2db/';...
                         '%s/ctd/BOTTLE_SAL/autosal*.csv %s/';...
                         '%s/ladcp/ix/DLUL_GPS_BT/processed/*.mat %s/'};
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

