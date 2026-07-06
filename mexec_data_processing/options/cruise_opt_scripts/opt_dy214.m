mexec_defaults_sbe
mexec_defaults_org_noc

switch opt1

    case 'setup'
        switch opt2
            case 'time_origin'
                MEXEC_G.MDEFAULT_DATA_TIME_ORIGIN = [2026 1 1 0 0 0];
            case 'setup_datatypes'
            MEXEC_G.ladcp='ix';
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
                cnvfile = fullfile(cdir,sprintf('%s_CTD%s.cnv', upper('dy181'), stn_string));
                if stn==10
                    cnvfile = fullfile(cdir,sprintf('%s_CTD%04d.cnv', upper('dy181'), stn));
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
                co.docal.temp = 0;
                co.docal.cond = 0;
                co.docal.oxygen = 0;
                %co.calstr.temp.sn34116.dy181 = 'dcal.temp = d0.temp+interp1([1 101],[1e-3 0e-3],d0.statnum) - 5e-4 +interp1([0 3100],[1e-3 -0.8e-3],d0.press);';
                %co.calstr.temp.sn34116.msg = 'SBE35 comparison, 180 low gradient points';
        end

            case 'nisk_proc'
        switch opt2
            case 'blfilename'
                blinfile = fullfile(root_botraw,sprintf('%s_CTD%s.bl', upper('dy181'), stn_string));
                if stn==10
                    blinfile = fullfile(root_botraw,sprintf('%s_CTD%04d.bl', upper('dy181'), stn));
                elseif stn==65.1
                    blinfile = fullfile(root_botraw,sprintf('%s_CTD%03dA.bl', upper('dy181'), floor(stn)));
                    stn_string = '065'; %for dataname
                end
        end

    case 'adcp_proc'
        switch opt2
            case 'ladcp'
        min_nvmadcpprf = 4; %throws a warning if number of vmADCP profiles within an LADCP cast is less than this
        min_nvmadcpbin = 3; %masks depths with number of valid bins less than this
        min_nvmadcpbin_refl = 3; %throws a warning if number of good profiles at any depth in the watertrack reference layer is less than this
        cfg.rawdir = fullfile(mgetdir('ladcp'),'rawdata');
        yos = [10 33];        
        if stn>=yos(1) && stn<=yos(2)
            cfg.uppat = sprintf('%s_CTD%03d-%03dS*.000',upper('dy181'),yos(1),yos(2));
            cfg.dnpat = sprintf('%s_CTD%03d-%03dM*.000',upper('dy181'),yos(1),yos(2));
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
            cfg.uppat = sprintf('%s_CTD%03dS*.000',upper('dy181'),stn);
            cfg.dnpat = sprintf('%s_CTD%03dM*.000',upper('dy181'),stn);
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
        end

    case 'outputs'
        switch opt2
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
     
end