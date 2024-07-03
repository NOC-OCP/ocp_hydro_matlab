function rtables = mrrename_varsunits(tables,varargin)
% function renametables = mrrename_varsunits(tables)
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
%   change much from cruise to cruise. It may be added to from time to
%   time. ***or put in cropt?***
%
% At the end of the function, ensures that all new variable names are
%   lowercase, regardless of what has been entered row by row.
%
% Examples
%
%   renametables = mrrename_varsunits;
%
% Input:
%   tables, the output of mrtables_from_json
%
% Output:
%
% renametables. A structure which is a set of rvdas table names and variables that will be
% renamed in mrload after reading into matlab and before writing to mexec.
%
% Examples of fields for renaming
%    renametables.ships_gyro_hehdt = {'headingTrue'  'degrees'  'heading' 'degrees'}
%    renametables.nmf_winch_winch = {'tension'  'newton'  'tension'  'tonnes'}
%    renametables.posmv_gyro_gphdt = {'headingTrue'  'degrees'  'heading' 'degrees'}
%    renametables.posmv_pos_gpgga = {'latitude'  'degrees and decimal minutes' 'latdegm'  'dddmm'}
%    renametables.posmv_pos_gpgga = {'longitude'  'degrees and decimal minutes' 'londegm'  'dddmm'}


m_common

fn = fieldnames(tables);
for no = 1:length(fn)
        
    a = tables.(fn{no})(2:end,:);    
    
    %add columns for new-name and new-units
    n = size(a,2);
    a = [a a(:,1:2)];

    %change any names that don't work for mexec (mostly, shorten ones that are too long)
    for vno = 1:size(a,1)
        a{vno,3} = m_check_nc_varname(a{vno,1},0);
    end
    
    %special cases
    m = strcmpi('utctime',a(:,1));
    a(m,n+1) = {'utctime'};
    a(m,n+2) = {'hhmmss_fff'};
    m = strcmpi('latitude',a(:,1)) & (strcmpi('degrees and decimal minutes',a(:,2)) | strcmpi('degrees, minutes and decimal minutes',a(:,2)));
    a(m,n+1) = {'latdegm'};
    a(m,n+2) = {'dddmm'};
    m = strcmpi('longitude',a(:,1)) & (strcmpi('degrees and decimal minutes',a(:,2)) | strcmpi('degrees, minutes and decimal minutes',a(:,2)));
    a(m,n+1) = {'londegm'};
    a(m,n+2) = {'dddmm'};
    m = strcmpi('waterDepthMeterFromSurface',a(:,1));
    a(m,n+1) = {'waterdepth'};
    a(m,n+2) = {'metres'};
    m = strcmpi('waterDepthMeterTransducer',a(:,1)) | strncmpi('waterDepthMeterFromTransdu',a(:,1),26);
    a(m,n+1) = {'depth_below_xducer'};
    a(m,n+2) = {'metres'};
    if (contains(fn{no},'ea640') || contains(fn{no},'singlebeam_kongsberg')) && contains(fn{no},'sddpt')
        m = strcmpi('depth',a(:,1));
        a(m,n+1) = {'depth_below_xducer'};
        a(m,n+2) = {'metres'};
    end
    if (contains(fn{no},'em122') || contains(fn{no},'multibeam_kongsberg')) && contains(fn{no},'kidpt')
        m = strcmpi('waterdepthmeter',a(:,1));
        a(m,n+1) = {'depth_below_xducer'}; %according to long name
        a(m,n+2) = {'metres'};
    end
    m = strcmpi('degressCelsius',a(:,2)) | strcmpi('degreesCelsius',a(:,2)) | strcmpi('degC',a(:,2));
    a(m,n+2) = {'degreesC'};
    m = strcmpi('courseOverGround',a(:,1)) | strcmpi('courseTrue',a(:,1));
    a(m,n+1) = {'course'};
    m = strcmpi('headingTrue',a(:,2));
    a(m,n+1) = {'heading'};
    m = strcmpi('remoteWaterTemperature',a(:,1)) | strcmpi('tempr',a(:,1));
    a(m,n+1) = {'temp_remote'};
    m = strcmpi('housingWaterTemperature',a(:,1));
    a(m,n+1) = {'temp_housing'};
    m = strcmpi('longitudinalWaterSpeed',a(:,1)) | strcmpi('longitudalWaterSpeed',a(:,1)) | strcmpi('speedfa',a(:,1));
    a(m,n+1) = {'speed_forward'};
    m = strcmpi('transverseWaterSpeed',a(:,1)) | strcmpi('speedps',a(:,1));
    a(m,n+1) = {'speed_stbd'};
    m = strcmpi('seasurfacetemperature',a(:,1));
    a(m,n+1) = {'sst'};
    m = strcmpi('temperature',a(:,1));
    a(m,n+1) = {'temp'};
    m = strcmpi('conductivity',a(:,1));
    a(m,n+1) = {'cond'};
    m = strcmpi('divalueallchannels',a(:,1));
    a(m,n+1) = {'ucsw_hoist'};

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

