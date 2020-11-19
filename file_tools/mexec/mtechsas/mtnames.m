function matlist = mtnames
% function matlist = mtnames
%
% approximate triplets of mexec short names, rvs streams and techsas streams 
%
% If called with no output argumnets, list is printed to terminal.
%
% entries are
% mexec short name; rvs name; techsas name

% JC032. If you need to add lines, that is harmless. If you need a whole
% new set of correspondences, retain this list but comment it out, and add
% your new list.

% list of Cook names significantly changed between JC032 and JC044
% no changes noted for jc064: bak in falmouth on w/s oceanus

m_common

matlist = {};

switch MEXEC_G.Mship
   case 'cook'
      matlist = {
%         'adupos'                      ' '                  'ADUPOS-ADUPOS_JC1.gps'
%         'adupos'                      ' '                  'PASHRPOS-ADUPOS_JC1.PASHR'
%         'smartsv'               'smartsv'                          'AML-AMLSV.SVP'
%         'gyropmv'               'gyropmv'                 'GyroJC-GYRO1_JC1.gyrJC'
%         'gyropmv'               'gyropmv'                 'gyro-GYRO1_JC1.gyr'
'gyropmv'      'gyropmv'             'gyro-POSMV_GYRO.gyr'
%         'gyro_s'                 'gyro_s'                 'GyroJC-SGYRO_JC1.gyrJC'
%         'gyro_s'                 'gyro_s'                 'gyro-SGYRO_JC1.gyr'
 'gyro_s'       'gyro_s'             'gyro-SGYRO_GYRO.gyr'
%         'adu5pat'               'adu5pat'                    'gppat-GPPAT_JC1.att'
         'adu5pat'               'adu5pat'                    'GPPAT-GPPAT_JC1.GPPAT'
%         'posmvpos'             'posmvpos'          'position-Applanix_GPS_JC1.gps'
 'posmvpos'     'posmvpos'             'position-POSMV_GPS.gps'
%         'satinfoposmv'               ' '     'satelliteinfo-Applanix_GPS_JC1.gps'
'satinfoposmv' 'posmvpos'             'satelliteinfo-POSMV_GPS.gps'
%         'dps116'                'dps116'               'position-DPS-116_JC1.gps'
%         'posmvtss'            'posmvtss'       'shipattitude-Aplanix_TSS_JC1.att'
%         'attposmv'                   'attposmv'   'shipattitude_aux-Aplanix_TSS_JC1.att'
         'attposmv'                   'attposmv'   'shipattitude-POSMV_ATT.att'
         'attposmvaux'          'attposmv'         'shipattitude_aux-POSMV_ATT.att'
 'posdps'       'posdps'             'position-DPS-116_GPS.gps'
%         'satinfodps'                 ' '          'satelliteinfo-DPS-116_JC1.gps'
 'satinfodps'   'posdps'             'satelliteinfo-DPS-116_GPS.gps'
%         'seapos'                'seapos'            'position-Seapath200_JC1.gps'
%         'seapos'                'seapos'            'position-Seapath330_JC1.gps'
 'seapos'       'seapos'             'position-Seapath330_GPS.gps'
%         'satinfosea'                 'seapos'       'satelliteinfo-Seapath200_JC1.gps' 
%         'satinfosea'                 'seapos'       'satelliteinfo-Seapath330_JC1.gps'
 'satinfosea'   'seapos'             'satelliteinfo-Seapath330_GPS.gps'
%         'attsea'                'attsea'      'shipattitude-Seapath200AT_JC1.att'
%         'attsea'                'attsea'      'shipattitude-Seapath330AT_JC1.att'
         'attsea'                'attsea'      'shipattitude-Seapath330_ATT.att'
%         'attseaaux'                  'attsea'  'shipattitude_aux-Seapath200AT_JC1.att'
%         'attseaaux'                  'attsea'  'shipattitude_aux-Seapath330AT_JC1.att'
         'attseaaux'                  'attsea'  'shipattitude_aux-Seapath330_ATT.att'
 'posranger'    'posranger'             'position-Ranger2_USBL.gps'
  'satinforanger' 'posranger'             'satelliteinfo-Ranger2_USBL.gps'
%         'cnav'                   'cnav'                              'cnav-CNAV.GPS'
 'cnav'         'cnav'             'cnav-CNAV-3050_GPS.GPS'
%         'satinfocnav'  'cnav'              'satelliteinfo-CNAV.gps'
 'satinfocnav'  'cnav'             'satelliteinfo-CNAV-3050_GPS.GPS'
         'usbpos'                     'usbl'                  'position-usbl_JC1.gps'
         'satinfousb'                 'usbl'             'satelliteinfo-usbl_JC1.gps'
%         'gravity'               'gravity'                  'AirSeaII-S84_JC1.grav'
%         'gravity'               'gravity'                  'AirSeaII-S84_JC1.AirSeaII'
         'gravity'      'gravity'             'AirSeaII-AirSeaII-S40_GRAVITY.nc'
%         'em120'                 'EM120'               'sb_depth-EM120_JC1.depth'
 'em120'        'em120'             'sb_depth-EM122_DEPTH.depth'
%         'ea600m'                 'ea600m'                  'EA600-EA600_JC1.EA600'
 'ea600m'       'ea600'             'EA600-EA640_DEPTH.EA600'
 %        'sim'                    'sim'                  'EA600-EA600_JC1.EA600'
 'sim'          'sim'             'EA600-EA640_DEPTH.EA600'
%         'winch'                   'winch'                 'JCWinch-CLAM_JC1.winch'
%         'winch'                   'winch'                 'CLAM-CLAM_JC1.CLAM'
         'winch'                   'winch'                 'CLAM-CLAM_WINCH.CLAM'
%         'surflight'             'surfmet'              'Light-JC-SM_JC1.SURFMETv2'
%  'surflight'    'surfmet'             'Light-SURFMET.SURFMETv2'
 'surflight'    'surfmet'             'Light-SURFMETv3.SURFMETv3' % bak; new on jc191
%         'met_light'             'surfmet'              'Light-JC-SM_JC1.SURFMETv2'
%          'met_light'             'surfmet'              'Light-SURFMET.SURFMETv2'
         'met_light'             'surfmet'              'Light-SURFMETv3.SURFMETv3' % bak; new on jc191
%         'surfmet'               'surfmet'                'MET-JC-SM_JC1.SURFMETv2'
%  'surfmet'      'surfmet'             'MET-SURFMET.SURFMETv2'
 'surfmet'      'surfmet'             'MET-SURFMETv3.SURFMETv3' % bak new on jc191
%         'surftsg'               'surfmet'               'Surf-JC-SM_JC1.SURFMETv2'
%         'met_tsg'               'surfmet'               'Surf-JC-SM_JC1.SURFMETv2'
%  'met_tsg'      'surfmet'             'Surf-SURFMET.SURFMETv2'
 'met_tsg'      'surfmet'             'Surf-SURFMETv3.SURFMETv3' % bak new on jc191
%         'SBE45'                   'SBE45'                          'SBE45-SBE45_JC1.TSG'
         'tsg'                   'tsg'                          'SBE45-SBE45.TSG'
         'mag'                        ' '              'scalar_mag-SeaSpy_JC1.mag'
%         'log_skip'            'log_skip'                 'vdvhw-log_skip_JC1.log'
%         'log_skip'            'log_skip'                 'VDVHW-log_skip_JC1.Log'
 'log_skip'     'log_skip'             'logskippervdvbw-SKIP_LOG.nc'
%         'log_chf'             'log_chf'                  'EMLog-log_chf_JC1.EMLog'
%         'log_chf'             'log_chf'                  'vmvbw-log_chf_JC1.log'
         'log_chf'             'log_chf'                  'vmvbw-CHF_LOG.log'
%         'surflight_regen'               'surfmet'              'Light-JC-SM_JC1.SURFMETv2.regen'
%         'surfmet_regen'               'surfmet'                'MET-JC-SM_JC1.SURFMETv2.regen'
%         'surftsg_regen'               'surfmet'               'Surf-JC-SM_JC1.SURFMETv2.regen'
%         'posmvpos_regen'              'posmvpos'          'position-Applanix_GPS_JC1.gps.regen'
%         'dps116_regen'                'posdps'               'position-DPS-116_JC1.gps.regen'
%         'seapos_regen'                'seapos'            'position-Seapath200_JC1.gps.regen'
      };		     

   case 'discovery'
      matlist = {           
        'adupos'              ' '  'ADUPOS-PAPOS.gps'
        'adupos' ' '   'PASHRPOS-PAPOS.PASHR'
        'adu5pat'       'gps_ash'  'gppat-GPPAT.att'
        'adu5pat' ' '  'GPPAT-GPPAT.GPPAT'
        'adu5pat'     ' '   'ADU2-ASH.gps'
        'gps_g12'       'gps_g12'  'ADUPOS-G12PAT.gps'
        'gps4000' ' '   'position-4000.gps'
        'gpsfugro' ' '   's9200G2s-FUGRO.GPS'
        'gps1' ' ' 's9200G2s-GPS1.GPS' % di368 gps splitter test
        'gps2' ' ' 's9200G2s-GPS2.GPS' % di368 gps splitter test
        'gyro_s' ' '   'gyro-GYRO.gyr'
        'satinfo4000' ' '   'satelliteinfo-4000.gps'
        'satinfofugro' ' '   'satelliteinfo-FUGRO.gps'
        'ea600m'          'ea500'  'PES-Simrad.PES'
        'ea600m' ' '  'PES-Simrad_PT1.PES'
%        'ea600m'      ' '   'PES-Simrad.PES'
        'log_chf'       'log_chf'  'DYLog-LOGCHF.DYLog'
        'log_chf ' ' '   'EMLog-LOGCHF.EMLog'
        'log_chf'     ' '   'logchf-log.logchf'
        'SBE45' ' '  'SBE45-SBE45.TSG'
        'surflight'     'surfmet'  'Light-SURFMET.SURFMETv2'
%        'surflight' ' '  'Light-SURFMET.SURFMETv2'
        'surfmet' ' ' 'MET-SURFMET.SURFMETv2'
%        'surfmet'       'surfmet'  'MET-SURFMET.SURFMETv2'
        'surfmet'     ' '   'SURFMET-Surfmet.met'
        'surftsg'       'surfmet'  'Surf-SURFMET.SURFMETv2'
%        'surftsg' ' '   'Surf-SURFMET.SURFMETv2'
        'winch'           'winch'  'DWINCH-CLAM.DWINCH'
%        'winch'       ' '   'DWINCH-CLAM.DWINCH'
        'winch' ' '   'CLAM-CLAM.CLAM'
        'usbl'        ' '   'USBL-USBL01.usbl'
    };
    
    otherwise
end
	
if nargout > 0; return; end

fprintf(1,'\n%20s %20s %45s\n\n',['mexec short name'],['rvs stream name'],['techsas stream name']);

for kstream = 1:size(matlist,1)
fprintf(1,'%20s %20s %45s\n',['''' matlist{kstream,1} ''''],['''' matlist{kstream,2} ''''],['''' matlist{kstream,3} '''']);
end
