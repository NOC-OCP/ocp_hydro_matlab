function time1_origin2 = m_commontime(varargin)
% function time1_origin2 = m_commontime(d,timevar,h1,h2);
% function time1_origin2 = m_commontime(d,'time',h1,h2);
% function time1_origin2 = m_commontime(d,'utime',h1,h2);
% function time1_origin2 = m_commontime(d,timevar,h1,units2);
% function time1_origin2 = m_commontime(d,'time',units1,units2);
% function time1_origin2 = m_commontime(d,'time_start',h1,data_time_origin2);
% function time1_origin2 = m_commontime(time,units1,data_time_origin2);
% etc.
%
% put one mstar file time variable into the same units (including origin)
%   as another, using information on the current and desired units in a
%   mixture of the following forms:
% a) structure (e.g. mstar file header variable) containing
%   data_time_origin (units assumed to be seconds) 
% b) structure containing timevar in cell array field fldnam, and cf-format
%   time units in corresponding position in cell array field fldunt  
% c) data_time_origin vector [yyyy mm dd HH MM SS] (units assumed to be
%   seconds) 
% d) cf-format units as string
%
% With 4 input arguments:
%   1) structure (mstar data structure)
%   2) name of the time variable in the structure
%   3) current time units
%   4) desired time units
% any of a, b, c, d can be used for the units
% With 3 input arguments: 
%   1) vector of times
%   2) current time units
%   3) desired time units
% only c and/or d can be used for the units
%
% e.g.
%
% [d1,h1] = mload(file1,'/'); [d2,h2] = mload(file2,'/');
% time1_origin2 = m_commontime(d1.time,h1.data_time_origin,h2.data_time_origin);
% % time1_origin2 can now be compared with d2.time
%
% [d1,h1] = mload('sam_dy146_all','/');
% d1.utime = m_commontime(d1,'utime',h1,'days since 2022-01-01');
% % d1.utime is now decimal days in 2022
% d1.utime = m_commontime(d1,'utime','days since 2022-1-1',[2021 1 1]);
% % d1.utime has now had 365 added to it


%figure out inputs
if nargin==4 && isstruct(varargin{1})
    d = varargin{1};
    timevar = varargin{2};
    in1 = varargin{3};
    in2 = varargin{4};
elseif nargin==3 && isnumeric(varargin{1})
    d.time = varargin{1};
    timevar = 'time';
    in1 = varargin{2};
    in2 = varargin{3};
else
    error('must have 3 or 4 input arguments, first must be structure or vector')
end

%parse units and origin
if ischar(in1)
    [unt{1}, o] = timeunits_mstar_cf(in2);
    if isempty(o)
        error('input %s not cf time unit',in1)
    end
elseif isstruct(in1)
    m = strcmp(timevar,in1.fldnam);
    if ~sum(m)
        error('%s not found in h1',timevar) %in this case don't trust data_time_origin matches either
    else
        [unt{1}, o] = timeunits_mstar_cf(in1.fldunt{m});
        if isempty(o)
            %revert to using data_time_origin
            o = in1.data_time_origin;
        end
    end
else
    o = in1;
    unt{1} = 'seconds';
end
if length(o)<6
    o = [o zeros(1,6-length(o))];
end
dto(1,:) = o;

if ischar(in2)
    [unt{2}, o] = timeunits_mstar_cf(in2);
    if isempty(o)
        error('input %s not cf time unit',in2)
    end
elseif isstruct(in2)
    m = strcmp(timevar,in2.fldnam);
    if ~sum(m)
        m = strcmp('time',in2.fldnam) | strcmp('utime',in2.fldnam);
        if sum(m)
            warning('guessed %s in h2 to compare with %s',in2.fldnam{m},timevar)
        else
            error('%s not found in h2',timevar) %in this case don't trust data_time_origin matches either
        end
    end
    [unt{2}, o] = timeunits_mstar_cf(in2.fldunt{m});
    if isempty(o)
        %revert to using data_time_origin
        o = in2.data_time_origin;
    end
else
    o = in2;
    unt{2} = 'seconds';
end
if length(o)<6
    o = [o zeros(1,6-length(o))];
end
dto(2,:) = o;

%convert units to factor (divide by this to get days)
fac = nan(2,1);
for no = 1:2
    if strncmp(unt{no},'sec',3) || strcmp(unt{no},'s')
        fac(no) = 3600*24;
    elseif strncmp(unt{no},'min',3)
        fac(no) = 60*24;
    elseif strncmp(unt{no},'hour',4) || strcmp(unt{no},'h') || strcmp(unt{no},'hr')
        fac(no) = 24;
    elseif strncmp(unt{no},'day',3) || strcmp(unt{no},'d')
        fac(no) = 1;
    end
end

%apply
time1_origin2 = (d.(timevar)/fac(1) + datenum(dto(1,:)) - datenum(dto(2,:)))*fac(2);


