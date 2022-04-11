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
% The rtables created in this script will define which variables are loaded
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

%             cnav_gps_gngga: [1×1 struct]
%             cnav_gps_gnvtg: [1×1 struct]
%             cnav_gps_gpgsv: [1×1 struct]
%             cnav_gps_glgsv: [1×1 struct]
%             cnav_gps_gndtm: [1×1 struct]
%             cnav_gps_gngst: [1×1 struct]
%          em640_depth_sddpt: [1×1 struct]
%          em640_depth_sddbs: [1×1 struct]
%          em122_depth_kidpt: [1×1 struct]
%             env_temp_wimta: [1×1 struct]
%             env_temp_wimhu: [1×1 struct]
%            fugro_gps_gpgga: [1×1 struct]
%            fugro_gps_gpvtg: [1×1 struct]
%            fugro_gps_gpdtm: [1×1 struct]
%            fugro_gps_gprmc: [1×1 struct]
%            fugro_gps_gpgsv: [1×1 struct]
%            fugro_gps_glgsv: [1×1 struct]
%            fugro_gps_gpgll: [1×1 struct]
%            fugro_gps_gngsa: [1×1 struct]
%          nmf_surfmet_gpxsm: [1×1 struct]
%            nmf_winch_winch: [1×1 struct]
%            phins_att_pashr: [1×1 struct]
%            phins_att_prdid: [1×1 struct]
%            phins_att_hehdt: [1×1 struct]
%            phins_att_heths: [1×1 struct]
%      phins_att_pixseatitud: [1×1 struct]
%      phins_att_pixsepositi: [1×1 struct]
%      phins_att_pixsespeed0: [1×1 struct]
%      phins_att_pixseutmwgs: [1×1 struct]
%      phins_att_pixseheave0: [1×1 struct]
%      phins_att_pixsetime00: [1×1 struct]
%      phins_att_pixsestdhrp: [1×1 struct]
%      phins_att_pixsestdpos: [1×1 struct]
%      phins_att_pixsestdspd: [1×1 struct]
%      phins_att_pixseutcin0: [1×1 struct]
%      phins_att_pixsegpsin0: [1×1 struct]
%      phins_att_pixsegp2in0: [1×1 struct]
%      phins_att_pixsealgsts: [1×1 struct]
%      phins_att_pixsestatus: [1×1 struct]
%      phins_att_pixseht0sts: [1×1 struct]
%            posmv_att_gpgga: [1×1 struct]
%            posmv_att_gphdt: [1×1 struct]
%            posmv_att_gpvtg: [1×1 struct]
%            posmv_att_gprmc: [1×1 struct]
%            posmv_att_gpzda: [1×1 struct]
%            posmv_att_pashr: [1×1 struct]
%            posmv_att_gpgll: [1×1 struct]
%            posmv_att_gpgst: [1×1 struct]
%           posmv_gyro_gpgga: [1×1 struct]
%           posmv_gyro_gphdt: [1×1 struct]
%           posmv_gyro_gpvtg: [1×1 struct]
%           posmv_gyro_gprmc: [1×1 struct]
%           posmv_gyro_gpzda: [1×1 struct]
%           posmv_gyro_pashr: [1×1 struct]
%           posmv_gyro_gpgll: [1×1 struct]
%           posmv_gyro_gpgst: [1×1 struct]
%            posmv_pos_gpgga: [1×1 struct]
%            posmv_pos_gphdt: [1×1 struct]
%            posmv_pos_gpvtg: [1×1 struct]
%            posmv_pos_gprmc: [1×1 struct]
%            posmv_pos_gpzda: [1×1 struct]
%            posmv_pos_pashr: [1×1 struct]
%            posmv_pos_gpgll: [1×1 struct]
%            posmv_pos_gpgst: [1×1 struct]
%         ranger2_usbl_gpgga: [1×1 struct]
%            rex2_wave_pramr: [1×1 struct]
%            sbe45_tsg_nanan: [1×1 struct]
%         seapath_att_psxn23: [1×1 struct]
%         seapath_att_psxn20: [1×1 struct]
%          seapath_att_ingga: [1×1 struct]
%          seapath_att_inzda: [1×1 struct]
%          seapath_pos_ingga: [1×1 struct]
%          seapath_pos_inhdt: [1×1 struct]
%          seapath_pos_invtg: [1×1 struct]
%          seapath_pos_inrmc: [1×1 struct]
%          seapath_pos_inzda: [1×1 struct]
%          seapath_pos_gngst: [1×1 struct]
%          seapath_pos_gpgst: [1×1 struct]
%           seaspy_mag_inmag: [1×1 struct]
%           seaspy_mag_3rr0r: [1×1 struct]
%           ships_gyro_hehdt: [1×1 struct]
%           ships_gyro_tirot: [1×1 struct]
%           ships_gyro_pplan: [1×1 struct]
%           ships_gyro_gpgga: [1×1 struct]
%           ships_gyro_gpvtg: [1×1 struct]
%     ships_skipperlog_vdvbw: [1×1 struct]
%     ships_skipperlog_vdvhw: [1×1 struct]
%     ships_skipperlog_iidpt: [1×1 struct]
%     ships_skipperlog_vdvtg: [1×1 struct]
%     ships_skipperlog_vdmtw: [1×1 struct]
%            wamos_wave_pwam: [1×1 struct]


% % % %10_at1m  1  sentences
% % % 
% % % %"UW – AT1M Gravitymeter RAW output message"
% % % rtables.10_at1m_uw    = {  % from 10_at1m.json
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
% % % rtables.air2sea_gravity_dat   = {  % from air2sea_gravity.json
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
% % % rtables.air2sea_gravity_env   = {  % from air2sea_gravity.json
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
% % % rtables.air2sea_s84_dat   = {  % from air2sea_s84.json
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
% % % rtables.air2sea_s84_env   = {  % from air2sea_s84.json
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
% % % rtables.at1m_u12_uw    = {  % from at1m_u12.json
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
rtables.cnav_gps_gngga = {  % from cnav_gps-dy.json
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

%"GNVTG – Course Over Ground and Ground Speed Data"
rtables.cnav_gps_gnvtg = {  % from cnav_gps-dy.json
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

% % % %"GPGSV – Number of GPS SVs in view, PRN, elevation, azimuth and SNR"
% % % rtables.cnav_gps_gpgsv = {  % from cnav_gps-dy.json
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
% % % rtables.cnav_gps_glgsv = {  % from cnav_gps-dy.json
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
% % % rtables.cnav_gps_gndtm = {  % from cnav_gps-dy.json
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
% % % rtables.cnav_gps_gngst = {  % from cnav_gps-dy.json
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
rtables.em640_depth_sddpt = {  % from ea640_depth-dy.json
    'em640_depth_sddpt'  2  % fields
    'waterDepthMeterTransducer'                       'metres'
    'transduceroffset'                       'metres'
    };

%"SDDBS – Depth below surface"
rtables.em640_depth_sddbs = {  % from ea640_depth-dy.json
    'em640_depth_sddbs'  6  % fields
    %     'waterDepthFeetFromSurface'                        'feets'
    %     'feetFlag'                             ''
    'waterDepthMeterFromSurface'                       'metres'
    %     'meterFlag'                             ''
    %     'waterDepthFathomFromSurface'                       'fathom'
    %     'fathomFlag'                             ''
    };


%em122_depth-dy  1  sentences

%"KIDPT – Depth of water"
rtables.em122_depth_kidpt = {  % from em122_depth-dy.json
    'em122_depth_kidpt'  3  % fields
    'waterDepthMeter'                       'metres'
    'transduceroffset'                       'metres'
    %     'maxRange'                       'metres'
    };


%env_temp-dy  2  sentences

%"WIMTA Environment Air Temperature 1"
rtables.env_temp_wimta = {  % from env_temp-dy.json
    'env_temp_wimta'  2  % fields
    'airTemperature'               'degressCelsius'
    %     'celsiusFlag'                             ''
    };

%"WIMHU Environment Humidity"
rtables.env_temp_wimhu = {  % from env_temp-dy.json
    'env_temp_wimhu'  4  % fields
    'humidity'                   'percentage'
    %     'flag'                             ''
    'temperatureDewPoint'               'degreesCelsius'
    %     'celsiusFlag'                             ''
    };


%fugro_gps-dy  8  sentences

%"GPGGA – Global Positioning Fix Data"
rtables.fugro_gps_gpgga = {  % from fugro_gps-dy.json
    'fugro_gps_gpgga' 14  % fields
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

%"GPVTG – Course Over Ground and Ground Speed Data"
rtables.fugro_gps_gpvtg = {  % from fugro_gps-dy.json
    'fugro_gps_gpvtg'  9  % fields
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

% % % %"GPDTM – Datum being used"
% % % rtables.fugro_gps_gpdtm = {  % from fugro_gps-dy.json
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
% % % rtables.fugro_gps_gprmc = {  % from fugro_gps-dy.json
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
% % % rtables.fugro_gps_gpgsv = {  % from fugro_gps-dy.json
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
% % % rtables.fugro_gps_glgsv = {  % from fugro_gps-dy.json
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
% % % rtables.fugro_gps_gpgll = {  % from fugro_gps-dy.json
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
rtables.fugro_gps_gngsa = {  % from fugro_gps-dy.json
    'fugro_gps_gngsa' 18  % fields
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


%nmf_surfmet-dy  1  sentences

%"GPXSM – Surfmet output message"
rtables.nmf_surfmet_gpxsm = {  % from nmf_surfmet-dy.json
    'nmf_surfmet_gpxsm' 14  % fields
    'flow1'                          'l/m'
    'watertemperature'                         'none'
    'flow3'                          'l/m'
    'fluo'                            'V'
    'trans'                            'V'
    'windSpeed'                          'm/s'
    'windDirection'                      'degrees'
    'airTemperature'               'degreesCelsius'
    'humidity'                   'percentage'
    'airPressure'                           'mB'
    'parPort'                            '-'
    'parStarboard'                            '-'
    'tirPort'                            '-'
    'tirStarboard'                            '-'
    };


%nmf_winch-dy  1  sentences

%"WINCH – Cable logging system data"
rtables.nmf_winch_winch = {  % from nmf_winch-dy.json
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


%phins_att-dy 19  sentences

%"PASHR – Attitude Data"
rtables.phins_att_pashr = {  % from phins_att-dy.json
    'phins_att_pashr' 11  % fields
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

%"PRDID – Attitude Data"
rtables.phins_att_prdid = {  % from phins_att-dy.json
    'phins_att_prdid'  3  % fields
    'pitch'                      'degrees'
    'roll'                      'degrees'
    'heading'                      'degrees'
    };

%"HEHDT – Heading – True Data"
rtables.phins_att_hehdt = {  % from phins_att-dy.json
    'phins_att_hehdt'  2  % fields
    'headingTrue'                      'degrees'
%     'trueHeading'                             ''
    };

% % % %"HETHS – Heading – True Data"
% % % rtables.phins_att_heths = {  % from phins_att-dy.json
% % %     'phins_att_heths'  2  % fields
% % %     'headingTrue'                      'degrees'
% % %     'mode'                             ''
% % %     };

%"PIXSE,ATITUD – Roll, Pitch"
rtables.phins_att_pixseatitud = {  % from phins_att-dy.json
    'phins_att_pixseatitud'  2  % fields
    'roll'                      'degrees'
    'pitch'                      'degrees'
    };

% % % %"PIXSE,POSITI – lat lon altitude"
% % % rtables.phins_att_pixsepositi = {  % from phins_att-dy.json
% % %     'phins_att_pixsepositi'  3  % fields
% % %     'latitudeDD'                      'degrees'
% % %     'longitudeDD'                      'degrees'
% % %     'altitude'                       'metres'
% % %     };

% % % %"PIXSE,SPEED_ – East North Up Speed"
% % % rtables.phins_att_pixsespeed0 = {  % from phins_att-dy.json
% % %     'phins_att_pixsespeed0'  3  % fields
% % %     'xEast'                          'm/s'
% % %     'xNorth'                          'm/s'
% % %     'xUp'                          'm/s'
% % %     };

% % % %"PIXSE,UTMWGS – UTM Zone data"
% % % rtables.phins_att_pixseutmwgs = {  % from phins_att-dy.json
% % %     'phins_att_pixseutmwgs'  5  % fields
% % %     'latitudeUTMZone'                             ''
% % %     'longitudeUTMZone'                             ''
% % %     'eastPosition'                            'm'
% % %     'northPosition'                            'm'
% % %     'altitude'                            'm'
% % %     };

%"PIXSE,HEAVE_ – surge sway heave data"
rtables.phins_att_pixseheave0 = {  % from phins_att-dy.json
    'phins_att_pixseheave0'  3  % fields
    'surge'                            'm'
    'sway'                            'm'
    'heave'                            'm'
    };

% % % %"PIXSE,TIME__ – time UTC"
% % % rtables.phins_att_pixsetime00 = {  % from phins_att-dy.json
% % %     'phins_att_pixsetime00'  1  % fields
% % %     'UTCTime'                'hhmmss.ssssss'
% % %     };

% % % %"PIXSE,STDHRP – Standard deviation Heading Roll Pitch"
% % % rtables.phins_att_pixsestdhrp = {  % from phins_att-dy.json
% % %     'phins_att_pixsestdhrp'  3  % fields
% % %     'headingStd'                      'degrees'
% % %     'rollStd'                      'degrees'
% % %     'pitchStd'                            'm'
% % %     };

% % % %"PIXSE,STDPOS – Standard deviation lat lon altitude"
% % % rtables.phins_att_pixsestdpos = {  % from phins_att-dy.json
% % %     'phins_att_pixsestdpos'  3  % fields
% % %     'latitudeStd'                            'm'
% % %     'longitudeStd'                            'm'
% % %     'altitudeStd'                            'm'
% % %     };

% % % %"PIXSE,STDSPD – Standard deviation north east vertical speed"
% % % rtables.phins_att_pixsestdspd = {  % from phins_att-dy.json
% % %     'phins_att_pixsestdspd'  3  % fields
% % %     'northSpeedStd'                          'm/s'
% % %     'eastSpeedStd'                          'm/s'
% % %     'verticalSpeedStd'                            'm'
% % %     };

% % % %"PIXSE,UTCIN_ – received time UTC"
% % % rtables.phins_att_pixseutcin0 = {  % from phins_att-dy.json
% % %     'phins_att_pixseutcin0'  1  % fields
% % %     'UTCTime'                'hhmmss.ssssss'
% % %     };

%"PIXSE,GPSIN_ – lat lon altitude UTCTime, qualityFlag"
rtables.phins_att_pixsegpsin0 = {  % from phins_att-dy.json
    'phins_att_pixsegpsin0'  5  % fields
    'latitudeDD'                      'degrees'
    'longitudeDD'                      'degrees'
    'altitude'                       'metres'
    'UTCTime'                'hhmmss.ssssss'
    %     'qualityIndicator'                             ''
    };

% % % %"PIXSE,GP2IN_ – Second GPS lat lon altitude UTCTime, qualityFlag"
% % % rtables.phins_att_pixsegp2in0 = {  % from phins_att-dy.json
% % %     'phins_att_pixsegp2in0'  5  % fields
% % %     'latitudeDD'                      'degrees'
% % %     'longitudeDD'                      'degrees'
% % %     'altitude'                       'metres'
% % %     'UTCTime'                'hhmmss.ssssss'
% % %     'qualityIndicator'                             ''
% % %     };

% % % %"PIXSE,ALGSTS – INS Algo status"
% % % rtables.phins_att_pixsealgsts = {  % from phins_att-dy.json
% % %     'phins_att_pixsealgsts'  2  % fields
% % %     'status1LSB'                  'hexadecimal'
% % %     'status2MSB'                  'hexadecimal'
% % %     };

% % % %"PIXSE,STATUS – INS System Status"
% % % rtables.phins_att_pixsestatus = {  % from phins_att-dy.json
% % %     'phins_att_pixsestatus'  2  % fields
% % %     'status1LSB'                  'hexadecimal'
% % %     'status2MSB'                  'hexadecimal'
% % %     };

% % % %"PIXSE,HT_STS – INS High Level Status"
% % % rtables.phins_att_pixseht0sts = {  % from phins_att-dy.json
% % %     'phins_att_pixseht0sts'  1  % fields
% % %     'status1HighLevel'                  'hexadecimal'
% % %     };


%posmv_att  8  sentences

% % % %"GPGGA – Global Positioning Fix Data"
% % % rtables.posmv_att_gpgga = {  % from posmv_att.json
% % %     'posmv_att_gpgga' 14  % fields
% % %     'utcTime'                             ''
% % %     'latitude'  'degrees and decimal minutes'
% % %     'latDir'                             ''
% % %     'longitude'  'degrees and decimal minutes'
% % %     'lonDir'                             ''
% % %     'ggaQual'                             ''
% % %     'numSat'                             ''
% % %     'hdop'                             ''
% % %     'altitude'                             ''
% % %     %     'unitsOfMeasureAntenna'                             ''
% % %     %     'geoidAltitude'                             ''
% % %     %     'unitsOfMeasureGeoid'                             ''
% % %     %     'diffcAge'                      'seconds'
% % %     %     'dgnssRefId'                             ''
% % %     };

% % % %"GPHDT – Heading – True Data"
% % % rtables.posmv_att_gphdt = {  % from posmv_att.json
% % %     'posmv_att_gphdt'  2  % fields
% % %     'headingTrue'                      'degrees'
% % %     %     'trueHeading'                             ''
% % %     };

% % % %"GPVTG – Course Over Ground and Ground Speed Data"
% % % rtables.posmv_att_gpvtg = {  % from posmv_att.json
% % %     'posmv_att_gpvtg'  9  % fields
% % %     'courseTrue'                      'degrees'
% % %     %     'trueCourse'                             ''
% % %     %     'magneticTrack'                      'degrees'
% % %     %     'mFlag'                             ''
% % %     'speedKnots'                        'knots'
% % %     %     'nFlag'                             ''
% % %     %     'speedKmph'                         'km/h'
% % %     %     'kFlag'                             ''
% % %     %     'positioningMode'                             ''
% % %     };

% % % %"GPRMC – RMC navigation data"
% % % rtables.posmv_att_gprmc = {  % from posmv_att.json
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

% % % %"GPZDA – Time and Date"
% % % rtables.posmv_att_gpzda = {  % from posmv_att.json
% % %     'posmv_att_gpzda'  6  % fields
% % %     'utcTime'                             ''
% % %     'day'                             ''
% % %     'month'                             ''
% % %     'year'                             ''
% % %     'zoneHour'                        'hours'
% % %     'zoneMinutes'                      'minutes'
% % %     };

% % % %"PASHR – Attitude Data"
% % % rtables.posmv_att_pashr = {  % from posmv_att.json
% % %     'posmv_att_pashr' 11  % fields
% % %     'utcTime'                             ''
% % %     'heading'                      'degrees'
% % %     %     'trueFlag'                             ''
% % %     'roll'                      'degrees'
% % %     'pitch'                      'degrees'
% % %     'heave'                       'metres'
% % %     %     'rollAccuracy'                      'degrees'
% % %     %     'pitchAccuracy'                      'degrees'
% % %     %     'headingAccuracy'                      'degrees'
% % %     %     'headingAccuracyFlag'                             ''
% % %     %     'imuFlag'                             ''
% % %     };

% % % %"GPGLL – Position data: Position fix, time of position fix and status"
% % % rtables.posmv_att_gpgll = {  % from posmv_att.json
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
% % % rtables.posmv_att_gpgst = {  % from posmv_att.json
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

% % % %"GPGGA – Global Positioning Fix Data"
% % % rtables.posmv_gyro_gpgga = {  % from posmv_gyro.json
% % %     'posmv_gyro_gpgga' 14  % fields
% % %     'utcTime'                             ''
% % %     'latitude'  'degrees and decimal minutes'
% % %     'latDir'                             ''
% % %     'longitude'  'degrees and decimal minutes'
% % %     'lonDir'                             ''
% % %     'ggaQual'                             ''
% % %     'numSat'                             ''
% % %     'hdop'                             ''
% % %     'altitude'                             ''
% % %     %     'unitsOfMeasureAntenna'                             ''
% % %     %     'geoidAltitude'                             ''
% % %     %     'unitsOfMeasureGeoid'                             ''
% % %     %     'diffcAge'                      'seconds'
% % %     %     'dgnssRefId'                             ''
% % %     };

% % % % % % %"GPHDT – Heading – True Data"
% % % rtables.posmv_gyro_gphdt = {  % from posmv_gyro.json
% % %     'posmv_gyro_gphdt'  2  % fields
% % %     'headingTrue'                      'degrees'
% % %     %     'trueHeading'                             ''
% % %     };

% % % %"GPVTG – Course Over Ground and Ground Speed Data"
% % % rtables.posmv_gyro_gpvtg = {  % from posmv_gyro.json
% % %     'posmv_gyro_gpvtg'  9  % fields
% % %     'courseTrue'                      'degrees'
% % %     %     'trueCourse'                             ''
% % %     %     'magneticTrack'                      'degrees'
% % %     %     'mFlag'                             ''
% % %     'speedKnots'                        'knots'
% % %     %     'nFlag'                             ''
% % %     %     'speedKmph'                         'km/h'
% % %     %     'kFlag'                             ''
% % %     %     'positioningMode'                             ''
% % %     };

% % % %"GPRMC – RMC navigation data"
% % % rtables.posmv_gyro_gprmc = {  % from posmv_gyro.json
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

% % % %"GPZDA – Time and Date"
% % % rtables.posmv_gyro_gpzda = {  % from posmv_gyro.json
% % %     'posmv_gyro_gpzda'  6  % fields
% % %     'utcTime'                             ''
% % %     'day'                             ''
% % %     'month'                             ''
% % %     'year'                             ''
% % %     'zoneHour'                        'hours'
% % %     'zoneMinutes'                      'minutes'
% % %     };

% % % %"PASHR – Attitude Data"
% % % rtables.posmv_gyro_pashr = {  % from posmv_gyro.json
% % %     'posmv_gyro_pashr' 11  % fields
% % %     'utcTime'                             ''
% % %     'heading'                      'degrees'
% % %     %     'trueFlag'                             ''
% % %     'roll'                      'degrees'
% % %     'pitch'                      'degrees'
% % %     'heave'                       'metres'
% % %     %     'rollAccuracy'                      'degrees'
% % %     %     'pitchAccuracy'                      'degrees'
% % %     %     'headingAccuracy'                      'degrees'
% % %     %     'headingAccuracyFlag'                             ''
% % %     %     'imuFlag'                             ''
% % %     };

% % % %"GPGLL – Position data: Position fix, time of position fix and status"
% % % rtables.posmv_gyro_gpgll = {  % from posmv_gyro.json
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
% % % rtables.posmv_gyro_gpgst = {  % from posmv_gyro.json
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
rtables.posmv_pos_gpgga = {  % from posmv_pos-dy.json
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

%"GPHDT – Heading – True Data"
rtables.posmv_pos_gphdt = {  % from posmv_pos-dy.json
    'posmv_pos_gphdt'  2  % fields
    'headingTrue'                      'degrees'
    %     'trueHeading'                             ''
    };

%"GPVTG – Course Over Ground and Ground Speed Data"
rtables.posmv_pos_gpvtg = {  % from posmv_pos-dy.json
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

% % % %"GPRMC – RMC navigation data"
% % % rtables.posmv_pos_gprmc = {  % from posmv_pos-dy.json
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

% % % %"GPZDA – Time and Date"
% % % rtables.posmv_pos_gpzda = {  % from posmv_pos-dy.json
% % %     'posmv_pos_gpzda'  6  % fields
% % %     'utcTime'                             ''
% % %     'day'                             ''
% % %     'month'                             ''
% % %     'year'                             ''
% % %     'zoneHour'                        'hours'
% % %     'zoneMinutes'                      'minutes'
% % %     };

%"PASHR – Attitude Data"
rtables.posmv_pos_pashr = {  % from posmv_pos-dy.json
    'posmv_pos_pashr' 11  % fields
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

% % % %"GPGLL – Position data: Position fix, time of position fix and status"
% % % rtables.posmv_pos_gpgll = {  % from posmv_pos-dy.json
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
% % % rtables.posmv_pos_gpgst = {  % from posmv_pos-dy.json
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
rtables.ranger2_usbl_gpgga = {  % from ranger2_usbl-dy.json
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


%rex_wave-dy  1  sentences

%"PRAMR – REX WAVERADAR Output Data"
rtables.rex2_wave_pramr = {  % from rex_wave-dy.json
    'rex2_wave_pramr' 10  % fields
%     'dateTimeFromWVC'                    'timestamp'  % not numeric
%     'julienDay'                         'days'
    'SSE_mean_m'                        'meter'
    'h4rms'                        'meter'
    'tz_s'                      'seconds'
    'rexrange'                        'meter'
    'hmax'                        'meter'
    'hcrest'                        'meter'
    'tp_s'                      'seconds'
    'tc_s'                      'seconds'
    };


%sbe45_tsg-dy  1  sentences

%"t1= – Thermosalinograph data (NOT NMEA LIKE!)"
rtables.sbe45_tsg_nanan = {  % from sbe45_tsg-dy.json
    'sbe45_tsg_nanan'  5  % fields
    'housingWaterTemperature'               'DegreesCelsius'
    'conductivity'                          'S/m'
    'salinity'                          'PSU'
    'soundVelocity'                          'm/s'
    'remoteWaterTemperature'               'DegreesCelsius'
    };


%seapath_att-dy  4  sentences

%"PSXN,23 – Roll, Pitch, Heading and Heave observations"
rtables.seapath_att_psxn23 = {  % from seapath_att-dy.json
    'seapath_att_psxn23'  4  % fields
    'roll'                      'degrees'
    'pitch'                      'degrees'
    'heading'                      'degrees'
    'heave'                       'metres'
    };

% % % %"PSXN,20 – Quality for Roll, Pitch, Heading and Heave observations"
% % % rtables.seapath_att_psxn20 = {  % from seapath_att-dy.json
% % %     'seapath_att_psxn20'  4  % fields
% % %     'rollPitchQuality'                             ''
% % %     'headingQuality'                             ''
% % %     'heightQuality'                             ''
% % %     'horizontalPositionQuality'                'dimensionless'
% % %     };

% % % %"INGGA – Global Positioning Fix Data"
% % % rtables.seapath_att_ingga = {  % from seapath_att-dy.json
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
% % % rtables.seapath_att_inzda = {  % from seapath_att-dy.json
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
rtables.seapath_pos_ingga = {  % from seapath_pos-dy.json
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

%"INHDT – Heading – True Data"
rtables.seapath_pos_inhdt = {  % from seapath_pos-dy.json
    'seapath_pos_inhdt'  2  % fields
    'headingTrue'                      'degrees'
    %     'trueHeading'                             ''
    };

%"INVTG – Course Over Ground and Ground Speed Data"
rtables.seapath_pos_invtg = {  % from seapath_pos-dy.json
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

% % % %"INRMC – RMC navigation data"
% % % rtables.seapath_pos_inrmc = {  % from seapath_pos-dy.json
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

% % % %"INZDA – Time and Date"
% % % rtables.seapath_pos_inzda = {  % from seapath_pos-dy.json
% % %     'seapath_pos_inzda'  6  % fields
% % %     'utcTime'                             ''
% % %     'day'                             ''
% % %     'month'                             ''
% % %     'year'                             ''
% % %     'zoneHour'                        'hours'
% % %     'zoneMinutes'                      'minutes'
% % %     };

% % % %"GNGST – GPS Pseudorange Noise Statistics"
% % % rtables.seapath_pos_gngst = {  % from seapath_pos-dy.json
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
% % % rtables.seapath_pos_gpgst = {  % from seapath_pos-dy.json
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

%"INMAG – Seapy Magnetometer Standard Output Data"
rtables.seaspy_mag_inmag = {  % from seaspy_mag-dy.json
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

%"3RR0R– Seapy Magnetometer messages"
rtables.seaspy_mag_3rr0r = {  % from seaspy_mag-dy.json
    'seaspy_mag_3rr0r'  1  % fields
    'message'                             ''
    };


%ships_gyro-dy  5  sentences

%"HEHDT – Heading – True Data"
rtables.ships_gyro_hehdt = {  % from ships_gyro-dy.json
    'ships_gyro_hehdt'  2  % fields
    'headingTrue'                      'degrees'
    %     'trueHeading'                             ''
    };

% % % %"TIROT – Rate of Turn"
% % % rtables.ships_gyro_tirot = {  % from ships_gyro-dy.json
% % %     'ships_gyro_tirot'  2  % fields
% % %     'rateOfTurn'           'degrees per minute'
% % %     'rotStatus'                             ''
% % %     };

% % % %"PPLAN ??"
% % % rtables.ships_gyro_pplan = {  % from ships_gyro-dy.json
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
% % % rtables.ships_gyro_gpgga = {  % from ships_gyro-dy.json
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
% % % rtables.ships_gyro_gpvtg = {  % from ships_gyro-dy.json
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
rtables.ships_skipperlog_vdvbw = {  % from ship_skipperlog-dy.json
    'ships_skipperlog_vdvbw' 10  % fields
    'longitudalWaterSpeed'                        'Knots'
    'transverseWaterSpeed'                        'Knots'
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
% % % rtables.ships_skipperlog_vdvhw = {  % from ship_skipperlog-dy.json
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
% % % rtables.ships_skipperlog_iidpt = {  % from ship_skipperlog-dy.json
% % %     'ships_skipperlog_iidpt'  3  % fields
% % %     'waterDepthMeter'                       'metres'
% % %     'offsetT'                       'metres'
% % %     'maxRange'                       'metres'
% % %     };

% % % %"VDVTG – Course Over Ground and Ground Speed Data"
% % % rtables.ships_skipperlog_vdvtg = {  % from ship_skipperlog-dy.json
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
% % % rtables.ships_skipperlog_vdmtw = {  % from ship_skipperlog-dy.json
% % %     'ships_skipperlog_vdmtw'  2  % fields
% % %     'waterTemperatureCelsius'               'DegreesCelsius'
% % %     'celsiusFlag'                             ''
% % %     };


%u12_at1m  1  sentences

%"UW – AT1M Gravitymeter RAW output message"
rtables.u12_at1m_uw    = {  % from u12_at1m.json
    'u12_at1m_uw' 18  % fields
    'gravity'                         'mGal'
    'long'                         'Gals'
    'cross'                         'Gals'
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
    'time'                             ''
    };


%wamos_wave-dy  1  sentences

%"PWAM – WAMOS WAVERADAR Output Data"
rtables.wamos_wave_pwam = {  % from wamos_wave-dy.json
    'wamos_wave_pwam' 13  % fields
    'hs'                        'meter'
    'tm2'                      'seconds'
    'pdir'                 'degrees_true'
    'tp'                       'second'
    'lp'                        'meter'
    'dp1'                      'degrees'
    'tp1'                       'second'
    'lp1'                        'meter'
    'dp2'                      'degrees'
    'tp2'                       'second'
    'lp2'                        'meter'
    'currentdir'                      'degrees'
    'currentspeed'                          'm/s'
    };


rtables_list = fieldnames(rtables);
