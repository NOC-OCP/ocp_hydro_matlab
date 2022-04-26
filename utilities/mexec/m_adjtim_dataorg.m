function data = m_adjtim_mstarorg(timename,data,h)
% function data = m_adjtim_mstarorg(timename,data,h)
%
% adjust a time variable from mstar_time_origin to data_time_origin

m_common

tvarnum = strmatch(timename,h.fldnam,'exact');
if length(tvarnum) ~= 1;
    m = ['The variable name ' sprintf('%s',timename) ' does not appear to be a variable name in the header'];
    error(m);
end

unit = h.fldunt{tvarnum};

isdays = m_isunitdays(unit);
issecs = m_isunitsecs(unit);

% if unit not recognised, assume it is seconds

if isdays + issecs == 0
    m = ['time unit ' unit ' not recognised as days or seconds, assumed to be seconds'];
    fprintf(MEXEC_A.Mfider,'\n\n%s\n\n',m)
    issecs = 1;
end

if issecs == 1
    data = data/86400; % convert seconds to days
end

toffset = datenum(h.data_time_origin) - datenum(h.mstar_time_origin);
data = data - toffset;

if issecs == 1
    data = data*86400;
end


