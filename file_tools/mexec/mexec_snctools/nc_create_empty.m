function nc_create_empty (ncfile , mode)
%
% version of nc_attget for mexec to replace snctools version
% the aim is to replace snctools nc_ calls with faster versions that make
% simple native matlab netcdf calls.
%
% rather than changing every mexec program, the snctools library can be
% replaced with this library
%
% The old snctools description was
%
% % NC_CREATE_EMPTY:  creates an empty netCDF file
% %     NC_CREATE_EMPTY(NCFILE,MODE) creates the empty netCDF file NCFILE
% %     with the given MODE.  MODE is optional, defaulting to
% %     nc_clobber_mode.
%
%
% bak jc191 6 Feb 2020
%
% In mexec, this is only called from m_create_file, with mode 'nc_clobber'
% mode is 'nc_clobber' or 'nc_noclobber'.
% is also seems that 'clobber' and 'noclobber' are ok.
% The netcdf.create help page refers to 'clobber' and 'noclobber' so translate to that
% form before call to netcdf.create.
%

if strcmp(lower(mode),'nc_noclobber'); mode = 'noclobber'; end
if strcmp(lower(mode),'nc_clobber'); mode = 'clobber'; end

ncid = netcdf.create(ncfile , mode);
netcdf.close(ncid);

return
