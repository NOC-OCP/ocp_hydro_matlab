function m_proghd
% function m_proghd

m_common
% m_getsites  DAS commented out as not found in mexec_v3

% don't reset MEXEC_A.MARGS_IN because this is how arguments are
MEXEC_A.MARGS_OT = {}; % reset list of args for writing to history.
MEXEC_A.Mhistory_in = {};
MEXEC_A.Mhistory_ot = {};

display_string = ['*** ' MEXEC_A.Mprog ' ***'];

% don't display 'extras' names that begin 'mc' or subroutine names that
% begin 'm_'
if strncmp(MEXEC_A.Mprog,'mc',2) == 1
    return
elseif strncmp(MEXEC_A.Mprog,'m_',2) == 1
    return
else
    fprintf(MEXEC_A.Mfider,'\n%s\n\n',display_string);
end

return