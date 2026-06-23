function nc_add_dimension(ncfile , dimname , dimlen)
%
% version of nc_add_dimension for mexec to replace snctools version
% the aim is to replace snctools nc_ calls with faster versions that make
% simple native matlab netcdf calls.
%
% rather than changing every mexec program, the snctools library can be
% replaced with this library
%
% The old snctools description was
%
% % NC_ADD_DIMENSION:  adds a dimension to an existing netcdf file
% %
% % USAGE:  nc_add_dimension ( ncfile, dimension_name, dimension_size );
% %
% % PARAMETERS:
% % Input:
% %     ncfile:  path to netcdf file
% %     dimension_name:  name of dimension to be added
% %     dimension_size:  length of new dimension.  If zero, it will be an
% %         unlimited dimension.
% % Output:
% %     none
%
%
% bak jc191 6 Feb 2020
%
%
% Note from netcdf.defDim page:
% dimlen for unlimited dimensions should be specified by the constant value for 'UNLIMITED'.
% eg
% timeDimId = netcdf.defDim(ncid,'time',netcdf.getConstant('UNLIMITED'));
%
% netcdf.getConstant('UNLIMITED') seems to be zero
%

ncid = netcdf.open(ncfile, 'WRITE' );

netcdf.reDef(ncid );

dimid = netcdf.defDim(ncid, dimname, dimlen);

netcdf.endDef(ncid );

netcdf.close(ncid );

return


