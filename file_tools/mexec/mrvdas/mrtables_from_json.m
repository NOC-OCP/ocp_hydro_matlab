function rtables = mrtables_from_json
% function rtables = mrtables_from_json
% Make the list of rvdas tables that mexec may want to copy.
% The rtables created in this script will define which variables are loaded
% when a table is loaded from rvdas. Units are collected from the json files
% The content of this file was obtained by using the script mrjson_load_all.m
% Variables and/or tables can subsequently be commented out
%
% Examples
%
%   rtables= mrtables_from_json; %list of tables to use
%   [rtables, ctables] = mrtables_from_json; %list of tables to use, and list of commented-out tables
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
%   to grab from rvdas are commented out and may be listed by supplying the
%   optional second output argument ctables.
 


%cnav-jc-2022-01-01T000000Z-null  9  sentences

%"GNGGA"
rtables.cnav_gngga = {  % from cnav-jc-2022-01-01T000000Z-null.json
'cnav_gngga' 14 []  % fields
                     'UTCTime'                             ''                                                                       'UTC_Time'
                    'latitude'  'degrees and decimal minutes'                                         'Latitude_(degrees_and_decimal_minutes)'
                      'latdir'                             ''                                                       'Latitude_Direction_(N|S)'
                   'longitude'  'degrees and decimal minutes'                                        'Longitude_(degrees_and_decimal_minutes)'
                      'londir'                             ''                                                      'Longitude_Direction_(E|W)'
%                    'ggaQual'                             ''                                                         'GNSS_Quality_Indicator'
%                     'numsat'                             ''                                      'Number_of_Satellites_used_in_GPS_Solution'
%                       'hdop'                             ''                                               'Horizontal_Dilution_of_Precision'
                    'altitude'                       'metres'                                          'Antenna_altitude_above_mean_sea_level'
%            'unitsOfAltitude'                             ''                                                      'Units_of_Antenna_Altitude'
%              'geoidAltitude'                       'metres'                                                               'Geoid_Separation'
%        'unitOfGeoidAltitude'                             ''                                                       'Unit_of_Geoid_Separation'
%                   'diffcAge'                             ''                      'Time_since_last_differential_correction_update_in_seconds'
%                 'dgnssRefid'                             ''                                                      'ID_Number_of_DGPS_station'
};

%"GNVTG"
rtables.cnav_gnvtg = {  % from cnav-jc-2022-01-01T000000Z-null.json
'cnav_gnvtg'  9 []  % fields
                         'cog'                      'degrees'                                                        'Course_Over_Ground_True'
%                     'desCog'                             ''                                            'Course_Over_Ground_True_Designation'
                        'cogm'                      'degrees'                                                    'Course_Over_Ground_Magnetic'
%                    'desCogm'                             ''                                        'Course_Over_Ground_Magnetic_Designation'
                         'sog'                        'knots'                                                     'Speed_Over_Ground_in_Knots'
%                     'desSog'                             ''                                         'Speed_Over_Ground_in_Knots_Designation'
                     'sogkmph'          'Kilometre per hours'                                       'Speed_Over_Ground_in_Kilometre_per_Hours'
%                 'desSogKmph'                             ''                           'Speed_Over_Ground_in_Kilometre_per_Hours_Designation'
%            'positioningMode'                             ''                                               'FAA_Mode_Indicator_(A|D|E|S|N|P)'
};

%"GNGSA"
rtables.cnav_gngsa = {  % from cnav-jc-2022-01-01T000000Z-null.json
'cnav_gngsa' 18 []  % fields
                     'gsaMode'                             ''                                        'Automatic_or_Manual_Solution_Mode_(M|A)'
%                  'gsaStatus'                             ''                                       'Solution_(fix_not_available=1|2D=2|3D=3)'
                        'sId1'                             ''                                                 'PRN_of_satellites_used_for_fix'
                        'sId2'                             ''                                                 'PRN_of_satellites_used_for_fix'
                        'sId3'                             ''                                                 'PRN_of_satellites_used_for_fix'
                        'sId4'                             ''                                                 'PRN_of_satellites_used_for_fix'
                        'sId5'                             ''                                                 'PRN_of_satellites_used_for_fix'
                        'sId6'                             ''                                                 'PRN_of_satellites_used_for_fix'
                        'sId7'                             ''                                                 'PRN_of_satellites_used_for_fix'
                       'sId10'                             ''                                                 'PRN_of_satellites_used_for_fix'
                        'sId8'                             ''                                                 'PRN_of_satellites_used_for_fix'
                        'sId9'                             ''                                                 'PRN_of_satellites_used_for_fix'
                       'sId11'                             ''                                                 'PRN_of_satellites_used_for_fix'
                       'sId12'                             ''                                                 'PRN_of_satellites_used_for_fix'
                        'pdop'                             ''                                                           'Dilution_of_position'
%                       'hdop'                             ''                                               'Horizontal_Dilution_of_Precision'
                        'vdop'                             ''                                                  'Vertical_dilution_of_position'
                        'gsId'                             ''                                           'GNSS_System_ID_(1_GPS;_2_DGPS;_3_3D)'
};


%ea640-jc-2022-02-04T064000Z-null  2  sentences

rtables.ea640_sddpt = {  % from ea640-jc-2022-02-04T064000Z-null.json
'ea640_sddpt'  2 []  % fields
                       'depth'                       'metres'                                            'Depth_in_meters_from_the_transducer'
            'transducerOffset'                             '' 'Positive_means_distance_from_transducer_to_waterline_Negative_means_distance_from_transducer_to_keel_in_meter'
};


%"SDDBS"
rtables.ea640_sddbs = {  % from ea640-jc-2022-02-04T064000Z-null.json
'ea640_sddbs'  6 []  % fields
%                   'depthFeet'                         'Feet'                                                'Depth_in_feets_from_the_surface'
%                   'flagFeet'                             ''                                                               'feet_designation'
                  'depthMeter'                       'metres'                                               'Depth_in_metres_from_the_surface'
%                  'flagMeter'                             ''                                                              'Meter_designation'
%                  'deptFathom'                       'fathom'                                               'Depth_in_Fathom_from_the_surface'
%                 'flagFathom'                             ''                                                             'Fathom_designation'
};

%em122-jc-2022-02-01T150300Z-null  1  sentences

%"KIDPT"
rtables.em122_kidpt = {  % from em122-jc-2022-02-01T150300Z-null.json
'em122_kidpt'  3 []  % fields
             'waterDepthMeter'                             ''                                'Depth_in_meters_from_the_transducer_centre_beam'
            'transducerOffset'                             ''                                  'Offset_of_transducer_from_waterline_in_meters'
%                   'maxRange'                             ''                                                     'Maximum_range_scale_in_use'
};


%envtemp-jc-2022-02-01T174900Z-null  2  sentences

%"WIMTA"
rtables.envtemp_wimta = {  % from envtemp-jc-2022-02-01T174900Z-null.json
'envtemp_wimta'  2 []  % fields
              'airTemperature'               'degreesCelsius'                                                     'Air_Temperature_from_probe'
%                'celsiusFlag'                             ''                                                       'Units_of_Air_Temperature'
};

%"WIMHU"
rtables.envtemp_wimhu = {  % from envtemp-jc-2022-02-01T174900Z-null.json
'envtemp_wimhu'  4 []  % fields
                    'humidity'                   'percentage'                                                   'Relative_humidity_from_probe'
%               'FlagHumidity'                             ''                                                   'Humidity_Flag_(mostly_empty)'
         'temperatureDewPoint'               'degreesCelsius'                                               'Dew_Point_Temperature_from_Probe'
%                'flagCelsius'                             ''                                                       'Units_of_Air_Temperature'
};


%posmv-jc-2022-02-03T184700Z-null  8  sentences

%"GPGGK"
rtables.posmv_gpggk = {  % from posmv-jc-2022-02-03T184700Z-null.json
'posmv_gpggk' 11 []  % fields
                     'UTCTime'                             ''                                                                       'UTC_Time'
%                    'UTCDate'                             ''                                                                       'UTC_Date'
                    'latitude'  'degrees and decimal minutes'                                                                       'Latitude'
                      'latdir'                             ''                                                       'Latitude_Direction_(N,S)'
                   'longitude'  'degrees and decimal minutes'                                                                      'Longitude'
                      'londir'                             ''                                                      'Longitude_Direction_(E|W)'
%                    'ggaQual'                             ''                                                          'GPS_Quality_Indicator'
%                     'numsat'                             ''                                      'Number_of_Satellites_used_in_GPS_Solution'
                        'pdop'                             ''                                                   'Dilution_of_Precision_of_Fix'
                         'eht'                             ''                   'Elipsoid_height_of_fix_(vessel_height_above_WGS84_ellipsoid)'
%                    'ethUnit'                             ''                                                                    'Unit_of_eth'
};

%"GPHDT"
rtables.posmv_gphdt = {  % from posmv-jc-2022-02-03T184700Z-null.json
'posmv_gphdt'  2 []  % fields
                     'heading'                      'degrees'                                                                   'Heading_True'
%                 'desHeading'                             ''              'Static_text_designating_the_heading_is_in_reference_to_true_North'
};

%"GPVTG"
rtables.posmv_gpvtg = {  % from posmv-jc-2022-02-03T184700Z-null.json
'posmv_gpvtg'  9 []  % fields
                         'cog'                      'degrees'                                                        'Course_Over_Ground_True'
%                     'desCog'                             ''                                            'Course_Over_Ground_True_Designation'
                        'cogm'                      'degrees'                                                    'Course_Over_Ground_Magnetic'
%                    'desCogm'                             ''                                        'Course_Over_Ground_Magnetic_Designation'
                         'sog'                        'knots'                                                     'Speed_Over_Ground_in_Knots'
%                     'desSog'                             ''                                         'Speed_Over_Ground_in_Knots_Designation'
                     'sogkmph'          'Kilometre per hours'                                       'Speed_Over_Ground_in_Kilometre_per_Hours'
%                 'desSogKmph'                             ''                           'Speed_Over_Ground_in_Kilometre_per_Hours_Designation'
%            'positioningMode'                             ''                                                             'FAA_Mode_Indicator'
};

%"PASHR"
rtables.posmv_pashr = {  % from posmv-jc-2022-02-03T184700Z-null.json
'posmv_pashr' 11 []  % fields
                     'UTCTime'                             ''                                                                       'UTC_Time'
                     'heading'                      'degrees'                                                        'True_Heading_in_degrees'
%                 'desHeading'                             ''              'Static_text_designating_the_heading_is_in_reference_to_true_North'
                        'roll'                      'degrees'                                     'Roll_about_the_longitudinal_axis_X_degrees'
                       'pitch'                      'degrees'                                         'Pitch_about_the_lateral_axis_Y_degrees'
                       'heave'                       'metres'                                         'Heave_along_the_vertical_axis_Z_meters'
                'rollAccuracy'                             ''                                                       'Accuracy_of_Roll_degrees'
               'pitchAccuracy'                             ''                                                      'Accuracy_of_Pitch_degrees'
              'headingAcuracy'                             ''                                                    'Accuracy_of_Heading_degrees'
%        'headingAccuracyFlag'                             ''     'Accuracy_Heading_Flag_0_=_no_aiding_1_=_GNSS_aiding_2_=_GNSS_&_GAMS_aiding'
%                    'imuFlag'                             ''                                          'IMU_Flag_0_=_IMU_out_1_–_Satisfactory'
};


%sbe38dropkeel-jc-2022-02-04T133000Z-null  1  sentences

%"SBE38"
rtables.sbe38dropkeel_sbe38 = {  % from sbe38dropkeel-jc-2022-02-04T133000Z-null.json
'sbe38dropkeel_sbe38'  1 []  % fields
                       'tempr'                         'degC'                                         'SBE38_dropkeel_sensor_watertemperature'
};


%sbe45-jc-2022-01-01T000000Z-null  1  sentences

%"NANaN"
rtables.sbe45_nanan = {  % from sbe45-jc-2022-01-01T000000Z-null.json
'sbe45_nanan'  5 []  % fields
                       'temph'                         'degC'                                            'Surface_water_temp_at_SBE45_housing'
                'conductivity'                             ''                                               'Surface_Water_Conductivity_(S/m)'
                    'salinity'                             ''                                                     'sea_surface_salinity_(PSU)'
               'soundVelocity'             'meter per second'                                               'Sea_Surface_Sound_Velocity_(m/s)'
                       'tempr'                         'degC'                                 'Remote_sea_water_temperature_from_SBE38_sensor'
};


%seapathatt-jc-2022-02-03T184800Z-null  3  sentences

%"PSXN23"
rtables.seapathatt_psxn23 = {  % from seapathatt-jc-2022-02-03T184800Z-null.json
'seapathatt_psxn23'  4 []  % fields
                        'roll'                      'degrees'                                     'Roll_about_the_longitudinal_axis_X_degrees'
                       'pitch'                      'degrees'                                         'Pitch_about_the_lateral_axis_Y_degrees'
                     'heading'                      'degrees'                                                         'Sensor_Heading_degrees'
                       'heave'                       'metres'                                         'Heave_along_the_vertical_axis_Z_meters'
};


%seapathgps-jc-2022-02-03T184800Z-null 10  sentences

%"INGGA"
rtables.seapathgps_ingga = {  % from seapathgps-jc-2022-02-03T184800Z-null.json
'seapathgps_ingga' 14 []  % fields
                     'UTCTime'                             ''                                                                       'UTC_Time'
                    'latitude'  'degrees and decimal minutes'                                         'Latitude_(degrees_and_decimal_minutes)'
                      'latdir'                             ''                                                       'Latitude_Direction_(N|S)'
                   'longitude'  'degrees and decimal minutes'                                        'Longitude_(degrees_and_decimal_minutes)'
                      'londir'                             ''                                                      'Longitude_Direction_(E|W)'
%                    'ggaQual'                             ''                                                         'GNSS_Quality_Indicator'
%                     'numsat'                             ''                                               'Number_of_satellites_used_in_fix'
%                       'hdop'                             ''                                               'Horizontal_Dilution_of_Precision'
                    'altitude'                       'metres'                                               'Height_above_sea-level_in_meters'
%            'unitsOfAltitude'                             ''                                                      'Units_of_Antenna_Altitude'
%              'geoidAltitude'                       'metres'                                                               'Geoid_Separation'
%        'unitOfGeoidAltitude'                             ''                                                       'Unit_of_Geoid_Separation'
%                   'diffcAge'                             ''                                         'Time_since_last_DGPS_update_in_seconds'
%                 'dgnssRefid'                             ''                                                      'ID_Number_of_DGPS_station'
};

%"INHDT"
rtables.seapathgps_inhdt = {  % from seapathgps-jc-2022-02-03T184800Z-null.json
'seapathgps_inhdt'  2 []  % fields
                     'heading'                      'degrees'                                                       'Heading_in_degrees,_true'
%                 'desHeading'                             ''              'Static_text_designating_the_heading_is_in_reference_to_true_North'
};

%"INVTG"
rtables.seapathgps_invtg = {  % from seapathgps-jc-2022-02-03T184800Z-null.json
'seapathgps_invtg'  9 []  % fields
                         'cog'                      'degrees'                                         'Course_over_ground_&_Ground_speed_data'
%                     'desCog'                             ''              'Static_text_designating_the_heading_is_in_reference_to_true_North'
                        'cogm'                      'degrees'                                                    'Course_Over_Ground_Magnetic'
%                    'desCogm'                             ''                                        'Course_Over_Ground_Magnetic_Designation'
                         'sog'                        'knots'                                                     'Speed_Over_Ground_in_Knots'
%                     'desSog'                             ''                                  'Static_text_designating_the_speed_is_in_knots'
                     'sogkmph'          'Kilometre per hours'                                                         'Speed_over_ground_km/h'
%                 'desSogKmph'                             ''                           'Speed_Over_Ground_in_Kilometre_per_Hours_Designation'
%            'positioningMode'                             ''                                               'FAA_Mode_Indicator_(A|D|E|M|S|N)'
};

%"GNGSA"
rtables.seapathgps_gngsa = {  % from seapathgps-jc-2022-02-03T184800Z-null.json
'seapathgps_gngsa' 17 []  % fields
                      'saMode'                             ''                                                     'Satellite_acquisition_mode'
                       'PMode'                             ''                                                                  'Position_Mode'
                        'sat1'                             ''                                        'Satellite_used_in_the_position_solution'
                        'sat2'                             ''                                        'Satellite_used_in_the_position_solution'
                        'sat3'                             ''                                        'Satellite_used_in_the_position_solution'
                        'sat4'                             ''                                        'Satellite_used_in_the_position_solution'
                        'sat5'                             ''                                        'Satellite_used_in_the_position_solution'
                        'sat6'                             ''                                        'Satellite_used_in_the_position_solution'
                        'sat7'                             ''                                        'Satellite_used_in_the_position_solution'
                        'sat8'                             ''                                        'Satellite_used_in_the_position_solution'
                        'sat9'                             ''                                        'Satellite_used_in_the_position_solution'
                       'sat10'                             ''                                        'Satellite_used_in_the_position_solution'
                       'sat11'                             ''                                        'Satellite_used_in_the_position_solution'
                        'pdop'                             ''                                          'Position_Dilution_of_Precision_(PDOP)'
%                       'hdop'                             ''                                        'Horizontal_Dilution_of_Precision_(HDOP)'
                        'vdop'                             ''                                          'Vertical_Dilution_of_Precision_(VDOP)'
                       'sat12'                             ''                                        'Satellite_used_in_the_position_solution'
};


%sgyro-jc-2022-02-04T070000Z-null  4  sentences

%"HEHDT"
rtables.sgyro_hehdt = {  % from sgyro-jc-2022-02-04T070000Z-null.json
'sgyro_hehdt'  2 []  % fields
                     'heading'                      'degrees'                                                'True_Heading_in_degrees_(0-360)'
%                 'desHeading'                             ''                                                       'Heading_True_designation'
};

%"TIROT"
rtables.sgyro_tirot = {  % from sgyro-jc-2022-02-04T070000Z-null.json
'sgyro_tirot'  2 []  % fields
                         'rot'                             ''                    'Rate_of_Turn,_degrees_per_minute_negative_means_bow_to_port'
%                  'rotStatus'                             ''                                                          'Status;_A_means_valid'
};


%surfmet-jc-2022-01-01T000000Z-null  1  sentences

%"GPXSM"
rtables.surfmet_gpxsm = {  % from surfmet-jc-2022-01-01T000000Z-null.json
'surfmet_gpxsm' 12 []  % fields
                        'flow'                          'l/m'                                     'Surface_Water_Instrument_flow_rate_(l/min)'
                        'fluo'                             ''                                                     'Surface_water_fluorescence'
                       'trans'                            'V'                                                   'Surface_water_transmissivity'
                   'windSpeed'             'meter per second'                                                    'Surface_wind_relative_speed'
               'windDirection'                      'degrees'                                                'Surface_wind_relative_direction'
              'airTemperature'               'degreesCelsius'                                                        'Surface_air_temperature'
                    'humidity'                             ''                                                       'Surface_air_humidity_(%)'
                 'airPressure'                          'hPa'                                                           'Surface_air_pressure'
                     'parPort'                          'cmV'                                                      'port_side_PAR_sensor_data'
                'parStarboard'                          'cmV'                                                      'starboard_side_PAR_sensor'
                     'tirPort'                          'cmV'                                                           'port_side_TIR_sensor'
                'tirStarboard'                          'cmV'                                                      'starboard_side_TIR_sensor'
};


%winchlog-jc-2022-02-04T084800Z-null  1  sentences

%"WINCH"
rtables.winchlog_winch = {  % from winchlog-jc-2022-02-04T084800Z-null.json
'winchlog_winch'  8 []  % fields
%                 'winchDatum'                             ''                                                      'Date/Time_YY_JJJ_HH:MM:SS'
                   'cableType'                             '' 'Cable_Type_0_=_No_Winch_Selected_1_=_CTD1_2_=_CTD2_3_=_Deep_Core_4_=_Trawl_5_=_Deep_Tow_6_=_Plasma_7_=_External_Winch'
                     'tension'                        'tonne'                                                              'Cable_Tension_(T)'
                    'cableOut'                             ''                                                                  'Cable_Out_(m)'
                        'rate'                             ''                                                             'Cable_Rate_(m/min)'
                 'backTension'                        'tonne'                                                               'Back_Tension_(T)'
                   'rollAngle'                             ''                                                'Heal_Angle_(degrees)_not_logged'
%                  'undefined'                             ''       'undefined_field_because_of_the_suffix_comma_in_the_message_(set_to_1.11)'
};


%windsonicnmea-jc-2022-01-01T120000Z-null  1  sentences

%"IIMWV"
rtables.windsonicnmea_iimwv = {  % from windsonicnmea-jc-2022-01-01T120000Z-null.json
'windsonicnmea_iimwv'  5 []  % fields
               'windDirection'                      'degrees'                                                'Surface_wind_relative_direction'
%                 'relWindDes'                             ''                                        'Relative_wind_Message_Designation_(R|T)'
                   'windSpeed'             'meter per second'                                              'Surface_wind_relative_speed_(m/s)'
%                  'speedUnit'                             ''                                                   'Unit_of_wind_Speed_(M_=_m/s)'
%                     'status'                             ''                                                                 'Status_A=valid'
};
