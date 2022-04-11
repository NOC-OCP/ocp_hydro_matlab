function isdays = m_isunitdays(unitname)
% function isdays = m_isunitdays(unitname)
%
% determine if variable unit matches anything in the list of recognised
% 'days' units

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

        