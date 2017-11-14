function ncfile = m_openio(ncfile)
% function ncfile = m_openio(ncfile)
%
% Check a file is a suitable input file, then
% Set the write flag to W 
% The file is now ready to be used for input and output

if nargin ~= 1
    error('Must supply precisely one argument to m_openio');
end

% ncfile.name = m_add_nc(ncfile.name);
ncfile = m_resolve_filename(ncfile);

ncfile = m_ismstar(ncfile); %exit if not mstar file
ncfile = m_exitifopen(ncfile); % exit if write flag set

% Set the write flag so noone else can use the file

nc_attput(ncfile.name,nc_global,'openflag','W'); % set to W if file is open to write. Usual state is R.

return



% % % % % 
% % % % % %check file exists
% % % % % if exist(ncfile.name,'file') ~= 2
% % % % %     error(['Error in m_openio. Filename ''' ncfile.name ''' not found']);
% % % % % end
% % % % % 
% % % % % % The flename has .nc extension so assume it is NetCDF; read the global attributes
% % % % % 
% % % % % metadata = nc_info(ncfile.name); %refresh metadata
% % % % % % ncfile.metadata = metadata;
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
% % % % % % Set the write flag so noone else can use the file
% % % % % 
% % % % % 
% % % % % nc_attput(ncfile.name,nc_global,'openflag','W'); % set to W if file is open to write. Otherwise R.
% % % % % 
% % % % % 
% % % % % return

