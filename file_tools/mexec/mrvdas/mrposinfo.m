function [latout,lonout] = mrposinfo(varargin)
% function mrposinfo(table,dnum,qflag)
% 
% *************************************************************************
% mexec interface for RVDAS data acquisition
% First drafts of scripts for start jc211 28 jan 2021, alongside in Stanley
% 
% Evolution on that cruise by bak, ylf, pa
% *************************************************************************
%
% Get position from an rvdas table at the specified time, or at the last
% time. Position is interpolated onto the time with interp1.
%
% Examples
%
%   [lat,lon] = mrposinfo; % use default navigation table name
%
%   [lat,lon] = mrposinfo('possea');
%
%   [lat,lon] = mrposinfo('possea','q');
%
%   dd = mrposinfo;
%
%   dd = mrposinfo('possea');
%
%   mrposinfo possea q; dd = ans;
%
% Input:
%
% The input arguments are parsed through mrparseargs. See the extensive
%   help in that function for descriptions of the arguments.
%
% table: is the rvdas table name or the mexec shorthand. The default
%   is taken from MEXEC_G.MEXEC_G.default_navstream
% If qflag is 'q', fprintf will be suppressed in calls to 
%   mrload, and so will a possible error message. Default is ''.
% dnum is a datenum or datevec at which the position is to be reported.
%   Default is now-10 seconds. The call to mrload will load data for 5
%   minutes either side of dnum. If the data pulled in doesn't have data that
%   bracket the dnum time, the position will be reported as NaN. So a long
%   data gap around the time of dnum should report a position of naN. If
%   the lastest position in rvdas is more than 10 seconds before now, and
%   no other dnum has bene specified, the position will be reported as Nan.
%
% Output:
%
% If called with two output arguments, lat and lon are returned
% If called with any other number, a structure is returned with fields for
%   lat
%   lon
%   mexec_table name
%   rvdas_table name
%   dnum : time onto which position was interpolated
%   datestring of dnum
%   latitude     (same value as lat, but full name)
%   latdeg, latitude degrees, negative if southern hemisphere
%   latmin, latitude minutes, always positive. latdeg is negative in S hemisphere
%   longitude    (same value as lon, but full name)
%   londeg, longitude degrees, negative if western hemisphere
%   lonmin, longitude minutes, always positive. londeg is negative in W hemisphere

argot = mrparseargs(varargin); % varargin is a cell array, passed into mrparseargs
table = argot.table;
qflag = argot.qflag;


m_common

if isempty(table)
    table = MEXEC_G.default_navstream;
end

if 0
    tablemap = mrnames('q');
else
    %replace above with slightly less efficient code but keeps all calls to
    %mrnames inside mrdefine
    def = mrdefine('this_cruise','has_mstarpre');
    %def = mrdefine('this_cruise');
    tablemap = def.tablemap;
end
% sort out the table name
table = mrresolve_table(table); % table is now an RVDAS table name for sure.
ktable = strcmp(table,tablemap(:,2));
mtable = tablemap{ktable,1}; % mtable is the mexec tablename

if length(argot.dnums) < 1
    dn = now-10/86400;
else
    dn = argot.dnums(1);
end

d = mrload(table,dn-5*60/86400,dn+5*60/86400,qflag); % load 30 minutes either side

if ~isfield(d,'latitude') || ~isfield(d,'longitude')
    if isempty(qflag)
    fprintf(MEXEC_A.Mfider,'%s %s\n','latitude or longitude not found in table',mtable);
    end
    % create d.lat and d.lon as empty, so rest of code works
    d.latitude = [];
    d.longitude = [];
end

if isempty(d.latitude)
    lat = nan;
    lon = nan;
else
    lat = interp1(d.dnum,d.latitude,dn);
    lon = interp1(d.dnum,d.longitude,dn);
end

switch nargout
    case 2
        latout = lat;
        lonout = lon;
    otherwise % put everything of interest into the first argument
        latout.lat = lat;
        latout.lon = lon;
        latout.mexec_table = mtable;
        latout.rvdas_table = table;
        latout.dnum = dn;
        latout.datestring = datestr(latout.dnum,31);
        latout.latitude = lat;
        [latout.latdeg,latout.latmin] = m_degmin_from_decdeg(lat);
        latout.longitude = lon;
        [latout.londeg,latout.lonmin] = m_degmin_from_decdeg(lon);
        lonout = nan;
end

return