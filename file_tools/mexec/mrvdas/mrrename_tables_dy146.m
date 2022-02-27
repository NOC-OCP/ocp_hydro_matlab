function [renametables,renametables_list] = mrrename_tables(varargin)
% function [renametables,renametables_list] = mrrename_tables(qflag)
%
% *************************************************************************
% mexec interface for RVDAS data acquisition
% First drafts of scripts for start jc211 28 jan 2021, alongside in Stanley
% 
% Evolution on that cruise by bak, ylf, pa
% *************************************************************************
%
% A list of rvdas variable names and units we wish to rename when read into
%   mexec.  The structures are cut and pasted and replacement names added from the script
%   'mrtables_from_json.m'
%
% The list in this script could be moved elsewhere, but is unlikely to
%   change much from crusie to cruise. It may be added to from time to
%   time.
%
% At the end of the function, ensure that all new variable names are
%   lowerecase, regardless of what has been entered row by row.
%
% Examples
%
%   [renametables,renametables_list] = mrrename_tables;
%
%   [renametables,renametables_list] = mrrename_tables('q');
%
% Input:
% 
%   If qflag has the value 'q', listign to the screen is suppressed.
%   Default ''
%
% Output: 
% 
% renametables. A structure which is a set of rvdas table names and variables that will be
% renamed in mrload after reading into matlab and before writing to mexec.
%
% renamtables_list. A cell array of rvdas tables that will have some renaming done.
%   rename_tables_list = fieldnames(renametables);
%
% Examples of fields for renaming
%    renametables.ships_gyro_hehdt = {'headingTrue'  'degrees'  'heading' 'degrees'}
%    renametables.nmf_winch_winch = {'tension'  'newton'  'tension'  'tonnes'}
%    renametables.posmv_gyro_gphdt = {'headingTrue'  'degrees'  'heading' 'degrees'}
%    renametables.posmv_pos_gpgga = {'latitude'  'degrees and decimal minutes' 'latdegm'  'dddmm'}
%    renametables.posmv_pos_gpgga = {'longitude'  'degrees and decimal minutes' 'londegm'  'dddmm'}


m_common

qflag = ''; % Don't use mrparseflags because that calls mrdefine which calls this function
allargs = varargin;
kq = find(strcmp('q',allargs));
if ~isempty(kq)
    qflag = 'q';
    allargs(kq) = [];
else
    qflag = ''; % qflag = '' if not present as an argument
end



clear renametables


% % % %10_at1m  1  sentences
% % % 
% % % %"UW – AT1M Gravitymeter RAW output message"
% % % renametables.10_at1m_uw    = {  % from 10_at1m.json
% % % '10_at1m_uw   ' 18  % fields
% % %                      'gravity'                         'mGal'
% % %                         'long'                         'Gals'
% % %                        'cross'                         'Gals'
% % %                         'beam'                         'Gals'
% % %                         'temp'               'degreesCelsius'
% % %                     'pressure'                       'inchHg'
% % %                     'elecTemp'               'degreesCelsius'
% % %                          'vcc'                         'mGal'
% % %                           've'                         'mGal'
% % %                           'al'                         'mGal'
% % %                           'ax'                         'mGal'
% % %                       'status'                             ''
% % %                     'checksum'                             ''
% % %                     'latitude'               'DecimalDegrees'
% % %                    'longitude'               'decimalDegrees'
% % %                        'speed'                        'knots'
% % %                       'course'                      'Degrees'
% % %                         'time'                             ''
% % % };


% % % %air2sea_gravity  2  sentences
% % % 
% % % %"DAT – Data Record output message"
% % % renametables.air2sea_gravity_dat   = {  % from air2sea_gravity.json
% % % 'air2sea_gravity_dat  ' 20  % fields
% % %                         'date'                         'date'
% % %                         'time'                         'time'
% % %                    'dayOfYear'                         'jday'
% % %                      'gravity'                           'cu'
% % %                'springTension'                           'cu'
% % %                 'beamPosition'                  'volt*750000'
% % %                          'vcc'                             ''
% % %                           'al'                             ''
% % %                           'ax'                             ''
% % %                           've'                             ''
% % %                          'ax2'                             ''
% % %                        'xacc2'                             ''
% % %                        'lacc2'                             ''
% % %                     'crossAcc'                             ''
% % %                      'longAcc'                          'gal'
% % %                       'eotvos'                         'mGal'
% % %                    'longitude'               'decimalDegrees'
% % %                     'latitude'               'decimalDegrees'
% % %                      'heading'                      'degrees'
% % %                     'velocity'                        'knots'
% % % };

% % % %"ENV – Environment Record output message"
% % % renametables.air2sea_gravity_env   = {  % from air2sea_gravity.json
% % % 'air2sea_gravity_env  ' 15  % fields
% % %                         'date'                         'date'
% % %                         'time'                         'time'
% % %                    'dayOfYear'                         'jday'
% % %                      'meterID'                             ''
% % %                'meterPressure'                        'incHg'
% % %             'meterTemperature'               'degreesCelsius'
% % %           'ambientTemperature'               'degreesCelsius'
% % %                      'kFactor'                             ''
% % %                     'vccCoeff'                             ''
% % %                      'alCoeff'                             ''
% % %                      'axCoeff'                             ''
% % %                      'veCoeff'                             ''
% % %                     'ax2Coeff'                             ''
% % %             'serialFiltLength'                       'second'
% % %                'qcFieltLength'                       'second'
% % % };


% % % %air2sea_s84  2  sentences
% % % 
% % % %"DAT – Data Record output message"
% % % renametables.air2sea_s84_dat   = {  % from air2sea_s84.json
% % % 'air2sea_s84_dat  ' 20  % fields
% % %                         'date'                         'date'
% % %                         'time'                         'time'
% % %                    'dayOfYear'                         'jday'
% % %                      'gravity'                           'cu'
% % %                'springTension'                           'cu'
% % %                 'beamPosition'                  'volt*750000'
% % %                          'vcc'                             ''
% % %                           'al'                             ''
% % %                           'ax'                             ''
% % %                           've'                             ''
% % %                          'ax2'                             ''
% % %                        'xacc2'                             ''
% % %                        'lacc2'                             ''
% % %                     'crossAcc'                             ''
% % %                      'longAcc'                          'gal'
% % %                       'eotvos'                         'mGal'
% % %                    'longitude'               'decimalDegrees'
% % %                     'latitude'               'decimalDegrees'
% % %                      'heading'                      'degrees'
% % %                     'velocity'                        'knots'
% % % };

% % % %"ENV – Environment Record output message"
% % % renametables.air2sea_s84_env   = {  % from air2sea_s84.json
% % % 'air2sea_s84_env  ' 15  % fields
% % %                         'date'                         'date'
% % %                         'time'                         'time'
% % %                    'dayOfYear'                         'jday'
% % %                      'meterID'                             ''
% % %                'meterPressure'                        'incHg'
% % %             'meterTemperature'               'degreesCelsius'
% % %           'ambientTemperature'               'degreesCelsius'
% % %                      'kFactor'                             ''
% % %                     'vccCoeff'                             ''
% % %                      'alCoeff'                             ''
% % %                      'axCoeff'                             ''
% % %                      'veCoeff'                             ''
% % %                     'ax2Coeff'                             ''
% % %             'serialFiltLength'                       'second'
% % %                'qcFieltLength'                       'second'
% % % };


% % % %at1m_u12  1  sentences
% % % 
% % % %"UW – AT1M Gravitymeter RAW output message"
% % % renametables.at1m_u12_uw    = {  % from at1m_u12.json
% % % 'at1m_u12_uw   ' 18  % fields
% % %                      'gravity'                         'mGal'
% % %                         'long'                         'Gals'
% % %                        'cross'                         'Gals'
% % %                         'beam'                         'Gals'
% % %                         'temp'               'degreesCelsius'
% % %                     'pressure'                       'inchHg'
% % %                     'elecTemp'               'degreesCelsius'
% % %                          'vcc'                         'mGal'
% % %                           've'                         'mGal'
% % %                           'al'                         'mGal'
% % %                           'ax'                         'mGal'
% % %                       'status'                             ''
% % %                     'checksum'                             ''
% % %                     'latitude'               'DecimalDegrees'
% % %                    'longitude'               'decimalDegrees'
% % %                        'speed'                        'knots'
% % %                       'course'                      'Degrees'
% % %                         'time'                             ''
% % % };


%cnav_gps-dy  6  sentences

%"GNGGA – Global Positioning Fix Data"
renametables.cnav_gps_gngga = {  % from cnav_gps-dy.json
    %     'cnav_gps_gngga' 14  % fields
        'utcTime'                             '' 'utctime'  'hhmmss_fff'
        'latitude' 'degrees, minutes and decimal minutes' 'latdegm' 'dddmm'
    %     'latDir'                             ''
        'longitude' 'degrees, minutes and decimal minutes' 'londegm' 'dddmm'
    %     'lonDir'                             ''
    %     'ggaQual'                             ''
    %     'numSat'                             ''
    %     'hdop'                             ''
    %     'altitude'                       'metres'
    %     'unitsOfMeasureAntenna'                             ''
    %     'geoidAltitude'                       'metres'
    %     'unitsOfMeasureGeoid'                             ''
    %     'diffcAge'                      'seconds'
    %     'dgnssRefId'                             ''
    };

%"GNVTG – Course Over Ground and Ground Speed Data"
renametables.cnav_gps_gnvtg = {  % from cnav_gps-dy.json
    %     'cnav_gps_gnvtg'  9  % fields
    'courseOverGround'                      'degrees' 'course' 'degrees'
    %     'trueCourse'                             ''
    %     'magneticTrack'                      'degrees'
    %     'mFlag'                             ''
    %     'speedKnots'                        'knots'
    %     'nFlag'                             ''
    %     'speedKmph'                         'km/h'
    %     'kFlag'                             ''
    %     'positioningMode'                             ''
    };

% % % %"GPGSV – Number of GPS SVs in view, PRN, elevation, azimuth and SNR"
% % % renametables.cnav_gps_gpgsv = {  % from cnav_gps-dy.json
% % %     'cnav_gps_gpgsv' 20  % fields
% % %     'messageTotalNo'                             ''
% % %     'messageNo'                             ''
% % %     'nsatView'                             ''
% % %     'sv1Id'                             ''
% % %     'sv1Elevation'                      'degrees'
% % %     'sv1Azimuth'                      'degrees'
% % %     'sv1Snr'                             ''
% % %     'sv2Id'                             ''
% % %     'sv2Elevation'                      'degrees'
% % %     'sv2Azimuth'                      'degrees'
% % %     'sv2Snr'                             ''
% % %     'sv3Id'                             ''
% % %     'sv3Elevation'                      'degrees'
% % %     'sv3Azimuth'                      'degrees'
% % %     'sv3Snr'                             ''
% % %     'sv4Id'                             ''
% % %     'sv4Elevation'                      'degrees'
% % %     'sv4Azimuth'                      'degrees'
% % %     'sv4Snr'                             ''
% % %     'signalID'                             ''
% % %     };

% % % %"GLGSV – Number of GPS SVs in view, PRN, elevation, azimuth and SNR"
% % % renametables.cnav_gps_glgsv = {  % from cnav_gps-dy.json
% % %     'cnav_gps_glgsv' 20  % fields
% % %     'messageTotalNo'                             ''
% % %     'messageNo'                             ''
% % %     'nsatView'                             ''
% % %     'sv1Id'                             ''
% % %     'sv1Elevation'                      'degrees'
% % %     'sv1Azimuth'                      'degrees'
% % %     'sv1Snr'                             ''
% % %     'sv2Id'                             ''
% % %     'sv2Elevation'                      'degrees'
% % %     'sv2Azimuth'                      'degrees'
% % %     'sv2Snr'                             ''
% % %     'sv3Id'                             ''
% % %     'sv3Elevation'                      'degrees'
% % %     'sv3Azimuth'                      'degrees'
% % %     'sv3Snr'                             ''
% % %     'sv4Id'                             ''
% % %     'sv4Elevation'                      'degrees'
% % %     'sv4Azimuth'                      'degrees'
% % %     'sv4Snr'                             ''
% % %     'signalID'                             ''
% % %     };

% % % %"GNDTM – Datum being used"
% % % renametables.cnav_gps_gndtm = {  % from cnav_gps-dy.json
% % %     'cnav_gps_gndtm'  8  % fields
% % %     'datumCode'                             ''
% % %     'subDatumCode'                             ''
% % %     'latOffset'                      'minutes'
% % %     'latDir'                             ''
% % %     'lonOffset'                      'minutes'
% % %     'lonDir'                             ''
% % %     'altitudeOffset'                       'metres'
% % %     'referenceDatumCode'                             ''
% % %     };

% % % %"GNGST – GPS Pseudorange Noise Statistics"
% % % renametables.cnav_gps_gngst = {  % from cnav_gps-dy.json
% % %     'cnav_gps_gngst'  8  % fields
% % %     'utcTime'                             ''
% % %     'rms'                             ''
% % %     'semiMajor'                       'metres'
% % %     'semiMinor'                       'metres'
% % %     'ellipseOrient'                      'degrees'
% % %     'standardDeviationOfLatitude'                       'metres'
% % %     'standardDeviationOfLongitude'                       'metres'
% % %     'standardDeviationOfHeight'                       'metres'
% % %     };


%ea640_depth-dy  2  sentences

%"SDDPT – Depth of water"
renametables.em640_depth_sddpt = {  % from ea640_depth-dy.json
    %     'em640_depth_sddpt'  2  % fields
    'waterDepthMeterTransducer'                       'metres' 'waterdepth_below_transducer' 'metres'
    %     'transduceroffset'                       'metres'
    };

%"SDDBS – Depth below surface"
renametables.em640_depth_sddbs = {  % from ea640_depth-dy.json
    %     'em640_depth_sddbs'  6  % fields
    %     'waterDepthFeetFromSurface'                        'feets'
    %     'feetFlag'                             ''
    'waterDepthMeterFromSurface'                       'metres' 'waterdepth' 'metres'
    %     'meterFlag'                             ''
    %     'waterDepthFathomFromSurface'                       'fathom'
    %     'fathomFlag'                             ''
    };


%em122_depth-dy  1  sentences

%"KIDPT – Depth of water"
renametables.em122_depth_kidpt = {  % from em122_depth-dy.json
    %     'em122_depth_kidpt'  3  % fields
    'waterDepthMeter'                       'metres' 'waterdepth' 'metres'
    %     'transduceroffset'                       'metres'
    %     'maxRange'                       'metres'
    };


%env_temp-dy  2  sentences

%"WIMTA Environment Air Temperature 1"
renametables.env_temp_wimta = {  % from env_temp-dy.json
    %     'env_temp_wimta'  2  % fields
    'airTemperature'               'degressCelsius' 'airTemperature' 'degreesC'
    %     'celsiusFlag'                             ''
    };

%"WIMHU Environment Humidity"
renametables.env_temp_wimhu = {  % from env_temp-dy.json
    %     'env_temp_wimhu'  4  % fields
    %     'humidity'                   'percentage'
    %     'flag'                             ''
    'temperatureDewPoint'               'degreesCelsius' 'temperatureDewPoint' 'degreesC'
    %     'celsiusFlag'                             ''
    };


%fugro_gps-dy  8  sentences

%"GPGGA – Global Positioning Fix Data"
renametables.fugro_gps_gpgga = {  % from fugro_gps-dy.json
    %     'fugro_gps_gpgga' 14  % fields
    'utcTime'                             '' 'utctime'  'hhmmss_fff'
    'latitude' 'degrees, minutes and decimal minutes' 'latdegm' 'dddmm'
    %     'latDir'                             ''
    'longitude' 'degrees, minutes and decimal minutes' 'londegm' 'dddmm'
    %     'lonDir'                             ''
    %     'ggaQual'                             ''
    %     'numSat'                             ''
    %     'hdop'                             ''
    %     'altitude'                       'metres'
    %     'unitsOfMeasureAntenna'                             ''
    %     'geoidAltitude'                       'metres'
    %     'unitsOfMeasureGeoid'                             ''
    %     'diffcAge'                      'seconds'
    %     'dgnssRefId'                             ''
    };

%"GPVTG – Course Over Ground and Ground Speed Data"
renametables.fugro_gps_gpvtg = {  % from fugro_gps-dy.json
    %     'fugro_gps_gpvtg'  9  % fields
    'courseOverGround'                      'degrees' 'course' 'degrees'
    %     'trueCourse'                             ''
    %     'magneticTrack'                      'degrees'
    %     'mFlag'                             ''
    %     'speedKnots'                        'knots'
    %     'nFlag'                             ''
    %     'speedKmph'                         'km/h'
    %     'kFlag'                             ''
    %     'positioningMode'                             ''
    };

% % % %"GPDTM – Datum being used"
% % % renametables.fugro_gps_gpdtm = {  % from fugro_gps-dy.json
% % %     'fugro_gps_gpdtm'  8  % fields
% % %     'datumCode'                             ''
% % %     'subDatumCode'                             ''
% % %     'latOffset'                      'minutes'
% % %     'latDir'                             ''
% % %     'lonOffset'                      'minutes'
% % %     'lonDir'                             ''
% % %     'altitudeOffset'                       'metres'
% % %     'referenceDatumCode'                             ''
% % %     };

% % % %"GPRMC – RMC navigation data"
% % % renametables.fugro_gps_gprmc = {  % from fugro_gps-dy.json
% % %     'fugro_gps_gprmc' 12  % fields
% % %     'utcTime'                             ''
% % %     'vFlag'                             ''
% % %     'latitude' 'degrees, minutes and decimal minutes'
% % %     'latDir'                             ''
% % %     'longitude' 'degrees, minutes and decimal minutes'
% % %     'lonDir'                             ''
% % %     'speedKnots'                        'knots'
% % %     'trackMadeGood'                      'degrees'
% % %     'navDate'                             ''
% % %     'magvar'                      'degrees'
% % %     'magvarDir'                             ''
% % %     'positioningMode'                             ''
% % %     };

% % % %"GPGSV – Number of GPS SVs in view, PRN, elevation, azimuth and SNR"
% % % renametables.fugro_gps_gpgsv = {  % from fugro_gps-dy.json
% % %     'fugro_gps_gpgsv' 20  % fields
% % %     'messageTotalNo'                             ''
% % %     'messageNo'                             ''
% % %     'nsatView'                             ''
% % %     'sv1Id'                             ''
% % %     'sv1Elevation'                      'degrees'
% % %     'sv1Azimuth'                      'degrees'
% % %     'sv1Snr'                             ''
% % %     'sv2Id'                             ''
% % %     'sv2Elevation'                      'degrees'
% % %     'sv2Azimuth'                      'degrees'
% % %     'sv2Snr'                             ''
% % %     'sv3Id'                             ''
% % %     'sv3Elevation'                      'degrees'
% % %     'sv3Azimuth'                      'degrees'
% % %     'sv3Snr'                             ''
% % %     'sv4Id'                             ''
% % %     'sv4Elevation'                      'degrees'
% % %     'sv4Azimuth'                      'degrees'
% % %     'sv4Snr'                             ''
% % %     'signalID'                             ''
% % %     };

% % % %"GLGSV – Number of GPS SVs in view, PRN, elevation, azimuth and SNR"
% % % renametables.fugro_gps_glgsv = {  % from fugro_gps-dy.json
% % %     'fugro_gps_glgsv' 20  % fields
% % %     'messageTotalNo'                             ''
% % %     'messageNo'                             ''
% % %     'nsatView'                             ''
% % %     'sv1Id'                             ''
% % %     'sv1Elevation'                      'degrees'
% % %     'sv1Azimuth'                      'degrees'
% % %     'sv1Snr'                             ''
% % %     'sv2Id'                             ''
% % %     'sv2Elevation'                      'degrees'
% % %     'sv2Azimuth'                      'degrees'
% % %     'sv2Snr'                             ''
% % %     'sv3Id'                             ''
% % %     'sv3Elevation'                      'degrees'
% % %     'sv3Azimuth'                      'degrees'
% % %     'sv3Snr'                             ''
% % %     'sv4Id'                             ''
% % %     'sv4Elevation'                      'degrees'
% % %     'sv4Azimuth'                      'degrees'
% % %     'sv4Snr'                             ''
% % %     'signalID'                             ''
% % %     };

% % % %"GPGLL – Position data: Position fix, time of position fix and status"
% % % renametables.fugro_gps_gpgll = {  % from fugro_gps-dy.json
% % %     'fugro_gps_gpgll'  7  % fields
% % %     'latitude' 'degrees, minutes and decimal minutes'
% % %     'latDir'                             ''
% % %     'longitude' 'degrees, minutes and decimal minutes'
% % %     'lonDir'                             ''
% % %     'utcTime'                             ''
% % %     'gllQual'                             ''
% % %     'positioningMode'                             ''
% % %     };

%"GNGSA – GPS DOP and active satellites"
renametables.fugro_gps_gngsa = {  % from fugro_gps-dy.json
%     'fugro_gps_gngsa' 18  % fields
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
    'pdop'                             '' 'pdop' '-'
    'hdop'                             '' 'hdop' '-'
    'vdop'                             '' 'vdop' '-'
    %     'gsid'                             ''
    };


%nmf_surfmet-dy  1  sentences

%"GPXSM – Surfmet output message"
renametables.nmf_surfmet_gpxsm = {  % from nmf_surfmet-dy.json
    %     'nmf_surfmet_gpxsm' 14  % fields
    %     'flow1'                          'l/m'
    %     'watertemperature'                         'none'
    %     'flow3'                          'l/m'
    %     'fluo'                            'V'
    %     'trans'                            'V'
    %     'windSpeed'                          'm/s'
    %     'windDirection'                      'degrees'
        'airTemperature'               'degreesCelsius' 'airTemperature' 'degreesC'
    %     'humidity'                   'percentage'
    %     'airPressure'                           'mB'
    %     'parPort'                            '-'
    %     'parStarboard'                            '-'
    %     'tirPort'                            '-'
    %     'tirStarboard'                            '-'
    };


%nmf_winch-dy  1  sentences

%"WINCH – Cable logging system data"
renametables.nmf_winch_winch = {  % from nmf_winch-dy.json
    %     'nmf_winch_winch'  8  % fields
    %     'winchDatum'                             ''
    %     'cableType'                             ''
    'tension'                       'newton' 'tension' 'tonnes'
    %     'cableOut'                       'metres'
    %     'rate'                          'm/s'
    %     'backTension'                       'newton'
    %     'rollAngle'                      'degrees'
    %     'undefined'                             ''
    };


%phins_att-dy 19  sentences

%"PASHR – Attitude Data"
renametables.phins_att_pashr = {  % from phins_att-dy.json
    %     'phins_att_pashr' 11  % fields
    'utcTime'                             '' 'utctime'  'hhmmss_fff'
    %     'heading'                      'degrees'
    %     'trueFlag'                             ''
    %     'roll'                      'degrees'
    %     'pitch'                      'degrees'
    %     'heave'                       'metres'
    %     'rollAccuracy'                      'degrees'
    %     'pitchAccuracy'                      'degrees'
    %     'headingAccuracy'                      'degrees'
    %     'headingAccuracyFlag'                             ''
    %     'imuFlag'                             ''
    };

% %"PRDID – Attitude Data"
% renametables.phins_att_prdid = {  % from phins_att-dy.json
%     'phins_att_prdid'  3  % fields
%     'pitch'                      'degrees'
%     'roll'                      'degrees'
%     'heading'                      'degrees'
%     };

%"HEHDT – Heading – True Data"
renametables.phins_att_hehdt = {  % from phins_att-dy.json
    %     'phins_att_hehdt'  2  % fields
    'headingTrue'                      'degrees' 'heading' 'degrees'
    %     'trueHeading'                             ''
    };

% % % %"HETHS – Heading – True Data"
% % % renametables.phins_att_heths = {  % from phins_att-dy.json
% % %     'phins_att_heths'  2  % fields
% % %     'headingTrue'                      'degrees'
% % %     'mode'                             ''
% % %     };

% % % %"PIXSE,ATITUD – Roll, Pitch"
% % % renametables.phins_att_pixseatitud = {  % from phins_att-dy.json
% % %     'phins_att_pixseatitud'  2  % fields
% % %     'roll'                      'degrees'
% % %     'pitch'                      'degrees'
% % %     };

% % % %"PIXSE,POSITI – lat lon altitude"
% % % renametables.phins_att_pixsepositi = {  % from phins_att-dy.json
% % %     'phins_att_pixsepositi'  3  % fields
% % %     'latitudeDD'                      'degrees'
% % %     'longitudeDD'                      'degrees'
% % %     'altitude'                       'metres'
% % %     };

% % % %"PIXSE,SPEED_ – East North Up Speed"
% % % renametables.phins_att_pixsespeed0 = {  % from phins_att-dy.json
% % %     'phins_att_pixsespeed0'  3  % fields
% % %     'xEast'                          'm/s'
% % %     'xNorth'                          'm/s'
% % %     'xUp'                          'm/s'
% % %     };

% % % %"PIXSE,UTMWGS – UTM Zone data"
% % % renametables.phins_att_pixseutmwgs = {  % from phins_att-dy.json
% % %     'phins_att_pixseutmwgs'  5  % fields
% % %     'latitudeUTMZone'                             ''
% % %     'longitudeUTMZone'                             ''
% % %     'eastPosition'                            'm'
% % %     'northPosition'                            'm'
% % %     'altitude'                            'm'
% % %     };

% %"PIXSE,HEAVE_ – surge sway heave data"
% renametables.phins_att_pixseheave0 = {  % from phins_att-dy.json
%     'phins_att_pixseheave0'  3  % fields
%     'surge'                            'm'
%     'sway'                            'm'
%     'heave'                            'm'
%     };

% % % %"PIXSE,TIME__ – time UTC"
% % % renametables.phins_att_pixsetime00 = {  % from phins_att-dy.json
% % %     'phins_att_pixsetime00'  1  % fields
% % %     'UTCTime'                'hhmmss.ssssss'
% % %     };

% % % %"PIXSE,STDHRP – Standard deviation Heading Roll Pitch"
% % % renametables.phins_att_pixsestdhrp = {  % from phins_att-dy.json
% % %     'phins_att_pixsestdhrp'  3  % fields
% % %     'headingStd'                      'degrees'
% % %     'rollStd'                      'degrees'
% % %     'pitchStd'                            'm'
% % %     };

% % % %"PIXSE,STDPOS – Standard deviation lat lon altitude"
% % % renametables.phins_att_pixsestdpos = {  % from phins_att-dy.json
% % %     'phins_att_pixsestdpos'  3  % fields
% % %     'latitudeStd'                            'm'
% % %     'longitudeStd'                            'm'
% % %     'altitudeStd'                            'm'
% % %     };

% % % %"PIXSE,STDSPD – Standard deviation north east vertical speed"
% % % renametables.phins_att_pixsestdspd = {  % from phins_att-dy.json
% % %     'phins_att_pixsestdspd'  3  % fields
% % %     'northSpeedStd'                          'm/s'
% % %     'eastSpeedStd'                          'm/s'
% % %     'verticalSpeedStd'                            'm'
% % %     };

%"PIXSE,UTCIN_ – received time UTC"
renametables.phins_att_pixseutcin0 = {  % from phins_att-dy.json
%     'phins_att_pixseutcin0'  1  % fields
    'UTCTime'                'hhmmss.ssssss' 'utctime' 'hhmmss.sssss'
    };

%"PIXSE,GPSIN_ – lat lon altitude UTCTime, qualityFlag"
renametables.phins_att_pixsegpsin0 = {  % from phins_att-dy.json
    %     'phins_att_pixsegpsin0'  5  % fields
    'latitudeDD'                      'degrees' 'latitude' 'degrees'
    'longitudeDD'                      'degrees' 'longitude' 'degrees'
    %     'altitude'                       'metres'
    'UTCTime'                'hhmmss.ssssss' 'utctime' 'hhmmss.sssss'
    %     'qualityIndicator'                             ''
    };

% % % %"PIXSE,GP2IN_ – Second GPS lat lon altitude UTCTime, qualityFlag"
% % % renametables.phins_att_pixsegp2in0 = {  % from phins_att-dy.json
% % %     'phins_att_pixsegp2in0'  5  % fields
% % %     'latitudeDD'                      'degrees'
% % %     'longitudeDD'                      'degrees'
% % %     'altitude'                       'metres'
% % %     'UTCTime'                'hhmmss.ssssss'
% % %     'qualityIndicator'                             ''
% % %     };

% % % %"PIXSE,ALGSTS – INS Algo status"
% % % renametables.phins_att_pixsealgsts = {  % from phins_att-dy.json
% % %     'phins_att_pixsealgsts'  2  % fields
% % %     'status1LSB'                  'hexadecimal'
% % %     'status2MSB'                  'hexadecimal'
% % %     };

% % % %"PIXSE,STATUS – INS System Status"
% % % renametables.phins_att_pixsestatus = {  % from phins_att-dy.json
% % %     'phins_att_pixsestatus'  2  % fields
% % %     'status1LSB'                  'hexadecimal'
% % %     'status2MSB'                  'hexadecimal'
% % %     };

% % % %"PIXSE,HT_STS – INS High Level Status"
% % % renametables.phins_att_pixseht0sts = {  % from phins_att-dy.json
% % %     'phins_att_pixseht0sts'  1  % fields
% % %     'status1HighLevel'                  'hexadecimal'
% % %     };


%posmv_att  8  sentences

%"GPGGA – Global Positioning Fix Data"
renametables.posmv_att_gpgga = {  % from posmv_att.json
    %     'posmv_att_gpgga' 14  % fields
    'utcTime'                             '' 'utctime'  'hhmmss_fff'
    'latitude' 'degrees, minutes and decimal minutes' 'latdegm' 'dddmm'
    %     'latDir'                             ''
    'longitude' 'degrees, minutes and decimal minutes' 'londegm' 'dddmm'
    %     'lonDir'                             ''
    %     'ggaQual'                             ''
    %     'numSat'                             ''
    %     'hdop'                             ''
    %     'altitude'                             ''
    %     'unitsOfMeasureAntenna'                             ''
    %     'geoidAltitude'                             ''
    %     'unitsOfMeasureGeoid'                             ''
    %     'diffcAge'                      'seconds'
    %     'dgnssRefId'                             ''
    };

%"GPHDT – Heading – True Data"
renametables.posmv_att_gphdt = {  % from posmv_att.json
%     'posmv_att_gphdt'  2  % fields
    'headingTrue'                      'degrees' 'heading' 'degrees'
    %     'trueHeading'                             ''
    };

%"GPVTG – Course Over Ground and Ground Speed Data"
renametables.posmv_att_gpvtg = {  % from posmv_att.json
    %     'posmv_att_gpvtg'  9  % fields
    'courseTrue'                      'degrees' 'course' 'degrees'
    %     'trueCourse'                             ''
    %     'magneticTrack'                      'degrees'
    %     'mFlag'                             ''
    %     'speedKnots'                        'knots'
    %     'nFlag'                             ''
    %     'speedKmph'                         'km/h'
    %     'kFlag'                             ''
    %     'positioningMode'                             ''
    };

% % % %"GPRMC – RMC navigation data"
% % % renametables.posmv_att_gprmc = {  % from posmv_att.json
% % %     'posmv_att_gprmc' 12  % fields
% % %     'utcTime'                             ''
% % %     'vFlag'                             ''
% % %     'latitude' 'degrees, minutes and decimal minutes'
% % %     'latDir'                             ''
% % %     'longitude' 'degrees, minutes and decimal minutes'
% % %     'lonDir'                             ''
% % %     'speedKnots'                        'knots'
% % %     'trackMadeGood'                      'degrees'
% % %     'navDate'                             ''
% % %     'magvar'                      'degrees'
% % %     'magvarDir'                             ''
% % %     'positioningMode'                             ''
% % %     };

%"GPZDA – Time and Date"
renametables.posmv_att_gpzda = {  % from posmv_att.json
    %     'posmv_att_gpzda'  6  % fields
    'utcTime'                             '' 'utctime' '-'
    %     'day'                             ''
    %     'month'                             ''
    %     'year'                             ''
    %     'zoneHour'                        'hours'
    %     'zoneMinutes'                      'minutes'
    };

%"PASHR – Attitude Data"
renametables.posmv_att_pashr = {  % from posmv_att.json
    %     'posmv_att_pashr' 11  % fields
    'utcTime'                             '' 'utctime'  'hhmmss_fff'
    %     'heading'                      'degrees'
    %     'trueFlag'                             ''
    %     'roll'                      'degrees'
    %     'pitch'                      'degrees'
    %     'heave'                       'metres'
    %     'rollAccuracy'                      'degrees'
    %     'pitchAccuracy'                      'degrees'
    %     'headingAccuracy'                      'degrees'
    %     'headingAccuracyFlag'                             ''
    %     'imuFlag'                             ''
    };

% % % %"GPGLL – Position data: Position fix, time of position fix and status"
% % % renametables.posmv_att_gpgll = {  % from posmv_att.json
% % %     'posmv_att_gpgll'  7  % fields
% % %     'latitude' 'degrees, minutes and decimal minutes'
% % %     'latDir'                             ''
% % %     'longitude' 'degrees, minutes and decimal minutes'
% % %     'lonDir'                             ''
% % %     'utcTime'                             ''
% % %     'gllQual'                             ''
% % %     'positioningMode'                             ''
% % %     };

% % % %"GPGST – GPS Pseudorange Noise Statistics"
% % % renametables.posmv_att_gpgst = {  % from posmv_att.json
% % %     'posmv_att_gpgst'  8  % fields
% % %     'utcTime'                             ''
% % %     'rms'                             ''
% % %     'semiMajor'                       'metres'
% % %     'semiMinor'                       'metres'
% % %     'ellipseOrient'                      'degrees'
% % %     'standardDeviationOfLatitude'                       'metres'
% % %     'standardDeviationOfLongitude'                       'metres'
% % %     'standardDeviationOfHeight'                       'metres'
% % %     };
% % % 

%posmv_gyro  8  sentences

%"GPGGA – Global Positioning Fix Data"
renametables.posmv_gyro_gpgga = {  % from posmv_gyro.json
    %     'posmv_gyro_gpgga' 14  % fields
    'utcTime'                             '' 'utctime'  'hhmmss_fff'
    'latitude' 'degrees, minutes and decimal minutes' 'latdegm' 'dddmm'
    %     'latDir'                             ''
    'longitude' 'degrees, minutes and decimal minutes' 'londegm' 'dddmm'
    %     'lonDir'                             ''
    %     'ggaQual'                             ''
    %     'numSat'                             ''
    %     'hdop'                             ''
    %     'altitude'                             ''
    %     'unitsOfMeasureAntenna'                             ''
    %     'geoidAltitude'                             ''
    %     'unitsOfMeasureGeoid'                             ''
    %     'diffcAge'                      'seconds'
    %     'dgnssRefId'                             ''
    };

%"GPHDT – Heading – True Data"
renametables.posmv_gyro_gphdt = {  % from posmv_gyro.json
%     'posmv_gyro_gphdt'  2  % fields
    'headingTrue'                      'degrees' 'heading' 'degrees'
    %     'trueHeading'                             ''
    };

%"GPVTG – Course Over Ground and Ground Speed Data"
renametables.posmv_gyro_gpvtg = {  % from posmv_gyro.json
    %     'posmv_gyro_gpvtg'  9  % fields
    'courseTrue'                      'degrees' 'course' 'degrees'
    %     'trueCourse'                             ''
    %     'magneticTrack'                      'degrees'
    %     'mFlag'                             ''
    %     'speedKnots'                        'knots'
    %     'nFlag'                             ''
    %     'speedKmph'                         'km/h'
    %     'kFlag'                             ''
    %     'positioningMode'                             ''
    };

% % % %"GPRMC – RMC navigation data"
% % % renametables.posmv_gyro_gprmc = {  % from posmv_gyro.json
% % %     'posmv_gyro_gprmc' 12  % fields
% % %     'utcTime'                             ''
% % %     'vFlag'                             ''
% % %     'latitude' 'degrees, minutes and decimal minutes'
% % %     'latDir'                             ''
% % %     'longitude' 'degrees, minutes and decimal minutes'
% % %     'lonDir'                             ''
% % %     'speedKnots'                        'knots'
% % %     'trackMadeGood'                      'degrees'
% % %     'navDate'                             ''
% % %     'magvar'                      'degrees'
% % %     'magvarDir'                             ''
% % %     'positioningMode'                             ''
% % %     };

%"GPZDA – Time and Date"
renametables.posmv_gyro_gpzda = {  % from posmv_gyro.json
    %     'posmv_gyro_gpzda'  6  % fields
    'utcTime'                             '' 'utctime' '-'
    %     'day'                             ''
    %     'month'                             ''
    %     'year'                             ''
    %     'zoneHour'                        'hours'
    %     'zoneMinutes'                      'minutes'
    };

%"PASHR – Attitude Data"
renametables.posmv_gyro_pashr = {  % from posmv_gyro.json
    %     'posmv_gyro_pashr' 11  % fields
    'utcTime'                             '' 'utctime'  'hhmmss_fff'
    %     'heading'                      'degrees'
    %     'trueFlag'                             ''
    %     'roll'                      'degrees'
    %     'pitch'                      'degrees'
    %     'heave'                       'metres'
    %     'rollAccuracy'                      'degrees'
    %     'pitchAccuracy'                      'degrees'
    %     'headingAccuracy'                      'degrees'
    %     'headingAccuracyFlag'                             ''
    %     'imuFlag'                             ''
    };

% % % %"GPGLL – Position data: Position fix, time of position fix and status"
% % % renametables.posmv_gyro_gpgll = {  % from posmv_gyro.json
% % %     'posmv_gyro_gpgll'  7  % fields
% % %     'latitude' 'degrees, minutes and decimal minutes'
% % %     'latDir'                             ''
% % %     'longitude' 'degrees, minutes and decimal minutes'
% % %     'lonDir'                             ''
% % %     'utcTime'                             ''
% % %     'gllQual'                             ''
% % %     'positioningMode'                             ''
% % %     };

% % % %"GPGST – GPS Pseudorange Noise Statistics"
% % % renametables.posmv_gyro_gpgst = {  % from posmv_gyro.json
% % %     'posmv_gyro_gpgst'  8  % fields
% % %     'utcTime'                             ''
% % %     'rms'                             ''
% % %     'semiMajor'                       'metres'
% % %     'semiMinor'                       'metres'
% % %     'ellipseOrient'                      'degrees'
% % %     'standardDeviationOfLatitude'                       'metres'
% % %     'standardDeviationOfLongitude'                       'metres'
% % %     'standardDeviationOfHeight'                       'metres'
% % %     };


%posmv_pos-dy  8  sentences

%"GPGGA – Global Positioning Fix Data"
renametables.posmv_pos_gpgga = {  % from posmv_pos-dy.json
    %     'posmv_pos_gpgga' 14  % fields
    'utcTime'                             '' 'utctime'  'hhmmss_fff'
    'latitude' 'degrees, minutes and decimal minutes' 'latdegm' 'dddmm'
    %     'latDir'                             ''
    'longitude' 'degrees, minutes and decimal minutes' 'londegm' 'dddmm'
    %     'lonDir'                             ''
    %     'ggaQual'                             ''
    %     'numSat'                             ''
    %     'hdop'                             ''
    %     'altitude'                             ''
    %     'unitsOfMeasureAntenna'                             ''
    %     'geoidAltitude'                             ''
    %     'unitsOfMeasureGeoid'                             ''
    %     'diffcAge'                      'seconds'
    %     'dgnssRefId'                             ''
    };

%"GPHDT – Heading – True Data"
renametables.posmv_pos_gphdt = {  % from posmv_pos-dy.json
    %     'posmv_pos_gphdt'  2  % fields
    'headingTrue'                      'degrees' 'heading' 'degrees'
    %     'trueHeading'                             ''
    };

%"GPVTG – Course Over Ground and Ground Speed Data"
renametables.posmv_pos_gpvtg = {  % from posmv_pos-dy.json
    %     'posmv_pos_gpvtg'  9  % fields
    'courseTrue'                      'degrees' 'course' 'degrees'
    %     'trueCourse'                             ''
    %     'magneticTrack'                      'degrees'
    %     'mFlag'                             ''
    %     'speedKnots'                        'knots'
    %     'nFlag'                             ''
    %     'speedKmph'                         'km/h'
    %     'kFlag'                             ''
    %     'positioningMode'                             ''
    };

% % % %"GPRMC – RMC navigation data"
% % % renametables.posmv_pos_gprmc = {  % from posmv_pos-dy.json
% % %     'posmv_pos_gprmc' 12  % fields
% % %     'utcTime'                             ''
% % %     'vFlag'                             ''
% % %     'latitude' 'degrees, minutes and decimal minutes'
% % %     'latDir'                             ''
% % %     'longitude' 'degrees, minutes and decimal minutes'
% % %     'lonDir'                             ''
% % %     'speedKnots'                        'knots'
% % %     'trackMadeGood'                      'degrees'
% % %     'navDate'                             ''
% % %     'magvar'                      'degrees'
% % %     'magvarDir'                             ''
% % %     'positioningMode'                             ''
% % %     };

%"GPZDA – Time and Date"
renametables.posmv_pos_gpzda = {  % from posmv_pos-dy.json
    %     'posmv_pos_gpzda'  6  % fields
    'utcTime'                             '' 'utctime' '-'
    %     'day'                             ''
    %     'month'                             ''
    %     'year'                             ''
    %     'zoneHour'                        'hours'
    %     'zoneMinutes'                      'minutes'
    };

%"PASHR – Attitude Data"
renametables.posmv_pos_pashr = {  % from posmv_pos-dy.json
    %     'posmv_pos_pashr' 11  % fields
    'utcTime'                             '' 'utctime'  'hhmmss_fff'
    %     'heading'                      'degrees'
    %     'trueFlag'                             ''
    %     'roll'                      'degrees'
    %     'pitch'                      'degrees'
    %     'heave'                       'metres'
    %     'rollAccuracy'                      'degrees'
    %     'pitchAccuracy'                      'degrees'
    %     'headingAccuracy'                      'degrees'
    %     'headingAccuracyFlag'                             ''
    %     'imuFlag'                             ''
    };

% % % %"GPGLL – Position data: Position fix, time of position fix and status"
% % % renametables.posmv_pos_gpgll = {  % from posmv_pos-dy.json
% % %     'posmv_pos_gpgll'  7  % fields
% % %     'latitude' 'degrees, minutes and decimal minutes'
% % %     'latDir'                             ''
% % %     'longitude' 'degrees, minutes and decimal minutes'
% % %     'lonDir'                             ''
% % %     'utcTime'                             ''
% % %     'gllQual'                             ''
% % %     'positioningMode'                             ''
% % %     };

% % % %"GPGST – GPS Pseudorange Noise Statistics"
% % % renametables.posmv_pos_gpgst = {  % from posmv_pos-dy.json
% % %     'posmv_pos_gpgst'  8  % fields
% % %     'utcTime'                             ''
% % %     'rms'                             ''
% % %     'semiMajor'                       'metres'
% % %     'semiMinor'                       'metres'
% % %     'ellipseOrient'                      'degrees'
% % %     'standardDeviationOfLatitude'                       'metres'
% % %     'standardDeviationOfLongitude'                       'metres'
% % %     'standardDeviationOfHeight'                       'metres'
% % %     };


%ranger2_usbl-dy  1  sentences

%"GPGGA – Global Positioning Fix Data"
renametables.ranger2_usbl_gpgga = {  % from ranger2_usbl-dy.json
    %     'ranger2_usbl_gpgga' 14  % fields
    'utcTime'                             '' 'utctime'  'hhmmss_fff'
    'latitude' 'degrees, minutes and decimal minutes' 'latdegm' 'dddmm'
    %     'latDir'                             ''
    'longitude' 'degrees, minutes and decimal minutes' 'londegm' 'dddmm'
    %     'lonDir'                             ''
    %     'ggaQual'                             ''
    %     'numSat'                             ''
    %     'hdop'                             ''
    %     'altitude'                       'metres'
    %     'unitsOfMeasureAntenna'                             ''
    %     'geoidAltitude'                       'metres'
    %     'unitsOfMeasureGeoid'                             ''
    %     'diffcAge'                      'seconds'
    %     'dgnssRefId'                             ''
    };


%rex_wave-dy  1  sentences

% %"PRAMR – REX WAVERADAR Output Data"
% renametables.rex2_wave_pramr = {  % from rex_wave-dy.json
%     'rex2_wave_pramr' 10  % fields
%     'dateTimeFromWVC'                    'timestamp'
%     'julienDay'                         'days'
%     'SSE_mean_m'                        'meter'
%     'h4rms'                        'meter'
%     'tz_s'                      'seconds'
%     'rexrange'                        'meter'
%     'hmax'                        'meter'
%     'hcrest'                        'meter'
%     'tp_s'                      'seconds'
%     'tc_s'                      'seconds'
%     };


%sbe45_tsg-dy  1  sentences

%"t1= – Thermosalinograph data (NOT NMEA LIKE!)"
renametables.sbe45_tsg_nanan = {  % from sbe45_tsg-dy.json
    %     'sbe45_tsg_nanan'  5  % fields
    'housingWaterTemperature'               'DegreesCelsius' 'temp_housing'  'degreesC'
    %     'conductivity'                          'S/m'
    %     'salinity'                          'PSU'
    %     'soundVelocity'                          'm/s'
    'remoteWaterTemperature'               'DegreesCelsius' 'temp_remote'  'degreesC'
    };


%seapath_att-dy  4  sentences

% %"PSXN,23 – Roll, Pitch, Heading and Heave observations"
% renametables.seapath_att_psxn23 = {  % from seapath_att-dy.json
%     'seapath_att_psxn23'  4  % fields
%     'roll'                      'degrees'
%     'pitch'                      'degrees'
%     'heading'                      'degrees'
%     'heave'                       'metres'
%     };

% % % %"PSXN,20 – Quality for Roll, Pitch, Heading and Heave observations"
% % % renametables.seapath_att_psxn20 = {  % from seapath_att-dy.json
% % %     'seapath_att_psxn20'  4  % fields
% % %     'rollPitchQuality'                             ''
% % %     'headingQuality'                             ''
% % %     'heightQuality'                             ''
% % %     'horizontalPositionQuality'                'dimensionless'
% % %     };

% % % %"INGGA – Global Positioning Fix Data"
% % % renametables.seapath_att_ingga = {  % from seapath_att-dy.json
% % %     'seapath_att_ingga' 14  % fields
% % %     'utcTime'                             ''
% % %     'latitude' 'degrees, minutes and decimal minutes'
% % %     'latDir'                             ''
% % %     'longitude' 'degrees, minutes and decimal minutes'
% % %     'lonDir'                             ''
% % %     'ggaQual'                             ''
% % %     'numSat'                             ''
% % %     'hdop'                             ''
% % %     'altitude'                       'metres'
% % %     'unitsOfMeasureAntenna'                             ''
% % %     'geoidAltitude'                       'metres'
% % %     'unitsOfMeasureGeoid'                             ''
% % %     'diffcAge'                      'seconds'
% % %     'dgnssRefId'                             ''
% % %     };

% % % %"INZDA – Time and Date"
% % % renametables.seapath_att_inzda = {  % from seapath_att-dy.json
% % %     'seapath_att_inzda'  6  % fields
% % %     'utcTime'                             ''
% % %     'day'                             ''
% % %     'month'                             ''
% % %     'year'                             ''
% % %     'zoneHour'                        'hours'
% % %     'zoneMinutes'                      'minutes'
% % %     };
% % % 

%seapath_pos-dy  7  sentences

%"INGGA – Global Positioning Fix Data"
renametables.seapath_pos_ingga = {  % from seapath_pos-dy.json
    %     'seapath_pos_ingga' 14  % fields
    'utcTime'                             '' 'utctime'  'hhmmss_fff'
    'latitude' 'degrees, minutes and decimal minutes' 'latdegm' 'dddmm'
    %     'latDir'                             ''
    'longitude' 'degrees, minutes and decimal minutes' 'londegm' 'dddmm'
    %     'lonDir'                             ''
    %     'ggaQual'                             ''
    %     'numSat'                             ''
    %     'hdop'                             ''
    %     'altitude'                       'metres'
    %     'unitsOfMeasureAntenna'                             ''
    %     'geoidAltitude'                       'metres'
    %     'unitsOfMeasureGeoid'                             ''
    %     'diffcAge'                      'seconds'
    %     'dgnssRefId'                             ''
    };

%"INHDT – Heading – True Data"
renametables.seapath_pos_inhdt = {  % from seapath_pos-dy.json
%     'seapath_pos_inhdt'  2  % fields
    'headingTrue'                      'degrees' 'heading' 'degrees'
    %     'trueHeading'                             ''
    };

%"INVTG – Course Over Ground and Ground Speed Data"
renametables.seapath_pos_invtg = {  % from seapath_pos-dy.json
    %     'seapath_pos_invtg'  9  % fields
    'courseOverGround'                      'degrees' 'course' 'degrees'
    %     'trueCourse'                             ''
    %     'magneticTrack'                      'degrees'
    %     'mFlag'                             ''
    %     'speedKnots'                        'knots'
    %     'nFlag'                             ''
    %     'speedKmph'                         'km/h'
    %     'kFlag'                             ''
    %     'positioningMode'                             ''
    };

% % % %"INRMC – RMC navigation data"
% % % renametables.seapath_pos_inrmc = {  % from seapath_pos-dy.json
% % %     'seapath_pos_inrmc' 12  % fields
% % %     'utcTime'                             ''
% % %     'vFlag'                             ''
% % %     'latitude' 'degrees, minutes and decimal minutes'
% % %     'latDir'                             ''
% % %     'longitude' 'degrees, minutes and decimal minutes'
% % %     'lonDir'                             ''
% % %     'speedKnots'                        'knots'
% % %     'heading'                 'degrees true'
% % %     'navDate'                             ''
% % %     'magvar'                      'degrees'
% % %     'magvarDir'                             ''
% % %     'positioningMode'                             ''
% % %     };

%"INZDA – Time and Date"
renametables.seapath_pos_inzda = {  % from seapath_pos-dy.json
    %     'seapath_pos_inzda'  6  % fields
    'utcTime'                             '' 'utctime' '-'
    %     'day'                             ''
    %     'month'                             ''
    %     'year'                             ''
    %     'zoneHour'                        'hours'
    %     'zoneMinutes'                      'minutes'
    };

% % % %"GNGST – GPS Pseudorange Noise Statistics"
% % % renametables.seapath_pos_gngst = {  % from seapath_pos-dy.json
% % %     'seapath_pos_gngst'  8  % fields
% % %     'utcTime'                             ''
% % %     'rms'                             ''
% % %     'semiMajor'                       'metres'
% % %     'semiMinor'                       'metres'
% % %     'ellipseOrient'                      'degrees'
% % %     'standardDeviationOfLatitude'                       'metres'
% % %     'standardDeviationOfLongitude'                       'metres'
% % %     'standardDeviationOfHeight'                       'metres'
% % %     };

% % % %"GPGST – GPS Pseudorange Noise Statistics"
% % % renametables.seapath_pos_gpgst = {  % from seapath_pos-dy.json
% % %     'seapath_pos_gpgst'  8  % fields
% % %     'utcTime'                             ''
% % %     'rms'                             ''
% % %     'semiMajor'                       'metres'
% % %     'semiMinor'                       'metres'
% % %     'ellipseOrient'                      'degrees'
% % %     'standardDeviationOfLatitude'                       'metres'
% % %     'standardDeviationOfLongitude'                       'metres'
% % %     'standardDeviationOfHeight'                       'metres'
% % %     };


%seaspy_mag-dy  2  sentences

% %"INMAG – Seapy Magnetometer Standard Output Data"
% renametables.seaspy_mag_inmag = {  % from seaspy_mag-dy.json
%     'seaspy_mag_inmag'  9  % fields
%     'juliendatetime'                             ''
%     'magneticfield'                    'nanotesla'
%     'signalstrength'                             ''
%     'depth'                        'meter'
%     'altitude'                        'meter'
%     'leak'                             ''
%     'measurementtime'                  'millisecond'
%     'signalquality'                             ''
%     'warningmessages'                             ''
%     };

% %"3RR0R– Seapy Magnetometer messages"
% renametables.seaspy_mag_3rr0r = {  % from seaspy_mag-dy.json
%     'seaspy_mag_3rr0r'  1  % fields
%     'message'                             ''
%     };


%ships_gyro-dy  5  sentences

%"HEHDT – Heading – True Data"
renametables.ships_gyro_hehdt = {  % from ships_gyro-dy.json
    %     'ships_gyro_hehdt'  2  % fields
    'headingTrue'                      'degrees' 'heading' 'degrees'
    %     'trueHeading'                             ''
    };

% % % %"TIROT – Rate of Turn"
% % % renametables.ships_gyro_tirot = {  % from ships_gyro-dy.json
% % %     'ships_gyro_tirot'  2  % fields
% % %     'rateOfTurn'           'degrees per minute'
% % %     'rotStatus'                             ''
% % %     };

% % % %"PPLAN ??"
% % % renametables.ships_gyro_pplan = {  % from ships_gyro-dy.json
% % %     'ships_gyro_pplan'  8  % fields
% % %     'pplan1'                             ''
% % %     'pplan2'                             ''
% % %     'pplan3'                             ''
% % %     'pplan4'                             ''
% % %     'pplan5'                             ''
% % %     'pplan6'                             ''
% % %     'pplan7'                             ''
% % %     'pplan8'                             ''
% % %     };

% % % %"GPGGA – Global Positioning Fix Data"
% % % renametables.ships_gyro_gpgga = {  % from ships_gyro-dy.json
% % %     'ships_gyro_gpgga' 14  % fields
% % %     'utcTime'                             ''
% % %     'latitude'  'degrees and decimal minutes'
% % %     'latDir'                             ''
% % %     'longitude'  'degrees and decimal minutes'
% % %     'lonDir'                             ''
% % %     'ggaQual'                             ''
% % %     'numSat'                             ''
% % %     'hdop'                             ''
% % %     'altitude'                             ''
% % %     'unitsOfMeasureAntenna'                             ''
% % %     'geoidAltitude'                             ''
% % %     'unitsOfMeasureGeoid'                             ''
% % %     'diffcAge'                      'seconds'
% % %     'dgnssRefId'                             ''
% % %     };

% % % %"GPVTG – Course Over Ground and Ground Speed Data"
% % % renametables.ships_gyro_gpvtg = {  % from ships_gyro-dy.json
% % %     'ships_gyro_gpvtg'  6  % fields
% % %     'courseTrue'                      'degrees'
% % %     'trueCourse'                             ''
% % %     'magneticTrack'                      'degrees'
% % %     'mFlag'                             ''
% % %     'speedKnots'                        'knots'
% % %     'nFlag'                             ''
% % %     };


%ship_skipperlog-dy  5  sentences

%"VDVBW –Dual ground/water speed"
renametables.ships_skipperlog_vdvbw = {  % from ship_skipperlog-dy.json
    %     'ships_skipperlog_vdvbw' 10  % fields
    'longitudalWaterSpeed'                        'Knots' 'speed_forward' 'knots'
    'transverseWaterSpeed'                        'Knots' 'speed_stbd' 'knots'
    %     'status1'                             ''
    %     'longitudalGroundSpeed'                        'Knots'
    %     'transverseGroundSpeed'                        'Knots'
    %     'status2'                             ''
    %     'vbw7'                             ''
    %     'vbw8'                             ''
    %     'vbw9'                             ''
    %     'vbw10'                        'Knots'
    };

% % % %"VDVHW – Water speed & heading"
% % % renametables.ships_skipperlog_vdvhw = {  % from ship_skipperlog-dy.json
% % %     'ships_skipperlog_vdvhw'  8  % fields
% % %     'headingTrue'                      'degrees'
% % %     'headingTrueFlag'                             ''
% % %     'headingMagnetic'                      'degrees'
% % %     'headingMagneticFlag'                             ''
% % %     'speedKnots'                        'knots'
% % %     'nFlag'                             ''
% % %     'speedKmph'                         'km/h'
% % %     'kFlag'                             ''
% % %     };

% % % %"IIDPT – Depth of water"
% % % renametables.ships_skipperlog_iidpt = {  % from ship_skipperlog-dy.json
% % %     'ships_skipperlog_iidpt'  3  % fields
% % %     'waterDepthMeter'                       'metres'
% % %     'offsetT'                       'metres'
% % %     'maxRange'                       'metres'
% % %     };

% % % %"VDVTG – Course Over Ground and Ground Speed Data"
% % % renametables.ships_skipperlog_vdvtg = {  % from ship_skipperlog-dy.json
% % %     'ships_skipperlog_vdvtg'  9  % fields
% % %     'courseOverGround'                      'degrees'
% % %     'trueCourse'                             ''
% % %     'magneticTrack'                      'degrees'
% % %     'mFlag'                             ''
% % %     'speedKnots'                        'knots'
% % %     'nFlag'                             ''
% % %     'speedKmph'                         'km/h'
% % %     'kFlag'                             ''
% % %     'positioningMode'                             ''
% % %     };

% % % %"VDMTW – Water Temperature"
% % % renametables.ships_skipperlog_vdmtw = {  % from ship_skipperlog-dy.json
% % %     'ships_skipperlog_vdmtw'  2  % fields
% % %     'waterTemperatureCelsius'               'DegreesCelsius'
% % %     'celsiusFlag'                             ''
% % %     };


%u12_at1m  1  sentences

% %"UW – AT1M Gravitymeter RAW output message"
% renametables.u12_at1m_uw    = {  % from u12_at1m.json
%     'u12_at1m_uw' 18  % fields
%     'gravity'                         'mGal'
%     'long'                         'Gals'
%     'cross'                         'Gals'
%     'beam'                         'Gals'
%     'temp'               'degreesCelsius'
%     'pressure'                       'inchHg'
%     'elecTemp'               'degreesCelsius'
%     'vcc'                         'mGal'
%     've'                         'mGal'
%     'al'                         'mGal'
%     'ax'                         'mGal'
%     'status'                             ''
%     'checksum'                             ''
%     'latitude'               'DecimalDegrees'
%     'longitude'               'decimalDegrees'
%     'speed'                        'knots'
%     'course'                      'Degrees'
%     'time'                             ''
%     };


%wamos_wave-dy  1  sentences

% %"PWAM – WAMOS WAVERADAR Output Data"
% renametables.wamos_wave_pwam = {  % from wamos_wave-dy.json
%     'wamos_wave_pwam' 13  % fields
%     'hs'                        'meter'
%     'tm2'                      'seconds'
%     'pdir'                 'degrees_true'
%     'tp'                       'second'
%     'lp'                        'meter'
%     'dp1'                      'degrees'
%     'tp1'                       'second'
%     'lp1'                        'meter'
%     'dp2'                      'degrees'
%     'tp2'                       'second'
%     'lp2'                        'meter'
%     'currentdir'                      'degrees'
%     'currentspeed'                          'm/s'
%     };






renametables_list = fieldnames(renametables);

for kt = 1:length(renametables_list)
    tname = renametables_list{kt};
    vlist = renametables.(tname);
    try ; vlist(:,3) = lower(vlist(:,3)); catch; keyboard; end
    renametables.(tname) = vlist;
end

if ~isempty(qflag); return; end

for kl = 1:size(renametables_list,1)
    
    tabname = renametables_list{kl};
    renamecell = renametables.(tabname);
    nrows = size(renamecell,1);
    for kr = 1:nrows
        s1 = tabname;
        s2 = sprintf('''%s''  ''%s''  ''%s''  ''%s''',renamecell{kr,1},renamecell{kr,2},renamecell{kr,3},renamecell{kr,4});
        pad = '                                            ';
        s1 = [pad s1]; s1 = s1(end-25:end);
        fprintf(MEXEC_A.Mfidterm,'%s: %s\n',s1,s2)
    end
end


