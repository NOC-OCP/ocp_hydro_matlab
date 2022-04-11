% use matlab fn nlinfit to least squares fit sin curves of 12 & 24hr period
% to atmospheric air pressure measured during D334
% scu, Nov 16, 2009

clear all;close all
m_setup

% hourly averaged data
[d h] = mload('/noc/users/pstar/cruise/data/met/surflight/met_light_di344_cal_01_av.nc','/');
t = ((d.time - d.time(1))/3600)'; % time in seconds to hours
press = (d.press-nanmean(d.press))';

%%%%%%%%%%%%%%%%%%%%%%%%%%%%
t_origin = datenum(h.data_time_origin); % matlab datenum of time origin
mat_datenum = t_origin + d.time/86400; % matlab datenums of data cycles; convert seconds to days
jd = (d.time-d.time(1))/86400;
plot_interval2 = str2num([datestr(mat_datenum(1),'yyyy mm dd HH');
datestr(mat_datenum(end),'yyyy mm dd HH')]);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%
addpath('/noc/users/pstar/di344/data/MEXEC.mexec_processing_scripts/tools');

sampling_rate = 24/median(diff(t));
innanpf           = find(~isnan(press));             
pf                    = auto_filt(press(innanpf), sampling_rate, 1/2,'low',4); % 2 day low-pass
p = press - pf; % remove 2-day low-pass signal to leave diurnal cycle

%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% fun = inline('b(1) * sin((2*pi()/12)*t + b(2))','b','t'); % fitting 12 hours
% fun = inline('b(1) * sin((2*pi()/24)*t + b(2))','b','t'); % fitting 24 hours
fun = inline('b(1) * sin((2*pi()/12)*t + b(2)) + b(3) * sin((2*pi()/24)*t + b(4))','b','t'); % 12 & 24 hrs
dc1 = 1 ; dc2 = length(t) ;
b0 = [1 -1.02 0.06 -1.4091]; % initial guess : 12hr amp 1, phase -1.02 rad; 24hr amp 0.06, ph -1.4
beyta = nlinfit(t(dc1:dc2),p(dc1:dc2),fun,b0);

disp(['12hr (amp phase) : ',num2str(beyta(1)),' ',num2str(beyta(2)*(180./pi()))])
disp(['24hr (amp phase) : ',num2str(beyta(3)),' ',num2str(beyta(4)*(180./pi()))])
%%%%%%%%%%%%%%%%%%%%%%%%%%%%


% plot of 2-day low-pass air pressure
figure(1)
plot(jd(dc1:dc2),nanmean(d.press)+pf(dc1:dc2),'r')
grid on ; hold on ;
plot(jd(dc1:dc2),d.press(dc1:dc2),'k')
title('2-day low pass air-pressure data from D344')
xlabel('time (hrs)')
ylabel('air pressure (mb)')
% legend('air pressure','Location','SouthWest')
xlim([0 jd(end)-jd(1)])
timeaxis(plot_interval2(1,1:3)); 

figure(2)
plot(t(dc1:dc2),p(dc1:dc2),'k')
hold on ; grid on; 
% a = beyta(1)*sin((2*pi()/12)*t(dc1:dc2)+beyta(2) );
% a = beyta(1)*sin((2*pi()/24)*t(dc1:dc2)+beyta(2) );
a = beyta(1)*sin((2*pi()/12)*t(dc1:dc2)+beyta(2)) +  beyta(3)*sin((2*pi()/12)*t(dc1:dc2)+beyta(4));
plot(t(dc1:dc2),a(dc1:dc2),'r')
title('12 & 24 hr cycle fitted to 2-day low pass air-pressure data from D344')
xlabel('time (hrs)')
ylabel('air pressure anomaly (mb)')
legend('air pressure','fit','Location','SouthWest')


