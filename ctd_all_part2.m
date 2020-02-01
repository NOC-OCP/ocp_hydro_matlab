minit

stn = stnlocal; mctd_04;

stn = stnlocal; mfir_01;
stn = stnlocal; mfir_02;
stn = stnlocal; mfir_03;
stn = stnlocal; mfir_04;

stn = stnlocal; mwin_01;
stn = stnlocal; mwin_03;
stn = stnlocal; mwin_04;

stn = stnlocal; mbot_00; % bak on jr302: insert default niskin bottle numbers and firing flags
stn = stnlocal; mbot_01; % mbot_00 only writes to csv file; mbot_01 writes to bot*.nc file
stn = stnlocal; mbot_02; % mbot_02 writes to sam file

d = mload([MEXEC_G.MEXEC_DATA_ROOT '/ctd/sam_' mcruise '_all.nc'], 'statnum', ' ');
if sum(d.statnum==stnlocal)==0
    stn = stnlocal; msam_apend
else
    stn = stnlocal; msam_updateall
end
