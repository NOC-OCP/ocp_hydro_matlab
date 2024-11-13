function diminfo = nc_getdiminfo(ncfile , dimname)
%
% version of nc_getdiminfo for mexec to replace snctools version
% the aim is to replace snctools nc_ calls with faster versions that make
% simple native matlab netcdf calls.
%
% rather than changing every mexec program, the snctools library can be
% replaced with this library
%
% In this version, the dimname is always a name, not a dimid.
% In the old snctools version, it was possible to pass in the dimid
% of an already open file.
%
% The old snctools description was
%
% % NC_GETDIMINFO:  returns metadata about a specific NetCDF dimension
% %
% % DINFO = NC_GETDIMINFO(NCFILE,DIMNAME) returns information about the
% % dimension DIMNAME in the netCDF file NCFILE.
% %
% % DINFO = NC_GETDIMINFO(NCID,DIMID) returns information about the
% % dimension with numeric ID DIMID in the already-opened netCDF file
% % with file ID NCID.  This form is not recommended for use from the
% % command line.
% %
% % Upon output, DINFO will have the following fields.
% %
% %    Name:
% %        a string containing the name of the dimension.
% %    Length:
% %        a scalar equal to the length of the dimension
% %    Unlimited:
% %        A flag, either 1 if the dimension is an unlimited dimension
% %        or 0 if not.
%
%
% bak jc191 6 Feb 2020
%

ncid=netcdf.open(ncfile,'NOWRITE');

[ndims,nvars,ngatts,unlimited_dimnum] = netcdf.inq(ncid); % save the unlimited dimnum if there is one

dimid = netcdf.inqDimID(ncid , dimname);

[diminfo.Name, diminfo.Length] = netcdf.inqDim(ncid, dimid);

% check for unlimited dimension. This has not been extensively tested.

diminfo.Unlimited = 0;

if dimid == unlimited_dimnum
    diminfo.Unlimited = 1;
end

netcdf.close(ncid);

return