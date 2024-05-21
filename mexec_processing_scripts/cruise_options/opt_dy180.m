switch opt1

    case 'setup'
        switch opt2
            case 'time_origin'
                MEXEC_G.MDEFAULT_DATA_TIME_ORIGIN = [2024 1 1 0 0 0];
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
               %sequential numbering and handled with cnvfilename
            case 's_choice'
                s_choice = 2; %fin sensor
            case 'o_choice'
                o_choice = 2; %fin sensor

        end

    case 'ctd_proc'
        switch opt2
            case 'redoctm'
            case 'cnvfilename'
                if redoctm; postf = '_align_ctm'; else; postf = ''; end
                if ismember(stn,ticasts)
                    framestr = 'Ti';
                else
                    framestr = 'SS';
                end
                cnvfile = fullfile(cdir,sprintf('%s%s_%03d%s.cnv',upper(mcruise),framestr,stn,postf));                %Ti vs SS casts?
        end

    case 'ladcp_proc'
        cfg.p.ambiguity = 4.0; %this one is not used?
        cfg.p.vlim = 4.0; %this one is***check it matches
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

    case 'check_sams'
        %make this display-dependent? (or session-dependent?)
        check_sal = 0;
        check_oxy = 0;
        check_sbe35 = 0;

end

