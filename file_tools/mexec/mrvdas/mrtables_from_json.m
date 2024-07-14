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
      'longitudinalWaterSpeed'                             ''
        'transverseWaterSpeed'                             ''
%                    'status1'                             ''
     'longitudinalGroundSpeed'                             ''
       'transverseGroundSpeed'                             ''
%                    'status2'                             ''
};


%autosal-dy  1  sentences

%"AUTOSAL"
rtables.autosal_autosal = {  % from autosal-dy.json
'autosal_autosal'  1 []  % fields
                 'Temperature'                             ''
};


%cnav-dy  6  sentences

%"GNGGA"
rtables.cnav_gngga = {  % from cnav-dy.json
'cnav_gngga' 14 []  % fields
                     'utcTime'                             ''
                    'latitude'                             ''
                      'latDir'                             ''
                   'longitude'                             ''
                      'lonDir'                             ''
%                    'ggaQual'                             ''
%                     'numSat'                             ''
%                       'hdop'                             ''
                    'altitude'                             ''
%      'unitsOfMeasureAntenna'                             ''
%              'geoidAltitude'                             ''
%        'unitsOfMeasureGeoid'                             ''
%                   'diffcAge'                             ''
%                 'dgnssRefId'                             ''
};

%"GNVTG"
rtables.cnav_gnvtg = {  % from cnav-dy.json
'cnav_gnvtg'  9 []  % fields
            'courseOverGround'                             ''
%                 'trueCourse'                             ''
%              'magneticTrack'                             ''
%                      'mFlag'                             ''
                  'speedKnots'                             ''
%                      'nFlag'                             ''
                   'speedKmph'                             ''
%                      'kFlag'                             ''
%            'positioningMode'                             ''
};


%ctd-dy  1  sentences

%"SMCTD"
rtables.ctd_smctd = {  % from ctd-dy.json
'ctd_smctd'  8 []  % fields
                       'depth'                       'metres'
                    'altitude'                             ''
                'temperature1'                             ''
                'temperature2'                             ''
                   'salinity1'                             ''
                   'salinity2'                             ''
                      'oxygen'                             ''
                'fluorescence'                             ''
};


%ea640-dy  2  sentences

%"SDDPT"
rtables.ea640_sddpt = {  % from ea640-dy.json
'ea640_sddpt'  2 []  % fields
   'waterDepthMetreTransducer'                             ''
            'transduceroffset'                             ''
};

%"SDDBS"
rtables.ea640_sddbs = {  % from ea640-dy.json
'ea640_sddbs'  6 []  % fields
%  'waterDepthFeetFromSurface'                             ''
%                   'feetFlag'                             ''
  'waterDepthMetreFromSurface'                             ''
%                  'metreFlag'                             ''
% 'waterDepthFathomFromSurface'                             ''
%                 'fathomFlag'                             ''
};


%em122-dy  1  sentences

%"KIDPT"
rtables.em122_kidpt = {  % from em122-dy.json
'em122_kidpt'  3 []  % fields
             'waterDepthMetre'                       'metres'
            'transducerOffset'                             ''
%                   'maxRange'                             ''
};


%fugro-dy  8  sentences

%"GPGGA"
rtables.fugro_gpgga = {  % from fugro-dy.json
'fugro_gpgga' 14 []  % fields
                     'utcTime'                             ''
                    'latitude'                             ''
                      'latDir'                             ''
                   'longitude'                             ''
                      'lonDir'                             ''
%                    'ggaQual'                             ''
%                     'numSat'                             ''
%                       'hdop'                             ''
                    'altitude'                             ''
%      'unitsOfMeasureAntenna'                             ''
%              'geoidAltitude'                             ''
%        'unitsOfMeasureGeoid'                             ''
%                   'diffcAge'                             ''
%                 'dgnssRefId'                             ''
};

%"GPVTG"
rtables.fugro_gpvtg = {  % from fugro-dy.json
'fugro_gpvtg'  9 []  % fields
            'courseOverGround'                             ''
%                 'trueCourse'                             ''
%              'magneticTrack'                             ''
%                      'mFlag'                             ''
                  'speedKnots'                             ''
%                      'nFlag'                             ''
                   'speedKmph'                             ''
%                      'kFlag'                             ''
%            'positioningMode'                             ''
};

%"GPGLL"
rtables.fugro_gpgll = {  % from fugro-dy.json
'fugro_gpgll'  7 []  % fields
                    'latitude'                             ''
                      'latDir'                             ''
                   'longitude'                             ''
                      'lonDir'                             ''
                     'utcTime'                             ''
%                    'gllQual'                             ''
%            'positioningMode'                             ''
};


%phins-dy 16  sentences

%"HEHDT"
rtables.phins_hehdt = {  % from phins-dy.json
'phins_hehdt'  2 []  % fields
                 'headingTrue'                             ''
%            'headingTrueFlag'                             ''
};

%"PIXSEATITUD"
rtables.phins_pixseatitud = {  % from phins-dy.json
'phins_pixseatitud'  2 []  % fields
                        'roll'                             ''
                       'pitch'                             ''
};

%"PIXSEPOSITI"
rtables.phins_pixsepositi = {  % from phins-dy.json
'phins_pixsepositi'  3 []  % fields
                  'latitudeDD'                             ''
                 'longitudeDD'                             ''
                    'altitude'                             ''
};

%"PIXSESPEED0"
rtables.phins_pixsespeed0 = {  % from phins-dy.json
'phins_pixsespeed0'  3 []  % fields
                       'xEast'                             ''
                      'xNorth'                             ''
                         'xUp'                             ''
};

%"PIXSEUTMWGS"
rtables.phins_pixseutmwgs = {  % from phins-dy.json
'phins_pixseutmwgs'  5 []  % fields
             'latitudeUTMZone'                             ''
            'longitudeUTMZone'                             ''
                'eastPosition'                             ''
               'northPosition'                             ''
                    'altitude'                             ''
};

%"PIXSEHEAVE0"
rtables.phins_pixseheave0 = {  % from phins-dy.json
'phins_pixseheave0'  3 []  % fields
                       'surge'                             ''
                        'sway'                             ''
                       'heave'                             ''
};

%"PIXSETIME00"
rtables.phins_pixsetime00 = {  % from phins-dy.json
'phins_pixsetime00'  1 []  % fields
                     'utcTime'                             ''
};

%"PIXSESTDHRP"
rtables.phins_pixsestdhrp = {  % from phins-dy.json
'phins_pixsestdhrp'  3 []  % fields
                  'headingStd'                             ''
                     'rollStd'                             ''
                    'pitchStd'                             ''
};

%"PIXSESTDPOS"
rtables.phins_pixsestdpos = {  % from phins-dy.json
'phins_pixsestdpos'  3 []  % fields
%                'latitudeStd'                             ''
%               'longitudeStd'                             ''
%                'altitudeStd'                             ''
};

%"PIXSESTDSPD"
rtables.phins_pixsestdspd = {  % from phins-dy.json
'phins_pixsestdspd'  3 []  % fields
               'northSpeedStd'                             ''
                'eastSpeedStd'                             ''
            'verticalSpeedStd'                             ''
};

%"PIXSEUTCIN0"
rtables.phins_pixseutcin0 = {  % from phins-dy.json
'phins_pixseutcin0'  1 []  % fields
                     'utcTime'                             ''
};

%"PIXSEGPSIN0"
rtables.phins_pixsegpsin0 = {  % from phins-dy.json
'phins_pixsegpsin0'  5 []  % fields
                  'latitudeDD'                             ''
                 'longitudeDD'                             ''
                    'altitude'                             ''
                     'utcTime'                             ''
            'qualityIndicator'                             ''
};

%"PIXSEALGSTS"
rtables.phins_pixsealgsts = {  % from phins-dy.json
'phins_pixsealgsts'  2 []  % fields
%                 'status1LSB'                             ''
%                 'status2MSB'                             ''
};

%"PIXSESTATUS"
rtables.phins_pixsestatus = {  % from phins-dy.json
'phins_pixsestatus'  2 []  % fields
%                 'status1LSB'                             ''
%                 'status2MSB'                             ''
};

%"PIXSEHT0STS"
rtables.phins_pixseht0sts = {  % from phins-dy.json
'phins_pixseht0sts'  1 []  % fields
%           'status1HighLevel'                             ''
};


%posmv-dy  8  sentences

%"GPHDT"
rtables.posmv_gphdt = {  % from posmv-dy.json
'posmv_gphdt'  2 []  % fields
                 'headingTrue'                             ''
%                'trueHeading'                             ''
};

%"PASHR"
rtables.posmv_pashr = {  % from posmv-dy.json
'posmv_pashr' 11 []  % fields
                     'utcTime'                             ''
                     'heading'                             ''
%                   'trueFlag'                             ''
                        'roll'                             ''
                       'pitch'                             ''
                       'heave'                             ''
                'rollAccuracy'                             ''
               'pitchAccuracy'                             ''
             'headingAccuracy'                             ''
%        'headingAccuracyFlag'                             ''
%                    'imuFlag'                             ''
};

%"GPGGA"
rtables.posmv_gpgga = {  % from posmv-dy.json
'posmv_gpgga' 14 []  % fields
                     'utcTime'                             ''
                    'latitude'              'decimal degrees'
                      'latDir'                             ''
                   'longitude'              'decimal degrees'
                      'lonDir'                             ''
%                    'ggaQual'                             ''
%                     'numSat'                             ''
%                       'hdop'                             ''
                    'altitude'                             ''
%      'unitsOfMeasureAntenna'                             ''
%              'geoidAltitude'                             ''
%        'unitsOfMeasureGeoid'                             ''
%                   'diffcAge'                             ''
%                 'dgnssRefId'                             ''
};

%"GPVTG"
rtables.posmv_gpvtg = {  % from posmv-dy.json
'posmv_gpvtg'  9 []  % fields
                  'courseTrue'                             ''
%                 'trueCourse'                             ''
%              'magneticTrack'                             ''
%                      'mFlag'                             ''
                  'speedKnots'                             ''
%                      'nFlag'                             ''
                   'speedKmph'                             ''
%                      'kFlag'                             ''
%            'positioningMode'                             ''
};


%ranger2usbl2-dy  1  sentences

%"GPGGA"
rtables.ranger2usbl2_gpgga = {  % from ranger2usbl2-dy.json
'ranger2usbl2_gpgga' 14 []  % fields
                     'utcTime'                             ''
                    'latitude'                             ''
                      'latDir'                             ''
                   'longitude'                             ''
                      'lonDir'                             ''
%                    'ggaQual'                             ''
%                     'numSat'                             ''
%                       'hdop'                             ''
                    'altitude'                             ''
%      'unitsOfMeasureAntenna'                             ''
%              'geoidAltitude'                             ''
%        'unitsOfMeasureGeoid'                             ''
%                   'diffcAge'                             ''
%                 'dgnssRefId'                             ''
};


%ranger2usbl-dy  2  sentences

%"GPGGA"
rtables.ranger2usbl_gpgga = {  % from ranger2usbl-dy.json
'ranger2usbl_gpgga' 14 []  % fields
                     'utcTime'                             ''
                    'latitude'                             ''
                      'latDir'                             ''
                   'longitude'                             ''
                      'lonDir'                             ''
%                    'ggaQual'                             ''
%                     'numSat'                             ''
%                       'hdop'                             ''
                    'altitude'                             ''
%      'unitsOfMeasureAntenna'                             ''
%              'geoidAltitude'                             ''
%         'unisOfMeasureGeoid'                             ''
%                   'diffcAge'                             ''
%                 'dgnssRefId'                             ''
};

%"PSONLLD"
rtables.ranger2usbl_psonlld = {  % from ranger2usbl-dy.json
'ranger2usbl_psonlld' 13 []  % fields
                     'UTCTime'                             ''
                          'id'                             ''
%                     'status'                             ''
                         'lat'              'decimal degrees'
                         'lon'              'decimal degrees'
                       'depth'                       'metres'
                 'horErrMajor'                             ''
                'horrErrMinor'                             ''
                  'depthError'                             ''
                'optionalSpec'                             ''
                        'opt1'                             ''
                        'opt2'                             ''
                        'opt3'                             ''
};


%salrmtemp-dy  1  sentences

%"SALIN"
rtables.salrmtemp_salin = {  % from salrmtemp-dy.json
'salrmtemp_salin' 16 []  % fields
                    'sn17Temp'              'degrees celsius'
                'sn17TempTime'                             ''
                     'sn17Hum'                      'percent'
                 'sn17HumTime'                             ''
                    'sn18Temp'              'degrees celsius'
                'sn18TempTime'                             ''
                     'sn18Hum'                      'percent'
                 'sn18HumTime'                             ''
                    'sn19Temp'              'degrees celsius'
                'sn19TempTime'                             ''
                     'sn19Hum'                      'percent'
                 'sn19HumTime'                             ''
                    'sn20Temp'              'degrees celsius'
                'sn20TempTime'                             ''
                     'sn20Hum'                      'percent'
                 'sn20HumTime'                             ''
};


%sbe38dk-dy  1  sentences

%"SBE38"
rtables.sbe38dk_sbe38 = {  % from sbe38dk-dy.json
'sbe38dk_sbe38'  1 []  % fields
                      'tempdk'              'degrees Celcius'
};


%sbe38-dy  1  sentences

%"SBE38"
rtables.sbe38_sbe38 = {  % from sbe38-dy.json
'sbe38_sbe38'  1 []  % fields
                      'tempdk'              'degrees Celcius'
};


%sbe45-dy  1  sentences

%"NANAN"
rtables.sbe45_nanan = {  % from sbe45-dy.json
'sbe45_nanan'  5 []  % fields
                       'tempH'                             ''
                'conductivity'                             ''
                    'salinity'                             ''
               'soundVelocity'                             ''
                       'tempR'              'degrees Celcius'
};


%seapathatt-dy  4  sentences

%"PSXN23"
rtables.seapathatt_psxn23 = {  % from seapathatt-dy.json
'seapathatt_psxn23'  4 []  % fields
                        'roll'                             ''
                       'pitch'                             ''
                     'heading'                             ''
                       'heave'                             ''
};

%"PSXN20"
rtables.seapathatt_psxn20 = {  % from seapathatt-dy.json
'seapathatt_psxn20'  4 []  % fields
            'rollPitchQuality'                             ''
              'headingQuality'                             ''
               'heightQuality'                             ''
   'horizontalPositionQuality'                             ''
};

%"INGGA"
rtables.seapathatt_ingga = {  % from seapathatt-dy.json
'seapathatt_ingga' 14 []  % fields
                     'utcTime'                             ''
                    'latitude'                             ''
                      'latDir'                             ''
                   'longitude'                             ''
                      'lonDir'                             ''
%                    'ggaQual'                             ''
%                     'numSat'                             ''
%                       'hdop'                             ''
                    'altitude'                             ''
%      'unitsOfMeasureAntenna'                             ''
%              'geoidAltitude'                             ''
%        'unitsOfMeasureGeoid'                             ''
%                   'diffcAge'                             ''
%                 'dgnssRefId'                             ''
};


%seapathpos-dy  7  sentences

%"INGGA"
rtables.seapathpos_ingga = {  % from seapathpos-dy.json
'seapathpos_ingga' 14 []  % fields
                     'utcTime'                             ''
                    'latitude'                             ''
                      'latDir'                             ''
                   'longitude'                             ''
                      'lonDir'                             ''
%                    'ggaQual'                             ''
%                     'numSat'                             ''
%                       'hdop'                             ''
                    'altitude'                             ''
%      'unitsOfMeasureAntenna'                             ''
%              'geoidAltitude'                             ''
%        'unitsofMeasureGeoid'                             ''
%                   'diffcAge'                             ''
%                 'dgnssRefId'                             ''
};

%"INHDT"
rtables.seapathpos_inhdt = {  % from seapathpos-dy.json
'seapathpos_inhdt'  2 []  % fields
                 'headingTrue'                             ''
%                'headingFlag'                             ''
};

%"INVTG"
rtables.seapathpos_invtg = {  % from seapathpos-dy.json
'seapathpos_invtg'  9 []  % fields
            'courseOverGround'                             ''
%                   'TrueFlag'                             ''
%             'magneticCourse'                             ''
%                      'mFlag'                             ''
                  'speedKnots'                             ''
%                      'nFlag'                             ''
                   'speedKmph'                             ''
%                      'kFlag'                             ''
%            'positioningMode'                             ''
};

%"INRMC"
rtables.seapathpos_inrmc = {  % from seapathpos-dy.json
'seapathpos_inrmc' 12 []  % fields
                     'utcTime'                             ''
%                      'vFlag'                             ''
                    'latitude'                             ''
                      'latDir'                             ''
                   'longitude'                             ''
                      'lonDir'                             ''
                  'speedKnots'                             ''
                     'heading'                             ''
                     'navDate'                             ''
%                     'magvar'                             ''
%                  'magVarDir'                             ''
%            'positioningMode'                             ''
};


%shipsgyro-dy  2  sentences

%"HEHDT"
rtables.shipsgyro_hehdt = {  % from shipsgyro-dy.json
'shipsgyro_hehdt'  2 []  % fields
                 'headingTrue' 'degrees (clockwise from the true north)'
%                'trueHeading'                             ''
};

%"TIROT"
rtables.shipsgyro_tirot = {  % from shipsgyro-dy.json
'shipsgyro_tirot'  2 []  % fields
                  'rateOfTurn'                             ''
%                  'rotStatus'                             ''
};


%skipperlog-dy  6  sentences

%"VDVBW"
rtables.skipperlog_vdvbw = {  % from skipperlog-dy.json
'skipperlog_vdvbw' 10 []  % fields
      'longitudinalWaterSpeed'                             ''
        'transverseWaterSpeed'                             ''
%                    'status1'                             ''
     'longitudinalGroundSpeed'                             ''
       'transverseGroundSpeed'                             ''
%                    'status2'                             ''
%                       'vbw7'                             ''
%                       'vbw8'                             ''
%                       'vbw9'                             ''
%                      'vbw10'                             ''
};

%"VDVHW"
rtables.skipperlog_vdvhw = {  % from skipperlog-dy.json
'skipperlog_vdvhw'  8 []  % fields
                 'headingTrue'                             ''
%            'headingTrueFlag'                             ''
%            'headingMagnetic'                             ''
%        'headingMagneticFlag'                             ''
                  'speedKnots'                             ''
%                      'nFlag'                             ''
                   'speedKmph'                             ''
%                      'kFlag'                             ''
};

%"IIDPT"
rtables.skipperlog_iidpt = {  % from skipperlog-dy.json
'skipperlog_iidpt'  3 []  % fields
             'waterDepthMetre'                             ''
                     'offsetT'                             ''
%                   'maxRange'                             ''
};

%"VDVTG"
rtables.skipperlog_vdvtg = {  % from skipperlog-dy.json
'skipperlog_vdvtg'  9 []  % fields
            'courseOverGround'                             ''
%                 'trueCourse'                             ''
%              'magneticTrack'                             ''
%                      'mFlag'                             ''
                  'speedKnots'                             ''
%                      'nFlag'                             ''
                   'speedKmph'                             ''
%                      'kFlag'                             ''
%            'positioningMode'                             ''
};

%"VDMTW"
rtables.skipperlog_vdmtw = {  % from skipperlog-dy.json
'skipperlog_vdmtw'  2 []  % fields
   'waterTemperatureinCelsius'                             ''
%                'celsiusFlag'                             ''
};

%"VDVLW"
rtables.skipperlog_vdvlw = {  % from skipperlog-dy.json
'skipperlog_vdvlw'  4 []  % fields
                         'TCD'                             ''
%                      'ddes1'                             ''
                         'DSR'                             ''
%                      'ddes2'                             ''
};


%surfmet-dy  4  sentences

%"GPXSM"
rtables.surfmet_gpxsm = {  % from surfmet-dy.json
'surfmet_gpxsm' 14 []  % fields
                       'flow1'                             ''
                      'tempdk'              'degrees Celcius'
                       'flow3'                             ''
                        'fluo'                             ''
                       'trans'                             ''
                   'windSpeed'                        'm*s-1'
               'windDirection' 'degrees (clockwise from the bow)'
              'airTemperature'              'degrees celsius'
                    'Humidity'                      'percent'
                 'airPressure'                          'hPa'
                     'parPort'                         'Wm-2'
                'parStarboard'                         'Wm-2'
                     'Tirport'                         'Wm-2'
                'TirStarboard'                         'Wm-2'
};

%"SFMET"
rtables.surfmet_sfmet = {  % from surfmet-dy.json
'surfmet_sfmet'  3 []  % fields
                 'airPressure'                          'hPa'
              'airTemperature'              'degrees celsius'
                    'humidity'                      'percent'
};

%"SFLGT"
rtables.surfmet_sflgt = {  % from surfmet-dy.json
'surfmet_sflgt'  4 []  % fields
                     'tirPort'                         'Wm-2'
                     'parPort'                         'Wm-2'
                'tirStarboard'                         'Wm-2'
                'parStarboard'                         'Wm-2'
};

%"SFUWY"
rtables.surfmet_sfuwy = {  % from surfmet-dy.json
'surfmet_sfuwy'  3 []  % fields
                        'fluo'                             ''
                       'trans'                             ''
                        'flow'                             ''
};


%winch-dy  1  sentences

%"WINCH"
rtables.winch_winch = {  % from winch-dy.json
'winch_winch'  8 []  % fields
%                 'winchDatum'                             ''
%                  'cableType'                             ''
                     'tension'                             ''
                    'cableOut'                             ''
                        'rate'                             ''
                 'backTension'                             ''
                   'rollAngle'                             ''
%                  'undefined'                             ''
};


%windsonic-dy  1  sentences

%"IIMWV"
rtables.windsonic_iimwv = {  % from windsonic-dy.json
'windsonic_iimwv'  5 []  % fields
               'windDirection' 'degrees (clockwise from the bow)'
%                 'relWindDes'                             ''
                   'windSpeed'                        'm*s-1'
%                  'speedUnit'                             ''
%                     'status'                             ''
};
