root_tsg = mgetdir('M_TSG');

[dt ht] =  mload(root_tsg '/tsg_jc069_01','/');
dt.cond = dt.cond*10;
dt.mysal = sw_salt(dt.cond/sw_c3515,dt.temp_h,0);

difs = dt.mysal-dt.salin;
dift = dt.temp_h-dt.temp_r;

close all
figure
plot(dt.time,difs)
figure
plot(dt.time,dift)

root_mettsg = mgetdir('M_MET_TSG');

[dm hm] = mload(root_mettsg '/met_tsg_jc069_01','/');
dm.cond = dm.cond*10;
dm.mysal = sw_salt(dm.cond/sw_c3515,dm.temp_h,0);

dift = dm.temp_h-dm.temp_m;

figure
plot(dm.time,dift)

dt.mth = interp1(dm.time,dm.temp_h,dt.time);
dt.mtm = interp1(dm.time,dm.temp_m,dt.time);
dt.mc = interp1(dm.time,dm.cond,dt.time);
dt.ms = interp1(dm.time-1,dm.mysal,dt.time);

tmdiff_th = dt.temp_h - dt.mth;
tmdiff_tm = dt.temp_r - dt.mtm;
tmdiff_c = dt.cond - dt.mc;
tmdiff_s = dt.mysal - dt.ms;

figure
plot(dt.time,tmdiff_th);
figure
plot(dt.time,tmdiff_tm);
figure
plot(dt.time,tmdiff_c);
figure
plot(dt.time,tmdiff_s);

figure
plot(dt.time,dt.temp_h,'+-');
hold on; grid on;
plot(dm.time,dm.temp_h,'r+-');
