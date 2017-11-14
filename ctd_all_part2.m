scriptname = 'ctd_all_part2';

if ~exist('stn','var')
    stn = input('type stn number ');
end
stn_string = sprintf('%03d',stn);

stnlocal = stn;

clear stn % so that it doesn't persist

stn = stnlocal; mctd_04;

stn = stnlocal; mfir_01;
stn = stnlocal; mfir_02;
stn = stnlocal; mfir_03;
stn = stnlocal; mfir_04;

stn = stnlocal; mwin_01;
stn = stnlocal; mwin_03;
stn = stnlocal; mwin_04;

stn = stnlocal; mbot_00; % bak on jr302: insert default niskin bottle numbers and firing flags
