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

disp(' ')
disp('Finishing up')

m_verson(ncfile,version_increment); %advance the version
m_add_history(ncfile);
m_update_filedate(ncfile); % set the file update variable

nc_attput(ncfile.name,nc_global,'openflag','R'); %set the open/writing attribute

return