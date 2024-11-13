function nc_padheader (ncfile , num_bytes)
%
% version of nc_padheader for mexec to replace snctools version
% the aim is to replace snctools nc_ calls with faster versions that make
% simple native matlab netcdf calls.
%
% rather than changing every mexec program, the snctools library can be
% replaced with this library
%
% The old snctools description was
%
% % NC_PADHEADER:  pads the metadata header of a netcdf file
% %
% % When a netCDF file gets very large, adding new attributes can become
% % a time-consuming process.  This can be mitigated by padding the
% % netCDF header with additional bytes.  Subsequent new attributes will
% % not result in long time delays unless the length of the new
% % attribute exceeds that of the header.
% %
% % USAGE:  nc_padheader ( ncfile, num_bytes );
%
%
% bak jc191 6 Feb 2020
%

ncid = netcdf.open(ncfile,'WRITE');

netcdf.reDef(ncid);

%
% Sets the padding to be "num_bytes" at the end of the header section.
%

netcdf.endDef(ncid,num_bytes,4,0,4);

netcdf.close(ncid);

return

