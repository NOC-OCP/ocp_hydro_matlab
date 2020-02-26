function ncfile = m_ismstar(ncfile)
% function ncfile = m_ismstar(ncfile)
%
% Check if a file is an mstar NetCDF file
% v4 version by bak on jc191; Use matlab native netcdf;
% bak jc191 removed second argument 'opt' which was never used

if nargin ~= 1
    error('Must supply precisely one argument to m_ismstar');
end

ncfile.name = m_add_nc(ncfile.name);

% bak will this become v4, using matlab netcdf commands ? jc191: use a single try and matlab native netcdf to try to check
% for a mstar netcdf file

try
    %         s = ncreadatt(ncfile.name,'/','mstar_string');
    ncid=netcdf.open(ncfile.name,'nowrite');
    varid = netcdf.getConstant('GLOBAL'); % usually -1
    s = netcdf.getAtt(ncid,varid,'mstar_string');
    netcdf.close(ncid);
catch
    if exist(ncfile.name,'file') ~= 2
        errstr0 = sprintf('\n%s',['The file ' ncfile.name ' does not exist']);
        error(errstr0);
    else
        errstr0 = sprintf('\n%s',['The file ' ncfile.name ' exists but does not contain the mstar_string']);
        error(errstr0);
    end
end
if ~strcmp(s(1:5),'mstar')
    errstr0 = sprintf('\n%s',['The file ' ncfile.name ' exists but the mstar_string contents are wrong']);
    error(errstr0);
end
return

% bak jc191: old code follows here and should function as before if
% ncreadatt doesnt exist.
% if the matlab netcdf command readatt exists, then the code will have
% exited before this point, either with the catch case, or after
% successfully determining that it is an OK mstar file. If ncreadatt
% is not available, then we revert to the old snctools code of nc_info.

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