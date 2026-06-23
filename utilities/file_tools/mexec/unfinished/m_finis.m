function m_finis(ncfile,version_increment)
% function m_finis(ncfile,version_increment)
%
% write to history, cleanup and close a file
% version_increment (optional) can be zero when loading pstar files to mstar

m_common

MEXEC_A.MARGS_IN_LOCAL_OLD = MEXEC_A.MARGS_IN_LOCAL;
MEXEC_A.MARGS_IN_LOCAL = {}; %clean up MEXEC_A.MARGS_IN_LOCAL in case there are any unused input arguments
% first, save what's left in case it is needed for passing from program to
% program

if nargin == 1; version_increment = 1; end

if ~MEXEC_G.quiet
    disp(' ')
    disp('Finishing up')
end

if isfield(MEXEC_G,'VERSION_FILE') && exist(MEXEC_G.VERSION_FILE,'file')
    m_verson(ncfile,version_increment); %advance the version
end
%m_add_history(ncfile); %with mfsave this no longer contains useful info,
%instead it should be added explicitly by calling programs
m_update_filedate(ncfile); % set the file update variable

nc_attput(ncfile.name,nc_global,'openflag','R'); %set the open/writing attribute

return
