% CPA 11/01/10 Load and plot processed CTD data to check quality.
% Also plots previous station data.

% CPA 17/01/10 modified to remove start and end of cast data from psal
% files before plotting.  

stn = input('type stn number ');
np = input('type number of previous stations to view ');

if np>=stn;
    disp('number of previous stations to view must be less than station number')
    return
end

stn_string = sprintf('%03d',stn);

prefix1 = ['ctd_' MEXEC_G.MSCRIPT_CRUISE_STRING '_'];
prefix2 = ['dcs_' MEXEC_G.MSCRIPT_CRUISE_STRING '_'];
infile1 = [prefix1 stn_string '_2db.nc'];
infile2 = [prefix1 stn_string '_psal.nc'];
infile3 = [prefix2 stn_string '.nc'];

% load data needed for TS plot and figure 3 %

density_fn = [MEXEC.mexec_processing_scripts '/tsgrid_density.mat'];
load(density_fn);

f3handle = [MEXEC.mexec_processing_scripts '/Handlef3.mat'];
load(f3handle)

mcd('M_CTD'); % change working directory

% load data

[d2db h2db]=mload(infile1,'/',' ');
[dpsal hpsal]=mload(infile2,'/',' ');
[ddcs hdcs]=mload(infile3,'/',' ');


% load previous station data if requested

if np ~=0;

stns = (stn-np:stn-1);

for i=1:np
stns_string = sprintf('%03d',stns(i));
file=[prefix1 stns_string '_psal.nc'];
file2db=[prefix1 stns_string '_2db.nc'];
filedcs=[prefix2 stns_string '.nc'];

if exist(file,'file')
    eval(['[dpsal' num2str(i) ' hpsal' num2str(i) ']=mload(file,''/'','' '')'])
end

if exist(file2db,'file')
    eval(['[d2db' num2str(i) ' h2db' num2str(i) ']=mload(file2db,''/'','' '')'])
end

if exist(filedcs,'file')
    eval(['[ddcs' num2str(i) ' hdcs' num2str(i) ']=mload(filedcs,''/'','' '')'])
end

end

end

clear stn % so that it doesn't persist

%%% remove start and end of cast from psal file data

ind_st_gd=find(dpsal.scan==ddcs.scan_start+0.5);
ind_en_gd=find(dpsal.scan==ddcs.scan_end+0.5);

% list all variables in psal file
%allvars={'scan','time','press','pressure_temp','temp','cond','temp1','cond1','temp2','cond2','altimeter','oxygen','fluor','transmittance','depth','psal','psal1','psal2','potemp','potemp1','potemp2'};
allvars={'scan','time','press','pressure_temp','temp','cond','temp1','cond1','temp2','cond2','altimeter','oxygen','depth','psal','psal1','psal2','potemp','potemp1','potemp2'};

for i=1:length(allvars);
eval(['dpsal.' allvars{i} '=dpsal.' allvars{i} '(ind_st_gd:ind_en_gd)']);
end

ind_mid=find(dpsal.scan==ddcs.scan_bot+0.5);

if np~=0;
    
for i=1:np;
    
eval(['ind_st_gd' num2str(i) '=find(dpsal' num2str(i) '.scan==ddcs' num2str(i) '.scan_start+0.5)']);
eval(['ind_en_gd' num2str(i) '=find(dpsal' num2str(i) '.scan==ddcs' num2str(i) '.scan_end+0.5)']);

for j=1:length(allvars);
eval(['dpsal' num2str(i) '.' allvars{j} '=dpsal' num2str(i) '.' allvars{j} '(ind_st_gd' num2str(i) ':ind_en_gd' num2str(i) ')']);
end

end

for i=1:np;

eval(['ind_mid' num2str(i) '=find(dpsal' num2str(i) '.scan==ddcs' num2str(i) '.scan_bot+0.5)']);

end

end

% calculate density

d2db.dens0=sw_pden(d2db.psal,d2db.temp,d2db.press,0);

dpsal.dens0=sw_pden(dpsal.psal1,dpsal.temp1,dpsal.press,0);
dpsal.dens02=sw_pden(dpsal.psal2,dpsal.temp2,dpsal.press,0);

%%%% plot data %%%%

% 2dbar gridded data %

figure(1)

subplot(221)

vsigma0=20:1:30;
[c h] = contour(density.salin,density.potemp,density.sigma0,vsigma0,'k-');
clabel(c,h)
hold on 
plot(d2db.psal,d2db.potemp,'b','linewidth',1)
xlim([min(d2db.psal)-0.2 max(d2db.psal)+0.2])
ylim([min(d2db.potemp)-1 max(d2db.potemp)+1])
xlabel('Salinity')
ylabel('Potential Temperature')
grid on;
title('2dbar PT-S First Choice')

subplot(222)

[AX,H1,H2]=plotyy(d2db.depth,d2db.temp,d2db.depth,d2db.psal);
set(H1,'linewidth',1)
set(H2,'linewidth',1)
ylabel(AX(1),'Temperature')
xlabel(AX(1),'Depth (m)')
ylabel(AX(2),'Salinity')
grid(AX(1),'on')
grid(AX(2),'on')
set(AX(1),'ylim',[min(d2db.temp)-1 max(d2db.temp)+1])
set(AX(2),'ylim',[min(d2db.psal)-0.2 max(d2db.psal)+0.2])
title('2dbar T and S First Choice')

subplot(223)

plot(d2db.depth,d2db.dens0,'b','linewidth',1);
ylabel('Density (sig0, Kg/m3)')
xlabel('Depth (m)')
grid on
ylim([min(d2db.dens0)-0.1 max(d2db.dens0)+0.1])
title('2dbar Density First Choice')

dlim=get(gca,'ylim');

subplot(224)

plot(d2db.depth,d2db.oxygen,'b','linewidth',1);
ylabel('Oxygen (umol/kg)')
xlabel('Depth (m)')
grid on
ylim([min(d2db.oxygen)-10 max(d2db.oxygen)+10])
title('2dbar Oxygen')

olim=get(gca,'ylim');

%%%%%%

tlim=get(AX(1),'ylim'); % save limits for psal plots and figure 3
slim=get(AX(2),'ylim');
xlims=get(AX(1),'xlim');

%%%%%

% 1hz psal data %

figure(2)

subplot(221)

plot(dpsal.depth(1:ind_mid),dpsal.temp1(1:ind_mid),'b','linewidth',1);
hold on
plot(dpsal.depth(ind_mid+1:end),dpsal.temp1(ind_mid+1:end),'b--','linewidth',1);
plot(dpsal.depth(1:ind_mid),dpsal.temp2(1:ind_mid),'k','linewidth',1);
plot(dpsal.depth(ind_mid+1:end),dpsal.temp2(ind_mid+1:end),'k--','linewidth',1);
%ylim(tlim)
ylim([min([dpsal.temp1 dpsal.temp2])-1 max([dpsal.temp1 dpsal.temp2])+1])
xlim(xlims)
ylabel('Temperature')
xlabel('Depth (m)')
grid on
title('psal (1hz) T, downcast and upcast, black=secondary, dash=upcast')

subplot(222)

plot(dpsal.depth(1:ind_mid),dpsal.psal1(1:ind_mid),'b','linewidth',1);
hold on
plot(dpsal.depth(ind_mid+1:end),dpsal.psal1(ind_mid+1:end),'b--','linewidth',1);
plot(dpsal.depth(1:ind_mid),dpsal.psal2(1:ind_mid),'k','linewidth',1);
plot(dpsal.depth(ind_mid+1:end),dpsal.psal2(ind_mid+1:end),'k--','linewidth',1);
%ylim(slim)
ylim([min([dpsal.psal1 dpsal.psal2])-0.2 max([dpsal.psal1 dpsal.psal2])+0.2])
xlim(xlims)
ylabel('Salinity')
xlabel('Depth (m)')
grid on
title('psal (1hz) S, downcast and upcast, black=secondary, dash=upcast')

subplot(223)

plot(dpsal.depth(1:ind_mid),dpsal.dens0(1:ind_mid),'b','linewidth',1);
hold on
plot(dpsal.depth(ind_mid+1:end),dpsal.dens0(ind_mid+1:end),'b--','linewidth',1);
plot(dpsal.depth(1:ind_mid),dpsal.dens02(1:ind_mid),'k','linewidth',1);
plot(dpsal.depth(ind_mid+1:end),dpsal.dens02(ind_mid+1:end),'k--','linewidth',1);
%ylim(dlim)
ylim([min([dpsal.dens0 dpsal.dens02])-0.1 max([dpsal.dens0 dpsal.dens02])+0.1])
xlim(xlims)
ylabel('Density (sig0, Kg/m3)')
xlabel('Depth (m)')
grid on
title('psal (1hz) Density, downcast and upcast, black=secondary, dash=upcast')

subplot(224)

plot(dpsal.depth(1:ind_mid),dpsal.oxygen(1:ind_mid),'b','linewidth',1);
hold on
plot(dpsal.depth(ind_mid+1:end),dpsal.oxygen(ind_mid+1:end),'b--','linewidth',1);
ylim(olim)
xlim(xlims)
ylabel('Oxygen (umol/kg)')
xlabel('Depth (m)')
grid on
title('psal (1hz) Oxygen, downcast and upcast, dash=upcast')

%%%%

%figure(3); % plot using mplotxy

%load('Handlef3.mat','Hf3') % moved to top of script
presslim=[0 max(dpsal.press)+10];

Hf3=rmfield(Hf3,'xax');
Hf3.yax([1,4])=presslim;
Hf3.yax([2,5])=slim;
Hf3.yax([3,6])=tlim;

mplotxy(Hf3,infile2)

%%%%

if np~=0;

lin_col=zeros(np,3);
lin_col(:,1)=(0:1/(np-1):1);
lin_col(:,3)=(1:-1/(np-1):0);
lin_col=cat(1,lin_col,[0 1 0]);

figure(4) % T-S plot of previous stations (primary sensors)

vsigma0=20:1:30;
[c h] = contour(density.salin,density.potemp,density.sigma0,vsigma0,'k-');
clabel(c,h)
hold on 
sltemp=min(d2db.psal1);
shtemp=max(d2db.psal1);
ptltemp=min(d2db.potemp1);
pthtemp=max(d2db.potemp1);

for i=1:np
    nns=num2str(i);
    nns2=num2str(i+1);
    eval(['plot(d2db' nns '.psal1,d2db' nns '.potemp1,''color'',lin_col(i,:),''linewidth'',1)'])
    eval(['sltemp(' nns2 ')=min(d2db' nns '.psal1);'])
    eval(['shtemp(' nns2 ')=max(d2db' nns '.psal1);'])
    eval(['ptltemp(' nns2 ')=min(d2db' nns '.potemp1);'])
    eval(['pthtemp(' nns2 ')=max(d2db' nns '.potemp1);'])
end

plot(d2db.psal1,d2db.potemp1,'color',lin_col(end,:),'linewidth',2)
xlim([min(sltemp)-0.2 max(shtemp)+0.2])
ylim([min(ptltemp)-1 max(pthtemp)+1])
xlabel('Salinity')
ylabel('Potential Temperature')
grid on;
eval(['title(''2dbar PT-S primary, stations ' num2str(stns(1)) '-' num2str(stns(end)) ' blue-red, station ' num2str(stns(end)+1) '=green'')'])


figure(5) % plot previous stations and upcast-downcast data (primary sensors)

% Get depth limits %

xhtemp=max(d2db.depth);

for i=1:np
    nns=num2str(i);
    nns2=num2str(i+1);
    eval(['xhtemp(' nns2 ')=max(d2db' nns '.depth);'])
end

x2lims=[0 max(xhtemp)+50];

subplot(221)

hold on 
for i=1:np
    nns=num2str(i);
    eval(['plot(dpsal' nns '.depth(1:ind_mid' num2str(i) '),dpsal' nns '.temp1(1:ind_mid' num2str(i) '),''color'',lin_col(i,:),''linewidth'',1)'])
    eval(['plot(dpsal' nns '.depth(ind_mid' num2str(i) '+1:end),dpsal' nns '.temp1(ind_mid' num2str(i) '+1:end),''color'',lin_col(i,:),''linewidth'',1,''linestyle'',''--'')'])
end
plot(dpsal.depth(1:ind_mid),dpsal.temp1(1:ind_mid),'color',lin_col(end,:),'linewidth',1)
plot(dpsal.depth(ind_mid+1:end),dpsal.temp1(ind_mid+1:end),'color',lin_col(end,:),'linewidth',1,'linestyle','--')
ylim([min(ptltemp)-1 max(pthtemp)+1])
xlim(x2lims)
xlabel('Depth (m)')
ylabel('Temperature')
grid on;
eval(['title(''psal T (primary), stations ' num2str(stns(1)) '-' num2str(stns(end)) ' blue-red, station ' num2str(stns(end)+1) '=green, dash=upcast'')'])

subplot(222)

hold on
for i=1:np
    nns=num2str(i);
    eval(['plot(dpsal' nns '.depth(1:ind_mid' num2str(i) '),dpsal' nns '.psal1(1:ind_mid' num2str(i) '),''color'',lin_col(i,:),''linewidth'',1)'])
    eval(['plot(dpsal' nns '.depth(ind_mid' num2str(i) '+1:end),dpsal' nns '.psal1(ind_mid' num2str(i) '+1:end),''color'',lin_col(i,:),''linewidth'',1,''linestyle'',''--'')'])
end
plot(dpsal.depth(1:ind_mid),dpsal.psal1(1:ind_mid),'color',lin_col(end,:),'linewidth',1)
plot(dpsal.depth(ind_mid+1:end),dpsal.psal1(ind_mid+1:end),'color',lin_col(end,:),'linewidth',1,'linestyle','--')
ylim([min(sltemp)-0.2 max(shtemp)+0.2])
xlim(x2lims)
xlabel('Depth (m)')
ylabel('Salinity')
grid on;
eval(['title(''psal S (primary), stations ' num2str(stns(1)) '-' num2str(stns(end)) ' blue-red, station ' num2str(stns(end)+1) '=green, dash=upcast'')'])

% Get oxygen limits %

oltemp=min(d2db.oxygen);
ohtemp=max(d2db.oxygen);

for i=1:np
    nns=num2str(i);
    nns2=num2str(i+1);
    eval(['oltemp(' nns2 ')=min(d2db' nns '.oxygen);'])
    eval(['ohtemp(' nns2 ')=max(d2db' nns '.oxygen);'])
end

subplot(223)

hold on 
for i=1:np
    nns=num2str(i);
    eval(['plot(dpsal' nns '.depth(1:ind_mid' num2str(i) '),dpsal' nns '.oxygen(1:ind_mid' num2str(i) '),''color'',lin_col(i,:),''linewidth'',1)'])
    eval(['plot(dpsal' nns '.depth(ind_mid' num2str(i) '+1:end),dpsal' nns '.oxygen(ind_mid' num2str(i) '+1:end),''color'',lin_col(i,:),''linewidth'',1,''linestyle'',''--'')'])
end
plot(dpsal.depth(1:ind_mid),dpsal.oxygen(1:ind_mid),'color',lin_col(end,:),'linewidth',1)
plot(dpsal.depth(ind_mid+1:end),dpsal.oxygen(ind_mid+1:end),'color',lin_col(end,:),'linewidth',1,'linestyle','--')
ylim([min(oltemp)-20 max(ohtemp)+20])
xlim(x2lims)
xlabel('Depth (m)')
ylabel('Oxygen (umol/kg)')
grid on;
eval(['title(''psal Oxygen, stations ' num2str(stns(1)) '-' num2str(stns(end)) ' blue-red, station ' num2str(stns(end)+1) '=green, dash=upcast'')'])

subplot(224) % TS plot of psal Pot T - S data

vsigma0=20:1:30;
[c h] = contour(density.salin,density.potemp,density.sigma0,vsigma0,'k-');
clabel(c,h)
hold on 

for i=1:np
    nns=num2str(i);
    eval(['plot(dpsal' nns '.psal1(1:ind_mid' num2str(i) '),dpsal' nns '.potemp1(1:ind_mid' num2str(i) '),''color'',lin_col(i,:),''linewidth'',1)'])
    eval(['plot(dpsal' nns '.psal1(ind_mid' num2str(i) '+1:end),dpsal' nns '.potemp1(ind_mid' num2str(i) '+1:end),''color'',lin_col(i,:),''linewidth'',1,''linestyle'',''--'')'])
end
plot(dpsal.psal1(1:ind_mid),dpsal.potemp1(1:ind_mid),'color',lin_col(end,:),'linewidth',1)
plot(dpsal.psal1(ind_mid+1:end),dpsal.potemp1(ind_mid+1:end),'color',lin_col(end,:),'linewidth',1,'linestyle','--')
xlim([min(sltemp)-0.2 max(shtemp)+0.2])
ylim([min(ptltemp)-1 max(pthtemp)+1])
xlabel('Salinity')
ylabel('Potential Temperature')
grid on;
eval(['title(''psal (1Hz) PT-S (primary), stations ' num2str(stns(1)) '-' num2str(stns(end)) ' blue-red, station ' num2str(stns(end)+1) '=green, dash=upcast'')'])

end

if np~=0;

figure(6) % T-S plot of previous stations

vsigma0=20:1:30;
[c h] = contour(density.salin,density.potemp,density.sigma0,vsigma0,'k-');
clabel(c,h)
hold on 
sltemp2=min(d2db.psal2);
shtemp2=max(d2db.psal2);
ptltemp2=min(d2db.potemp2);
pthtemp2=max(d2db.potemp2);

for i=1:np
    nns=num2str(i);
    nns2=num2str(i+1);
    eval(['plot(d2db' nns '.psal2,d2db' nns '.potemp2,''color'',lin_col(i,:),''linewidth'',1)'])
    eval(['sltemp2(' nns2 ')=min(d2db' nns '.psal2);'])
    eval(['shtemp2(' nns2 ')=max(d2db' nns '.psal2);'])
    eval(['ptltemp2(' nns2 ')=min(d2db' nns '.potemp2);'])
    eval(['pthtemp2(' nns2 ')=max(d2db' nns '.potemp2);'])
end

plot(d2db.psal2,d2db.potemp2,'color',lin_col(end,:),'linewidth',2)
xlim([min(sltemp2)-0.2 max(shtemp2)+0.2])
ylim([min(ptltemp2)-1 max(pthtemp2)+1])
xlabel('Salinity')
ylabel('Potential Temperature')
grid on;
eval(['title(''2dbar PT-S secondary, stations ' num2str(stns(1)) '-' num2str(stns(end)) ' blue-red, station ' num2str(stns(end)+1) '=green'')'])
    
figure(7) % plot previous stations and upcast-downcast data (secondary sensors)

% Get depth limits %

xhtemp=max(d2db.depth);

for i=1:np
    nns=num2str(i);
    nns2=num2str(i+1);
    eval(['xhtemp(' nns2 ')=max(d2db' nns '.depth);'])
end

x2lims=[0 max(xhtemp)+50];

subplot(221)

hold on 
for i=1:np
    nns=num2str(i);
    eval(['plot(dpsal' nns '.depth(1:ind_mid' num2str(i) '),dpsal' nns '.temp2(1:ind_mid' num2str(i) '),''color'',lin_col(i,:),''linewidth'',1)'])
    eval(['plot(dpsal' nns '.depth(ind_mid' num2str(i) '+1:end),dpsal' nns '.temp2(ind_mid' num2str(i) '+1:end),''color'',lin_col(i,:),''linewidth'',1,''linestyle'',''--'')'])
end
plot(dpsal.depth(1:ind_mid),dpsal.temp2(1:ind_mid),'color',lin_col(end,:),'linewidth',1)
plot(dpsal.depth(ind_mid+1:end),dpsal.temp2(ind_mid+1:end),'color',lin_col(end,:),'linewidth',1,'linestyle','--')
ylim([min(ptltemp2)-1 max(pthtemp2)+1])
xlim(x2lims)
xlabel('Depth (m)')
ylabel('Temperature')
grid on;
eval(['title(''psal T (secondary), stations ' num2str(stns(1)) '-' num2str(stns(end)) ' blue-red, station ' num2str(stns(end)+1) '=green, dash=upcast'')'])

subplot(222)

hold on 
for i=1:np
    nns=num2str(i);
    eval(['plot(dpsal' nns '.depth(1:ind_mid' num2str(i) '),dpsal' nns '.psal2(1:ind_mid' num2str(i) '),''color'',lin_col(i,:),''linewidth'',1)'])
    eval(['plot(dpsal' nns '.depth(ind_mid' num2str(i) '+1:end),dpsal' nns '.psal2(ind_mid' num2str(i) '+1:end),''color'',lin_col(i,:),''linewidth'',1,''linestyle'',''--'')'])
end
plot(dpsal.depth(1:ind_mid),dpsal.psal2(1:ind_mid),'color',lin_col(end,:),'linewidth',1)
plot(dpsal.depth(ind_mid+1:end),dpsal.psal2(ind_mid+1:end),'color',lin_col(end,:),'linewidth',1,'linestyle','--')
ylim([min(sltemp2)-0.2 max(shtemp2)+0.2])
xlim(x2lims)
xlabel('Depth (m)')
ylabel('Salinity')
grid on;
eval(['title(''psal S (secondary), stations ' num2str(stns(1)) '-' num2str(stns(end)) ' blue-red, station ' num2str(stns(end)+1) '=green, dash=upcast'')'])

% Get oxygen limits %

oltemp=min(d2db.oxygen);
ohtemp=max(d2db.oxygen);

for i=1:np
    nns=num2str(i);
    nns2=num2str(i+1);
    eval(['oltemp(' nns2 ')=min(d2db' nns '.oxygen);'])
    eval(['ohtemp(' nns2 ')=max(d2db' nns '.oxygen);'])
end

subplot(223)

hold on 
for i=1:np
    nns=num2str(i);
    eval(['plot(dpsal' nns '.depth(1:ind_mid' num2str(i) '),dpsal' nns '.oxygen(1:ind_mid' num2str(i) '),''color'',lin_col(i,:),''linewidth'',1)'])
    eval(['plot(dpsal' nns '.depth(ind_mid' num2str(i) '+1:end),dpsal' nns '.oxygen(ind_mid' num2str(i) '+1:end),''color'',lin_col(i,:),''linewidth'',1,''linestyle'',''--'')'])
end
plot(dpsal.depth(1:ind_mid),dpsal.oxygen(1:ind_mid),'color',lin_col(end,:),'linewidth',1)
plot(dpsal.depth(ind_mid+1:end),dpsal.oxygen(ind_mid+1:end),'color',lin_col(end,:),'linewidth',1,'linestyle','--')
ylim([min(oltemp)-20 max(ohtemp)+20])
xlim(x2lims)
xlabel('Depth (m)')
ylabel('Oxygen (umol/kg)')
grid on;
eval(['title(''psal Oxygen, stations ' num2str(stns(1)) '-' num2str(stns(end)) ' blue-red, station ' num2str(stns(end)+1) '=green, dash=upcast'')'])

subplot(224) % TS plot of psal Pot T - S data

vsigma0=20:1:30;
[c h] = contour(density.salin,density.potemp,density.sigma0,vsigma0,'k-');
clabel(c,h)
hold on 

for i=1:np
    nns=num2str(i);
    eval(['plot(dpsal' nns '.psal2(1:ind_mid' num2str(i) '),dpsal' nns '.potemp2(1:ind_mid' num2str(i) '),''color'',lin_col(i,:),''linewidth'',1)'])
    eval(['plot(dpsal' nns '.psal2(ind_mid' num2str(i) '+1:end),dpsal' nns '.potemp2(ind_mid' num2str(i) '+1:end),''color'',lin_col(i,:),''linewidth'',1,''linestyle'',''--'')'])
end
plot(dpsal.psal2(1:ind_mid),dpsal.potemp2(1:ind_mid),'color',lin_col(end,:),'linewidth',1)
plot(dpsal.psal2(ind_mid+1:end),dpsal.potemp2(ind_mid+1:end),'color',lin_col(end,:),'linewidth',1,'linestyle','--')
xlim([min(sltemp2)-0.2 max(shtemp2)+0.2])
ylim([min(ptltemp2)-1 max(pthtemp2)+1])
xlabel('Salinity')
ylabel('Potential Temperature')
grid on;
eval(['title(''psal (1Hz) PT-S (secondary), stations ' num2str(stns(1)) '-' num2str(stns(end)) ' blue-red, station ' num2str(stns(end)+1) '=green, dash=upcast'')'])

end

%%%%%%%%%%

% plot downcast versus upcast differences on density or pressure grid

f_st=find(dpsal.press>=20);

% % for density
% 
% f_db=find(dpsal.dens0==max(dpsal.dens0));

% for pressure

f_db=find(dpsal.press==max(dpsal.press));

%%%%

dpsal.temp_dc=(dpsal.temp(f_st(1):f_db));
dpsal.temp_uc=(dpsal.temp(f_db+1:f_st(end)));
dpsal.psal_dc=(dpsal.psal(f_st(1):f_db));
dpsal.psal_uc=(dpsal.psal(f_db+1:f_st(end)));
dpsal.oxygen_dc=(dpsal.oxygen(f_st(1):f_db));
dpsal.oxygen_uc=(dpsal.oxygen(f_db+1:f_st(end)));
dpsal.press_dc=(dpsal.press(f_st(1):f_db));
dpsal.press_uc=(dpsal.press(f_db+1:f_st(end)));
dpsal.dens0_dc=(dpsal.dens0(f_st(1):f_db));
dpsal.dens0_uc=(dpsal.dens0(f_db+1:f_st(end)));

% sort by variable 'var'

var=5; % 5 = pressure, 1 = density

dens_ar_dc=cat(1,dpsal.dens0_dc,dpsal.temp_dc,dpsal.psal_dc,dpsal.oxygen_dc,dpsal.press_dc);
dens_ar_uc=cat(1,dpsal.dens0_uc,dpsal.temp_uc,dpsal.psal_uc,dpsal.oxygen_uc,dpsal.press_uc);

dens_ar_dcs=sortrows(dens_ar_dc',var);
dens_ar_ucs=sortrows(dens_ar_uc',var);

[Bdc,Idc,Jdc]=unique(dens_ar_dcs(:,var));
[Buc,Iuc,Juc]=unique(dens_ar_ucs(:,var));

dens_ar_dcs=dens_ar_dcs(Idc,:);
dens_ar_ucs=dens_ar_ucs(Iuc,:);

% interpolate down and upcast measurements onto regular density grid

%XI=(1020:0.0001:1030); % for density
XI=(0:1:6000); % for pressure
filttype=('cubic');

dpsal.temp_dc_gr=interp1(dens_ar_dcs(:,var),dens_ar_dcs(:,2),XI,filttype,nan);
dpsal.temp_uc_gr=interp1(dens_ar_ucs(:,var),dens_ar_ucs(:,2),XI,filttype,nan);
dpsal.psal_dc_gr=interp1(dens_ar_dcs(:,var),dens_ar_dcs(:,3),XI,filttype,nan);
dpsal.psal_uc_gr=interp1(dens_ar_ucs(:,var),dens_ar_ucs(:,3),XI,filttype,nan);
dpsal.oxygen_dc_gr=interp1(dens_ar_dcs(:,var),dens_ar_dcs(:,4),XI,filttype,nan);
dpsal.oxygen_uc_gr=interp1(dens_ar_ucs(:,var),dens_ar_ucs(:,4),XI,filttype,nan);
dpsal.press_dc_gr=interp1(dens_ar_dcs(:,var),dens_ar_dcs(:,5),XI,filttype,nan);
dpsal.press_uc_gr=interp1(dens_ar_ucs(:,var),dens_ar_ucs(:,5),XI,filttype,nan);

% calculate difference between upcast and downcast

dpsal.temp_diff=dpsal.temp_uc_gr-dpsal.temp_dc_gr;
dpsal.psal_diff=dpsal.psal_uc_gr-dpsal.psal_dc_gr;
dpsal.oxygen_diff=dpsal.oxygen_uc_gr-dpsal.oxygen_dc_gr;
dpsal.press_diff=dpsal.press_uc_gr-dpsal.press_dc_gr;

% plot

figure(8) 

subplot(311)
plot(XI,dpsal.temp_diff)
grid on
xlim([0 6000])
xlabel('pressure (dbar)')
ylabel('offset (degC)')
title('T up-down First Choice')
ylim([-1 1])

subplot(312)
plot(XI,dpsal.psal_diff)
grid on
xlim([0 6000])
xlabel('pressure (dbar)')
ylabel('offset (psu)')
title('S up-down First Choice')
ylim([-0.05 0.05])

subplot(313)
plot(XI,dpsal.oxygen_diff)
grid on
xlim([0 6000])
xlabel('pressure (dbar)')
ylabel('offset (umol/kg)')
title('Oxygen up-down')
ylim([-5 5])

% figure(6) % for density
% 
% subplot(311)
% plot(XI,dpsal.potemp_diff)
% grid on
% xlim([1025 1028])
% xlabel('density (sig0)')
% ylabel('offset (degC)')
% title('PT up-down')
% ylim([-1 1])
% 
% subplot(312)
% plot(XI,dpsal.psal_diff)
% grid on
% xlim([1025 1028])
% xlabel('density (sig0)')
% ylabel('offset (psu)')
% title('S up-down')
% ylim([-0.05 0.05])
% 
% subplot(313)
% plot(XI,dpsal.oxygen_diff)
% grid on
% xlim([1025 1028])
% xlabel('density (sig0)')
% ylabel('offset (umol/kg)')
% title('Ox up-down')
% ylim([-5 5])
% 
% figure(7) % density offset plotted on interpolated pressure surfaces
% 
% subplot(311)
% plot(dpsal.press_dc_gr,dpsal.potemp_diff)
% grid on
% xlim([0 6000])
% xlabel('pressure (dbar)')
% ylabel('offset (degC)')
% title('PT up-down')
% ylim([-1 1])
% 
% subplot(312)
% plot(dpsal.press_dc_gr,dpsal.psal_diff)
% grid on
% xlim([0 6000])
% xlabel('pressure (dbar)')
% ylabel('offset (psu)')
% title('S up-down')
% ylim([-0.05 0.05])
% 
% subplot(313)
% plot(dpsal.press_dc_gr,dpsal.oxygen_diff)
% grid on
% xlim([0 6000])
% xlabel('pressure dbar)')
% ylabel('offset (umol/kg)')
% title('Ox up-down')
% ylim([-5 5])

if np==0

figure(2) % bring figure 2 second top
figure(1) % bring figure 1 to top

end

if np~=0

figure(2) % bring figure 2 third top
figure(6) % bring figure 6 second top
figure(5) % bring figure 5 to top

end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Old method interpolating onto regular pressure grid
% i.e. not using sort.m and unique.m
%
% smooth pressure
% 
% fil1=1;
% fil2=repmat(1/36,36,1);
% dpsal.press_dcsm=filtfilt(fil2,fil1,dpsal.press_dc);
% dpsal.press_ucsm=filtfilt(fil2,fil1,dpsal.press_uc);
% 
% interpolate down and upcast measurements onto regular pressure grid
% 
% XI=(10:1:dpsal.press(f_db));
% 
% dpsal.potemp_dc_gr=interp1(dpsal.press_dcsm,dpsal.potemp_dc,XI,'linear',nan);
% dpsal.potemp_uc_gr=interp1(dpsal.press_ucsm,dpsal.potemp_uc,XI,'linear',nan);
% dpsal.psal_dc_gr=interp1(dpsal.press_dcsm,dpsal.psal_dc,XI,'linear',nan);
% dpsal.psal_uc_gr=interp1(dpsal.press_ucsm,dpsal.psal_uc,XI,'linear',nan);
% dpsal.oxygen_dc_gr=interp1(dpsal.press_dcsm,dpsal.oxygen_dc,XI,'linear',nan);
% dpsal.oxygen_uc_gr=interp1(dpsal.press_ucsm,dpsal.oxygen_uc,XI,'linear',nan);
% 
% calculate difference between upcast and downcast
% 
% dpsal.potemp_diff=dpsal.potemp_uc_gr-dpsal.potemp_dc_gr;
% dpsal.psal_diff=dpsal.psal_uc_gr-dpsal.psal_dc_gr;
% dpsal.oxygen_diff=dpsal.oxygen_uc_gr-dpsal.oxygen_dc_gr;
% 



