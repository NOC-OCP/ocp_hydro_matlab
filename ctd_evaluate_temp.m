d = mload('sam_jr306_all','/')

ts = d.sbe35temp;
t1 = d.utemp1;
t2 = d.utemp2;

d1 = ts-t1;
d2 = ts-t2;
dd = t1-t2;

% kok = find(d.upress > 000 & d.statnum > 91);
% kok = find(d.upress > 000 & d.statnum < 91 & d.statnum >= 28 & d.utemp1 > 1);
% kok = find(d.upress > 000 & d.statnum < 991 & d.statnum >= -28 & d.utemp1 > -100); % ie , all
kok = find(d.upress > 000 & d.statnum < 991 & d.statnum >= -28 & d.utemp1 > -100 & d.sbe35flag == 2); % ie , all with flag = 2

edges = [-.005:.0005:.005];

n1 = histc(d1(kok),edges);
n2 = histc(d2(kok),edges);
nd = histc(dd(kok),edges);

figure
subplot(3,1,1)
bar(edges,n1,'histc')
hold on; grid on;
title('sbe35-t1');
subplot(3,1,2)
bar(edges,n2,'histc')
hold on; grid on;
title('sbe35-t2');
subplot(3,1,3)
bar(edges,nd,'histc')
hold on; grid on;
title('t1-t2');

figure
subplot(3,1,1)
plot(d.statnum(kok),d1(kok),'+');
title('sbe35-t1');
hold on; grid on;
ax = axis; axis([ax(1) ax(2) -0.010 0.010])
subplot(3,1,2)
plot(d.statnum(kok),d2(kok),'+');
title('sbe35-t2');
hold on; grid on;
ax = axis; axis([ax(1) ax(2) -0.010 0.010])
subplot(3,1,3)
plot(d.statnum(kok),dd(kok),'+');
title('t1-t2');
hold on; grid on;
ax = axis; axis([ax(1) ax(2) -0.010 0.010])

[1000*nanmedian(d1(kok)) 1000*nanmedian(d2(kok)) 1000*nanmedian(dd(kok))
1000*iqr(d1(kok)) 1000*iqr(d2(kok)) 1000*iqr(dd(kok))]
