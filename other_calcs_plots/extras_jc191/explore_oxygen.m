d = mload('sam_jc191_all.nc','/');

s = d.statnum;
p = d.upress;
o1 = d.uoxygen1;
o2 = d.uoxygen2;
ob = d.botoxy;
of = d.botoxyflag;

n = numel(s);
nb = 24;
ns = n/nb; % number stations

s = reshape(s,nb,ns);
p = reshape(p,nb,ns);
o1 = reshape(o1,nb,ns);
o2 = reshape(o2,nb,ns);
ob = reshape(ob,nb,ns);
of = reshape(of,nb,ns);

of(ob<50) = 4; % some crude QC to get rid of zeros

kok = find((of == 2 | of == 3 ) & ob > 50 & isfinite(ob) & s >= 2 & p > 0000);
kbad = setdiff(1:n,kok);
ob(kbad) = nan; % set to nan if flag ~= 2

o1r = ob./o1;  % ratio bottle to CTD
o2r = ob./o2;

kbad = find(o1r < 0.8 | o1r > 1.5);
ob(kbad) = nan;
o1r = ob./o1;  % ratio bottle to CTD
o2r = ob./o2;


o1rs = nanmedian(o1r,1); % median ratio per station
o2rs = nanmedian(o2r,1);

% for stations 1 to 25, choose single offset
o1rsuse = o1rs+nan;
o2rsuse = o2rs+nan;
f11 = ones(1,11);

o1rsf = filter_bak(f11,o1rs); % smooth the median ratio per station and put it in 'filtered'
o2rsf = filter_bak(f11,o2rs);

b10 = 0;
b11 = 20;
b12 = 70;
b13 = 135;

kuse11 = find(isfinite(o1rs) & s(1,:) >= b10+1 & s(1,:) <= b11);
kuse12 = find(isfinite(o1rs) & s(1,:) >= b11+1 & s(1,:) <= b12);
kuse13 = find(isfinite(o1rs) & s(1,:) >= b12+1 & s(1,:) <= b13);
n11 = length(kuse11);
n12 = length(kuse12);
n13 = length(kuse13);
% coefs2 = polyfit(s(1,kuse2),o2rs(kuse2),1);
% o2rsreg = polyval(coefs2,s(1,25:end));
snum1 = [kuse11 kuse12 kuse13];

yy1 = o1rs([kuse11 kuse12 kuse13]); yy1 = yy1(:);
V1 = zeros(length(yy1),4);
V1(:,1) = 1;
V1(1:n11,2) = kuse11;
V1(n11+1:end,2) = b11;
V1(n11+(1:n12),3) = kuse12-b11;
V1(n11+n12+1:end,3) = b12-b11;
V1(n11+n12+(1:n13),4) = kuse13-b12;
V1(:,2) = 0; % o1rs = a + b * s + c *(s-20) + d * (s-70); force b to be zero. 


[Q,R] = qr(V1);
coef_new1 = R\(Q'*yy1);

o1rsuse = V1*coef_new1;
o1rsuse = o1rsuse(:)';

getfac1 = [
    1 0 0 0
    1 b11 0 0
    1 b11 b12-b11 0
    1 b11 b12-b11 b13-b12
    ];
getfac1out = getfac1*coef_new1;



b20 = 0;
b21 = 20;
b22 = 70;
b23 = 135;

kuse21 = find(isfinite(o2rs) & s(1,:) >= b20+1 & s(1,:) <= b21);
kuse22 = find(isfinite(o2rs) & s(1,:) >= b21+1 & s(1,:) <= b22);
kuse23 = find(isfinite(o2rs) & s(1,:) >= b22+1 & s(1,:) <= b23);
n21 = length(kuse21);
n22 = length(kuse22);
n23 = length(kuse23);
% coefs2 = polyfit(s(1,kuse2),o2rs(kuse2),1);
% o2rsreg = polyval(coefs2,s(1,25:end));
snum2 = [kuse21 kuse22 kuse23];

yy2 = o2rs([kuse21 kuse22 kuse23]); yy2 = yy2(:);
V2 = zeros(length(yy2),4);
V2(:,1) = 1;
V2(1:n21,2) = kuse21;
V2(n21+1:end,2) = b21;
V2(n21+(1:n22),3) = kuse22-b21;
V2(n21+n22+1:end,3) = b22-b21;
V2(n21+n22+(1:n23),4) = kuse23-b22;
V2(:,2) = 0;


[Q,R] = qr(V2);
coef_new2 = R\(Q'*yy2);

o2rsuse = V2*coef_new2;
o2rsuse = o2rsuse(:)';

getfac2 = [
    1 0 0 0
    1 b21 0 0
    1 b21 b22-b21 0
    1 b21 b22-b21 b23-b22
    ];
getfac2out = getfac2*coef_new2;



% o1rsuse(25:end) = o1rsreg;         % use regression for stn >= 25
% o1rsuse(1:24) = nanmedian(o1rs(1:24));  % use fixed value for stn <= 25
% o2rsuse(25:end) = o2rsreg;
% o2rsuse(1:24) = nanmedian(o2rs(1:40));

figure(101); clf

subplot(2,1,1)
plot(s(kok),o1r(kok),'k.'); hold on; grid on;
plot(s(1,:),o1rsf,'m+-','linewidth',2); hold on; grid on;
plot(snum1,o1rsuse,'c-','linewidth',2); hold on; grid on;

subplot(2,1,2)
plot(s(kok),o2r(kok),'k.'); hold on; grid on;
plot(s(1,:),o2rsf,'m+-','linewidth',2); hold on; grid on;
plot(snum2,o2rsuse,'c-','linewidth',2); hold on; grid on;


o1rsuse(length(o1rsuse)+1:length(o1)) = o1rsuse(end);
o2rsuse(length(o2rsuse)+1:length(o2)) = o2rsuse(end);

o1corfac = repmat(o1rsuse,24,1); % repmat the correction factor
o2corfac = repmat(o2rsuse,24,1);

o1cor = o1.*o1corfac; % adjusted for sensor drift
o2cor = o2.*o2corfac;

o1rr = ob./o1cor; % residual factor after adjusting for sensor drift
o2rr = ob./o2cor;

deps = [-10 2000:1000:6000 6600]; % don't use 1000 dbar; strong gradients
ndeps = length(deps);

o1dfac = nan(1,ndeps); % will collect depth factor here
o2dfac = nan(1,ndeps);

for kd = 1:ndeps
    dep1 = deps(kd)-200;
    dep2 = deps(kd)+200;
    kuse = find(of == 2 & isfinite(ob) & p >= dep1 & p <= dep2);
    o1dfac(kd) = nanmedian(o1rr(kuse)); % median factor in this 400m depth bin centred on a depth level
    o2dfac(kd) = nanmedian(o2rr(kuse));
end

o1dfac(end) = o1dfac(end-1); % use same factor at 6600 as 6000
o2dfac(end) = o2dfac(end-1);

o1corfacd = interp1(deps,o1dfac,p,'linear','extrap'); % interpolate the depth-dependent corfac onto press
o2corfacd = interp1(deps,o2dfac,p,'linear','extrap');

o1cord = o1cor.*o1corfacd; % corrected for station drift and depth dependence
o2cord = o2cor.*o2corfacd;

figure(102); clf
subplot(1,2,1)
plot(ob./o1cor,-p,'k+'); hold on; grid on; % adjusted for sensor drift with station, but not depth dependence
plot(o1dfac,-deps,'r+-','linewidth',2)
set(gca,'xlim',[0.96 1.04]);
xlabel({'oxygen1';'factor'});
subplot(1,2,2)
plot(ob./o2cor,-p,'k+'); hold on; grid on;
plot(o2dfac,-deps,'r+-','linewidth',2)
set(gca,'xlim',[0.96 1.04]);
xlabel({'oxygen2';'factor'});


figure(103); clf
subplot(1,2,1)
plot(ob-o1cord,-p,'k+'); hold on; grid on;
set(gca,'xlim',[-10 10]);
ylabel('bottle - adjusted CTD');
xlabel('oxygen1 umol/kg')
subplot(1,2,2)
plot(ob-o2cord,-p,'k+'); hold on; grid on;
set(gca,'xlim',[-10 10]);
xlabel('oxygen2 umol/kg')



figure(104); clf
subplot(2,1,1)
plot(s,ob-o1cord,'k.'); hold on; grid on;
set(gca,'ylim',[-10 10]);
ylabel('bot-ox1 umol/kg');
subplot(2,1,2)
plot(s,ob-o2cord,'k.'); hold on; grid on;
set(gca,'ylim',[-10 10]);
ylabel('bot-ox2 umol/kg');


fprintf(1,'%s %d %d %d %d %s\n','o1rs_s = [',b10,b11,b12,b13,' ];');
fprintf(1,'%s %7.4f %7.4f %7.4f %7.4f %s\n','o1rs_f = [',getfac1out,' ];');
dform = []; for knd = 1:length(deps); dform = [dform ' %d']; end
fform = []; for knd = 1:length(deps); fform = [fform ' %7.4f']; end
fprintf(1,['%s' dform ' %s\n'],'deps = [',deps,' ];');
fprintf(1,['%s' fform ' %s\n'],'o1dfac = [',o1dfac,' ];');

fprintf(1,'\n');

fprintf(1,'%s %d %d %d %d %s\n','o2rs_s = [',b20,b21,b22,b23,' ];');
fprintf(1,'%s %7.4f %7.4f %7.4f %7.4f %s\n','o2rs_f = [',getfac2out,' ];');
dform = []; for knd = 1:length(deps); dform = [dform ' %d']; end
fform = []; for knd = 1:length(deps); fform = [fform ' %7.4f']; end
fprintf(1,['%s' dform ' %s\n'],'deps = [',deps,' ];');
fprintf(1,['%s' fform ' %s\n'],'o2dfac = [',o2dfac,' ];');



