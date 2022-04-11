function udirs = muwaydirs(Mshipdatasystem)

switch Mshipdatasystem

    case {'scs' 'techsas'}
%nav streams
udirsn = {
     'adupos'              'nav/adu'
	 'adu5pat'             'nav/adu'
	 'ashtech'             'nav/ash'
	 'attsea'              'nav/seaatt'
	 'attseaaux'           'nav/seaatt'
     'attphins'            'nav/phinsatt'
     'attposmv'            'nav/posmvatt'
	 'cnav'                'nav/cnav'
	 'satinfocnav'         'nav/cnav'
	 'dps116'              'nav/dps'
     'posdps'              'nav/dps'
	 'satinfodps'          'nav/dps'
	 'dps116_regen'        'nav/dps'
	 'furuno_gga'          'nav/furuno'
	 'furuno_gll'          'nav/furuno'
	 'furuno_rmc'          'nav/furuno'
	 'furuno_vtg'          'nav/furuno'
	 'furuno_zda'          'nav/furuno'
	 'glonass'             'nav/glonass'
     'gps_g12'             'nav/gps'
	 'gps4000'             'nav/gps'
	 'satinfo4000'         'nav/gps'
	 'gpsfugro'            'nav/gps'
	 'satinfofugro'        'nav/gps'
	 'gps1'                'nav/gps'
	 'gps2'                'nav/gps'
     'gyropmv'             'nav/gyropmv'
	 'gyro_s'              'nav/gyros'
	 'posmvpos'            'nav/posmvpos'
	 'satinfoposmv'        'nav/posmvpos'
	 'posmvpos_regen'      'nav/posmvpos'
	 'posmvtss'            'nav/posmvtss'
	 'seapos'              'nav/seapos'
	 'satinfosea'          'nav/seapos'
     'posranger'           'nav/ranger'
     'satinforanger'       'nav/ranger'
	 'seapos_regen'        'nav/seapos'
	 'seatex_gga'          'nav/seatex'
	 'seatex_gll'          'nav/seatex'
	 'seatex_hdt'          'nav/seahead'
	 'seatex_psxn'         'nav/seatex'
	 'seatex_vtg'          'nav/seatex'
	 'seatex_zda'          'nav/seatex'
	 'tsshrp'	       'nav/tsshrp'
   	 'dopplerlog'      'nav/log'
	 'chf'             'nav/log'
	 'emlog_vlw'       'nav/log'
	 'emlog_vhw'       'nav/log'
	 'log_chf'         'nav/log'
	 'log_skip'        'nav/log'
        };

    %others
udirso = {
     'surflight'       'met/surflight'
	 'surflight_regen' 'met/surflight_regen'
     'met_light'       'met/surflight'
	 'surfmet'         'met/surfmet'
%	 'surfmet'         'met/anemom'
	 'anemometer'         'met/anemom'
	 'surfmet_regen'   'met/surfmet'
	 'met_tsg'         'ocl/tsg'
	 'surftsg'         'ocl/tsg'
	 'oceanlogger'     'ocl/tsg'
	 'ocl'             'ocl/tsg'
	 'SBE45'           'ocl/tsg'
	 'tsg'             'ocl/tsg'
%	 'surftsg'         'ocl/tsg'
	 'surftsg_regen'   'ocl/tsg'
	 'sim'             'bathy/sim'
	 'em120'           'bathy/em120'
	 'em122'           'bathy/em120'
	 'gravity'	       'uother/gravity'
	 'mag'		       'uother/mag'
	 'seaspy'	       'uother/mag'
	 'netmonitor'      'uother/netmonitor'
	 'usbpos'	       'uother/usbl'
	 'satinfousb'      'uother/usbl'
	 'usbl'		       'uother/usbl'
	 'usbl_gga'	       'uother/usbl'
	 'winch'	       'uother/winch'
        };

udirs = [udirsn; udirso]; clear udirsn udirso

    case 'rvdas'

            udirs = {
        'dopcnav'    fullfile('nav','cnav')
        'poscnav'    fullfile('nav','cnav')
        'vtgcnav'    fullfile('nav','cnav')
        'posfugro'   fullfile('nav','fugro')
        'hdtgyro'    fullfile('nav','gyro')
        'attpmv'     fullfile('nav','pmv')
        'hdtpmv'     fullfile('nav','pmv')
        'pospmv'     fullfile('nav','pmv')
        'vtgpmv'     fullfile('nav','pmv')
        'posranger'  fullfile('nav','ranger')
        'attsea'     fullfile('nav','sea')
        'hdtsea'     fullfile('nav','sea')
        'possea'     fullfile('nav','sea')
        'dopsea'     fullfile('nav','sea')
        'vtgsea'     fullfile('nav','sea')
        'tsg'        fullfile('met','tsg')
        'surfmet'    fullfile('met','surfmet')
        'windsonic'  fullfile('met','sonic')
        'winch'      fullfile('ctd','WINCH')
        'ea600'      fullfile('bathy','ea600')
        'em120'      fullfile('bathy','em120')
        'singleb'    fullfile('bathy','singleb')
        'singleb_t'  fullfile('bathy','singleb')
        'multib'     fullfile('bathy','multib')
        'multib_t'   fullfile('bathy','multib')
        'envhumid'   fullfile('uother','env')
        'envtemp'    fullfile('uother','env')
        'gravity'    fullfile('uother','gravity')
        'logchf'     fullfile('uother','chf')
        'logskip'    fullfile('uother','skip')
        'mag'        fullfile('uother','mag')
        };
end
