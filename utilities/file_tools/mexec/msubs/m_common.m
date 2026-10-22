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

if exist('stn','var')
    opt1 = 'setup'; opt2 = 'm_stn_string'; run(MEXEC_G.opt_cruise)
end