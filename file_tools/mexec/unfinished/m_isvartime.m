function istime = m_isvartime(varname)
% function istime = m_isvartime(varname)
%
% determine if variable name matches anything in the list of recognised
% time names

m_common

nnames = length(MEXEC_A.Mtimnames);

istime = 0; 
for k = 1:nnames
    tnam = MEXEC_A.Mtimnames{k};
    if strncmp(varname,tnam,length(tnam))
        istime = 1;
        return
    end
end

        