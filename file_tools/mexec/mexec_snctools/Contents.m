% mexec snctools toolbox 
%
% v 1.0 bak on jc191, 24N hydro cruise 7 Feb 2020
%
% This set of .m scripts is intended to replace the snctools toolbox.
%
% Rather than edit all the mexec programs, a new set of routines has been
% written and is intended to have identical names and outputs as the
% snctools routines of the same name.
% 
% Not every snctools routine has been replaced. But as far as I can tell at
% the time of writing, every snctools routine that is calleed by mexec has
% been replaced.
%
% The original snctools routines did a lot of checking, and could be very
% slow for routines called often. Many mexec programs or scripts executed
% very slowly because of time spent in snctools. Especially nc_info..
%
% The new routines don't do very much checking of calling arguments. It is
% assumed that if the routine is called from a program or mexec processing
% scripts, then the call will be properly formatted.
%
% The resulting library executes much much faster than snctools used to.
%
% The calls all use the matlab netcdf command, eg  netcdf.inqVar, and so
% on. There are no residual calls (that I can find) to the old mexnc library.
% So all that is needed is the netcdf.xxxxx commands.
%
% The matlab netcdf library has commands like "ncread". These have been
% avoided, since they are often slower. Useful commands for investigating
% NetCDF files include ncinfo, ncdisp.
%
% The code was written with mexec NetCDF files in mind. 
% For example _FillValue is recognised on both
% input and output, but "missing_value" is not given special treatment.
% One view is that 'missing value' is for information for the user, and
% should not necessarily be changed to NaN.
% Handling of unlimited dimensions may fail in some places,
% because it has not been extensively tested. mexec netcdf does not use
% unlimited dimensions.
%
% When this library started to be used for routine mecxec processing, it broke when
% reading a CODAS netcdf file. This is because it tried to read a _FillValue
% attribute, which did not exist. This glitch was fixed, but there could be
% others if reading non-mexec NetCDF files.
%
% 8 Feb: added handling of scale_factor and add_offset in nc_varget and
% nc_varput. If there is scaling or offset, then the _FillValue is handled in the
% normalisation of the scaled/offset file variable not the real world variable.
% This convention agrees with the matlab ncread and ncwrite commands.
%
% Files in this library, each of which has some help comments
%
% Contents.m
% nc_add_dimension.m
% nc_addvar.m
% nc_attget.m
% nc_attput.m
% nc_attputq.m (alias for nc_attput)
% nc_create_empty.m
% nc_getdiminfo.m
% nc_getvarinfo.m
% nc_global.m
% nc_info.m
% nc_infoqatt.m (alias for nc_info)
% nc_infoqdim.m (alias for nc_info)
% nc_infoq.m    (alias for nc_info)
% nc_padheader.m
% nc_varget.m
% nc_varput.m
% nc_varrename.m
