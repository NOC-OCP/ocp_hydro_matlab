function [rtables,rtables_list] = mrtables_from_json
% function [rtables rtables_list]= mrtables_from_json
%
% *************************************************************************
% mexec interface for RVDAS data acquisition
% First drafts of scripts for start jc211 28 jan 2021, alongside in Stanley
% 
% Evolution on that cruise by bak, ylf, pa
% *************************************************************************
%
% Make the list of rvdas tables that mexec may want to copy.
%
% json files from NMF were parsed on BAK mac because the relevant json
% decoder was not available in matlab 2015 on koaeula.
%
% Each json file was converted to a matlab structure and saved.
% There are around 70 possible rvdas tables, and we are only interested in some
% of those tables, and only interested in some of the variables in each table.
%
% The rtables created in this script will define which varaibles are loaded
% when a table is loaded from rvdas. At the time of writing, units are not
% stored in rvdas, so they have been collected from the matlab version of
% the json files.
%
% The content of this file was obtained by using the script
%     show_json_all.m, which calls show_jason.m in the directory
%     /local/users/pstar/jc211/mcruise/data/rvdas_data/dev
%     That command went through all .mat versions of the .json files,
%     and printed them in the format seen below. That text was cut and
%     pasted here, so that variables not required could be commented out
%     and tables not required could be omitted.
%
%
% Examples
%
%   [rtables rtables_list]= mrtables_from_json
%
% Input:
%
%   None
%
% Output:
%
% rtables is a structure. Each field is a cell array. The name of the
%   is the rvdas table name. The content of each field is an Nx2 cell array.
%   Element {1,1} is the rvdas table name. The remaining rows are the 
%   variable names and units we are interested in. Variables we do not wish
%   to grab from rvdas are commented out.
%
% rtables_list is a cell array and is a list of the tables we have
%   identified. So rtables_list = fieldnames(rtables).


clear rtables rtables_list

rtables.ships_gyro_hehdt = {  % from ships_gyro-jc.mat.json
    'ships_gyro_hehdt'  2  % fields
    'headingTrue'                      'degrees'
    %     'trueHeading'                             ''
    };

rtables.nmf_winch_winch = {  % from nmf_winch-jc.json
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


rtables.posmv_gyro_gphdt = {  % from posmv_gyro-jc.json
    'posmv_gyro_gphdt'  2  % fields
    'headingTrue'                      'degrees'
    %     'trueHeading'                             ''
    };



rtables.posmv_att_pashr = {  % from posmv_att-jc.json
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

rtables.posmv_pos_gpgga = {  % from posmv_pos-jc.json
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



rtables.posmv_pos_gpvtg = {  % from posmv_pos-jc.json
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

rtables.nmf_surfmet_gpxsm = {  % from nmf_surfmet-jc.mat.json
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






rtables.windsonic_nmea_iimwv = {  % from windsonic_nmea.mat.json
    'windsonic_nmea_iimwv'  5  % fields
    'windDirection'                      'degrees'
    %     'relWindmes'                             ''
    'windSpeed'                          'm/s'
    %     'Units'                             ''
    %     'status'                             ''
    };


rtables.cnav_gps_gngga = {  % from cnav_gps-jc.json
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


rtables.cnav_gps_gnvtg = {  % from cnav_gps-jc.json
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

rtables.cnav_gps_gngsa = {  % from cnav_gps-jc.json
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

rtables.dps116_gps_gpgga = {  % from dps116_gps-jc.json
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

rtables.em120_depth_kidpt = {  % from em120_depth-jc.json
    'em120_depth_kidpt'  3  % fields
    'waterDepthMeter'                       'metres'
    %     'transduceroffset'                       'metres'
    %     'maxRange'                       'metres'
    };

rtables.em600_depth_sddbs = {  % from em600_depth-jc.json
    'em600_depth_sddbs'  6  % fields
    %     'waterDepthFeetFromSurface'                        'feets'
    %     'feetFlag'                             ''
    'waterDepthMeterFromSurface'                       'metres'
    %     'meterFlag'                             ''
    %     'waterDepthFathomFromSurface'                       'fathom'
    %     'fathomFlag'                             ''
    };

rtables.env_temp_wimta = {  % from env_temp-jc.json
    'env_temp_wimta'  2  % fields
    'airTemperature'               'degressCelsius'
    %     'celsiusFlag'                             ''
    };

rtables.env_temp_wimhu = {  % from env_temp-jc.json
    'env_temp_wimhu'  4  % fields
    'humidity'                   'percentage'
    %     'flag'                             ''
    'temperatureDewPoint'               'degreesCelsius'
    %     'celsiusFlag'                             ''
    };


rtables.ranger2_usbl_gpgga = {  % from RANGER2_USBL-jc.json
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


rtables.sbe45_tsg_nanan = {  % from sbe45_tsg-jc.json
    'sbe45_tsg_nanan'  5  % fields
    'housingWaterTemperature'               'DegreesCelsius'
    'conductivity'                          'S/m'
    'salinity'                          'PSU'
    'soundVelocity'                          'm/s'
    'remoteWaterTemperature'               'DegreesCelsius'
    };

rtables.seapath_pos_inhdt = {  % from seapath_pos.json
    'seapath_pos_inhdt'  2  % fields
    'headingTrue'                      'degrees'
    %     'trueHeading'                             ''
    };

rtables.seapath_pos_ingga = {  % from seapath_pos-jc.json
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

rtables.seapath_pos_ingsa = {  % from seapath_pos-jc.json
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

rtables.seapath_pos_invtg = {  % from seapath_pos-jc.json
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

rtables.seapath_att_psxn23 = {  % from seapath_att-jc.json
    'seapath_att_psxn23'  4  % fields
    'roll'                      'degrees'
    'pitch'                      'degrees'
    'heading'                      'degrees'
    'heave'                       'metres'
    };

rtables.ships_chernikeef_vmvbw = {  % from ships_chernikeef-jc.json
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

rtables.ships_skipperlog_vdvbw = {  % from ship_skipperlog-jc.json
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


rtables.u12_at1m_uw = {  % from u12_at1m.json
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

% % rtables.seaspy_mag_inmag = {  % from seaspy_mag-jc.json   % JC211 - there is a json file for this, but it is not present in RVDAS list of tables
% %     'seaspy_mag_inmag'  9  % fields
% %     'juliendatetime'                             ''
% %     'magneticfield'                    'nanotesla'
% %     'signalstrength'                             ''
% %     'depth'                        'meter'
% %     'altitude'                        'meter'
% %     'leak'                             ''
% %     'measurementtime'                  'millisecond'
% %     'signalquality'                             ''
% %     'warningmessages'                             ''
% %     };

rtables_list = fieldnames(rtables);