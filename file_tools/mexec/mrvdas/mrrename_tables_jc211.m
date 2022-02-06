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

renametables.ships_gyro_hehdt = {  % from ships_gyro-jc.mat.json
    %     'ships_gyro_hehdt'  2  % fields
    'headingTrue'                      'degrees' 'heading' 'degrees'
    %     'trueHeading'                             ''
    };

renametables.nmf_winch_winch = {  % from nmf_winch-jc.json
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


renametables.posmv_gyro_gphdt = {  % from posmv_gyro-jc.json
    %     'posmv_gyro_gphdt'  2  % fields
    'headingTrue'                      'degrees' 'heading' 'degrees'
    %     'trueHeading'                             ''
    };

renametables.posmv_att_pashr = {  % from posmv_att-jc.json
    %     'posmv_att_pashr' 11  % fields
    'utcTime'                             ''    'utctime'  'hhmmss_fff'
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

renametables.posmv_pos_gpgga = {  % from posmv_pos-jc.json
    %     'posmv_pos_gpgga' 14  % fields
    'utcTime'                             ''    'utctime'  'hhmmss_fff'
    'latitude'  'degrees and decimal minutes' 'latdegm' 'dddmm'
    %     'latDir'                             ''
    'longitude'  'degrees and decimal minutes' 'londegm' 'dddmm'
    %     'lonDir'                             ''
    %     'ggaQual'                             ''
    %     'numSat'                             ''
    %     'hdop'                             ''
    'altitude'                             ''     'altitude' 'metres'
    %     'unitsOfMeasureAntenna'                             ''
    %     'geoidAltitude'                             ''
    %     'unitsOfMeasureGeoid'                             ''
    %     'diffcAge'                      'seconds'
    %     'dgnssRefId'                             ''
    };

renametables.posmv_pos_gpvtg = {  % from posmv_pos-jc.json
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


renametables.cnav_gps_gngga = {  % from cnav_gps-jc.json
    %     'cnav_gps_gngga' 14  % fields
    'utcTime'                             ''      'utctime'  'hhmmss_fff'
    'latitude' 'degrees, minutes and decimal minutes' 'latdegm' 'dddmm'
    %     'latDir'                             ''
    'longitude' 'degrees, minutes and decimal minutes' 'londegm' 'dddmm'
    %     'lonDir'                             ''
    %     'ggaQual'                             ''
    %     'numSat'                             ''
    %     'hdop'                             ''
    %     'altitude'                       'metres'
    %     %     'unitsOfMeasureAntenna'                             ''
    %     'geoidAltitude'                       'metres'
    %     'unitsOfMeasureGeoid'                             ''
    %     'diffcAge'                      'seconds'
    %     'dgnssRefId'                             ''
    };

renametables.cnav_gps_gnvtg = {  % from cnav_gps-jc.json
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


renametables.dps116_gps_gpgga = {  % from dps116_gps-jc.json
    %     'dps116_gps_gpgga' 14  % fields
    'utcTime'                             ''      'utctime'  'hhmmss_fff'
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

renametables.em120_depth_kidpt = {  % from em120_depth-jc.json
    %     'em120_depth_kidpt'  3  % fields
    'waterDepthMeter'                       'metres' 'waterdepth' 'metres'
    %     'transduceroffset'                       'metres'
    %     'maxRange'                       'metres'
    };

renametables.em600_depth_sddbs = {  % from em600_depth-jc.json
    %     'em600_depth_sddbs'  6  % fields
    %     'waterDepthFeetFromSurface'                        'feets'
    %     'feetFlag'                             ''
    'waterDepthMeterFromSurface'                       'metres' 'waterdepth' 'metres'
    %     'meterFlag'                             ''
    %     'waterDepthFathomFromSurface'                       'fathom'
    %     'fathomFlag'                             ''
    };




renametables.ranger2_usbl_gpgga = {  % from RANGER2_USBL-jc.json
    %     'ranger2_usbl_gpgga' 14  % fields
    'utcTime'                             ''      'utctime'  'hhmmss_fff'
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


renametables.sbe45_tsg_nanan = {  % from sbe45_tsg-jc.json
    %     'sbe45_tsg_nanan'  5  % fields
    'housingWaterTemperature'               'DegreesCelsius' 'temp_housing' 'degreesC'
    %     'conductivity'                          'S/m'
    %     'salinity'                          'PSU'
    %     'soundVelocity'                          'm/s'
    'remoteWaterTemperature'               'DegreesCelsius' 'temp_remote' 'degreesC'
    };

renametables.seapath_pos_inhdt = {  % from seapath_pos.json
    %     'seapath_pos_inhdt'  2  % fields
    'headingTrue'                      'degrees' 'heading' 'degrees'
    %     'trueHeading'                             ''
    };


renametables.seapath_pos_ingga = {  % from seapath_pos-jc.json
    %     'seapath_pos_ingga' 14  % fields
    'utcTime'                             ''      'utctime'  'hhmmss_fff'
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



renametables.seapath_pos_invtg = {  % from seapath_pos-jc.json
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

renametables.ships_chernikeef_vmvbw = {  % from ships_chernikeef-jc.json
    %     'ships_chernikeef_vmvbw' 10  % fields
    'longitudalWaterSpeed'                        'Knots' 'speed_forward' 'knots'
    'transverseWaterSpeed'                        'Knots' 'speed_stbd' 'knots'
    %     'status1'                             ''
    %     'longitudalGroundSpeed'                        'Knots'
    %     'transverseGroundSpeed'                        'Knots'
    %     'status2'                             ''
    %     'vbw7'                        'Knots'
    %     'status3'                             ''
    %     'vbw10'                        'Knots'
    %     'status4'                             ''
    };

renametables.ships_skipperlog_vdvbw = {  % from ship_skipperlog-jc.json
    %     'ships_skipperlog_vdvbw' 10  % fields
    'longitudalWaterSpeed'                        'Knots' 'speed_forward' 'knots'
    'transverseWaterSpeed'                        'Knots' 'speed_stbd' 'knots'
    %     'status1'                             ''
    %     'longitudalGroundSpeed'                        'Knots'
    %     'transverseGroundSpeed'                        'Knots'
    %     'status2'                             ''
    %     'vbw7'                        'Knots'
    %     'status3'                             ''
    %     'vbw8'                             ''
    %     'status4'                             ''
    };




renametables_list = fieldnames(renametables);

for kt = 1:length(renametables_list)
    tname = renametables_list{kt};
    vlist = renametables.(tname);
    vlist(:,3) = lower(vlist(:,3));
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


