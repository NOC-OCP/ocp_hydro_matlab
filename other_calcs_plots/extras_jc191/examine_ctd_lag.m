d = mload('ctd_jc191_060_psal.nc','/');
dd = mload('ctd_jc191_060_2db.nc','/');
du = mload('ctd_jc191_060_2up.nc','/');

pd = dd.press;
td = dd.time-min(dd.time);
s1d = dd.psal1;
t1d = dd.temp1;
s2d = dd.psal2;
t2d = dd.temp2;

pu = du.press;
tu = du.time-min(du.time);
s1u = du.psal1;
t1u = du.temp1;
s2u = du.psal2;
t2u = du.temp2;

f = ones(1,21);

t1d = filter_bak(f,t1d);
t2d = filter_bak(f,t2d);
t1u = filter_bak(f,t1u);
t2u = filter_bak(f,t2u);
s1d = filter_bak(f,s1d);
s2d = filter_bak(f,s2d);
s1u = filter_bak(f,s1u);
s2u = filter_bak(f,s2u);

c1d = sw_cndr(s1d,t1d,pd);
c2d = sw_cndr(s2d,t2d,pd);
c1u = sw_cndr(s1u,t1u,pu);
c2u = sw_cndr(s2u,t2u,pu);

tadj11d = 1*[0.27 -0.46]; tadj11d = tadj11d(1)/1e3 + pd*tadj11d(2)/1e6;
t1d = t1d+tadj11d;
tadj11u = 1*[0.27 -0.46]; tadj11u = tadj11u(1)/1e3 + pu*tadj11u(2)/1e6;
t1u = t1u+tadj11u;


fac1d = 1+interp1([-10 0 2000 4000 8000],1*[0 0 0 -1 -1]/1e3,pd)/35;
fac1u = 1+interp1([-10 0 2000 4000 8000],1*[0 0 0 -1 -1]/1e3,pu)/35;
fac2d = 1+interp1([-10 0 2000 6000 7000],1*[3 3 3 1.3 1.3]/1e3,pd)/35;
fac2u = 1+interp1([-10 0 2000 6000 7000],1*[3 3 3 1.3 1.3]/1e3,pu)/35;

s1d = sw_salt(c1d.*fac1d,t1d,pd);
s2d = sw_salt(c2d.*fac2d,t2d,pd);
s1u = sw_salt(c1u.*fac1u,t1u,pu);
s2u = sw_salt(c2u.*fac2u,t2u,pu);



dt = 11; % width of filter;
dth = (dt-1)/2;
f = [-1*ones(1,dth) 0 1*ones(1,dth)];

dtd = filter_bak_nonorm(f,td);
dpd = filter_bak_nonorm(f,pd);
dt1d = filter_bak_nonorm(f,t1d);
dt2d = filter_bak_nonorm(f,t2d);
ds1d = filter_bak_nonorm(f,s1d);
ds2d = filter_bak_nonorm(f,s2d);

dt1ddp = dt1d./dpd;
dt2ddp = dt2d./dpd;
ds1ddp = ds1d./dpd;
ds2ddp = ds2d./dpd;

dt1ddt = dt1d./dtd;
dt2ddt = dt2d./dtd;
ds1ddt = ds1d./dtd;
ds2ddt = ds2d./dtd;

dtu = filter_bak_nonorm(f,tu);
dpu = filter_bak_nonorm(f,pu);
dt1u = filter_bak_nonorm(f,t1u);
dt2u = filter_bak_nonorm(f,t2u);
ds1u = filter_bak_nonorm(f,s1u);
ds2u = filter_bak_nonorm(f,s2u);

dt1udp = dt1u./dpu;
dt2udp = dt2u./dpu;
ds1udp = ds1u./dpu;
ds2udp = ds2u./dpu;

dt1udt = dt1u./dtu;
dt2udt = dt2u./dtu;
ds1udt = ds1u./dtu;
ds2udt = ds2u./dtu;

s1dx = sw_salt(c1d.*fac1d,t1d + 0.1*dt1ddp,pd);
t1dx = t1d + 0.1*dt1ddp;


figure(100); clf

plot(t2d-t1d,-pd,'k-'); hold on; grid on;
plot(t2u-(t1u-3*dt1udp),-pu,'b-'); hold on; grid on;
plot(t2d-t1dx,-pu,'m-'); hold on; grid on;
h = gca;
set(h,'xlim',[-.1 .1]);
set(h,'ylim',[-6500 10]');
plot(-3*dt1udp,-pu,'c-');
title('t2-t1; k down b up;')

figure(101); clf

plot(s2d-s1d,-pd,'k-'); hold on; grid on;
plot(s2d-s1dx,-pd,'m-'); hold on; grid on;
plot(s2u-(s1u-3*ds1udp),-pu,'b-'); hold on; grid on;
h = gca;
set(h,'xlim',[-.02 .02]);
set(h,'ylim',[-6500 10]');
plot(-3*ds1udp,-pu,'c');
title('s2-s1; k down b up;')

figure(102); clf
plot(t1u,-pu,'b'); hold on; grid on;

figure(103); clf
plot(s1u,-pu,'b'); hold on; grid on;

figure(104)
plot((t2u-t1u)./dt1udp,-pu,'k'); hold on; grid on;
plot((s2u-s1u)./ds1udp,-pu,'m'); hold on; grid on;


