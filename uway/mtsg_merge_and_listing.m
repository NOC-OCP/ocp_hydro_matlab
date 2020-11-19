% bak jc191
% make TSG listing with fluor. trans, flow rate and merged on atmospheric
% pressure and position
% run in directory ocl/tsg

%--------------------------------
% 2020-02-13 03:46:23
% mmerge
% calling history, most recent first
%    mmerge in file: mmerge.m line: 440
% input files
% Filename tsg_jc191_01_medav_clean_cal.nc   Data Name :  tsg_jc191_01 <version> 100 <site> jc191_atsea
% Filename met_tsg_jc191_01.nc   Data Name :  met_tsg_jc191_01 <version> 27 <site> jc191_atsea
% output files
% Filename test.nc   Data Name :  tsg_jc191_01 <version> 101 <site> jc191_atsea
MEXEC_A.MARGS_IN = {
'tsg_psal_fluo_trans.nc'
'tsg_jc191_01_medav_clean_cal.nc'
'/'
'time'
'met_tsg_jc191_01.nc'
'time'
'/'
'k'
};
mmerge
%--------------------------------

MEXEC_A.MARGS_IN = {
'tsg_psal_fluo_trans_pres.nc'
'tsg_psal_fluo_trans.nc'
'/'
'time'
'../../met/surflight/met_light_jc191_01.nc'
'time'
'pres/'
'k'
};
mmerge

MEXEC_A.MARGS_IN = {
'tsg_psal_fluo_trans_pres_latlon.nc'
'tsg_psal_fluo_trans_pres.nc'
'/'
'time'
'../../nav/posmvpos/bst_jc191_01.nc'
'time'
'lat long/'
'k'
};
mmerge


%--------------------------------
% 2020-02-13 03:51:18
% mcalib2
% calling history, most recent first
%    mcalib2 in file: mcalib2.m line: 156
% input files
% Filename test.nc   Data Name :  tsg_jc191_01 <version> 102 <site> jc191_atsea
% output files
% Filename test.nc   Data Name :  tsg_jc191_01 <version> 103 <site> jc191_atsea
MEXEC_A.MARGS_IN = {
'tsg_psal_fluo_trans_pres_latlon.nc'
'y'
'fluo'
'fluo psal_cal'
'y = x1+x2-x2'
' '
' '
'trans'
'trans psal_cal'
'y = x1+x2-x2'
' '
' '
' '
};
mcalib2
%--------------------------------

[dt ht] = mload('tsg_psal_fluo_trans_pres_latlon.nc','/');

ncycles = length(dt.time);
dt.dnum = datenum(ht.data_time_origin) + dt.time/86400;
fid = fopen('jc191_tsg_listing.txt','w');

fprintf(fid,'%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s\n','yy','mm','dd','HH','MM','SS','sbe38_temp','flow','sbe45_temp','psal','fluo_volts','trans_volts','lat','lon','atm_pres');

for kl = 1:ncycles;
    dvec = datevec(dt.dnum(kl));
    fprintf(fid,'%d,%d,%d,%d,%d,%d,%7.3f,%7.3f,%7.3f,%7.3f,%8.5f,%8.4f,%10.5f,%10.5f,%8.2f\n',dvec,dt.temp_r(kl),dt.flow(kl),dt.temp_h(kl),dt.psal_cal(kl),dt.fluo(kl),dt.trans(kl),dt.lat(kl),dt.long(kl),dt.pres(kl));
end
    
fclose(fid);