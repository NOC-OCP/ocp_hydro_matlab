% bak jc191
% find the bottle chl that is max in each station; this should be region
% of smallest vertical gradient and best for CTD fluor cal.

[d h ]= mload('sam_jc191_all','/');
d.dnum = datenum(h.data_time_origin) + d.time/86400;

botchl_max = nan(max(d.statnum),1);
ctdf_max = nan(max(d.statnum),1);
bottime_max = botchl_max;

figure(201); clf

for kl = 1:max(d.statnum);
    if kl >= 67 & kl <= 70; continue; end
    kok = find(d.statnum == kl);
    ctdf = d.ufluor(kok);
%     ctdf = 1.85*(ctdf-0.02);
    botchl = d.chla(kok);
    ctdp = d.upress(kok);
    bottime = 24*(d.dnum(kok)-floor(d.dnum(kok))); % hour of day
    [cmax kmax] = max(botchl);
    botchl_max(kl) = botchl(kmax);
    ctdf_max(kl) = ctdf(kmax);
    bottime_max(kl) = bottime(kmax);
    plot(ctdf,botchl,'k+'); hold on; grid on;
    if isfinite(botchl(kmax))
        fprintf(1,'%3d %5.0f %6.3f %6.3f\n',kl,ctdp(kmax),ctdf(kmax),botchl(kmax))
    end
end
    

figure(201)

set(gcf,'defaultaxeslinewidth',2)
%return
set(gcf,'defaultlinelinewidth',2)
%return
set(gcf,'defaultaxesfontsize',16)
set(gcf,'defaulttextfontsize',16)

plot(ctdf_max,botchl_max,'ro','markerface','r','markersize',6); hold on; grid on;

plot([-.25 1]*.4,[-.25 1 ]*.4,'k-');

axis square
xlabel('1.85 * (CTD_fluor_raw - 0.02)','interpreter','none');
ylabel('Sample Chla');
title({'JC191 sample and CTD fluor';'Stations 4 to 135 ';'Red circles are Chla max on each station'});
axis([-0.1 0.4 -0.1 0.4]);


print -dpsc jc191_chlcal.ps
print -dpng jc191_chlcal.png


figure(202); clf

plot(bottime_max,botchl_max./ctdf_max,'k+'); hold on; grid on;
