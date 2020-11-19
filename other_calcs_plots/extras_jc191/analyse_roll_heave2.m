stn = 75; stnstr = sprintf('%03d',stn);
roll_rad = 11; % metres
filt_len = 11;
filt_b = ones(filt_len,1);

fnin1 = ['ctd_jc191_' stnstr '_psal.nc'];
fnin2 = ['dcs_jc191_' stnstr '.nc'];


[dctd hctd] = mload(fnin1,'/');
torg_ctd = datenum(hctd.data_time_origin);
dctd.tim = torg_ctd + dctd.time/86400;

[ddcs hdcs] = mload(fnin2,'/');
torg_dcs = datenum(hdcs.data_time_origin);
ddcs.tims = torg_dcs + ddcs.time_start/86400;
ddcs.timb = torg_dcs + ddcs.time_bot/86400;
ddcs.time = torg_dcs + ddcs.time_end/86400;

p = dctd.press;
psm = filter_bak(filt_b(:)',p(:)');
panom = psm-p; % negative is package going down relative to where it should be;


pmvatt = mtload('attposmv',ddcs.tims,ddcs.time);
torg_techsas = datenum([1899 12 30]);
pmvatt.tim = torg_techsas + pmvatt.time;




figure(100); clf
plot(1440*(dctd.tim-ddcs.timb)+0/60,panom,'k-'); hold on; grid on;
xlabel('minutes from bottom of cast');
ylabel('metres');

roll_metres = -pmvatt.roll*roll_rad/57; % 180/pi positive roll isstb block going down

heave_metres = pmvatt.heave;

% plot(1440*(pmvatt.tim-ddcs.timb),roll_metres,'r-'); hold on; grid on;
% plot(1440*(pmvatt.tim-ddcs.timb),heave_metres,'c-'); hold on; grid on;
plot(1440*(pmvatt.tim-ddcs.timb),-heave_metres+roll_metres,'m-'); hold on; grid on;
legend('CTD pressure','ship roll & heave')
title(['Station ' num2str(stn)])
% plot(1440*(pmvatt.tim-ddcs.timb),heave_metres-roll_metres,'b-'); hold on; grid on;

figure
subplot()



