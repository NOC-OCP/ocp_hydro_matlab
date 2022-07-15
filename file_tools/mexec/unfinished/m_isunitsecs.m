function issecs = m_isunitsecs(unitname)
% function issecs = m_isunitsecs(unitname)
%
% determine if variable unit matches anything in the list of recognised
% 'seconds' units

m_common

nnames = length(MEXEC_A.Mtimunits_seconds);

issecs = 0; 
for k = 1:nnames
    secnam = MEXEC_A.Mtimunits_seconds{k};
    if strncmp(unitname,secnam,length(secnam))
        issecs = 1;
        return
    end
end

        