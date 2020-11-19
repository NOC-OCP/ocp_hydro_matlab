d = mload('sam_jc191_all.nc','/');
% d = mload('/run/media/pstar/jc191_2/jc191/backup_20200225011001/data/ctd/sam_jc191_all.nc','/');
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

kok = find((of == 2 | of == 3 ) & ob > 50 & isfinite(ob) & s >= 2 & p > 0000 & s <= 135);
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

% b1 = [0 20 70 121 135]; nb1 = length(b1)-1; % number of break points apart from station zero
b1 = [0 20 70 122 135]; nb1 = length(b1)-1; % number of break points apart from station zero
clear kuse1 n1 snum1
getfac1 = zeros(nb1+1,nb1+1);
snum1 = [];
for kb = 1:nb1
    kuse1{kb} =  find(isfinite(o1rs) & s(1,:) >= b1(kb)+1 & s(1,:) <= b1(kb+1));
    n1(kb) = length(kuse1{kb});
    snum1 = [snum1 kuse1{kb}];
end

% coefs2 = polyfit(s(1,kuse2),o2rs(kuse2),1);
% o2rsreg = polyval(coefs2,s(1,25:end));

yy1 = o1rs(snum1); yy1 = yy1(:);
V1 = zeros(length(yy1),nb1);

V1(:,1) = 1;
getfac1(:,1) = 1;

for kb = 1:nb1
    nbefore = sum(n1(1:kb-1));
    nuse = n1(kb);
    nafter = sum(n1(kb+1:nb1));
    kuse = kuse1{kb}; kuse = kuse(:);
    V1(1:nbefore,kb+1) = 0;
    V1(nbefore+1:nbefore+nuse,kb+1) = kuse-b1(kb);
    V1(nbefore+nuse+1:nbefore+nuse+nafter,kb+1) = b1(kb+1)-b1(kb);
    getfac1(kb+1:end,kb+1) = b1(kb+1)-b1(kb);
end


V1(:,2) = 0; % o1rs = a + b * s + c *(s-20) + d * (s-70) + e *(s-121); force b to be zero. 


[Q,R] = qr(V1);
coef_new1 = R\(Q'*yy1);

o1rsuse = V1*coef_new1;
o1rsuse = o1rsuse(:)';


getfac1out = getfac1*coef_new1;




b2 = [0 20 70 122 135]; nb2 = length(b2)-1; % number of break points apart from station zero
clear kuse2 n2 snum2
getfac2 = zeros(nb2+1,nb2+1);
snum2 = [];
for kb = 1:nb2
    kuse2{kb} =  find(isfinite(o2rs) & s(1,:) >= b2(kb)+1 & s(1,:) <= b2(kb+1));
    n2(kb) = length(kuse2{kb});
    snum2 = [snum2 kuse2{kb}];
end

% coefs2 = polyfit(s(1,kuse2),o2rs(kuse2),1);
% o2rsreg = polyval(coefs2,s(1,25:end));

yy2 = o2rs(snum2); yy2 = yy2(:);
V2 = zeros(length(yy2),nb2);

V2(:,1) = 1;
getfac2(:,1) = 1;

for kb = 1:nb2
    nbefore = sum(n2(1:kb-1));
    nuse = n2(kb);
    nafter = sum(n2(kb+1:nb1));
    kuse = kuse2{kb}; kuse = kuse(:);
    V2(1:nbefore,kb+1) = 0;
    V2(nbefore+1:nbefore+nuse,kb+1) = kuse-b2(kb);
    V2(nbefore+nuse+1:nbefore+nuse+nafter,kb+1) = b2(kb+1)-b2(kb);
    getfac2(kb+1:end,kb+1) = b2(kb+1)-b2(kb);
end


V2(:,2) = 0; % o1rs = a + b * s + c *(s-20) + d * (s-70) + e *(s-122); force b to be zero. 


[Q,R] = qr(V2);
coef_new2 = R\(Q'*yy2);

o2rsuse = V2*coef_new2;
o2rsuse = o2rsuse(:)';


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

form1 = [];
form2 = [];
for kb = 1:length(b1);
    form1 = [form1 '%d '];
    form2 = [form2 '%7.4f '];
end

fprintf(1,['%s ' form1 ' %s\n'],'o1rs_s = [',b1,' ];');
fprintf(1,['%s ' form2 ' %s\n'],'o1rs_f = [',getfac1out,' ];');
dform = []; for knd = 1:length(deps); dform = [dform ' %d']; end
fform = []; for knd = 1:length(deps); fform = [fform ' %7.4f']; end
fprintf(1,['%s' dform ' %s\n'],'deps = [',deps,' ];');
fprintf(1,['%s' fform ' %s\n'],'o1dfac = [',o1dfac,' ];');

fprintf(1,'\n');

form1 = [];
form2 = [];
for kb = 1:length(b2);
    form1 = [form1 '%d '];
    form2 = [form2 '%7.4f '];
end

fprintf(1,['%s ' form1 ' %s\n'],'o2rs_s = [',b2,' ];');
fprintf(1,['%s ' form2 ' %s\n'],'o2rs_f = [',getfac2out,' ];');
dform = []; for knd = 1:length(deps); dform = [dform ' %d']; end
fform = []; for knd = 1:length(deps); fform = [fform ' %7.4f']; end
fprintf(1,['%s' dform ' %s\n'],'deps = [',deps,' ];');
fprintf(1,['%s' fform ' %s\n'],'o2dfac = [',o2dfac,' ];');



