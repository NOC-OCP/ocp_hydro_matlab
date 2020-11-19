% run mgeost first 

bc.fix = -10e6;
ekman.fix = -3e6;
all.fix = 0e0;
basindivide = -27;


fnin1 = 'grid_jc159_24s.nc';
fnin2 = 'grid_jc159_24s_g3.nc';
% fnin1 = 'grid_jc032_main.nc';
% fnin2 = 'grid_jc032_main_g3.nc';

d1 = mload(fnin1,'/');
d2 = mload(fnin2,'/');

x = d1.longitude(1,:);
y = d1.latitude(1,:);
p = d1.press(:,1);
celldp = 20;

kdiv = max(find(d2.glon(1,:) <= basindivide));

d2.dist = sw_dist(y,x,'km');

nx = size(d2.glon,2);
nx1 = nx+1;
np = size(d2.glon,1);
d2.cellarea = nan+d2.gvel;

for kp = 1:np
    for kx = 1:nx
        d2.cellarea(kp,kx) = 1000*d2.dist(kx)*celldp;
    end
end

d2.mask = isfinite(d2.gvel);
d2.mask = double(d2.mask);

d2.vel = d2.gveldcl;

d2.cellpotemp = nan+d2.mask;
d2.cellpsal = nan+d2.mask;

% interpolate properties
for kp = 1:np
    d2.cellpotemp(kp,:) = interp1(x,d1.potemp(kp,:),d2.glon(kp,:));
    d2.cellpsal(kp,:) = interp1(x,d1.psal(kp,:),d2.glon(kp,:));
end

% adjust ref level to 1300

pref = 1300;
pdif = p-pref;
[pdifmin kmin] = min(abs(pdif));
velref = d2.vel(kmin,:);
velref(~isfinite(velref)) = 0;
vel_adj = -velref;
vel_adj = repmat(vel_adj,np,1);

d2.vel = d2.vel + vel_adj;

all.cellarea = d2.cellarea;
all.cellpotemp = d2.cellpotemp;
all.cellpsal = d2.cellpsal;
all.vel = d2.vel;
all.mask = d2.mask;
all.press = p;
all.glon = d2.glon(1,:);

% ekman

ekman.mask = 0*all.mask;
ekman.mask(1,:) = all.mask(1,:);
ekman.potempav = nansum(all.cellarea(:).*all.cellpotemp(:).*ekman.mask(:))/nansum(all.cellarea(:).*ekman.mask(:));
ekman.psalav = nansum(all.cellarea(:).*all.cellpsal(:).*ekman.mask(:))/nansum(all.cellarea(:).*ekman.mask(:));

% brazil current

bc.mask = 0*all.mask;
bc.mask(1:25,1:6) = 1;
bc.mask = min(bc.mask,all.mask);
bcrow = sum(bc.mask,1);
bcrow(bcrow >= 1) = 1; % work out which columns are in the bc mask.
bc.colmask = repmat(bcrow,np,1).*all.mask; % entire column in masked in or out

bc.potempav = nansum(all.cellarea(:).*all.cellpotemp(:).*bc.colmask(:))/nansum(all.cellarea(:).*bc.colmask(:));
bc.psalav = nansum(all.cellarea(:).*all.cellpsal(:).*bc.colmask(:))/nansum(all.cellarea(:).*bc.colmask(:));

% basin

basin.mask = all.mask - bc.mask;



% adjust brazil current to bc.fix; adjustment must be applied over whole
% water column, even if the constraint is over just part of the water
% columns
bc.transport_vol = nansum(all.cellarea(:).*all.vel(:).*bc.mask(:));
vol_adj = bc.fix-bc.transport_vol;
vel_adj = vol_adj/nansum(all.cellarea(:).*bc.mask(:));
bc.vel_adj = vel_adj*bc.colmask;



% adjust ekman to ekman.fix
vel_adj = ekman.fix/nansum(all.cellarea(:).*ekman.mask(:));
ekman.vel_adj = vel_adj*ekman.mask;


% adjust total volume to zero
vel = all.vel + bc.vel_adj + ekman.vel_adj;
all.transport_vol = nansum(all.cellarea(:).*vel(:).*all.mask(:));
vol_adj = all.fix-all.transport_vol;
vel_adj = vol_adj/nansum(all.cellarea(:).*all.mask(:));
all.vel_adj = vel_adj*all.mask;

all.velnew = all.vel + bc.vel_adj + ekman.vel_adj + all.vel_adj;

% divide western and eastern basins
all.mask_w = 0*all.mask;
all.mask_w(:,1:kdiv) = all.mask(:,1:kdiv);
all.mask_e = 0*all.mask;
all.mask_e(:,kdiv+1:end) = all.mask(:,kdiv+1:end);

% now do some calculations

all.celltransport_vol = all.cellarea.*all.velnew;
all.celltransport_potemp = all.celltransport_vol.*all.cellpotemp;
all.celltransport_psal = all.celltransport_vol.*all.cellpsal;

all.total_area = nansum(all.cellarea(:).*all.mask(:));
all.total_flux_vol = nansum(all.celltransport_vol(:).*all.mask(:));
all.total_flux_potemp = nansum(all.celltransport_potemp(:).*all.mask(:));
all.total_flux_psal = nansum(all.celltransport_psal(:).*all.mask(:));
all.potempav = nansum(all.cellarea(:).*all.cellpotemp(:).*all.mask(:))/all.total_area;
all.psalav = nansum(all.cellarea(:).*all.cellpsal(:).*all.mask(:))/all.total_area;

all.transport_per_layer = nansum(all.celltransport_vol.*all.mask,2);
all.transport_cum_from_top = cumsum(all.transport_per_layer);

all.transport_per_column = nansum(all.celltransport_vol.*all.mask,1);
all.transport_cum_from_west = cumsum(all.transport_per_column);


west.transport_per_layer = nansum(all.celltransport_vol.*all.mask_w,2);
west.transport_cum_from_top = cumsum(west.transport_per_layer);

east.transport_per_layer = nansum(all.celltransport_vol.*all.mask_e,2);
east.transport_cum_from_top = cumsum(east.transport_per_layer);

all.transport_freshwater = (-0.8e6*32.5 - all.total_flux_psal)/all.psalav/1e6;
[ov kmax] = max(all.transport_cum_from_top);
all.overturning = ov;
all.pmax_overturning = p(kmax);

all.layerarea = nansum(all.cellarea.*all.mask,2);
all.vbarx = nansum(all.velnew.*all.cellarea.*all.mask,2)./all.layerarea;
all.tbarx = nansum(all.cellpotemp.*all.cellarea.*all.mask,2)./all.layerarea;
all.sbarx = nansum(all.cellpsal.*all.cellarea.*all.mask,2)./all.layerarea;
all.colarea = nansum(all.cellarea.*all.mask,1);
all.tbarz = nansum(all.cellarea.*all.cellpotemp.*all.mask,1)./all.colarea;
all.sbarz = nansum(all.cellarea.*all.cellpsal.*all.mask,1)./all.colarea;

all.vanom = all.velnew-repmat(all.vbarx,1,nx);
all.tanom = all.cellpotemp-repmat(all.tbarx,1,nx);
all.sanom = all.cellpsal-repmat(all.sbarx,1,nx);

all.over_t = nansum(all.vbarx.*all.tbarx.*all.layerarea);
all.over_s = nansum(all.vbarx.*all.sbarx.*all.layerarea);
all.horiz_t = nansum(all.vanom.*all.tanom.*all.cellarea,2);
all.horiz_s = nansum(all.vanom.*all.sanom.*all.cellarea,2);

all.sumover_t = nansum(all.over_t);
all.sumover_s = nansum(all.over_s);
all.sumhoriz_t = nansum(all.horiz_t);
all.sumhoriz_s = nansum(all.horiz_s);


fprintf(1,'\n\n%s %7.2f %s \n','Total heat transport : ',all.total_flux_potemp*1000*4000/1e15,' PW')
fprintf(1,'%s %7.2f %s \n','Over  heat transport : ',all.sumover_t*1000*4000/1e15,' PW')
fprintf(1,'%s %7.2f %s \n','Horiz heat transport : ',all.sumhoriz_t*1000*4000/1e15,' PW')
fprintf(1,'%s %7.2f %s \n','Resid heat transport : ',(all.total_flux_potemp - all.sumover_t - all.sumhoriz_t)*1000*4000/1e15,' PW')
fprintf(1,'\n%s %7.2f %s \n','Total salt transport : ',all.total_flux_psal/1e6,' SvPSU')
fprintf(1,'%s %7.2f %s \n','Over  salt transport : ',all.sumover_s/1e6,' SvPSU')
fprintf(1,'%s %7.2f %s \n','Horiz salt transport : ',all.sumhoriz_s/1e6,' SvPSU')
fprintf(1,'%s %7.2f %s \n','Resid salt transport : ',(all.total_flux_psal - all.sumover_s - all.sumhoriz_s)/1e6,' SvPSU')
fprintf(1,'\n%s %7.2f %s \n','Total freshwater transport : ',all.transport_freshwater,' Sv')
fprintf(1,'\n%s %7.2f %s \n','Mov                        : ',-all.over_s/all.psalav/1e6,' Sv')
fprintf(1,'\n%s %7.2f %s %5d %s \n','Max overturning            : ',all.overturning/1e6,' Sv at ',all.pmax_overturning',' dbar')
fprintf(1,'%s %7.3f %s  \n','potemp av            : ',all.potempav,' degc')
fprintf(1,'%s %7.3f %s  \n','psal av              :               ',all.psalav,' PSU')
fprintf(1,'%s %7.3f %s  \n','potemp av  ekman     : ',ekman.potempav,' degc')
fprintf(1,'%s %7.3f %s  \n','psal av    ekman     :               ',ekman.psalav,' PSU')
fprintf(1,'%s %7.3f %s  \n','potemp av  bc        : ',bc.potempav,' degc')
fprintf(1,'%s %7.3f %s  \n','psal av    bc        :               ',bc.psalav,' PSU')


w = ones(1,11);
figure(101); clf
plot(filter_bak(w,west.transport_per_layer(2:end))*1000/celldp/1e6,-p(2:end),'k'); %transport Sv per thousand dbar
hold on; grid on;
plot(filter_bak(w,east.transport_per_layer(2:end))*1000/celldp/1e6,-p(2:end),'m'); %transport Sv per thousand dbar
plot(filter_bak(w,all.transport_per_layer(2:end))*1000/celldp/1e6,-p(2:end),'c'); %transport Sv per thousand dbar
xlabel('k,m,c : west,east,all  Sv/1000 ');

figure(102); clf
plot(all.transport_cum_from_top/1e6,-p,'k');
hold on; grid on;

figure(103); clf
subplot(3,1,1)
plot(all.glon,all.transport_cum_from_west/1e6,'k+-');
hold on; grid on;
subplot(3,1,2)
plot(all.glon,all.tbarz,'k+-');
hold on; grid on;
subplot(3,1,3)
plot(all.glon,all.sbarz,'k+-');
hold on; grid on;


figure(104); clf
subplot(1,2,1)
plot(all.tbarx-all.potempav,-p,'k-');
xlabel('potemp anomaly');
hold on; grid on
subplot(1,2,2)
plot(all.sbarx-all.psalav,-p,'k-');
hold on; grid on;
xlabel('psal anomaly');

return


