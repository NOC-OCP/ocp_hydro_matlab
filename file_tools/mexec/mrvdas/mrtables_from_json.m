function rtables = mrtables_from_json
% function rtables = mrtables_from_json
% Make the list of rvdas tables that mexec may want to copy.
% The rtables created in this script, along with mrnames_new, will
% define which variables are loaded when a table is loaded from rvdas.
% Units are collected from the json files.
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
 


%adcp-dy  1  sentences

%"VDVBW"
rtables.adcp_vdvbw = {  % from adcp-dy.json
'adcp_vdvbw'  6 []  % fields
      'longitudinalWaterSpeed'                             ''                                                         'longitudinalWaterSpeed'
        'transverseWaterSpeed'                             ''                                                           'transverseWaterSpeed'
%                    'status1'                             ''                                                                        'status1'
     'longitudinalGroundSpeed'                             ''                                                        'longitudinalGroundSpeed'
       'transverseGroundSpeed'                             ''                                                          'transverseGroundSpeed'
%                    'status2'                             ''                                                                        'status2'
};


%autosal-dy  1  sentences

%"AUTOSAL"
rtables.autosal_autosal = {  % from autosal-dy.json
'autosal_autosal'  1 []  % fields
                 'Temperature'                             ''                                                                    'Temperature'
};


%cnav-dy  6  sentences

%"GNGGA"
rtables.cnav_gngga = {  % from cnav-dy.json
'cnav_gngga' 14 []  % fields
                     'utcTime'                             ''                                                                        'utcTime'
                    'latitude'                             ''                                                                       'latitude'
                      'latDir'                             ''                                                                         'latDir'
                   'longitude'                             ''                                                                      'longitude'
                      'lonDir'                             ''                                                                         'lonDir'
%                    'ggaQual'                             ''                                                                        'ggaQual'
%                     'numSat'                             ''                                                                         'numSat'
%                       'hdop'                             ''                                                                           'hdop'
                    'altitude'                             ''                                                                       'altitude'
%      'unitsOfMeasureAntenna'                             ''                                                          'unitsOfMeasureAntenna'
%              'geoidAltitude'                             ''                                                                  'geoidAltitude'
%        'unitsOfMeasureGeoid'                             ''                                                            'unitsOfMeasureGeoid'
%                   'diffcAge'                             ''                                                                       'diffcAge'
%                 'dgnssRefId'                             ''                                                                     'dgnssRefId'
};

%"GNVTG"
rtables.cnav_gnvtg = {  % from cnav-dy.json
'cnav_gnvtg'  9 []  % fields
            'courseOverGround'                             ''                                                               'courseOverGround'
%                 'trueCourse'                             ''                                                                     'trueCourse'
%              'magneticTrack'                             ''                                                                  'magneticTrack'
%                      'mFlag'                             ''                                                                          'mFlag'
                  'speedKnots'                             ''                                                                     'speedKnots'
%                      'nFlag'                             ''                                                                          'nFlag'
                   'speedKmph'                             ''                                                                      'speedKmph'
%                      'kFlag'                             ''                                                                          'kFlag'
%            'positioningMode'                             ''                                                                'positioningMode'
};


%ctd-dy  1  sentences

%"SMCTD"
rtables.ctd_smctd = {  % from ctd-dy.json
'ctd_smctd'  8 []  % fields
                       'depth'                       'metres'                                                                          'depth'
                    'altitude'                             ''                                                                       'altitude'
                'temperature1'                             ''                                                                   'temperature1'
                'temperature2'                             ''                                                                   'temperature2'
                   'salinity1'                             ''                                                                      'salinity1'
                   'salinity2'                             ''                                                                      'salinity2'
                      'oxygen'                             ''                                                                         'oxygen'
                'fluorescence'                             ''                                                                   'fluorescence'
};


%ea640-dy  2  sentences

%"SDDPT"
rtables.ea640_sddpt = {  % from ea640-dy.json
'ea640_sddpt'  2 []  % fields
   'waterDepthMetreTransducer'                             ''                                                      'waterDepthMetreTransducer'
            'transduceroffset'                             ''                                                               'transduceroffset'
};

%"SDDBS"
rtables.ea640_sddbs = {  % from ea640-dy.json
'ea640_sddbs'  6 []  % fields
%  'waterDepthFeetFromSurface'                             ''                                                      'waterDepthFeetFromSurface'
%                   'feetFlag'                             ''                                                                       'feetFlag'
  'waterDepthMetreFromSurface'                             ''                                                     'waterDepthMetreFromSurface'
%                  'metreFlag'                             ''                                                                      'metreFlag'
% 'waterDepthFathomFromSurface'                             ''                                                    'waterDepthFathomFromSurface'
%                 'fathomFlag'                             ''                                                                     'fathomFlag'
};


%em122-dy  1  sentences

%"KIDPT"
rtables.em122_kidpt = {  % from em122-dy.json
'em122_kidpt'  3 []  % fields
             'waterDepthMetre'                       'metres'                                                                'waterDepthMetre'
            'transducerOffset'                             ''                                                               'transducerOffset'
%                   'maxRange'                             ''                                                                       'maxRange'
};


%envtemp-dy  2  sentences

%"WIMTA"
rtables.envtemp_wimta = {  % from envtemp-dy.json
'envtemp_wimta'  2 []  % fields
              'airTemperature'                             ''                                                                 'airTemperature'
%                'celsiusFlag'                             ''                                                                    'celsiusFlag'
};

%"WIMHU"
rtables.envtemp_wimhu = {  % from envtemp-dy.json
'envtemp_wimhu'  4 []  % fields
                    'humidity'                             ''                                                                       'humidity'
         'temperatureDewPoint'                             ''                                                            'temperatureDewPoint'
%                       'flag'                             ''                                                                           'flag'
%                'celsiusFlag'                             ''                                                                    'celsiusFlag'
};


%fugro-dy  8  sentences

%"GPGGA"
rtables.fugro_gpgga = {  % from fugro-dy.json
'fugro_gpgga' 14 []  % fields
                     'utcTime'                             ''                                                                        'utcTime'
                    'latitude'                             ''                                                                       'latitude'
                      'latDir'                             ''                                                                         'latDir'
                   'longitude'                             ''                                                                      'longitude'
                      'lonDir'                             ''                                                                         'lonDir'
%                    'ggaQual'                             ''                                                                        'ggaQual'
%                     'numSat'                             ''                                                                         'numSat'
%                       'hdop'                             ''                                                                           'hdop'
                    'altitude'                             ''                                                                       'altitude'
%      'unitsOfMeasureAntenna'                             ''                                                          'unitsOfMeasureAntenna'
%              'geoidAltitude'                             ''                                                                  'geoidAltitude'
%        'unitsOfMeasureGeoid'                             ''                                                            'unitsOfMeasureGeoid'
%                   'diffcAge'                             ''                                                                       'diffcAge'
%                 'dgnssRefId'                             ''                                                                     'dgnssRefId'
};

%"GPVTG"
rtables.fugro_gpvtg = {  % from fugro-dy.json
'fugro_gpvtg'  9 []  % fields
            'courseOverGround'                             ''                                                               'courseOverGround'
%                 'trueCourse'                             ''                                                                     'trueCourse'
%              'magneticTrack'                             ''                                                                  'magneticTrack'
%                      'mFlag'                             ''                                                                          'mFlag'
                  'speedKnots'                             ''                                                                     'speedKnots'
%                      'nFlag'                             ''                                                                          'nFlag'
                   'speedKmph'                             ''                                                                      'speedKmph'
%                      'kFlag'                             ''                                                                          'kFlag'
%            'positioningMode'                             ''                                                                'positioningMode'
};

%"GPGLL"
rtables.fugro_gpgll = {  % from fugro-dy.json
'fugro_gpgll'  7 []  % fields
                    'latitude'                             ''                                                                       'latitude'
                      'latDir'                             ''                                                                         'latDir'
                   'longitude'                             ''                                                                      'longitude'
                      'lonDir'                             ''                                                                         'lonDir'
                     'utcTime'                             ''                                                                        'utcTime'
%                    'gllQual'                             ''                                                                        'gllQual'
%            'positioningMode'                             ''                                                                'positioningMode'
};


%phins-dy 16  sentences

%"HEHDT"
rtables.phins_hehdt = {  % from phins-dy.json
'phins_hehdt'  2 []  % fields
                 'headingTrue'                             ''                                                                    'headingTrue'
%            'headingTrueFlag'                             ''                                                                'headingTrueFlag'
};

%"PIXSEATITUD"
rtables.phins_pixseatitud = {  % from phins-dy.json
'phins_pixseatitud'  2 []  % fields
                        'roll'                             ''                                                                           'roll'
                       'pitch'                             ''                                                                          'pitch'
};

%"PIXSEPOSITI"
rtables.phins_pixsepositi = {  % from phins-dy.json
'phins_pixsepositi'  3 []  % fields
                  'latitudeDD'                             ''                                                                     'latitudeDD'
                 'longitudeDD'                             ''                                                                    'longitudeDD'
                    'altitude'                             ''                                                                       'altitude'
};

%"PIXSESPEED0"
rtables.phins_pixsespeed0 = {  % from phins-dy.json
'phins_pixsespeed0'  3 []  % fields
                       'xEast'                             ''                                                                          'xEast'
                      'xNorth'                             ''                                                                         'xNorth'
                         'xUp'                             ''                                                                            'xUp'
};

%"PIXSEUTMWGS"
rtables.phins_pixseutmwgs = {  % from phins-dy.json
'phins_pixseutmwgs'  5 []  % fields
             'latitudeUTMZone'                             ''                                                                'latitudeUTMZone'
            'longitudeUTMZone'                             ''                                                               'longitudeUTMZone'
                'eastPosition'                             ''                                                                   'eastPosition'
               'northPosition'                             ''                                                                  'northPosition'
                    'altitude'                             ''                                                                       'altitude'
};

%"PIXSEHEAVE0"
rtables.phins_pixseheave0 = {  % from phins-dy.json
'phins_pixseheave0'  3 []  % fields
                       'surge'                             ''                                                                          'surge'
                        'sway'                             ''                                                                           'sway'
                       'heave'                             ''                                                                          'heave'
};

%"PIXSETIME00"
rtables.phins_pixsetime00 = {  % from phins-dy.json
'phins_pixsetime00'  1 []  % fields
                     'utcTime'                             ''                                                                        'utcTime'
};

%"PIXSESTDHRP"
rtables.phins_pixsestdhrp = {  % from phins-dy.json
'phins_pixsestdhrp'  3 []  % fields
                  'headingStd'                             ''                                                                     'headingStd'
                     'rollStd'                             ''                                                                        'rollStd'
                    'pitchStd'                             ''                                                                       'pitchStd'
};

%"PIXSESTDPOS"
rtables.phins_pixsestdpos = {  % from phins-dy.json
'phins_pixsestdpos'  3 []  % fields
%                'latitudeStd'                             ''                                                                    'latitudeStd'
%               'longitudeStd'                             ''                                                                   'longitudeStd'
%                'altitudeStd'                             ''                                                                    'altitudeStd'
};

%"PIXSESTDSPD"
rtables.phins_pixsestdspd = {  % from phins-dy.json
'phins_pixsestdspd'  3 []  % fields
               'northSpeedStd'                             ''                                                                  'northSpeedStd'
                'eastSpeedStd'                             ''                                                                   'eastSpeedStd'
            'verticalSpeedStd'                             ''                                                               'verticalSpeedStd'
};

%"PIXSEUTCIN0"
rtables.phins_pixseutcin0 = {  % from phins-dy.json
'phins_pixseutcin0'  1 []  % fields
                     'utcTime'                             ''                                                                        'utcTime'
};

%"PIXSEGPSIN0"
rtables.phins_pixsegpsin0 = {  % from phins-dy.json
'phins_pixsegpsin0'  5 []  % fields
                  'latitudeDD'                             ''                                                                     'latitudeDD'
                 'longitudeDD'                             ''                                                                    'longitudeDD'
                    'altitude'                             ''                                                                       'altitude'
                     'utcTime'                             ''                                                                        'utcTime'
            'qualityIndicator'                             ''                                                               'qualityIndicator'
};

%"PIXSEALGSTS"
rtables.phins_pixsealgsts = {  % from phins-dy.json
'phins_pixsealgsts'  2 []  % fields
%                 'status1LSB'                             ''                                                                     'status1LSB'
%                 'status2MSB'                             ''                                                                     'status2MSB'
};

%"PIXSESTATUS"
rtables.phins_pixsestatus = {  % from phins-dy.json
'phins_pixsestatus'  2 []  % fields
%                 'status1LSB'                             ''                                                                     'status1LSB'
%                 'status2MSB'                             ''                                                                     'status2MSB'
};

%"PIXSEHT0STS"
rtables.phins_pixseht0sts = {  % from phins-dy.json
'phins_pixseht0sts'  1 []  % fields
%           'status1HighLevel'                             ''                                                               'status1HighLevel'
};


%posmv-dy  8  sentences

%"GPHDT"
rtables.posmv_gphdt = {  % from posmv-dy.json
'posmv_gphdt'  2 []  % fields
                 'headingTrue'                             ''                                                                    'headingTrue'
%                'trueHeading'                             ''                                                                    'trueHeading'
};

%"PASHR"
rtables.posmv_pashr = {  % from posmv-dy.json
'posmv_pashr' 11 []  % fields
                     'utcTime'                             ''                                                                        'utcTime'
                     'heading'                             ''                                                                        'heading'
%                   'trueFlag'                             ''                                                                       'trueFlag'
                        'roll'                             ''                                                                           'roll'
                       'pitch'                             ''                                                                          'pitch'
                       'heave'                             ''                                                                          'heave'
                'rollAccuracy'                             ''                                                                   'rollAccuracy'
               'pitchAccuracy'                             ''                                                                  'pitchAccuracy'
             'headingAccuracy'                             ''                                                                'headingAccuracy'
%        'headingAccuracyFlag'                             ''                                                            'headingAccuracyFlag'
%                    'imuFlag'                             ''                                                                        'imuFlag'
};

%"GPGGA"
rtables.posmv_gpgga = {  % from posmv-dy.json
'posmv_gpgga' 14 []  % fields
                     'utcTime'                             ''                                                                        'utcTime'
                    'latitude'              'decimal degrees'                                                                       'latitude'
                      'latDir'                             ''                                                                         'latDir'
                   'longitude'              'decimal degrees'                                                                      'longitude'
                      'lonDir'                             ''                                                                         'lonDir'
%                    'ggaQual'                             ''                                                                        'ggaQual'
%                     'numSat'                             ''                                                                         'numSat'
%                       'hdop'                             ''                                                                           'hdop'
                    'altitude'                             ''                                                                       'altitude'
%      'unitsOfMeasureAntenna'                             ''                                                          'unitsOfMeasureAntenna'
%              'geoidAltitude'                             ''                                                                  'geoidAltitude'
%        'unitsOfMeasureGeoid'                             ''                                                            'unitsOfMeasureGeoid'
%                   'diffcAge'                             ''                                                                       'diffcAge'
%                 'dgnssRefId'                             ''                                                                     'dgnssRefId'
};

%"GPVTG"
rtables.posmv_gpvtg = {  % from posmv-dy.json
'posmv_gpvtg'  9 []  % fields
                  'courseTrue'                             ''                                                                     'courseTrue'
%                 'trueCourse'                             ''                                                                     'trueCourse'
%              'magneticTrack'                             ''                                                                  'magneticTrack'
%                      'mFlag'                             ''                                                                          'mFlag'
                  'speedKnots'                             ''                                                                     'speedKnots'
%                      'nFlag'                             ''                                                                          'nFlag'
                   'speedKmph'                             ''                                                                      'speedKmph'
%                      'kFlag'                             ''                                                                          'kFlag'
%            'positioningMode'                             ''                                                                'positioningMode'
};


%ranger2usbl2-dy  1  sentences

%"GPGGA"
rtables.ranger2usbl2_gpgga = {  % from ranger2usbl2-dy.json
'ranger2usbl2_gpgga' 14 []  % fields
                     'utcTime'                             ''                                                                        'utcTime'
                    'latitude'                             ''                                                                       'latitude'
                      'latDir'                             ''                                                                         'latDir'
                   'longitude'                             ''                                                                      'longitude'
                      'lonDir'                             ''                                                                         'lonDir'
%                    'ggaQual'                             ''                                                                        'ggaQual'
%                     'numSat'                             ''                                                                         'numSat'
%                       'hdop'                             ''                                                                           'hdop'
                    'altitude'                             ''                                                                       'altitude'
%      'unitsOfMeasureAntenna'                             ''                                                          'unitsOfMeasureAntenna'
%              'geoidAltitude'                             ''                                                                  'geoidAltitude'
%        'unitsOfMeasureGeoid'                             ''                                                            'unitsOfMeasureGeoid'
%                   'diffcAge'                             ''                                                                       'diffcAge'
%                 'dgnssRefId'                             ''                                                                     'dgnssRefId'
};


%ranger2usbl-dy  2  sentences

%"GPGGA"
rtables.ranger2usbl_gpgga = {  % from ranger2usbl-dy.json
'ranger2usbl_gpgga' 14 []  % fields
                     'utcTime'                             ''                                                                        'utcTime'
                    'latitude'                             ''                                                                       'latitude'
                      'latDir'                             ''                                                                         'latDir'
                   'longitude'                             ''                                                                      'longitude'
                      'lonDir'                             ''                                                                         'lonDir'
%                    'ggaQual'                             ''                                                                        'ggaQual'
%                     'numSat'                             ''                                                                         'numSat'
%                       'hdop'                             ''                                                                           'hdop'
                    'altitude'                             ''                                                                       'altitude'
%      'unitsOfMeasureAntenna'                             ''                                                          'unitsOfMeasureAntenna'
%              'geoidAltitude'                             ''                                                                  'geoidAltitude'
%         'unisOfMeasureGeoid'                             ''                                                             'unisOfMeasureGeoid'
%                   'diffcAge'                             ''                                                                       'diffcAge'
%                 'dgnssRefId'                             ''                                                                     'dgnssRefId'
};

%"PSONLLD"
rtables.ranger2usbl_psonlld = {  % from ranger2usbl-dy.json
'ranger2usbl_psonlld' 13 []  % fields
                     'UTCTime'                             ''                                                                        'UTCTime'
                          'id'                             ''                                                                             'id'
%                     'status'                             ''                                                                         'status'
                         'lat'              'decimal degrees'                                                                            'lat'
                         'lon'              'decimal degrees'                                                                            'lon'
                       'depth'                       'metres'                                                                          'depth'
                 'horErrMajor'                             ''                                                                    'horErrMajor'
                'horrErrMinor'                             ''                                                                   'horrErrMinor'
                  'depthError'                             ''                                                                     'depthError'
                'optionalSpec'                             ''                                                                   'optionalSpec'
                        'opt1'                             ''                                                                           'opt1'
                        'opt2'                             ''                                                                           'opt2'
                        'opt3'                             ''                                                                           'opt3'
};


%rex2-dy  1  sentences

%"PRAMR"
rtables.rex2_pramr = {  % from rex2-dy.json
'rex2_pramr' 10 []  % fields
             'dateTimeFromWVC'                             ''                                                                'dateTimeFromWVC'
                   'julianDay'                             ''                                                                      'julianDay'
                         'SSE'                             ''                                                                            'SSE'
                       'h4rms'                             ''                                                                          'h4rms'
                          'tz'                             ''                                                                             'tz'
                    'rexrange'                             ''                                                                       'rexrange'
                        'hmax'                             ''                                                                           'hmax'
                      'hcrest'                             ''                                                                         'hcrest'
                          'tp'                             ''                                                                             'tp'
                          'tc'                             ''                                                                             'tc'
};


%salrmtemp-dy  1  sentences

%"SALIN"
rtables.salrmtemp_salin = {  % from salrmtemp-dy.json
'salrmtemp_salin' 16 []  % fields
                    'sn17Temp'              'degrees celsius'                                                                       'sn17Temp'
                'sn17TempTime'                             ''                                                                   'sn17TempTime'
                     'sn17Hum'                      'percent'                                                                        'sn17Hum'
                 'sn17HumTime'                             ''                                                                    'sn17HumTime'
                    'sn18Temp'              'degrees celsius'                                                                       'sn18Temp'
                'sn18TempTime'                             ''                                                                   'sn18TempTime'
                     'sn18Hum'                      'percent'                                                                        'sn18Hum'
                 'sn18HumTime'                             ''                                                                    'sn18HumTime'
                    'sn19Temp'              'degrees celsius'                                                                       'sn19Temp'
                'sn19TempTime'                             ''                                                                   'sn19TempTime'
                     'sn19Hum'                      'percent'                                                                        'sn19Hum'
                 'sn19HumTime'                             ''                                                                    'sn19HumTime'
                    'sn20Temp'              'degrees celsius'                                                                       'sn20Temp'
                'sn20TempTime'                             ''                                                                   'sn20TempTime'
                     'sn20Hum'                      'percent'                                                                        'sn20Hum'
                 'sn20HumTime'                             ''                                                                    'sn20HumTime'
};


%sbe38dk-dy  1  sentences

%"SBE38"
rtables.sbe38dk_sbe38 = {  % from sbe38dk-dy.json
'sbe38dk_sbe38'  1 []  % fields
                      'tempdk'              'degrees Celcius'                                                                         'tempdk'
};


%sbe38-dy  1  sentences

%"SBE38"
rtables.sbe38_sbe38 = {  % from sbe38-dy.json
'sbe38_sbe38'  1 []  % fields
                      'tempdk'              'degrees Celcius'                                                                         'tempdk'
};


%sbe45-dy  1  sentences

%"NANAN"
rtables.sbe45_nanan = {  % from sbe45-dy.json
'sbe45_nanan'  5 []  % fields
                       'tempH'                             ''                                                                          'tempH'
                'conductivity'                             ''                                                                   'conductivity'
                    'salinity'                             ''                                                                       'salinity'
               'soundVelocity'                             ''                                                                  'soundVelocity'
                       'tempR'              'degrees Celcius'                                                                          'tempR'
};


%seapathatt-dy  4  sentences

%"PSXN23"
rtables.seapathatt_psxn23 = {  % from seapathatt-dy.json
'seapathatt_psxn23'  4 []  % fields
                        'roll'                             ''                                                                           'roll'
                       'pitch'                             ''                                                                          'pitch'
                     'heading'                             ''                                                                        'heading'
                       'heave'                             ''                                                                          'heave'
};

%"PSXN20"
rtables.seapathatt_psxn20 = {  % from seapathatt-dy.json
'seapathatt_psxn20'  4 []  % fields
            'rollPitchQuality'                             ''                                                               'rollPitchQuality'
              'headingQuality'                             ''                                                                 'headingQuality'
               'heightQuality'                             ''                                                                  'heightQuality'
   'horizontalPositionQuality'                             ''                                                      'horizontalPositionQuality'
};

%"INGGA"
rtables.seapathatt_ingga = {  % from seapathatt-dy.json
'seapathatt_ingga' 14 []  % fields
                     'utcTime'                             ''                                                                        'utcTime'
                    'latitude'                             ''                                                                       'latitude'
                      'latDir'                             ''                                                                         'latDir'
                   'longitude'                             ''                                                                      'longitude'
                      'lonDir'                             ''                                                                         'lonDir'
%                    'ggaQual'                             ''                                                                        'ggaQual'
%                     'numSat'                             ''                                                                         'numSat'
%                       'hdop'                             ''                                                                           'hdop'
                    'altitude'                             ''                                                                       'altitude'
%      'unitsOfMeasureAntenna'                             ''                                                          'unitsOfMeasureAntenna'
%              'geoidAltitude'                             ''                                                                  'geoidAltitude'
%        'unitsOfMeasureGeoid'                             ''                                                            'unitsOfMeasureGeoid'
%                   'diffcAge'                             ''                                                                       'diffcAge'
%                 'dgnssRefId'                             ''                                                                     'dgnssRefId'
};


%seapathpos-dy  7  sentences

%"INGGA"
rtables.seapathpos_ingga = {  % from seapathpos-dy.json
'seapathpos_ingga' 14 []  % fields
                     'utcTime'                             ''                                                                        'utcTime'
                    'latitude'                             ''                                                                       'latitude'
                      'latDir'                             ''                                                                         'latDir'
                   'longitude'                             ''                                                                      'longitude'
                      'lonDir'                             ''                                                                         'lonDir'
%                    'ggaQual'                             ''                                                                        'ggaQual'
%                     'numSat'                             ''                                                                         'numSat'
%                       'hdop'                             ''                                                                           'hdop'
                    'altitude'                             ''                                                                       'altitude'
%      'unitsOfMeasureAntenna'                             ''                                                          'unitsOfMeasureAntenna'
%              'geoidAltitude'                             ''                                                                  'geoidAltitude'
%        'unitsofMeasureGeoid'                             ''                                                            'unitsofMeasureGeoid'
%                   'diffcAge'                             ''                                                                       'diffcAge'
%                 'dgnssRefId'                             ''                                                                     'dgnssRefId'
};

%"INHDT"
rtables.seapathpos_inhdt = {  % from seapathpos-dy.json
'seapathpos_inhdt'  2 []  % fields
                 'headingTrue'                             ''                                                                    'headingTrue'
%                'headingFlag'                             ''                                                                    'headingFlag'
};

%"INVTG"
rtables.seapathpos_invtg = {  % from seapathpos-dy.json
'seapathpos_invtg'  9 []  % fields
            'courseOverGround'                             ''                                                               'courseOverGround'
%                   'TrueFlag'                             ''                                                                       'TrueFlag'
%             'magneticCourse'                             ''                                                                 'magneticCourse'
%                      'mFlag'                             ''                                                                          'mFlag'
                  'speedKnots'                             ''                                                                     'speedKnots'
%                      'nFlag'                             ''                                                                          'nFlag'
                   'speedKmph'                             ''                                                                      'speedKmph'
%                      'kFlag'                             ''                                                                          'kFlag'
%            'positioningMode'                             ''                                                                'positioningMode'
};

%"INRMC"
rtables.seapathpos_inrmc = {  % from seapathpos-dy.json
'seapathpos_inrmc' 12 []  % fields
                     'utcTime'                             ''                                                                        'utcTime'
%                      'vFlag'                             ''                                                                          'vFlag'
                    'latitude'                             ''                                                                       'latitude'
                      'latDir'                             ''                                                                         'latDir'
                   'longitude'                             ''                                                                      'longitude'
                      'lonDir'                             ''                                                                         'lonDir'
                  'speedKnots'                             ''                                                                     'speedKnots'
                     'heading'                             ''                                                                        'heading'
                     'navDate'                             ''                                                                        'navDate'
%                     'magvar'                             ''                                                                         'magvar'
%                  'magVarDir'                             ''                                                                      'magVarDir'
%            'positioningMode'                             ''                                                                'positioningMode'
};


%shipsgyro-dy  2  sentences

%"HEHDT"
rtables.shipsgyro_hehdt = {  % from shipsgyro-dy.json
'shipsgyro_hehdt'  2 []  % fields
                 'headingTrue' 'degrees (clockwise from the true north)'                                                                    'headingTrue'
%                'trueHeading'                             ''                                                                    'trueHeading'
};

%"TIROT"
rtables.shipsgyro_tirot = {  % from shipsgyro-dy.json
'shipsgyro_tirot'  2 []  % fields
                  'rateOfTurn'                             ''                                                                     'rateOfTurn'
%                  'rotStatus'                             ''                                                                      'rotStatus'
};


%skipperlog-dy  6  sentences

%"VDVBW"
rtables.skipperlog_vdvbw = {  % from skipperlog-dy.json
'skipperlog_vdvbw' 10 []  % fields
      'longitudinalWaterSpeed'                             ''                                                         'longitudinalWaterSpeed'
        'transverseWaterSpeed'                             ''                                                           'transverseWaterSpeed'
%                    'status1'                             ''                                                                        'status1'
     'longitudinalGroundSpeed'                             ''                                                        'longitudinalGroundSpeed'
       'transverseGroundSpeed'                             ''                                                          'transverseGroundSpeed'
%                    'status2'                             ''                                                                        'status2'
%                       'vbw7'                             ''                                                                           'vbw7'
%                       'vbw8'                             ''                                                                           'vbw8'
%                       'vbw9'                             ''                                                                           'vbw9'
%                      'vbw10'                             ''                                                                          'vbw10'
};

%"VDVHW"
rtables.skipperlog_vdvhw = {  % from skipperlog-dy.json
'skipperlog_vdvhw'  8 []  % fields
                 'headingTrue'                             ''                                                                    'headingTrue'
%            'headingTrueFlag'                             ''                                                                'headingTrueFlag'
%            'headingMagnetic'                             ''                                                                'headingMagnetic'
%        'headingMagneticFlag'                             ''                                                            'headingMagneticFlag'
                  'speedKnots'                             ''                                                                     'speedKnots'
%                      'nFlag'                             ''                                                                          'nFlag'
                   'speedKmph'                             ''                                                                      'speedKmph'
%                      'kFlag'                             ''                                                                          'kFlag'
};

%"IIDPT"
rtables.skipperlog_iidpt = {  % from skipperlog-dy.json
'skipperlog_iidpt'  3 []  % fields
             'waterDepthMetre'                             ''                                                                'waterDepthMetre'
                     'offsetT'                             ''                                                                        'offsetT'
%                   'maxRange'                             ''                                                                       'maxRange'
};

%"VDVTG"
rtables.skipperlog_vdvtg = {  % from skipperlog-dy.json
'skipperlog_vdvtg'  9 []  % fields
            'courseOverGround'                             ''                                                               'courseOverGround'
%                 'trueCourse'                             ''                                                                     'trueCourse'
%              'magneticTrack'                             ''                                                                  'magneticTrack'
%                      'mFlag'                             ''                                                                          'mFlag'
                  'speedKnots'                             ''                                                                     'speedKnots'
%                      'nFlag'                             ''                                                                          'nFlag'
                   'speedKmph'                             ''                                                                      'speedKmph'
%                      'kFlag'                             ''                                                                          'kFlag'
%            'positioningMode'                             ''                                                                'positioningMode'
};

%"VDMTW"
rtables.skipperlog_vdmtw = {  % from skipperlog-dy.json
'skipperlog_vdmtw'  2 []  % fields
   'waterTemperatureinCelsius'                             ''                                                      'waterTemperatureinCelsius'
%                'celsiusFlag'                             ''                                                                    'celsiusFlag'
};

%"VDVLW"
rtables.skipperlog_vdvlw = {  % from skipperlog-dy.json
'skipperlog_vdvlw'  4 []  % fields
                         'TCD'                             ''                                                                            'TCD'
%                      'ddes1'                             ''                                                                          'ddes1'
                         'DSR'                             ''                                                                            'DSR'
%                      'ddes2'                             ''                                                                          'ddes2'
};


%surfmet-dy  4  sentences

%"GPXSM"
rtables.surfmet_gpxsm = {  % from surfmet-dy.json
'surfmet_gpxsm' 14 []  % fields
                       'flow1'                             ''                                                                          'flow1'
                      'tempdk'              'degrees Celcius'                                                                         'tempdk'
                       'flow3'                             ''                                                                          'flow3'
                        'fluo'                             ''                                                                           'fluo'
                       'trans'                             ''                                                                          'trans'
                   'windSpeed'                        'm*s-1'                                                                      'windSpeed'
               'windDirection' 'degrees (clockwise from the bow)'                                                                  'windDirection'
              'airTemperature'              'degrees celsius'                                                                 'airTemperature'
                    'Humidity'                      'percent'                                                                       'Humidity'
                 'airPressure'                          'hPa'                                                                    'airPressure'
                     'parPort'                         'Wm-2'                                                                        'parPort'
                'parStarboard'                         'Wm-2'                                                                   'parStarboard'
                     'Tirport'                         'Wm-2'                                                                        'Tirport'
                'TirStarboard'                         'Wm-2'                                                                   'TirStarboard'
};

%"SFMET"
rtables.surfmet_sfmet = {  % from surfmet-dy.json
'surfmet_sfmet'  3 []  % fields
                 'airPressure'                          'hPa'                                                                    'airPressure'
              'airTemperature'              'degrees celsius'                                                                 'airTemperature'
                    'humidity'                      'percent'                                                                       'humidity'
};

%"SFLGT"
rtables.surfmet_sflgt = {  % from surfmet-dy.json
'surfmet_sflgt'  4 []  % fields
                     'tirPort'                         'Wm-2'                                                                        'tirPort'
                     'parPort'                         'Wm-2'                                                                        'parPort'
                'tirStarboard'                         'Wm-2'                                                                   'tirStarboard'
                'parStarboard'                         'Wm-2'                                                                   'parStarboard'
};

%"SFUWY"
rtables.surfmet_sfuwy = {  % from surfmet-dy.json
'surfmet_sfuwy'  3 []  % fields
                        'fluo'                             ''                                                                           'fluo'
                       'trans'                             ''                                                                          'trans'
                        'flow'                             ''                                                                           'flow'
};


%tempconv-dy  1  sentences

%"TEMPCONV"
rtables.tempconv_tempconv = {  % from tempconv-dy.json
'tempconv_tempconv'  2 []  % fields
                          'TW'                             ''                                                                             'TW'
                          'TD'                             ''                                                                             'TD'
};


%truewind-dy  1  sentences

%"TRUEWIND"
rtables.truewind_truewind = {  % from truewind-dy.json
'truewind_truewind'  2 []  % fields
           'truewinddirection'                             ''                                                              'truewinddirection'
               'truewindspeed'                             ''                                                                  'truewindspeed'
};


%usbl beacon position in gga-dy  1  sentences

%"GPGGA"
rtables.usbl beacon position in gga_gpgga = {  % from usbl beacon position in gga-dy.json
'usbl beacon position in gga_gpgga' 14 []  % fields
                     'utcTime'                             ''                                                                        'utcTime'
                    'latitude'                             ''                                                                       'latitude'
                      'latDir'                             ''                                                                         'latDir'
                   'longitude'                             ''                                                                      'longitude'
                      'lonDir'                             ''                                                                         'lonDir'
%                    'ggaQual'                             ''                                                                        'ggaQual'
%                     'numSat'                             ''                                                                         'numSat'
%                       'hdop'                             ''                                                                           'hdop'
                    'altitude'                             ''                                                                       'altitude'
%      'unitsOfMeasureAntenna'                             ''                                                          'unitsOfMeasureAntenna'
%              'geoidAltitude'                             ''                                                                  'geoidAltitude'
%         'unisOfMeasureGeoid'                             ''                                                             'unisOfMeasureGeoid'
%                   'diffcAge'                             ''                                                                       'diffcAge'
%                 'dgnssRefId'                             ''                                                                     'dgnssRefId'
};


%usblpson-dy  1  sentences

%"PSONLLD"
rtables.usblpson_psonlld = {  % from usblpson-dy.json
'usblpson_psonlld' 13 []  % fields
                   'TimeValid'                             ''                                                                      'TimeValid'
                          'id'                             ''                                                                             'id'
%                     'status'                             ''                                                                         'status'
                         'lat'                             ''                                                                            'lat'
                        'long'                             ''                                                                           'long'
                       'depth'                             ''                                                                          'depth'
                 'horErrMajor'                             ''                                                                    'horErrMajor'
                'horrErrMinor'                             ''                                                                   'horrErrMinor'
                  'depthError'                             ''                                                                     'depthError'
                'optionalSpec'                             ''                                                                   'optionalSpec'
                        'opt1'                             ''                                                                           'opt1'
                        'opt2'                             ''                                                                           'opt2'
                        'opt3'                             ''                                                                           'opt3'
};


%wamos-dy  1  sentences

%"PWAM"
rtables.wamos_pwam = {  % from wamos-dy.json
'wamos_pwam' 16 []  % fields
                          'hs'                             ''                                                                             'hs'
                         'tm2'                             ''                                                                            'tm2'
                        'pdir'                             ''                                                                           'pdir'
                          'tp'                             ''                                                                             'tp'
                          'lp'                             ''                                                                             'lp'
                         'dp1'                             ''                                                                            'dp1'
                         'tp1'                             ''                                                                            'tp1'
                         'lp1'                             ''                                                                            'lp1'
                         'dp2'                             ''                                                                            'dp2'
                         'tp2'                             ''                                                                            'tp2'
                         'lp2'                             ''                                                                            'lp2'
                  'currentdir'                             ''                                                                     'currentdir'
                'currentspeed'                             ''                                                                   'currentspeed'
                         'stw'                             ''                                                                            'stw'
                        'hmax'                             ''                                                                           'hmax'
                         'ctw'                             ''                                                                            'ctw'
};


%winch-dy  1  sentences

%"WINCH"
rtables.winch_winch = {  % from winch-dy.json
'winch_winch'  8 []  % fields
%                 'winchDatum'                             ''                                                                     'winchDatum'
%                  'cableType'                             ''                                                                      'cableType'
                     'tension'                             ''                                                                        'tension'
                    'cableOut'                             ''                                                                       'cableOut'
                        'rate'                             ''                                                                           'rate'
                 'backTension'                             ''                                                                    'backTension'
                   'rollAngle'                             ''                                                                      'rollAngle'
%                  'undefined'                             ''                                                                      'undefined'
};


%windsonic-dy  1  sentences

%"IIMWV"
rtables.windsonic_iimwv = {  % from windsonic-dy.json
'windsonic_iimwv'  5 []  % fields
               'windDirection' 'degrees (clockwise from the bow)'                                                                  'windDirection'
%                 'relWindDes'                             ''                                                                     'relWindDes'
                   'windSpeed'                        'm*s-1'                                                                      'windSpeed'
%                  'speedUnit'                             ''                                                                      'speedUnit'
%                     'status'                             ''                                                                         'status'
};
