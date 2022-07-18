function [rtables,rtables_list] = mrtables_from_json
% Make the list of rvdas tables that mexec may want to copy.
% The rtables created in this script will define which variables are loaded
% when a table is loaded from rvdas. Units are collected from the json files
% The content of this file was obtained by using the script mrjson_load_all.m
% Variables and/or tables can subsequently be commented out
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
 


%cnav-jc-2022-01-01T000000Z-null  9  sentences

%"GNGGA"
rtables.cnav_gngga = {  % from cnav-jc-2022-01-01T000000Z-null.json
'cnav_gngga' 14  % fields
                     'UTCTime'                             ''
                    'latitude'  'degrees and decimal minutes'
                      'latdir'                             ''
                   'longitude'  'degrees and decimal minutes'
                      'londir'                             ''
                     'ggaQual'                             ''
                      'numsat'                             ''
                        'hdop'                             ''
                    'altitude'                       'metres'
             'unitsOfAltitude'                             ''
%                'geoidAltitude'                       'metres'
%          'unitOfGeoidAltitude'                             ''
%                     'diffcAge'                             ''
%                   'dgnssRefid'                             ''
};

%"GNGLL"
rtables.cnav_gngll = {  % from cnav-jc-2022-01-01T000000Z-null.json
'cnav_gngll'  7  % fields
                    'latitude'  'degrees and decimal minutes'
                      'latdir'                             ''
                   'longitude'  'degrees and decimal minutes'
                      'londir'                             ''
                     'UTCTime'                             ''
%                    'recStatus'                             ''
%              'positioningMode'                             ''
};

%"GNRMC"
rtables.cnav_gnrmc = {  % from cnav-jc-2022-01-01T000000Z-null.json
'cnav_gnrmc' 13  % fields
                     'UTCTime'                             ''
                   'recStatus'                             ''
                    'latitude'  'degrees and decimal minutes'
                      'latdir'                             ''
                   'longitude'  'degrees and decimal minutes'
                      'londir'                             ''
                         'sog'                        'knots'
                         'tmg'                      'degrees'
%                      'UTCDate'                             ''
%                       'magvar'                      'degrees'
%                    'magvarDir'                             ''
%              'positioningMode'                             ''
%                    'navStatus'                             ''
};

%"GNVTG"
rtables.cnav_gnvtg = {  % from cnav-jc-2022-01-01T000000Z-null.json
'cnav_gnvtg'  9  % fields
                         'cog'                      'degrees'
                      'desCog'                             ''
                        'cogm'                      'degrees'
                     'desCogm'                             ''
                         'sog'                        'knots'
                      'desSog'                             ''
                     'sogkmph'          'Kilometre per hours'
                  'desSogKmph'                             ''
             'positioningMode'                             ''
};

%"GNZDA"
rtables.cnav_gnzda = {  % from cnav-jc-2022-01-01T000000Z-null.json
'cnav_gnzda'  6  % fields
                     'UTCTime'                             ''
                         'day'                             ''
                       'month'                             ''
                        'year'                             ''
                    'zoneHour'                             ''
                 'zoneMinutes'                             ''
};

%"GNGSA"
rtables.cnav_gngsa = {  % from cnav-jc-2022-01-01T000000Z-null.json
'cnav_gngsa' 18  % fields
                     'gsaMode'                             ''
                   'gsaStatus'                             ''
                        'sId1'                             ''
                        'sId2'                             ''
                        'sId3'                             ''
                        'sId4'                             ''
                        'sId5'                             ''
                        'sId6'                             ''
                        'sId7'                             ''
                       'sId10'                             ''
                        'sId8'                             ''
                        'sId9'                             ''
                       'sId11'                             ''
                       'sId12'                             ''
                        'pdop'                             ''
                        'hdop'                             ''
                        'vdop'                             ''
                        'gsId'                             ''
};

%"GNDTM"
rtables.cnav_gndtm = {  % from cnav-jc-2022-01-01T000000Z-null.json
'cnav_gndtm'  8  % fields
                   'datumCode'                             ''
                'subDatumCode'                             ''
                   'latOffset'                             ''
                      'latdir'                             ''
                   'lonOffset'                             ''
                      'londir'                             ''
              'altitudeOffset'                             ''
          'referenceDatumCode'                             ''
};

%"GPGSV"
rtables.cnav_gpgsv = {  % from cnav-jc-2022-01-01T000000Z-null.json
'cnav_gpgsv' 20  % fields
              'messageTotalNo'                             ''
                   'messageNo'                             ''
                     'totalSv'                             ''
                       'svId1'                             ''
                     'svElev1'                      'degrees'
                      'svAzi1'                      'degrees'
                      'svSNR1'                      'decibel'
                       'svId2'                             ''
                     'svElev2'                      'degrees'
                      'svAzi2'                      'degrees'
                      'svSNR2'                      'decibel'
                       'svId3'                             ''
                     'svElev3'                      'degrees'
                      'svAzi3'                      'degrees'
                      'svSNR3'                      'decibel'
                       'svId4'                             ''
                     'svElev4'                      'degrees'
                      'svAzi4'                      'degrees'
                      'svSNR4'                      'decibel'
                    'signalId'                             ''
};

%"GLGSV"
rtables.cnav_glgsv = {  % from cnav-jc-2022-01-01T000000Z-null.json
'cnav_glgsv' 20  % fields
              'messageTotalNo'                             ''
                   'messageNo'                             ''
                     'totalSv'                             ''
                       'svId1'                             ''
                       'svId2'                             ''
                       'svId3'                             ''
                       'svId4'                             ''
                     'svElev1'                      'degrees'
                     'svElev2'                      'degrees'
                     'svElev3'                      'degrees'
                     'svElev4'                      'degrees'
                      'svAzi1'                      'degrees'
                      'svAzi2'                      'degrees'
                      'svAzi3'                      'degrees'
                      'svAzi4'                      'degrees'
                      'svSNR1'                      'decibel'
                      'svSNR2'                      'decibel'
                      'svSNR3'                      'decibel'
                      'svSNR4'                      'decibel'
                    'signalId'                             ''
};


%ea640-jc-2022-02-04T064000Z-null  2  sentences

%"SDDPT"
rtables.ea640_sddpt = {  % from ea640-jc-2022-02-04T064000Z-null.json
'ea640_sddpt'  2  % fields
                       'depth'                       'metres'
            'transducerOffset'                             ''
};

%"SDDBS"
rtables.ea640_sddbs = {  % from ea640-jc-2022-02-04T064000Z-null.json
'ea640_sddbs'  6  % fields
                   'depthFeet'                         'Feet'
                    'flagFeet'                             ''
                  'depthMeter'                       'metres'
                   'flagMeter'                             ''
                  'deptFathom'                       'fathom'
                  'flagFathom'                             ''
};


%em122-jc-2022-02-01T150300Z-null  1  sentences

%"KIDPT"
rtables.em122_kidpt = {  % from em122-jc-2022-02-01T150300Z-null.json
'em122_kidpt'  3  % fields
             'waterDepthMeter'                             ''
            'transducerOffset'                             ''
                    'maxRange'                             ''
};


%envtemp-jc-2022-02-01T174900Z-null  2  sentences

%"WIMTA"
rtables.envtemp_wimta = {  % from envtemp-jc-2022-02-01T174900Z-null.json
'envtemp_wimta'  2  % fields
              'airTemperature'               'degreesCelsius'
                 'celsiusFlag'                             ''
};

%"WIMHU"
rtables.envtemp_wimhu = {  % from envtemp-jc-2022-02-01T174900Z-null.json
'envtemp_wimhu'  4  % fields
                    'humidity'                   'percentage'
                'FlagHumidity'                             ''
         'temperatureDewPoint'               'degreesCelsius'
                 'flagCelsius'                             ''
};


%posmv-jc-2022-02-03T184700Z-null  8  sentences

%"PRDID"
rtables.posmv_prdid = {  % from posmv-jc-2022-02-03T184700Z-null.json
'posmv_prdid'  3  % fields
                       'pitch'                      'degrees'
                        'roll'                      'degrees'
                     'heading'                      'degrees'
};

%"GPGGK"
rtables.posmv_gpggk = {  % from posmv-jc-2022-02-03T184700Z-null.json
'posmv_gpggk' 11  % fields
                     'UTCTime'                             ''
                     'UTCDate'                             ''
                    'latitude'  'degrees and decimal minutes'
                      'latdir'                             ''
                   'longitude'  'degrees and decimal minutes'
                      'londir'                             ''
                     'ggaQual'                             ''
                      'numsat'                             ''
                        'pdop'                             ''
                         'eht'                             ''
                     'ethUnit'                             ''
};

%"GPGGA"
rtables.posmv_gpgga = {  % from posmv-jc-2022-02-03T184700Z-null.json
'posmv_gpgga' 14  % fields
                     'UTCTime'                             ''
                    'latitude'  'degrees and decimal minutes'
                      'latdir'                             ''
                   'longitude'  'degrees and decimal minutes'
                      'londir'                             ''
                     'ggaQual'                             ''
                      'numsat'                             ''
                        'hdop'                             ''
                    'altitude'                       'metres'
             'unitsOfAltitude'                             ''
               'geoidAltitude'                             ''
         'unitOfGeoidAltitude'                             ''
                    'diffcAge'                             ''
                  'dgnssRefid'                             ''
};

%"GPHDT"
rtables.posmv_gphdt = {  % from posmv-jc-2022-02-03T184700Z-null.json
'posmv_gphdt'  2  % fields
                     'heading'                      'degrees'
                  'desHeading'                             ''
};

%"GPVTG"
rtables.posmv_gpvtg = {  % from posmv-jc-2022-02-03T184700Z-null.json
'posmv_gpvtg'  9  % fields
                         'cog'                      'degrees'
                      'desCog'                             ''
                        'cogm'                      'degrees'
                     'desCogm'                             ''
                         'sog'                        'knots'
                      'desSog'                             ''
                     'sogkmph'          'Kilometre per hours'
                  'desSogKmph'                             ''
             'positioningMode'                             ''
};

%"GPRMC"
rtables.posmv_gprmc = {  % from posmv-jc-2022-02-03T184700Z-null.json
'posmv_gprmc' 12  % fields
                     'UTCTime'                             ''
                   'recStatus'                             ''
                    'latitude'  'degrees and decimal minutes'
                      'latdir'                             ''
                   'longitude'  'degrees and decimal minutes'
                      'londir'                             ''
                         'sog'                        'knots'
                         'tmg'                      'degrees'
                     'UTCDate'                             ''
                      'magvar'                             ''
                   'magvarDir'                             ''
             'positioningMode'                             ''
};

%"GPZDA"
rtables.posmv_gpzda = {  % from posmv-jc-2022-02-03T184700Z-null.json
'posmv_gpzda'  6  % fields
                     'UTCTime'                             ''
                         'day'                             ''
                       'month'                             ''
                        'year'                             ''
                    'zoneHour'                             ''
                 'zoneMinutes'                             ''
};

%"PASHR"
rtables.posmv_pashr = {  % from posmv-jc-2022-02-03T184700Z-null.json
'posmv_pashr' 11  % fields
                     'UTCTime'                             ''
                     'heading'                      'degrees'
                  'desHeading'                             ''
                        'roll'                      'degrees'
                       'pitch'                      'degrees'
                       'heave'                       'metres'
                'rollAccuracy'                             ''
               'pitchAccuracy'                             ''
              'headingAcuracy'                             ''
         'headingAccuracyFlag'                             ''
                     'imuFlag'                             ''
};


%ranger2usbl-jc-2022-02-04T072000Z-null  1  sentences

%"GPGGA"
rtables.ranger2usbl_gpgga = {  % from ranger2usbl-jc-2022-02-04T072000Z-null.json
'ranger2usbl_gpgga' 14  % fields
                     'UTCTime'                             ''
                    'latitude'  'degrees and decimal minutes'
                      'latdir'                             ''
                   'longitude'  'degrees and decimal minutes'
                      'londir'                             ''
                     'ggaQual'                             ''
                      'numsat'                             ''
                        'hdop'                             ''
                    'altitude'                       'metres'
             'unitsOfAltitude'                             ''
               'geoidAltitude'                       'metres'
         'unitOfGeoidAltitude'                             ''
                    'diffcAge'                             ''
                  'dgnssRefid'                             ''
};


%rex2-jc-2022-02-10T110000Z-null  2  sentences

%"PRAMR"
rtables.rex2_pramr = {  % from rex2-jc-2022-02-10T110000Z-null.json
'rex2_pramr'  9  % fields
             'dateTimeFromWVC'                             ''
                   'julianDay'                             ''
                      'airgap'                             ''
                       'h4rms'                             ''
                        'tz_s'                             ''
                        'hmax'                             ''
                      'hcrest'                             ''
                        'tp_s'                             ''
                        'tc_s'                             ''
};

%"3RR0R"
rtables.rex2_3rr0r = {  % from rex2-jc-2022-02-10T110000Z-null.json
'rex2_3rr0r'  1  % fields
                     'message'                             ''
};


%sbe38dropkeel-jc-2022-02-04T133000Z-null  1  sentences

%"SBE38"
rtables.sbe38dropkeel_sbe38 = {  % from sbe38dropkeel-jc-2022-02-04T133000Z-null.json
'sbe38dropkeel_sbe38'  1  % fields
                       'tempr'                         'degC'
};


%sbe45-jc-2022-01-01T000000Z-null  1  sentences

%"NANaN"
rtables.sbe45_nanan = {  % from sbe45-jc-2022-01-01T000000Z-null.json
'sbe45_nanan'  5  % fields
                       'temph'                         'degC'
                'conductivity'                             ''
                    'salinity'                             ''
               'soundVelocity'             'meter per second'
                       'tempr'                         'degC'
};


%seapathatt-jc-2022-02-03T184800Z-null  3  sentences

%"INGGA"
rtables.seapathatt_ingga = {  % from seapathatt-jc-2022-02-03T184800Z-null.json
'seapathatt_ingga' 14  % fields
                     'UTCTime'                             ''
                    'latitude'  'degrees and decimal minutes'
                      'latdir'                             ''
                   'longitude'  'degrees and decimal minutes'
                      'londir'                             ''
                     'ggaQual'                             ''
                      'numsat'                             ''
                        'hdop'                             ''
                    'altitude'                       'metres'
             'unitsOfAltitude'                             ''
               'geoidAltitude'                             ''
         'unitOfGeoidAltitude'                             ''
                    'diffcAge'                             ''
                  'dgnssRefid'                             ''
};

%"PSXN23"
rtables.seapathatt_psxn23 = {  % from seapathatt-jc-2022-02-03T184800Z-null.json
'seapathatt_psxn23'  4  % fields
                        'roll'                      'degrees'
                       'pitch'                      'degrees'
                     'heading'                      'degrees'
                       'heave'                       'metres'
};

%"PSXN20"
rtables.seapathatt_psxn20 = {  % from seapathatt-jc-2022-02-03T184800Z-null.json
'seapathatt_psxn20'  4  % fields
           'horizontalQuality'                             ''
               'heightQuality'                             ''
              'headingQuality'                             ''
            'pitchRollQuality'                             ''
};


%seapathgps-jc-2022-02-03T184800Z-null 10  sentences

%"INGGA"
rtables.seapathgps_ingga = {  % from seapathgps-jc-2022-02-03T184800Z-null.json
'seapathgps_ingga' 14  % fields
                     'UTCTime'                             ''
                    'latitude'  'degrees and decimal minutes'
                      'latdir'                             ''
                   'longitude'  'degrees and decimal minutes'
                      'londir'                             ''
                     'ggaQual'                             ''
                      'numsat'                             ''
                        'hdop'                             ''
                    'altitude'                       'metres'
             'unitsOfAltitude'                             ''
               'geoidAltitude'                       'metres'
         'unitOfGeoidAltitude'                             ''
                    'diffcAge'                             ''
                  'dgnssRefid'                             ''
};

%"INHDT"
rtables.seapathgps_inhdt = {  % from seapathgps-jc-2022-02-03T184800Z-null.json
'seapathgps_inhdt'  2  % fields
                     'heading'                      'degrees'
                  'desHeading'                             ''
};

%"INVTG"
rtables.seapathgps_invtg = {  % from seapathgps-jc-2022-02-03T184800Z-null.json
'seapathgps_invtg'  9  % fields
                         'cog'                      'degrees'
                      'desCog'                             ''
                        'cogm'                      'degrees'
                     'desCogm'                             ''
                         'sog'                        'knots'
                      'desSog'                             ''
                     'sogkmph'          'Kilometre per hours'
                  'desSogKmph'                             ''
             'positioningMode'                             ''
};

%"INRMC"
rtables.seapathgps_inrmc = {  % from seapathgps-jc-2022-02-03T184800Z-null.json
'seapathgps_inrmc' 12  % fields
                     'UTCTime'                             ''
                   'recStatus'                             ''
                    'latitude'  'degrees and decimal minutes'
                      'latdir'                             ''
                   'longitude'  'degrees and decimal minutes'
                      'londir'                             ''
                         'sog'                        'knots'
                         'tmg'                      'degrees'
                     'UTCDate'                             ''
                      'magvar'                             ''
                   'magvarDir'                             ''
             'positioningMode'                             ''
};

%"INZDA"
rtables.seapathgps_inzda = {  % from seapathgps-jc-2022-02-03T184800Z-null.json
'seapathgps_inzda'  6  % fields
                     'UTCTime'                             ''
                         'day'                             ''
                       'month'                             ''
                        'year'                             ''
                    'zoneHour'                             ''
                 'zoneMinutes'                             ''
};

%"GPGSA"
rtables.seapathgps_gpgsa = {  % from seapathgps-jc-2022-02-03T184800Z-null.json
'seapathgps_gpgsa' 17  % fields
                     'gsaMode'                             ''
                   'gsaStatus'                             ''
                        'sId1'                             ''
                        'sId2'                             ''
                        'sId3'                             ''
                        'sId4'                             ''
                        'sId5'                             ''
                        'sId6'                             ''
                        'sId7'                             ''
                        'sId8'                             ''
                        'sId9'                             ''
                       'sId10'                             ''
                       'sId11'                             ''
                       'sId12'                             ''
                        'pdop'                             ''
                        'hdop'                             ''
                        'vdop'                             ''
};

%"INGLL"
rtables.seapathgps_ingll = {  % from seapathgps-jc-2022-02-03T184800Z-null.json
'seapathgps_ingll'  7  % fields
                    'latitude'  'degrees and decimal minutes'
                      'latdir'                             ''
                   'longitude'  'degrees and decimal minutes'
                      'londir'                             ''
                     'UTCTime'                             ''
                   'recStatus'                             ''
             'positioningMode'                             ''
};

%"GPGSV"
rtables.seapathgps_gpgsv = {  % from seapathgps-jc-2022-02-03T184800Z-null.json
'seapathgps_gpgsv' 19  % fields
              'messageTotalNo'                             ''
                   'messageNo'                             ''
                     'totalSv'                             ''
                       'svId1'                             ''
                     'svElev1'                             ''
                      'svAzi1'                             ''
                      'svSNR1'                      'decibel'
                       'svId2'                             ''
                     'svElev2'                             ''
                      'svAzi2'                             ''
                      'svSNR2'                      'decibel'
                       'svId3'                             ''
                     'svElev3'                             ''
                      'svAzi3'                             ''
                      'svSNR3'                      'decibel'
                       'svId4'                             ''
                     'svElev4'                             ''
                      'svAzi4'                             ''
                      'svSNR4'                      'decibel'
};

%"GLGSV"
rtables.seapathgps_glgsv = {  % from seapathgps-jc-2022-02-03T184800Z-null.json
'seapathgps_glgsv' 19  % fields
              'messageTotalNo'                             ''
                   'messageNo'                             ''
                     'totalSv'                             ''
                       'svId1'                             ''
                     'svElev1'                             ''
                      'svAzi1'                             ''
                      'svSNR1'                             ''
                       'svId2'                             ''
                     'svElev2'                             ''
                      'svAzi2'                             ''
                      'svSNR2'                      'decibel'
                       'svId3'                             ''
                     'svElev3'                             ''
                      'svAzi3'                             ''
                      'svSNR3'                      'decibel'
                       'svId4'                             ''
                     'svElev4'                             ''
                      'svAzi4'                             ''
                      'svSNR4'                      'decibel'
};

%"GNGSA"
rtables.seapathgps_gngsa = {  % from seapathgps-jc-2022-02-03T184800Z-null.json
'seapathgps_gngsa' 17  % fields
                      'saMode'                             ''
                       'PMode'                             ''
                        'sat1'                             ''
                        'sat2'                             ''
                        'sat3'                             ''
                        'sat4'                             ''
                        'sat5'                             ''
                        'sat6'                             ''
                        'sat7'                             ''
                        'sat8'                             ''
                        'sat9'                             ''
                       'sat10'                             ''
                       'sat11'                             ''
                        'pdop'                             ''
                        'hdop'                             ''
                        'vdop'                             ''
                       'sat12'                             ''
};


%sgyro-jc-2022-02-04T070000Z-null  4  sentences

%"HEHDT"
rtables.sgyro_hehdt = {  % from sgyro-jc-2022-02-04T070000Z-null.json
'sgyro_hehdt'  2  % fields
                     'heading'                      'degrees'
                  'desHeading'                             ''
};

%"HCHDM"
rtables.sgyro_hchdm = {  % from sgyro-jc-2022-02-04T070000Z-null.json
'sgyro_hchdm'  2  % fields
                     'heading'                      'degrees'
                  'desHeading'                             ''
};

%"TIROT"
rtables.sgyro_tirot = {  % from sgyro-jc-2022-02-04T070000Z-null.json
'sgyro_tirot'  2  % fields
                         'rot'                             ''
                   'rotStatus'                             ''
};

%"PPNSD"
rtables.sgyro_ppnsd = {  % from sgyro-jc-2022-02-04T070000Z-null.json
'sgyro_ppnsd'  8  % fields
                         'dm1'                             ''
                         'dm2'                             ''
                         'dm3'                             ''
                         'dm4'                             ''
                         'dm5'                             ''
                         'dm6'                             ''
                         'dm7'                             ''
                         'dm8'                             ''
};


%slogchernikeef-jc-2022-02-04T130800Z-null  2  sentences

%"VMVLW"
rtables.slogchernikeef_vmvlw = {  % from slogchernikeef-jc-2022-02-04T130800Z-null.json
'slogchernikeef_vmvlw'  4  % fields
                       'tdist'                             ''
                      'nFlag1'                             ''
                       'rdist'                             ''
                      'nFlag2'                             ''
};

%"VMVBW"
rtables.slogchernikeef_vmvbw = {  % from slogchernikeef-jc-2022-02-04T130800Z-null.json
'slogchernikeef_vmvbw' 10  % fields
                     'speedfa'                             ''
                     'speedps'                             ''
                     'status1'                             ''
               'speedfaGround'                        'knots'
               'speedpsGround'                        'knots'
                     'status2'                             ''
                        'vbw7'                             ''
                        'vbw8'                             ''
                     'status3'                             ''
                       'vbw10'                             ''
};


%surfmet-jc-2022-01-01T000000Z-null  1  sentences

%"GPXSM"
rtables.surfmet_gpxsm = {  % from surfmet-jc-2022-01-01T000000Z-null.json
'surfmet_gpxsm' 12  % fields
                        'flow'                          'l/m'
                        'fluo'                             ''
                       'trans'                            'V'
                   'windSpeed'             'meter per second'
               'windDirection'                      'degrees'
              'airTemperature'               'degreesCelsius'
                    'humidity'                             ''
                 'airPressure'                          'hPa'
                     'parPort'                          'cmV'
                'parStarboard'                          'cmV'
                     'tirPort'                          'cmV'
                'tirStarboard'                          'cmV'
};


%winchlog-jc-2022-02-04T084800Z-null  1  sentences

%"WINCH"
rtables.winchlog_winch = {  % from winchlog-jc-2022-02-04T084800Z-null.json
'winchlog_winch'  8  % fields
                  'winchDatum'                             ''
                   'cableType'                             ''
                     'tension'                        'tonne'
                    'cableOut'                             ''
                        'rate'                             ''
                 'backTension'                        'tonne'
                   'rollAngle'                             ''
                   'undefined'                             ''
};


%windsonicnmea-jc-2022-01-01T120000Z-null  1  sentences

%"IIMWV"
rtables.windsonicnmea_iimwv = {  % from windsonicnmea-jc-2022-01-01T120000Z-null.json
'windsonicnmea_iimwv'  5  % fields
               'windDirection'                      'degrees'
                  'relWindDes'                             ''
                   'windSpeed'             'meter per second'
                   'speedUnit'                             ''
                      'status'                             ''
};

rtables_list = fieldnames(rtables);
