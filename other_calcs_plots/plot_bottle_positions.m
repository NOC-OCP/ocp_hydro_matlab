d = mload('sam_jc159_all','/');
dp.in = load('BOTTLE_SHORE/jc159_niskins_microplastics_noheader.csv');
dp.sampnum = 100*dp.in(:,1)+dp.in(:,2);


figure(101); clf
set(gcf,'defaultaxeslinewidth',2)
%return
set(gcf,'defaultlinelinewidth',2)
%return
set(gcf,'defaultaxesfontsize',16)
set(gcf,'defaulttextfontsize',16)


plot(d.lon,-d.upress,'k+');
title('JC159 bottle positions');
xlabel('Longitude (degrees)');
ylabel('Pressure (dbar)');
grid on;

print -dpsc jc159_bottle_positions_all.ps
print -dpng jc159_bottle_positions_all.png


figure(106); clf
set(gcf,'defaultaxeslinewidth',2)
%return
set(gcf,'defaultlinelinewidth',2)
%return
set(gcf,'defaultaxesfontsize',16)
set(gcf,'defaulttextfontsize',16)

kok = find(d.upress < 600);

plot(d.lon(kok),-d.upress(kok),'k+');
title({'JC159 bottle positions';'(upper 600 metres)'});
xlabel('Longitude (degrees)');
ylabel('Pressure (dbar)');
grid on;

print -dpsc jc159_bottle_positions_all_upper600.ps
print -dpng jc159_bottle_positions_all_upper600.png


figure(102); clf
set(gcf,'defaultaxeslinewidth',2)
%return
set(gcf,'defaultlinelinewidth',2)
%return
set(gcf,'defaultaxesfontsize',16)
set(gcf,'defaulttextfontsize',16)

kok = find(d.botchla_flag == 1);

plot(d.lon(kok),-d.upress(kok),'k+');
title('JC159 bottle positions sampled for Chla');
xlabel('Longitude (degrees)');
ylabel('Pressure (dbar)');
set(gca,'YLim',[-400 0]);
grid on

print -dpsc jc159_bottle_positions_chla.ps
print -dpng jc159_bottle_positions_chla.png



figure(103); clf
set(gcf,'defaultaxeslinewidth',2)
%return
set(gcf,'defaultlinelinewidth',2)
%return
set(gcf,'defaultaxesfontsize',16)
set(gcf,'defaulttextfontsize',16)

kok = find(d.del13c_imp_flag == 1 | d.del14c_imp_flag == 1);

plot(d.lon(kok),-d.upress(kok),'k+');
title('JC159 bottle positions sampled for carbon isotopes');
xlabel('Longitude (degrees)');
ylabel('Pressure (dbar)');
grid on

print -dpsc jc159_bottle_positions_isotopes.ps
print -dpng jc159_bottle_positions_isotopes.png



figure(107); clf
set(gcf,'defaultaxeslinewidth',2)
%return
set(gcf,'defaultlinelinewidth',2)
%return
set(gcf,'defaultaxesfontsize',16)
set(gcf,'defaulttextfontsize',16)

kok = find(~isnan(d.cfc11) | ~isnan(d.cfc12) |~isnan(d.sf6) |~isnan(d.f113) |~isnan(d.ccl4) );

plot(d.lon(kok),-d.upress(kok),'k+');
title('JC159 bottle positions sampled for CFCs');
xlabel('Longitude (degrees)');
ylabel('Pressure (dbar)');
set(gca,'XLim',[-50 20]);
grid on

print -dpsc jc159_bottle_positions_cfc.ps
print -dpng jc159_bottle_positions_cfc.png



figure(104); clf
set(gcf,'defaultaxeslinewidth',2)
%return
set(gcf,'defaultlinelinewidth',2)
%return
set(gcf,'defaultaxesfontsize',16)
set(gcf,'defaulttextfontsize',16)

[k0 k1 kok] = intersect(dp.sampnum,d.sampnum);

plot(d.lon(kok),-d.upress(kok),'k+');
title('JC159 bottle positions sampled for microplastics');
xlabel('Longitude (degrees)');
ylabel('Pressure (dbar)');
grid on

print -dpsc jc159_bottle_positions_plastics.ps
print -dpng jc159_bottle_positions_plastics.png


figure(105); clf
set(gcf,'defaultaxeslinewidth',2)
%return
set(gcf,'defaultlinelinewidth',2)
%return
set(gcf,'defaultaxesfontsize',16)
set(gcf,'defaulttextfontsize',16)

[k0 k1 kok] = intersect(dp.sampnum,d.sampnum);
kok2 = find(d.upress(kok) < 600);

plot(d.lon(kok(kok2)),-d.upress(kok(kok2)),'k+');
title({'JC159 bottle positions sampled for microplastics'; '(upper 600 metres)'});
xlabel('Longitude (degrees)');
ylabel('Pressure (dbar)');
grid on

print -dpsc jc159_bottle_positions_plastics_upper600.ps
print -dpng jc159_bottle_positions_plastics_upper600.png




figure(108); clf
set(gcf,'defaultaxeslinewidth',2)
%return
set(gcf,'defaultlinelinewidth',2)
%return
set(gcf,'defaultaxesfontsize',16)
set(gcf,'defaulttextfontsize',16)

kok = find(~isnan(d.alk) | ~isnan(d.dic) );

plot(d.lon(kok),-d.upress(kok),'k+');
title('JC159 bottle positions sampled for carbon');
xlabel('Longitude (degrees)');
ylabel('Pressure (dbar)');
set(gca,'XLim',[-50 20]);
grid on

print -dpsc jc159_bottle_positions_carbon.ps
print -dpng jc159_bottle_positions_carbon.png

