root = '/local/users/pstar/jc191/mcruise/data/ctd/';

% stn = 41;
% close all
% t21pall = nan(75,2);
% ts1pall = nan(75,2);
% ts2pall = nan(75,2);

stnstr = sprintf('%03d',stn);

fnctd2db = [root 'ctd_jc191_' stnstr '_2db.nc'];
fnctd2up = [root 'ctd_jc191_' stnstr '_2up.nc'];
fnctd1hz = [root 'ctd_jc191_' stnstr '_psal.nc'];
fnsam = [root 'sam_jc191_' stnstr '.nc'];
fndcs = [root 'dcs_jc191_' stnstr '.nc'];

[dctd2db hctd2db] = mload(fnctd2db,'/');
[dctd2up hctd2up] = mload(fnctd2up,'/');
[dctd1hz hctd1hz] = mload(fnctd1hz,'/');
[dsam hsam] = mload(fnsam,'/');
[ddcs hdcs] = mload(fndcs,'/');

dctd2db.dnum = datenum(hctd2db.data_time_origin) + dctd2db.time/86400;
dctd2up.dnum = datenum(hctd2up.data_time_origin) + dctd2up.time/86400;
dctd1hz.dnum = datenum(hctd1hz.data_time_origin) + dctd1hz.time/86400;
dsam.dnum = datenum(hsam.data_time_origin) + dsam.time/86400;
ddcs.dnums = datenum(hdcs.data_time_origin) + ddcs.time_start/86400;
ddcs.dnumb = datenum(hdcs.data_time_origin) + ddcs.time_bot/86400;
ddcs.dnume = datenum(hdcs.data_time_origin) + ddcs.time_end/86400;

t11adj = [0.27 -0.46]./[1e3 1e6];
t21adj = [2.89 -0.24]./[1e3 1e6];
t22adj = [0 0]./[1e3 1e6];

t1adj = t11adj;
if stn <= 34
    t2adj = t21adj;
else
    t2adj = t22adj;
end

d = dctd1hz;
d.temp1 = d.temp1 + t1adj(1) + t1adj(2)*d.press;
d.temp2 = d.temp2 + t2adj(1) + t2adj(2)*d.press;
dctd1hz = d;

d = dctd2db;
d.temp1 = d.temp1 + t1adj(1) + t1adj(2)*d.press;
d.temp2 = d.temp2 + t2adj(1) + t2adj(2)*d.press;
dctd2db = d;

d = dctd2up;
d.temp1 = d.temp1 + t1adj(1) + t1adj(2)*d.press;
d.temp2 = d.temp2 + t2adj(1) + t2adj(2)*d.press;
dctd2up = d;

d = dsam;
d.utemp1 = d.utemp1 + t1adj(1) + t1adj(2)*d.upress;
d.utemp2 = d.utemp2 + t2adj(1) + t2adj(2)*d.upress;
dsam = d;


nlev = 24;
samptime = 20; % second

sbe35temp = nan(nlev,1);
temp1 = nan(nlev,1);
temp2 = nan(nlev,1);

for kl = 1:nlev
    sbe35temp(kl) = dsam.sbe35temp(kl);
    bot_dnum = dsam.dnum(kl);
    kctd = find(dctd1hz.dnum >= bot_dnum & dctd1hz.dnum <= (bot_dnum+samptime/86400));
    temp1(kl) = nanmean(dctd1hz.temp1(kctd));
    temp2(kl) = nanmean(dctd1hz.temp2(kctd));
end

figure(100)
plot(sbe35temp-temp1,-dsam.upress,'k+'); hold on; grid on;
title('SBE35 - temp1');
figure(101)
plot(sbe35temp-temp2,-dsam.upress,'k+'); hold on; grid on;
title('SBE35 - temp2');
figure(102)
plot(temp2-temp1,-dsam.upress,'k+'); hold on; grid on;
title('temp2 - temp1');


figure(103)
plot(dctd1hz.temp1,-dctd1hz.press,'k+-');
hold on; grid on
plot(dctd1hz.temp2,-dctd1hz.press,'r+-');
plot(temp1,-dsam.upress,'m*');
plot(temp2,-dsam.upress,'c*');
plot(temp1,-dsam.upress,'mo');
plot(temp2,-dsam.upress,'co');
plot(sbe35temp,-dsam.upress,'bo');

kseld = find(dctd1hz.dnum >= ddcs.dnums & dctd1hz.dnum <= ddcs.dnumb);
kselu = find(dctd1hz.dnum >= ddcs.dnumb & dctd1hz.dnum <= ddcs.dnume);

filt = [-1 -2 -3 -2 -1 0 1 2 3 2 1];
f2 = [1 1 1 1 1];
temp1_filt = filter_bak_nonorm(filt,dctd2db.temp1);
temp2_filt = filter_bak_nonorm(filt,dctd2db.temp2);
psal1_filt = filter_bak_nonorm(filt,dctd2db.psal1);
psal2_filt = filter_bak_nonorm(filt,dctd2db.psal2);
press_filt = filter_bak_nonorm(filt,dctd2db.press);
tgrad = temp2_filt./press_filt;
sgrad = psal2_filt./press_filt;

figure(104)
plot(filter_bak(f2,dctd2db.temp2-dctd2db.temp1),-dctd2db.press,'k.');
hold on; grid on
plot(filter_bak(f2,dctd2up.temp2-dctd2up.temp1),-dctd2up.press,'r.');
hold on; grid on
title('temp2 - temp1; k down r up');

ksel = find(dctd2db.press >= 2000 & dctd2db.press <= 4000 & ~isnan(dctd2db.temp1+dctd2db.temp2));
t21p = polyfit(dctd2db.press(ksel),(dctd2db.temp2(ksel)-dctd2db.temp1(ksel)),1);
t21f = polyval(t21p,dctd2db.press);
t21pall(stn,:) = t21p;
plot(t21f,-dctd2db.press,'m-','linewidth',2);


plot(filter_bak(f2,-4*tgrad(6:end-5)),-dctd2db.press(6:end-5),'c.','linewidth',2);
plot(filter_bak(f2,0.3*tgrad(6:end-5)),-dctd2db.press(6:end-5),'m.','linewidth',2);

figure(105)
plot(dctd2db.psal2-dctd2db.psal1,-dctd2db.press,'k.');
hold on; grid on
plot(dctd2up.psal2-dctd2up.psal1,-dctd2up.press,'r.');
hold on; grid on
title('psal2 - psal1; k down r up');
plot(filter_bak(f2,-4*sgrad(6:end-5)),-dctd2db.press(6:end-5),'c.','linewidth',2);
plot(filter_bak(f2,0.3*sgrad(6:end-5)),-dctd2db.press(6:end-5),'m.','linewidth',2);


dsamall = mload('sam_jc191_all.nc','/');
d = dsamall;
ksel = find(d.upress >= 3000 & d.upress <= 6000 & ~isnan(d.utemp1+d.utemp2+d.sbe35temp));
ts1p = polyfit(d.upress(ksel),(d.sbe35temp(ksel)-d.utemp1(ksel)),1);
ts1f = polyval(ts1p,d.upress);
ts2p = polyfit(d.upress(ksel),(d.sbe35temp(ksel)-d.utemp2(ksel)),1);
ts2f = polyval(ts2p,d.upress);
ts1pall(stn,:) = ts1p;
ts2pall(stn,:) = ts2p;

ts1p = [2 -3/6]./[1e3 1e6]; ts1p = fliplr(ts1p);
ts2p = [2 -3/6]./[1e3 1e6]; ts2p = fliplr(ts2p);
ts1f = polyval(ts1p,d.upress);
ts2f = polyval(ts2p,d.upress);

figure(100)
plot(ts1f,-d.upress,'m-','linewidth',2);
figure(101)
plot(ts2f,-d.upress,'m-','linewidth',2);









