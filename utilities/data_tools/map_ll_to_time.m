function tim = map_ll_to_time(lon, lat, lonr, latr, timr, tim0)
% tim = map_ll_to_time(lon, lat, lonr, latr, timr, tim0)
% 
% use a time series of longitude and latitude, (lonr(timr), latr(timr)), 
% to estimate times, starting closely after tim0 and increasing
% (regularly?), when series (lon, lat) was measured 
% 

%***add optional timstep? 

m = timr>=tim0;
timr = timr(m);
lonr = lonr(m);
latr = latr(m);


keyboard