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
 


%anemometer_ft_technologies_ft702lt  1  sentences

%"WIMWV – Wind Speed and Angle"
rtables.anemometer_ft_technologies_ft702lt_wimwv = {  % from anemometer_ft_technologies_ft702lt.json
'anemometer_ft_technologies_ft702lt_wimwv'  5 []  % fields
               'windDirection'                      'degrees'                                                                 'Wind_Direction'
           'windDirectionType'                             ''                                                            'Wind_Direction_Type'
                   'windSpeed'                          'm/s'                                                                     'Wind_Speed'
%             'windSpeedUnits'                             ''                                                               'Wind_Speed_Units'
%                 'windStatus'                             ''                                                                    'Wind_Status'
};


%anemometer_metek_usonic3_1  1  sentences

%"PMWIND – bespoke output from the Metek uSonic-3 anemometer "
rtables.anemometer_metek_usonic3_1_pmwind = {  % from anemometer_metek_usonic3_1.json
'anemometer_metek_usonic3_1_pmwind'  6 []  % fields
              'dataOutputType'                             ''                                                               'Data_Output_Type'
                  'xComponent'                         'cm/s'                                                            'X_Component_of_Wind'
                  'yComponent'                         'cm/s'                                                            'Y_Component_of_Wind'
                  'zComponent'                         'cm/s'                                                            'Z_Component_of_Wind'
                'acousticTemp'           'hundreth degrees c'                                                           'Acoustic_Temperature'
                 'dataQuality'                   'percentage'                                                                   'Data_Quality'
};


%anemometer_metek_usonic3_2  1  sentences

%"PMWIND – bespoke output from the Metek uSonic-3 anemometer "
rtables.anemometer_metek_usonic3_2_pmwind = {  % from anemometer_metek_usonic3_2.json
'anemometer_metek_usonic3_2_pmwind'  6 []  % fields
              'dataOutputType'                             ''                                                               'Data_Output_Type'
                  'xComponent'                         'cm/s'                                                            'X_Component_of_Wind'
                  'yComponent'                         'cm/s'                                                            'Y_Component_of_Wind'
                  'zComponent'                         'cm/s'                                                            'Z_Component_of_Wind'
                'acousticTemp'           'hundreth degrees c'                                                           'Acoustic_Temperature'
                 'dataQuality'                   'percentage'                                                                   'Data_Quality'
};


%anemometer_metek_usonic3_3  1  sentences

%"PMWIND – bespoke output from the Metek uSonic-3 anemometer "
rtables.anemometer_metek_usonic3_3_pmwind = {  % from anemometer_metek_usonic3_3.json
'anemometer_metek_usonic3_3_pmwind'  6 []  % fields
              'dataOutputType'                             ''                                                               'Data_Output_Type'
                  'xComponent'                         'cm/s'                                                            'X_Component_of_Wind'
                  'yComponent'                         'cm/s'                                                            'Y_Component_of_Wind'
                  'zComponent'                         'cm/s'                                                            'Z_Component_of_Wind'
                'acousticTemp'           'hundreth degrees c'                                                           'Acoustic_Temperature'
                 'dataQuality'                   'percentage'                                                                   'Data_Quality'
};


%anemometer_observator_omc116_1  1  sentences

%"WIMWV – Wind Speed and Angle"
rtables.anemometer_observator_omc116_1_wimwv = {  % from anemometer_observator_omc116_1.json
'anemometer_observator_omc116_1_wimwv'  5 []  % fields
               'windDirection'                      'degrees'                                                                 'Wind_Direction'
           'windDirectionType'                             ''                                                            'Wind_Direction_Type'
                   'windSpeed'                          'm/s'                                                                     'Wind_Speed'
%             'windSpeedUnits'                             ''                                                               'Wind_Speed_Units'
%                 'windStatus'                             ''                                                                    'Wind_Status'
};


%anemometer_observator_omc116_2  1  sentences

%"WIMWV – Wind Speed and Angle"
rtables.anemometer_observator_omc116_2_wimwv = {  % from anemometer_observator_omc116_2.json
'anemometer_observator_omc116_2_wimwv'  5 []  % fields
               'windDirection'                      'degrees'                                                                 'Wind_Direction'
           'windDirectionType'                             ''                                                            'Wind_Direction_Type'
                   'windSpeed'                          'm/s'                                                                     'Wind_Speed'
%             'windSpeedUnits'                             ''                                                               'Wind_Speed_Units'
%                 'windStatus'                             ''                                                                    'Wind_Status'
};


%attitude_ixblue_phins_surface_heading  1  sentences

%"HEHDT – Heading – True Data"
rtables.attitude_ixblue_phins_surface_heading_hehdt = {  % from attitude_ixblue_phins_surface_heading.json
'attitude_ixblue_phins_surface_heading_hehdt'  2 []  % fields
                 'headingTrue'                      'degrees'                                                                   'Heading_True'
%                'trueHeading'                             ''                                                               'True_Designation'
};


%attitude_ixblue_phins_surface_motion  1  sentences

%"KMATT – Motion Data"
rtables.attitude_ixblue_phins_surface_motion_kmatt = {  % from attitude_ixblue_phins_surface_motion.json
'attitude_ixblue_phins_surface_motion_kmatt'  6 []  % fields
%      'syncByte1SensorStatus'                             ''                                                   'Sync_Byte_1_or_Sensor_Status'
                   'syncByte2'                             ''                                                                    'Sync_Byte_2'
                        'roll'             'hundreth degrees'                                                     'Roll__postive_port_side_up'
                       'pitch'             'hundreth degrees'                                                          'Pitch__postive_bow_up'
                       'heave'                  'centimetres'                                                              'Heave__postive_up'
                     'heading'             'hundreth degrees'                                                     'Heading__postive_clockwise'
};


%attitude_seapath_320_1_heading  2  sentences

%"INHDT – Heading – True Data"
rtables.attitude_seapath_320_1_heading_inhdt = {  % from attitude_seapath_320_1_heading.json
'attitude_seapath_320_1_heading_inhdt'  2 []  % fields
                 'headingTrue'                      'degrees'                                                                   'Heading_True'
%                'trueHeading'                             ''                                                               'True_Designation'
};

%"INROT – Rate of Turn"
rtables.attitude_seapath_320_1_heading_inrot = {  % from attitude_seapath_320_1_heading.json
'attitude_seapath_320_1_heading_inrot'  2 []  % fields
                  'rateOfTurn'           'degrees per minute'                                            'Rate_of_Turn___-__means_bow_to_port'
%                  'rotStatus'                             ''                                                                         'Status'
};


%attitude_seapath_320_1_motion  1  sentences

%"KMATT – Motion Data"
rtables.attitude_seapath_320_1_motion_kmatt = {  % from attitude_seapath_320_1_motion.json
'attitude_seapath_320_1_motion_kmatt'  6 []  % fields
%      'syncByte1SensorStatus'                             ''                                                   'Sync_Byte_1_or_Sensor_Status'
                   'syncByte2'                             ''                                                                    'Sync_Byte_2'
                        'roll'             'hundreth degrees'                                                     'Roll__postive_port_side_up'
                       'pitch'             'hundreth degrees'                                                          'Pitch__postive_bow_up'
                       'heave'                  'centimetres'                                                              'Heave__postive_up'
                     'heading'             'hundreth degrees'                                                     'Heading__postive_clockwise'
};


%attitude_seapath_320_2_heading  2  sentences

%"INHDT – Heading – True Data"
rtables.attitude_seapath_320_2_heading_inhdt = {  % from attitude_seapath_320_2_heading.json
'attitude_seapath_320_2_heading_inhdt'  2 []  % fields
                 'headingTrue'                      'degrees'                                                                   'Heading_True'
%                'trueHeading'                             ''                                                               'True_Designation'
};

%"INROT – Rate of Turn"
rtables.attitude_seapath_320_2_heading_inrot = {  % from attitude_seapath_320_2_heading.json
'attitude_seapath_320_2_heading_inrot'  2 []  % fields
                  'rateOfTurn'           'degrees per minute'                                            'Rate_of_Turn___-__means_bow_to_port'
%                  'rotStatus'                             ''                                                                         'Status'
};


%attitude_seapath_320_2_motion  1  sentences

%"KMATT – Motion Data"
rtables.attitude_seapath_320_2_motion_kmatt = {  % from attitude_seapath_320_2_motion.json
'attitude_seapath_320_2_motion_kmatt'  6 []  % fields
%      'syncByte1SensorStatus'                             ''                                                   'Sync_Byte_1_or_Sensor_Status'
                   'syncByte2'                             ''                                                                    'Sync_Byte_2'
                        'roll'             'hundreth degrees'                                                     'Roll__postive_port_side_up'
                       'pitch'             'hundreth degrees'                                                          'Pitch__postive_bow_up'
                       'heave'                  'centimetres'                                                              'Heave__postive_up'
                     'heading'             'hundreth degrees'                                                     'Heading__postive_clockwise'
};


%attitude_smc_imu108_2  2  sentences

%"PSMCV – Roll, Pitch and Heave observations"
rtables.attitude_smc_imu108_2_psmcv = {  % from attitude_smc_imu108_2.json
'attitude_smc_imu108_2_psmcv'  6 []  % fields
                        'roll'                      'degrees'                                                                     'Roll_Angle'
                       'pitch'                      'degrees'                                                                    'Pitch_Angle'
                       'heave'                       'metres'                                                                          'Heave'
                'rollVelocity'               'degrees/second'                                                                  'Roll_Velocity'
               'pitchVelocity'               'degrees/second'                                                                 'Pitch_Velocity'
               'heaveVelocity'                'metres/second'                                                                 'Heave_Velocity'
};

%"PSMCB – Roll, Pitch and Heave observations"
rtables.attitude_smc_imu108_2_psmcb = {  % from attitude_smc_imu108_2.json
'attitude_smc_imu108_2_psmcb' 18 []  % fields
                        'roll'                      'degrees'                                                                     'Roll_Angle'
                       'pitch'                      'degrees'                                                                    'Pitch_Angle'
                         'yaw'                      'degrees'                                                                            'Yaw'
                'rollVelocity'               'degrees/second'                                                                  'Roll_Velocity'
               'pitchVelocity'               'degrees/second'                                                                 'Pitch_Velocity'
                 'yawVelocity'               'degrees/second'                                                                   'Yaw_Velocity'
            'rollAcceleration'             'degrees/second^2'                                                              'Roll_Acceleration'
           'pitchAcceleration'             'degrees/second^2'                                                             'Pitch_Acceleration'
             'yawAcceleration'             'degrees/second^2'                                                               'Yaw_Acceleration'
                       'surge'                       'metres'                                                                          'Surge'
                        'sway'                       'metres'                                                                           'Sway'
                       'heave'                       'metres'                                                                          'Heave'
               'surgeVelocity'                'metres/second'                                                                 'Surge_Velocity'
                'swayVelocity'                'metres/second'                                                                  'Sway_Velocity'
               'heaveVelocity'                'metres/second'                                                                 'Heave_Velocity'
               'accelerationX'              'metres/second^2'                                                                 'Acceleration_X'
               'accelerationY'              'metres/second^2'                                                                 'Acceleration_Y'
               'accelerationZ'              'metres/second^2'                                                                 'Acceleration_Z'
};


%gnss_fugro_oceanstar  3  sentences

%"GPVTG – Course Over Ground and Ground Speed Data"
rtables.gnss_fugro_oceanstar_gpvtg = {  % from gnss_fugro_oceanstar.json
'gnss_fugro_oceanstar_gpvtg'  9 []  % fields
            'courseOverGround'                      'degrees'                                                        'Course_Over_Ground_True'
%                 'trueCourse'                             ''                                                               'True_Designation'
%              'magneticTrack'                      'degrees'                                                    'Course_Over_Ground_Magnetic'
%                      'mFlag'                             ''                                                           'Magnetic_Designation'
%                 'speedKnots'                        'knots'                                                        'Speed_Over_Ground_Knots'
%                      'nFlag'                             ''                                                              'Knots_Designation'
%                  'speedKmph'                         'km/h'                                                         'Speed_Over_Ground_km/h'
%                      'kFlag'                             ''                                                                'kph_Designation'
%            'positioningMode'                             ''                                                             'FAA_Mode_Indicator'
};


%gnss_saab_r5_supreme  6  sentences

%"GNVTG – Course Over Ground and Ground Speed Data"
rtables.gnss_saab_r5_supreme_gnvtg = {  % from gnss_saab_r5_supreme.json
'gnss_saab_r5_supreme_gnvtg'  9 []  % fields
            'courseOverGround'                      'degrees'                                                        'Course_Over_Ground_True'
%                 'trueCourse'                             ''                                                               'True_Designation'
%              'magneticTrack'                      'degrees'                                                    'Course_Over_Ground_Magnetic'
%                      'mFlag'                             ''                                                           'Magnetic_Designation'
%                 'speedKnots'                        'knots'                                                        'Speed_Over_Ground_Knots'
%                      'nFlag'                             ''                                                              'Knots_Designation'
%                  'speedKmph'                         'km/h'                                                         'Speed_Over_Ground_km/h'
%                      'kFlag'                             ''                                                                'kph_Designation'
%            'positioningMode'                             ''                                                             'FAA_Mode_Indicator'
};

%"GNRMC – RMC navigation data"
rtables.gnss_saab_r5_supreme_gnrmc = {  % from gnss_saab_r5_supreme.json
'gnss_saab_r5_supreme_gnrmc' 13 []  % fields
                     'utcTime'                             ''                                                    'UTC_Time_of_Navigation_Data'
%                      'vFlag'                             ''                                                                'Receiver_Status'
                    'latitude' 'degrees, minutes and decimal minutes'                                                                       'Latitude'
                      'latDir'                             ''                                                    'Latitude_Cardinal_Direction'
                   'longitude' 'degrees, minutes and decimal minutes'                                                                      'Longitude'
                      'lonDir'                             ''                                                   'Longitude_Cardinal_Direction'
%                 'speedKnots'                        'knots'                                                              'Speed_over_ground'
               'trackMadeGood'                      'degrees'                                                                'Track_Made_Good'
                     'navDate'                             ''                                                    'UTC_Date_of_Navigation_Data'
%                     'magvar'                      'degrees'                                                             'Magnetic_variation'
%                  'magvarDir'                             ''                                                'Direction_of_magnetic_variation'
%            'positioningMode'                             ''                                                                 'Mode_indicator'
%         'navigationalStatus'                             ''                                                            'Navigational_Status'
};

%"GNGLL – Position data: Position fix, time of position fix and status"
rtables.gnss_saab_r5_supreme_gngll = {  % from gnss_saab_r5_supreme.json
'gnss_saab_r5_supreme_gngll'  7 []  % fields
                    'latitude' 'degrees, minutes and decimal minutes'                                                                       'Latitude'
                      'latDir'                             ''                                                    'Latitude_Cardinal_Direction'
                   'longitude' 'degrees, minutes and decimal minutes'                                                                      'Longitude'
                      'lonDir'                             ''                                                   'Longitude_Cardinal_Direction'
                     'utcTime'                             ''                                                      'UTC_Time_for_position_fix'
                     'gllQual'                             ''                                                                'Receiver_Status'
%            'positioningMode'                             ''                                                                 'Mode_indicator'
};


%gnss_seapath_320_1  3  sentences

%"INGGA – Global Positioning Fix Data"
rtables.gnss_seapath_320_1_ingga = {  % from gnss_seapath_320_1.json
'gnss_seapath_320_1_ingga' 14 []  % fields
                     'utcTime'                             ''                                                                       'UTC_Time'
                    'latitude' 'degrees, minutes and decimal minutes'                                                                       'Latitude'
                      'latDir'                             ''                                                    'Latitude_Cardinal_Direction'
                   'longitude' 'degrees, minutes and decimal minutes'                                                                      'Longitude'
                      'lonDir'                             ''                                                   'Longitude_Cardinal_Direction'
%                    'ggaQual'                             ''                                                         'GNSS_Quality_Indicator'
                      'numSat'                             ''                                               'Number_of_satellites_used_in_fix'
%                       'hdop'                             ''                                               'Horizontal_Dilution_of_Precision'
                    'altitude'                       'metres'                                          'Antenna_altitude_above_mean_sea_level'
%      'unitsOfMeasureAntenna'                             ''                                                      'Units_of_antenna_altitude'
%              'geoidAltitude'                       'metres'                                                               'Geoid_separation'
%        'unitsOfMeasureGeoid'                             ''                                                      'Units_of_geoid_separation'
%                   'diffcAge'                      'seconds'                                 'Time_since_last_differential_correction_update'
%                 'dgnssRefId'                             ''                                                        'Differential_station_ID'
};

%"INVTG – Course Over Ground and Ground Speed Data"
rtables.gnss_seapath_320_1_invtg = {  % from gnss_seapath_320_1.json
'gnss_seapath_320_1_invtg'  9 []  % fields
            'courseOverGround'                      'degrees'                                                        'Course_Over_Ground_True'
%                 'trueCourse'                             ''                                                               'True_Designation'
%              'magneticTrack'                      'degrees'                                                    'Course_Over_Ground_Magnetic'
%                      'mFlag'                             ''                                                           'Magnetic_Designation'
%                 'speedKnots'                        'knots'                                                        'Speed_Over_Ground_Knots'
%                      'nFlag'                             ''                                                              'Knots_Designation'
%                  'speedKmph'                         'km/h'                                                         'Speed_Over_Ground_km/h'
%                      'kFlag'                             ''                                                                'kph_Designation'
%            'positioningMode'                             ''                                                             'FAA_Mode_Indicator'
};


%gnss_seapath_320_2  3  sentences

%"INGGA – Global Positioning Fix Data"
rtables.gnss_seapath_320_2_ingga = {  % from gnss_seapath_320_2.json
'gnss_seapath_320_2_ingga' 14 []  % fields
                     'utcTime'                             ''                                                                       'UTC_Time'
                    'latitude' 'degrees, minutes and decimal minutes'                                                                       'Latitude'
                      'latDir'                             ''                                                    'Latitude_Cardinal_Direction'
                   'longitude' 'degrees, minutes and decimal minutes'                                                                      'Longitude'
                      'lonDir'                             ''                                                   'Longitude_Cardinal_Direction'
%                    'ggaQual'                             ''                                                         'GNSS_Quality_Indicator'
                      'numSat'                             ''                                               'Number_of_satellites_used_in_fix'
%                       'hdop'                             ''                                               'Horizontal_Dilution_of_Precision'
                    'altitude'                       'metres'                                          'Antenna_altitude_above_mean_sea_level'
%      'unitsOfMeasureAntenna'                             ''                                                      'Units_of_antenna_altitude'
%              'geoidAltitude'                       'metres'                                                               'Geoid_separation'
%        'unitsOfMeasureGeoid'                             ''                                                      'Units_of_geoid_separation'
%                   'diffcAge'                      'seconds'                                 'Time_since_last_differential_correction_update'
%                 'dgnssRefId'                             ''                                                        'Differential_station_ID'
};

%"INVTG – Course Over Ground and Ground Speed Data"
rtables.gnss_seapath_320_2_invtg = {  % from gnss_seapath_320_2.json
'gnss_seapath_320_2_invtg'  9 []  % fields
            'courseOverGround'                      'degrees'                                                        'Course_Over_Ground_True'
%                 'trueCourse'                             ''                                                               'True_Designation'
%              'magneticTrack'                      'degrees'                                                    'Course_Over_Ground_Magnetic'
%                      'mFlag'                             ''                                                           'Magnetic_Designation'
%                 'speedKnots'                        'knots'                                                        'Speed_Over_Ground_Knots'
%                      'nFlag'                             ''                                                              'Knots_Designation'
%                  'speedKmph'                         'km/h'                                                         'Speed_Over_Ground_km/h'
%                      'kFlag'                             ''                                                                'kph_Designation'
%            'positioningMode'                             ''                                                             'FAA_Mode_Indicator'
};


%gyrocompass_raytheon_standard_30_mf_1  2  sentences

%"HEHDT – Heading – True Data"
rtables.gyrocompass_raytheon_standard_30_mf_1_hehdt = {  % from gyrocompass_raytheon_standard_30_mf_1.json
'gyrocompass_raytheon_standard_30_mf_1_hehdt'  2 []  % fields
                 'headingTrue'                      'degrees'                                                                   'Heading_True'
%                'trueHeading'                             ''                                                               'True_Designation'
};

%"HEROT – Rate of Turn"
rtables.gyrocompass_raytheon_standard_30_mf_1_herot = {  % from gyrocompass_raytheon_standard_30_mf_1.json
'gyrocompass_raytheon_standard_30_mf_1_herot'  2 []  % fields
                  'rateOfTurn'           'degrees per minute'                                            'Rate_of_Turn___-__means_bow_to_port'
%                  'rotStatus'                             ''                                                                         'Status'
};


%gyrocompass_raytheon_standard_30_mf_2  2  sentences

%"HEHDT – Heading – True Data"
rtables.gyrocompass_raytheon_standard_30_mf_2_hehdt = {  % from gyrocompass_raytheon_standard_30_mf_2.json
'gyrocompass_raytheon_standard_30_mf_2_hehdt'  2 []  % fields
                 'headingTrue'                      'degrees'                                                                   'Heading_True'
%                'trueHeading'                             ''                                                               'True_Designation'
};

%"HEROT – Rate of Turn"
rtables.gyrocompass_raytheon_standard_30_mf_2_herot = {  % from gyrocompass_raytheon_standard_30_mf_2.json
'gyrocompass_raytheon_standard_30_mf_2_herot'  2 []  % fields
                  'rateOfTurn'           'degrees per minute'                                            'Rate_of_Turn___-__means_bow_to_port'
%                  'rotStatus'                             ''                                                                         'Status'
};


%gyrocompass_safran_bluenaute  2  sentences

%"HEHDT – Heading – True Data"
rtables.gyrocompass_safran_bluenaute_hehdt = {  % from gyrocompass_safran_bluenaute.json
'gyrocompass_safran_bluenaute_hehdt'  2 []  % fields
                 'headingTrue'                      'degrees'                                                                   'Heading_True'
%                'trueHeading'                             ''                                                               'True_Designation'
};

%"HEROT – Rate of Turn"
rtables.gyrocompass_safran_bluenaute_herot = {  % from gyrocompass_safran_bluenaute.json
'gyrocompass_safran_bluenaute_herot'  2 []  % fields
                  'rateOfTurn'           'degrees per minute'                                            'Rate_of_Turn___-__means_bow_to_port'
%                  'rotStatus'                             ''                                                                         'Status'
};


%met_biral_sws_200_j11302_01  1  sentences

%"PBPWS - Biral SWS200 Present Weather Sensor default message"
rtables.met_biral_sws_200_j11302_01_pbpws = {  % from met_biral_sws_200_j11302_01.json
'met_biral_sws_200_j11302_01_pbpws' 14 []  % fields
               'messagePrefix'                             ''                                                                 'Message_Prefix'
        'sensorIdentification'                             ''                                                          'Sensor_Identification'
               'averagingTime'                      'seconds'                                                                 'Averaging_Time'
  'meteorologicalOpticalRange'                           'km'                                                   'Meteorological_Optical_Range'
% 'meteorologicalOpticalRangeUnits'                             ''                                              'Meteorological_Optical_Range_Unit'
          'precipitationWater'                           'mm'                                                  'Precipitation_Water_in_Period'
          'presentWeatherCode'                             ''                                                           'Present_Weather_Code'
              'airTemperature'                'degreeCelcius'                                                                'Air_Temperature'
%         'airTemperatureUnit'                             ''                                                           'Air_Temperature_Unit'
'instantaneousMeteorologicalOpticalRange'                           'km'                                     'Instantaneous_Meteorological_Optical_Range'
% 'instantaneousMeteorologicalOpticalRangeUnit'                             ''                                'Instantaneous_Meteorological_Optical_Range_Unit'
                    'selfTest'                             ''                                                                       'SelfTest'
'windowContaminationMonitoring'                             ''                                                'Window_Contamination_Monitoring'
                    'testMode'                             ''                                                                      'Test_Mode'
};


%met_campbell_0871lh1_0490  1  sentences

%"PCFRS - Campbell Scientific Freezing Rain Sensor message"
rtables.met_campbell_0871lh1_0490_pcfrs = {  % from met_campbell_0871lh1_0490.json
'met_campbell_0871lh1_0490_pcfrs' 22 []  % fields
                    'stringID'                             ''                                                                      'String_ID'
            'probeHeaterState'                             ''                                                             'Probe_Heater_State'
                   'iceOutput'                             ''                                                                     'Ice_Output'
%               'statusOutput'                             ''                                                                  'Status_Output'
                'msoFrequency'                             ''                                                                  'MSO_Frequency'
                    'errstat1'                             ''                                                                       'ERRSTAT1'
                    'errstat2'                             ''                                                                       'ERRSTAT2'
%                'onTimeCount'                             ''                                                                  'On_Time_Count'
%             'coldStartCount'                             ''                                                               'Cold_Start_Count'
%                   'iceCount'                             ''                                                                      'Ice_Count'
%                  'failCount'                             ''                                                                     'Fail_Count'
                    'failDTL1'                             ''                                                                      'Fail_DTL1'
                    'failDTL2'                             ''                                                                      'Fail_DTL2'
                  'lastError1'                             ''                                                                   'Last_Error_1'
                  'lastError2'                             ''                                                                   'Last_Error_2'
            'secondLastError1'                             ''                                                            'Second_Last_Error_1'
            'secondLastError2'                             ''                                                            'Second_Last_Error_2'
                  'permError1'                             ''                                                                   'Perm_Error_1'
                  'permError2'                             ''                                                                   'Perm_Error_2'
             'softwareVersion'                             ''                                                               'Software_Version'
%           'correlationCount'                             ''                                                              'Correlation_Count'
                    'checksum'                             ''                                                                       'Checksum'
};


%met_eliasson_cbme80_2275  1  sentences

%"PECEIL - Eliasson CBME80 Ceilometer message format 5 - ASCII"
rtables.met_eliasson_cbme80_2275_peceil = {  % from met_eliasson_cbme80_2275.json
'met_eliasson_cbme80_2275_peceil' 23 []  % fields
                    'identity'                             ''                                                                       'Identity'
              'programVersion'                             ''                                                                'Program_Version'
                'serialNumber'                             ''                                                                  'Serial_Number'
                      'blower'                             ''                                                                  'Blower_on/off'
%                 'statusWord'                             ''                                                                    'Status_Word'
              'measuringRange'                         'feet'                                                                'Measuring_Range'
            'cloudBase1Height'                         'feet'                                                            'Cloud_Base_1_Height'
           'penetrationDepth1'                         'feet'                                                            'Penetration_Depth_1'
            'cloudBase2Height'                         'feet'                                                            'Cloud_Base_2_Height'
           'penetrationDepth2'                         'feet'                                                            'Penetration_Depth_2'
            'cloudBase3Height'                         'feet'                                                            'Cloud_Base_3_Height'
           'penetrationDepth3'                         'feet'                                                            'Penetration_Depth_3'
          'verticalVisibility'                         'feet'                                                            'Vertical_Visibility'
           'cloudLayer1Amount'                        'octas'                                                           'Cloud_Layer_1_Amount'
           'cloudLayer1Height'                         'feet'                                                        'Height_of_Cloud_Layer_1'
           'cloudLayer2Amount'                        'octas'                                                           'Cloud_Layer_2_Amount'
           'cloudLayer2Height'                         'feet'                                                        'Height_of_Cloud_Layer_2'
           'cloudLayer3Amount'                        'octas'                                                           'Cloud_Layer_3_Amount'
           'cloudLayer3Height'                         'feet'                                                        'Height_of_Cloud_Layer_3'
           'cloudLayer4Amount'                        'octas'                                                           'Cloud_Layer_4_Amount'
           'cloudLayer4Height'                         'feet'                                                        'Height_of_Cloud_Layer_4'
            'totalCloudAmount'                        'octas'                                                             'Total_Cloud_Amount'
                       'spare'                             ''                                                           'Spare_for_Future_Use'
};


%met_michell_optidew_154553  1  sentences

%"PMDEW - Michell Optidew Hygrometer message"
rtables.met_michell_optidew_154553_pmdew = {  % from met_michell_optidew_154553.json
'met_michell_optidew_154553_pmdew' 10 []  % fields
         'dewPointTemperature'                             ''                                                          'Dew_Point_Temperature'
          'ambientTemperature'                             ''                                                            'Ambient_Temperature'
            'relativeHumidity'                             ''                                                              'Relative_Humidity'
           'mirrorSignalLevel'                             ''                                                            'Mirror_Signal_Level'
          'heatPumpDepression'                             ''                                                    'Depression_of_the_Heat_Pump'
%           'instrumentStatus'                             ''                                                              'Instrument_Status'
          'gramsPerCubicMetre'                             ''                                                          'Grams_per_Cubic_Metre'
            'gramsPerKilogram'                             ''                                                             'Grams_per_Kilogram'
%                      'Units'                             ''                                                                          'Units'
% 'mirrorTemperatureControlStatus'                             ''                                              'Mirror_Temperature_Control_Status'
};


%met_thies_clima_5_4110_2782  1  sentences


%met_vaisala_hmp155e_s0850273  1  sentences

%"PVTNH - Vaisala custom output message"
rtables.met_vaisala_hmp155e_s0850273_pvtnh = {  % from met_vaisala_hmp155e_s0850273.json
'met_vaisala_hmp155e_s0850273_pvtnh'  2 []  % fields
            'relativeHumidity'                   'percentage'                                                              'Relative_Humidity'
              'airTemperature'               'degreesCelsius'                                                                'Air_Temperature'
};


%met_vaisala_hmp155e_s0850274  1  sentences

%"PVTNH2 - Vaisala custom output message"
rtables.met_vaisala_hmp155e_s0850274_pvtnh2 = {  % from met_vaisala_hmp155e_s0850274.json
'met_vaisala_hmp155e_s0850274_pvtnh2'  9 []  % fields
            'relativeHumidity'                   'percentage'                                                              'Relative_Humidity'
              'airTemperature'               'degreesCelsius'                                                                'Air_Temperature'
'dewPointFrostPointTemperature'               'degreesCelsius'                                            'Dew_Point_/_Frost_Point_Temperature'
         'dewPointTemperature'               'degreesCelsius'                                                          'Dew_Point_Temperature'
                 'mixingRatio'                         'g/kg'                                                                   'Mixing_Ratio'
          'wetBulbTemperature'               'degreesCelsius'                                                           'Wet_Bulb_Temperature'
%                 'errorFlags'                             ''                                                                    'Error_Flags'
%         'probeHeatingStatus'                             ''                                                           'Probe_Heating_Status'
                'serialNumber'                             ''                                                                  'Serial_Number'
};


%met_vaisala_hmp155e_s0850275  1  sentences

%"PVTNH - Vaisala custom output message"
rtables.met_vaisala_hmp155e_s0850275_pvtnh = {  % from met_vaisala_hmp155e_s0850275.json
'met_vaisala_hmp155e_s0850275_pvtnh'  2 []  % fields
            'relativeHumidity'                   'percentage'                                                              'Relative_Humidity'
              'airTemperature'               'degreesCelsius'                                                                'Air_Temperature'
};


%met_vaisala_ptb330_n2410065  1  sentences

%"PVBAR - Vaisala custom output message"
rtables.met_vaisala_ptb330_n2410065_pvbar = {  % from met_vaisala_ptb330_n2410065.json
'met_vaisala_ptb330_n2410065_pvbar'  3 []  % fields
                 'airPressure'                          'hPa'                                                                   'Air_Pressure'
  'heightCorrectedAirPressure'                          'hPa'                                                  'Height_Corrected_Air_Pressure'
         'internalTemperature'               'degreesCelsius'                                                           'Internal_Temperature'
};


%met_vaisala_ptb330_n2410066  1  sentences

%"PVBAR - Vaisala custom output message"
rtables.met_vaisala_ptb330_n2410066_pvbar = {  % from met_vaisala_ptb330_n2410066.json
'met_vaisala_ptb330_n2410066_pvbar'  3 []  % fields
                 'airPressure'                          'hPa'                                                                   'Air_Pressure'
  'heightCorrectedAirPressure'                          'hPa'                                                  'Height_Corrected_Air_Pressure'
         'internalTemperature'               'degreesCelsius'                                                           'Internal_Temperature'
};


%platform_comet_t3510  1  sentences

%"Comet T3510 - temperature, relative humidity and dew point"
rtables.platform_comet_t3510_pctnh = {  % from platform_comet_t3510.json
'platform_comet_t3510_pctnh' 20 []  % fields
                     'devname'                             ''                                                                    'Device_Name'
                       'devsn'                             ''                                                           'Device_Serial_Number'
                     'devtime'          'hh:mm:ss yyyy-mm-dd'                                                                    'Device_Time'
                    'timeSync'                             ''                                                                      'Time_Sync'
                     'ch1Name'                             ''                                                                 'Channel_1_Name'
%                    'ch1Unit'                             ''                                                                 'Channel_1_Unit'
                    'ch1Value'                             ''                                                                'Channel_1_Value'
                    'ch1Alarm'                             ''                                                                'Channel_1_Alarm'
                     'ch2Name'                             ''                                                                 'Channel_2_Name'
%                    'ch2Unit'                             ''                                                                 'Channel_2_Unit'
                    'ch2Value'                             ''                                                                'Channel_2_Value'
                    'ch2Alarm'                             ''                                                                'Channel_2_Alarm'
                     'ch3Name'                             ''                                                                 'Channel_3_Name'
%                    'ch3Unit'                             ''                                                                 'Channel_3_Unit'
                    'ch3Value'                             ''                                                                'Channel_3_Value'
                    'ch3Alarm'                             ''                                                                'Channel_3_Alarm'
                     'ch4Name'                             ''                                                                 'Channel_4_Name'
%                    'ch4Unit'                             ''                                                                 'Channel_4_Unit'
                    'ch4Value'                             ''                                                                'Channel_4_Value'
                    'ch4Alarm'                             ''                                                                'Channel_4_Alarm'
};


%platform_schneider_ap8953  1  sentences

%"Schneider AP8953 temperature, relative humidity"
rtables.platform_schneider_ap8953_ps8953 = {  % from platform_schneider_ap8953.json
'platform_schneider_ap8953_ps8953'  5 []  % fields
                 'modelnumber'                             ''                                                                  'Model_Number_'
                'serialNumber'                             ''                                                                  'Serial_Number'
                        'name'                             ''                                                                           'Name'
                 'temperature'                  '10ths deg C'                                                                    'Temperature'
            'relativeHumidity'                          '%RH'                                                               'RelativeHumidity'
};


%platform_yotta_a1819  1  sentences

%"Yotta A-1819 Temperature Logger"
rtables.platform_yotta_a1819_pytemp = {  % from platform_yotta_a1819.json
'platform_yotta_a1819_pytemp'  3 []  % fields
                  'macAddress'                             ''                                                                   'MAC_Address_'
                     'channel'                             ''                                                                        'Channel'
                 'temperature'                            'c'                                                                    'Temperature'
};


%ptu_vaisala_ptb330_n2410065  1  sentences

%"PVBAR - Vaisala custom output message"
rtables.ptu_vaisala_ptb330_n2410065_pvbar = {  % from ptu_vaisala_ptb330_n2410065.json
'ptu_vaisala_ptb330_n2410065_pvbar'  2 []  % fields
                 'airPressure'                          'hPa'                                                                   'Air_Pressure'
              'airTemperature'               'degreesCelsius'                                                                'Air_Temperature'
};


%ptu_vaisala_ptb330_n2410066  1  sentences

%"PVBAR - Vaisala custom output message"
rtables.ptu_vaisala_ptb330_n2410066_pvbar = {  % from ptu_vaisala_ptb330_n2410066.json
'ptu_vaisala_ptb330_n2410066_pvbar'  2 []  % fields
                 'airPressure'                          'hPa'                                                                   'Air_Pressure'
              'airTemperature'               'degreesCelsius'                                                                'Air_Temperature'
};


%radiometer_heitronics_ct15_85_13316  1  sentences

%"PHSST - Heitronics CT15 infrared temperature of sea surface"
rtables.radiometer_heitronics_ct15_85_13316_phsst = {  % from radiometer_heitronics_ct15_85_13316.json
'radiometer_heitronics_ct15_85_13316_phsst'  2 []  % fields
       'seaSurfaceTemperature'               'degreesCelsius'                                                        'Sea_Surface_Temperature'
%  'seaSurfaceTemperatureUnit'                             ''                                                   'Sea_Surface_Temperature_Unit'
};


%radiometer_heitronics_ct15_85_13317  1  sentences

%"PHSST - Heitronics CT15 infrared temperature of sea surface"
rtables.radiometer_heitronics_ct15_85_13317_phsst = {  % from radiometer_heitronics_ct15_85_13317.json
'radiometer_heitronics_ct15_85_13317_phsst'  2 []  % fields
       'seaSurfaceTemperature'               'degreesCelsius'                                                        'Sea_Surface_Temperature'
%  'seaSurfaceTemperatureUnit'                             ''                                                   'Sea_Surface_Temperature_Unit'
};


%radiometer_kipp_zonen_sgr4a_190056  1  sentences

%"PKPYRGE - Bespoke Kipp and Zonen SGR4-A Pyrgeometer message read from a MODBUS interface"
rtables.radiometer_kipp_zonen_sgr4a_190056_pkpyrge = {  % from radiometer_kipp_zonen_sgr4a_190056.json
'radiometer_kipp_zonen_sgr4a_190056_pkpyrge' 34 []  % fields
                  'deviceType'                             ''                                                                    'Device_Type'
            'datamodelVersion'                             ''                                                             'Data_Model_Version'
             'operationalMode'                             ''                                                               'Operational_Mode'
%                'statusFlags'                             ''                                                                   'Status_Flags'
                 'scaleFactor'                             ''                                                                   'Scale_Factor'
       'netRadiationCorrected'                             '' 'Temperature_Corrected_Net_Radiation_-_Longwave_Downward_Radiation_minus_Longwave_Upwards_Sensor_Radiation'
     'netRadiationUncorrected'                             '' 'Temperature_Uncorrected_Net_Radiation_-_Longwave_Downward_Radiation_minus_Longwave_Upwards_Sensor_Radiation'
'netRadiationStandardDeviation'                             ''                                               'Net_Radiation_Standard_Deviation'
             'bodyTemperature'                             ''                                                               'Body_Temperature'
        'externalPowerVoltage'                             ''                                                         'External_Power_Voltage'
'longwaveDownwardRadiationCorrected'                         'w/m2'                              'Temperature_Corrected_Longwave_Downward_Radiation'
'longwaveDownwardRadiationUncorrected'                         'w/m2'                                     'Temperature_Uncorrected_Downward_Radiation'
'longwaveDownwardRadiationStandardDeviation'                             ''            'Longwave_Downward_Radiation_Standard_Deviation_-_Not_used__Always_0'
            'bodyTemperatureK'                        '0.01K'                                                             'Body_Temperature_K'
                   'auxInput2'                             ''                                               'Aux_Input_2_-_Not_used__Always_0'
                   'auxInput3'                             ''                                               'Aux_Input_3_-_Not_used__Always_0'
            'dacOutputVoltage'                             ''                                                             'DAC_Output_Voltage'
            'selectedDacInput'                             ''                                                     'DAC_Selected_Input_Voltage'
%                 'adc1Counts'                             ''                                                                    'ADC1_Counts'
%                 'adc2Counts'                             ''                                          'ADC2_Counts_-_Not_supported__Always_0'
%                 'adc3Counts'                             ''                                                                    'ADC3_Counts'
%                 'adc4Counts'                             ''                                                                    'ADC4_Counts'
                   'errorCode'                             ''                                                                     'Error_Code'
               'protocolError'                             ''                                                                 'Protocol_Error'
%        'errorCountPriority1'                             ''                                                         'Error_Count_Priority_1'
%        'errorCountPriority2'                             ''                                                         'Error_Count_Priority_2'
%     'controlledRestartCount'                             ''                                                       'Controlled_Restart_Count'
%   'uncontrolledRestartCount'                             ''                                                     'Uncontrolled_Restart_Count'
                'sensorOnTime'                            's'                                                                 'Sensor_On_Time'
                 'batchNumber'                            's'                                                                   'Batch_Number'
                'serialNumber'                            's'                                                                  'Serial_Number'
             'softwareVersion'                            's'                                                               'Software_Version'
             'hardwareVersion'                            's'                                                               'Hardware_Version'
                      'nodeID'                             ''                                               'Node_ID_-_MODBUS_Device_Address_'
};


%radiometer_kipp_zonen_sgr4a_190057  1  sentences

%"PKPYRGE - Bespoke Kipp and Zonen SGR4-A Pyrgeometer message read from a MODBUS interface"
rtables.radiometer_kipp_zonen_sgr4a_190057_pkpyrge = {  % from radiometer_kipp_zonen_sgr4a_190057.json
'radiometer_kipp_zonen_sgr4a_190057_pkpyrge' 34 []  % fields
                  'deviceType'                             ''                                                                    'Device_Type'
            'datamodelVersion'                             ''                                                             'Data_Model_Version'
             'operationalMode'                             ''                                                               'Operational_Mode'
%                'statusFlags'                             ''                                                                   'Status_Flags'
                 'scaleFactor'                             ''                                                                   'Scale_Factor'
       'netRadiationCorrected'                             '' 'Temperature_Corrected_Net_Radiation_-_Longwave_Downward_Radiation_minus_Longwave_Upwards_Sensor_Radiation'
     'netRadiationUncorrected'                             '' 'Temperature_Uncorrected_Net_Radiation_-_Longwave_Downward_Radiation_minus_Longwave_Upwards_Sensor_Radiation'
'netRadiationStandardDeviation'                             ''                                               'Net_Radiation_Standard_Deviation'
             'bodyTemperature'                             ''                                                               'Body_Temperature'
        'externalPowerVoltage'                             ''                                                         'External_Power_Voltage'
'longwaveDownwardRadiationCorrected'                         'w/m2'                              'Temperature_Corrected_Longwave_Downward_Radiation'
'longwaveDownwardRadiationUncorrected'                         'w/m2'                                     'Temperature_Uncorrected_Downward_Radiation'
'longwaveDownwardRadiationStandardDeviation'                             ''            'Longwave_Downward_Radiation_Standard_Deviation_-_Not_used__Always_0'
            'bodyTemperatureK'                        '0.01K'                                                             'Body_Temperature_K'
                   'auxInput2'                             ''                                               'Aux_Input_2_-_Not_used__Always_0'
                   'auxInput3'                             ''                                               'Aux_Input_3_-_Not_used__Always_0'
            'dacOutputVoltage'                             ''                                                             'DAC_Output_Voltage'
            'selectedDacInput'                             ''                                                     'DAC_Selected_Input_Voltage'
%                 'adc1Counts'                             ''                                                                    'ADC1_Counts'
%                 'adc2Counts'                             ''                                          'ADC2_Counts_-_Not_supported__Always_0'
%                 'adc3Counts'                             ''                                                                    'ADC3_Counts'
%                 'adc4Counts'                             ''                                                                    'ADC4_Counts'
                   'errorCode'                             ''                                                                     'Error_Code'
               'protocolError'                             ''                                                                 'Protocol_Error'
%        'errorCountPriority1'                             ''                                                         'Error_Count_Priority_1'
%        'errorCountPriority2'                             ''                                                         'Error_Count_Priority_2'
%     'controlledRestartCount'                             ''                                                       'Controlled_Restart_Count'
%   'uncontrolledRestartCount'                             ''                                                     'Uncontrolled_Restart_Count'
                'sensorOnTime'                            's'                                                                 'Sensor_On_Time'
                 'batchNumber'                            's'                                                                   'Batch_Number'
                'serialNumber'                            's'                                                                  'Serial_Number'
             'softwareVersion'                            's'                                                               'Software_Version'
             'hardwareVersion'                            's'                                                               'Hardware_Version'
                      'nodeID'                             ''                                               'Node_ID_-_MODBUS_Device_Address_'
};


%radiometer_kipp_zonen_smp22a_190028  1  sentences

%"PKPYRAN - Bespoke Kipp and Zonen SMP22-A Pyranometer message read from a MODBUS interface"
rtables.radiometer_kipp_zonen_smp22a_190028_pkpyran = {  % from radiometer_kipp_zonen_smp22a_190028.json
'radiometer_kipp_zonen_smp22a_190028_pkpyran' 34 []  % fields
                  'deviceType'                             ''                                                                    'Device_Type'
            'datamodelVersion'                             ''                                                             'Data_Model_Version'
             'operationalMode'                             ''                                                               'Operational_Mode'
%                'statusFlags'                             ''                                                                   'Status_Flags'
                 'scaleFactor'                             ''                                                                   'Scale_Factor'
 'shortwaveRadiationCorrected'                             ''                                      'Temperature_Corrected_Shortwave_Radiation'
'shortwaveRadiationUncorrected'                             ''                                    'Temperature_Uncorrected_Shortwave_Radiation'
'shortwaveRadiationStandardDeviation'                             ''                                         'Shortwave_Radiation_Standard_Deviation'
             'bodyTemperature'                             ''                                                               'Body_Temperature'
        'externalPowerVoltage'                             ''                                                         'External_Power_Voltage'
          'sensor2DataSGROnly'                             ''                       'Sensor_2_Data_-_Only_relevant_for_SGR_pyrgeometer_models'
       'sensor2RawDataSGROnly'                             ''                   'Sensor_2_Raw_Data_-_Only_relevant_for_SGR_pyrgeometer_models'
    'sensor2StandardDeviation'                             ''                               'Sensor_2_Standard_Deviation_-_Not_used__Always_0'
     'bodyTemperatureKSGROnly'                        '0.01K'                  'Body_Temperature_K_-_Only_relevant_for_SGR_pyrgeometer_models'
                   'auxInput2'                             ''                                               'Aux_Input_2_-_Not_used__Always_0'
                   'auxInput3'                             ''                                               'Aux_Input_3_-_Not_used__Always_0'
            'dacOutputVoltage'                             ''                                                             'DAC_Output_Voltage'
            'selectedDacInput'                             ''                                                     'DAC_Selected_Input_Voltage'
%                 'adc1Counts'                             ''                                                                    'ADC1_Counts'
%                 'adc2Counts'                             ''                                          'ADC2_Counts_-_Not_supported__Always_0'
%                 'adc3Counts'                             ''                                                                    'ADC3_Counts'
%                 'adc4Counts'                             ''                                                                    'ADC4_Counts'
                   'errorCode'                             ''                                                                     'Error_Code'
               'protocolError'                             ''                                                                 'Protocol_Error'
%        'errorCountPriority1'                             ''                                                         'Error_Count_Priority_1'
%        'errorCountPriority2'                             ''                                                         'Error_Count_Priority_2'
%     'controlledRestartCount'                             ''                                                       'Controlled_Restart_Count'
%   'uncontrolledRestartCount'                             ''                                                     'Uncontrolled_Restart_Count'
                'sensorOnTime'                            's'                                                                 'Sensor_On_Time'
                 'batchNumber'                            's'                                                                   'Batch_Number'
                'serialNumber'                            's'                                                                  'Serial_Number'
             'softwareVersion'                            's'                                                               'Software_Version'
             'hardwareVersion'                            's'                                                               'Hardware_Version'
                      'nodeID'                             ''                                               'Node_ID_-_MODBUS_Device_Address_'
};


%radiometer_kipp_zonen_smp22a_190029  1  sentences

%"PKPYRAN - Bespoke Kipp and Zonen SMP22-A Pyranometer message read from a MODBUS interface"
rtables.radiometer_kipp_zonen_smp22a_190029_pkpyran = {  % from radiometer_kipp_zonen_smp22a_190029.json
'radiometer_kipp_zonen_smp22a_190029_pkpyran' 34 []  % fields
                  'deviceType'                             ''                                                                    'Device_Type'
            'datamodelVersion'                             ''                                                             'Data_Model_Version'
             'operationalMode'                             ''                                                               'Operational_Mode'
%                'statusFlags'                             ''                                                                   'Status_Flags'
                 'scaleFactor'                             ''                                                                   'Scale_Factor'
 'shortwaveRadiationCorrected'                             ''                                      'Temperature_Corrected_Shortwave_Radiation'
'shortwaveRadiationUncorrected'                             ''                                    'Temperature_Uncorrected_Shortwave_Radiation'
'shortwaveRadiationStandardDeviation'                             ''                                         'Shortwave_Radiation_Standard_Deviation'
             'bodyTemperature'                             ''                                                               'Body_Temperature'
        'externalPowerVoltage'                             ''                                                         'External_Power_Voltage'
          'sensor2DataSGROnly'                             ''                       'Sensor_2_Data_-_Only_relevant_for_SGR_pyrgeometer_models'
       'sensor2RawDataSGROnly'                             ''                   'Sensor_2_Raw_Data_-_Only_relevant_for_SGR_pyrgeometer_models'
    'sensor2StandardDeviation'                             ''                               'Sensor_2_Standard_Deviation_-_Not_used__Always_0'
     'bodyTemperatureKSGROnly'                        '0.01K'                  'Body_Temperature_K_-_Only_relevant_for_SGR_pyrgeometer_models'
                   'auxInput2'                             ''                                               'Aux_Input_2_-_Not_used__Always_0'
                   'auxInput3'                             ''                                               'Aux_Input_3_-_Not_used__Always_0'
            'dacOutputVoltage'                             ''                                                             'DAC_Output_Voltage'
            'selectedDacInput'                             ''                                                     'DAC_Selected_Input_Voltage'
%                 'adc1Counts'                             ''                                                                    'ADC1_Counts'
%                 'adc2Counts'                             ''                                          'ADC2_Counts_-_Not_supported__Always_0'
%                 'adc3Counts'                             ''                                                                    'ADC3_Counts'
%                 'adc4Counts'                             ''                                                                    'ADC4_Counts'
                   'errorCode'                             ''                                                                     'Error_Code'
               'protocolError'                             ''                                                                 'Protocol_Error'
%        'errorCountPriority1'                             ''                                                         'Error_Count_Priority_1'
%        'errorCountPriority2'                             ''                                                         'Error_Count_Priority_2'
%     'controlledRestartCount'                             ''                                                       'Controlled_Restart_Count'
%   'uncontrolledRestartCount'                             ''                                                     'Uncontrolled_Restart_Count'
                'sensorOnTime'                            's'                                                                 'Sensor_On_Time'
                 'batchNumber'                            's'                                                                   'Batch_Number'
                'serialNumber'                            's'                                                                  'Serial_Number'
             'softwareVersion'                            's'                                                               'Software_Version'
             'hardwareVersion'                            's'                                                               'Hardware_Version'
                      'nodeID'                             ''                                               'Node_ID_-_MODBUS_Device_Address_'
};


%radiometer_satlantic_par_ser_icsa_2039  1  sentences

%"PSPAR - Satlantic PAR short-ascii message"
rtables.radiometer_satlantic_par_ser_icsa_2039_pspar = {  % from radiometer_satlantic_par_ser_icsa_2039.json
'radiometer_satlantic_par_ser_icsa_2039_pspar'  7 []  % fields
             'makeModelSerial'                             ''                                                              'Make_Model_Serial'
                       'timer'                      'seconds'                                                                          'Timer'
                         'par'                             ''                                                                            'Par'
                       'pitch'                      'degrees'                                                                    'Pitch_Angle'
                        'roll'                      'degrees'                                                                     'Roll_Angle'
         'internalTemperature'               'degreesCelsius'                                                           'Internal_Temperature'
                    'checksum'                             ''                                                                       'Checksum'
};


%radiometer_satlantic_par_ser_icsa_2040  1  sentences

%"PSPAR - Satlantic PAR short-ascii message"
rtables.radiometer_satlantic_par_ser_icsa_2040_pspar = {  % from radiometer_satlantic_par_ser_icsa_2040.json
'radiometer_satlantic_par_ser_icsa_2040_pspar'  7 []  % fields
             'makeModelSerial'                             ''                                                              'Make_Model_Serial'
                       'timer'                      'seconds'                                                                          'Timer'
                         'par'                             ''                                                                            'Par'
                       'pitch'                      'degrees'                                                                    'Pitch_Angle'
                        'roll'                      'degrees'                                                                     'Roll_Angle'
         'internalTemperature'               'degreesCelsius'                                                           'Internal_Temperature'
                    'checksum'                             ''                                                                       'Checksum'
};


%singlebeam_kongsberg_ea640  1  sentences

%"DBDBT – Depth below transducer"
rtables.singlebeam_kongsberg_ea640_dbdbt = {  % from singlebeam_kongsberg_ea640.json
'singlebeam_kongsberg_ea640_dbdbt'  6 []  % fields
% 'waterDepthFeetFromTransducer'                         'feet'                                             'Depth_in_feets_from_the_Transducer'
%                   'feetFlag'                             ''                                                               'Feet_Designation'
'waterDepthMeterFromTransducer'                       'metres'                                            'Depth_in_meters_from_the_Transducer'
%                  'meterFlag'                             ''                                                              'Meter_Designation'
% 'waterDepthFathomFromTransducer'                       'fathom'                                           'Depth_in_fathoms_from_the_Transducer'
%                 'fathomFlag'                             ''                                                             'Fathom_Designation'
};


%singlebeam_skipper_gds102  6  sentences

%"SDDPT – Depth of water"
rtables.singlebeam_skipper_gds102_sddpt = {  % from singlebeam_skipper_gds102.json
'singlebeam_skipper_gds102_sddpt'  3 []  % fields
             'waterDepthMeter'                       'metres'                                'Depth_in_meters_from_the_transducer_Centre_Beam'
                     'offsetT'                       'metres'                                  'Offset_of_transducer_from_waterline_in_meters'
%                   'maxRange'                       'metres'                                                     'Maximum_range_Scale_in_Use'
};

%"SDDBS – Depth below surface"
rtables.singlebeam_skipper_gds102_sddbs = {  % from singlebeam_skipper_gds102.json
'singlebeam_skipper_gds102_sddbs'  6 []  % fields
%  'waterDepthFeetFromSurface'                         'feet'                                                'Depth_in_feets_from_the_Surface'
%                   'feetFlag'                             ''                                                               'Feet_Designation'
  'waterDepthMeterFromSurface'                       'metres'                                               'Depth_in_meters_from_the_Surface'
%                  'meterFlag'                             ''                                                              'Meter_Designation'
% 'waterDepthFathomFromSurface'                       'fathom'                                              'Depth_in_fathoms_from_the_Surface'
%                 'fathomFlag'                             ''                                                             'Fathom_Designation'
};

%"SDDBT – Depth below transducer"
rtables.singlebeam_skipper_gds102_sddbt = {  % from singlebeam_skipper_gds102.json
'singlebeam_skipper_gds102_sddbt'  6 []  % fields
% 'waterDepthFeetFromTransducer'                         'feet'                                             'Depth_in_feets_from_the_Transducer'
%                   'feetFlag'                             ''                                                               'Feet_Designation'
'waterDepthMeterFromTransducer'                       'metres'                                            'Depth_in_meters_from_the_Transducer'
%                  'meterFlag'                             ''                                                              'Meter_Designation'
% 'waterDepthFathomFromTransducer'                       'fathom'                                           'Depth_in_fathoms_from_the_Transducer'
%                 'fathomFlag'                             ''                                                             'Fathom_Designation'
};

%"SDDBK – Depth below keel"
rtables.singlebeam_skipper_gds102_sddbk = {  % from singlebeam_skipper_gds102.json
'singlebeam_skipper_gds102_sddbk'  6 []  % fields
%     'waterDepthFeetFromKeel'                         'feet'                                                   'Depth_in_feets_from_the_Keel'
%                   'feetFlag'                             ''                                                               'Feet_Designation'
     'waterDepthMeterFromKeel'                       'metres'                                                  'Depth_in_meters_from_the_Keel'
%                  'meterFlag'                             ''                                                              'Meter_Designation'
%   'waterDepthFathomFromKeel'                       'fathom'                                                 'Depth_in_fathoms_from_the_Keel'
%                 'fathomFlag'                             ''                                                             'Fathom_Designation'
};

%"PSKPDPT – Depth of water"
rtables.singlebeam_skipper_gds102_pskpdpt = {  % from singlebeam_skipper_gds102.json
'singlebeam_skipper_gds102_pskpdpt'  6 []  % fields
             'waterDepthMeter'                       'metres'                                'Depth_in_meters_from_the_transducer_Centre_Beam'
                     'offsetT'                       'metres'                                  'Offset_of_transducer_from_waterline_in_meters'
%                   'maxRange'                       'metres'                                                     'Maximum_range_Scale_in_Use'
          'bottomEchoStrength'                             ''                                                           'Bottom_Echo_Strength'
    'echosounderChannelNumber'                             ''                                                     'Echosounder_Channel_Number'
          'TransducerLocation'                             ''                                                            'Transducer_Location'
};

%"SDALR – Water Depth Alarm"
rtables.singlebeam_skipper_gds102_sdalr = {  % from singlebeam_skipper_gds102.json
'singlebeam_skipper_gds102_sdalr'  5 []  % fields
      'utcTimeLastAlarmChange'                             ''                                                  'UTC_Time_of_Last_Alarm_Change'
                     'alarmID'                             ''                                                                       'Alarm_ID'
%                'alarmStatus'                             ''                                                                   'Alarm_Status'
%          'acknowledgeStatus'                             ''                                                             'Acknowledge_Status'
%           'alarmDescription'                             ''                                                              'Alarm_Description'
};


%soundvelocity_valeport_minisvs_ucsw1  1  sentences

%"PVSVS – Sound Velocity"
rtables.soundvelocity_valeport_minisvs_ucsw1_pvsvs = {  % from soundvelocity_valeport_minisvs_ucsw1.json
'soundvelocity_valeport_minisvs_ucsw1_pvsvs'  1 []  % fields
               'soundVelocity'                'metres/second'                                                                 'Sound_Velocity'
};
