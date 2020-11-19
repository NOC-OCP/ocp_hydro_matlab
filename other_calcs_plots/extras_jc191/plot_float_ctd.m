fstr = {
    '0046'
    '0047'
    '0048'
    '0049'
    '00060'
    };

ctds = [
    66
    53
    58
    70
    62
    ];

ofac = [
    1.067
    1.042
    1.084
    1.069
    1
    ];

cfac = [
    1
    1
    1-0.000/35
    1-0.001/35
    1-.0085/35
    ];

cpcor_new = nan(5,7);
cfac_new = nan(5,7);
cols = 'krcmbbbbb';

for kl = 1:5
    fn_ctd = ['../ctd/ctd_jc191_' sprintf('%03d',ctds(kl)) '_2db.nc'];
    dc = mload(fn_ctd,'/');
    figure(100*kl+1); clf
    plot(dc.potemp,-dc.press,'k--'); hold on; grid on;
    figure(100*kl+2); clf
    plot(dc.psal,-dc.press,'k--'); hold on; grid on;
    figure(100*kl+3); clf
    plot(dc.psal,dc.potemp,'k--'); hold on; grid on;
    figure(100*kl+4); clf
    plot(dc.oxygen,-dc.press,'k--'); hold on; grid on;
    figure(100*kl+5); clf
    
    for kp = 1:999
        fn_f = ['f' fstr{kl} '_p_' sprintf('%03d',kp) '.mat'];
        if exist(fn_f,'file') ~= 2; continue; end
        df = load(fn_f);
        figure(100*kl+1)
        
        plot(df.ctd_cp.potemp,-df.ctd_cp.pres,[cols(kp) '-'])
        title(fstr{kl})
        
        figure(100*kl+2)
        plot(df.ctd_cp.psal,-df.ctd_cp.pres,[cols(kp) '-'])
        title(fstr{kl})
        
        figure(100*kl+3)
        plot(df.ctd_cp.psal,df.ctd_cp.potemp,[cols(kp) '-'])
        title(fstr{kl})
        
        
        % now think about cpcor should redo this by interpolating CTD psal
        % onto float theta, then calculate c_expected.
        ctcor = 3.25e-6;
        cpcor = -9.57e-8;
        
        f = ones(1,1);
        
        cp = dc.press;
        ct = dc.temp2;
        cs = dc.psal2;
        cc = sw_cndr(cs,ct,cp);
        cth = dc.potemp2;
        fp = df.ctd_cp.pres;
        ft = df.ctd_cp.temp;
        fs = df.ctd_cp.psal;
        fc = sw_cndr(fs,ft,fp);
        fcraw = fc.*(1 + ft*ctcor + fp*cpcor);
        fth = df.ctd_cp.potemp;
        
        thmin = min(cth);
        thmax = max(cth);
        th1 = floor(thmin*100)/100;
        th2 = ceil(thmax*100)/100;
        thbase = th1:.01:th2;
        
        [x ksortc] = sort(cth);
        csp = cp(ksortc);
        cst = ct(ksortc);
        css = cs(ksortc);
        csc = cc(ksortc);
        csth = cth(ksortc);
        
        [x ksortf] = sort(fth);
        fsp = fp(ksortf);
        fst = ft(ksortf);
        fss = fs(ksortf);
        fsc = fc(ksortf);
        fscraw = fcraw(ksortf);
        fsth = fth(ksortf);
        
        csi = interp1(csth,css,thbase);
        fcrawi = interp1(fsth,fscraw,thbase);
        fsti = interp1(fsth,fst,thbase);
        fspi = interp1(fsth,fsp,thbase);
        fsc_expected = sw_cndr(csi,fsti,fspi);
        
        fpterm = cfac(kl)*fcrawi./fsc_expected - 1 - ctcor*fsti;
        
        kok = find(fspi > 3000);
        
        p = fspi(kok);
        if range(p) > 2000
            rat = cfac(kl)*fcrawi(kok)./fsc_expected(kok);
            t = -1 - ctcor*fsti(kok);
            v = [p(:)/1e8 -rat(:)];
            t = t(:);
            [Q R] = qr(v);
            coefs = R\(Q'*t);
            cpcor_n = coefs(1);
            
            
            figure(100*kl+5)
            
            cpcor_est = 1e8*fpterm./fspi;
            
            plot(cpcor_est,-fspi,[cols(kp) '-']);
            hold on; grid on;
            title(fstr{kl})
            h = gca;
            set(h,'xlim',[-20 20]);
            %         cpcor_new(kl,kp) = nanmedian(cpcor_est(fspi>2500));
            cpcor_new(kl,kp) = cpcor_n;
            cfac_new(kl,kp) = 35*(coefs(2)-1);
            
            %         c -> c/(1+t*ctcor + p*cpcor)
            
        end
        
        
        if kl == 5; continue; end
        
        figure(100*kl+4)
        
        df.doxy.doxy = df.doxy.doxy*ofac(kl);
        
        koxbad = [];
        koxbad1 = find(df.doxy.doxy < 100); koxbad = [koxbad koxbad1(:)'];
        koxbad1 = find(df.doxy.doxy < 200 & df.doxy.pres > 2000); koxbad = [koxbad koxbad1(:)'];
        koxbad1 = find(df.doxy.doxy > 260 & df.doxy.pres > 0); koxbad = [koxbad koxbad1(:)'];
        koxbad1 = find(df.doxy.doxy < 160 & df.doxy.pres > 1200); koxbad = [koxbad koxbad1(:)'];
        koxbad1 = find(df.doxy.doxy > 240 & df.doxy.pres < 1250); koxbad = [koxbad koxbad1(:)'];
        koxbad1 = find(df.doxy.doxy > 210 & df.doxy.pres < 1100); koxbad = [koxbad koxbad1(:)'];
        koxbad1 = find(df.doxy.doxy > 190 & df.doxy.pres < 1000); koxbad = [koxbad koxbad1(:)'];
        koxbad1 = find(df.doxy.doxy > 250 & df.doxy.pres > 5000); koxbad = [koxbad koxbad1(:)'];
        df.doxy.doxy(koxbad) = nan;
        plot(df.doxy.doxy,-df.doxy.pres,'r+-')
        title(fstr{kl})
    end
    
end

