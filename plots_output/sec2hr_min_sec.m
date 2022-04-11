function timeconvert = sec2hr_min_sec(seconds)
% -----------------------------------------------------------------------%
% function converts seconds since 00:00:00 UTC at the beginning of the
% year to day# + hours minutes seconds
%
% (primarily for facilitating comparison 
% of the echo sounder paper chart with the plotted logged data since
% plotting commands have no option to reformat time into hhmmss on x-axis)
%
% Last updated: HP 12/01/10 for di346
%
% probably already exists in the toolbox
% -----------------------------------------------------------------------%

m_setup
m_common
m_margslocal
m_varargs

for k  = 1:size(seconds,2)

days = floor(seconds(1,k)./86400);

hours = floor(abs(seconds(1,k) - days*86400)./3600);

secs_remaining = abs(seconds(1,k)) - (hours*3600 + days*86400);

mins = floor(secs_remaining./60);

secs = floor(seconds(1,k) - (mins*60) - (hours*3600) - (days*86400));

time = [sprintf('%02d',hours) ':' sprintf('%02d',mins) ':'...
                              sprintf('%02d',secs)]

disp(['day = ',num2str(days)]); disp(['time = ',time,' UTC'])

timestamp{k} = time;

end

[timeconvert.timestamp] = timestamp;

