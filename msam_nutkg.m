%--------------------------------
% 2010-02-18 14:04:31
% mcalib2
% calling history, most recent first
%    mcalib2 in file: mcalib2.m line: 156
% input files
% Filename sam_di346_all.nc   Data Name :  sam_di346_all <version> 72 <site> di346_atsea
% output files
% Filename sam_di346_all.nc   Data Name :  sam_di346_all <version> 73 <site> di346_atsea
MEXEC_A.MARGS_IN = {
'sam_di346_all.nc'
'y'
'silc'
'silc uasal'
'y = x1./(gsw_rho_CT(x2,20,0)/1000);'
' '
'umol/kg'
'phos'
'phos uasal'
'y = x1./(gsw_rho_CT(x2,20,0)/1000);'
' '
'umol/kg'
'totnit'
'totnit upsal'
'y = x1./(gsw_rho_CT(x2,20,0)/1000);'
' '
'umol/kg'
'tn'
'tn upsal'
'y = x1./(sw_dens0(x2,20+0*x2)/1000)' %***
' '
'umol/kg'
'tp'
'tp upsal'
'y = x1./(sw_dens0(x2,20+0*x2)/1000)'
' '
'umol/kg'
'don'
'don upsal'
'y = x1./(sw_dens0(x2,20+0*x2)/1000)'
' '
'umol/kg'
'dop'
'dop upsal'
'y = x1./(sw_dens0(x2,20+0*x2)/1000)'
' '
'umol/kg'
' '
};
mcalib2
%--------------------------------