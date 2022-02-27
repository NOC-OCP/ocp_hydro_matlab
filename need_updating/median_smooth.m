function smooth = median_smooth(var,time_today,day,n)

% ========================================================================%
% Wind speed and direction relative to the ship are measured by the 
% anemometer. Calculation of the true wind speed and direction requires
% the ship's speed and course (made good). 
%
% This function smooths the ship's speed and course using an n minute
% median despiking.
%
% The function is called by mtruewind_met.m and requires the last n/2
% minutes of data from day-1 and the first n/2 minutes of data from day+1
%
% usage: median_smooth(variable,time,day#,smoothing interval in mins) 
%   e.g  median_smooth(gndcourse,time,7,30) 
%        takes 1Hz gndcourse data from day 7 and smoothes it
%        using a 30 minute median despiking
%
% Last updated: HP 12/01/10 for Di346
% ========================================================================%
m_setup
m_common
m_margslocal
m_varargs

cruise = 'di346';
data_route = '/noc/users/pstar/di346/data';
daystr_yesterday = sprintf('%03d',day-1);
daystr_tomorrow = sprintf('%03d',day+1);

% -----------------------------------------------------------
% Load final n/2 minutes of var data from file for day-1
% -----------------------------------------------------------
if var == 'gndcourse';
 fname = 'pos';
 ext = '_edt.nc';   
elseif var == 'gndspeed';
    fname = 'pos';
    ext = '_edt.nc';
else disp('Invalid variable chosen. Select gndspeed or gndcourse') 
end

ncfile_yesterday.name = [fname '_' cruise '_d' daystr_yesterday ext];
[d1 h1] = mload([ncfileT_yesterday.name],[var],' ');
var_yesterday = eval(['d1.' [var]]);                             % full airtemp record from yesterday
[dt1 ht1] = mload([ncfile_yesterday.name],'time',' ');         
time_yesterday = eval(['dt1.' 'time']);                          % full time record from yesterday
ix = find(time_yesterday >= (((day-1)*60*60*24) - ((n/2)*60)));  
var_end_yesterday = var_yesterday(ix);                           % extract final n/2 minutes of airtemp data from yesterday
time_end_yesterday = time_yesterday(ix);                         % extract final n/2 minutes of time data from yesterday
clear ix

% -------------------------------------------------------
% Load first n/2 minutes of var data from file day+1
% -------------------------------------------------------
ncfile_tomorrow.name = [fname '_' cruise '_d' daystr_tomorrow ext];
[d2 h2] = mload([ncfileT_tomorrow.name],[var],' ');
var_tomorrow = eval(['d2.' [var]]);
[dt2 ht2] = mload([ncfile_tomorrow.name],'time',' ');
time_tomorrow = eval(['dt2.' 'time']);
ix = find(time_tomorrow <= (((day*60*60*24) + ((n/2)*60))));           
var_begin_tomorrow = var_tomorrow(ix);                               % extract first n/2 minutes of airtemp data from tomorrow
time_begin_tomorrow = time_tomorrow(ix);                         % extract first n/2 minutes of time data from tomorrow
clear ix

% -------------------------------------------------------
% Gather var and time data from day-1, day and day+1
% -------------------------------------------------------
for k = 1:size(var_end_yesterday,2)
var_extended(1,k) = var_end_yesterday(1,k);
time_extended(1,k) = time_end_yesterday(1,k);
end
for k = 1 : size(var_today,2)
var_extended(size(var_end_yesterday,2) + k) = var_today(1,k);
time_extended(size(var_end_yesterday,2) + k) = time_today(1,k);
end
for k = 1: size(var_begin_tomorrow,2)
var_extended(size(var_end_yesterday,2) + size(var_today,2) + k) = var_begin_tomorrow(1,k);
time_extended(size(var_end_yesterday,2) + size(var_today,2) + k) = time_begin_tomorrow(1,k);
end

% ------------------
% Check by plotting
% ------------------
figure(2)
subplot(2,1,1)
plot(time_today,var_today,'r'); hold on; 
plot(time_end_yesterday,var_end_yesterday,'g');
plot(time_begin_tomorrow,var_begin_tomorrow,'b');
title(['day = ',num2str(day)]);
ylabel(['variable = ',var]);xlabel('time since 2010-00-00');hold off
subplot(2,1,2)
plot(time_extended,var_extended,'k')
ylabel(['variable = ',var]);xlabel('time since 2010-00-00');

% ------------------------------------------------------------------------
% Compute median for data chunks spanning n minutes and assign this median 
% for airtemp to the midpoint of the group
% ------------------------------------------------------------------------
for k = 1:size(time_today,2)
 startpoint = find(time_extended == time_today(1,k));   % point being replaced with smoothed value
 start_time = time_extended(startpoint);
 ix = find((time_extended >= (start_time - (n*60)/2)) &...
                             (time_extended < (start_time + (n*60)/2))); 
 var_group = var_extended(ix);            % gather all airtemps n/2 minutes either side of the point being smoothed
 var_smoothed(k) = m_nanmedian(var_group);  % compute the median of this n minute group
 clear ix var_group
end

% ------------------
% Check by plotting
% ------------------
figure(3)
plot(time_today,var_today,'g')
hold on
plot(time_today,var_smoothed,'r')
ylabel(['variable = ',var]);xlabel('time since 2010-00-00');
title([var,'for day = ',num2str(day),' with ',num2str(n),' min median smoothing']);
legend('raw data','smoothed data',4); 
hold off

[smooth.var_smoothed] = var_smoothed;