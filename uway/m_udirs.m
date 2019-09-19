function [udirs, udcruise] = m_udirs();

udcruise = 'jr18002';
udirs = {
'furuno_gga'    'M_FURUNO_GGA'    'nav/furuno'    'furuno-gga';
'furuno_gll'    'M_FURUNO_GLL'    'nav/furuno'    'furuno-gll';
'furuno_rmc'    'M_FURUNO_RMC'    'nav/furuno'    'furuno-rmc';
'furuno_vtg'    'M_FURUNO_VTG'    'nav/furuno'    'furuno-vtg';
'furuno_zda'    'M_FURUNO_ZDA'    'nav/furuno'    'furuno-zda';
'gyro_s'    'M_GYRO_S'    'nav/gyros'    'gyro';
'seatex_gga'    'M_SEATEX_GGA'    'nav/seatex'    'seatex-gga';
'seatex_gll'    'M_SEATEX_GLL'    'nav/seatex'    'seatex-gll';
'seatex_hdt'    'M_SEATEX_HDT'    'nav/seahead'    'seatex-hdt';
'seatex_vtg'    'M_SEATEX_VTG'    'nav/seatex'    'seatex-vtg';
'seatex_zda'    'M_SEATEX_ZDA'    'nav/seatex'    'seatex-zda';
'tsshrp'    'M_TSSHRP'    'nav/tsshrp'    'tsshrp';
'netmonitor'    'M_NETMONITOR'    'uother/netmonitor'    'netmonitor';
'anemometer'    'M_ANEMOMETER'    'met/anemom'    'anemometer';
'dopplerlog'    'M_DOPPLERLOG'    'ocl/log'    'dopplerlog';
'ea600'    'M_EA600'    'bathy/sim'    'ea600';
'em122'    'M_EM122'    'bathy/em120'    'em122';
'emlog_vhw'    'M_EMLOG_VHW'    'ocl/log'    'emlog-vhw';
'emlog_vlw'    'M_EMLOG_VLW'    'ocl/log'    'emlog-vlw';
'oceanlogger'    'M_OCEANLOGGER'    'ocl/tsg'    'oceanlogger';
'seaspy'    'M_SEASPY'    'uother/mag'    'seaspy';
'usbl_gga'    'M_USBL_GGA'    'uother/usbl'    'usbl-gga';
'winch'    'M_WINCH'    'uother/winch'    'winch';
};
