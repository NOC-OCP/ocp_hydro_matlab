function data = m_adjtime(timename,data,h1,h2)
% function data = m_adjtime(timename,data,h1,h2)
%
% adjust a time variable from data_time_origin in h1 to data_time_origin in
% h2

m_common

torg1 = h1.data_time_origin;
torg2 = h2.data_time_origin;
tdif = torg1-torg2;
if max(abs(tdif)) > 0
    %adjust time origin
    m = ['adjusting value of time variable ''' timename ''' for difference in data_time_origin between files'];
    fprintf(MEXEC_A.Mfider,'%s\n',m)
else
    return
end


tvarnum = strmatch(timename,h1.fldnam,'exact');
if length(tvarnum) ~= 1;
    m = ['The variable name ' sprintf('%s',timename) ' does not appear to be a variable name in the header'];
    error(m);
end

unit = h1.fldunt{tvarnum};

[isdays,issecs] = m_parseunit_time(unit);

% if unit not recognised, assume it is seconds

if isdays + issecs == 0
    m = ['time unit ' unit ' not recognised as days or seconds, assumed to be seconds'];
    fprintf(MEXEC_A.Mfider,'\n\n%s\n\n',m)
    issecs = 1;
end

if issecs == 1
    data = data/86400; % convert seconds to days
end

toffset = datenum(h1.data_time_origin) - datenum(h2.data_time_origin);
data = data + toffset;

if issecs == 1
    data = data*86400;
end

return
