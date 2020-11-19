
stn_num = 1:145;
for kl = stn_num
    if mod(kl,5) == 0; fprintf(1,'%s %d\n','kl = ',kl); end

    w = ones(1,401);
    
    do1(kl).doxfilt = filter_bak(w,do1(kl).oxupdown);
    do2(kl).doxfilt = filter_bak(w,do2(kl).oxupdown);
    
    sens1_diff(1:7000,kl) =do1(kl).doxfilt'; 
    sens2_diff(1:7000,kl) =do2(kl).doxfilt'; 
end
% % 
% % sens1_diff = do1(stn_num]).doxfilt;
% % sens2_diff = do2(stn_num).doxfilt;

stn_num = 1:145;
figure
orient portrait
hold on, grid on
xlabel('station number'), ylabel('oxygen difference: upcast minus downcast')
title('sensor 1; up minus down;  k:0-1000 r:1000-2000 g:2000-3000 b:3000-4000 c:4000-5000 m:5000+')
mn_diff = nanmean(sens1_diff(1:1000,:));
plot(stn_num, mn_diff-4,'k.')
Igd = find(~isnan(mn_diff));
mn_diff_filt = filter_bak_median(51,mn_diff(Igd));
plot(stn_num(Igd),mn_diff_filt-4,'k','Linewidth',[2])
plot(stn_num(Igd),mn_diff_filt,'k','Linewidth',[2])

mn_diff = nanmean(sens1_diff(1001:2000,:));
plot(stn_num, mn_diff-6,'r.')
Igd = find(~isnan(mn_diff));
mn_diff_filt = filter_bak_median(51,mn_diff(Igd));
plot(stn_num(Igd),mn_diff_filt-6,'r','Linewidth',[2])
plot(stn_num(Igd),mn_diff_filt,'r','Linewidth',[2])

mn_diff = nanmean(sens1_diff(2001:3000,:));
plot(stn_num, mn_diff-8,'g.')
Igd = find(~isnan(mn_diff));
mn_diff_filt = filter_bak_median(21,mn_diff(Igd));
plot(stn_num(Igd),mn_diff_filt-8,'g','Linewidth',[2])
plot(stn_num(Igd),mn_diff_filt,'g','Linewidth',[2])

mn_diff = nanmean(sens1_diff(3001:4000,:));
plot(stn_num, mn_diff-10,'b.')
Igd = find(~isnan(mn_diff));
mn_diff_filt = filter_bak_median(21,mn_diff(Igd));
plot(stn_num(Igd),mn_diff_filt-10,'b','Linewidth',[2])
plot(stn_num(Igd),mn_diff_filt,'b','Linewidth',[2])

mn_diff = nanmean(sens1_diff(4001:5000,:));
plot(stn_num, mn_diff-12,'c.')
Igd = find(~isnan(mn_diff));
mn_diff_filt = filter_bak_median(21,mn_diff(Igd));
plot(stn_num(Igd),mn_diff_filt-12,'c','Linewidth',[2])
plot(stn_num(Igd),mn_diff_filt,'c','Linewidth',[2])

mn_diff = nanmean(sens1_diff(5001:end,:));
plot(stn_num, mn_diff-14,'m.')
Igd = find(~isnan(mn_diff));
mn_diff_filt = filter_bak_median(21,mn_diff(Igd));
plot(stn_num(Igd),mn_diff_filt-14,'m','Linewidth',[2])
plot(stn_num(Igd),mn_diff_filt,'m','Linewidth',[2])


figure
orient portrait
hold on, grid on
xlabel('station number'), ylabel('oxygen difference: upcast minus downcast')
title('sensor 2; up minus down;  k:0-1000 r:1000-2000 g:2000-3000 b:3000-4000 c:4000-5000 m:5000+')
mn_diff = nanmean(sens2_diff(1:1000,:));
plot(stn_num, mn_diff-4,'k.')
Igd = find(~isnan(mn_diff));
mn_diff_filt = filter_bak_median(51,mn_diff(Igd));
plot(stn_num(Igd),mn_diff_filt-4,'k','Linewidth',[2])
plot(stn_num(Igd),mn_diff_filt,'k','Linewidth',[2])

mn_diff = nanmean(sens2_diff(1001:2000,:));
plot(stn_num, mn_diff-6,'r.')
Igd = find(~isnan(mn_diff));
mn_diff_filt = filter_bak_median(51,mn_diff(Igd));
plot(stn_num(Igd),mn_diff_filt-6,'r','Linewidth',[2])
plot(stn_num(Igd),mn_diff_filt,'r','Linewidth',[2])

mn_diff = nanmean(sens2_diff(2001:3000,:));
plot(stn_num, mn_diff-8,'g.')
Igd = find(~isnan(mn_diff));
mn_diff_filt = filter_bak_median(21,mn_diff(Igd));
plot(stn_num(Igd),mn_diff_filt-8,'g','Linewidth',[2])
plot(stn_num(Igd),mn_diff_filt,'g','Linewidth',[2])

mn_diff = nanmean(sens2_diff(3001:4000,:));
plot(stn_num, mn_diff-10,'b.')
Igd = find(~isnan(mn_diff));
mn_diff_filt = filter_bak_median(21,mn_diff(Igd));
plot(stn_num(Igd),mn_diff_filt-10,'b','Linewidth',[2])
plot(stn_num(Igd),mn_diff_filt,'b','Linewidth',[2])

mn_diff = nanmean(sens2_diff(4001:5000,:));
plot(stn_num, mn_diff-12,'c.')
Igd = find(~isnan(mn_diff));
mn_diff_filt = filter_bak_median(21,mn_diff(Igd));
plot(stn_num(Igd),mn_diff_filt-12,'c','Linewidth',[2])
plot(stn_num(Igd),mn_diff_filt,'c','Linewidth',[2])

mn_diff = nanmean(sens2_diff(5001:end,:));
plot(stn_num, mn_diff-14,'m.')
Igd = find(~isnan(mn_diff));
mn_diff_filt = filter_bak_median(21,mn_diff(Igd));
plot(stn_num(Igd),mn_diff_filt-14,'m','Linewidth',[2])
plot(stn_num(Igd),mn_diff_filt,'m','Linewidth',[2])
