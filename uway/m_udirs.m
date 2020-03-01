function [udirs, udcruise] = m_udirs();

udcruise = 'dy113';
udirs = {
'cnav'    'M_CNAV'    'nav/cnav'    'cnav-CNAV.GPS';
'gpsfugro'    'M_GPSFUGRO'    'nav/gps'    'cnav-FUGRO.GPS';
'posmvpos'    'M_POSMVPOS'    'nav/posmvpos'    'position-Applanix_GPS_DY1.gps';
'satinfoposmv'    'M_SATINFOPOSMV'    'nav/posmvpos'    'satelliteinfo-Applanix_GPS_DY1.gps';
'satinfocnav'    'M_SATINFOCNAV'    'nav/cnav'    'satelliteinfo-CNAV.GPS';
'satinfofugro'    'M_SATINFOFUGRO'    'nav/gps'    'satelliteinfo-FUGRO.GPS';
'attposmv'    'M_ATTPOSMV'    'nav/posmvatt'    'shipattitude-Applanix_TSS_DY1.att';
'attphins'    'M_ATTPHINS'    'nav/phinsatt'    'shipattitude-Phins_TSS_DY1.att';
'attsea'    'M_ATTSEA'    'nav/seaatt'    'shipattitude-Seapath_TSS_DY1.att';
'attseaaux'    'M_ATTSEAAUX'    'nav/seaatt'    'shipattitude_aux-Seapath_TSS_DY1.att';
'gyro_s'    'M_GYRO_S'    'nav/gyros'    'gyro-SGYRO_DY1.gyr';
'em120'    'M_EM120'    'bathy/em120'    'sb_depth-EM120_DY1.depth';
'sim'    'M_SIM'    'bathy/sim'    'EA600-EA640_DY1.EA600';
'log_skip'    'M_LOG_SKIP'    'ocl/log'    'logskippervdvbw-SkipLog.nc';
'surflight'    'M_SURFLIGHT'    'met/surflight'    'Light-DY-SM_DY1.SURFMETv3';
'surfmet'    'M_SURFMET'    'met/surfmet'    'MET-DY-SM_DY1.SURFMETv3';
'tsg'    'M_TSG'    'ocl/tsg'    'SBE45-SBE45_DY1.TSG';
'met_tsg'    'M_MET_TSG'    'ocl/tsg'    'Surf-DY-SM_DY1.SURFMETv3';
'winch'    'M_WINCH'    'uother/winch'    'CLAM-CLAM_DY1.CLAM';
};
