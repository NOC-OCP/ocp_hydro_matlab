function [rtables,rawlist] = mrrename_tables(tables,varargin)
% function [renametables,rawlist] = mrrename_tables(tables,qflag)
%
% *************************************************************************
% mexec interface for RVDAS data acquisition
% First drafts of scripts for start jc211 28 jan 2021, alongside in Stanley
% 
% Evolution on that cruise by bak, ylf, pa
% *************************************************************************
%
% A list and/or set of find-replace for rvdas variable names and units we
% wish to rename when read into mexec, as well as those we wish to ignore
% (not read in). 
%
% The list in this script could be moved elsewhere, but is unlikely to
%   change much from crusie to cruise. It may be added to from time to
%   time.
%
% At the end of the function, ensures that all new variable names are
%   lowercase, regardless of what has been entered row by row.
%
% Examples
%
%   [renametables,renametables_list] = mrrename_tables;
%   [renametables,renametables_list] = mrrename_tables('q');
%
% Input:
%   tables, the output of mrtables_from_json
%   [optional] qflag: if qflag has the value 'q', listing to screen is
%     supressed
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

fn = fieldnames(tables);
for no = 1:length(fn)
        
    a = tables.(fn{no});    
    
    %add columns for new-name and new-units
    n = size(a,2);
    a = [a a(:,1:2)];
    
    m = strcmpi('utctime',a(:,1));
    a(m,n+1) = {'utctime'};
    a(m,n+2) = {'hhmmss_fff'};
    m = strcmpi('latitude',a(:,1)) & strcmpi('degrees and decimal minutes',a(:,2));
    a(m,n+1) = {'latdegm'};
    a(m,n+2) = {'dddmm'};
    m = strcmpi('longitude',a(:,1)) & strcmpi('degrees and decimal minutes',a(:,2));
    a(m,n+1) = {'londegm'};
    a(m,n+2) = {'dddmm'};
    m = strcmpi('waterDepthMeterTransducer',a(:,1)) | strcmpi('waterDepthMeterFromTransducer',a(:,1));
    a(m,n+1) = {'depth_below_xducer'};
    a(m,n+2) = {'metres'};
    m = strcmpi('waterDepthMeterFromSurface',a(:,1));
    a(m,n+1) = {'waterdepth'};
    a(m,n+2) = {'metres'};
    if strcmp(fn{no},'ea640_sddpt')
        m = strcmpi('depth',a(:,1));
        a(m,n+1) = {'depth_below_xducer'};
        a(m,n+2) = {'metres'};
    end
    if strcmp(fn{no},'em122_kidpt') 
        m = strcmpi('waterdepthmeter',a(:,1));
        a(m,n+1) = {'depth_below_xducer'}; %according to long name
        a(m,n+2) = {'metres'};
    end
    m = strcmpi('degressCelsius',a(:,2)) | strcmpi('degreesCelsius',a(:,2)) | strcmpi('degC',a(:,2));
    a(m,n+2) = {'degreesC'};
    m = strcmpi('courseOverGround',a(:,1)) | strcmpi('courseTrue',a(1,:));
    a(m,n+1) = {'course'};
    m = strcmpi('headingTrue',a(:,2));
    a(m,n+1) = {'heading'};
    m = strcmpi('remoteWaterTemperature',a(:,1)) | strcmpi('tempr',a(:,1));
    a(m,n+1) = {'temp_remote'};
    m = strcmpi('housingWaterTemperature',a(:,1));
    a(m,n+1) = {'temp_housing'};
    m = strcmpi('longitudalWaterSpeed',a(:,1)) | strcmpi('speedfa',a(:,1));
    a(m,n+1) = {'speed_forward'};
    m = strcmpi('transverseWaterSpeed',a(:,1)) | strcmpi('speedps',a(:,1));
    a(m,n+1) = {'speed_stbd'};

    %cut the lines that are the same
    s = strcmp(a(:,1),a(:,n+1)) & strcmp(a(:,2),a(:,n+2));
    a(s,:) = [];

    %temporary!***
    a = a(:,[1 2 end-1:end]); %discard long_name column
    
    %reassign
    if ~isempty(a)
        rtables.(fn{no}) = a;
    end

end
%***lower case units?

rawlist = {
    %     'ships_gyro_hehdt'
    %     'nmf_winch_winch'
    %     'posmv_gyro_gphdt'
    %     'posmv_att_pashr'
    %     'posmv_pos_gpgga'
    %     'posmv_pos_gpvtg'
    'surfmet_gpxsm'
    %'nmf_surfmet_gpxsm'
    %'windsonic_nmea_iimwv'
    %     'cnav_gps_gngga'
    %     'cnav_gps_gnvtg'
    %     'cnav_gps_gngsa'
    %     'dps116_gps_gpgga'
    %     'em120_depth_kidpt'
    %'em640_sddbs'
    %'em122_kidpt'
    %'em600_depth_sddbs'
    %     'env_temp_wimta'
    %     'env_temp_wimhu'
    %     'ranger2_usbl_gpgga'
    'sbe45_nanan'
    %'sbe45_tsg_nanan'
    %     'seapath_pos_ingga'
    %     'seapath_pos_ingsa'
    %     'seapath_pos_invtg'
    %     'seapath_att_psxn23'
    %'ships_chernikeef_vmvbw'
    %'ships_skipperlog_vdvbw'
    'slog_chernikeef_vmvbw'
    %     'u12_at1m_uw'
    %     'seaspy_mag_inmag'
    };
