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
% The code was written with mexecNetCDF files in mind, so some standard
% NetCDF features are ignored. For example _FillValue is recognised on both
% input and output, but "missing_value" is not, and nor are scaling and
% offset, although these could easily be included in the relevant parts of
% the code. Handling of unlimited dimensions may fail in some places,
% because it has not been extensively tested. mexec netcdf does not use
% unlimited dimensions.
%
% When it started to be used for routine mecxec processing, it broke when
% reading a CODAS netcdf file. This is because it expected a _FillValue
% attribute, which did not exist. This glitch was fixed, but their could be
% others if reading non-mexec NetCDF files.
%
% SJones on DY120
% Removed alias files:
% nc_infoqatt.m (alias for nc_info)
% nc_infoqdim.m (alias for nc_info)
% nc_infoq.m    (alias for nc_info)
% nc_attputq.m (alias for nc_attput)
% and replaced with the functions they point to.  Somewhere in the Git process the links broke down and 
% were replaced with unreadable text.
%
%
% Files in this library, each of which has some help comments
%
% Contents.m
% nc_add_dimension.m
% nc_addvar.m
% nc_attget.m
% nc_attput.m
% nc_create_empty.m
% nc_getdiminfo.m
% nc_getvarinfo.m
% nc_global.m
% nc_info.m
% nc_padheader.m
% nc_varget.m
% nc_varput.m
% nc_varrename.m
