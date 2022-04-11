function ncfile = m_openot(ncfile)
% function ncfile = m_openot(ncfile)
%
% Create a new file for mstar output
% Check whether a file already exists
% If not, create it with write flag W so it is ready for output
% If yes and the write flag is W, exit with error
% If yes and the write flag is R, overwrite with a new file and set the
%           flag to W so it is ready for output

if nargin ~= 1
    error('Must supply precisely one argument to m_openot');
end

% ncfile.name = m_add_nc(ncfile.name);
ncfile = m_resolve_filename(ncfile);

e = exist(ncfile.name);

if (e == 7)
    errstr0 = sprintf('\n%s',['You appear to be trying to create a file with name ' ncfile.name ' but a directory of that name already exists']);
    error(errstr0);
end

if (e == 2)
    ncfile = m_ismstar(ncfile); % exit if not mstar file
    ncfile = m_exitifopen(ncfile); % exit if write flag set
end


% Either it doesn't exist 
% or it exists, but is not in use so we will overwrite it.
% Create a new file
m_create_file(ncfile);

return


% % % % %Set the write flag
% % % %
% % % % nc_attput(ncfile.name,nc_global,'openflag','W'); %set the open/writing attribute


% % % % % 
% % % % % 
% % % % % if (e ~= 2 & e ~= 7)
% % % % %     % does not exist as file name or directory
% % % % %     m_create_file(ncfile);
% % % % %     return
% % % % % end
% % % % % 
% % % % % % The flename has .nc extension so assume it is NetCDF; read the global attributes
% % % % % 
% % % % % metadata = nc_info(ncfile.name); %refresh metadata
% % % % % ncfile.metadata = metadata;
% % % % % globatt = metadata.Attribute;
% % % % % for k = 1:length(globatt);
% % % % %     gattname = globatt(k).Name;
% % % % %     gattvalue = globatt(k).Value;
% % % % %     com = ['h.' gattname ' = gattvalue;'];
% % % % %     eval(com)
% % % % % end
% % % % % 
% % % % % if ~isfield(h,'mstar_string')
% % % % %     errstr0 = sprintf('\n%s\n',['Error attempting to open file ' ncfile.name ' which exists but is not an mstar file']);
% % % % %     error(errstr0);
% % % % % end
% % % % % 
% % % % % s = h.mstar_string;
% % % % % if ~strcmp(s(1:5),'mstar')
% % % % %     errstr0 = sprintf('\n%s\n',['Error attempting to open file ' ncfile.name ' which exists but is not an mstar file']);
% % % % %     error(errstr0);
% % % % % end
% % % % % 
% % % % % 
% % % % % % If we get here, the file exists and is a NetCDF file with a global
% % % % % % attribute mstar_string whose first 5 characters are 'mstar'. We therefore
% % % % % % presume this is a mstar netcdf file.
% % % % % 
% % % % % % Check the write flag
% % % % % 
% % % % % openflag = nc_attget(ncfile.name,nc_global,'openflag');
% % % % % 
% % % % % if strcmp(openflag,'W')
% % % % %     %file is already open for write
% % % % %     errstr0 = sprintf('\n%s\n',['Error attempting to open file ' ncfile.name ' which is already open for write']);
% % % % %     error(errstr0);
% % % % % end
% % % % % 
% % % % % % It exists, btu is not in use. We will overwrite it.
% % % % % % Create a new file
% % % % % m_create_file(ncfile);
% % % % % 
% % % % % 
% % % % % % % % % %Set the write flag
% % % % % % % % %
% % % % % % % % % nc_attput(ncfile.name,nc_global,'openflag','W'); %set the open/writing attribute
% % % % % 
% % % % % return