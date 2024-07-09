function mfixperms(fname, varargin)
% mfixperms(filename)
% mfixperms(dirname, 'dir')
% 
% make files (or directories) saved by ocp_hydro_matlab scripts
% have permissions set in MEXEC_G.perms
%
% for multiple users to work on the same files, this appears to be
% necessary as Matlab does not use umask defaults set in .bashrc or
% /etc/bash* 

global MEXEC_G

if isfield(MEXEC_G,'perms')
    if nargin>1 && strcmp(varargin{1},'dir')
        system(sprintf('chmod %d %s', MEXEC_G.perms(2)), fname)
    else
        system(sprintf('chmod %d %s', MEXEC_G.perms(1)), fname)
    end
end