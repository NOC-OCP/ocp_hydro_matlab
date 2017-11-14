%--------------------------------
% 2013-04-03 16:15:59
% mcalc
% calling history, most recent first
%    mcalc in file: mcalc.m line: 228
% input files
% Filename grid_jr281_orkney.nc   Data Name :  ctd_jr281_orkney <version> 16 <site> jr281_atsea
% output files
% Filename grid_jr281_orkney_rats.nc   Data Name :  ctd_jr281_orkney <version> 17 <site> jr281_atsea
MARGS_IN = {
'grid_jr281_orkney.nc'
'grid_jr281_orkney_rats.nc'
'/'
'sf6 cfc12'
'y = x1./x2;'
'sf6_12_ratio'
'ratio'
'sf6 cfc13'
'y = x1./x2;'
'sf6_13_ratio'
'ratio'
'cfc12 cfc13'
'y = x1./x2;'
'cfc12_13_ratio'
'ratio'
' '
};
mcalc
%--------------------------------