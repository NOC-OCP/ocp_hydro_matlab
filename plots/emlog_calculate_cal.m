% sequence to work out em log cal
% bak jc069 feb 2012


os = 150;
kbin = 2; % use this bin for comparison with em log
osstr = sprintf('%d',os);
binstr = sprintf('%d',kbin);

% find and load adcp data

root_vmadcp = mgetdir('vmadcp'); cd(root_vmadcp)
cmd=['cd ' MEXEC_G.MSCRIPT_CRUISE_STRING '_os' sprintf('%d',os)];eval(cmd);

vmfile = ['os' osstr '_' MEXEC_G.MSCRIPT_CRUISE_STRING 'nnx_01'];


[vd vh] = mload(vmfile,'/');
vd.dn = datenum(vh.data_time_origin) + vd.time/86400; % datenum

v.time = vd.dn(kbin,:); % should be 5 minute averages
v.uabs = vd.uabs(kbin,:); % cm/s
v.vabs = vd.vabs(kbin,:); % cm/s
v.uship = vd.uship(kbin,:); % m/s
v.vship = vd.vship(kbin,:); % m/s
v.shipspd = vd.shipspd(kbin,:); % m/s

v.urel =v.uship - v.uabs/100;
v.vrel =v.vship - v.vabs/100;

root_pos = mgetdir('M_POS');

bstfile = [root_pos '/bst_'  MEXEC_G.MSCRIPT_CRUISE_STRING '_01'];

[bd bh] = mload(bstfile,'/');
bd.dn = datenum(bh.data_time_origin) + bd.time/86400; % datenum

v.heading = interp1(bd.dn,bd.heading_av,v.time); % merge on one minute vector average heading; not quite right but doing it more thoroughly is hard work
v.frel = v.vrel.*cos(v.heading*pi/180) + v.urel.*sin(v.heading*pi/180); % forward relative speed

root_chf = mgetdir('M_CHF');

chfile = [root_chf '/chf_'  MEXEC_G.MSCRIPT_CRUISE_STRING '_01'];
chfileav = [root_chf '/chf_'  MEXEC_G.MSCRIPT_CRUISE_STRING '_01_av'];

%--------------------------------
% 2012-02-22 12:41:38
% mavrge
% calling history, most recent first
%    mavrge in file: mavrge.m line: 324
% input files
% Filename chf_jc069_01.nc   Data Name :  chf_jc069_01 <version> 25 <site> jc069_atsea
% output files
% Filename chf_jc069_01_av.nc   Data Name :  chf_jc069_01 <version> 26 <site> jc069_atsea
MEXEC_A.MARGS_IN = {
chfile
chfileav
'f'
'time'
'0 1e10 300'
'b'
};
mavrge
%--------------------------------


[ed eh] = mload(chfileav,'/');
ed.dn = datenum(eh.data_time_origin) + ed.time/86400; % datenum

kbad = find(ed.speedfa_bin_std > 0.5); % knots. discard data where speed is varying in the 5 minutes
ed.speedfa(kbad) = nan;


v.chfint = interp1(ed.dn,ed.speedfa,v.time)*1852/3600; % interp and convert to m/s

scl = 3600/1852;

figure

t_0 = datenum([2012 2 6 0 0 0]); % calibration period
t_1 = datenum([2012 2 23 18 51 00]);

% t_0 = datenum([2012 2 23 18 51 00]); after cal inserted in deck unit
% t_1 = 1e10;

% t_0 = 0;
% t_1 = datenum([2012 2 6 0 0 0]); % early part of cruise

kok = find(~isnan(v.chfint+v.frel) & (v.time-t_0 > 0) & (v.time - t_1 < 0)); % seemed ok first 5 days of cruise, then drifts towards reading 2 knots too high. temperature depndent ?

plot((v.chfint(kok)*scl),v.frel(kok)*scl,'b+')
axis square
axlims = [-2 18];
axis([axlims(1) axlims(2) axlims(1) axlims(2)])
xlabel('em log fa speed (knots)');
ylabel(['vm ' osstr ' bin ' binstr ' forward speed (knots)']);
grid on
hold on
plot([axlims(1) axlims(2)],[ axlims(1) axlims(2)],'k-');
title({['em log cal ' MEXEC_G.MSCRIPT_CRUISE_STRING]; 'start of cruise ; cal applied in post processing'})
% title({['em log cal ' MEXEC_G.MSCRIPT_CRUISE_STRING]; 'end of cruise no further cal applied'})
% title({['em log cal ' MEXEC_G.MSCRIPT_CRUISE_STRING]; 'up to end of 5 feb 2012 cal applied'})

%em log speed 0 to 6
ee1 = [-2 5.90];

kok = find(~isnan(v.chfint+v.frel) & (v.chfint*scl >= ee1(1)) & (v.chfint*scl <= ee1(2)) & (v.time-t_0 > 0) & (v.time - t_1 < 0)); % seemed ok first 5 days of cruise, then drifts towards reading 2 knots too high. temperature depndent ?
p1 = polyfit(v.chfint(kok)*scl,v.frel(kok)*scl,1);
vv1 = polyval(p1,ee1);

plot(ee1,vv1,'r-','linewidth',2)

%em log speed over 7
ee2 = [7.88 20];

kok = find(~isnan(v.chfint+v.frel) & (v.chfint*scl >= ee2(1)) & (v.chfint*scl <= ee2(2)) & (v.time-t_0 > 0) & (v.time - t_1 < 0));
p2 = polyfit(v.chfint(kok)*scl,v.frel(kok)*scl,1);
vv2 = polyval(p2,ee2);

plot(ee2,vv2,'r-','linewidth',2)

%em log speed 6 to 7 % join up the gap
ee3 = [ee1(2) ee2(1)];

p3 = polyfit([ee1(2) ee2(1)],[vv1(2) vv2(1)],1);
vv3 = polyval(p3,ee3);

plot(ee3,vv3,'r-','linewidth',2)

kok = find(~isnan(v.chfint+v.frel) & (v.time-t_0 > 0) & (v.time - t_1 < 0)); % seemed ok first 5 days of cruise, then drifts towards reading 2 knots too high. temperature depndent ?
ecal = emlog_cal_jc069(v.chfint*scl);
plot(ecal(kok),v.frel(kok)*scl,'k+');
m_nanmean(v.frel(kok)*scl-ecal(kok))
m_nanstd(v.frel(kok)*scl-ecal(kok))


ee4 = [ee1 ee2];
vv4 = [vv1 vv2];


