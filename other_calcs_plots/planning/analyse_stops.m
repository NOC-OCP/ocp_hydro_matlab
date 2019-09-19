    tlossall = [];
    
for kstn = 3:15
    
    if kstn == 12; continue; end
    
    cols = 'krbcm';
    cols = [cols cols cols cols cols];
    cols = [cols cols cols];
    
    stnstr = sprintf('%03d',kstn);
    
    fnwin = ['WINCH/win_jc159_' stnstr '.nc'];
    fnsam = ['sam_jc159_' stnstr '.nc'];
    
    [dwin hwin] = mload(fnwin,'/');
    [dsam hsam] = mload(fnsam,'/');
    
    
    dwin.t = datenum(hwin.data_time_origin)+dwin.time/86400;
    dsam.t = datenum(hsam.data_time_origin)+dsam.time/86400;
    
    
    nstop = length(dsam.sampnum);
    
    
    figure(102)
    
    for kl = 1:nstop
        t0 = dsam.t(kl);
        if dsam.wireout(kl) < 1000; continue; end
        t1 = t0+300/86400;
        kok = find(dwin.t > t0 & dwin.t < t1);
        
        r = -dwin.rate(kok);
        k0 = min(find(r > 0));
        t0 = dwin.t(kok(k0));
        
        dt = dwin.t(kok)-t0;
        dt = dt*86400;
        w0 = interp1(dwin.t,dwin.cablout,t0);
        dw = w0 - dwin.cablout(kok);
        
        plot(dt,dw-dt,[cols(kstn) '-'],'linewidth',2); hold on; grid on;
        
        tloss = dw-dt;
        tloss150 = interp1(dt,tloss,150);
        tlossall = [tlossall tloss150];
        
    end
    
    
    figure(103)
    
    for kl = 1:nstop
        t0 = dsam.t(kl);
        if dsam.wireout(kl) < 1000; continue; end
        t1 = t0+300/86400;
        kok = find(dwin.t > t0 & dwin.t < t1);
        
        r = -dwin.rate(kok);
        k0 = min(find(r > 0));
        t0 = dwin.t(kok(k0));
        
        
        dt = dwin.t(kok)-t0;
        dt = dt*86400;
        r = -dwin.rate(kok);
        
        plot(dt,r,[cols(kstn) '-'],'linewidth',2); hold on; grid on;
        
    end
    
    
end

figure(102)

plot([0 250],[0 -250],'k-','linewidth',2);

figure(104)

edges = [-10:10:200];

n = histc(-tlossall,edges);
bar(edges,n,'histc'); hold on; grid on;
