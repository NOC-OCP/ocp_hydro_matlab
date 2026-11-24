switch opt2
    case 'ladcp_files'
        foundit = true;
        cfg.stnstr = stn_string;
        %file and format for ascii file of 1hz ctd data and corresponding nmea nav data
        cfg.f.ctd = fullfile(MEXEC_G.data_root, 'ladcp', 'ctd', sprintf('ctd.%s.asc',stn_string));
        cfg.f.ctd_header_lines      = 1;
        cfg.f.ctd_fields_per_line	= 6;
        cfg.f.ctd_time_base = 1; %year-day
        cfg.f.ctd_time_field = 1;
        cfg.f.ctd_pressure_field	= 2;
        cfg.f.ctd_temperature_field = 3;
        cfg.f.ctd_salinity_field	= 4;
        cfg.f.nav                   = cfg.f.ctd;
        cfg.f.nav_header_lines	= cfg.f.ctd_header_lines;
        cfg.f.nav_fields_per_line	= cfg.f.ctd_fields_per_line;
        cfg.f.nav_time_base = cfg.f.ctd_time_base;
        cfg.f.nav_time_field	= cfg.f.ctd_time_field;
        cfg.f.nav_lat_field 	= 5;
        cfg.f.nav_lon_field 	= 6;
        if exist('inst','var')
            %file for vmadcp data corresponding to this cast. if available, use
            %the instrument/mode with deepest range
            cfg.f.sadcp = replace(pfiles.sadcp_stnav,'stn_string',stn_string);
        end
        cfg.
        cfg.rawdir = fullfile(MEXEC_G.data_root, 'ladcp','rawdata');
        if stn==6
            cfg.uppat = sprintf('UL%s00*m.000',cfg.stnstr);
            cfg.dnpat = sprintf('DL%s00*s.000',cfg.stnstr);
        else
            cfg.uppat = sprintf('UL%s00*s.000',cfg.stnstr);
            cfg.dnpat = sprintf('DL%s00*m.000',cfg.stnstr);
        end
    case 'ladcp_cfg'
        foundit = true;
        cfg.p.cruise_id = MEXEC_G.mcruise;
        cfg.p.ladcp_station = stn;
        %parameters for LADCP processing
        %cfg.p.magdec_source = 1;
        %cfg.p.drot = system()
        %cfg.p.edit_mask_dn_bins = 1;
        %cfg.p.edit_mask_up_bins = 1;
        cfg.p.orig = 0; % save original data or not
        isul = 1; %is there an uplooker? process it first on its own
        cfg.p.ambiguity = 4.0; %this one is not used?
        %cfg.p.vlim = 4.0; %no default set; check LADCP configuration and
        %set to match
end
