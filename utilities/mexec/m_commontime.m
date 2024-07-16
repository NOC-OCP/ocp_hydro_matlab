function [time1_new, varargout] = m_commontime(varargin)
% function time1_new = m_commontime(time1,uo1,uo2);
% function time1_new = m_commontime(d,timevar,uo1,uo2);
% function [time1_new, units_new] = m_commontime(d,timevar,uo1,uo2);
%
% transform one time variable, time1 or d.(timevar), from the units-origin
%   base given by uo1 to that given by uo2 
%
% if timevar is not specified it defaults to 'time'
%
% uo1 and uo2 are input in order and can have information in one (the same)
%   or two (different) forms from this list: 
% a) string of cf-format units (e.g. 'seconds since 2023-01-31 10:00:05')
% b) the string 'datenum' (equivalent to 'days since 0000-00-00
%    00:00:00')
% c) a 3- to 6-element numeric vector [yyyy mm dd HH MM SS] giving the time
%    origin; units assumed to be in seconds
% d) structure containing one or both of:
%    data_time_origin vector, and
%    two matching cell arrays of strings, fldnam and fldunt, or names and
%      units, with timevar ocurring once in the first array and time units
%      (e.g. 'seconds' or 'days') taken from the corresponding position in
%      the second array
%    if names and units are not listed, units default to 'seconds'
%    if data_time_origin is not present or is empty, the units string (in
%      fldunt or units field of structure, matching timevar in fldnam or
%      names field) must be cf-format 
%
% e.g.
%
% [d1,h1] = mload(file1,'/'); [d2,h2] = mload(file2,'/');
% time1_new = m_commontime(d1.time,h1.data_time_origin,h2.data_time_origin);
% % time1_new can now be compared with d2.time (assuming h1 and h2
% % data_time_origin were not empty)
%
% [d1,h1] = mload('sam_dy146_all','/');
% d1.utime = m_commontime(d1,'utime',h1,'days since 2022-01-01');
% % d1.utime is now decimal days in 2022
% d1.utime = m_commontime(d1,'utime','days since 2022-1-1',[2022 1 12]);
% % d1.utime has now had 11*86400 subtracted from it (is now in seconds
%   since 2022-01-12 00:00:00)
%
% optional second output units_new is the cf-format time units string
%   corresponding uo2 (it may be the same as uo2)


%figure out inputs
if nargin==4
    timevar = varargin{2};
    in1 = varargin{3};
    in2 = varargin{4};
elseif nargin==3
    timevar = 'time';
    in1 = varargin{2};
    in2 = varargin{3};
else
    error('must have 3 or 4 input arguments')
end
if isstruct(varargin{1})
    d = varargin{1};
elseif isnumeric(varargin{1})
    d.(timevar) = varargin{1};
else
    error('first input must be structure or vector')
end

%parse units and origins from inputs
[unt{1}, dto(1,:)] = parse_time_units(in1,timevar);
[unt{2}, dto(2,:)] = parse_time_units(in2,timevar);

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
time1_new = (d.(timevar)/fac(1) + datenum(dto(1,:)) - datenum(dto(2,:)))*fac(2);

if nargout>1
    varargout{1} = [unt{2} ' since ' datestr(dto(2,:),'yyyy-mm-dd HH:MM:SS')];
end


function [uni,ori] = parse_time_units(in,timevar)
if iscell(in)
    if length(in)==1
        in = in{1};
    else
        error('non-scalar cell array input not accepted')
    end
end
if ischar(in)
    if strcmp(in,'datenum')
        uni = 'days';
        ori = [0 0 0 0 0 0];
    else
        [uni, ori] = timeunits_mstar_cf(in); %separate units and origin
        if isempty(ori)
            error('input %s is a string but not a cf time unit',in)
        end
    end
elseif isstruct(in)
    if isfield(in,'fldnam')
        m = strcmp(timevar,in.fldnam);
        u = 'fldunt';
    elseif isfield(in,'names')
        m = strcmp(timevar,in.names);
        u = 'units';
    else
        uni = 'seconds'; 
        ori = in1.data_time_origin;
        m = NaN;
    end
    if sum(m)==0
        error('%s not found in in',timevar) %in this case don't trust data_time_origin matches either
    elseif sum(m)==1
        [uni, ori] = timeunits_mstar_cf(in.(u){m});
        if isempty(ori)
            %revert to using data_time_origin
            ori = in.data_time_origin;
        end
    end
elseif isnumeric(in) && length(in)>=3 
    ori = in;
    uni = 'seconds';
end
if length(ori)<6
    ori = [ori zeros(1,6-length(ori))];
end
