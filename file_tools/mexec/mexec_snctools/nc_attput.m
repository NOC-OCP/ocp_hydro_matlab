function nc_attput (ncfile , varname , attribute_name , attval )
%
% version of nc_attput for mexec to replace snctools version
% the aim is to replace snctools nc_ calls with faster versions that make
% simple native matlab netcdf calls.
%
% rather than changing every mexec program, the snctools library can be
% replaced with this library
%
% Use numeric varname = -1 to get a global attribute
%
% The old snctools description was
%
% % NC_ATTPUT:  writes an attribute into a netCDF file
% %     NC_ATTPUT(NCFILE,VARNAME,ATTNAME,ATTVAL) writes the data in ATTVAL to
% %     the attribute ATTNAME of the variable VARNAME of the netCDF file NCFILE.
% %     VARNAME should be the name of a netCDF VARIABLE, but one can also use the
% %     mnemonic nc_global to specify a global attribute.  Do not use 'global'.
%
%
% bak jc191 6 Feb 2020
%

ncid=netcdf.open(ncfile,'WRITE');

if isnumeric(varname)
    % global attribute, can enter -1 in the argument
    varid = netcdf.getConstant('GLOBAL'); % usually -1
else
    varid = netcdf.inqVarID(ncid, varname);
end

netcdf.reDef(ncid); % need to enter def mode in case attribute is new

netcdf.putAtt(ncid,varid,attribute_name, attval);

netcdf.endDef(ncid);

netcdf.close(ncid);

% %
% % % we could use the ncattwrite utility, but it seems to be slower, and we
% % % are only using netcdf.xxxxx() routines.
% %
% % if isnumeric(varname)
% %     % global attribute, value = -1, signified here by '/'
% %     varname = '/';
% % end
% %
% % ncwriteatt(ncfile , varname, attribute_name , attval);

return
