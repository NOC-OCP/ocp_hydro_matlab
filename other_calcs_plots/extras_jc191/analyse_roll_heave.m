ship = 'jc';

switch ship
    case 'jc'
        stn = 10; stnstr = sprintf('%03d',stn);
    case 'dy'
        stn = 60; stnstr = sprintf('%03d',stn);
end


roll_rad = 11; % metres
filt_len = 11;
filt_b = ones(filt_len,1);

switch ship
    case 'jc'
        
        ctdroot = '/local/users/pstar/cruise/data/ctd/';
        attroot = '/local/users/pstar/cruise/data/nav/posmvatt/';
        fnin1 = [ctdroot 'ctd_jc191_' stnstr '_psal.nc'];
        fnin2 = [ctdroot 'dcs_jc191_' stnstr '.nc'];
        fnin3 = [attroot 'attposmv_jc191_01.nc'];
        fnin4 = [ctdroot '/WINCH/win_jc191_' stnstr '.nc'];
        
    case 'dy'
        
        ctdroot = '/data/pstar/dy040/backup_20160123160346/data/ctd/';
        attroot = '/data/pstar/dy040/backup_20160123160346/data/nav/attposmv/';
        fnin1 = [ctdroot 'ctd_dy040_' stnstr '_psal.nc'];
        fnin2 = [ctdroot 'dcs_dy040_' stnstr '.nc'];
        fnin3 = [attroot 'attposmv_dy040_01.nc'];
        
end

[dctd hctd] = mload(fnin1,'/');
torg_ctd = datenum(hctd.data_time_origin);
dctd.tim = torg_ctd + dctd.time/86400;

[dwin hwin] = mload(fnin4,'/');
torg_win = datenum(hwin.data_time_origin);
dwin.tim = torg_win + dwin.time/86400;

[ddcs hdcs] = mload(fnin2,'/');
torg_dcs = datenum(hdcs.data_time_origin);
ddcs.tims = torg_dcs + ddcs.time_start/86400;
ddcs.timb =pmvatt torg_dcs + ddcs.time_bot/86400;
ddcs.time = torg_dcs + ddcs.time_end/86400;

[datt hatt] = mload(fnin3,'/');
torg_att = datenum(hatt.data_time_origin);
datt.tim = torg_att + datt.time/86400;

kattuse = find(datt.tim > ddcs.tims & datt.tim < ddcs.time);

p = dctd.press;
psm = filter_bak(filt_b(:)',p(:)');
win = interp1(dwin.tim,dwin.cablout,dctd.tim);
panom1 = psm-p; % negative is package going down relative to where it should be;
panom2 = win-p; % negative is package going down relative to where it should be;


dp = panom1(3:end)-panom1(1:end-2);
dt = dctd.time(3:end) - dctd.time(1:end-2); %in seconds

panom_speed = dp./dt;
panom_time = dctd.tim(2:end-1);

% pmvatt = mtload('attposmv',ddcs.tims,ddcs.time);
% torg_techsas = datenum([1899 12 30]);
% pmvatt.tim = torg_techsas + pmvatt.time;
% 

% should find residualafter subtracting +/- heave and +/- roll

figure(100); clf
plot(1440*(dctd.tim-ddcs.timb)+1/60,-1*panom1,'k-'); hold on; grid on;
% plot(1440*(dctd.tim-ddcs.timb)+0/60,panom2,'b-'); hold on; grid on;
xlabel('minutes from bottom of cast');
ylabel('metres');

plot(1440*(panom_time-ddcs.timb)+1/60,3+panom_speed,'c-'); hold on; grid on;


roll_metres = -datt.roll(kattuse)*roll_rad/57; % 180/pi positive roll is the block going down; negative roll is block goes up. so +ve roll_metres = block goes up.

heave_metres = datt.heave(kattuse); % positive heave means ship goes up. p should be less than expected, panom should be positive.




% plot(1440*(pmvatt.tim-ddcs.timb),roll_metres,'r-'); hold on; grid on;
% plot(1440*(pmvatt.tim-ddcs.timb),heave_metres,'c-'); hold on; grid on;
plot(1440*(datt.tim(kattuse)-ddcs.timb), 1* heave_metres + 0*roll_metres,'m-'); hold on; grid on;
plot(1440*(datt.tim(kattuse)-ddcs.timb), 0* heave_metres + 1* roll_metres,'b-'); hold on; grid on;


switch ship
    
    case 'jc'
        
        titstr = {'CTD depth anom (k); heave+roll(m)';'jc191 station 10'};
        
    case 'dy'
        
        titstr = {'CTD depth anom (k); heave+roll(m)';'dy040 station 60'};
        
end

titstr = [titstr; {'cyan curve is depth anomaly speed in m/s around +3 that needs to be compensated'}];

title(titstr);


