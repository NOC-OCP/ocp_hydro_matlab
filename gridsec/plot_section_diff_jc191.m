figure(101); clf


% din = diffs.dic_intrp_scl;
% din = diffs.potemp_intrp;
din = diffs.dic_intrp;
dot = din;
x= diffs.longitude_intrp;
y = -diffs.press_intrp;

k1 = find(x >= -80 & x <= -55);
k2 = find(x >= -55 & x <= -14);
k3 = find(x >= -80 & x <= -14);

scl = 200;


w = ones(1,35); % base grid is 0.2 deg lon, 20 dbar;

for kl = 1:size(din,1);
    dot(kl,:) = filter_bak(w,din(kl,:)); % each row, 35 x.2 in the horizontal
%     dot(kl,k1) = filter_bak(w,din(kl,k1));
%     dot(kl,k2) = filter_bak(w,din(kl,k2));
%     dot(kl,k3) = filter_bak(w,din(kl,k3));
end

w = ones(1,15);
for kl = 1:size(din,2);  
    dot(:,kl) = filter_bak(w,dot(:,kl));  % each column, 5 x 20 dbar in the vertical
end

clev = [-.06:.02:.06 -.1 -.2 .1 .2 .4 -.4]*scl;
clev = unique(clev);
contourf(x,y,dot,clev);
hold on; grid on;

jet41 = jet(41);

jj = [
    jet41(1:9,:)
    jet41(15,:)
    jet41(28,:)
    jet41(33:41,:)
    ];

colormap(jj);
colorbar;
caxis([-.4 .4]*scl);

allcruises = {
    'JC191 (2020)'
    'DY040 (2016)'
    'DI346 (2010)'
    'DI279 (2004)'
    'USA98 (1998)'
    'HE006 (1992)'
    'AT109 (1981)'
    'DS057 (1957)'
    };

cr1 = allcruises{dc_1};
cr2 = allcruises{dc_2};

% tit_str = ['Salinity difference ' cr1 ' minus ' cr2];
% xlabstr = ['Salinity units'];
% tit_str = ['Temperature difference ' cr1 ' minus ' cr2];
% xlabstr = ['Degrees'];

tit_str = ['DIC difference ' cr1 ' minus ' cr2];
xlabstr = ['umol/kg'];

xlabel('Longitude');
ylabel('Pressure');
title(tit_str);


figure(102); 
dd1 = nanmean(dot(:,k1),2);
dd2 = nanmean(dot(:,k2),2);
dd3 = nanmean(dot(:,k3),2);


plot(0*y,y,'k-','linewidth',1);
hold on; grid on;
plot(dd1,y,'k-','linewidth',2);
hold on; grid on;
% plot(dd2,y,'r-','linewidth',2);
% plot(dd3,y,'c-','linewidth',2);
title(tit_str);
xlabel(xlabstr);
ylabel('Pressure');

return

k1 = min(find(x > -25));
k2 = min(find(x > -2));
k3 = min(find(x > 12));

ks = 30;

figure(103); clf
plot(d1.botoxy_intrp(:,k1),d1.potemp_intrp(:,k1),'k-');
hold on; grid on
plot(d2.botoxy_intrp(:,k1),d2.potemp_intrp(:,k1),'r-');
plot(d1.botoxy_intrp(:,k2),d1.potemp_intrp(:,k2),'b-');
hold on; grid on
plot(d2.botoxy_intrp(:,k2),d2.potemp_intrp(:,k2),'m-');

figure(104); clf
plot(nanmean(d1.botoxy_intrp(:,k1:k1+ks),2),-d1.press_intrp(:),'k-');
hold on; grid on
plot(nanmean(d2.botoxy_intrp(:,k1:k1+ks),2),-d2.press_intrp(:),'r-');
plot(nanmean(d1.botoxy_intrp(:,k2:k2+ks),2),-d1.press_intrp(:),'b-');
hold on; grid on
plot(nanmean(d2.botoxy_intrp(:,k2:k2+ks),2),-d2.press_intrp(:),'m-');

figure(105); clf
hold on; grid on
plot(nanmean(d1.botoxy_intrp(:,k2:k2+ks)-d2.botoxy_intrp(:,k2:k2+ks),2),-d2.press_intrp(:),'m-');


