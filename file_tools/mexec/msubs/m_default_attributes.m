function hatt = m_default_attributes
% function hatt = m_default_attributes
%
% prepare default attributes to create empty file

m_common

hatt.mstar_string = ['mstar_' MEXEC_G.mexec_version]'; % Always make the first 5 characters of this string identical to 'mstar'
hatt.openflag = 'W'; % set to W if file is open to write. Otherwise R.
hatt.date_file_updated = [0 0 0 0 0 0]; % This is the time of file update, stored as a recognisable 6 element vector
hatt.mstar_time_origin = MEXEC_G.MSTAR_TIME_ORIGIN; % If ever we need a reference time for some mstar purpose, this is what we will use. Stored as a 6 element vector.
hatt.data_time_origin = MEXEC_G.MDEFAULT_DATA_TIME_ORIGIN; % This is the reference time for data, stored as a recognisable 6 element vector; usually time will be measured as decimal days or seconds since this time
hatt.time_convention = 'date_file_updated and data_time_origin are 6-element vectors, as commonly used in matlab date handling: [yyyy mo dd hh mm ss]';
hatt.dataname = 'null_dataname';
hatt.version = 0;
hatt.platform_type = MEXEC_G.PLATFORM_TYPE; % eg 'ship'
hatt.platform_identifier = MEXEC_G.PLATFORM_IDENTIFIER; % eg 'RRS James Cook'
hatt.platform_number = MEXEC_G.PLATFORM_NUMBER; % eg 'Cruise 31'
hatt.instrument_identifier = 'none_specified'; % eg 'CTD' or 'Current meter plus serial number'
hatt.recording_interval = 'none_specified'; % plain text eg '1 Hz'
hatt.water_depth_metres = -999; % eg 4000
hatt.instrument_depth_metres = -999; % eg 3995; relevent for current meters
hatt.latitude = -999; % decimal degrees; relevant for moorings or CTD stations
hatt.longitude = -999; % decimal degrees; relevant for moorings or CTD stations
hatt.mstar_site = MEXEC_G.SITE; % identifier of computer where file was created
hatt.comment_delimiter_string = MEXEC_G.COMMENT_DELIMITER_STRING;
hatt.comment = hatt.comment_delimiter_string; %start with a single delimiter 