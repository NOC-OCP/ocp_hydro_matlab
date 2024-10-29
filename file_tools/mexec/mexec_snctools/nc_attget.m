function attval = nc_attget (ncfile , varname , attribute_name)
%
% version of nc_attget for mexec to replace snctools version
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
% % USAGE:  att_value = nc_attget(ncfile, varname, attribute_name);
% %
% % PARAMETERS:
% % Input:
% %   ncfile:  
% %       name of netcdf file in question
% %   varname:  
% %       name of variable in question.  In order to retrieve a global
% %       attribute, use NC_GLOBAL for the variable name argument.
% %       Do NOT use 'global'!
% %   attribute_name:  
% %       name of attribute in question
% % Output:    
% %   values:  
% %       value of attribute asked for.  Returns the empty matrix 
% %       in case of an error.  
%
%
% bak jc191 6 Feb 2020
%

ncid=netcdf.open(ncfile,'nowrite');
 
if isnumeric(varname)
    % global attribute, can enter -1 in the argument
    varid = netcdf.getConstant('GLOBAL'); % usually -1
else
    varid = netcdf.inqVarID(ncid, varname);
end

attval = netcdf.getAtt(ncid,varid,attribute_name);

netcdf.close(ncid);


% we could use the ncattread utility, but it seems to be slower.
% if isnumeric(varname)
%     % global attribute, value = -1, signified here by '/'
%     varname = '/';
% end
% 
% attval = ncreadatt(ncfile, varname, attribute_name);

return
