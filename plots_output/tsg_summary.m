root_tsg = mgetdir('M_MET_TSG');
root_tsgall = mgetdir('M_CTD');

%--------------------------------
% 2011-08-02 13:42:05
% mmerge
% calling history, most recent first
%    mmerge in file: mmerge.m line: 402
% input files
% Filename ../../ctd/tsg_di368_all.nc   Data Name :  tsg_di368_all <version> 3 <site> di368_atsea
% Filename met_tsg_di368_psal.nc   Data Name :  met_tsg_di368_01 <version> 72 <site> di368_atsea
% output files
% Filename tsg_di368_merged.nc   Data Name :  tsg_di368_all <version> 7 <site> di368_atsea
MEXEC_A.MARGS_IN = {
[root_tsg '/tsg_di368_merged.nc']
[root_tsgall '/tsg_di368_all.nc']
'time salinity_adj/'
'time'
'met_tsg_di368_psal.nc'
'time'
'temp_h cond condcal psal'
'k'
};
mmerge
%--------------------------------
%--------------------------------
% 2011-08-02 13:46:07
% mcalc
% calling history, most recent first
%    mcalc in file: mcalc.m line: 228
% input files
% Filename tsg_di368_merged.nc   Data Name :  tsg_di368_all <version> 7 <site> di368_atsea
% output files
% Filename tsg_di368_merged2.nc   Data Name :  tsg_di368_all <version> 8 <site> di368_atsea
MEXEC_A.MARGS_IN = {
[root_tsg '/tsg_di368_merged.nc']
[root_tsg '/tsg_di368_merged2.nc']
'/'
'salinity_adj temp_h'
'y = sw_c3515*sw_cndr(x1,x2,0);'
'botcond'
'mS/cm'
' '
};
mcalc
%--------------------------------

d = mload([root_tsg '/tsg_di368_merged2'],'/')
cr = d.botcond./(d.condcal) - 1;
kgood = find((cr)<2e-4 & cr>-4e-4)
p = polyfit(d.time(kgood),cr(kgood),1)
y = polyval(p,d.time)
cd = d.botcond./((d.cond*10)-1);

%polyfit((d.time(kgood)-195*86400)/86400,cr(kgood),1)
%p = ans
figure
plot(d.time/86400,y,'k')
hold on
plot(d.time/86400,cr,'+k')
grid on
title('di368 TSG bottle conductivity ratio')
xlabel('decimal day (noon on 1 Jan 2011 = 0.5)')
ylabel('bottle : TSG -1')
ylim([-0.0007 0.0007])
%print -dpsc tsgratio.ps

figure
plot(d.time/86400,d.salinity_adj-d.psal,'+k')
title('di368 TSG bottle salinity residuals')
xlabel('decimal day (noon on 1 Jan 2011 = 0.5)')
ylabel('bottle minus TSG')
ylim([-0.035 0.035])
grid on

%print -dpsc tsgsal.ps



