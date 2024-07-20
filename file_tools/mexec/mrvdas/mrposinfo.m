function [latout,lonout] = mrposinfo(varargin)
% function mrposinfo(rtable,dnum,qflag)
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
% rtable: is the rvdas table name or the mexec shorthand. The default
%   is taken from MEXEC_G.MEXEC_G.default_navstream. The table must be one
%   that has an mexec shorthand.
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
rtable = argot.table;
qflag = argot.qflag;


m_common

if isempty(rtable)
    opt1 = 'ship'; opt2 = 'datasys_best'; get_cropt
    rtable = default_navstream;
end
[rtable, mtable] = mrresolve_table(rtable); %make it an rvdas table name

if length(argot.dnums) < 1
    dn = now-10/86400;
else
    dn = argot.dnums(1);
end

argot.dnums = dn+[-5 5]*60/86400; %load 30 min either side
d = mrload('noparse',argot); 

if ~isfield(d,'latitude') || ~isfield(d,'longitude')
    if isempty(qflag)
    fprintf(MEXEC_A.Mfider,'%s %s\n','latitude or longitude not found in table', rtable);
    end
    % create d.lat and d.lon as empty, so rest of code works
    d.latitude = [];
    d.longitude = [];
end

if isempty(d.latitude)
    lat = nan;
    lon = nan;
else
    m = diff(d.dnum)<=0;
    if sum(m)
        warning('removing %d repeated or backwards times',sum(m))
        ii = 1+find(~m); ii = [1; ii(:)];
    else
        ii = 1:length(d.dnum);
    end
    lat = interp1(d.dnum(ii),d.latitude(ii),dn);
    lon = interp1(d.dnum(ii),d.longitude(ii),dn);
end

switch nargout
    case 2
        latout = lat;
        lonout = lon;
    otherwise % put everything of interest into the first argument
        latout.lat = lat;
        latout.lon = lon;
        latout.mexec_table = mtable;
        latout.rvdas_table = rtable;
        latout.dnum = dn;
        latout.datestring = datestr(latout.dnum,31);
        latout.latitude = lat;
        [latout.latdeg,latout.latmin] = m_degmin_from_decdeg(lat);
        latout.longitude = lon;
        [latout.londeg,latout.lonmin] = m_degmin_from_decdeg(lon);
        lonout = nan;
end
