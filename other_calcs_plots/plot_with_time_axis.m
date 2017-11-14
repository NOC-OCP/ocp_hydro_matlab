% plot of data with a time/date axis

clear all; close all;

infile1 = ['/noc/users/pstar/di344/data/ctd/ctd_di344_015_1hz.nc'];
[d,h] = mload(infile1,'/');

addpath('/noc/users/pstar/di344/data/MEXEC.mexec_processing_scripts/tools');

t_origin = datenum(h.data_time_origin); % matlab datenum of time origin
mat_datenum = t_origin + d.time/86400; % matlab datenums of data cycles; convert seconds to days

jd = (d.time)/86400; % time in doy since start of year
jd=jd-floor(jd(1)); % time in doy since start of day number of first data cycle

plot_interval2 = str2num([datestr(mat_datenum(1),'yyyy mm dd HH');
     datestr(mat_datenum(end),'yyyy mm dd HH')]);
 
figure(1)
plot(jd,d.press,'k')
grid on ;
xlim([jd(1) jd(end)])
timeaxis(plot_interval2(1,1:3)); 

title(infile1)


