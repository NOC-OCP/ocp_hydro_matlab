function nc_addvar (ncfile , v)
%
% version of nc_addvar for mexec to replace snctools version
% the aim is to replace snctools nc_ calls with faster versions that make
% simple native matlab netcdf calls.
%
% rather than changing every mexec program, the snctools library can be
% replaced with this library
%
% In this version, varaiable v has Name. Dimension and Ncype
% This is called from mexec program m_add_variable name; attributes are
% added later in m_add_default_variable_attributes.
%
% The old snctools description was
%
% % NC_ADDVAR:  adds a variable to a NetCDF file
% %
% % USAGE:  nc_addvar ( ncfile, varstruct );
% %
% % PARAMETERS:
% % Input
% %    ncfile:
% %    varstruct:
% %        This is a structure with four fields:
% %
% %        Name
% %        Nctype
% %        Dimension
% %        Attribute
% %
% %      "Name" is just that, the name of the variable to be defined.
% %
% %      "Nctype" should be
% %          'double', 'float', 'int', 'short', or 'byte', or 'char'
% %          'NC_DOUBLE', 'NC_FLOAT', 'NC_INT', 'NC_SHORT', 'NC_BYTE', 'NC_CHAR'
% %
% %      "Dimension" is a cell array of dimension names.
% %
% %      "Attribute" is also a structure array.  Each element has two
% %      fields, "Name", and "Value".
%
%
% bak jc191 6 Feb 2020
%

ncid = netcdf.open(ncfile,'WRITE');

num_dims_v = length(v.Dimension);
dimids = nan(1,num_dims_v);

for k = 1:num_dims_v
    dimids(1,k) = netcdf.inqDimID(ncid,v.Dimension{k});
end

% we seem to need to flip the dimids to get the same effect as the snctools
% nc_addvar

dimids = fliplr(dimids);

netcdf.reDef(ncid);

varid = netcdf.defVar(ncid, v.Name , v.Nctype, dimids );

netcdf.endDef(ncid );

netcdf.close(ncid );

return
