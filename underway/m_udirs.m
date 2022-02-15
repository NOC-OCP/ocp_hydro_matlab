function [udirs, udcruise] = m_udirs();

udcruise = 'dy146';
udirs = {
'winch'    'ctd/WINCH'    'nmf_winch_winch';
'hdtgyro'    'nav/gyro'    'ships_gyro_hehdt';
'attpmv'    'nav/pmv'    'posmv_pos_pashr';
'hdtpmv'    'nav/pmv'    'posmv_pos_gphdt';
'pospmv'    'nav/pmv'    'posmv_pos_gpgga';
'vtgpmv'    'nav/pmv'    'posmv_pos_gpvtg';
'posfugro'    'nav/fugro'    'fugro_gps_gpgga';
'poscnav'    'nav/cnav'    'cnav_gps_gngga';
'vtgcnav'    'nav/cnav'    'cnav_gps_gnvtg';
'posranger'    'nav/ranger'    'ranger2_usbl_gpgga';
'attsea'    'nav/sea'    'seapath_att_psxn23';
'hdtsea'    'nav/sea'    'seapath_pos_inhdt';
'possea'    'nav/sea'    'seapath_pos_ingga';
'vtgsea'    'nav/sea'    'seapath_pos_invtg';
'surfmet'    'met/surfmet'    'nmf_surfmet_gpxsm';
'multib_t'    'bathy/multib'    'em122_depth_kidpt';
'singleb'    'bathy/singleb'    'em640_depth_sddbs';
'singleb_t'    'bathy/singleb'    'em640_depth_sddpt';
'envtemp'    'uother/env'    'env_temp_wimta';
'envhumid'    'uother/env'    'env_temp_wimhu';
'tsg'    'met/tsg'    'sbe45_tsg_nanan';
'logskip'    'uother/skip'    'ships_skipperlog_vdvbw';
};
