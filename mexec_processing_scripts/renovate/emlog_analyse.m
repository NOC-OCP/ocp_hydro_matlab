% di346
% 15/5/2005 data, was entered in em log panel at start di346

% rpm = [75 100 125 150 160 ;75 100 125 150 160];
% true = [402 602 860 971 1123 ;476 653 807 980 1034]/100;
% meas = [220 391 587 704 762 ;380 541 699 849 864]/100;
% fake point added to visualise extrapolation
rpm = [75 100 125 150 160 999;75 100 125 150 160 999];
true = [402 602 860 971 1123 1700;476 653 807 980 1034 1700]/100;
meas = [220 391 587 704 762 1043 ;380 541 699 849 864 1043]/100;

figure

plot(meas,true,'+-'); hold on; grid on;
title('di346; 2005/05/15')
xlabel('measured (knots)')
ylabel('true (knots)')

mean_meas = mean(meas,1)
mean_true = mean(true,1)

plot(mean_meas,mean_true,'k+-');
axis([0 12 0 18])


% 2008/7/17 data
rpm = [70 100 150; 70 100 150];

true = [379 588 958; 584 878 1184]/100;
meas = [442 697 1127; 437 826 1196]/100;

% figure

plot(meas,true,'+-'); hold on; grid on;
title('di346; 2007/07/17')
xlabel('measured (knots) ie emlog raw data')
ylabel('true (knots), ie emlog will be calibrated to report')

mean_meas = mean(meas,1);
mean_true = mean(true,1);

plot(mean_meas,mean_true,'k+-');
axis([0 12 0 18])

plot([0 12], [0 12],'m-','linewidth',3);

% bw proposed table after comparing emlog with VMADCP on di346
rpm = [75 100 125 150 160 999;75 100 125 150 160 999];
true = [ 326 468 625 735 811 1086;  326 468 625 735 811 1086]/100;
true = [ 326 468 625 770 811 1086;  326 468 625 770 811 1086]/100;
meas = [300 466 643 776 813 1043; 300 466 643 776 813 1043]/100;

plot(meas,true,'c+-'); hold on; grid on;
title('di346; 2007/07/17')
xlabel('measured (knots) ie emlog raw data')
ylabel('true (knots), ie emlog will be calibrated to report')

mean_meas = mean(meas,1);
mean_true = mean(true,1);

plot(mean_meas,mean_true,'r+-','linewidth',3);
axis([0 12 0 18])

% jc069

rpm1 = [37 60 85 110];
meas1 = [92 150 212 274]/100;
true1 = [371 590 788 1066]/100;

rpm2 = [13 20 27 37 47 60 84 110];
meas2 = [19 32 46 92 93 150 180 274]/100;
true2 = [108 155 207 371 411 590 795 1011]/100;

lookup = [
    0 0
    10 48
    20 80
    30 120
    40 161
    60 241
    80 322
    92 371
    100 401
    120 476
    140 552
    150 590
    180 685
    200 749
    212 788
    274 1066
    370 1496
    ];
meas3 = lookup(:,1)/100;
true3 = lookup(:,2)/100; % emlog displayed speed using start of cruise cal
cal3 = emlog_cal_jc069(true3); % true speed from vmadcp

figure

plot(meas3,true3,'b+-','linewidth',3);
hold on; grid on;
plot(meas2,true2,'r+-');
plot(meas1, true1,'ko-','linewidth',2)
plot(meas3, cal3,'c+-','linewidth',2)
title('jc069; start of cruise')
xlabel('measured (knots) ie emlog raw data')
ylabel('true (knots), ie emlog will be calibrated to report')
axis([-2 4 -2 12])

fprintf(1,'%4s %4s\n','a','s')
for kl = 1:length(meas3)
    fprintf(1,'%4.0f %4.0f\n',meas3(kl)*100,cal3(kl)*100);
end






