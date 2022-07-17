function [rtables,rtables_list] = mrrename_tables(tables,varargin)
% function [renametables,renametables_list] = mrrename_tables(tables,qflag)
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


fn = fieldnames(tables);
for no = 1:length(fn)

    a = tables.(fn{no});
    a = [a a];

    m = strcmp('utcTime',a(:,1));
    a(m,3) = {'utctime'};
    a(m,4) = {'hhmmss_fff'};
    m = strcmp('latitude',a(:,1)) & strcmp('degrees and decimal minutes',a(:,2));
    a(m,3) = {'latdegm'};
    a(m,4) = {'dddmm'};
    m = strcmp('longitude',a(:,1)) & strcmp('degrees and decimal minutes',a(:,2));
    a(m,3) = {'londegm'};
    a(m,4) = {'dddmm'};
    m = strcmp('waterDepthMeterTransducer',a(:,1)) | strcmp('waterDepthMeterFromTransducer',a(:,1));
    a(m,3) = {'waterdepth_below_transducer'};
    a(m,4) = {'metres'};
    m = strcmp('waterDepthMeter',a(:,1)) | strcmp('depthMeter',a(:,1)); %***check for two instruments which is below transducer and which below surface
    a(m,3) = {'waterdepth_below_transducer'};
    a(m,4) = {'metres'};
    m = strcmp('waterDepthMeterFromSurface',a(:,1));
    a(m,3) = {'waterdepth'};
    a(m,4) = {'metres'};
    m = strcmp('degressCelsius',a(:,2)) | strcmp('degreesCelsius',a(:,2)) | strcmp('DegreesCelsius',a(:,2)) | strcmp('degC',a(:,2));
    a(m,4) = {'degreesC'};
    m = strcmp('courseOverGround',a(:,1)) | strcmp('courseTrue',a(1,:));
    a(m,3) = {'course'};
    m = strcmp('headingTrue',a(:,2));
    a(m,3) = {'heading'};
    m = strcmp('remoteWaterTemperature',a(:,1)) | strcmp('tempr',a(:,1));
    a(m,3) = {'temp_remote'};
    m = strcmp('housingWaterTemperature',a(:,1));
    a(m,3) = {'temp_housing'};
    m = strcmp('longitudalWaterSpeed',a(:,1)) | strcmp('speedfa',a(:,1));
    a(m,3) = {'speed_forward'};
    m = strcmp('transverseWaterSpeed',a(:,1)) | strcmp('speedps',a(:,1));
    a(m,3) = {'speed_stbd'};

    %cut the lines that are the same
    s = strcmp(a(:,1),a(:,3)) & strcmp(a(:,2),a(:,4));
    a(s,:) = [];

    %reassign
    if ~isempty(a)
        rtables.(fn{no}) = a;
    end

end
%lower case units***

rtables_list = fieldnames(rtables);
