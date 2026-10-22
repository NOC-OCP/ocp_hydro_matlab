switch opt2
    case 'ladcp_cfg'
        %file for vmadcp data corresponding to this cast. if available, use
        %the instrument/mode with deepest range
        cfg.f.sadcp = sprintf(pd.sadcp_for_ix,'os75nb',stn_string); 
        %file and format for ascii file of 1hz ctd data and corresponding nmea nav data
        cfg.f.ctd = sprintf(pd.ctdnav_for_ix, stn_string);
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
        %parameters for LADCP processing
        %cfg.p.magdec_source = 1;
        %cfg.p.drot = system()
        %cfg.p.edit_mask_dn_bins = 1;
        %cfg.p.edit_mask_up_bins = 1;
        cfg.p.orig = 0; % save original data or not
        isul = 1; %is there an uplooker? process it first on its own
        cfg.p.ambiguity = 4.0; %this one is not used?
        %cfg.p.vlim = 4.0; %this one is***require setting in opt_cruise
end