function nc_varrename (ncfile, old_name , new_name)
%
% version of nc_varrename for mexec to replace snctools version
% the aim is to replace snctools nc_ calls with faster versions that make
% simple native matlab netcdf calls.
%
% rather than changing every mexec program, the snctools library can be
% replaced with this library
%
% The old snctools description was
%
% % NC_VARRENAME:  renames a NetCDF variable.
% %
% % NC_VARRENAME(NCFILE,OLD_VARNAME,NEW_VARNAME) renames a netCDF variable from
% % OLD_VARNAME to NEW_VARNAME.
%
%
% bak jc191 6 Feb 2020
%


ncid=netcdf.open(ncfile,'write');

netcdf.reDef(ncid); % reDef and endDef may happen automatically, but safer to keep them in the code than leave them out

varid = netcdf.inqVarID(ncid, old_name);

netcdf.renameVar(ncid, varid, new_name);

netcdf.endDef(ncid);

netcdf.close(ncid);

return