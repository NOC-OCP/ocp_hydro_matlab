function [tstart tend] = mtimerange(fn)

% quick and dirty on jr302


[d h] = mload(fn,'time',' ');

torg = datenum(h.data_time_origin);

tstart = torg+d.time(1)/86400;
dnumstart = floor(tstart) - datenum([h.data_time_origin(1) 1 1 0 0 0]) + 1;
tend = torg+d.time(end)/86400;
dnumend = floor(tend) - datenum([h.data_time_origin(1) 1 1 0 0 0]) + 1;

fprintf(1,'%5s %s %s %03d\n','start',datestr(tstart,31),'day',dnumstart);
fprintf(1,'%5s %s %s %03d\n','end  ',datestr(tend,31),'day',dnumend);



