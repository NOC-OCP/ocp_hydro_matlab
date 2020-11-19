stats = [40:90];

numstat = length(stats);

[dsam hsam] = mload('sam_jc191_all','/');
figure(301); clf

plim = 2000;
fac = [];
pre = [];

ctcor = 3.25e-6;
cpcor1 = -9.57e-8;
cpcor2 = -9.57e-8 + 1*1.1429e-08;

for ks = 1:numstat
    stn = stats(ks);
    stn_str = sprintf('%03d',stn);
    fnctd = ['ctd_jc191_' stn_str '_2db.nc'];
    [dctd hctd] = mload(fnctd,'/');
    p = dctd.press;
    s = dctd.psal2;
    c = dctd.cond2;
    f1 = [1 2 3 2 1];
    filt = [-f1 0 f1];
    nfilt = length(filt);
    nhalf = (nfilt-1)/2;
    dp = filter_bak_nonorm(filt,p); dp(1:nhalf) = nan; dp(end+1-nhalf:end) = nan;
    ds = filter_bak_nonorm(filt,s); ds(1:nhalf) = nan; ds(end+1-nhalf:end) = nan;
    dsdp = ds./dp;
    f2 = ones(1,11);
    dsdp = filter_bak(f2,dsdp);
    
    kuse = find(dsam.statnum == stn);
    
    us = dsam.upsal2(kuse);
    ut = dsam.utemp2(kuse);
    up = dsam.upress(kuse);
    uc = dsam.ucond2(kuse);
    ubs = dsam.botpsal(kuse);
    ubc = sw_c3515*sw_cndr(ubs,ut,up); % botcond
    
    udsdp = interp1(p,dsdp,up);
    coef = 5;
    uc2 = sw_c3515*sw_cndr(us + coef*udsdp,ut,up)*(1+(0.0022 + 1*.0017)/35);
    
    uc3 = uc2.*(1+ut*ctcor+up*cpcor1)./(1 + ut * ctcor + up * cpcor2);
    
    uctd = uc3;
    
    bcuc = ubc./uc;
    bcuc2 = ubc./uctd;
    plot((bcuc-1)*35000,-up,'w+'); hold on; grid on
    plot((bcuc2-1)*35000,-up,'k+'); hold on; grid on
    set(gca,'xlim',[-40 40]);
    
    ksub = find(up > 2000 & (bcuc2-1)*35000 < 100);
    
    fac = [fac; (bcuc2(ksub)-1)*35000];
    pre = [pre; up(ksub)];
        
end

pp = polyfit(pre/1000,fac,1);
ffit = polyval(pp,[000 6]);
plot(ffit,-[000 6000],'r-');

