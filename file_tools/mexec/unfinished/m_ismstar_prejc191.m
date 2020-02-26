function ncfile = m_ismstar(ncfile,opt)
% function ncfile = m_ismstar(ncfile,opt)
%
% Check if a file is an mstar NetCDF file

if nargin ~= 1
    error('Must supply precisely one argument to m_ismstar');
end

ncfile.name = m_add_nc(ncfile.name);

%check file exists
if exist(ncfile.name,'file') ~= 2
    error(['Checking existence of mstar file: Filename ''' ncfile.name ''' not found']);
end

% The flename exists and has .nc extension so assume it is a NetCDF file; 
% Now read the global attributes

metadata = nc_infoqatt(ncfile.name); %refresh metadata
% ncfile.metadata = metadata;
globatt = metadata.Attribute;
for k = 1:length(globatt);
    gattname = globatt(k).Name;
    gattvalue = globatt(k).Value;
    com = ['h.' gattname ' = gattvalue;'];
    eval(com)
end

if ~isfield(h,'mstar_string')
    errstr0 = sprintf('\n%s',['The file ' ncfile.name ' exists but is not an mstar file']);
    error(errstr0);
end

s = h.mstar_string;
if ~strcmp(s(1:5),'mstar')
    errstr0 = sprintf('\n%s',['The file ' ncfile.name ' exists but is not an mstar file']);
    error(errstr0);
end

% If we get here without exiting, the file exists and is a NetCDF file with a global
% attribute mstar_string whose first 5 characters are 'mstar'. We therefore
% presume this is a mstar netcdf file.

return