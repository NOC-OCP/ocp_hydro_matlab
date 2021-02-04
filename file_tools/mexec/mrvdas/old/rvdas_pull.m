clear defs

defs.ships_gyro_hehdt = {  % from ships_gyro-jc.mat.json
    'ships_gyro_hehdt'  2  % fields
    'headingTrue'                      'degrees'
    %     'trueHeading'                             ''
    };

defs.nmf_winch_winch = {  % from nmf_winch-jc.json
    'nmf_winch_winch'  8  % fields
    %     'winchDatum'                             ''
    'cableType'                             ''
    'tension'                       'newton'
    'cableOut'                       'metres'
    'rate'                          'm/s'
    'backTension'                       'newton'
    'rollAngle'                      'degrees'
    %     'undefined'                             ''
    };


defs.posmv_gyro_gphdt = {  % from posmv_gyro-jc.json
    'posmv_gyro_gphdt'  2  % fields
    'headingTrue'                      'degrees'
    %     'trueHeading'                             ''
    };



defs.posmv_att_pashr = {  % from posmv_att-jc.json
    'posmv_att_pashr' 11  % fields
    'utcTime'                             ''
    'heading'                      'degrees'
    %     'trueFlag'                             ''
    'roll'                      'degrees'
    'pitch'                      'degrees'
    'heave'                       'metres'
    %     'rollAccuracy'                      'degrees'
    %     'pitchAccuracy'                      'degrees'
    %     'headingAccuracy'                      'degrees'
    %     'headingAccuracyFlag'                             ''
    %     'imuFlag'                             ''
    };

defs.posmv_pos_gpgga = {  % from posmv_pos-jc.json
    'posmv_pos_gpgga' 14  % fields
    'utcTime'                             ''
    'latitude'  'degrees and decimal minutes'
    'latDir'                             ''
    'longitude'  'degrees and decimal minutes'
    'lonDir'                             ''
    'ggaQual'                             ''
    'numSat'                             ''
    'hdop'                             ''
    'altitude'                             ''
    %     'unitsOfMeasureAntenna'                             ''
    %     'geoidAltitude'                             ''
    %     'unitsOfMeasureGeoid'                             ''
    %     'diffcAge'                      'seconds'
    %     'dgnssRefId'                             ''
    };



defs.posmv_pos_gpvtg = {  % from posmv_pos-jc.json
    'posmv_pos_gpvtg'  9  % fields
    'courseTrue'                      'degrees'
    %     'trueCourse'                             ''
    %     'magneticTrack'                      'degrees'
    %     'mFlag'                             ''
    'speedKnots'                        'knots'
    %     'nFlag'                             ''
    %     'speedKmph'                         'km/h'
    %     'kFlag'                             ''
    %     'positioningMode'                             ''
    };

defs.nmf_surfmet_gpxsm = {  % from nmf_surfmet-jc.mat.json
    'nmf_surfmet_gpxsm' 12  % fields
    'flow'                          'l/m'
    'fluo'                            'V'
    'trans'                            'V'
    'windSpeed'                          'm/s'
    'windDirection'                      'degrees'
    'airTemperature'               'degreesCelsius'
    'humidity'                            '%'
    'airPressure'                           'mB'
    'parPort'                            '-'
    'parStarboard'                            '-'
    'tirPort'                            '-'
    'tirStarboard'                            '-'
    };






defs.windsonic_nmea_iimwv = {  % from windsonic_nmea.mat.json
    'windsonic_nmea_iimwv'  5  % fields
    'windDirection'                      'degrees'
    %     'relWindmes'                             ''
    'windSpeed'                          'm/s'
    %     'Units'                             ''
    %     'status'                             ''
    };


defs.cnav_gps_gngga = {  % from cnav_gps-jc.json
    'cnav_gps_gngga' 14  % fields
    'utcTime'                             ''
    'latitude' 'degrees, minutes and decimal minutes'
    'latDir'                             ''
    'longitude' 'degrees, minutes and decimal minutes'
    'lonDir'                             ''
    'ggaQual'                             ''
    'numSat'                             ''
    'hdop'                             ''
    'altitude'                       'metres'
    %     'unitsOfMeasureAntenna'                             ''
    %     'geoidAltitude'                       'metres'
    %     'unitsOfMeasureGeoid'                             ''
    %     'diffcAge'                      'seconds'
    %     'dgnssRefId'                             ''
    };


defs.cnav_gps_gnvtg = {  % from cnav_gps-jc.json
    'cnav_gps_gnvtg'  9  % fields
    'courseOverGround'                      'degrees'
    %     'trueCourse'                             ''
    %     'magneticTrack'                      'degrees'
    %     'mFlag'                             ''
    'speedKnots'                        'knots'
    %     'nFlag'                             ''
    %     'speedKmph'                         'km/h'
    %     'kFlag'                             ''
    %     'positioningMode'                             ''
    };

defs.cnav_gps_gngsa = {  % from cnav_gps-jc.json
    'cnav_gps_gngsa' 18  % fields
    %     'gsaMode'                             ''
    %     'gsaStatus'                             ''
    %     'sId1'                             ''
    %     'sId2'                             ''
    %     'sId3'                             ''
    %     'sId4'                             ''
    %     'sId5'                             ''
    %     'sId6'                             ''
    %     'sId7'                             ''
    %     'sId8'                             ''
    %     'sId9'                             ''
    %     'sId10'                             ''
    %     'sId11'                             ''
    %     'sId12'                             ''
    'pdop'                             ''
    'hdop'                             ''
    'vdop'                             ''
    %     'gsid'                             ''
    };

defs.dps116_gps_gpgga = {  % from dps116_gps-jc.json
    'dps116_gps_gpgga' 14  % fields
    'utcTime'                             ''
    'latitude' 'degrees, minutes and decimal minutes'
    'latDir'                             ''
    'longitude' 'degrees, minutes and decimal minutes'
    'lonDir'                             ''
    'ggaQual'                             ''
    'numSat'                             ''
    'hdop'                             ''
    'altitude'                       'metres'
    %     'unitsOfMeasureAntenna'                             ''
    %     'geoidAltitude'                       'metres'
    %     'unitsOfMeasureGeoid'                             ''
    %     'diffcAge'                      'seconds'
    %     'dgnssRefId'                             ''
    };

defs.em120_depth_kidpt = {  % from em120_depth-jc.json
    'em120_depth_kidpt'  3  % fields
    'waterDepthMeter'                       'metres'
    %     'transduceroffset'                       'metres'
    %     'maxRange'                       'metres'
    };

defs.em600_depth_sddbs = {  % from em600_depth-jc.json
    'em600_depth_sddbs'  6  % fields
    %     'waterDepthFeetFromSurface'                        'feets'
    %     'feetFlag'                             ''
    'waterDepthMeterFromSurface'                       'metres'
    %     'meterFlag'                             ''
    %     'waterDepthFathomFromSurface'                       'fathom'
    %     'fathomFlag'                             ''
    };

defs.env_temp_wimta = {  % from env_temp-jc.json
    'env_temp_wimta'  2  % fields
    'airTemperature'               'degressCelsius'
    %     'celsiusFlag'                             ''
    };

defs.env_temp_wimhu = {  % from env_temp-jc.json
    'env_temp_wimhu'  4  % fields
    'humidity'                   'percentage'
    %     'flag'                             ''
    'temperatureDewPoint'               'degreesCelsius'
    %     'celsiusFlag'                             ''
    };


defs.ranger2_usbl_gpgga = {  % from RANGER2_USBL-jc.json
    'ranger2_usbl_gpgga' 14  % fields
    'utcTime'                             ''
    'latitude' 'degrees, minutes and decimal minutes'
    'latDir'                             ''
    'longitude' 'degrees, minutes and decimal minutes'
    'lonDir'                             ''
    'ggaQual'                             ''
    'numSat'                             ''
    'hdop'                             ''
    'altitude'                       'metres'
    %     'unitsOfMeasureAntenna'                             ''
    %     'geoidAltitude'                       'metres'
    %     'unitsOfMeasureGeoid'                             ''
    %     'diffcAge'                      'seconds'
    %     'dgnssRefId'                             ''
    };


defs.sbe45_tsg_nanan = {  % from sbe45_tsg-jc.json
    'sbe45_tsg_nanan'  5  % fields
    'housingWaterTemperature'               'DegreesCelsius'
    'conductivity'                          'S/m'
    'salinity'                          'PSU'
    'soundVelocity'                          'm/s'
    'remoteWaterTemperature'               'DegreesCelsius'
    };

defs.seapath_pos_ingga = {  % from seapath_pos-jc.json
    'seapath_pos_ingga' 14  % fields
    'utcTime'                             ''
    'latitude' 'degrees, minutes and decimal minutes'
    'latDir'                             ''
    'longitude' 'degrees, minutes and decimal minutes'
    'lonDir'                             ''
    'ggaQual'                             ''
    'numSat'                             ''
    'hdop'                             ''
    'altitude'                       'metres'
    %     'unitsOfMeasureAntenna'                             ''
    %     'geoidAltitude'                       'metres'
    %     'unitsOfMeasureGeoid'                             ''
    %     'diffcAge'                      'seconds'
    %     'dgnssRefId'                             ''
    };

defs.seapath_pos_ingsa = {  % from seapath_pos-jc.json
    'seapath_pos_ingsa' 17  % fields
    %     'gsaMode'                             ''
    %     'gsaStatus'                             ''
    %     'sId1'                             ''
    %     'sId2'                             ''
    %     'sId3'                             ''
    %     'sId4'                             ''
    %     'sId5'                             ''
    %     'sId6'                             ''
    %     'sId7'                             ''
    %     'sId8'                             ''
    %     'sId9'                             ''
    %     'sId10'                             ''
    %     'sId11'                             ''
    %     'sId12'                             ''
    'pdop'                             ''
    'hdop'                             ''
    'vdop'                             ''
    };

defs.seapath_pos_invtg = {  % from seapath_pos-jc.json
    'seapath_pos_invtg'  9  % fields
    'courseOverGround'                      'degrees'
    %     'trueCourse'                             ''
    %     'magneticTrack'                      'degrees'
    %     'mFlag'                             ''
    'speedKnots'                        'knots'
    %     'nFlag'                             ''
    %     'speedKmph'                         'km/h'
    %     'kFlag'                             ''
    %     'positioningMode'                             ''
    };

defs.seapath_att_psxn23 = {  % from seapath_att-jc.json
    'seapath_att_psxn23'  4  % fields
    'roll'                      'degrees'
    'pitch'                      'degrees'
    'heading'                      'degrees'
    'heave'                       'metres'
    };

defs.ships_chernikeef_vmvbw = {  % from ships_chernikeef-jc.json
    'ships_chernikeef_vmvbw' 10  % fields
    'longitudalWaterSpeed'                        'Knots'
    'transverseWaterSpeed'                        'Knots'
    %     'status1'                             ''
    %     'longitudalGroundSpeed'                        'Knots'
    %     'transverseGroundSpeed'                        'Knots'
    %     'status2'                             ''
    %     'vbw7'                        'Knots'
    %     'status3'                             ''
    %     'vbw10'                        'Knots'
    %     'status4'                             ''
    };

defs.ships_skipperlog_vdvbw = {  % from ship_skipperlog-jc.json
    'ships_skipperlog_vdvbw' 10  % fields
    'longitudalWaterSpeed'                        'Knots'
    'transverseWaterSpeed'                        'Knots'
    %     'status1'                             ''
    %     'longitudalGroundSpeed'                        'Knots'
    %     'transverseGroundSpeed'                        'Knots'
    %     'status2'                             ''
    %     'vbw7'                        'Knots'
    %     'status3'                             ''
    %     'vbw8'                             ''
    %     'status4'                             ''
    };


defs.u12_at1m_uw = {  % from u12_at1m.json
    'u12_at1m_uw' 18  % fields
    'gravity'                         'mGal'
    'long'                         'Gals'
    'crossa'                         'Gals'
    'beam'                         'Gals'
    'temp'               'degreesCelsius'
    'pressure'                       'inchHg'
    'elecTemp'               'degreesCelsius'
    'vcc'                         'mGal'
    've'                         'mGal'
    'al'                         'mGal'
    'ax'                         'mGal'
    'status'                             ''
    'checksum'                             ''
    'latitude'               'DecimalDegrees'
    'longitude'               'decimalDegrees'
    'speed'                        'knots'
    'course'                      'Degrees'
    'timestamp'                             ''
    };

defs.seaspy_mag_inmag = {  % from seaspy_mag-jc.json
    'seaspy_mag_inmag'  9  % fields
    'juliendatetime'                             ''
    'magneticfield'                    'nanotesla'
    'signalstrength'                             ''
    'depth'                        'meter'
    'altitude'                        'meter'
    'leak'                             ''
    'measurementtime'                  'millisecond'
    'signalquality'                             ''
    'warningmessages'                             ''
    };
