function plot_surfmet_weekly

% HP dy

m_setup
m_common
m_margslocal
m_varargs
data_route = '/local/users/pstar/jc191/Jess';

surfmet_dir = '/met/surfmet'
surflight_dir = '/met/surflight'
cd([data_route surfmet_dir])
infile_humid = [data_route surfmet_dir '/' 'wind_' MEXEC_G.MSCRIPT_CRUISE_STRING '_.nc'];
infile_press = [data_route surflight_dir '/' 'surflight_' MEXEC_G.MSCRIPT_CRUISE_STRING '_edt.nc'];
infile_wind = [data_route surfmet_dir '/' 'wind_' MEXEC_G.MSCRIPT_CRUISE_STRING '_.nc']

% ------------------------------------
% load airtemp, humidity and wind data
% ------------------------------------
dmet = mload(infile_humid,'/',' ');
time_met = dmet.time;
humid = dmet.humid; 
airtemp = dmet.airtemp;
speed_shiprel = dmet.speed;
dir_shiprel = dmet.direct;

% -------------------------------------
% load calibrated, z-corrected pressure
% -------------------------------------
dpress = mload(infile_press,'/',' ');
time_press = dpress.time;
press = dpress.pres;
% ------------------------
% load corrected wind data
% ------------------------
dwind = mload(infile_wind,'/',' ');
time_wind = dwind.time_bin_average;
% direction
wind_reldir = dwind.wind_dir_onboard;
heading = dwind.heading_av_corrected;
wind_truedir = dwind.truewind_dir;
% speed
wind_relspeed = dwind.wind_speed_onboard_ms;
smg = dwind.smg;
wind_truespeed = dwind.truewind_speed;


% ---------------------------------------------
% plot the data for each week during the cruise
% ---------------------------------------------
interval = 7;
start_day = 6;
end_day = 46;
for week = 1:ceil((end_day-start_day)/7);

    ix = find((time_met > (start_day-1)*86400) & (time_met < (start_day -1 + 7)*86400));
    airtemp_7days = airtemp(ix);
    humid_7days = humid(ix);
    dir_shiprel_7days = dir_shiprel(ix);
    speed_shiprel_7days = speed_shiprel(ix);
    time_7days = time_met(ix).*1/86400;

    ip = find((time_press > (start_day-1)*86400) & (time_press < (start_day -1 + 7)*86400));
    press_7days = press(ip);
    time_press_7days = time_press(ip).*1/86400;
  
    iw = find((time_wind > (start_day-1)*86400) & (time_wind < (start_day -1 + 7)*86400));
    wind_reldir_7days = wind_reldir(iw);
    heading_7days = heading(iw);
    wind_truedir_7days = wind_truedir(iw);
    wind_relspeed_7days = wind_relspeed(iw);
    smg_7days = smg(iw);
    wind_truespeed_7days = wind_truespeed(iw);
    time_wind_7days = (time_wind(iw).*(1/86400));
    
% plot airtemp
figure(week+10)
plot(time_7days,airtemp_7days,'-b');

% plot pressure/10 and humidity
figure(week+20)
plot(time_7days,humid_7days,'-b');
hold on
plot(time_press_7days,(press_7days)/10,'-k');
set(gca,'YLim',[25 130])
xlabel('Julian Day');
legend('humidity (%)','pressure (db)');
hold off 

% plot wind direction
figure(week+30)
plot(time_wind_7days,wind_reldir_7days,'-k');
hold on
plot(time_wind_7days,heading_7days,'-g');
plot(time_wind_7days,wind_truedir_7days,'-r');
set(gca,'YLim',[0 360])
xlabel('Julian Day');
ylabel('degrees to')
legend('rel dir','heading','true dir');
hold off 

% plot wind speed
figure(week+40)
plot(time_wind_7days,wind_relspeed_7days,'-k');
hold on
plot(time_wind_7days,smg_7days,'-g');
plot(time_wind_7days,wind_truespeed_7days,'-r');
set(gca,'YLim',[0 30])
xlabel('Julian Day');
ylabel('speed (m/s)')
legend('rel speed','ship speed','true speed');
hold off 


clear *_7days ix ip iw

start_day = start_day + interval;

end
