figure(101); clf


din = diffs.potemp_intrp;
dot = din;
x= diffs.longitude_intrp;
y = -diffs.press_intrp;

k1 = find(x >= -42 & x <= -14);
k2 = find(x >= -14 & x <= 6);
k3 = find(x > 6 & x <= 15);

scl = 1;


w = ones(1,15);

for kl = 1:size(din,1);
    dot(kl,:) = filter_bak(w,din(kl,:));
%     dot(kl,k1) = filter_bak(w,din(kl,k1));
%     dot(kl,k2) = filter_bak(w,din(kl,k2));
%     dot(kl,k3) = filter_bak(w,din(kl,k3));
end

w = ones(1,5);
for kl = 1:size(din,2);
    dot(:,kl) = filter_bak(w,dot(:,kl));
end

clev = [-.06:.02:.06 -.1 -.2 .1 .2 ]*scl;
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

title(' Temperature difference JC159 (2018) minus JC032 (2009)');
xlabel('Longitude');
ylabel('Pressure');


figure(102); clf
dd1 = nanmean(dot(:,k1),2);
dd2 = nanmean(dot(:,k2),2);
dd3 = nanmean(dot(:,k3),2);


plot(dd1,y,'k-','linewidth',2);
hold on; grid on;
plot(dd2,y,'r-','linewidth',2);
plot(dd3,y,'c-','linewidth',2);
title(' Temperature difference JC159 (2018) minus JC032 (2009)');
xlabel('Degrees');
ylabel('Pressure');

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


