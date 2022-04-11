function section_plots(klist, reload)
% function section_plots(klist, reload)
%
% make section contour plots for ctd variables and scatter plots for
% bottle variables
%
% ylf jc159

m_common
mcruise = MEXEC_G.MSCRIPT_CRUISE_STRING;

cruise0loc = []; mcruise0 = 'jc032'; cruise0loc = '/local/users/pstar/jc032/jc032_fromship/ctd/';
klist0 = [23:47 49:118];

if reload

   pg = [1:2:6201]';

   %load ctd data
   potemp = NaN+zeros(length(pg), length(klist));
   psal = potemp; oxy = psal;
   lon = NaN+zeros(1, length(klist)); lat = lon;
   for sno = 1:length(klist)
      stn = klist(sno); stn_string = sprintf('%03d', stn);
      fname = ['ctd/ctd_' mcruise '_' stn_string '_2db.nc'];
      if exist(fname)
         [d, h] = mload(fname, '/');
         n = length(d.press); n0 = (d.press(1)-1)/2+1;
         potemp(n0+[1:n], sno) = d.potemp;
         psal(n0+[1:n], sno) = d.psal;
         oxy(n0+[1:n], sno) = d.oxygen;
         lon(sno) = h.longitude; lat(sno) = h.latitude;
      end
   end
   %exclude missing stations and sort by longitude
   stns = klist;
   ii = find(isnan(lon)); stns(ii) = []; lon(ii) = []; lat(ii) = [];
   potemp(:,ii) = []; psal(:,ii) = []; oxy(:,ii) = [];
   [lon, ii] = sort(lon); lat = lat(ii); stns = stns(ii);
   potemp = potemp(:,ii); psal = psal(:,ii); oxy = oxy(:,ii);

   save ctd_mat lon lat stns potemp psal oxy pg

   if exist(cruise0loc)==7
      %load old cruise data
      potemp0 = NaN+zeros(length(pg), length(klist0));
      psal0 = potemp0; oxy0 = psal0;
      lon0 = NaN+zeros(1, length(klist0)); lat0 = lon0;
      for sno = 1:length(klist0)
         stn = klist0(sno); stn_string = sprintf('%03d', stn);
         fname = [cruise0loc '/ctd_' mcruise0 '_' stn_string '_2db.nc'];
         if exist(fname)
            [d, h] = mload(fname, '/');
            n = length(d.press); n0 = (d.press(1)-1)/2+1;
            potemp0(n0+[1:n], sno) = d.potemp;
            psal0(n0+[1:n], sno) = d.psal;
            oxy0(n0+[1:n], sno) = d.oxygen;
            lon0(sno) = h.longitude; lat0(sno) = h.latitude;
         end
      end
      %sort
      stns0 = klist0;
      [lon0, ii] = sort(lon0); lat0 = lat0(ii); stns0 = stns0(ii);
      potemp0 = potemp0(:,ii); psal0 = psal0(:,ii); oxy0 = oxy0(:,ii);
      save -append ctd_mat lon0 lat0 stns0 potemp0 psal0 oxy0
   end
   
else

   load ctd_mat
   
end


%apply approx/prelim calibration to ctd data
disp('applying oxy calibration before plotting')
oxy = oxy_apply_cal(1, repmat(stns, length(pg), 1), repmat(pg, 1, length(lon)), zeros(length(pg), length(lon)), zeros(length(pg), length(lon)), oxy); iscal = 1;


%load bottle data
[d, h] = mload(['ctd/sam_' mcruise '_all'], '/');
iis = find(ismember(d.statnum, stns));
[stnl,ia,iistn] = intersect(5:10:150, stns); %for labels

%load old bottle data
if exist(cruise0loc)
   [d0, h0] = mload([cruise0loc '/sam_' mcruise0 '_all'], '/');
   iis0 = find(ismember(d.statnum, stns0));
   d0.lon = NaN+d0.statnum;
   for no = 1:length(stns0); ii = find(d0.statnum==stns0(no)); d0.lon(ii) = lon0(no); end
end
%apply glodap adjustments
oxy0 = oxy0*1.035; d0.uoxygen = d0.uoxygen*1.035;
d0.silc = d0.silc*0.95; d0.totnit = d0.totnit*0.99;

%plot parameters
clevt = [0:26]; clevlt = [];
clevs = [34.4:.1:37]; clevls = [34.5:.5:37];
clevo = [130:5:260]; clevlo = [140:20:260];
clevtni = [2.5:1.25:35]; clevltni = [5:5:35];
clevsil = [5:5:135]; clevlsil = [5:20:135];
clevpho = [.1:.1:2.7]; clevlpho = [.3:.4:2.7];
clevlt = []; clevls = []; clevlo = [];
clevltni = []; clevlsil = []; clevlpho = [];
clevalk = [2290:5:2420]; clevlalk = [2170:20:2410];
clevdic = [2060:7.5:2255]; clevldic = [2060:30:2240];
clevlalk = []; clevldic = [];
clevsf6 = [.05:.05:1.35]; clevlsf6 = [];
clevccl4 = [0:26]/5; clevlccl4 = [];
clevcfc11 = [0:26]*.15; clevlcfc11 = [];
clevcfc12 = [0:26]*.08; clevlcfc12 = [];
clevf113 = [0:26]*.008; clevlf113 = [];
ms = 10; %scatter dot size


w = 10; h = 8; spx = 1.75; spy = 1.25; spc = 0.4;
sll = 200;

load cmap_by
cmap = interp1([0:63]/63, cmap_by, [0:length(clevt)]/length(clevt));


ii1 = [1:22]; ii2 = [ii1(end)+1:ii1(end)+22]; ii3 = [ii2(end)+1:ii2(end)+15]; ii4 = [ii3(end)+1:ii3(end)+22]; ii5 = [ii4(end)+1:ii4(end)+15]; ii6 = [ii5(end)+1:length(lon)];
n1 = length(ii1); n2 = length(ii2); n3 = length(ii3); n4 = length(ii4); n5 = length(ii5); n6 = length(ii6);
cmap1 = flipud(mk_cmap(n1+4, 'hot')); cmap1 = cmap1(3:end-2,:);
cmap2 = mk_cmap(n2+5, 'copper'); cmap2 = cmap2(6:end,:);
cmapp = flipud(mk_cmap(n3+20, 'spring')); cmapp = cmapp(21:end,:); %n = 10; a = 4; y = a*repmat(exp(-[1:n]'.^2/n),1,3); cmapp(1:n,:) = (cmapp(1:n,:)+y)./(1+y);
cmap3 = cmapp;
cmap4 = flipud(mk_cmap(n4, 'cool'));
cmap3 = interp1([0 n3+1]', [cmap2(end,:); cmap4(1,:)], [1:n3]');
cmap6 = mk_cmap(n6,'summer');
cmap5 = interp1([0 n5+1], [cmap4(end,:); cmap6(1,:)], [1:n5]');
cmap_l = [cmap1; cmap2; cmap3; cmap4; cmap5; cmap6];


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


%T,S,O
figure(1); clf; clear ha hc*

[ha(1,1), hcb(1,1)] = sect_cont_scat(lon, -pg, potemp, clevt, cmap, clevlt, d.lon(iis), -d.upress(iis), []);
text(lon(iistn)', sll+zeros(length(iistn),1), num2str(stnl'), 'horizontalalignment', 'center');
axes(ha(1,1)); ylabel('-p (dbar)'); set(ha(1,1), 'xticklabel', []);
axes(ha(1,1)); ylabel('-p (dbar)'); title(mcruise)
axes(hcb(1,1)); ylabel('\theta (degC)'); %axes(hcb(2,1)); ylabel('\theta (degC)')

[ha(2,1), hcb(2,1)] = sect_cont_scat(lon, -pg, psal, clevs, cmap, clevls, d.lon(iis), -d.upress(iis), d.botpsal(iis));
text(lon(iistn)', sll+zeros(length(iistn),1), num2str(stnl'), 'horizontalalignment', 'center');
ylabel('-p (dbar)'); set(ha(2,1), 'xticklabel', [])
axes(hcb(2,1)); ylabel('S_P (psu)')

[ha(3,1), hcb(3,1)] = sect_cont_scat(lon, -pg, oxy, clevo, cmap, clevlo, d.lon(iis), -d.upress(iis), d.botoxy(iis));
text(lon(iistn)', sll+zeros(length(iistn),1), num2str(stnl'), 'horizontalalignment', 'center');
ylabel('-p (dbar)'); xlabel('longitude')
axes(hcb(3,1)); ylabel('O (umol/kg)')

if exist(cruise0loc) & exist('potemp0')

   [ha(1,2), h0] = sect_cont_scat(lon0, -pg, potemp0, clevt, cmap, clevlt, d0.lon, -d0.upress, []);
   set(ha(1,2), 'xticklabel', [], 'yticklabel', []); delete(h0)
   axis([lon(1)-.1 lon(end)+.1 min(-pg)-1 max(-pg)+1])
   title(mcruise0)
   [ha(2,2), h0] = sect_cont_scat(lon0, -pg, psal0, clevs, cmap, clevls, d0.lon, -d0.upress, d0.botpsal);
   set(ha(2,2), 'xticklabel', [], 'yticklabel', []); delete(h0)
   axis([lon(1)-.1 lon(end)+.1 min(-pg)-1 max(-pg)+1])
   [ha(3,2), h0] = sect_cont_scat(lon0, -pg, oxy0, clevo, cmap, clevlo, d0.lon, -d0.upress, d0.botoxy);
   set(ha(3,2), 'yticklabel', []); delete(h0)
   axis([lon(1)-.1 lon(end)+.1 min(-pg)-1 max(-pg)+1])
end

axes_paper_pos(ha, w, h, size(ha,1), size(ha,2), hcb, 'centimeters')

axes(ha(1,1)); hold on
for no = 1:length(lon); hlc(no) = plot(lon(no),-6000,'o','markerfacecolor',cmap_l(no,:),'color',cmap_l(no,:)); hold on; end

if exist('iscal') & iscal
   print -dpng plots/sect_tso_cal.png
else
   print -dpng plots/sect_tso_uncal.png
end


%Si, NO3+NO2, P
figure(2); clf; clear ha hc*

[ha(1,1), hcb(1,1)] = sect_cont_scat(lon, -pg, [], clevsil, cmap, clevlsil, d.lon(iis), -d.upress(iis), d.silc(iis));
text(lon(iistn)', sll+zeros(length(iistn),1), num2str(stnl'), 'horizontalalignment', 'center');
ylabel('-p (dbar)'); set(ha(1,1), 'xticklabel', [])
axes(hcb(1,1)); ylabel('Si (umol/L)')

[ha(2,1), hcb(2,1)] = sect_cont_scat(lon, -pg, [], clevtni, cmap, clevltni, d.lon(iis), -d.upress(iis), d.totnit(iis));
text(lon(iistn)', sll+zeros(length(iistn),1), num2str(stnl'), 'horizontalalignment', 'center');
ylabel('-p (dbar)'); set(ha(2,1), 'xticklabel', [])
axes(hcb(2,1)); ylabel('NO3+NO2 (umol/L)')

[ha(3,1), hcb(3,1)] = sect_cont_scat(lon, -pg, [], clevpho, cmap, clevlpho, d.lon(iis), -d.upress(iis), d.phos(iis));
text(lon(iistn)', sll+zeros(length(iistn),1), num2str(stnl'), 'horizontalalignment', 'center');
ylabel('-p (dbar)'); xlabel('longitude')
axes(hcb(3,1)); ylabel('PO4 (umol/L)') %varnames?***

if exist(cruise0loc) & exist('potemp0')
   [ha(1,2), h0] = sect_cont_scat(lon0, -pg, [], clevsil, cmap, clevlsil, d0.lon, -d0.upress, d0.silc);
   set(ha(1,2), 'xticklabel', [], 'yticklabel', []); delete(h0)
   axis([lon(1)-.1 lon(end)+.1 min(-pg)-1 max(-pg)+1])
   [ha(2,2), h0] = sect_cont_scat(lon0, -pg, [], clevtni, cmap, clevltni, d0.lon, -d0.upress, d0.totnit);
   set(ha(2,2), 'xticklabel', [], 'yticklabel', []); delete(h0)
   axis([lon(1)-.1 lon(end)+.1 min(-pg)-1 max(-pg)+1])
   [ha(3,2), h0] = sect_cont_scat(lon0, -pg, [], clevpho, cmap, clevlpho, d0.lon, -d0.upress, d0.phos);
   set(ha(3,2), 'yticklabel', [], 'yticklabel', []); delete(h0)
   axis([lon(1)-.1 lon(end)+.1 min(-pg)-1 max(-pg)+1])
end

axes_paper_pos(ha, w, h, size(ha,1), size(ha,2), hcb, 'centimeters')
print -dpng plots/sect_siltnipho.png



%TAlk, DIC
figure(3); clf; clear ha hc*

[ha(1,1), hcb(1,1)] = sect_cont_scat(lon, -pg, [], clevalk, cmap, clevalk, d.lon(iis), -d.upress(iis), d.alk(iis));
text(lon(iistn)', sll+zeros(length(iistn),1), num2str(stnl'), 'horizontalalignment', 'center');
ylabel('-p (dbar)'); set(ha(1,1), 'xticklabel', [])
axes(hcb(1,1)); ylabel('TAlk (umol/L)')

[ha(2,1), hcb(2,1)] = sect_cont_scat(lon, -pg, [], clevdic, cmap, clevltni, d.lon(iis), -d.upress(iis), d.dic(iis));
text(lon(iistn)', sll+zeros(length(iistn),1), num2str(stnl'), 'horizontalalignment', 'center');
ylabel('-p (dbar)');
axes(hcb(2,1)); ylabel('DIC (umol/L)')

if exist(cruise0loc) & exist('potemp0')
   [ha(1,2), h0] = sect_cont_scat(lon0, -pg, [], clevalk, cmap, clevlalk, d0.lon, -d0.upress, d0.alk);
   set(ha(1,2), 'xticklabel', [], 'yticklabel', []); delete(h0)
   axis([lon(1)-.1 lon(end)+.1 min(-pg)-1 max(-pg)+1])
   [ha(2,2), h0] = sect_cont_scat(lon0, -pg, [], clevdic, cmap, clevldic, d0.lon, -d0.upress, d0.dic);
   set(ha(2,2), 'xticklabel', [], 'yticklabel', []); delete(h0)
   axis([lon(1)-.1 lon(end)+.1 min(-pg)-1 max(-pg)+1])
end

axes_paper_pos(ha, w, h, size(ha,1), size(ha,2), hcb, 'centimeters')
print -dpng plots/sect_alkdic.png



%tracers
figure(10); clf; clear ha hc*

[ha(1,1), hcb(1,1)] = sect_cont_scat(lon, -pg, [], clevsf6, cmap, clevlsf6, d.lon(iis), -d.upress(iis), d.sf6(iis));
text(lon(iistn)', sll+zeros(length(iistn),1), num2str(stnl'), 'horizontalalignment', 'center');
ylabel('-p (dbar)'); set(ha(1,1), 'xticklabel', [])
axes(hcb(1,1)); ylabel('SF6 (pmol/L)')

[ha(2,1), hcb(2,1)] = sect_cont_scat(lon, -pg, [], clevccl4, cmap, clevlccl4, d.lon(iis), -d.upress(iis), d.ccl4(iis));
text(lon(iistn)', sll+zeros(length(iistn),1), num2str(stnl'), 'horizontalalignment', 'center');
ylabel('-p (dbar)');
axes(hcb(2,1)); ylabel('CCL4 (pmol/L)')

if exist(cruise0loc) & exist('potemp0')
   [ha(1,2), h0] = sect_cont_scat(lon0, -pg, [], clevsf6, cmap, clevlsf6, d0.lon, -d0.upress, d0.sf6);
   set(ha(1,2), 'xticklabel', [], 'yticklabel', []); delete(h0)
   axis([lon(1)-.1 lon(end)+.1 min(-pg)-1 max(-pg)+1])
   [ha(2,2), h0] = sect_cont_scat(lon0, -pg, [], clevccl4, cmap, clevlccl4, d0.lon, -d0.upress, d0.ccl4);
   set(ha(2,2), 'xticklabel', [], 'yticklabel', []); delete(h0)
   axis([lon(1)-.1 lon(end)+.1 min(-pg)-1 max(-pg)+1])
end

axes_paper_pos(ha, w, h, size(ha,1), size(ha,2), hcb, 'centimeters')
print -dpng plots/sect_cfcs1.png


figure(11); clf; clear ha hc*

[ha(1,1), hcb(1,1)] = sect_cont_scat(lon, -pg, [], clevcfc11, cmap, clevlcfc11, d.lon(iis), -d.upress(iis), d.cfc11(iis));
text(lon(iistn)', sll+zeros(length(iistn),1), num2str(stnl'), 'horizontalalignment', 'center');
ylabel('-p (dbar)'); set(ha(1,1), 'xticklabel', [])
axes(hcb(1,1)); ylabel('CFC11 (pmol/L)')

[ha(2,1), hcb(2,1)] = sect_cont_scat(lon, -pg, [], clevcfc12, cmap, clevlcfc12, d.lon(iis), -d.upress(iis), d.cfc12(iis));
text(lon(iistn)', sll+zeros(length(iistn),1), num2str(stnl'), 'horizontalalignment', 'center');
ylabel('-p (dbar)'); set(ha(2,1), 'xticklabel', [])
axes(hcb(2,1)); ylabel('CFC12 (pmol/L)')

[ha(3,1), hcb(3,1)] = sect_cont_scat(lon, -pg, [], clevf113, cmap, clevlf113, d.lon(iis), -d.upress(iis), d.f113(iis));
text(lon(iistn)', sll+zeros(length(iistn),1), num2str(stnl'), 'horizontalalignment', 'center');
ylabel('-p (dbar)'); xlabel('longitude')
axes(hcb(3,1)); ylabel('F113 (pmol/L)')

if exist(cruise0loc) & exist('potemp0')
   [ha(1,2), h0] = sect_cont_scat(lon0, -pg, [], clevcfc11, cmap, clevlcfc11, d0.lon, -d0.upress, d0.cfc11);
   set(ha(1,2), 'xticklabel', [], 'yticklabel', []); delete(h0)
   axis([lon(1)-.1 lon(end)+.1 min(-pg)-1 max(-pg)+1])
   [ha(2,2), h0] = sect_cont_scat(lon0, -pg, [], clevcfc12, cmap, clevlcfc12, d0.lon, -d0.upress, d0.cfc12);
   set(ha(2,2), 'xticklabel', [], 'yticklabel', []); delete(h0)
   axis([lon(1)-.1 lon(end)+.1 min(-pg)-1 max(-pg)+1])
   [ha(3,2), h0] = sect_cont_scat(lon0, -pg, [], clevf113, cmap, clevlf113, d0.lon, -d0.upress, d0.f113);
   set(ha(3,2), 'yticklabel', [], 'yticklabel', []); delete(h0)
   axis([lon(1)-.1 lon(end)+.1 min(-pg)-1 max(-pg)+1])
end

axes_paper_pos(ha, w, h, size(ha,1), size(ha,2), hcb, 'centimeters')
print -dpng plots/sect_cfcs2.png




%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


pden = sw_dens(psal, potemp, pg);

clear ha hc* hl
iid = find(pg>=3000);

tlim = [-.5 28]; tlimd = [-.1 2.6];
slim = [34.1 37.3]; slimd = [34.66 34.93];
olim = [60 260]; olimd = [215 257];

figure(4); clf
subplot(121); hl(:,1,1) = plot(psal, potemp);
xlabel('S_P (psu)'); ylabel('\theta (degC)')
axis([slim tlim])
subplot(122); hl(:,1,2) = plot(psal(iid,:), potemp(iid,:));
xlabel('S_P (psu)'); ylabel('\theta (degC)')
axis([slimd tlimd])

figure(5); clf
subplot(121); hl(:,2,1) = plot(potemp, oxy);
xlabel('\theta (degC)'); ylabel('oxygen (umol/kg)')
axis([tlim olim])
subplot(122); hl(:,2,2) = plot(potemp(iid,:), oxy(iid,:));
xlabel('\theta (degC)'); ylabel('oxygen (umol/kg)')
axis([tlimd olimd])

figure(6); clf
subplot(121); hl(:,3,1) = plot(psal, oxy);
xlabel('S_P (psu)'); ylabel('oxygen (umol/kg)')
axis([slim olim])
subplot(122); hl(:,3,2) = plot(psal(iid,:), oxy(iid,:));
xlabel('S_P (psu)'); ylabel('oxygen (umol/kg)')
axis([slimd olimd])

figure(7); clf
subplot(131); hl(:,2,3) = plot(potemp, -pg);
xlabel('\theta (degC)'); ylabel('-p (dbar)')
axis([tlim -6000 0])
subplot(132); hl(:,1,3) = plot(psal, -pg);
xlabel('S_P (psu)'); ylabel('-p (dbar)')
axis([slim -6000 0])
subplot(133); hl(:,3,3) = plot(oxy, -pg);
xlabel('oxygen (umol/kg)'); ylabel('-p (dbar)')
axis([olim -6000 0])

for no = 1:length(lon); set(hl(no,:,:), 'color', cmap_l(no,:)); end

figure(4); orient landscape; print -dpng plots/ts_scatter.png
figure(5); orient landscape; print -dpng plots/to_scatter.png
figure(6); orient landscape; print -dpng plots/so_scatter.png
figure(7); orient landscape; print -dpng plots/tso_profiles.png



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


SA = gsw_SA_from_SP(psal, pg, lon, lat);
CT = gsw_CT_from_pt(SA, potemp);
p_ref = 0; %***does pref have to be in pg?
addpath ~/projects/sr1b/mfiles
[phi, gvel, lonm, latm, ang, dst] = gshr(lon, lat, SA, CT, pg, p_ref);


keyboard


%plotting function
function [ha, hcb] = sect_cont_scat(xa, ya, data, clev, cmap, clevl, xs, ys, datas);

   ms = 10; %scatter dot size

   iid = find(ya<=1000);

   colormap(cmap)
   ha(1) = axes;
%   ha(2) = axes;

   if ~isempty(data)

      axes(ha(1))
      [hc, hcb] = cont_cbar(xa, ya, data, clev, cmap);
%      [hc, hcb] = cont_cbar_nl(2, xa, ya, data, clev, cmap); 
      axes(ha); hold on; ca = caxis;
%      if length(clevl)>0; [c, hc] = contour(xa, ya, data, clevl, 'k'); end
%      axes(ha(2))
%      [hc, hcb] = cont_cbar(xa, ya(iid), data(iid,:), clev, cmap);
   else
      data = zeros(length(ya), length(xa));
      [hc, hcb] = cont_cbar(xa, ya, data, clev, cmap);
%      [hc, hcb] = cont_cbar_nl(2, xa, ya, data, clev, cmap);
      delete(hc)
      axes(ha); hold on; ca = caxis;
   end

   if ~isempty(datas)
      axes(ha(1))
      iig = find(~isnan(datas));
      hold on; scatter(xs(iig), ys(iig), ms, datas(iig), 'filled');
%      datas1 = power(abs(datas), 2); datas1(datas<0) = -datas1(datas<0);
%      hold on; scatter(xs(iig), ys(iig), ms, datas1(iig), 'filled');
%      axes(ha(2))
%      iig = find(~isnan(datas) & ys<=1000);
%      hold on; scatter(xs(iig), ys(iig), ms, datas(iig), 'filled');
   end

%   caxis(clev([1 end]))
   axes(ha(1)); axis([xa(1)-.1 xa(end)+.1 min(ya)-1 max(ya)+1]); caxis(ca)
%   axes(ha(2)); axis([xa(1)-.1 xa(end)+.1 min(ya(iid))-1 max(ya(iid))+1]); caxis(ca)
