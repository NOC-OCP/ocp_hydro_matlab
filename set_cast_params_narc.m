% LADCP Cast Processing for NARC DY167 in 2023
% Set the cast number in here and then run process_cast.m 
% e.g. process_cast(001)

% Station
stn=162;
stnstr = 'CTD162';

%% Load CTD metadata file for lat-lon and define cruise ID
    meta = load('/Users/jeh200/Library/CloudStorage/OneDrive-NOC/NArc/data_proc/events/DY167_CTD_MetaData.mat');
    ip = strmatch(stnstr,meta.ID);
    lat = meta.LAT(ip); lon = meta.LON(ip);

% Define cruise ID
    p.cruise_id = 'DY167';
    p.ladcp_station = stn;
    p.whoami = 'Jo Hopkins';

% Define plot titles
    p.name=sprintf('SS-Cast %d of %s (Combined LADCP+CTD+GPS)',p.ladcp_station,p.cruise_id)
% Set base name of checkpoint file
    f.checkpoints=sprintf('/Users/jeh200/Library/CloudStorage/OneDrive-NOC/NArc/data_proc/LADCP/checkpoints/%03d',stn);
% Set basename of output file
    f.res=sprintf('/Users/jeh200/Library/CloudStorage/OneDrive-NOC/NArc/data_proc/LADCP/processed/%03d',stn);

%% Set filename of raw LADCP files

% Master - downward
    f.ladcpdo=sprintf('/Users/jeh200/Library/CloudStorage/OneDrive-NOC/NArc/data_proc/LADCP/raw/DY167_CTD_%03dM.000',stn);
    %p.saveplot=[1:4 11 13:14];
    
% Slave - upward
    f.ladcpup=sprintf('/Users/jeh200/Library/CloudStorage/OneDrive-NOC/NArc/data_proc/LADCP/raw/DY167_CTD_%03dS.000',stn);
    
    
    %p.saveplot=[1:6 10:11 13:14];
    p.saveplot=[1:6 9:11 13:14];

%% Set magnetic declination    
    
    % p.drot = magdev(lat,lon,0,2023); Do NOT set manually if GPS data are
    % used in the processing
    
    p.btrk_ts = 10;
    
%% CTD data

    f.ctd=sprintf('/Users/jeh200/Library/CloudStorage/OneDrive-NOC/NArc/data_proc/LADCP/ctd_1s_bin/DY167_CTD_%03dS_derived_LADCP.asc',stn);
    f.ctd_header_lines = 1;
    f.ctd_fields_per_line = 6;
    f.ctd_pressure_field = 4;
    f.ctd_temperature_field = 5;
    f.ctd_salinity_field = 6;
    f.ctd_time_field = 3;
% ctd_time_base
% 0 = seconds elapsed - number of seconds since the CTD was turned on
% 1 = Year-Day - decimal days since the beginning of the curent year,
%       starting 1.0 at middnight on 1st Jan
% 2 = Gregorian - decimal days (suboptimal choice)
    f.ctd_time_base = 1; 
    
%% Navigation data

    f.nav=f.ctd;
    f.nav_header_lines=1;
    f.nav_fields_per_line=6;
    f.nav_lat_field=1;
    f.nav_lon_field=2;
    f.nav_time_field=3;
    f.nav_time_base=1;

%% Include SADCP data

    f.sadcp = '/Users/jeh200/Library/CloudStorage/OneDrive-NOC/NArc/data_proc/LADCP/SADCP/DY167_SADCP.mat';
    ps.sadcpfac=0;
    ps.barofrac = 0;


%%Call mkSADCP to update Vessel Mounted ADCP data file

%    CODAS_CONTOUR_DIR = '/Volumes/current_cruise/Ship_Systems/Data/Acoustics/ADCP/proc/os150nb/contour';
     CODAS_CONTOUR_DIR = '/Users/jeh200/Library/CloudStorage/OneDrive-NOC/NArc/data_proc/VMADCP/os150nb_from_ship/contour';
     SADCP_OUTPUT_FILE = '/Users/jeh200/Library/CloudStorage/OneDrive-NOC/NArc/data_proc/LADCP/SADCP/DY167_SADCP';
    
     mkSADCP(CODAS_CONTOUR_DIR,SADCP_OUTPUT_FILE);



