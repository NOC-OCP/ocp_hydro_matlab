function eta(varargin)
% function eta
% bak on di346
% can have zero, one or two args
% args are target number and averaging interval in seconds for speed
% calculation.
% Default target is next most east target
% default ave interval is 300 seconds
% 
% di368 15 jul 2011 BAK.
% three possible arguments
% target number
% averaging interval
% time origin. SO you can see what eta would have said at a certain time.
% eg
% eta 10 3600 now-1
% eta 12 1200 datenum([2011 7 24 2 20 0])
%
% di368 extra option
%
% use target zero with averaging interval to automatically select next
% target but define averaging interval, eg
% eta 0 3600
%
% so default (to ensure there is nav data even if the workstation clock is
% a minute fast) is 
%
% eta 0 300 now-1/1440

m_setup

targets = [
    1 52 00.00 -49 24.00 % jr302
    2 53 11.69 -50 37.63
    3 52 37.12 -52 03.35
    4 52 00.00 -55 42.00
%     1  -53 18.90  -57 51.24 % jr281 test
%     2 -54 40.00 -58 00.00
%     3 -54 55.34 -58 00.00
%     4 -54 58.67 -58 00.00
%     5 -55 00.39 -58 00.00
%     6 -55 04.20 -58 00.00 % 80
%     7 -55 07.26 -58 00.00 % 81
%     8 -55 10.16 -58 00.00 % 82
%     9 -55 12.86 -58 00.00 % 82
%     10 -55 31.00 -58 00.00 % 83
%     11 -55 50.00 -57 49.20 % 84
%     12 -56 09.00 -57 37.45 % 85
%     13 -56 28.00 -57 25.67 % 86
%     14 -56 47.00 -57 13.90 % 87
%  80   -55   4.800    -57 56% sr1 positions
%  81   -55   8.400    -57 56
%  82   -55  12.600    -57 56
%  83   -55  31.152    -57 56
%  84   -55  50.478    -57  48.528
%  85   -56   9.264    -57  36.270
%  86   -56  28.032    -57  25.494
%  87   -56  46.938    -57  13.734
%  88   -57   5.676    -57   2.064
%  89   -57  24.942    -56  50.388
%  91   -57  44.010    -56  38.418
%  92   -58   3.030    -56  26.760
%  93   -58  21.618    -56  13.764
%   94   -58  31.344    -56   8.535
];
fprintf(1,'%3d %4d %4.1f %4d %4.1f\n',targets');
targets_lat = targets(:,2) + sign(targets(:,2)).*targets(:,3)/60;
targets_lon = targets(:,4) + sign(targets(:,4)).*targets(:,5)/60;

if nargin == 3
    cmd = ['tzero =  ' varargin{3} ';']; eval(cmd);
else
    tzero = now-1/1440;
end


[latnow lonnow] = msposinfo(tzero);
[latdnow latmnow] = m_degmin_from_decdeg(latnow);
[londnow lonmnow] = m_degmin_from_decdeg(lonnow);
targets_east = find(targets_lon>lonnow);
targets_south = find(targets_lat<latnow);

%eastbound section
% next_target = targets(min(targets_east),1);
% fprintf(1,'%s %d\n','next_target east of present position is ',next_target)
%southbound section
next_target = targets(min(targets_south),1);
fprintf(1,'%s %d\n','next_target south of present position is ',next_target)

m = ['Present position is      ',sprintf('%4.0f %5.2f',latdnow,latmnow), sprintf(' %5.0f %5.2f',londnow,lonmnow)];
fprintf(1,'%s\n',m);

if nargin >= 1;
    tnum = str2num(varargin{1});
    if tnum < 1
        tnum = next_target;
    end
else
    %     tnum = input('Choose target number ');
    tnum = next_target;
end
fprintf(1,'%s %d\n','Using target ',tnum);

krow = find(targets(:,1) == tnum);
target_lat = targets(krow,2) + sign(targets(krow,2)).*targets(krow,3)/60;
target_lon = targets(krow,4) + sign(targets(krow,4)).*targets(krow,5)/60;

m = ['Using target number  ' sprintf('%3d',tnum)  ' ' sprintf('%4d %5.2f',targets(krow,2),targets(krow,3))  '  ' sprintf('%4d %5.2f',targets(krow,4),targets(krow,5))  ' '];
fprintf(1,'%s\n',m);

% if now > datenum([2010 1  1 0 0 0]); t_local_offset_h = -5; end % start of cruise; put clock changes here
% if now > datenum([2010 1 16 05 0 0]); t_local_offset_h = -4; end % clocks advance 1 hour at end of day 15; display new time after 0500 UTC on day 16 (midnight old ship's time)
% if now > datenum([2010 1 22 04 0 0]); t_local_offset_h = -3; end % clocks advance 1 hour at end of day 21; display new time after 0400 UTC on day 22 (midnight old ship's time)
% if now > datenum([2010 1 31 03 0 0]); t_local_offset_h = -2; end % clocks advance 1 hour at end of day 30; display new time after 0300 UTC on day 31 (midnight old ship's time)
% if now > datenum([2010 2  7 26 0 0]); t_local_offset_h = -1; end % clocks advance 1 hour at end of day 38; display new time after 0200 UTC on day 39 (midnight old ship's time)
% if now > datenum([2010 2 14 25 0 0]); t_local_offset_h =  0; end % clocks advance 1 hour at end of day 45; display new time after 0100 UTC on day 46 (midnight old ship's time)
% if now > datenum([2011 7 14 01 0 0]); t_local_offset_h =  1; end % clocks advance 1 hour at end of day 45; display new time after 0100 UTC on day 46 (midnight old ship's time)
% if now > datenum([2011 7 16 24 1 0]); t_local_offset_h =  0; end % clocks retard 1 hour at 1am day 198; display new time after 0100 UTC on day 198 (1 am old ship's time)
% if now > datenum([2011 8 3 0 0 0]); t_local_offset_h =  1; end % clocks retard 1 hour at 1am day 198; display new time after 0100 UTC on day 198 (1 am old ship's time)
if now > datenum([2011 8 30 0 0 0]); t_local_offset_h =  1; end % BST Falmouth
if now > datenum([2012 1 30 0 0 0]); t_local_offset_h =  -2; end % start jc069 montevideo
if now > datenum([2012 2 22 0 0 0]); t_local_offset_h =  -3; end % jc069 change clocks in stanley
if now > datenum([2013 3 17 0 0 0]); t_local_offset_h =  -3; end % jr281 start in stanley
if now > datenum([2014 5 00 0 0 0]); t_local_offset_h =  -2.5; end % jr302 start in st johns
if now > datenum([2014 6 08 2 30 0]); t_local_offset_h =  -2; end % jr302 first clock change
t_local_offset_d = t_local_offset_h/24; % days

if nargin == 2
    delt = str2num(varargin{2}); % allow second argin to be time in seconds.
else
    delt = 300; % seconds for speed averaging interval
end

tnow = tzero;
datestr(tnow,31);
[lat1 lon1] = msposinfo_noup(tnow-30/86400); % update not needed because has already been updated to tnow
[lat2 lon2] = msposinfo_noup(tnow-(delt+30)/86400);

dist = sw_dist([lat1 lat2],[lon1 lon2],'km');
speed = dist*1000/delt; % speed in m/s
speed = max(speed,0.001); % bak on jr302 while in port. Force nonzero speed

del_lat = [lat1 target_lat];
del_lon = [lon1 target_lon];
[dist angle] = sw_dist_original(del_lat,del_lon,'km');
dist_togo = 1000*sw_dist(del_lat,del_lon,'km');


time_togo = dist_togo/speed; % seconds
time_arr = tnow+time_togo/86400;

s1 = datestr(time_arr,31);
s2 = datestr(time_arr + t_local_offset_d,31);
mm_togo = floor(time_togo/60);

hh_togo1 = floor(mm_togo/60);
mm_togo1 = mm_togo-60*hh_togo1;

dd_togo2 = floor(hh_togo1/24);
hh_togo2 = hh_togo1-24*dd_togo2;
mm_togo2 = mm_togo1;

m1 = ['Estimated arrival time UTC:      ' s1];
m2 = ['Estimated arrival time UTC' sprintf('%+5.1f',t_local_offset_h) ': ' s2];
m3 = ['Time to go:                     ' sprintf('%5d',mm_togo) ' minutes'];
m4 = ['Time to go:           ' sprintf('%5d',hh_togo1) ' hours  ' sprintf('%2d',mm_togo1) ' minutes'];
m5 = ['Time to go: ' sprintf('%5d',dd_togo2) ' days   ' sprintf('%2d',hh_togo2) ' hours  ' sprintf('%2d',mm_togo2) ' minutes'];
m6 = ['Distance to target:    ' sprintf('%6.1f',dist_togo/1852) ' nm'];
m7 = ['Average speed:         ' sprintf('%6.1f',speed*3600/1852) ' knots'];
m8 = ['Bearing to target:       ' sprintf(' %03.0f',mcrange(90-angle,0,360)) ' degrees'];

fprintf(1,'%s\n',' ',m3);
fprintf(1,'%s\n',m4);
fprintf(1,'%s\n',m5);
fprintf(1,'%s\n',' ',m6);
fprintf(1,'%s\n',m8);
fprintf(1,'%s\n',m7);
fprintf(1,'%s\n',' ',m1);
fprintf(1,'%s\n',' ',m2);

% fprintf(1,'\n%s\n%s\n%s\n%s\n','If you require a different target number, use ','>> eta number', 'eg', '>> eta 28');
fprintf(1,'\n%s\n%s\n','If you require a different target number, use ','>> eta number');

