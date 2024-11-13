function value = nc_global()
%
% version of nc_attput for mexec to replace snctools version
% the aim is to replace snctools nc_ calls with faster versions that make
% simple native matlab netcdf calls.
%
% rather than changing every mexec program, the snctools library can be
% replaced with this library
%
% The old snctools description was
%
% % NC_GLOBAL:  returns enumerated constant NC_GLOBAL in netcdf.h
% %
% % USAGE:  the_value = nc_global;
%

% bak jc191 6 Feb 2020

value = netcdf.getConstant('NC_GLOBAL'); % The number to use as varid global attributes. Expect it to be -1

return
