function [udirs, udcruise] = m_udirs();

udcruise = 'dy146';
udirs = {
'cnav'    'nav/cnav'    'cnav-CNAV-3050_GPS.GPS';
'gpsfugro'    'nav/gps'    'cnav-FUGRO-SEASTAR_GPS.GPS';
'pospmv'    'nav/pmv'    'position-POSMV_GPS.gps';
'seapos'    'nav/sea'    'position-Seapath330_GPS.gps';
'satinfoposmv'    'nav/pmv'    'satelliteinfo-POSMV_GPS.gps';
'satinfocnav'    'nav/cnav'    'satelliteinfo-CNAV-3050_GPS.GPS';
'satinfofugro'    'nav/gps'    'satelliteinfo-FUGRO-SEASTAR_GPS.GPS';
'satinfosea'    'nav/sea'    'satelliteinfo-Seapath330_GPS.gps';
'attpmv'    'nav/pmv'    'shipattitude-POSMV_ATT.att';
'attphins'    'nav/phins'    'shipattitude-Phins_ATT.att';
'hdtphins'    'nav/phins'   'shipheading-Phins_ATT.att';
'hdtphins'    'nav/phins'   'shipheading-Phins_ATT.att';
'attsea'    'nav/sea'    'shipattitude-Seapath330_ATT.att';
'attseaaux'    'nav/sea'    'shipattitude_aux-Seapath330_ATT.att';
'gyro_s'    'nav/gyros'    'gyro-SGYRO_GYRO.gyr';
'log_skip'    'nav/log'    'logskippervdvbw-SKIP_LOG.nc';
'surflight'    'met/surflight'    'Light-SURFMET.SURFMETv3';
'surfmet'    'met/surfmet'    'MET-SURFMET.SURFMETv3';
'met_tsg'    'ocl/tsg'    'Surf-SURFMET.SURFMETv3';
'winch'    'uother/winch'    'CLAM-CLAM_WINCH.CLAM';
'singleb'  'bathy/singleb'   '';
'multib'   'bathy/multib'    '';
'tsg'      'ocl/tsg'         '';
};
