%script to convert to mstar time (seconds relative to mstar origin)

mstar_torg = datenum(h.mstar_time_origin);
data_torg = datenum(h.data_time_origin);

tdif = data_torg - mstar_torg;

t = d.time;
mt = t+tdif; % decimal days relative to mstar origin

t = mt+mstar_torg; % decimal days in matlab
t = t-180+366 - (32417)/86400;
form = 'yymmdd HHMMSS';

for k = 1:10
fprintf(MEXEC_A.Mfidterm,'%s\n',datestr(t(k),form))
end

dv = datevec(t);
yy = dv(:,1);
ymd = dv(:,1:3);
z3 = 0*ymd;
z1 = 0*yy+1;
year_org = [yy z1 z1 z3];
dayofyear = datenum([ymd z3]) - datenum(year_org)+1;

secondsofyear = 86400*(t - datenum(year_org));

% matlab double precision counts decimal days near year 2000 to better than 1e-5 seconds


