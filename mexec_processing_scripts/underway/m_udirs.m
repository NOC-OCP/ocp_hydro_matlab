function [udirs, udcruise] = m_udirs()

udcruise = 'jc238';
udirs = {
'winch'    'ctd/WINCH'    'winchlog_winch';
'hdtgyro'    'nav/gyro'    'sgyro_hehdt';
'attpmv'    'nav/pmv'    'posmv_pashr';
'hdtpmv'    'nav/pmv'    'posmv_gphdt';
'pospmv'    'nav/pmv'    'posmv_gpgga';
'vtgpmv'    'nav/pmv'    'posmv_gpvtg';
'poscnav'    'nav/cnav'    'cnav_gngga';
'vtgcnav'    'nav/cnav'    'cnav_gnvtg';
'dopcnav'    'nav/cnav'    'cnav_gngsa';
'posranger'    'nav/ranger'    'ranger2usbl_gpgga';
'attsea'    'nav/sea'    'seapathatt_psxn23';
'hdtsea'    'nav/sea'    'seapathgps_inhdt';
'possea'    'nav/sea'    'seapathgps_ingga';
'vtgsea'    'nav/sea'    'seapathgps_invtg';
'surfmet'    'met/surfmet'    'surfmet_gpxsm';
'windsonic'    'met/sonic'    'windsonicnmea_iimwv';
'multib_t'    'bathy/multib'    'em122_kidpt';
'singleb'    'bathy/singleb'    'ea640_sddbs';
'singleb_t'    'bathy/singleb'    'ea640_sddpt';
'envtemp'    'uother/env'    'envtemp_wimta';
'envhumid'    'uother/env'    'envtemp_wimhu';
'tsg'    'met/tsg'    'sbe45_nanan';
'logchf'    'uother/chf'    'slogchernikeef_vmvbw';
};
