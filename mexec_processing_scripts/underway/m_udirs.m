function [udirs, udcruise] = m_udirs()

udcruise = 'en697';
udirs = {
'posfur'    'nav/furuno'    'furuno_gga'
'singleb'   'bathy/singleb'  'singleb'
'hdtgyro'    'nav/gyro'    'gyro'
'sbe21'   'tsg/sbe21'  'sbe21'
'sbe45'   'tsg/sbe45'  'sbe45'
'dopplerlog' 'nav/dopplerlog' 'dopplerlog'
'abxtwo'      'nav/abxtwo'    'abxtwo'
% 'attpmv'    'nav/pmv'    'posmv_pashr';
% 'attsea'    'nav/sea'    'seapathatt_psxn23';
% 'dopcnav'    'nav/cnav'    'cnav_gngsa';
% 'envhumid'    'uother/env'    'envtemp_wimhu';
% 'envtemp'    'uother/env'    'envtemp_wimta';
% 'hdtpmv'    'nav/pmv'    'posmv_gphdt';
% 'hdtsea'    'nav/sea'    'seapathgps_inhdt';
% 'multib'    'bathy/multib'    'em122_kidpt';
% 'poscnav'    'nav/cnav'    'cnav_gngga';
% 'pospmv'    'nav/pmv'    'posmv_gpggk';
% 'possea'    'nav/sea'    'seapathgps_ingga';
% 'singleb'    'bathy/singleb'    'ea640_sddpt';
% 'surfmet'    'met/surfmet'    'surfmet_gpxsm';
% 'tsg'    'met/tsg'    'sbe45_nanan';
% 'vtgcnav'    'nav/cnav'    'cnav_gnvtg';
% 'vtgpmv'    'nav/pmv'    'posmv_gpvtg';
% 'vtgsea'    'nav/sea'    'seapathgps_invtg';
% 'winch'    'ctd/WINCH'    'winchlog_winch';
% 'windsonic'    'met/sonic'    'windsonicnmea_iimwv';
};

% udcruise = 'jc238';
% udirs = {
% 'attpmv'    'nav/pmv'    'posmv_pashr';
% 'attsea'    'nav/sea'    'seapathatt_psxn23';
% 'dopcnav'    'nav/cnav'    'cnav_gngsa';
% 'envhumid'    'uother/env'    'envtemp_wimhu';
% 'envtemp'    'uother/env'    'envtemp_wimta';
% 'hdtgyro'    'nav/gyro'    'sgyro_hehdt';
% 'hdtpmv'    'nav/pmv'    'posmv_gphdt';
% 'hdtsea'    'nav/sea'    'seapathgps_inhdt';
% 'multib'    'bathy/multib'    'em122_kidpt';
% 'poscnav'    'nav/cnav'    'cnav_gngga';
% 'pospmv'    'nav/pmv'    'posmv_gpggk';
% 'possea'    'nav/sea'    'seapathgps_ingga';
% 'singleb'    'bathy/singleb'    'ea640_sddpt';
% 'surfmet'    'met/surfmet'    'surfmet_gpxsm';
% 'tsg'    'met/tsg'    'sbe45_nanan';
% 'vtgcnav'    'nav/cnav'    'cnav_gnvtg';
% 'vtgpmv'    'nav/pmv'    'posmv_gpvtg';
% 'vtgsea'    'nav/sea'    'seapathgps_invtg';
% 'winch'    'ctd/WINCH'    'winchlog_winch';
% 'windsonic'    'met/sonic'    'windsonicnmea_iimwv';
% };
