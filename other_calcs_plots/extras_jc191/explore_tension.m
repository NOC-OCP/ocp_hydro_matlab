% d = mtload('winch',[2020 02 13 17 00 00],[2020 02 13 22 00 00]); % stn 91
% d = mtload('winch',[2020 02 14 00 00 00],[2020 02 14 05 00 00]); % stn 92
d = mtload('winch',[2020 02 16 20 00 00],[2020 02 17 01 00 00]); % stn 101



ti = d.time;
c = d.cablout;
t = d.tension;
r = d.rate;
flt = ones(1,21);

rs = filter_bak(flt,r);
ts = filter_bak(flt,t);
cs = filter_bak(flt,c);

[csmax kmax] = max(cs);
tmax = ti(kmax);

figure(101); clf
plot(c,t,'k-'); hold on; grid on;

kdown = find(cs > 2000 & cs < 4000 & ti < tmax);

plot(cs(kdown),ts(kdown),'r-');

coef_co = polyfit(cs(kdown),ts(kdown),1);

ts_per_metre = coef_co(1);  % 0.348 tonnes per 1000 cablout

c1 = [0 6500];
t1 = polyval(coef_co,c1);
plot(c1,t1,'m-','linewidth',2);

ts_adj_cablout = ts - cs*ts_per_metre;

figure(102); clf

plot(ts_adj_cablout,rs,'k-'); hold on; grid on;

% drag appears to be 0.15 T for rate of 60

ts_adj_cablout_rate = ts_adj_cablout - 0.12*rs/60;

tpred = 0.6 + 0.328 * cs/1000 - 0.15*rs/60;

figure(101)

plot(cs,tpred,'c');

figure(104); clf
plot(ti,ts-tpred,'k-'); hold on; grid on;


figure(103); clf

plot(ti,ts,'k-'); hold on; grid on
plot(ti,0.5+0.348*cs/1000,'r-');











