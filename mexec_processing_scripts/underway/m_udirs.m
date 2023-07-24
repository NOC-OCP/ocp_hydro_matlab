function [udirs, udcruise] = m_udirs()

udcruise = 'en705';
udirs = {
'posfur'    'nav/furuno'    'GPS_Furuno_GGA'
'singleb'   'bathy/singleb'  'SingleBeam_Knudsen_PKEL99'
'hdtgyro'    'nav/gyro'    'Gyro1_HDT'
'sbe21'   'tsg/sbe21'  'TSG1_SBE21'
'sbe45'   'tsg/sbe45'  'TSG2_SBE45'
'dopplerlog' 'nav/dopplerlog' 'SpeedLog_Furuno_VBW'
'abxtwo'      'nav/abxtwo'    'GNSS_ABXTWO_PASHR'
'winch'       'ctd/WINCH'     'Win1'
};
