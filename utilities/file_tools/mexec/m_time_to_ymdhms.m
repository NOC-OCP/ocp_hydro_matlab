function [yy mo dd hh mm ss dayofyear] = m_time_to_ymdhms(vname,vdata,h)
% function [yy mo dd hh mm ss dayofyear] = m_time_to_ymdhms(vname,vdata,h)
%
% convert time in days or seconds, as identified by h.fldunt and h.data_time_origin,
% to vector
% seconds are rounded to nearest integer

m_common

if isnan(vdata)
    yy = nan; mo = nan; dd = nan;
    hh = nan; mm = nan; ss = nan;
    dayofyear = nan;
    return
end

varnum = m_findvarnum(vname,h);

unit = h.fldunt{varnum};

if isempty(h.data_time_origin)
    dnum = m_commontime(vdata,unit,'datenum');
else
    d.(vname) = vdata;
    dnum = m_commontime(d,vname,h,'datenum');
end
[yy mo dd hh mm ss] = datevec(dnum);
ss = round(ss);
% machine rounding error in the datenum/datvec conversion can cause ss=60
% to be returned as ss=59.9999923706055
ss = ss+0.001;
z = datenum([yy mo dd hh mm ss]); % Use matlab algorithms to take care of ss = 60, mm = 60 etc
[yy mo dd hh mm ss] = datevec(z);
ss = round(ss);

if nargout == 7
    dayofyear = 1+ floor(dnum - datenum([yy 1 1 0 0 0]));
end
