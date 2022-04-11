% m_common
%
% mexec script
% set of common commands to be used at start of an mexec main program
%
% calls:
% m_global
% m_global_args

m_global
m_global_args;
if ~isempty(MEXEC_G)
    mcruise = MEXEC_G.MSCRIPT_CRUISE_STRING;
end