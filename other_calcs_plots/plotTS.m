% plot of data with a time/date axis

clear all ; close all ;
m_setup;
statnum = input('type statnum number : ');
statnum = sprintf('%03d',statnum);

infile1 = ['/noc/users/pstar/di344/data/ctd/ctd_di344_',statnum,'_2db.nc'];
[d,h] = mload(infile1,'/');

load tsgrid_density.mat ;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Derived variables here
d.salin = sw_salt(d.cond/sw_c3515,d.temp,d.press);
d.potemp = sw_ptmp(d.salin,d.temp,d.press,0);



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% time axis if required
addpath('/noc/users/pstar/di344/data/MEXEC.mexec_processing_scripts/tools');
t_origin = datenum(h.data_time_origin); % matlab datenum of time origin
mat_datenum = t_origin + d.time/86400; % matlab datenums of data cycles; convert seconds to days

jd = (d.time)/86400; % time in doy since start of year
jd=jd-floor(jd(1)); % time in doy since start of day number of first data cycle

plot_interval2 = str2num([datestr(mat_datenum(1),'yyyy mm dd HH');
     datestr(mat_datenum(end),'yyyy mm dd HH')]);
 %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
 
figure(1)
vsigma0=24:.25:26;
[c h] = contour(density.salin,density.potemp,density.sigma0,vsigma0,'k-');
clabel(c,h);
vsigma0=24:.25:26;
[c h] = contour(density.salin,density.potemp,density.sigma2,vsigma0,'k-');
clabel(c,h);
hold on; 
plot(d.salin,d.potemp,'k.');
axis([34.5 37 0 30])
grid on;

title(infile1)


