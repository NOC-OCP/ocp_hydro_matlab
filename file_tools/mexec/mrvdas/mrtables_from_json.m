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
%          'windDirectionType'                             ''                                                            'Wind_Direction_Type'
                   'windSpeed'                          'm/s'                                                                     'Wind_Speed'
%             'windSpeedUnits'                             ''                                                               'Wind_Speed_Units'
%                 'windStatus'                             ''                                                                    'Wind_Status'
};


%anemometer_metek_usonic3_1  1  sentences

%"PMWIND – bespoke output from the Metek uSonic-3 anemometer "
rtables.anemometer_metek_usonic3_1_pmwind = {  % from anemometer_metek_usonic3_1.json
'anemometer_metek_usonic3_1_pmwind'  6 []  % fields
%             'dataOutputType'                             ''                                                               'Data_Output_Type'
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
%             'dataOutputType'                             ''                                                               'Data_Output_Type'
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
%             'dataOutputType'                             ''                                                               'Data_Output_Type'
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
%          'windDirectionType'                             ''                                                            'Wind_Direction_Type'
                   'windSpeed'                          'm/s'                                                                     'Wind_Speed'
%             'windSpeedUnits'                             ''                                                               'Wind_Speed_Units'
%                 'windStatus'                             ''                                                                    'Wind_Status'
};


%anemometer_observator_omc116_2  1  sentences

%"WIMWV – Wind Speed and Angle"
rtables.anemometer_observator_omc116_2_wimwv = {  % from anemometer_observator_omc116_2.json
'anemometer_observator_omc116_2_wimwv'  5 []  % fields
               'windDirection'                      'degrees'                                                                 'Wind_Direction'
%          'windDirectionType'                             ''                                                            'Wind_Direction_Type'
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
%                  'syncByte2'                             ''                                                                    'Sync_Byte_2'
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
%                  'syncByte2'                             ''                                                                    'Sync_Byte_2'
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
%                  'syncByte2'                             ''                                                                    'Sync_Byte_2'
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


%cloud_vaisala_cl31_stbd1  1  sentences

%"PVCEIL1 - Vaisala CL31 Ceilometer message format msg2_10x770"
rtables.cloud_vaisala_cl31_stbd1_pvceil1 = {  % from cloud_vaisala_cl31_stbd1.json
'cloud_vaisala_cl31_stbd1_pvceil1' 28 []  % fields
     'identityMessageMetadata'                             ''                                                  'Identity_and_Message_Metadata'
% 'cloudDetectionStatusAlarmWarningStatus'                             ''                                'Cloud_Detection_Status_and_Alarm/Warning_status'
                     'height1'                       'metres'                                'Lowest_Cloud_Base_Height_or_Vertical_Visibility'
                     'height2'                       'metres'                     'Second_lowest_cloud_base_height_or_Highest_Signal_Detected'
                     'height3'                       'metres'                                                      'Highest_Cloud_Base_Height'
     'alarmWarningInformation'                             ''                                 'Alarm__warning_and_internal_status_information'
         'CloudLayer1Coverage'                        'octas'                                              'Cloud_Coverage_of_the_first_layer'
           'CloudLayer1Height'                       'metres'                                                'Cloud_Height_of_the_first_layer'
         'CloudLayer2Coverage'                        'octas'                                             'Cloud_Coverage_of_the_second_layer'
           'CloudLayer2Height'                       'metres'                                               'Cloud_Height_of_the_second_layer'
         'CloudLayer3Coverage'                        'octas'                                              'Cloud_Coverage_of_the_third_layer'
           'CloudLayer3Height'                       'metres'                                                'Cloud_Height_of_the_third_layer'
         'CloudLayer4Coverage'                        'octas'                                             'Cloud_Coverage_of_the_fourth_layer'
           'CloudLayer4Height'                       'metres'                                               'Cloud_Height_of_the_fourth_layer'
         'CloudLayer5Coverage'                        'octas'                                              'Cloud_Coverage_of_the_fifth_layer'
           'CloudLayer5Height'                       'metres'                                                'Cloud_Height_of_the_fifth_layer'
              'parameterScale'                   'percentage'                                                                'Parameter_Scale'
'backscatterProfileResolution'                       'metres'                                                 'Backscatter_Profile_Resolution'
         'profileSampleLength'                             ''                                               'Length_of_the_profile_in_Samples'
            'laserPulseEnergy'                   'percentage'                                                             'Laser_Pulse_Energy'
            'laserTemperature'                      'celsius'                                                              'Laser_Temperature'
  'windowTransmissionEstimate'                   'percentage'                                                   'Window_Transmission_Estimate'
                   'tiltAngle'                      'degrees'                                                                     'Tilt_Angle'
             'backgroundLight'                   'millivolts'                                                               'Background_Light'
       'measurementParameters'                             ''                                                         'Measurement_Parameters'
              'backscatterSum'                             ''                                     'Sum_of_detected_and_normalised_backscatter'
          'backscatterProfile'            '(10000 srad km)-1'                                         'Two-way_Attenuated_Backscatter_Profile'
               'crc16Checksum'                             ''                                                                 'CRC16_Checksum'
};


%flowmeter_litremeter_lmx24_ucsw1  1  sentences

%"PLMFLOW1 - bespoke set of variables from Modbus registers on a LitreMeter LMX.24 flowmeter "
rtables.flowmeter_litremeter_lmx24_ucsw1_plmflow1 = {  % from flowmeter_litremeter_lmx24_ucsw1.json
'flowmeter_litremeter_lmx24_ucsw1_plmflow1' 15 []  % fields
%               'serialNumber'                             ''                                                                  'Serial_Number'
                    'flowRate'                   'litres/min'                                                                      'Flow_Rate'
%               'flowRateUnit'                             ''                                                                 'Flow_Rate_Unit'
%           'flowRateTimeUnit'                             ''                                                            'Flow_Rate_Time_Unit'
            'flowRateDecimals'                             ''                                                             'Flow_Rate_Decimals'
             'flowRateKFactor'                             ''                                                             'Flow_Rate_K_Factor'
     'flowRateKFactorDecimals'                             ''                                                    'Flow_Rate_K_Factor_Decimals'
              'flowRatePulses'                             ''                                                               'Flow_Rate_Pulses'
                   'totalFlow'                       'litres'                                                                     'Total_Flow'
        'totalFlowAccumulated'                       'litres'                                                         'Total_Flow_Accumulated'
%              'totalFlowUnit'                             ''                                                                'Total_Flow_Unit'
           'totalFlowDecimals'                             ''                                                            'Total_Flow_Decimals'
            'TotalFlowKFactor'                             ''                                                            'Total_Flow_K_Factor'
    'totalFlowKFactorDecimals'                             ''                                                   'Total_Flow_K_Factor_Decimals'
%                'errorStatus'                             ''                                                                   'Error_Status'
};


%fluorometer_wetlabs_wschl_ucsw1  1  sentences

%"PWLFLUOR1 - WETLabs WETStar (WSCHL) fluorometer message"
rtables.fluorometer_wetlabs_wschl_ucsw1_pwlfluor1 = {  % from fluorometer_wetlabs_wschl_ucsw1.json
'fluorometer_wetlabs_wschl_ucsw1_pwlfluor1'  1 []  % fields
                 'chlorophyll'                       'counts'                                                                    'Chlorophyll'
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
                   'speedKmph'                         'km/h'                                                         'Speed_Over_Ground_km/h'
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
                   'speedKmph'                         'km/h'                                                         'Speed_Over_Ground_km/h'
%                      'kFlag'                             ''                                                                'kph_Designation'
%            'positioningMode'                             ''                                                             'FAA_Mode_Indicator'
};

%"GNGLL – Position data: Position fix, time of position fix and status"
rtables.gnss_saab_r5_supreme_gngll = {  % from gnss_saab_r5_supreme.json
'gnss_saab_r5_supreme_gngll'  7 []  % fields
                    'latitude' 'degrees, minutes and decimal minutes'                                                                       'Latitude'
                      'latDir'                             ''                                                    'Latitude_Cardinal_Direction'
                   'longitude' 'degrees, minutes and decimal minutes'                                                                      'Longitude'
                      'lonDir'                             ''                                                   'Longitude_Cardinal_Direction'
                     'utcTime'                             ''                                                      'UTC_Time_for_position_fix'
%                    'gllQual'                             ''                                                                'Receiver_Status'
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
%                     'numSat'                             ''                                               'Number_of_satellites_used_in_fix'
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
                   'speedKmph'                         'km/h'                                                         'Speed_Over_Ground_km/h'
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
%                     'numSat'                             ''                                               'Number_of_satellites_used_in_fix'
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
                   'speedKmph'                         'km/h'                                                         'Speed_Over_Ground_km/h'
%                      'kFlag'                             ''                                                                'kph_Designation'
%            'positioningMode'                             ''                                                             'FAA_Mode_Indicator'
};


%gravimeter_dgs_at1m10_100_corrected  1  sentences

%"Dynamic Gravity Systems AT1M-10 Gravity Meter QC output message"
rtables.gravimeter_dgs_at1m10_100_corrected_pdgrav = {  % from gravimeter_dgs_at1m10_100_corrected.json
'gravimeter_dgs_at1m10_100_corrected_pdgrav' 26 []  % fields
            'gravityCorrected'                         'mGal'                                               'Cross_coupling_corrected_gravity'
          'gravityUncorrected'                         'mGal'                                                            'Uncorrected_gravity'
           'longAccelerometer'                          'Gal'                                                             'Long_Accelerometer'
          'crossAccelerometer'                         'mGal'                                                            'Cross_Accelerometer'
                        'beam'                        'Volts'                                                                           'beam'
           'sensorTemperature'               'degreesCelsius'                                                             'Sensor_Temperature'
%                     'status'                             ''                                      'sensor_status_binary_codified_status_word'
%                   'checksum'                             ''                                                                  'simple_sum_of'
              'sensorPressure'                       'inchHg'                                                       'Internal_sensor_pressure'
      'electronicsTemperature'               'degreesCelsius'                                                        'Electronics_Temperature'
      'veCrossCouplingMonitor'                         'mGal'                                                      'Ve_Cross_Coupling_Monitor'
     'vccCrossCouplingMonitor'                         'mGal'                                                     'Vcc_Cross_Coupling_Monitor'
      'alCrossCouplingMonitor'                         'mGal'                                                      'Al_Cross_Coupling_Monitor'
      'axCrossCouplingMonitor'                         'mGal'                                                      'Ax_Cross_Coupling_Monitor'
                    'latitude'               'DecimalDegrees'                                                                       'latitude'
                   'longitude'               'decimalDegrees'                                                                      'longitude'
             'speedOverGround'                        'knots'                                                              'speed_over_ground'
            'courseOverGround'                      'Degrees'                                                             'Course_over_Ground'
                       'vmond'                             ''                                                         'Mean_vertical_velocity'
                        'year'                             ''                                                                           'Year'
                       'month'                             ''                                                                          'Month'
                         'day'                             ''                                                                            'Day'
                       'hours'                             ''                                                                          'Hours'
                     'minutes'                             ''                                                                        'Minutes'
                     'seconds'                             ''                                                                        'Seconds'
                  'lineNumber'                             ''                                              'Line_number_since_start_of_sensor'
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
%                   'selfTest'                             ''                                                                       'SelfTest'
'windowContaminationMonitoring'                             ''                                                'Window_Contamination_Monitoring'
%                   'testMode'                             ''                                                                      'Test_Mode'
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
                 'onTimeCount'                             ''                                                                  'On_Time_Count'
              'coldStartCount'                             ''                                                               'Cold_Start_Count'
                    'iceCount'                             ''                                                                      'Ice_Count'
                   'failCount'                             ''                                                                     'Fail_Count'
                    'failDTL1'                             ''                                                                      'Fail_DTL1'
                    'failDTL2'                             ''                                                                      'Fail_DTL2'
                  'lastError1'                             ''                                                                   'Last_Error_1'
                  'lastError2'                             ''                                                                   'Last_Error_2'
            'secondLastError1'                             ''                                                            'Second_Last_Error_1'
            'secondLastError2'                             ''                                                            'Second_Last_Error_2'
                  'permError1'                             ''                                                                   'Perm_Error_1'
                  'permError2'                             ''                                                                   'Perm_Error_2'
%            'softwareVersion'                             ''                                                               'Software_Version'
            'correlationCount'                             ''                                                              'Correlation_Count'
%                   'checksum'                             ''                                                                       'Checksum'
};


%met_eliasson_cbme80_2275  1  sentences

%"PECEIL - Eliasson CBME80 Ceilometer message format 5 - ASCII"
rtables.met_eliasson_cbme80_2275_peceil = {  % from met_eliasson_cbme80_2275.json
'met_eliasson_cbme80_2275_peceil' 23 []  % fields
%                   'identity'                             ''                                                                       'Identity'
%             'programVersion'                             ''                                                                'Program_Version'
%               'serialNumber'                             ''                                                                  'Serial_Number'
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
%                      'spare'                             ''                                                           'Spare_for_Future_Use'
};


%met_thies_clima_5_4110_2782  1  sentences

%"PTDISD - Thies Clima 5.4110.00.000 disdrometer output telegram 4"
rtables.met_thies_clima_5_4110_2782_ptdisd = {  % from met_thies_clima_5_4110_2782.json
'met_thies_clima_5_4110_2782_ptdisd' 520 []  % fields
%              'deviceAddress'                             ''                                                                 'Device_Address'
%               'serialNumber'                             ''                                                                  'Serial_Number'
%            'softwareVersion'                             ''                                                               'Software_Version'
                  'sensorDate'                             ''                                                                    'Sensor_Date'
                  'sensorTime'                             ''                                                                    'Sensor_Time'
 'fiveMinuteWMOSynop4677value'                             ''                                    'Five_minute_WMO_SYNOP_Table_4677_mean_value'
 'fiveMinuteWMOSynop4680value'                             ''                                    'Five_minute_WMO_SYNOP_Table_4680_mean_value'
  'fiveMinuteWMOMetar4678code'                             ''                               'Five_minute_WMO_METAR_Table_4678_mean_code_value'
         'fiveMinuteIntensity'                             ''                                                          'Five_Minute_Intensity'
  'oneMinuteWMOSynop4677value'                             ''                                     'One_minute_WMO_SYNOP_Table_4677_mean_value'
  'oneMinuteWMOSynop4680value'                             ''                                     'One_minute_WMO_SYNOP_Table_4680_mean_value'
   'oneMinuteWMOMetar4678code'                             ''                                'One_minute_WMO_METAR_Table_4678_mean_code_value'
'oneMinuteIntensityTotalPrecipitation'                         'mm/h'                                     'One_Minute_Intensity_-_Total_Precipitation'
'oneMinuteIntensityLiquidPrecipitation'                         'mm/h'                                    'One_Minute_Intensity_-_Liquid_Precipitation'
'oneMinuteIntensitySolidPrecipitation'                         'mm/h'                                     'One_Minute_Intensity_-_Solid_Precipitation'
         'precipitationAmount'                           'mm'                                                           'Precipitation_Amount'
'oneMinuteVisibilityInPrecipitation'                            'm'                                         'One_Minute_Visibility_in_Precipitation'
  'oneMinuteRadarReflectivity'                          'dBZ'                                                           'Precipitation_Amount'
   'oneMinuteMeasuringQuality'                   'precentage'                                                   'One_Minute_Measuring_Quality'
    'oneMinuteMaxDiameterHail'                           'mm'                                               'One_Minute_Maximum_Diameter_Hail'
%                'statusLaser'                             ''                                                                   'Status_Laser'
                'staticSignal'                             ''                                                                  'Static_Signal'
% 'statusLaserTemperatureAnalogue'                             ''                                              'Status_Laser_Temperature_Analogue'
% 'statusLaserTemperatureDigital'                             ''                                               'Status_Laser_Temperature_Digital'
% 'statusLaserCurrentAnalogue'                             ''                                                  'Status_Laser_Current_Analogue'
%  'statusLaserCurrentDigital'                             ''                                                   'Status_Laser_Current_Digital'
%         'statusSensorSupply'                             ''                                                          'Status_Sensor_Suppply'
% 'statusCurrentPaneHeatingLaserHead'                             ''                                         'Status_Current_Pane_Heating_Laser_Head'
% 'statusCurrentPaneReceiverLaserHead'                             ''                                        'Status_Current_Pane_Receiver_Laser_Head'
%    'statusTemperatureSensor'                             ''                                                      'Status_Temperature_Sensor'
%        'statusHeatingSupply'                             ''                                                          'Status_Heating_Supply'
% 'statusCurrentHeatingHousing'                             ''                                                 'Status_Current_Heating_Housing'
%  'statusCurrentHeatingHeads'                             ''                                                   'Status_Current_Heating_Heads'
% 'statusCurrentHeatingCarriers'                             ''                                                'Status_Current_Heating_Carriers'
% 'statusControlOutputLaserPower'                             ''                                              'Status_Control_Output_Laser_Power'
%              'reserveStatus'                             ''                                                                 'Reserve_Status'
         'interiorTemperature'                            'c'                                                           'Interior_Temperature'
      'temperatureLaserDriver'                            'c'                                                'Temperature_of_the_Laser_Driver'
       'laserCurrentMeanValue'                       '0.01mA'                                                       'Laser_Current_Mean_Value'
              'controlVoltage'                           'mV'                                                                'Control_Voltage'
        'opticalControlOutput'                           'mV'                                                         'Optical_Control_Output'
         'voltageSensorSupply'                           'mV'                                                          'Voltage_Sensor_Supply'
 'currentPaneHeatingLaserHead'                           'mA'                                                'Current_Pane_Heating_Laser_Head'
'currentPaneHeatingReceiverHead'                           'mA'                                             'Current_Pane_Heating_Receiver_Head'
          'ambientTemperature'                            'c'                                                            'Ambient_Temperature'
        'voltageHeatingSupply'                         '0.1V'                                                         'Voltage_Heating_Supply'
       'currentHeatingHousing'                           'mA'                                                        'Current_Heating_Housing'
         'currentHeatingHeads'                           'mA'                                                          'Current_Heating_Heads'
      'currentHeatingCarriers'                           'mA'                                                       'Current_Heating_Carriers'
  'numberAllMeasuredParticles'                             ''                                               'Number_of_all_Measured_Particles'
               'internalData1'                             ''                                                                'Internal_Data_1'
'numberParticlesBelowMinimalSpeed'                             ''                                        'Number_of_Particles_Below_Minimal_Speed'
               'internalData2'                             ''                                                                'Internal_Data_2'
'numberParticlesAboveMaximalSpeed'                             ''                                        'Number_of_Particles_Above_Maximal_Speed'
               'internalData3'                             ''                                                                'Internal_Data_3'
'numberParticlesBelowMinimalDiameter'                             ''                                     'Number_of_Particles_Below_Minimal_Diameter'
               'internalData4'                             ''                                                                'Internal_Data_4'
'numberParticlesNoHydrometeor'                             ''                                             'Number_of_Particles_No_Hydrometeor'
'volumeParticlesNoHydrometeor'                             ''                                             'Volume_of_Particles_No_Hydrometeor'
'numberParticlesUnknownClassification'                             ''                                  'Number_of_Particles_of_Unknown_Classification'
'volumeParticlesUnknownClassification'                             ''                                  'Volume_of_Particles_of_Unknown_Classification'
       'numberParticlesClass1'                             ''                                                 'Number_of_Particles_of_Class_1'
       'volumeParticlesClass1'                             ''                                                    'Volume_of_Particles_Class_1'
       'numberParticlesClass2'                             ''                                                 'Number_of_Particles_of_Class_2'
       'volumeParticlesClass2'                             ''                                                    'Volume_of_Particles_Class_2'
       'numberParticlesClass3'                             ''                                                 'Number_of_Particles_of_Class_3'
       'volumeParticlesClass3'                             ''                                                    'Volume_of_Particles_Class_3'
       'numberParticlesClass4'                             ''                                                 'Number_of_Particles_of_Class_4'
       'volumeParticlesClass4'                             ''                                                    'Volume_of_Particles_Class_4'
       'numberParticlesClass5'                             ''                                                 'Number_of_Particles_of_Class_5'
       'volumeParticlesClass5'                             ''                                                    'Volume_of_Particles_Class_5'
       'numberParticlesClass6'                             ''                                                 'Number_of_Particles_of_Class_6'
       'volumeParticlesClass6'                             ''                                                    'Volume_of_Particles_Class_6'
       'numberParticlesClass7'                             ''                                                 'Number_of_Particles_of_Class_7'
       'volumeParticlesClass7'                             ''                                                    'Volume_of_Particles_Class_7'
       'numberParticlesClass8'                             ''                                                 'Number_of_Particles_of_Class_8'
       'volumeParticlesClass8'                             ''                                                    'Volume_of_Particles_Class_8'
       'numberParticlesClass9'                             ''                                                 'Number_of_Particles_of_Class_9'
       'volumeParticlesClass9'                             ''                                                    'Volume_of_Particles_Class_9'
'numberParticlesDiameter0125_0250_Speed0000_0200'                             '' 'Number_of_Particles_of_0.125mm_=<_Diameter_<_0.25mm_and_0__m/s_=<_Speed_<_0.2_m/s'
'numberParticlesDiameter0125_0250_Speed0200_0400'                             '' 'Number_of_Particles_of_0.125mm_=<_Diameter_<_0.25mm_and_0.2_m/s_=<_Speed_<_0.4_m/s'
'numberParticlesDiameter0125_0250_Speed0400_0600'                             '' 'Number_of_Particles_of_0.125mm_=<_Diameter_<_0.25mm_and_0.4_m/s_=<_Speed_<_0.6_m/s'
'numberParticlesDiameter0125_0250_Speed0600_0800'                             '' 'Number_of_Particles_of_0.125mm_=<_Diameter_<_0.25mm_and_0.6_m/s_=<_Speed_<_0.8_m/s'
'numberParticlesDiameter0125_0250_Speed0800_1000'                             '' 'Number_of_Particles_of_0.125mm_=<_Diameter_<_0.25mm_and_0.8_m/s_=<_Speed_<_1.0_m/s'
'numberParticlesDiameter0125_0250_Speed1000_1400'                             '' 'Number_of_Particles_of_0.125mm_=<_Diameter_<_0.25mm_and_1.0_m/s_=<_Speed_<_1.4_m/s'
'numberParticlesDiameter0125_0250_Speed1400_1800'                             '' 'Number_of_Particles_of_0.125mm_=<_Diameter_<_0.25mm_and_1.4_m/s_=<_Speed_<_1.8_m/s'
'numberParticlesDiameter0125_0250_Speed1800_2200'                             '' 'Number_of_Particles_of_0.125mm_=<_Diameter_<_0.25mm_and_1.8_m/s_=<_Speed_<_2.2_m/s'
'numberParticlesDiameter0125_0250_Speed2200_2600'                             '' 'Number_of_Particles_of_0.125mm_=<_Diameter_<_0.25mm_and_2.2_m/s_=<_Speed_<_2.6_m/s'
'numberParticlesDiameter0125_0250_Speed2600_3000'                             '' 'Number_of_Particles_of_0.125mm_=<_Diameter_<_0.25mm_and_2.6_m/s_=<_Speed_<_3.0_m/s'
'numberParticlesDiameter0125_0250_Speed3000_3400'                             '' 'Number_of_Particles_of_0.125mm_=<_Diameter_<_0.25mm_and_3.0_m/s_=<_Speed_<_3.4_m/s'
'numberParticlesDiameter0125_0250_Speed3400_4200'                             '' 'Number_of_Particles_of_0.125mm_=<_Diameter_<_0.25mm_and_3.4_m/s_=<_Speed_<_4.2_m/s'
'numberParticlesDiameter0125_0250_Speed4200_5000'                             '' 'Number_of_Particles_of_0.125mm_=<_Diameter_<_0.25mm_and_4.2_m/s_=<_Speed_<_5.0_m/s'
'numberParticlesDiameter0125_0250_Speed5000_5800'                             '' 'Number_of_Particles_of_0.125mm_=<_Diameter_<_0.25mm_and_5.0_m/s_=<_Speed_<_5.8_m/s'
'numberParticlesDiameter0125_0250_Speed5800_6600'                             '' 'Number_of_Particles_of_0.125mm_=<_Diameter_<_0.25mm_and_5.8_m/s_=<_Speed_<_6.6_m/s'
'numberParticlesDiameter0125_0250_Speed6600_7400'                             '' 'Number_of_Particles_of_0.125mm_=<_Diameter_<_0.25mm_and_6.6_m/s_=<_Speed_<_7.4_m/s'
'numberParticlesDiameter0125_0250_Speed7400_8200'                             '' 'Number_of_Particles_of_0.125mm_=<_Diameter_<_0.25mm_and_7.4_m/s_=<_Speed_<_8.2_m/s'
'numberParticlesDiameter0125_0250_Speed8200_9000'                             '' 'Number_of_Particles_of_0.125mm_=<_Diameter_<_0.25mm_and_8.2_m/s_=<_Speed_<_9.0_m/s'
'numberParticlesDiameter0125_0250_Speed9000_10000'                             '' 'Number_of_Particles_of_0.125mm_=<_Diameter_<_0.25mm_and_9.0_m/s_=<_Speed_<_10_m/s'
'numberParticlesDiameter0125_0250_Speed10000_20000'                             '' 'Number_of_Particles_of_0.125mm_=<_Diameter_<_0.25mm_and_10_m/s_=<_Speed_<_20_m/s'
'numberParticlesDiameter0250_0375_Speed0000_0200'                             '' 'Number_of_Particles_of_0.25mm_=<_Diameter_<_0.375mm_and_0__m/s_=<_Speed_<_0.2_m/s'
'numberParticlesDiameter0250_0375_Speed0200_0400'                             '' 'Number_of_Particles_of_0.25mm_=<_Diameter_<_0.375mm_and_0.2_m/s_=<_Speed_<_0.4_m/s'
'numberParticlesDiameter0250_0375_Speed0400_0600'                             '' 'Number_of_Particles_of_0.25mm_=<_Diameter_<_0.375mm_and_0.4_m/s_=<_Speed_<_0.6_m/s'
'numberParticlesDiameter0250_0375_Speed0600_0800'                             '' 'Number_of_Particles_of_0.25mm_=<_Diameter_<_0.375mm_and_0.6_m/s_=<_Speed_<_0.8_m/s'
'numberParticlesDiameter0250_0375_Speed0800_1000'                             '' 'Number_of_Particles_of_0.25mm_=<_Diameter_<_0.375mm_and_0.8_m/s_=<_Speed_<_1.0_m/s'
'numberParticlesDiameter0250_0375_Speed1000_1400'                             '' 'Number_of_Particles_of_0.25mm_=<_Diameter_<_0.375mm_and_1.0_m/s_=<_Speed_<_1.4_m/s'
'numberParticlesDiameter0250_0375_Speed1400_1800'                             '' 'Number_of_Particles_of_0.25mm_=<_Diameter_<_0.375mm_and_1.4_m/s_=<_Speed_<_1.8_m/s'
'numberParticlesDiameter0250_0375_Speed1800_2200'                             '' 'Number_of_Particles_of_0.25mm_=<_Diameter_<_0.375mm_and_1.8_m/s_=<_Speed_<_2.2_m/s'
'numberParticlesDiameter0250_0375_Speed2200_2600'                             '' 'Number_of_Particles_of_0.25mm_=<_Diameter_<_0.375mm_and_2.2_m/s_=<_Speed_<_2.6_m/s'
'numberParticlesDiameter0250_0375_Speed2600_3000'                             '' 'Number_of_Particles_of_0.25mm_=<_Diameter_<_0.375mm_and_2.6_m/s_=<_Speed_<_3.0_m/s'
'numberParticlesDiameter0250_0375_Speed3000_3400'                             '' 'Number_of_Particles_of_0.25mm_=<_Diameter_<_0.375mm_and_3.0_m/s_=<_Speed_<_3.4_m/s'
'numberParticlesDiameter0250_0375_Speed3400_4200'                             '' 'Number_of_Particles_of_0.25mm_=<_Diameter_<_0.375mm_and_3.4_m/s_=<_Speed_<_4.2_m/s'
'numberParticlesDiameter0250_0375_Speed4200_5000'                             '' 'Number_of_Particles_of_0.25mm_=<_Diameter_<_0.375mm_and_4.2_m/s_=<_Speed_<_5.0_m/s'
'numberParticlesDiameter0250_0375_Speed5000_5800'                             '' 'Number_of_Particles_of_0.25mm_=<_Diameter_<_0.375mm_and_5.0_m/s_=<_Speed_<_5.8_m/s'
'numberParticlesDiameter0250_0375_Speed5800_6600'                             '' 'Number_of_Particles_of_0.25mm_=<_Diameter_<_0.375mm_and_5.8_m/s_=<_Speed_<_6.6_m/s'
'numberParticlesDiameter0250_0375_Speed6600_7400'                             '' 'Number_of_Particles_of_0.25mm_=<_Diameter_<_0.375mm_and_6.6_m/s_=<_Speed_<_7.4_m/s'
'numberParticlesDiameter0250_0375_Speed7400_8200'                             '' 'Number_of_Particles_of_0.25mm_=<_Diameter_<_0.375mm_and_7.4_m/s_=<_Speed_<_8.2_m/s'
'numberParticlesDiameter0250_0375_Speed8200_9000'                             '' 'Number_of_Particles_of_0.25mm_=<_Diameter_<_0.375mm_and_8.2_m/s_=<_Speed_<_9.0_m/s'
'numberParticlesDiameter0250_0375_Speed9000_10000'                             '' 'Number_of_Particles_of_0.25mm_=<_Diameter_<_0.375mm_and_9.0_m/s_=<_Speed_<_10_m/s'
'numberParticlesDiameter0250_0375_Speed10000_20000'                             '' 'Number_of_Particles_of_0.25mm_=<_Diameter_<_0.375mm_and_10_m/s_=<_Speed_<_20_m/s'
'numberParticlesDiameter0375_0500_Speed0000_0200'                             '' 'Number_of_Particles_of_0.375mm_=<_Diameter_<_0.5mm_and_0__m/s_=<_Speed_<_0.2_m/s'
'numberParticlesDiameter0375_0500_Speed0200_0400'                             '' 'Number_of_Particles_of_0.375mm_=<_Diameter_<_0.5mm_and_0.2_m/s_=<_Speed_<_0.4_m/s'
'numberParticlesDiameter0375_0500_Speed0400_0600'                             '' 'Number_of_Particles_of_0.375mm_=<_Diameter_<_0.5mm_and_0.4_m/s_=<_Speed_<_0.6_m/s'
'numberParticlesDiameter0375_0500_Speed0600_0800'                             '' 'Number_of_Particles_of_0.375mm_=<_Diameter_<_0.5mm_and_0.6_m/s_=<_Speed_<_0.8_m/s'
'numberParticlesDiameter0375_0500_Speed0800_1000'                             '' 'Number_of_Particles_of_0.375mm_=<_Diameter_<_0.5mm_and_0.8_m/s_=<_Speed_<_1.0_m/s'
'numberParticlesDiameter0375_0500_Speed1000_1400'                             '' 'Number_of_Particles_of_0.375mm_=<_Diameter_<_0.5mm_and_1.0_m/s_=<_Speed_<_1.4_m/s'
'numberParticlesDiameter0375_0500_Speed1400_1800'                             '' 'Number_of_Particles_of_0.375mm_=<_Diameter_<_0.5mm_and_1.4_m/s_=<_Speed_<_1.8_m/s'
'numberParticlesDiameter0375_0500_Speed1800_2200'                             '' 'Number_of_Particles_of_0.375mm_=<_Diameter_<_0.5mm_and_1.8_m/s_=<_Speed_<_2.2_m/s'
'numberParticlesDiameter0375_0500_Speed2200_2600'                             '' 'Number_of_Particles_of_0.375mm_=<_Diameter_<_0.5mm_and_2.2_m/s_=<_Speed_<_2.6_m/s'
'numberParticlesDiameter0375_0500_Speed2600_3000'                             '' 'Number_of_Particles_of_0.375mm_=<_Diameter_<_0.5mm_and_2.6_m/s_=<_Speed_<_3.0_m/s'
'numberParticlesDiameter0375_0500_Speed3000_3400'                             '' 'Number_of_Particles_of_0.375mm_=<_Diameter_<_0.5mm_and_3.0_m/s_=<_Speed_<_3.4_m/s'
'numberParticlesDiameter0375_0500_Speed3400_4200'                             '' 'Number_of_Particles_of_0.375mm_=<_Diameter_<_0.5mm_and_3.4_m/s_=<_Speed_<_4.2_m/s'
'numberParticlesDiameter0375_0500_Speed4200_5000'                             '' 'Number_of_Particles_of_0.375mm_=<_Diameter_<_0.5mm_and_4.2_m/s_=<_Speed_<_5.0_m/s'
'numberParticlesDiameter0375_0500_Speed5000_5800'                             '' 'Number_of_Particles_of_0.375mm_=<_Diameter_<_0.5mm_and_5.0_m/s_=<_Speed_<_5.8_m/s'
'numberParticlesDiameter0375_0500_Speed5800_6600'                             '' 'Number_of_Particles_of_0.375mm_=<_Diameter_<_0.5mm_and_5.8_m/s_=<_Speed_<_6.6_m/s'
'numberParticlesDiameter0375_0500_Speed6600_7400'                             '' 'Number_of_Particles_of_0.375mm_=<_Diameter_<_0.5mm_and_6.6_m/s_=<_Speed_<_7.4_m/s'
'numberParticlesDiameter0375_0500_Speed7400_8200'                             '' 'Number_of_Particles_of_0.375mm_=<_Diameter_<_0.5mm_and_7.4_m/s_=<_Speed_<_8.2_m/s'
'numberParticlesDiameter0375_0500_Speed8200_9000'                             '' 'Number_of_Particles_of_0.375mm_=<_Diameter_<_0.5mm_and_8.2_m/s_=<_Speed_<_9.0_m/s'
'numberParticlesDiameter0375_0500_Speed9000_10000'                             '' 'Number_of_Particles_of_0.375mm_=<_Diameter_<_0.5mm_and_9.0_m/s_=<_Speed_<_10_m/s'
'numberParticlesDiameter0375_0500_Speed10000_20000'                             '' 'Number_of_Particles_of_0.375mm_=<_Diameter_<_0.5mm_and_10_m/s_=<_Speed_<_20_m/s'
'numberParticlesDiameter0500_0750_Speed0000_0200'                             '' 'Number_of_Particles_of_0.5mm_=<_Diameter_<_0.75mm_and_0__m/s_=<_Speed_<_0.2_m/s'
'numberParticlesDiameter0500_0750_Speed0200_0400'                             '' 'Number_of_Particles_of_0.5mm_=<_Diameter_<_0.75mm_and_0.2_m/s_=<_Speed_<_0.4_m/s'
'numberParticlesDiameter0500_0750_Speed0400_0600'                             '' 'Number_of_Particles_of_0.5mm_=<_Diameter_<_0.75mm_and_0.4_m/s_=<_Speed_<_0.6_m/s'
'numberParticlesDiameter0500_0750_Speed0600_0800'                             '' 'Number_of_Particles_of_0.5mm_=<_Diameter_<_0.75mm_and_0.6_m/s_=<_Speed_<_0.8_m/s'
'numberParticlesDiameter0500_0750_Speed0800_1000'                             '' 'Number_of_Particles_of_0.5mm_=<_Diameter_<_0.75mm_and_0.8_m/s_=<_Speed_<_1.0_m/s'
'numberParticlesDiameter0500_0750_Speed1000_1400'                             '' 'Number_of_Particles_of_0.5mm_=<_Diameter_<_0.75mm_and_1.0_m/s_=<_Speed_<_1.4_m/s'
'numberParticlesDiameter0500_0750_Speed1400_1800'                             '' 'Number_of_Particles_of_0.5mm_=<_Diameter_<_0.75mm_and_1.4_m/s_=<_Speed_<_1.8_m/s'
'numberParticlesDiameter0500_0750_Speed1800_2200'                             '' 'Number_of_Particles_of_0.5mm_=<_Diameter_<_0.75mm_and_1.8_m/s_=<_Speed_<_2.2_m/s'
'numberParticlesDiameter0500_0750_Speed2200_2600'                             '' 'Number_of_Particles_of_0.5mm_=<_Diameter_<_0.75mm_and_2.2_m/s_=<_Speed_<_2.6_m/s'
'numberParticlesDiameter0500_0750_Speed2600_3000'                             '' 'Number_of_Particles_of_0.5mm_=<_Diameter_<_0.75mm_and_2.6_m/s_=<_Speed_<_3.0_m/s'
'numberParticlesDiameter0500_0750_Speed3000_3400'                             '' 'Number_of_Particles_of_0.5mm_=<_Diameter_<_0.75mm_and_3.0_m/s_=<_Speed_<_3.4_m/s'
'numberParticlesDiameter0500_0750_Speed3400_4200'                             '' 'Number_of_Particles_of_0.5mm_=<_Diameter_<_0.75mm_and_3.4_m/s_=<_Speed_<_4.2_m/s'
'numberParticlesDiameter0500_0750_Speed4200_5000'                             '' 'Number_of_Particles_of_0.5mm_=<_Diameter_<_0.75mm_and_4.2_m/s_=<_Speed_<_5.0_m/s'
'numberParticlesDiameter0500_0750_Speed5000_5800'                             '' 'Number_of_Particles_of_0.5mm_=<_Diameter_<_0.75mm_and_5.0_m/s_=<_Speed_<_5.8_m/s'
'numberParticlesDiameter0500_0750_Speed5800_6600'                             '' 'Number_of_Particles_of_0.5mm_=<_Diameter_<_0.75mm_and_5.8_m/s_=<_Speed_<_6.6_m/s'
'numberParticlesDiameter0500_0750_Speed6600_7400'                             '' 'Number_of_Particles_of_0.5mm_=<_Diameter_<_0.75mm_and_6.6_m/s_=<_Speed_<_7.4_m/s'
'numberParticlesDiameter0500_0750_Speed7400_8200'                             '' 'Number_of_Particles_of_0.5mm_=<_Diameter_<_0.75mm_and_7.4_m/s_=<_Speed_<_8.2_m/s'
'numberParticlesDiameter0500_0750_Speed8200_9000'                             '' 'Number_of_Particles_of_0.5mm_=<_Diameter_<_0.75mm_and_8.2_m/s_=<_Speed_<_9.0_m/s'
'numberParticlesDiameter0500_0750_Speed9000_10000'                             '' 'Number_of_Particles_of_0.5mm_=<_Diameter_<_0.75mm_and_9.0_m/s_=<_Speed_<_10_m/s'
'numberParticlesDiameter0500_0750_Speed10000_20000'                             '' 'Number_of_Particles_of_0.5mm_=<_Diameter_<_0.75mm_and_10_m/s_=<_Speed_<_20_m/s'
'numberParticlesDiameter0750_1000_Speed0000_0200'                             ''  'Number_of_Particles_of_0.75mm_=<_Diameter_<_1mm_and_0__m/s_=<_Speed_<_0.2_m/s'
'numberParticlesDiameter0750_1000_Speed0200_0400'                             '' 'Number_of_Particles_of_0.75mm_=<_Diameter_<_1mm_and_0.2_m/s_=<_Speed_<_0.4_m/s'
'numberParticlesDiameter0750_1000_Speed0400_0600'                             '' 'Number_of_Particles_of_0.75mm_=<_Diameter_<_1mm_and_0.4_m/s_=<_Speed_<_0.6_m/s'
'numberParticlesDiameter0750_1000_Speed0600_0800'                             '' 'Number_of_Particles_of_0.75mm_=<_Diameter_<_1mm_and_0.6_m/s_=<_Speed_<_0.8_m/s'
'numberParticlesDiameter0750_1000_Speed0800_1000'                             '' 'Number_of_Particles_of_0.75mm_=<_Diameter_<_1mm_and_0.8_m/s_=<_Speed_<_1.0_m/s'
'numberParticlesDiameter0750_1000_Speed1000_1400'                             '' 'Number_of_Particles_of_0.75mm_=<_Diameter_<_1mm_and_1.0_m/s_=<_Speed_<_1.4_m/s'
'numberParticlesDiameter0750_1000_Speed1400_1800'                             '' 'Number_of_Particles_of_0.75mm_=<_Diameter_<_1mm_and_1.4_m/s_=<_Speed_<_1.8_m/s'
'numberParticlesDiameter0750_1000_Speed1800_2200'                             '' 'Number_of_Particles_of_0.75mm_=<_Diameter_<_1mm_and_1.8_m/s_=<_Speed_<_2.2_m/s'
'numberParticlesDiameter0750_1000_Speed2200_2600'                             '' 'Number_of_Particles_of_0.75mm_=<_Diameter_<_1mm_and_2.2_m/s_=<_Speed_<_2.6_m/s'
'numberParticlesDiameter0750_1000_Speed2600_3000'                             '' 'Number_of_Particles_of_0.75mm_=<_Diameter_<_1mm_and_2.6_m/s_=<_Speed_<_3.0_m/s'
'numberParticlesDiameter0750_1000_Speed3000_3400'                             '' 'Number_of_Particles_of_0.75mm_=<_Diameter_<_1mm_and_3.0_m/s_=<_Speed_<_3.4_m/s'
'numberParticlesDiameter0750_1000_Speed3400_4200'                             '' 'Number_of_Particles_of_0.75mm_=<_Diameter_<_1mm_and_3.4_m/s_=<_Speed_<_4.2_m/s'
'numberParticlesDiameter0750_1000_Speed4200_5000'                             '' 'Number_of_Particles_of_0.75mm_=<_Diameter_<_1mm_and_4.2_m/s_=<_Speed_<_5.0_m/s'
'numberParticlesDiameter0750_1000_Speed5000_5800'                             '' 'Number_of_Particles_of_0.75mm_=<_Diameter_<_1mm_and_5.0_m/s_=<_Speed_<_5.8_m/s'
'numberParticlesDiameter0750_1000_Speed5800_6600'                             '' 'Number_of_Particles_of_0.75mm_=<_Diameter_<_1mm_and_5.8_m/s_=<_Speed_<_6.6_m/s'
'numberParticlesDiameter0750_1000_Speed6600_7400'                             '' 'Number_of_Particles_of_0.75mm_=<_Diameter_<_1mm_and_6.6_m/s_=<_Speed_<_7.4_m/s'
'numberParticlesDiameter0750_1000_Speed7400_8200'                             '' 'Number_of_Particles_of_0.75mm_=<_Diameter_<_1mm_and_7.4_m/s_=<_Speed_<_8.2_m/s'
'numberParticlesDiameter0750_1000_Speed8200_9000'                             '' 'Number_of_Particles_of_0.75mm_=<_Diameter_<_1mm_and_8.2_m/s_=<_Speed_<_9.0_m/s'
'numberParticlesDiameter0750_1000_Speed9000_10000'                             ''  'Number_of_Particles_of_0.75mm_=<_Diameter_<_1mm_and_9.0_m/s_=<_Speed_<_10_m/s'
'numberParticlesDiameter0750_1000_Speed10000_20000'                             ''   'Number_of_Particles_of_0.75mm_=<_Diameter_<_1mm_and_10_m/s_=<_Speed_<_20_m/s'
'numberParticlesDiameter1000_1250_Speed0000_0200'                             ''  'Number_of_Particles_of_1mm_=<_Diameter_<_1.25mm_and_0__m/s_=<_Speed_<_0.2_m/s'
'numberParticlesDiameter1000_1250_Speed0200_0400'                             '' 'Number_of_Particles_of_1mm_=<_Diameter_<_1.25mm_and_0.2_m/s_=<_Speed_<_0.4_m/s'
'numberParticlesDiameter1000_1250_Speed0400_0600'                             '' 'Number_of_Particles_of_1mm_=<_Diameter_<_1.25mm_and_0.4_m/s_=<_Speed_<_0.6_m/s'
'numberParticlesDiameter1000_1250_Speed0600_0800'                             '' 'Number_of_Particles_of_1mm_=<_Diameter_<_1.25mm_and_0.6_m/s_=<_Speed_<_0.8_m/s'
'numberParticlesDiameter1000_1250_Speed0800_1000'                             '' 'Number_of_Particles_of_1mm_=<_Diameter_<_1.25mm_and_0.8_m/s_=<_Speed_<_1.0_m/s'
'numberParticlesDiameter1000_1250_Speed1000_1400'                             '' 'Number_of_Particles_of_1mm_=<_Diameter_<_1.25mm_and_1.0_m/s_=<_Speed_<_1.4_m/s'
'numberParticlesDiameter1000_1250_Speed1400_1800'                             '' 'Number_of_Particles_of_1mm_=<_Diameter_<_1.25mm_and_1.4_m/s_=<_Speed_<_1.8_m/s'
'numberParticlesDiameter1000_1250_Speed1800_2200'                             '' 'Number_of_Particles_of_1mm_=<_Diameter_<_1.25mm_and_1.8_m/s_=<_Speed_<_2.2_m/s'
'numberParticlesDiameter1000_1250_Speed2200_2600'                             '' 'Number_of_Particles_of_1mm_=<_Diameter_<_1.25mm_and_2.2_m/s_=<_Speed_<_2.6_m/s'
'numberParticlesDiameter1000_1250_Speed2600_3000'                             '' 'Number_of_Particles_of_1mm_=<_Diameter_<_1.25mm_and_2.6_m/s_=<_Speed_<_3.0_m/s'
'numberParticlesDiameter1000_1250_Speed3000_3400'                             '' 'Number_of_Particles_of_1mm_=<_Diameter_<_1.25mm_and_3.0_m/s_=<_Speed_<_3.4_m/s'
'numberParticlesDiameter1000_1250_Speed3400_4200'                             '' 'Number_of_Particles_of_1mm_=<_Diameter_<_1.25mm_and_3.4_m/s_=<_Speed_<_4.2_m/s'
'numberParticlesDiameter1000_1250_Speed4200_5000'                             '' 'Number_of_Particles_of_1mm_=<_Diameter_<_1.25mm_and_4.2_m/s_=<_Speed_<_5.0_m/s'
'numberParticlesDiameter1000_1250_Speed5000_5800'                             '' 'Number_of_Particles_of_1mm_=<_Diameter_<_1.25mm_and_5.0_m/s_=<_Speed_<_5.8_m/s'
'numberParticlesDiameter1000_1250_Speed5800_6600'                             '' 'Number_of_Particles_of_1mm_=<_Diameter_<_1.25mm_and_5.8_m/s_=<_Speed_<_6.6_m/s'
'numberParticlesDiameter1000_1250_Speed6600_7400'                             '' 'Number_of_Particles_of_1mm_=<_Diameter_<_1.25mm_and_6.6_m/s_=<_Speed_<_7.4_m/s'
'numberParticlesDiameter1000_1250_Speed7400_8200'                             '' 'Number_of_Particles_of_1mm_=<_Diameter_<_1.25mm_and_7.4_m/s_=<_Speed_<_8.2_m/s'
'numberParticlesDiameter1000_1250_Speed8200_9000'                             '' 'Number_of_Particles_of_1mm_=<_Diameter_<_1.25mm_and_8.2_m/s_=<_Speed_<_9.0_m/s'
'numberParticlesDiameter1000_1250_Speed9000_10000'                             ''  'Number_of_Particles_of_1mm_=<_Diameter_<_1.25mm_and_9.0_m/s_=<_Speed_<_10_m/s'
'numberParticlesDiameter1000_1250_Speed10000_20000'                             ''   'Number_of_Particles_of_1mm_=<_Diameter_<_1.25mm_and_10_m/s_=<_Speed_<_20_m/s'
'numberParticlesDiameter1250_1500_Speed0000_0200'                             '' 'Number_of_Particles_of_1.25mm_=<_Diameter_<_1.5mm_and_0__m/s_=<_Speed_<_0.2_m/s'
'numberParticlesDiameter1250_1500_Speed0200_0400'                             '' 'Number_of_Particles_of_1.25mm_=<_Diameter_<_1.5mm_and_0.2_m/s_=<_Speed_<_0.4_m/s'
'numberParticlesDiameter1250_1500_Speed0400_0600'                             '' 'Number_of_Particles_of_1.25mm_=<_Diameter_<_1.5mm_and_0.4_m/s_=<_Speed_<_0.6_m/s'
'numberParticlesDiameter1250_1500_Speed0600_0800'                             '' 'Number_of_Particles_of_1.25mm_=<_Diameter_<_1.5mm_and_0.6_m/s_=<_Speed_<_0.8_m/s'
'numberParticlesDiameter1250_1500_Speed0800_1000'                             '' 'Number_of_Particles_of_1.25mm_=<_Diameter_<_1.5mm_and_0.8_m/s_=<_Speed_<_1.0_m/s'
'numberParticlesDiameter1250_1500_Speed1000_1400'                             '' 'Number_of_Particles_of_1.25mm_=<_Diameter_<_1.5mm_and_1.0_m/s_=<_Speed_<_1.4_m/s'
'numberParticlesDiameter1250_1500_Speed1400_1800'                             '' 'Number_of_Particles_of_1.25mm_=<_Diameter_<_1.5mm_and_1.4_m/s_=<_Speed_<_1.8_m/s'
'numberParticlesDiameter1250_1500_Speed1800_2200'                             '' 'Number_of_Particles_of_1.25mm_=<_Diameter_<_1.5mm_and_1.8_m/s_=<_Speed_<_2.2_m/s'
'numberParticlesDiameter1250_1500_Speed2200_2600'                             '' 'Number_of_Particles_of_1.25mm_=<_Diameter_<_1.5mm_and_2.2_m/s_=<_Speed_<_2.6_m/s'
'numberParticlesDiameter1250_1500_Speed2600_3000'                             '' 'Number_of_Particles_of_1.25mm_=<_Diameter_<_1.5mm_and_2.6_m/s_=<_Speed_<_3.0_m/s'
'numberParticlesDiameter1250_1500_Speed3000_3400'                             '' 'Number_of_Particles_of_1.25mm_=<_Diameter_<_1.5mm_and_3.0_m/s_=<_Speed_<_3.4_m/s'
'numberParticlesDiameter1250_1500_Speed3400_4200'                             '' 'Number_of_Particles_of_1.25mm_=<_Diameter_<_1.5mm_and_3.4_m/s_=<_Speed_<_4.2_m/s'
'numberParticlesDiameter1250_1500_Speed4200_5000'                             '' 'Number_of_Particles_of_1.25mm_=<_Diameter_<_1.5mm_and_4.2_m/s_=<_Speed_<_5.0_m/s'
'numberParticlesDiameter1250_1500_Speed5000_5800'                             '' 'Number_of_Particles_of_1.25mm_=<_Diameter_<_1.5mm_and_5.0_m/s_=<_Speed_<_5.8_m/s'
'numberParticlesDiameter1250_1500_Speed5800_6600'                             '' 'Number_of_Particles_of_1.25mm_=<_Diameter_<_1.5mm_and_5.8_m/s_=<_Speed_<_6.6_m/s'
'numberParticlesDiameter1250_1500_Speed6600_7400'                             '' 'Number_of_Particles_of_1.25mm_=<_Diameter_<_1.5mm_and_6.6_m/s_=<_Speed_<_7.4_m/s'
'numberParticlesDiameter1250_1500_Speed7400_8200'                             '' 'Number_of_Particles_of_1.25mm_=<_Diameter_<_1.5mm_and_7.4_m/s_=<_Speed_<_8.2_m/s'
'numberParticlesDiameter1250_1500_Speed8200_9000'                             '' 'Number_of_Particles_of_1.25mm_=<_Diameter_<_1.5mm_and_8.2_m/s_=<_Speed_<_9.0_m/s'
'numberParticlesDiameter1250_1500_Speed9000_10000'                             '' 'Number_of_Particles_of_1.25mm_=<_Diameter_<_1.5mm_and_9.0_m/s_=<_Speed_<_10_m/s'
'numberParticlesDiameter1250_1500_Speed10000_20000'                             '' 'Number_of_Particles_of_1.25mm_=<_Diameter_<_1.5mm_and_10_m/s_=<_Speed_<_20_m/s'
'numberParticlesDiameter1500_1750_Speed0000_0200'                             '' 'Number_of_Particles_of_1.5mm_=<_Diameter_<_1.75mm_and_0__m/s_=<_Speed_<_0.2_m/s'
'numberParticlesDiameter1500_1750_Speed0200_0400'                             '' 'Number_of_Particles_of_1.5mm_=<_Diameter_<_1.75mm_and_0.2_m/s_=<_Speed_<_0.4_m/s'
'numberParticlesDiameter1500_1750_Speed0400_0600'                             '' 'Number_of_Particles_of_1.5mm_=<_Diameter_<_1.75mm_and_0.4_m/s_=<_Speed_<_0.6_m/s'
'numberParticlesDiameter1500_1750_Speed0600_0800'                             '' 'Number_of_Particles_of_1.5mm_=<_Diameter_<_1.75mm_and_0.6_m/s_=<_Speed_<_0.8_m/s'
'numberParticlesDiameter1500_1750_Speed0800_1000'                             '' 'Number_of_Particles_of_1.5mm_=<_Diameter_<_1.75mm_and_0.8_m/s_=<_Speed_<_1.0_m/s'
'numberParticlesDiameter1500_1750_Speed1000_1400'                             '' 'Number_of_Particles_of_1.5mm_=<_Diameter_<_1.75mm_and_1.0_m/s_=<_Speed_<_1.4_m/s'
'numberParticlesDiameter1500_1750_Speed1400_1800'                             '' 'Number_of_Particles_of_1.5mm_=<_Diameter_<_1.75mm_and_1.4_m/s_=<_Speed_<_1.8_m/s'
'numberParticlesDiameter1500_1750_Speed1800_2200'                             '' 'Number_of_Particles_of_1.5mm_=<_Diameter_<_1.75mm_and_1.8_m/s_=<_Speed_<_2.2_m/s'
'numberParticlesDiameter1500_1750_Speed2200_2600'                             '' 'Number_of_Particles_of_1.5mm_=<_Diameter_<_1.75mm_and_2.2_m/s_=<_Speed_<_2.6_m/s'
'numberParticlesDiameter1500_1750_Speed2600_3000'                             '' 'Number_of_Particles_of_1.5mm_=<_Diameter_<_1.75mm_and_2.6_m/s_=<_Speed_<_3.0_m/s'
'numberParticlesDiameter1500_1750_Speed3000_3400'                             '' 'Number_of_Particles_of_1.5mm_=<_Diameter_<_1.75mm_and_3.0_m/s_=<_Speed_<_3.4_m/s'
'numberParticlesDiameter1500_1750_Speed3400_4200'                             '' 'Number_of_Particles_of_1.5mm_=<_Diameter_<_1.75mm_and_3.4_m/s_=<_Speed_<_4.2_m/s'
'numberParticlesDiameter1500_1750_Speed4200_5000'                             '' 'Number_of_Particles_of_1.5mm_=<_Diameter_<_1.75mm_and_4.2_m/s_=<_Speed_<_5.0_m/s'
'numberParticlesDiameter1500_1750_Speed5000_5800'                             '' 'Number_of_Particles_of_1.5mm_=<_Diameter_<_1.75mm_and_5.0_m/s_=<_Speed_<_5.8_m/s'
'numberParticlesDiameter1500_1750_Speed5800_6600'                             '' 'Number_of_Particles_of_1.5mm_=<_Diameter_<_1.75mm_and_5.8_m/s_=<_Speed_<_6.6_m/s'
'numberParticlesDiameter1500_1750_Speed6600_7400'                             '' 'Number_of_Particles_of_1.5mm_=<_Diameter_<_1.75mm_and_6.6_m/s_=<_Speed_<_7.4_m/s'
'numberParticlesDiameter1500_1750_Speed7400_8200'                             '' 'Number_of_Particles_of_1.5mm_=<_Diameter_<_1.75mm_and_7.4_m/s_=<_Speed_<_8.2_m/s'
'numberParticlesDiameter1500_1750_Speed8200_9000'                             '' 'Number_of_Particles_of_1.5mm_=<_Diameter_<_1.75mm_and_8.2_m/s_=<_Speed_<_9.0_m/s'
'numberParticlesDiameter1500_1750_Speed9000_10000'                             '' 'Number_of_Particles_of_1.5mm_=<_Diameter_<_1.75mm_and_9.0_m/s_=<_Speed_<_10_m/s'
'numberParticlesDiameter1500_1750_Speed10000_20000'                             '' 'Number_of_Particles_of_1.5mm_=<_Diameter_<_1.75mm_and_10_m/s_=<_Speed_<_20_m/s'
'numberParticlesDiameter1750_2000_Speed0000_0200'                             ''  'Number_of_Particles_of_1.75mm_=<_Diameter_<_2mm_and_0__m/s_=<_Speed_<_0.2_m/s'
'numberParticlesDiameter1750_2000_Speed0200_0400'                             '' 'Number_of_Particles_of_1.75mm_=<_Diameter_<_2mm_and_0.2_m/s_=<_Speed_<_0.4_m/s'
'numberParticlesDiameter1750_2000_Speed0400_0600'                             '' 'Number_of_Particles_of_1.75mm_=<_Diameter_<_2mm_and_0.4_m/s_=<_Speed_<_0.6_m/s'
'numberParticlesDiameter1750_2000_Speed0600_0800'                             '' 'Number_of_Particles_of_1.75mm_=<_Diameter_<_2mm_and_0.6_m/s_=<_Speed_<_0.8_m/s'
'numberParticlesDiameter1750_2000_Speed0800_1000'                             '' 'Number_of_Particles_of_1.75mm_=<_Diameter_<_2mm_and_0.8_m/s_=<_Speed_<_1.0_m/s'
'numberParticlesDiameter1750_2000_Speed1000_1400'                             '' 'Number_of_Particles_of_1.75mm_=<_Diameter_<_2mm_and_1.0_m/s_=<_Speed_<_1.4_m/s'
'numberParticlesDiameter1750_2000_Speed1400_1800'                             '' 'Number_of_Particles_of_1.75mm_=<_Diameter_<_2mm_and_1.4_m/s_=<_Speed_<_1.8_m/s'
'numberParticlesDiameter1750_2000_Speed1800_2200'                             '' 'Number_of_Particles_of_1.75mm_=<_Diameter_<_2mm_and_1.8_m/s_=<_Speed_<_2.2_m/s'
'numberParticlesDiameter1750_2000_Speed2200_2600'                             '' 'Number_of_Particles_of_1.75mm_=<_Diameter_<_2mm_and_2.2_m/s_=<_Speed_<_2.6_m/s'
'numberParticlesDiameter1750_2000_Speed2600_3000'                             '' 'Number_of_Particles_of_1.75mm_=<_Diameter_<_2mm_and_2.6_m/s_=<_Speed_<_3.0_m/s'
'numberParticlesDiameter1750_2000_Speed3000_3400'                             '' 'Number_of_Particles_of_1.75mm_=<_Diameter_<_2mm_and_3.0_m/s_=<_Speed_<_3.4_m/s'
'numberParticlesDiameter1750_2000_Speed3400_4200'                             '' 'Number_of_Particles_of_1.75mm_=<_Diameter_<_2mm_and_3.4_m/s_=<_Speed_<_4.2_m/s'
'numberParticlesDiameter1750_2000_Speed4200_5000'                             '' 'Number_of_Particles_of_1.75mm_=<_Diameter_<_2mm_and_4.2_m/s_=<_Speed_<_5.0_m/s'
'numberParticlesDiameter1750_2000_Speed5000_5800'                             '' 'Number_of_Particles_of_1.75mm_=<_Diameter_<_2mm_and_5.0_m/s_=<_Speed_<_5.8_m/s'
'numberParticlesDiameter1750_2000_Speed5800_6600'                             '' 'Number_of_Particles_of_1.75mm_=<_Diameter_<_2mm_and_5.8_m/s_=<_Speed_<_6.6_m/s'
'numberParticlesDiameter1750_2000_Speed6600_7400'                             '' 'Number_of_Particles_of_1.75mm_=<_Diameter_<_2mm_and_6.6_m/s_=<_Speed_<_7.4_m/s'
'numberParticlesDiameter1750_2000_Speed7400_8200'                             '' 'Number_of_Particles_of_1.75mm_=<_Diameter_<_2mm_and_7.4_m/s_=<_Speed_<_8.2_m/s'
'numberParticlesDiameter1750_2000_Speed8200_9000'                             '' 'Number_of_Particles_of_1.75mm_=<_Diameter_<_2mm_and_8.2_m/s_=<_Speed_<_9.0_m/s'
'numberParticlesDiameter1750_2000_Speed9000_10000'                             ''  'Number_of_Particles_of_1.75mm_=<_Diameter_<_2mm_and_9.0_m/s_=<_Speed_<_10_m/s'
'numberParticlesDiameter1750_2000_Speed10000_20000'                             ''   'Number_of_Particles_of_1.75mm_=<_Diameter_<_2mm_and_10_m/s_=<_Speed_<_20_m/s'
'numberParticlesDiameter2000_2500_Speed0000_0200'                             ''   'Number_of_Particles_of_2mm_=<_Diameter_<_2.5mm_and_0__m/s_=<_Speed_<_0.2_m/s'
'numberParticlesDiameter2000_2500_Speed0200_0400'                             ''  'Number_of_Particles_of_2mm_=<_Diameter_<_2.5mm_and_0.2_m/s_=<_Speed_<_0.4_m/s'
'numberParticlesDiameter2000_2500_Speed0400_0600'                             ''  'Number_of_Particles_of_2mm_=<_Diameter_<_2.5mm_and_0.4_m/s_=<_Speed_<_0.6_m/s'
'numberParticlesDiameter2000_2500_Speed0600_0800'                             ''  'Number_of_Particles_of_2mm_=<_Diameter_<_2.5mm_and_0.6_m/s_=<_Speed_<_0.8_m/s'
'numberParticlesDiameter2000_2500_Speed0800_1000'                             ''  'Number_of_Particles_of_2mm_=<_Diameter_<_2.5mm_and_0.8_m/s_=<_Speed_<_1.0_m/s'
'numberParticlesDiameter2000_2500_Speed1000_1400'                             ''  'Number_of_Particles_of_2mm_=<_Diameter_<_2.5mm_and_1.0_m/s_=<_Speed_<_1.4_m/s'
'numberParticlesDiameter2000_2500_Speed1400_1800'                             ''  'Number_of_Particles_of_2mm_=<_Diameter_<_2.5mm_and_1.4_m/s_=<_Speed_<_1.8_m/s'
'numberParticlesDiameter2000_2500_Speed1800_2200'                             ''  'Number_of_Particles_of_2mm_=<_Diameter_<_2.5mm_and_1.8_m/s_=<_Speed_<_2.2_m/s'
'numberParticlesDiameter2000_2500_Speed2200_2600'                             ''  'Number_of_Particles_of_2mm_=<_Diameter_<_2.5mm_and_2.2_m/s_=<_Speed_<_2.6_m/s'
'numberParticlesDiameter2000_2500_Speed2600_3000'                             ''  'Number_of_Particles_of_2mm_=<_Diameter_<_2.5mm_and_2.6_m/s_=<_Speed_<_3.0_m/s'
'numberParticlesDiameter2000_2500_Speed3000_3400'                             ''  'Number_of_Particles_of_2mm_=<_Diameter_<_2.5mm_and_3.0_m/s_=<_Speed_<_3.4_m/s'
'numberParticlesDiameter2000_2500_Speed3400_4200'                             ''  'Number_of_Particles_of_2mm_=<_Diameter_<_2.5mm_and_3.4_m/s_=<_Speed_<_4.2_m/s'
'numberParticlesDiameter2000_2500_Speed4200_5000'                             ''  'Number_of_Particles_of_2mm_=<_Diameter_<_2.5mm_and_4.2_m/s_=<_Speed_<_5.0_m/s'
'numberParticlesDiameter2000_2500_Speed5000_5800'                             ''  'Number_of_Particles_of_2mm_=<_Diameter_<_2.5mm_and_5.0_m/s_=<_Speed_<_5.8_m/s'
'numberParticlesDiameter2000_2500_Speed5800_6600'                             ''  'Number_of_Particles_of_2mm_=<_Diameter_<_2.5mm_and_5.8_m/s_=<_Speed_<_6.6_m/s'
'numberParticlesDiameter2000_2500_Speed6600_7400'                             ''  'Number_of_Particles_of_2mm_=<_Diameter_<_2.5mm_and_6.6_m/s_=<_Speed_<_7.4_m/s'
'numberParticlesDiameter2000_2500_Speed7400_8200'                             ''  'Number_of_Particles_of_2mm_=<_Diameter_<_2.5mm_and_7.4_m/s_=<_Speed_<_8.2_m/s'
'numberParticlesDiameter2000_2500_Speed8200_9000'                             ''  'Number_of_Particles_of_2mm_=<_Diameter_<_2.5mm_and_8.2_m/s_=<_Speed_<_9.0_m/s'
'numberParticlesDiameter2000_2500_Speed9000_10000'                             ''   'Number_of_Particles_of_2mm_=<_Diameter_<_2.5mm_and_9.0_m/s_=<_Speed_<_10_m/s'
'numberParticlesDiameter2000_2500_Speed10000_20000'                             ''    'Number_of_Particles_of_2mm_=<_Diameter_<_2.5mm_and_10_m/s_=<_Speed_<_20_m/s'
'numberParticlesDiameter2500_3000_Speed0000_0200'                             ''   'Number_of_Particles_of_2.5mm_=<_Diameter_<_3mm_and_0__m/s_=<_Speed_<_0.2_m/s'
'numberParticlesDiameter2500_3000_Speed0200_0400'                             ''  'Number_of_Particles_of_2.5mm_=<_Diameter_<_3mm_and_0.2_m/s_=<_Speed_<_0.4_m/s'
'numberParticlesDiameter2500_3000_Speed0400_0600'                             ''  'Number_of_Particles_of_2.5mm_=<_Diameter_<_3mm_and_0.4_m/s_=<_Speed_<_0.6_m/s'
'numberParticlesDiameter2500_3000_Speed0600_0800'                             ''  'Number_of_Particles_of_2.5mm_=<_Diameter_<_3mm_and_0.6_m/s_=<_Speed_<_0.8_m/s'
'numberParticlesDiameter2500_3000_Speed0800_1000'                             ''  'Number_of_Particles_of_2.5mm_=<_Diameter_<_3mm_and_0.8_m/s_=<_Speed_<_1.0_m/s'
'numberParticlesDiameter2500_3000_Speed1000_1400'                             ''  'Number_of_Particles_of_2.5mm_=<_Diameter_<_3mm_and_1.0_m/s_=<_Speed_<_1.4_m/s'
'numberParticlesDiameter2500_3000_Speed1400_1800'                             ''  'Number_of_Particles_of_2.5mm_=<_Diameter_<_3mm_and_1.4_m/s_=<_Speed_<_1.8_m/s'
'numberParticlesDiameter2500_3000_Speed1800_2200'                             ''  'Number_of_Particles_of_2.5mm_=<_Diameter_<_3mm_and_1.8_m/s_=<_Speed_<_2.2_m/s'
'numberParticlesDiameter2500_3000_Speed2200_2600'                             ''  'Number_of_Particles_of_2.5mm_=<_Diameter_<_3mm_and_2.2_m/s_=<_Speed_<_2.6_m/s'
'numberParticlesDiameter2500_3000_Speed2600_3000'                             ''  'Number_of_Particles_of_2.5mm_=<_Diameter_<_3mm_and_2.6_m/s_=<_Speed_<_3.0_m/s'
'numberParticlesDiameter2500_3000_Speed3000_3400'                             ''  'Number_of_Particles_of_2.5mm_=<_Diameter_<_3mm_and_3.0_m/s_=<_Speed_<_3.4_m/s'
'numberParticlesDiameter2500_3000_Speed3400_4200'                             ''  'Number_of_Particles_of_2.5mm_=<_Diameter_<_3mm_and_3.4_m/s_=<_Speed_<_4.2_m/s'
'numberParticlesDiameter2500_3000_Speed4200_5000'                             ''  'Number_of_Particles_of_2.5mm_=<_Diameter_<_3mm_and_4.2_m/s_=<_Speed_<_5.0_m/s'
'numberParticlesDiameter2500_3000_Speed5000_5800'                             ''  'Number_of_Particles_of_2.5mm_=<_Diameter_<_3mm_and_5.0_m/s_=<_Speed_<_5.8_m/s'
'numberParticlesDiameter2500_3000_Speed5800_6600'                             ''  'Number_of_Particles_of_2.5mm_=<_Diameter_<_3mm_and_5.8_m/s_=<_Speed_<_6.6_m/s'
'numberParticlesDiameter2500_3000_Speed6600_7400'                             ''  'Number_of_Particles_of_2.5mm_=<_Diameter_<_3mm_and_6.6_m/s_=<_Speed_<_7.4_m/s'
'numberParticlesDiameter2500_3000_Speed7400_8200'                             ''  'Number_of_Particles_of_2.5mm_=<_Diameter_<_3mm_and_7.4_m/s_=<_Speed_<_8.2_m/s'
'numberParticlesDiameter2500_3000_Speed8200_9000'                             ''  'Number_of_Particles_of_2.5mm_=<_Diameter_<_3mm_and_8.2_m/s_=<_Speed_<_9.0_m/s'
'numberParticlesDiameter2500_3000_Speed9000_10000'                             ''   'Number_of_Particles_of_2.5mm_=<_Diameter_<_3mm_and_9.0_m/s_=<_Speed_<_10_m/s'
'numberParticlesDiameter2500_3000_Speed10000_20000'                             ''    'Number_of_Particles_of_2.5mm_=<_Diameter_<_3mm_and_10_m/s_=<_Speed_<_20_m/s'
'numberParticlesDiameter3000_3500_Speed0000_0200'                             ''   'Number_of_Particles_of_3mm_=<_Diameter_<_3.5mm_and_0__m/s_=<_Speed_<_0.2_m/s'
'numberParticlesDiameter3000_3500_Speed0200_0400'                             ''  'Number_of_Particles_of_3mm_=<_Diameter_<_3.5mm_and_0.2_m/s_=<_Speed_<_0.4_m/s'
'numberParticlesDiameter3000_3500_Speed0400_0600'                             ''  'Number_of_Particles_of_3mm_=<_Diameter_<_3.5mm_and_0.4_m/s_=<_Speed_<_0.6_m/s'
'numberParticlesDiameter3000_3500_Speed0600_0800'                             ''  'Number_of_Particles_of_3mm_=<_Diameter_<_3.5mm_and_0.6_m/s_=<_Speed_<_0.8_m/s'
'numberParticlesDiameter3000_3500_Speed0800_1000'                             ''  'Number_of_Particles_of_3mm_=<_Diameter_<_3.5mm_and_0.8_m/s_=<_Speed_<_1.0_m/s'
'numberParticlesDiameter3000_3500_Speed1000_1400'                             ''  'Number_of_Particles_of_3mm_=<_Diameter_<_3.5mm_and_1.0_m/s_=<_Speed_<_1.4_m/s'
'numberParticlesDiameter3000_3500_Speed1400_1800'                             ''  'Number_of_Particles_of_3mm_=<_Diameter_<_3.5mm_and_1.4_m/s_=<_Speed_<_1.8_m/s'
'numberParticlesDiameter3000_3500_Speed1800_2200'                             ''  'Number_of_Particles_of_3mm_=<_Diameter_<_3.5mm_and_1.8_m/s_=<_Speed_<_2.2_m/s'
'numberParticlesDiameter3000_3500_Speed2200_2600'                             ''  'Number_of_Particles_of_3mm_=<_Diameter_<_3.5mm_and_2.2_m/s_=<_Speed_<_2.6_m/s'
'numberParticlesDiameter3000_3500_Speed2600_3000'                             ''  'Number_of_Particles_of_3mm_=<_Diameter_<_3.5mm_and_2.6_m/s_=<_Speed_<_3.0_m/s'
'numberParticlesDiameter3000_3500_Speed3000_3400'                             ''  'Number_of_Particles_of_3mm_=<_Diameter_<_3.5mm_and_3.0_m/s_=<_Speed_<_3.4_m/s'
'numberParticlesDiameter3000_3500_Speed3400_4200'                             ''  'Number_of_Particles_of_3mm_=<_Diameter_<_3.5mm_and_3.4_m/s_=<_Speed_<_4.2_m/s'
'numberParticlesDiameter3000_3500_Speed4200_5000'                             ''  'Number_of_Particles_of_3mm_=<_Diameter_<_3.5mm_and_4.2_m/s_=<_Speed_<_5.0_m/s'
'numberParticlesDiameter3000_3500_Speed5000_5800'                             ''  'Number_of_Particles_of_3mm_=<_Diameter_<_3.5mm_and_5.0_m/s_=<_Speed_<_5.8_m/s'
'numberParticlesDiameter3000_3500_Speed5800_6600'                             ''  'Number_of_Particles_of_3mm_=<_Diameter_<_3.5mm_and_5.8_m/s_=<_Speed_<_6.6_m/s'
'numberParticlesDiameter3000_3500_Speed6600_7400'                             ''  'Number_of_Particles_of_3mm_=<_Diameter_<_3.5mm_and_6.6_m/s_=<_Speed_<_7.4_m/s'
'numberParticlesDiameter3000_3500_Speed7400_8200'                             ''  'Number_of_Particles_of_3mm_=<_Diameter_<_3.5mm_and_7.4_m/s_=<_Speed_<_8.2_m/s'
'numberParticlesDiameter3000_3500_Speed8200_9000'                             ''  'Number_of_Particles_of_3mm_=<_Diameter_<_3.5mm_and_8.2_m/s_=<_Speed_<_9.0_m/s'
'numberParticlesDiameter3000_3500_Speed9000_10000'                             ''   'Number_of_Particles_of_3mm_=<_Diameter_<_3.5mm_and_9.0_m/s_=<_Speed_<_10_m/s'
'numberParticlesDiameter3000_3500_Speed10000_20000'                             ''    'Number_of_Particles_of_3mm_=<_Diameter_<_3.5mm_and_10_m/s_=<_Speed_<_20_m/s'
'numberParticlesDiameter3500_4000_Speed0000_0200'                             ''   'Number_of_Particles_of_3.5mm_=<_Diameter_<_4mm_and_0__m/s_=<_Speed_<_0.2_m/s'
'numberParticlesDiameter3500_4000_Speed0200_0400'                             ''  'Number_of_Particles_of_3.5mm_=<_Diameter_<_4mm_and_0.2_m/s_=<_Speed_<_0.4_m/s'
'numberParticlesDiameter3500_4000_Speed0400_0600'                             ''  'Number_of_Particles_of_3.5mm_=<_Diameter_<_4mm_and_0.4_m/s_=<_Speed_<_0.6_m/s'
'numberParticlesDiameter3500_4000_Speed0600_0800'                             ''  'Number_of_Particles_of_3.5mm_=<_Diameter_<_4mm_and_0.6_m/s_=<_Speed_<_0.8_m/s'
'numberParticlesDiameter3500_4000_Speed0800_1000'                             ''  'Number_of_Particles_of_3.5mm_=<_Diameter_<_4mm_and_0.8_m/s_=<_Speed_<_1.0_m/s'
'numberParticlesDiameter3500_4000_Speed1000_1400'                             ''  'Number_of_Particles_of_3.5mm_=<_Diameter_<_4mm_and_1.0_m/s_=<_Speed_<_1.4_m/s'
'numberParticlesDiameter3500_4000_Speed1400_1800'                             ''  'Number_of_Particles_of_3.5mm_=<_Diameter_<_4mm_and_1.4_m/s_=<_Speed_<_1.8_m/s'
'numberParticlesDiameter3500_4000_Speed1800_2200'                             ''  'Number_of_Particles_of_3.5mm_=<_Diameter_<_4mm_and_1.8_m/s_=<_Speed_<_2.2_m/s'
'numberParticlesDiameter3500_4000_Speed2200_2600'                             ''  'Number_of_Particles_of_3.5mm_=<_Diameter_<_4mm_and_2.2_m/s_=<_Speed_<_2.6_m/s'
'numberParticlesDiameter3500_4000_Speed2600_3000'                             ''  'Number_of_Particles_of_3.5mm_=<_Diameter_<_4mm_and_2.6_m/s_=<_Speed_<_3.0_m/s'
'numberParticlesDiameter3500_4000_Speed3000_3400'                             ''  'Number_of_Particles_of_3.5mm_=<_Diameter_<_4mm_and_3.0_m/s_=<_Speed_<_3.4_m/s'
'numberParticlesDiameter3500_4000_Speed3400_4200'                             ''  'Number_of_Particles_of_3.5mm_=<_Diameter_<_4mm_and_3.4_m/s_=<_Speed_<_4.2_m/s'
'numberParticlesDiameter3500_4000_Speed4200_5000'                             ''  'Number_of_Particles_of_3.5mm_=<_Diameter_<_4mm_and_4.2_m/s_=<_Speed_<_5.0_m/s'
'numberParticlesDiameter3500_4000_Speed5000_5800'                             ''  'Number_of_Particles_of_3.5mm_=<_Diameter_<_4mm_and_5.0_m/s_=<_Speed_<_5.8_m/s'
'numberParticlesDiameter3500_4000_Speed5800_6600'                             ''  'Number_of_Particles_of_3.5mm_=<_Diameter_<_4mm_and_5.8_m/s_=<_Speed_<_6.6_m/s'
'numberParticlesDiameter3500_4000_Speed6600_7400'                             ''  'Number_of_Particles_of_3.5mm_=<_Diameter_<_4mm_and_6.6_m/s_=<_Speed_<_7.4_m/s'
'numberParticlesDiameter3500_4000_Speed7400_8200'                             ''  'Number_of_Particles_of_3.5mm_=<_Diameter_<_4mm_and_7.4_m/s_=<_Speed_<_8.2_m/s'
'numberParticlesDiameter3500_4000_Speed8200_9000'                             ''  'Number_of_Particles_of_3.5mm_=<_Diameter_<_4mm_and_8.2_m/s_=<_Speed_<_9.0_m/s'
'numberParticlesDiameter3500_4000_Speed9000_10000'                             ''   'Number_of_Particles_of_3.5mm_=<_Diameter_<_4mm_and_9.0_m/s_=<_Speed_<_10_m/s'
'numberParticlesDiameter3500_4000_Speed10000_20000'                             ''    'Number_of_Particles_of_3.5mm_=<_Diameter_<_4mm_and_10_m/s_=<_Speed_<_20_m/s'
'numberParticlesDiameter4000_4500_Speed0000_0200'                             ''   'Number_of_Particles_of_4mm_=<_Diameter_<_4.5mm_and_0__m/s_=<_Speed_<_0.2_m/s'
'numberParticlesDiameter4000_4500_Speed0200_0400'                             ''  'Number_of_Particles_of_4mm_=<_Diameter_<_4.5mm_and_0.2_m/s_=<_Speed_<_0.4_m/s'
'numberParticlesDiameter4000_4500_Speed0400_0600'                             ''  'Number_of_Particles_of_4mm_=<_Diameter_<_4.5mm_and_0.4_m/s_=<_Speed_<_0.6_m/s'
'numberParticlesDiameter4000_4500_Speed0600_0800'                             ''  'Number_of_Particles_of_4mm_=<_Diameter_<_4.5mm_and_0.6_m/s_=<_Speed_<_0.8_m/s'
'numberParticlesDiameter4000_4500_Speed0800_1000'                             ''  'Number_of_Particles_of_4mm_=<_Diameter_<_4.5mm_and_0.8_m/s_=<_Speed_<_1.0_m/s'
'numberParticlesDiameter4000_4500_Speed1000_1400'                             ''  'Number_of_Particles_of_4mm_=<_Diameter_<_4.5mm_and_1.0_m/s_=<_Speed_<_1.4_m/s'
'numberParticlesDiameter4000_4500_Speed1400_1800'                             ''  'Number_of_Particles_of_4mm_=<_Diameter_<_4.5mm_and_1.4_m/s_=<_Speed_<_1.8_m/s'
'numberParticlesDiameter4000_4500_Speed1800_2200'                             ''  'Number_of_Particles_of_4mm_=<_Diameter_<_4.5mm_and_1.8_m/s_=<_Speed_<_2.2_m/s'
'numberParticlesDiameter4000_4500_Speed2200_2600'                             ''  'Number_of_Particles_of_4mm_=<_Diameter_<_4.5mm_and_2.2_m/s_=<_Speed_<_2.6_m/s'
'numberParticlesDiameter4000_4500_Speed2600_3000'                             ''  'Number_of_Particles_of_4mm_=<_Diameter_<_4.5mm_and_2.6_m/s_=<_Speed_<_3.0_m/s'
'numberParticlesDiameter4000_4500_Speed3000_3400'                             ''  'Number_of_Particles_of_4mm_=<_Diameter_<_4.5mm_and_3.0_m/s_=<_Speed_<_3.4_m/s'
'numberParticlesDiameter4000_4500_Speed3400_4200'                             ''  'Number_of_Particles_of_4mm_=<_Diameter_<_4.5mm_and_3.4_m/s_=<_Speed_<_4.2_m/s'
'numberParticlesDiameter4000_4500_Speed4200_5000'                             ''  'Number_of_Particles_of_4mm_=<_Diameter_<_4.5mm_and_4.2_m/s_=<_Speed_<_5.0_m/s'
'numberParticlesDiameter4000_4500_Speed5000_5800'                             ''  'Number_of_Particles_of_4mm_=<_Diameter_<_4.5mm_and_5.0_m/s_=<_Speed_<_5.8_m/s'
'numberParticlesDiameter4000_4500_Speed5800_6600'                             ''  'Number_of_Particles_of_4mm_=<_Diameter_<_4.5mm_and_5.8_m/s_=<_Speed_<_6.6_m/s'
'numberParticlesDiameter4000_4500_Speed6600_7400'                             ''  'Number_of_Particles_of_4mm_=<_Diameter_<_4.5mm_and_6.6_m/s_=<_Speed_<_7.4_m/s'
'numberParticlesDiameter4000_4500_Speed7400_8200'                             ''  'Number_of_Particles_of_4mm_=<_Diameter_<_4.5mm_and_7.4_m/s_=<_Speed_<_8.2_m/s'
'numberParticlesDiameter4000_4500_Speed8200_9000'                             ''  'Number_of_Particles_of_4mm_=<_Diameter_<_4.5mm_and_8.2_m/s_=<_Speed_<_9.0_m/s'
'numberParticlesDiameter4000_4500_Speed9000_10000'                             ''   'Number_of_Particles_of_4mm_=<_Diameter_<_4.5mm_and_9.0_m/s_=<_Speed_<_10_m/s'
'numberParticlesDiameter4000_4500_Speed10000_20000'                             ''    'Number_of_Particles_of_4mm_=<_Diameter_<_4.5mm_and_10_m/s_=<_Speed_<_20_m/s'
'numberParticlesDiameter4500_5000_Speed0000_0200'                             ''   'Number_of_Particles_of_4.5mm_=<_Diameter_<_5mm_and_0__m/s_=<_Speed_<_0.2_m/s'
'numberParticlesDiameter4500_5000_Speed0200_0400'                             ''  'Number_of_Particles_of_4.5mm_=<_Diameter_<_5mm_and_0.2_m/s_=<_Speed_<_0.4_m/s'
'numberParticlesDiameter4500_5000_Speed0400_0600'                             ''  'Number_of_Particles_of_4.5mm_=<_Diameter_<_5mm_and_0.4_m/s_=<_Speed_<_0.6_m/s'
'numberParticlesDiameter4500_5000_Speed0600_0800'                             ''  'Number_of_Particles_of_4.5mm_=<_Diameter_<_5mm_and_0.6_m/s_=<_Speed_<_0.8_m/s'
'numberParticlesDiameter4500_5000_Speed0800_1000'                             ''  'Number_of_Particles_of_4.5mm_=<_Diameter_<_5mm_and_0.8_m/s_=<_Speed_<_1.0_m/s'
'numberParticlesDiameter4500_5000_Speed1000_1400'                             ''  'Number_of_Particles_of_4.5mm_=<_Diameter_<_5mm_and_1.0_m/s_=<_Speed_<_1.4_m/s'
'numberParticlesDiameter4500_5000_Speed1400_1800'                             ''  'Number_of_Particles_of_4.5mm_=<_Diameter_<_5mm_and_1.4_m/s_=<_Speed_<_1.8_m/s'
'numberParticlesDiameter4500_5000_Speed1800_2200'                             ''  'Number_of_Particles_of_4.5mm_=<_Diameter_<_5mm_and_1.8_m/s_=<_Speed_<_2.2_m/s'
'numberParticlesDiameter4500_5000_Speed2200_2600'                             ''  'Number_of_Particles_of_4.5mm_=<_Diameter_<_5mm_and_2.2_m/s_=<_Speed_<_2.6_m/s'
'numberParticlesDiameter4500_5000_Speed2600_3000'                             ''  'Number_of_Particles_of_4.5mm_=<_Diameter_<_5mm_and_2.6_m/s_=<_Speed_<_3.0_m/s'
'numberParticlesDiameter4500_5000_Speed3000_3400'                             ''  'Number_of_Particles_of_4.5mm_=<_Diameter_<_5mm_and_3.0_m/s_=<_Speed_<_3.4_m/s'
'numberParticlesDiameter4500_5000_Speed3400_4200'                             ''  'Number_of_Particles_of_4.5mm_=<_Diameter_<_5mm_and_3.4_m/s_=<_Speed_<_4.2_m/s'
'numberParticlesDiameter4500_5000_Speed4200_5000'                             ''  'Number_of_Particles_of_4.5mm_=<_Diameter_<_5mm_and_4.2_m/s_=<_Speed_<_5.0_m/s'
'numberParticlesDiameter4500_5000_Speed5000_5800'                             ''  'Number_of_Particles_of_4.5mm_=<_Diameter_<_5mm_and_5.0_m/s_=<_Speed_<_5.8_m/s'
'numberParticlesDiameter4500_5000_Speed5800_6600'                             ''  'Number_of_Particles_of_4.5mm_=<_Diameter_<_5mm_and_5.8_m/s_=<_Speed_<_6.6_m/s'
'numberParticlesDiameter4500_5000_Speed6600_7400'                             ''  'Number_of_Particles_of_4.5mm_=<_Diameter_<_5mm_and_6.6_m/s_=<_Speed_<_7.4_m/s'
'numberParticlesDiameter4500_5000_Speed7400_8200'                             ''  'Number_of_Particles_of_4.5mm_=<_Diameter_<_5mm_and_7.4_m/s_=<_Speed_<_8.2_m/s'
'numberParticlesDiameter4500_5000_Speed8200_9000'                             ''  'Number_of_Particles_of_4.5mm_=<_Diameter_<_5mm_and_8.2_m/s_=<_Speed_<_9.0_m/s'
'numberParticlesDiameter4500_5000_Speed9000_10000'                             ''   'Number_of_Particles_of_4.5mm_=<_Diameter_<_5mm_and_9.0_m/s_=<_Speed_<_10_m/s'
'numberParticlesDiameter4500_5000_Speed10000_20000'                             ''    'Number_of_Particles_of_4.5mm_=<_Diameter_<_5mm_and_10_m/s_=<_Speed_<_20_m/s'
'numberParticlesDiameter5000_5500_Speed0000_0200'                             ''   'Number_of_Particles_of_5mm_=<_Diameter_<_5.5mm_and_0__m/s_=<_Speed_<_0.2_m/s'
'numberParticlesDiameter5000_5500_Speed0200_0400'                             ''  'Number_of_Particles_of_5mm_=<_Diameter_<_5.5mm_and_0.2_m/s_=<_Speed_<_0.4_m/s'
'numberParticlesDiameter5000_5500_Speed0400_0600'                             ''  'Number_of_Particles_of_5mm_=<_Diameter_<_5.5mm_and_0.4_m/s_=<_Speed_<_0.6_m/s'
'numberParticlesDiameter5000_5500_Speed0600_0800'                             ''  'Number_of_Particles_of_5mm_=<_Diameter_<_5.5mm_and_0.6_m/s_=<_Speed_<_0.8_m/s'
'numberParticlesDiameter5000_5500_Speed0800_1000'                             ''  'Number_of_Particles_of_5mm_=<_Diameter_<_5.5mm_and_0.8_m/s_=<_Speed_<_1.0_m/s'
'numberParticlesDiameter5000_5500_Speed1000_1400'                             ''  'Number_of_Particles_of_5mm_=<_Diameter_<_5.5mm_and_1.0_m/s_=<_Speed_<_1.4_m/s'
'numberParticlesDiameter5000_5500_Speed1400_1800'                             ''  'Number_of_Particles_of_5mm_=<_Diameter_<_5.5mm_and_1.4_m/s_=<_Speed_<_1.8_m/s'
'numberParticlesDiameter5000_5500_Speed1800_2200'                             ''  'Number_of_Particles_of_5mm_=<_Diameter_<_5.5mm_and_1.8_m/s_=<_Speed_<_2.2_m/s'
'numberParticlesDiameter5000_5500_Speed2200_2600'                             ''  'Number_of_Particles_of_5mm_=<_Diameter_<_5.5mm_and_2.2_m/s_=<_Speed_<_2.6_m/s'
'numberParticlesDiameter5000_5500_Speed2600_3000'                             ''  'Number_of_Particles_of_5mm_=<_Diameter_<_5.5mm_and_2.6_m/s_=<_Speed_<_3.0_m/s'
'numberParticlesDiameter5000_5500_Speed3000_3400'                             ''  'Number_of_Particles_of_5mm_=<_Diameter_<_5.5mm_and_3.0_m/s_=<_Speed_<_3.4_m/s'
'numberParticlesDiameter5000_5500_Speed3400_4200'                             ''  'Number_of_Particles_of_5mm_=<_Diameter_<_5.5mm_and_3.4_m/s_=<_Speed_<_4.2_m/s'
'numberParticlesDiameter5000_5500_Speed4200_5000'                             ''  'Number_of_Particles_of_5mm_=<_Diameter_<_5.5mm_and_4.2_m/s_=<_Speed_<_5.0_m/s'
'numberParticlesDiameter5000_5500_Speed5000_5800'                             ''  'Number_of_Particles_of_5mm_=<_Diameter_<_5.5mm_and_5.0_m/s_=<_Speed_<_5.8_m/s'
'numberParticlesDiameter5000_5500_Speed5800_6600'                             ''  'Number_of_Particles_of_5mm_=<_Diameter_<_5.5mm_and_5.8_m/s_=<_Speed_<_6.6_m/s'
'numberParticlesDiameter5000_5500_Speed6600_7400'                             ''  'Number_of_Particles_of_5mm_=<_Diameter_<_5.5mm_and_6.6_m/s_=<_Speed_<_7.4_m/s'
'numberParticlesDiameter5000_5500_Speed7400_8200'                             ''  'Number_of_Particles_of_5mm_=<_Diameter_<_5.5mm_and_7.4_m/s_=<_Speed_<_8.2_m/s'
'numberParticlesDiameter5000_5500_Speed8200_9000'                             ''  'Number_of_Particles_of_5mm_=<_Diameter_<_5.5mm_and_8.2_m/s_=<_Speed_<_9.0_m/s'
'numberParticlesDiameter5000_5500_Speed9000_10000'                             ''   'Number_of_Particles_of_5mm_=<_Diameter_<_5.5mm_and_9.0_m/s_=<_Speed_<_10_m/s'
'numberParticlesDiameter5000_5500_Speed10000_20000'                             ''    'Number_of_Particles_of_5mm_=<_Diameter_<_5.5mm_and_10_m/s_=<_Speed_<_20_m/s'
'numberParticlesDiameter5500_6000_Speed0000_0200'                             ''   'Number_of_Particles_of_5.5mm_=<_Diameter_<_6mm_and_0__m/s_=<_Speed_<_0.2_m/s'
'numberParticlesDiameter5500_6000_Speed0200_0400'                             ''  'Number_of_Particles_of_5.5mm_=<_Diameter_<_6mm_and_0.2_m/s_=<_Speed_<_0.4_m/s'
'numberParticlesDiameter5500_6000_Speed0400_0600'                             ''  'Number_of_Particles_of_5.5mm_=<_Diameter_<_6mm_and_0.4_m/s_=<_Speed_<_0.6_m/s'
'numberParticlesDiameter5500_6000_Speed0600_0800'                             ''  'Number_of_Particles_of_5.5mm_=<_Diameter_<_6mm_and_0.6_m/s_=<_Speed_<_0.8_m/s'
'numberParticlesDiameter5500_6000_Speed0800_1000'                             ''  'Number_of_Particles_of_5.5mm_=<_Diameter_<_6mm_and_0.8_m/s_=<_Speed_<_1.0_m/s'
'numberParticlesDiameter5500_6000_Speed1000_1400'                             ''  'Number_of_Particles_of_5.5mm_=<_Diameter_<_6mm_and_1.0_m/s_=<_Speed_<_1.4_m/s'
'numberParticlesDiameter5500_6000_Speed1400_1800'                             ''  'Number_of_Particles_of_5.5mm_=<_Diameter_<_6mm_and_1.4_m/s_=<_Speed_<_1.8_m/s'
'numberParticlesDiameter5500_6000_Speed1800_2200'                             ''  'Number_of_Particles_of_5.5mm_=<_Diameter_<_6mm_and_1.8_m/s_=<_Speed_<_2.2_m/s'
'numberParticlesDiameter5500_6000_Speed2200_2600'                             ''  'Number_of_Particles_of_5.5mm_=<_Diameter_<_6mm_and_2.2_m/s_=<_Speed_<_2.6_m/s'
'numberParticlesDiameter5500_6000_Speed2600_3000'                             ''  'Number_of_Particles_of_5.5mm_=<_Diameter_<_6mm_and_2.6_m/s_=<_Speed_<_3.0_m/s'
'numberParticlesDiameter5500_6000_Speed3000_3400'                             ''  'Number_of_Particles_of_5.5mm_=<_Diameter_<_6mm_and_3.0_m/s_=<_Speed_<_3.4_m/s'
'numberParticlesDiameter5500_6000_Speed3400_4200'                             ''  'Number_of_Particles_of_5.5mm_=<_Diameter_<_6mm_and_3.4_m/s_=<_Speed_<_4.2_m/s'
'numberParticlesDiameter5500_6000_Speed4200_5000'                             ''  'Number_of_Particles_of_5.5mm_=<_Diameter_<_6mm_and_4.2_m/s_=<_Speed_<_5.0_m/s'
'numberParticlesDiameter5500_6000_Speed5000_5800'                             ''  'Number_of_Particles_of_5.5mm_=<_Diameter_<_6mm_and_5.0_m/s_=<_Speed_<_5.8_m/s'
'numberParticlesDiameter5500_6000_Speed5800_6600'                             ''  'Number_of_Particles_of_5.5mm_=<_Diameter_<_6mm_and_5.8_m/s_=<_Speed_<_6.6_m/s'
'numberParticlesDiameter5500_6000_Speed6600_7400'                             ''  'Number_of_Particles_of_5.5mm_=<_Diameter_<_6mm_and_6.6_m/s_=<_Speed_<_7.4_m/s'
'numberParticlesDiameter5500_6000_Speed7400_8200'                             ''  'Number_of_Particles_of_5.5mm_=<_Diameter_<_6mm_and_7.4_m/s_=<_Speed_<_8.2_m/s'
'numberParticlesDiameter5500_6000_Speed8200_9000'                             ''  'Number_of_Particles_of_5.5mm_=<_Diameter_<_6mm_and_8.2_m/s_=<_Speed_<_9.0_m/s'
'numberParticlesDiameter5500_6000_Speed9000_10000'                             ''   'Number_of_Particles_of_5.5mm_=<_Diameter_<_6mm_and_9.0_m/s_=<_Speed_<_10_m/s'
'numberParticlesDiameter5500_6000_Speed10000_20000'                             ''    'Number_of_Particles_of_5.5mm_=<_Diameter_<_6mm_and_10_m/s_=<_Speed_<_20_m/s'
'numberParticlesDiameter6000_6500_Speed0000_0200'                             ''   'Number_of_Particles_of_6mm_=<_Diameter_<_6.5mm_and_0__m/s_=<_Speed_<_0.2_m/s'
'numberParticlesDiameter6000_6500_Speed0200_0400'                             ''  'Number_of_Particles_of_6mm_=<_Diameter_<_6.5mm_and_0.2_m/s_=<_Speed_<_0.4_m/s'
'numberParticlesDiameter6000_6500_Speed0400_0600'                             ''  'Number_of_Particles_of_6mm_=<_Diameter_<_6.5mm_and_0.4_m/s_=<_Speed_<_0.6_m/s'
'numberParticlesDiameter6000_6500_Speed0600_0800'                             ''  'Number_of_Particles_of_6mm_=<_Diameter_<_6.5mm_and_0.6_m/s_=<_Speed_<_0.8_m/s'
'numberParticlesDiameter6000_6500_Speed0800_1000'                             ''  'Number_of_Particles_of_6mm_=<_Diameter_<_6.5mm_and_0.8_m/s_=<_Speed_<_1.0_m/s'
'numberParticlesDiameter6000_6500_Speed1000_1400'                             ''  'Number_of_Particles_of_6mm_=<_Diameter_<_6.5mm_and_1.0_m/s_=<_Speed_<_1.4_m/s'
'numberParticlesDiameter6000_6500_Speed1400_1800'                             ''  'Number_of_Particles_of_6mm_=<_Diameter_<_6.5mm_and_1.4_m/s_=<_Speed_<_1.8_m/s'
'numberParticlesDiameter6000_6500_Speed1800_2200'                             ''  'Number_of_Particles_of_6mm_=<_Diameter_<_6.5mm_and_1.8_m/s_=<_Speed_<_2.2_m/s'
'numberParticlesDiameter6000_6500_Speed2200_2600'                             ''  'Number_of_Particles_of_6mm_=<_Diameter_<_6.5mm_and_2.2_m/s_=<_Speed_<_2.6_m/s'
'numberParticlesDiameter6000_6500_Speed2600_3000'                             ''  'Number_of_Particles_of_6mm_=<_Diameter_<_6.5mm_and_2.6_m/s_=<_Speed_<_3.0_m/s'
'numberParticlesDiameter6000_6500_Speed3000_3400'                             ''  'Number_of_Particles_of_6mm_=<_Diameter_<_6.5mm_and_3.0_m/s_=<_Speed_<_3.4_m/s'
'numberParticlesDiameter6000_6500_Speed3400_4200'                             ''  'Number_of_Particles_of_6mm_=<_Diameter_<_6.5mm_and_3.4_m/s_=<_Speed_<_4.2_m/s'
'numberParticlesDiameter6000_6500_Speed4200_5000'                             ''  'Number_of_Particles_of_6mm_=<_Diameter_<_6.5mm_and_4.2_m/s_=<_Speed_<_5.0_m/s'
'numberParticlesDiameter6000_6500_Speed5000_5800'                             ''  'Number_of_Particles_of_6mm_=<_Diameter_<_6.5mm_and_5.0_m/s_=<_Speed_<_5.8_m/s'
'numberParticlesDiameter6000_6500_Speed5800_6600'                             ''  'Number_of_Particles_of_6mm_=<_Diameter_<_6.5mm_and_5.8_m/s_=<_Speed_<_6.6_m/s'
'numberParticlesDiameter6000_6500_Speed6600_7400'                             ''  'Number_of_Particles_of_6mm_=<_Diameter_<_6.5mm_and_6.6_m/s_=<_Speed_<_7.4_m/s'
'numberParticlesDiameter6000_6500_Speed7400_8200'                             ''  'Number_of_Particles_of_6mm_=<_Diameter_<_6.5mm_and_7.4_m/s_=<_Speed_<_8.2_m/s'
'numberParticlesDiameter6000_6500_Speed8200_9000'                             ''  'Number_of_Particles_of_6mm_=<_Diameter_<_6.5mm_and_8.2_m/s_=<_Speed_<_9.0_m/s'
'numberParticlesDiameter6000_6500_Speed9000_10000'                             ''   'Number_of_Particles_of_6mm_=<_Diameter_<_6.5mm_and_9.0_m/s_=<_Speed_<_10_m/s'
'numberParticlesDiameter6000_6500_Speed10000_20000'                             ''    'Number_of_Particles_of_6mm_=<_Diameter_<_6.5mm_and_10_m/s_=<_Speed_<_20_m/s'
'numberParticlesDiameter6500_7000_Speed0000_0200'                             ''   'Number_of_Particles_of_6.5mm_=<_Diameter_<_7mm_and_0__m/s_=<_Speed_<_0.2_m/s'
'numberParticlesDiameter6500_7000_Speed0200_0400'                             ''  'Number_of_Particles_of_6.5mm_=<_Diameter_<_7mm_and_0.2_m/s_=<_Speed_<_0.4_m/s'
'numberParticlesDiameter6500_7000_Speed0400_0600'                             ''  'Number_of_Particles_of_6.5mm_=<_Diameter_<_7mm_and_0.4_m/s_=<_Speed_<_0.6_m/s'
'numberParticlesDiameter6500_7000_Speed0600_0800'                             ''  'Number_of_Particles_of_6.5mm_=<_Diameter_<_7mm_and_0.6_m/s_=<_Speed_<_0.8_m/s'
'numberParticlesDiameter6500_7000_Speed0800_1000'                             ''  'Number_of_Particles_of_6.5mm_=<_Diameter_<_7mm_and_0.8_m/s_=<_Speed_<_1.0_m/s'
'numberParticlesDiameter6500_7000_Speed1000_1400'                             ''  'Number_of_Particles_of_6.5mm_=<_Diameter_<_7mm_and_1.0_m/s_=<_Speed_<_1.4_m/s'
'numberParticlesDiameter6500_7000_Speed1400_1800'                             ''  'Number_of_Particles_of_6.5mm_=<_Diameter_<_7mm_and_1.4_m/s_=<_Speed_<_1.8_m/s'
'numberParticlesDiameter6500_7000_Speed1800_2200'                             ''  'Number_of_Particles_of_6.5mm_=<_Diameter_<_7mm_and_1.8_m/s_=<_Speed_<_2.2_m/s'
'numberParticlesDiameter6500_7000_Speed2200_2600'                             ''  'Number_of_Particles_of_6.5mm_=<_Diameter_<_7mm_and_2.2_m/s_=<_Speed_<_2.6_m/s'
'numberParticlesDiameter6500_7000_Speed2600_3000'                             ''  'Number_of_Particles_of_6.5mm_=<_Diameter_<_7mm_and_2.6_m/s_=<_Speed_<_3.0_m/s'
'numberParticlesDiameter6500_7000_Speed3000_3400'                             ''  'Number_of_Particles_of_6.5mm_=<_Diameter_<_7mm_and_3.0_m/s_=<_Speed_<_3.4_m/s'
'numberParticlesDiameter6500_7000_Speed3400_4200'                             ''  'Number_of_Particles_of_6.5mm_=<_Diameter_<_7mm_and_3.4_m/s_=<_Speed_<_4.2_m/s'
'numberParticlesDiameter6500_7000_Speed4200_5000'                             ''  'Number_of_Particles_of_6.5mm_=<_Diameter_<_7mm_and_4.2_m/s_=<_Speed_<_5.0_m/s'
'numberParticlesDiameter6500_7000_Speed5000_5800'                             ''  'Number_of_Particles_of_6.5mm_=<_Diameter_<_7mm_and_5.0_m/s_=<_Speed_<_5.8_m/s'
'numberParticlesDiameter6500_7000_Speed5800_6600'                             ''  'Number_of_Particles_of_6.5mm_=<_Diameter_<_7mm_and_5.8_m/s_=<_Speed_<_6.6_m/s'
'numberParticlesDiameter6500_7000_Speed6600_7400'                             ''  'Number_of_Particles_of_6.5mm_=<_Diameter_<_7mm_and_6.6_m/s_=<_Speed_<_7.4_m/s'
'numberParticlesDiameter6500_7000_Speed7400_8200'                             ''  'Number_of_Particles_of_6.5mm_=<_Diameter_<_7mm_and_7.4_m/s_=<_Speed_<_8.2_m/s'
'numberParticlesDiameter6500_7000_Speed8200_9000'                             ''  'Number_of_Particles_of_6.5mm_=<_Diameter_<_7mm_and_8.2_m/s_=<_Speed_<_9.0_m/s'
'numberParticlesDiameter6500_7000_Speed9000_10000'                             ''   'Number_of_Particles_of_6.5mm_=<_Diameter_<_7mm_and_9.0_m/s_=<_Speed_<_10_m/s'
'numberParticlesDiameter6500_7000_Speed10000_20000'                             ''    'Number_of_Particles_of_6.5mm_=<_Diameter_<_7mm_and_10_m/s_=<_Speed_<_20_m/s'
'numberParticlesDiameter7000_7500_Speed0000_0200'                             ''   'Number_of_Particles_of_7mm_=<_Diameter_<_7.5mm_and_0__m/s_=<_Speed_<_0.2_m/s'
'numberParticlesDiameter7000_7500_Speed0200_0400'                             ''  'Number_of_Particles_of_7mm_=<_Diameter_<_7.5mm_and_0.2_m/s_=<_Speed_<_0.4_m/s'
'numberParticlesDiameter7000_7500_Speed0400_0600'                             ''  'Number_of_Particles_of_7mm_=<_Diameter_<_7.5mm_and_0.4_m/s_=<_Speed_<_0.6_m/s'
'numberParticlesDiameter7000_7500_Speed0600_0800'                             ''  'Number_of_Particles_of_7mm_=<_Diameter_<_7.5mm_and_0.6_m/s_=<_Speed_<_0.8_m/s'
'numberParticlesDiameter7000_7500_Speed0800_1000'                             ''  'Number_of_Particles_of_7mm_=<_Diameter_<_7.5mm_and_0.8_m/s_=<_Speed_<_1.0_m/s'
'numberParticlesDiameter7000_7500_Speed1000_1400'                             ''  'Number_of_Particles_of_7mm_=<_Diameter_<_7.5mm_and_1.0_m/s_=<_Speed_<_1.4_m/s'
'numberParticlesDiameter7000_7500_Speed1400_1800'                             ''  'Number_of_Particles_of_7mm_=<_Diameter_<_7.5mm_and_1.4_m/s_=<_Speed_<_1.8_m/s'
'numberParticlesDiameter7000_7500_Speed1800_2200'                             ''  'Number_of_Particles_of_7mm_=<_Diameter_<_7.5mm_and_1.8_m/s_=<_Speed_<_2.2_m/s'
'numberParticlesDiameter7000_7500_Speed2200_2600'                             ''  'Number_of_Particles_of_7mm_=<_Diameter_<_7.5mm_and_2.2_m/s_=<_Speed_<_2.6_m/s'
'numberParticlesDiameter7000_7500_Speed2600_3000'                             ''  'Number_of_Particles_of_7mm_=<_Diameter_<_7.5mm_and_2.6_m/s_=<_Speed_<_3.0_m/s'
'numberParticlesDiameter7000_7500_Speed3000_3400'                             ''  'Number_of_Particles_of_7mm_=<_Diameter_<_7.5mm_and_3.0_m/s_=<_Speed_<_3.4_m/s'
'numberParticlesDiameter7000_7500_Speed3400_4200'                             ''  'Number_of_Particles_of_7mm_=<_Diameter_<_7.5mm_and_3.4_m/s_=<_Speed_<_4.2_m/s'
'numberParticlesDiameter7000_7500_Speed4200_5000'                             ''  'Number_of_Particles_of_7mm_=<_Diameter_<_7.5mm_and_4.2_m/s_=<_Speed_<_5.0_m/s'
'numberParticlesDiameter7000_7500_Speed5000_5800'                             ''  'Number_of_Particles_of_7mm_=<_Diameter_<_7.5mm_and_5.0_m/s_=<_Speed_<_5.8_m/s'
'numberParticlesDiameter7000_7500_Speed5800_6600'                             ''  'Number_of_Particles_of_7mm_=<_Diameter_<_7.5mm_and_5.8_m/s_=<_Speed_<_6.6_m/s'
'numberParticlesDiameter7000_7500_Speed6600_7400'                             ''  'Number_of_Particles_of_7mm_=<_Diameter_<_7.5mm_and_6.6_m/s_=<_Speed_<_7.4_m/s'
'numberParticlesDiameter7000_7500_Speed7400_8200'                             ''  'Number_of_Particles_of_7mm_=<_Diameter_<_7.5mm_and_7.4_m/s_=<_Speed_<_8.2_m/s'
'numberParticlesDiameter7000_7500_Speed8200_9000'                             ''  'Number_of_Particles_of_7mm_=<_Diameter_<_7.5mm_and_8.2_m/s_=<_Speed_<_9.0_m/s'
'numberParticlesDiameter7000_7500_Speed9000_10000'                             ''   'Number_of_Particles_of_7mm_=<_Diameter_<_7.5mm_and_9.0_m/s_=<_Speed_<_10_m/s'
'numberParticlesDiameter7000_7500_Speed10000_20000'                             ''    'Number_of_Particles_of_7mm_=<_Diameter_<_7.5mm_and_10_m/s_=<_Speed_<_20_m/s'
'numberParticlesDiameter7500_8000_Speed0000_0200'                             ''   'Number_of_Particles_of_7.5mm_=<_Diameter_<_8mm_and_0__m/s_=<_Speed_<_0.2_m/s'
'numberParticlesDiameter7500_8000_Speed0200_0400'                             ''  'Number_of_Particles_of_7.5mm_=<_Diameter_<_8mm_and_0.2_m/s_=<_Speed_<_0.4_m/s'
'numberParticlesDiameter7500_8000_Speed0400_0600'                             ''  'Number_of_Particles_of_7.5mm_=<_Diameter_<_8mm_and_0.4_m/s_=<_Speed_<_0.6_m/s'
'numberParticlesDiameter7500_8000_Speed0600_0800'                             ''  'Number_of_Particles_of_7.5mm_=<_Diameter_<_8mm_and_0.6_m/s_=<_Speed_<_0.8_m/s'
'numberParticlesDiameter7500_8000_Speed0800_1000'                             ''  'Number_of_Particles_of_7.5mm_=<_Diameter_<_8mm_and_0.8_m/s_=<_Speed_<_1.0_m/s'
'numberParticlesDiameter7500_8000_Speed1000_1400'                             ''  'Number_of_Particles_of_7.5mm_=<_Diameter_<_8mm_and_1.0_m/s_=<_Speed_<_1.4_m/s'
'numberParticlesDiameter7500_8000_Speed1400_1800'                             ''  'Number_of_Particles_of_7.5mm_=<_Diameter_<_8mm_and_1.4_m/s_=<_Speed_<_1.8_m/s'
'numberParticlesDiameter7500_8000_Speed1800_2200'                             ''  'Number_of_Particles_of_7.5mm_=<_Diameter_<_8mm_and_1.8_m/s_=<_Speed_<_2.2_m/s'
'numberParticlesDiameter7500_8000_Speed2200_2600'                             ''  'Number_of_Particles_of_7.5mm_=<_Diameter_<_8mm_and_2.2_m/s_=<_Speed_<_2.6_m/s'
'numberParticlesDiameter7500_8000_Speed2600_3000'                             ''  'Number_of_Particles_of_7.5mm_=<_Diameter_<_8mm_and_2.6_m/s_=<_Speed_<_3.0_m/s'
'numberParticlesDiameter7500_8000_Speed3000_3400'                             ''  'Number_of_Particles_of_7.5mm_=<_Diameter_<_8mm_and_3.0_m/s_=<_Speed_<_3.4_m/s'
'numberParticlesDiameter7500_8000_Speed3400_4200'                             ''  'Number_of_Particles_of_7.5mm_=<_Diameter_<_8mm_and_3.4_m/s_=<_Speed_<_4.2_m/s'
'numberParticlesDiameter7500_8000_Speed4200_5000'                             ''  'Number_of_Particles_of_7.5mm_=<_Diameter_<_8mm_and_4.2_m/s_=<_Speed_<_5.0_m/s'
'numberParticlesDiameter7500_8000_Speed5000_5800'                             ''  'Number_of_Particles_of_7.5mm_=<_Diameter_<_8mm_and_5.0_m/s_=<_Speed_<_5.8_m/s'
'numberParticlesDiameter7500_8000_Speed5800_6600'                             ''  'Number_of_Particles_of_7.5mm_=<_Diameter_<_8mm_and_5.8_m/s_=<_Speed_<_6.6_m/s'
'numberParticlesDiameter7500_8000_Speed6600_7400'                             ''  'Number_of_Particles_of_7.5mm_=<_Diameter_<_8mm_and_6.6_m/s_=<_Speed_<_7.4_m/s'
'numberParticlesDiameter7500_8000_Speed7400_8200'                             ''  'Number_of_Particles_of_7.5mm_=<_Diameter_<_8mm_and_7.4_m/s_=<_Speed_<_8.2_m/s'
'numberParticlesDiameter7500_8000_Speed8200_9000'                             ''  'Number_of_Particles_of_7.5mm_=<_Diameter_<_8mm_and_8.2_m/s_=<_Speed_<_9.0_m/s'
'numberParticlesDiameter7500_8000_Speed9000_10000'                             ''   'Number_of_Particles_of_7.5mm_=<_Diameter_<_8mm_and_9.0_m/s_=<_Speed_<_10_m/s'
'numberParticlesDiameter7500_8000_Speed10000_20000'                             ''    'Number_of_Particles_of_7.5mm_=<_Diameter_<_8mm_and_10_m/s_=<_Speed_<_20_m/s'
'numberParticlesDiameter8000_9999_Speed0000_0200'                             ''           'Number_of_Particles_of_Diameter_>=_8mm_and_0__m/s_=<_Speed_<_0.2_m/s'
'numberParticlesDiameter8000_9999_Speed0200_0400'                             ''          'Number_of_Particles_of_Diameter_>=_8mm_and_0.2_m/s_=<_Speed_<_0.4_m/s'
'numberParticlesDiameter8000_9999_Speed0400_0600'                             ''          'Number_of_Particles_of_Diameter_>=_8mm_and_0.4_m/s_=<_Speed_<_0.6_m/s'
'numberParticlesDiameter8000_9999_Speed0600_0800'                             ''          'Number_of_Particles_of_Diameter_>=_8mm_and_0.6_m/s_=<_Speed_<_0.8_m/s'
'numberParticlesDiameter8000_9999_Speed0800_1000'                             ''          'Number_of_Particles_of_Diameter_>=_8mm_and_0.8_m/s_=<_Speed_<_1.0_m/s'
'numberParticlesDiameter8000_9999_Speed1000_1400'                             ''          'Number_of_Particles_of_Diameter_>=_8mm_and_1.0_m/s_=<_Speed_<_1.4_m/s'
'numberParticlesDiameter8000_9999_Speed1400_1800'                             ''          'Number_of_Particles_of_Diameter_>=_8mm_and_1.4_m/s_=<_Speed_<_1.8_m/s'
'numberParticlesDiameter8000_9999_Speed1800_2200'                             ''          'Number_of_Particles_of_Diameter_>=_8mm_and_1.8_m/s_=<_Speed_<_2.2_m/s'
'numberParticlesDiameter8000_9999_Speed2200_2600'                             ''          'Number_of_Particles_of_Diameter_>=_8mm_and_2.2_m/s_=<_Speed_<_2.6_m/s'
'numberParticlesDiameter8000_9999_Speed2600_3000'                             ''          'Number_of_Particles_of_Diameter_>=_8mm_and_2.6_m/s_=<_Speed_<_3.0_m/s'
'numberParticlesDiameter8000_9999_Speed3000_3400'                             ''          'Number_of_Particles_of_Diameter_>=_8mm_and_3.0_m/s_=<_Speed_<_3.4_m/s'
'numberParticlesDiameter8000_9999_Speed3400_4200'                             ''          'Number_of_Particles_of_Diameter_>=_8mm_and_3.4_m/s_=<_Speed_<_4.2_m/s'
'numberParticlesDiameter8000_9999_Speed4200_5000'                             ''          'Number_of_Particles_of_Diameter_>=_8mm_and_4.2_m/s_=<_Speed_<_5.0_m/s'
'numberParticlesDiameter8000_9999_Speed5000_5800'                             ''          'Number_of_Particles_of_Diameter_>=_8mm_and_5.0_m/s_=<_Speed_<_5.8_m/s'
'numberParticlesDiameter8000_9999_Speed5800_6600'                             ''          'Number_of_Particles_of_Diameter_>=_8mm_and_5.8_m/s_=<_Speed_<_6.6_m/s'
'numberParticlesDiameter8000_9999_Speed6600_7400'                             ''          'Number_of_Particles_of_Diameter_>=_8mm_and_6.6_m/s_=<_Speed_<_7.4_m/s'
'numberParticlesDiameter8000_9999_Speed7400_8200'                             ''          'Number_of_Particles_of_Diameter_>=_8mm_and_7.4_m/s_=<_Speed_<_8.2_m/s'
'numberParticlesDiameter8000_9999_Speed8200_9000'                             ''          'Number_of_Particles_of_Diameter_>=_8mm_and_8.2_m/s_=<_Speed_<_9.0_m/s'
'numberParticlesDiameter8000_9999_Speed9000_10000'                             ''           'Number_of_Particles_of_Diameter_>=_8mm_and_9.0_m/s_=<_Speed_<_10_m/s'
'numberParticlesDiameter8000_9999_Speed10000_20000'                             ''            'Number_of_Particles_of_Diameter_>=_8mm_and_10_m/s_=<_Speed_<_20_m/s'
%                   'checksum'                             ''                                                                       'Checksum'
};


%met_vaisala_hmp155e_foremast1  1  sentences

%"PVTNH2 - Vaisala custom output message, extended from version 1"
rtables.met_vaisala_hmp155e_foremast1_pvtnh2 = {  % from met_vaisala_hmp155e_foremast1.json
'met_vaisala_hmp155e_foremast1_pvtnh2'  9 []  % fields
            'relativeHumidity'                   'percentage'                                                         'Relative_Humidity_-_RH'
              'airTemperature'               'degreesCelsius'                                            'Additional_T-probe_Temperature_-_Ta'
'dewPointFrostPointTemperature'               'degreesCelsius'                                      'Dew_Point_/_Frost_Point_Temparature_-_TDF'
         'dewPointTemperature'               'degreesCelsius'                                                     'Dew_Point_Temparature_-_Td'
                 'mixingRatio'                         'g/kg'                                                               'Mixing_Ratio_-_x'
          'wetBulbTemperature'               'degreesCelsius'                                                      'Wet_Bulb_Temperature_-_tw'
%                 'errorFlags'                             ''                                                                    'Error_Flags'
%         'probeHeatingStatus'                             ''                                                           'Probe_Heating_Status'
%               'serialNumber'                             ''                                                            'Probe_Serial_Number'
};


%met_vaisala_hmp155e_scimast1  1  sentences

%"PVTNH2 - Vaisala custom output message, extended from version 1"
rtables.met_vaisala_hmp155e_scimast1_pvtnh2 = {  % from met_vaisala_hmp155e_scimast1.json
'met_vaisala_hmp155e_scimast1_pvtnh2'  9 []  % fields
            'relativeHumidity'                   'percentage'                                                         'Relative_Humidity_-_RH'
              'airTemperature'               'degreesCelsius'                                            'Additional_T-probe_Temperature_-_Ta'
'dewPointFrostPointTemperature'               'degreesCelsius'                                      'Dew_Point_/_Frost_Point_Temparature_-_TDF'
         'dewPointTemperature'               'degreesCelsius'                                                     'Dew_Point_Temparature_-_Td'
                 'mixingRatio'                         'g/kg'                                                               'Mixing_Ratio_-_x'
          'wetBulbTemperature'               'degreesCelsius'                                                      'Wet_Bulb_Temperature_-_tw'
%                 'errorFlags'                             ''                                                                    'Error_Flags'
%         'probeHeatingStatus'                             ''                                                           'Probe_Heating_Status'
%               'serialNumber'                             ''                                                            'Probe_Serial_Number'
};


%met_vaisala_hmp155e_scimast2  1  sentences

%"PVTNH2 - Vaisala custom output message, extended from version 1"
rtables.met_vaisala_hmp155e_scimast2_pvtnh2 = {  % from met_vaisala_hmp155e_scimast2.json
'met_vaisala_hmp155e_scimast2_pvtnh2'  9 []  % fields
            'relativeHumidity'                   'percentage'                                                         'Relative_Humidity_-_RH'
              'airTemperature'               'degreesCelsius'                                            'Additional_T-probe_Temperature_-_Ta'
'dewPointFrostPointTemperature'               'degreesCelsius'                                      'Dew_Point_/_Frost_Point_Temparature_-_TDF'
         'dewPointTemperature'               'degreesCelsius'                                                     'Dew_Point_Temparature_-_Td'
                 'mixingRatio'                         'g/kg'                                                               'Mixing_Ratio_-_x'
          'wetBulbTemperature'               'degreesCelsius'                                                      'Wet_Bulb_Temperature_-_tw'
%                 'errorFlags'                             ''                                                                    'Error_Flags'
%         'probeHeatingStatus'                             ''                                                           'Probe_Heating_Status'
%               'serialNumber'                             ''                                                            'Probe_Serial_Number'
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


%multibeam_kongsberg_em122  1  sentences

%"KIDPT – Depth below EM122 Transducer"
rtables.multibeam_kongsberg_em122_kidpt = {  % from multibeam_kongsberg_em122.json
'multibeam_kongsberg_em122_kidpt'  3 []  % fields
'waterDepthMetreFromTransducer'                       'metres'                                            'Depth_in_metres_from_the_Transducer'
   'offsetMetreFromTransducer'                       'metres'                 'Offset__in_metres__to_the_waterline_relative_to_the_transducer'
%              'maxRangeScale'                       'metres'                                                     'Maximum_range_scale_in_use'
};


%multibeam_kongsberg_em712  1  sentences

%"KODPT – Depth below EM712 Transducer"
rtables.multibeam_kongsberg_em712_kodpt = {  % from multibeam_kongsberg_em712.json
'multibeam_kongsberg_em712_kodpt'  3 []  % fields
'waterDepthMetreFromTransducer'                       'metres'                                            'Depth_in_metres_from_the_Transducer'
   'offsetMetreFromTransducer'                       'metres'                 'Offset__in_metres__to_the_waterline_relative_to_the_transducer'
%              'maxRangeScale'                       'metres'                                                     'Maximum_range_scale_in_use'
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
%                 'deviceType'                             ''                                                                    'Device_Type'
%           'datamodelVersion'                             ''                                                             'Data_Model_Version'
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
                  'adc1Counts'                             ''                                                                    'ADC1_Counts'
                  'adc2Counts'                             ''                                          'ADC2_Counts_-_Not_supported__Always_0'
                  'adc3Counts'                             ''                                                                    'ADC3_Counts'
                  'adc4Counts'                             ''                                                                    'ADC4_Counts'
                   'errorCode'                             ''                                                                     'Error_Code'
               'protocolError'                             ''                                                                 'Protocol_Error'
         'errorCountPriority1'                             ''                                                         'Error_Count_Priority_1'
         'errorCountPriority2'                             ''                                                         'Error_Count_Priority_2'
      'controlledRestartCount'                             ''                                                       'Controlled_Restart_Count'
    'uncontrolledRestartCount'                             ''                                                     'Uncontrolled_Restart_Count'
                'sensorOnTime'                            's'                                                                 'Sensor_On_Time'
                 'batchNumber'                            's'                                                                   'Batch_Number'
%               'serialNumber'                            's'                                                                  'Serial_Number'
%            'softwareVersion'                            's'                                                               'Software_Version'
%            'hardwareVersion'                            's'                                                               'Hardware_Version'
                      'nodeID'                             ''                                               'Node_ID_-_MODBUS_Device_Address_'
};


%radiometer_kipp_zonen_sgr4a_190057  1  sentences

%"PKPYRGE - Bespoke Kipp and Zonen SGR4-A Pyrgeometer message read from a MODBUS interface"
rtables.radiometer_kipp_zonen_sgr4a_190057_pkpyrge = {  % from radiometer_kipp_zonen_sgr4a_190057.json
'radiometer_kipp_zonen_sgr4a_190057_pkpyrge' 34 []  % fields
%                 'deviceType'                             ''                                                                    'Device_Type'
%           'datamodelVersion'                             ''                                                             'Data_Model_Version'
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
                  'adc1Counts'                             ''                                                                    'ADC1_Counts'
                  'adc2Counts'                             ''                                          'ADC2_Counts_-_Not_supported__Always_0'
                  'adc3Counts'                             ''                                                                    'ADC3_Counts'
                  'adc4Counts'                             ''                                                                    'ADC4_Counts'
                   'errorCode'                             ''                                                                     'Error_Code'
               'protocolError'                             ''                                                                 'Protocol_Error'
         'errorCountPriority1'                             ''                                                         'Error_Count_Priority_1'
         'errorCountPriority2'                             ''                                                         'Error_Count_Priority_2'
      'controlledRestartCount'                             ''                                                       'Controlled_Restart_Count'
    'uncontrolledRestartCount'                             ''                                                     'Uncontrolled_Restart_Count'
                'sensorOnTime'                            's'                                                                 'Sensor_On_Time'
                 'batchNumber'                            's'                                                                   'Batch_Number'
%               'serialNumber'                            's'                                                                  'Serial_Number'
%            'softwareVersion'                            's'                                                               'Software_Version'
%            'hardwareVersion'                            's'                                                               'Hardware_Version'
                      'nodeID'                             ''                                               'Node_ID_-_MODBUS_Device_Address_'
};


%radiometer_kipp_zonen_smp22a_190028  1  sentences

%"PKPYRAN - Bespoke Kipp and Zonen SMP22-A Pyranometer message read from a MODBUS interface"
rtables.radiometer_kipp_zonen_smp22a_190028_pkpyran = {  % from radiometer_kipp_zonen_smp22a_190028.json
'radiometer_kipp_zonen_smp22a_190028_pkpyran' 34 []  % fields
%                 'deviceType'                             ''                                                                    'Device_Type'
%           'datamodelVersion'                             ''                                                             'Data_Model_Version'
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
                  'adc1Counts'                             ''                                                                    'ADC1_Counts'
                  'adc2Counts'                             ''                                          'ADC2_Counts_-_Not_supported__Always_0'
                  'adc3Counts'                             ''                                                                    'ADC3_Counts'
                  'adc4Counts'                             ''                                                                    'ADC4_Counts'
                   'errorCode'                             ''                                                                     'Error_Code'
               'protocolError'                             ''                                                                 'Protocol_Error'
         'errorCountPriority1'                             ''                                                         'Error_Count_Priority_1'
         'errorCountPriority2'                             ''                                                         'Error_Count_Priority_2'
      'controlledRestartCount'                             ''                                                       'Controlled_Restart_Count'
    'uncontrolledRestartCount'                             ''                                                     'Uncontrolled_Restart_Count'
                'sensorOnTime'                            's'                                                                 'Sensor_On_Time'
                 'batchNumber'                            's'                                                                   'Batch_Number'
%               'serialNumber'                            's'                                                                  'Serial_Number'
%            'softwareVersion'                            's'                                                               'Software_Version'
%            'hardwareVersion'                            's'                                                               'Hardware_Version'
                      'nodeID'                             ''                                               'Node_ID_-_MODBUS_Device_Address_'
};


%radiometer_kipp_zonen_smp22a_190029  1  sentences

%"PKPYRAN - Bespoke Kipp and Zonen SMP22-A Pyranometer message read from a MODBUS interface"
rtables.radiometer_kipp_zonen_smp22a_190029_pkpyran = {  % from radiometer_kipp_zonen_smp22a_190029.json
'radiometer_kipp_zonen_smp22a_190029_pkpyran' 34 []  % fields
%                 'deviceType'                             ''                                                                    'Device_Type'
%           'datamodelVersion'                             ''                                                             'Data_Model_Version'
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
                  'adc1Counts'                             ''                                                                    'ADC1_Counts'
                  'adc2Counts'                             ''                                          'ADC2_Counts_-_Not_supported__Always_0'
                  'adc3Counts'                             ''                                                                    'ADC3_Counts'
                  'adc4Counts'                             ''                                                                    'ADC4_Counts'
                   'errorCode'                             ''                                                                     'Error_Code'
               'protocolError'                             ''                                                                 'Protocol_Error'
         'errorCountPriority1'                             ''                                                         'Error_Count_Priority_1'
         'errorCountPriority2'                             ''                                                         'Error_Count_Priority_2'
      'controlledRestartCount'                             ''                                                       'Controlled_Restart_Count'
    'uncontrolledRestartCount'                             ''                                                     'Uncontrolled_Restart_Count'
                'sensorOnTime'                            's'                                                                 'Sensor_On_Time'
                 'batchNumber'                            's'                                                                   'Batch_Number'
%               'serialNumber'                            's'                                                                  'Serial_Number'
%            'softwareVersion'                            's'                                                               'Software_Version'
%            'hardwareVersion'                            's'                                                               'Hardware_Version'
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
%                   'checksum'                             ''                                                                       'Checksum'
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
%                   'checksum'                             ''                                                                       'Checksum'
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


%soundvelocity_valeport_minisvs_ucsw1  1  sentences

%"PVSV1 – Sound Velocity"
rtables.soundvelocity_valeport_minisvs_ucsw1_pvsv1 = {  % from soundvelocity_valeport_minisvs_ucsw1.json
'soundvelocity_valeport_minisvs_ucsw1_pvsv1'  1 []  % fields
               'soundVelocity'                'metres/second'                                                                 'Sound_Velocity'
};


%speedlog_northern_solutions_eme_s60  4  sentences

%"VMVBW –Dual ground/water speed"
rtables.speedlog_northern_solutions_eme_s60_vmvbw = {  % from speedlog_northern_solutions_eme_s60.json
'speedlog_northern_solutions_eme_s60_vmvbw' 10 []  % fields
        'longitudalWaterSpeed'                        'Knots'                                                'Longitudal_Water_Speed_in_Knots'
        'transverseWaterSpeed'                        'Knots'                                                'Transverse_Water_Speed_in_Knots'
%           'waterSpeedStatus'                             ''                                                               'waterSpeedStatus'
       'longitudalGroundSpeed'                        'Knots'                                               'Longitudal_Ground_Speed_in_Knots'
       'transverseGroundSpeed'                        'Knots'                                               'Transverse_Gorund_Speed_in_Knots'
%          'groundSpeedStatus'                             ''                                                              'groundSpeedStatus'
    'sternTranverseWaterSpeed'                        'Knots'                                                       'sternTranverseWaterSpeed'
% 'sternTranverseWaterSpeedStatus'                             ''                                                 'sternTranverseWaterSpeedStatus'
   'sternTranverseGroundSpeed'                        'Knots'                                                      'sternTranverseGroundSpeed'
% 'sternTranverseGroundSpeedStatus'                             ''                                                'sternTranverseGroundSpeedStatus'
};

%"VMVHW – Water speed & heading"
rtables.speedlog_northern_solutions_eme_s60_vmvhw = {  % from speedlog_northern_solutions_eme_s60.json
'speedlog_northern_solutions_eme_s60_vmvhw'  8 []  % fields
                 'headingTrue'                      'degrees'                                                                   'Heading_True'
%            'headingTrueFlag'                             ''                                                               'True_Designation'
%            'headingMagnetic'                      'degrees'                                                               'Heading_Magnetic'
%        'headingMagneticFlag'                             ''                                                           'Magnetic_Designation'
%                 'speedKnots'                        'knots'                                     'Speed_of_Vessel_Relative_to_Water_in_Knots'
%                      'nFlag'                             ''                                                              'Knots_Designation'
                   'speedKmph'                         'km/h'                                      'Speed_of_Vessel_Relative_to_Water_in_km/h'
%                      'kFlag'                             ''                                                                'kph_Designation'
};

%"VMVLW – Distance travelled through the water"
rtables.speedlog_northern_solutions_eme_s60_vmvlw = {  % from speedlog_northern_solutions_eme_s60.json
'speedlog_northern_solutions_eme_s60_vmvlw'  8 []  % fields
               'totalDistance'                             ''                                                                 'Total_Distance'
%         'totalDistanceUnits'                             ''                                                            'True_Distance_Units'
          'distanceSinceReset'                             ''                                                           'Distance_since_Reset'
%    'distanceSinceResetUnits'                             ''                                                     'Distance_since_Reset_Units'
'totalCumulativeGroundDistance'                             ''                                               'Total_Cumulative_Ground_Distance'
% 'totalCumulativeGroundDistanceUnits'                             ''                                         'Total_Cumulative_Ground_Distance_Units'
    'groundDistanceSinceReset'                             ''                                                    'Ground_Distance_since_Reset'
% 'groundDistanceSinceResetUnits'                             ''                                              'Ground_Distance_since_Reset_Units'
};

%"VMMTW – Water Temperature"
rtables.speedlog_northern_solutions_eme_s60_vmmtw = {  % from speedlog_northern_solutions_eme_s60.json
'speedlog_northern_solutions_eme_s60_vmmtw'  2 []  % fields
     'waterTemperatureCelsius'               'DegreesCelsius'                                           'Water_Temperature_in_Degrees_Celsius'
%                'celsiusFlag'                             ''                                                     'Units_of_Water_Temperature'
};


%speedlog_skipper_dl850  3  sentences

%"VDVBW –Dual ground/water speed"
rtables.speedlog_skipper_dl850_vdvbw = {  % from speedlog_skipper_dl850.json
'speedlog_skipper_dl850_vdvbw' 10 []  % fields
        'longitudalWaterSpeed'                        'Knots'                                                'Longitudal_Water_Speed_in_Knots'
        'transverseWaterSpeed'                        'Knots'                                                'Transverse_Water_Speed_in_Knots'
%           'waterSpeedStatus'                             ''                                                               'waterSpeedStatus'
       'longitudalGroundSpeed'                        'Knots'                                               'Longitudal_Ground_Speed_in_Knots'
       'transverseGroundSpeed'                        'Knots'                                               'Transverse_Gorund_Speed_in_Knots'
%          'groundSpeedStatus'                             ''                                                              'groundSpeedStatus'
    'sternTranverseWaterSpeed'                        'Knots'                                                       'sternTranverseWaterSpeed'
% 'sternTranverseWaterSpeedStatus'                             ''                                                 'sternTranverseWaterSpeedStatus'
   'sternTranverseGroundSpeed'                        'Knots'                                                      'sternTranverseGroundSpeed'
% 'sternTranverseGroundSpeedStatus'                             ''                                                'sternTranverseGroundSpeedStatus'
};

%"VDVHW – Water speed & heading"
rtables.speedlog_skipper_dl850_vdvhw = {  % from speedlog_skipper_dl850.json
'speedlog_skipper_dl850_vdvhw'  8 []  % fields
                 'headingTrue'                      'degrees'                                                                   'Heading_True'
%            'headingTrueFlag'                             ''                                                               'True_Designation'
%            'headingMagnetic'                      'degrees'                                                               'Heading_Magnetic'
%        'headingMagneticFlag'                             ''                                                           'Magnetic_Designation'
%                 'speedKnots'                        'knots'                                     'Speed_Of_Vessel_Relative_to_Water_in_Knots'
%                      'nFlag'                             ''                                                              'Knots_Designation'
                   'speedKmph'                         'km/h'                                      'Speed_Of_Vessel_Relative_to_Water_in_km/h'
%                      'kFlag'                             ''                                                                'kph_Designation'
};

%"VDVLW – Distance travelled through the water"
rtables.speedlog_skipper_dl850_vdvlw = {  % from speedlog_skipper_dl850.json
'speedlog_skipper_dl850_vdvlw'  8 []  % fields
               'totalDistance'                             ''                                                                 'Total_Distance'
%         'totalDistanceUnits'                             ''                                                            'True_Distance_Units'
          'distanceSinceReset'                             ''                                                           'Distance_Since_Reset'
%    'distanceSinceResetUnits'                             ''                                                     'Distance_Since_Reset_Units'
'totalCumulativeGroundDistance'                             ''                                               'Total_Cumulative_Ground_Distance'
% 'totalCumulativeGroundDistanceUnits'                             ''                                         'Total_Cumulative_Ground_Distance_Units'
    'groundDistanceSinceReset'                             ''                                                    'Ground_Distance_Since_Reset'
% 'groundDistanceSinceResetUnits'                             ''                                              'Ground_Distance_Since_Reset_Units'
};


%thermometer_seabird_sbe38_ucsw1  1  sentences

%"PSBSST1 – Seabird temperature message"
rtables.thermometer_seabird_sbe38_ucsw1_psbsst1 = {  % from thermometer_seabird_sbe38_ucsw1.json
'thermometer_seabird_sbe38_ucsw1_psbsst1'  1 []  % fields
                 'temperature'                      'celcius'                                                            'Temperature__ITS-90'
};


%thermometer_seabird_sbe38_ucsw2  1  sentences

%"PSBSST1 – Seabird temperature message"
rtables.thermometer_seabird_sbe38_ucsw2_psbsst1 = {  % from thermometer_seabird_sbe38_ucsw2.json
'thermometer_seabird_sbe38_ucsw2_psbsst1'  1 []  % fields
                 'temperature'                      'celcius'                                                            'Temperature__ITS-90'
};


%thermosalinograph_seabird_sbe45_ucsw1  1  sentences

%"PSBTSG1 - Sea-Bird SBE45 thermosalinograph output format 0 ascii csv message"
rtables.thermosalinograph_seabird_sbe45_ucsw1_psbtsg1 = {  % from thermosalinograph_seabird_sbe45_ucsw1.json
'thermosalinograph_seabird_sbe45_ucsw1_psbtsg1'  4 []  % fields
                 'temperature'                            'c'                                                           'Temperature_(ITS-90)'
                'conductivity'                          'S/m'                                                                   'Conductivity'
                    'salinity'                          'psu'                                                                       'Salinity'
               'soundVelocity'                          'm/s'                                                                 'Sound_Velocity'
};


%transmissometer_wetlabs_cstar_ucsw1  1  sentences

%"PWLTRAN1 - Seb-Bird WETLabs C-Star transmissometer default ascii csv message"
rtables.transmissometer_wetlabs_cstar_ucsw1_pwltran1 = {  % from transmissometer_wetlabs_cstar_ucsw1.json
'transmissometer_wetlabs_cstar_ucsw1_pwltran1'  6 []  % fields
%         'modelSerialVersion'                             ''                                                           'Model_Serial_Version'
                   'reference'                       'counts'                                                                'Reference_value'
                      'signal'                       'counts'                                                                         'Signal'
             'correctedSignal'                       'counts'                                                               'Corrected_Signal'
              'calculatedBeam'                          'm-1'                                                                'Calculated_Beam'
                  'thermistor'                       'counts'                                                                     'Thermistor'
};


%wave_rutter_sigma_s6_wamos_ii_bridge1  1  sentences

%"PWAM1 - Rutter WaMoS PWAM proprietary message extended with extra variables by BAS"
rtables.wave_rutter_sigma_s6_wamos_ii_bridge1_pwam1 = {  % from wave_rutter_sigma_s6_wamos_ii_bridge1.json
'wave_rutter_sigma_s6_wamos_ii_bridge1_pwam1' 37 []  % fields
       'significantWaveHeight'                            'm'                                                  'Significant_Wave_Height_(XHS)'
           'maximumWaveHeight'                            'm'                                                    'Maximum_Wave_Height_(HSMAX)'
                   'periodTM2'                            's'                                                              'Period_(TM2_def.)'
                   'periodTM0'                            's'                                                              'Period_(TM0_def.)'
           'peakWaveDirection'                      'degrees'                                       'Peak_Wave_Direction_(coming_from)_(PDIR)'
                  'peakPeriod'                            's'                                                               'Peak_Period_(TP)'
              'peakWavelength'                            'm'                                                           'Peak_Wavelength_(LP)'
           'meanWaveDirection'                      'degrees'                                       'Mean_Wave_Direction_(coming_from)_(MDIR)'
              'meanWavelength'                            'm'                                                          'Mean_Wavelength_(MLP)'
            'waveHeightSwell1'                            'm'                                                    'Wave_Height_Swell_1_(XHS_2)'
             'directionSwell1'                      'degrees'                                                        'Direction_Swell_1_(DPS)'
                'periodSwell1'                            's'                                                           'Period_Swell_1_(TPS)'
            'wavelengthSwell1'                            'm'                                                       'Wavelength_Swell_1_(LPS)'
             'directionSwell2'                      'degrees'                                                      'Direction_Swell_2_(DPS_2)'
                'periodSwell2'                            's'                                                         'Period_Swell_2_(TPS_2)'
            'wavelengthSwell2'                            'm'                                                     'Wavelength_Swell_2_(LPS_2)'
             'waveHeightWind1'                            'm'                                                     'Wave_Height_Wind_1_(XHS_3)'
              'directionWind1'                      'degrees'                                                        'Direction_Swell_1_(DPW)'
                 'periodWind1'                            's'                                                            'Period_Wind_1_(TPW)'
             'wavelengthWind1'                            'm'                                                        'Wavelength_Wind_1_(LPW)'
              'directionWind2'                      'degrees'                                                       'Direction_Wind_2_(DPW_2)'
                 'periodWind2'                            's'                                                          'Period_Wind_2_(TPW_2)'
             'wavelengthWind2'                            'm'                                                      'Wavelength_Wind_2_(LPW_2)'
           'meanWaveSpreading'                             ''                                                      'Mean_Wave_Spreading_(SPR)'
               'crossSeaIndex'                             ''                                                         'Cross-Sea_Index__(CSI)'
          'frequencyThreshold'                           'Hz'                          'Frequency_Threshold_to_separate_wind_sea/swell_(SLIM)'
     'surfaceCurrentDirection'                      'degrees'          'Surface_Current_Direction_(geographically_oriented__going_to)_(CURRD)'
         'surfaceCurrentSpeed'                          'm/s'                                                  'Surface_Current_Speed_(CURRS)'
   'encounterCurrentDirection'                      'degrees'        'Encounter_Current_Direction_(geographically_oriented__going_to)_(ENCUD)'
       'encounterCurrentSpeed'                          'm/s'                                                'Encounter_Current_Speed_(ENCUS)'
   'currentDirectionduetoship'                      'degrees'                                          'Current_Direction_Due_To_Ship_(DSHIP)'
       'currentSpeedDueToShip'                          'm/s'                                              'Current_Speed_Due_To_Ship_(SSHIP)'
           'trueWindDirection'                      'degrees'                                                    'True_Wind_Direction_(TWINR)'
            'trueWindSpeed10m'                          'm/s'                                                    '10m_True_Wind_Speed_(TWINS)'
                'compassValue'                      'degrees'                                                          'Compass_Value_(GYROC)'
                   'timestamp'                             ''                                                                      'Timestamp'
                'qualityIndex'                             ''                                                                  'Quality_Index'
};


%winch_sda_v3  1  sentences

%"SDAWINCH – Cable logging system data based on ODIM telegram v3"
rtables.winch_sda_v3_sdawinch = {  % from winch_sda_v3.json
'winch_sda_v3_sdawinch' 72 []  % fields
             'headerMessageID'                             ''                                                              'Header_Message_ID'
       'headerNumberOfRetries'                             ''                                                       'Header_Number_of_Retries'
           'headerWantReceipt'                             ''                                                            'Header_Want_Receipt'
   'headerNumberByteFollowing'                             ''                                               'Header_Number_of_Bytes_Following'
%    'headerDestinationObject'                             ''                                                      'Header_Destination_Object'
          'headerOriginObject'                             ''                                                           'Header_Origin_Object'
               'headerCommand'                             ''                                                                 'Header_Command'
   'headerNumberBytesUserData'                             ''                                               'Header_Number_of_Bytes_User_Data'
              'messageCounter'                             ''                                                                'Message_Counter'
           'GPOutboardTension'                           'kg'                                               'General_Purpose_Outboard_Tension'
            'GPInboardTension'                           'kg'                                                'General_Purpose_Inboard_Tension'
            'GPCableLengthOut'                       'metres'                                               'General_Purpose_Cable_Length_Out'
             'GPDeployedDepth'                       'metres'                                                 'General_Purpose_Deployed_Depth'
                 'GPLineSpeed'                          'm/s'                                                     'General_Purpose_Line_Speed'
%           'GPSelectedStatus'                             ''                                                'General_Purpose_Selected_Status'
% 'GPActiveHeaveCompensationEnabledStatus'                             ''                       'General_Purpose_Active_Heave_Compensation_Enabled_Status'
    'GPOverboardPointSelected'                             ''                                       'General_Purpose_Overboard_Point_Selected'
%          'GPSpareStatusByte'                             ''                                              'General_Purpose_Spare_Status_Byte'
          'CTDOutboardTension'                           'kg'                                                           'CTD_Outboard_Tension'
           'CTDInboardTension'                           'kg'                                                            'CTD_Inboard_Tension'
           'CTDCableLengthOut'                       'metres'                                                           'CTD_Cable_Length_Out'
            'CTDDeployedDepth'                       'metres'                                                             'CTD_Deployed_Depth'
                'CTDLineSpeed'                          'm/s'                                                                 'CTD_Line_Speed'
%          'CTDSelectedStatus'                             ''                                                            'CTD_Selected_Status'
% 'CTDActiveHeaveCompensationEnabledStatus'                             ''                                   'CTD_Active_Heave_Compensation_Enabled_Status'
   'CTDOverboardPointSelected'                             ''                                                   'CTD_Overboard_Point_Selected'
%         'CTDSpareStatusByte'                             ''                                                          'CTD_Spare_Status_Byte'
      'DeepTowOutboardTension'                           'kg'                                                      'Deep_Tow_Outboard_Tension'
       'DeepTowInboardTension'                           'kg'                                                       'Deep_Tow_Inboard_Tension'
       'DeepTowCableLengthOut'                       'metres'                                                      'Deep_Tow_Cable_Length_Out'
        'DeepTowDeployedDepth'                       'metres'                                                        'Deep_Tow_Deployed_Depth'
            'DeepTowLineSpeed'                          'm/s'                                                            'Deep_Tow_Line_Speed'
%      'DeepTowSelectedStatus'                             ''                                                       'Deep_Tow_Selected_Status'
% 'DeepTowActiveHeaveCompensationEnabledStatus'                             ''                              'Deep_Tow_Active_Heave_Compensation_Enabled_Status'
'DeepTowOverboardPointSelected'                             ''                                              'Deep_Tow_Overboard_Point_Selected'
%     'DeepTowSpareStatusByte'                             ''                                                     'Deep_Tow_Spare_Status_Byte'
        'CorerOutboardTension'                           'kg'                                                         'Corer_Outboard_Tension'
         'CorerInboardTension'                           'kg'                                                  'Corer_Purpose_Inboard_Tension'
         'CorerCableLengthOut'                       'metres'                                                         'Corer_Cable_Length_Out'
     'CorerCableDeployedDepth'                       'metres'                                                     'Corer_Cable_Deployed_Depth'
              'CorerLineSpeed'                          'm/s'                                                               'Corer_Line_Speed'
%        'CorerSelectedStatus'                             ''                                                          'Corer_Selected_Status'
% 'CorerActiveHeaveCompensationEnabledStatus'                             ''                                 'Corer_Active_Heave_Compensation_Enabled_Status'
 'CorerOverboardPointSelected'                             ''                                                 'Corer_Overboard_Point_Selected'
%       'CorerSpareStatusByte'                             ''                                                        'Corer_Spare_Status_Byte'
      'BioWireOutboardTension'                           'kg'                                                  'Biology_Wire_Outboard_Tension'
       'BioWireInboardTension'                           'kg'                                                   'Biology_Wire_Inboard_Tension'
       'BioWireCableLengthOut'                       'metres'                                                  'Biology_Wire_Cable_Length_Out'
        'BioWireDeployedDepth'                       'metres'                                                    'Biology_Wire_Deployed_Depth'
            'BioWireLineSpeed'                          'm/s'                                                        'Biology_Wire_Line_Speed'
%      'BioWireSelectedStatus'                             ''                                                   'Biology_Wire_Selected_Status'
% 'BioWireActiveHeaveCompensationEnabledStatus'                             ''                          'Biology_Wire_Active_Heave_Compensation_Enabled_Status'
'BioWireOverboardPointSelected'                             ''                                          'Biology_Wire_Overboard_Point_Selected'
%     'BioWireSpareStatusByte'                             ''                                                 'Biology_Wire_Spare_Status_Byte'
        'HydroOutboardTension'                           'kg'                                                    'Hydro_Wire_Outboard_Tension'
         'HydroInboardTension'                           'kg'                                                     'Hydro_Wire_Inboard_Tension'
         'HydroCableLengthOut'                       'metres'                                                    'Hydro_Wire_Cable_Length_Out'
          'HydroDeployedDepth'                       'metres'                                                      'Hydro_Wire_Deployed_Depth'
              'HydroLineSpeed'                          'm/s'                                                          'Hydro_Wire_Line_Speed'
%        'HydroSelectedStatus'                             ''                                                     'Hydro_Wire_Selected_Status'
% 'HydroActiveHeaveCompensationEnabledStatus'                             ''                                         'Hydro_Wire_Active_Heave_Enabled_Status'
 'HydroOverboardPointSelected'                             ''                                            'Hydro_Wire_Overboard_Point_Selected'
%       'HydroSpareStatusByte'                             ''                                                   'Hydro_Wire_Spare_Status_Byte'
        'MFCTDOutboardTension'                           'kg'                                                'Metal_Free_CTD_Outboard_Tension'
         'MFCTDInboardTension'                           'kg'                                                 'Metal_Free_CTD_Inboard_Tension'
         'MFCTDCableLengthOut'                       'metres'                                                'Metal_Free_CTD_Cable_Length_Out'
          'MFCTDDeployedDepth'                       'metres'                                                  'Metal_Free_CTD_Deployed_Depth'
              'MFCTDLineSpeed'                          'm/s'                                                      'Metal_Free_CTD_Line_Speed'
%        'MFCTDSelectedStatus'                             ''                                                 'Metal_Free_CTD_Selected_Status'
% 'MFCTDActiveHeaveCompensationEnabledStatus'                             ''                        'Metal_Free_CTD_Active_Heave_Compensation_Enabled_Status'
 'MFCTDOverboardPointSelected'                             ''                                        'Metal_Free_CTD_Overboard_Point_Selected'
%       'MFCTDSpareStatusByte'                             ''                                               'Metal_Free_CTD_Spare_Status_Byte'
};
