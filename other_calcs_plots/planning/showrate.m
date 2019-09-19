fnwin = 'WINCH/win_jc159_013.nc';
fnctd = 'ctd_jc159_013_psal.nc';

datt = mtload('attposmv');
torg = datenum([1899 12 30 0 0 0]);
datt.t = torg+datt.time;

dsea = mtload('attsea');
dsea.t = torg+dsea.time;

x = mtload('winch');
x.t = torg+x.time;

[dwin hwin] = mload(fnwin,'/');
[dctd hctd] = mload(fnctd,'/');

dwin.t = datenum(hwin.data_time_origin)+dwin.time/86400;
dctd.t = datenum(hctd.data_time_origin)+dctd.time/86400;

kok = find(datt.t > dctd.t(1) & datt.t < dctd.t(end));
koks = find(dsea.t > dctd.t(1) & dsea.t < dctd.t(end));
kokx = find(x.t > dctd.t(1) & x.t < dctd.t(end));
x.r = x.rate(kokx);
x.t = x.t(kokx);

filtw = [-1 0  1];
dctd.dp = filter_bak_nonorm(filtw,dctd.press);
dctd.dt = 1440*filter_bak_nonorm(filtw,dctd.t);
dctd.rate = dctd.dp./dctd.dt;

datt.roll = datt.roll(kok);
datt.t = datt.t(kok);
datt.heave = datt.heave(kok);
dsea.roll = dsea.roll(kok);
dsea.t = dsea.t(kok);

datt.dp = 15*filter_bak_nonorm(filtw,datt.roll)*3.14/180;
datt.dt = 1440*filter_bak_nonorm(filtw,datt.t);
datt.dh = filter_bak_nonorm(filtw,datt.heave);
datt.rate = datt.dp./datt.dt;
datt.hrate = datt.dh./datt.dt;
dsea.dp = 15*filter_bak_nonorm(filtw,dsea.roll)*3.14/180;
dsea.dt = 1440*filter_bak_nonorm(filtw,dsea.t);
dsea.rate = dsea.dp./dsea.dt;

torg = min(dctd.t);

dwin.t1 = (dwin.t-torg)*1440;
dctd.t1 = (dctd.t-torg)*1440+.5/60;
datt.t1 = (datt.t-torg)*1440;
dsea.t1 = (dsea.t-torg)*1440;
x.t1 = (x.t-torg)*1440;

dctd.winrate = interp1(dwin.t1,dwin.rate,dctd.t1);
dctd.shiprate = interp1(datt.t1,datt.hrate+datt.rate,dctd.t1);

dctd.delrate = dctd.rate-dctd.winrate;
dctd.resid = dctd.delrate-dctd.shiprate;

fprintf(1,'%20s %10.1f \n','iqr ctd',iqr(dctd.delrate));
fprintf(1,'%20s %10.1f \n','iqr resid',iqr(dctd.resid));


figure(101)
clf
plot(datt.t1,datt.hrate+datt.rate,'b-','linewidth',2);
hold on; grid on;
% plot(datt.t1,datt.rate,'c-','linewidth',2);
plot(dctd.t1,dctd.delrate,'r-','linewidth',2);
% plot(dctd.t1,dctd.resid,'m-','linewidth',2);
plot(dwin.t1,dwin.rate,'k-','linewidth',2);
% plot(datt.t1,datt.hrate,'m-','linewidth',2);

% plot(datt.t1,.5*datt.roll,'m','linewidth',2);
% plot(x.t1,x.r,'g');




