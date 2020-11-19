stnstr = sprintf('%03d',stn);

fnin = ['ctd_jc191_' stnstr '_psal.nc'];

[d h] = mload(fnin,'/');

torg = datenum(h.data_time_origin);
d.dnum = torg+d.time/86400;


figure(100); clf
plot((1440*(d.dnum-torg)),-d.depth,'k-');
hold on; grid on;
plot((1440*(d.dnum-torg)),-d.depth-d.altimeter,'r-');
plot((1440*(d.dnum-torg)),-d.depth-d.altimeter,'b.');

% [dw hw] = mload('WINCH/win_jc191_091','/');
% 
% dw.dnum = datenum(hw.data_time_origin) + dw.time/86400;
% 
% plot((1440*(dw.dnum-torg)),-4660-100*dw.tension,'m-');
