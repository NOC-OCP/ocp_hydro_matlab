function ncfile = m_openin(ncfile)
% function ncfile = m_openin(ncfile)
%
% Check a file is a suitable input file

if nargin ~= 1
    error('Must supply precisely one argument to m_openio');
end

ncfile = m_resolve_filename(ncfile);

ncfile = m_ismstar(ncfile); %exit if not mstar file

if isfield(ncfile,'noflagcheck')
    noflagcheck = ncfile.noflagcheck;
    ncfile = rmfield(ncfile,'noflagcheck'); %noflag check is used once only then reset
else
    noflagcheck = 0;
end
if noflagcheck == 0
    % set ncfile.noflagcheck = 1 to avoid this check
    ncfile = m_exitifopen(ncfile); % exit if write flag set
end

% % % Set the write flag so noone else can use the file
% % 
% % nc_attput(ncfile.name,nc_global,'openflag','W'); % set to W if file is open to write. Usual state is R.

return