function [isdays,issecs] = m_parseunit_time(unitname)
% function [isdays,issecs] = m_parseunit_time(unitname)
%
% determine if variable unit matches anything in the list of recognised
% 'days' units or 'secs' units

m_common

nnames = length(MEXEC_A.Mtimunits_days);
isdays = 0; 
for k = 1:nnames
    daynam = MEXEC_A.Mtimunits_days{k};
    if strncmp(unitname,daynam,length(daynam))
        isdays = 1;
        return
    end
end

nnames = length(MEXEC_A.Mtimunits_seconds);
issecs = 0; 
for k = 1:nnames
    secnam = MEXEC_A.Mtimunits_seconds{k};
    if strncmp(unitname,secnam,length(secnam))
        issecs = 1;
        return
    end
end
