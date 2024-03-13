function m_create_file(ncfile)
% function m_create_file(ncfile)
%
% Create an empty mstar file, ncfile, and create 'header' data in NetCDF global attributes
%

m_common


d = fileparts(ncfile.name);
if ~exist(d,'dir')
    warning('creating directory %s',d)
    mkdir(d)
end
nc_create_empty(ncfile.name,'nc_clobber');

hdef = m_default_attributes;

m_write_header(ncfile,hdef);

m_create_padvar(ncfile);

nc_padheader(ncfile.name,17752);

m_update_filedate(ncfile);

return
