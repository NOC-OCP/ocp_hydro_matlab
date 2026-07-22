%for ladcp, using vmadcp
cfg.f.sadcp = fullfile(root_vmadcp, 'mproc', [dataname '_forladcp.mat']);
SADCP_inst = 'os75nb';

%and ctd: set file location and format for ascii file of 1hz ctd
%data and nmea nav data, which will be used in ladcp LDEO_IX processing
cfg.f.ctd = fullfile(mgetdir('ladcp'), 'ctd', ['ctd.' stn_string '.02.asc']);
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
cfg.p.magdec_source = 1;
%cfg.p.edit_mask_dn_bins = 1;
%cfg.p.edit_mask_up_bins = 1;
cfg.p.orig = 0; % save original data or not
isul = 1; %is there an uplooker? process it first on its own
cfg.rawdir = fullfile(mgetdir('ladcp'),'rawdata',cfg.stnstr);
cfg.pdir_root = fullfile(mgetdir('ladcp'),'ix');
cfg.p.ambiguity = 4.0; %this one is not used?
%cfg.p.vlim = 4.0; %this one is***require setting in opt_cruise
