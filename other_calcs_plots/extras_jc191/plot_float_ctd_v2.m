fstr = {
    '0047'
    '0048'
    '00060'
    '0046'
    '0049'
    };

ctds = [
    53
    58
    62
    66
    70
    ];

ofac = [
    1.042*1.08
    1.084*1.08
    1
    1.067*1.08
    1.069*1.08
    ];

cfac = [
    1+0.0039/35;%+0.001/35
    1+0.0027/35;%-0.000/35
    1-0.0070/35;
    1+0.0028/35;%
    1+0.0023/35;%-0.001/35
    ];

cpcor_new = nan(5,10);
cfac_new = nan(5,10);
cols = 'krcmbbbbb';

figure(1000);clf 
figure(1001);clf 
figure(1002);clf 

fs_on_theta = nan(5,10);
cs_on_theta = nan(5,1);
theta_test = 1.6;

for kl = 1:5
    fn_ctd = ['../ctd/ctd_jc191_' sprintf('%03d',ctds(kl)) '_2db.nc'];
    dc = mload(fn_ctd,'/');
    figure(100*kl+1); clf
    plot(dc.potemp,-dc.press,'k-'); hold on; grid on;
    figure(100*kl+2); clf
    plot(dc.psal,-dc.press,'k-'); hold on; grid on;
    figure(100*kl+3); clf
    plot(dc.psal,dc.potemp,'k-'); hold on; grid on;
    figure(100*kl+4); clf
    plot(dc.oxygen,-dc.press,'k-'); hold on; grid on;
    figure(100*kl+5); clf
    figure(100*kl+6); clf
    
    for kp = 1:999
        fn_f = ['f' fstr{kl} '_p_' sprintf('%03d',kp) '.mat'];
        if exist(fn_f,'file') ~= 2; continue; end
        df = load(fn_f);
        figure(100*kl+1)
        
        plot(df.ctd_cp.potemp,-df.ctd_cp.pres,'r-')
        title(fstr{kl})
        
        figure(100*kl+2)
        plot(df.ctd_cp.psal,-df.ctd_cp.pres,'r-')
        title(fstr{kl})
        
        figure(100*kl+3)
        plot(df.ctd_cp.psal,df.ctd_cp.potemp,'r-')
        title(fstr{kl})
        
        
        % now think about cpcor should redo this by interpolating CTD psal
        % onto float theta, then calculate c_expected.
        ctcor0 = 3.25e-6; % on board value
        cpcor0 = -9.57e-8; % on board value
        cpcor1 = -11.5e-8; % possible fleet value
        
        f = ones(1,1);
        
        % ctd profile
        cp = dc.press;
        ct = dc.temp2;
        cs = dc.psal2;
        cc = sw_cndr(cs,ct,cp);
        cth = dc.potemp2;
        
        % float profile
        fp = df.ctd_cp.pres;
        ft = df.ctd_cp.temp;
        fs = df.ctd_cp.psal;
        fc = sw_cndr(fs,ft,fp);
        fcraw = fc.*(1 + ft*ctcor0 + fp*cpcor0);
        fcraw = fcraw * cfac(kl); % apply a scaling calibration to raw float cond.
        fth = df.ctd_cp.potemp;
        fcnew = fcraw./(1 + ft*ctcor0 + fp*cpcor1); % candidate fc with better fleet cpcor
        
% % %         thmin = min(cth);
% % %         thmax = max(cth);
% % %         th1 = floor(thmin*100)/100;
% % %         th2 = ceil(thmax*100)/100;
% % %         thbase = th1:.01:th2;
        
        [x ksortc] = sort(cth); % sort CTD profile in order of theta
        csp = cp(ksortc); % ctd_sorted_p
        cst = ct(ksortc); % ctd_sorted_t
        css = cs(ksortc); % ctd_sprted_s
        csc = cc(ksortc);
        csth = cth(ksortc);
        
% % %         [x ksortf] = sort(fth);
% % %         fsp = fp(ksortf);
% % %         fst = ft(ksortf);
% % %         fss = fs(ksortf);
% % %         fsc = fc(ksortf);
% % %         fscraw = fcraw(ksortf);
% % %         fsth = fth(ksortf);
        
        csi = interp1(csth,css,fth); % ctd salinity interp onto float theta
        fc_expected = sw_cndr(csi,ft,fp); % cond required in float to give CTD value of S on theta
        
        fpterm = fcraw./fc_expected - 1 - ctcor0*ft; % This is the required pressure term = p*cpcor, if all the error is in cpcor
        
        kok = find(fp > 3000);
        
        p = fp(kok);
        if range(p) > 2000
            
            % profiles with 2000 dbars of profile, deeper than 3000 dbar.
            
            % we are looking for cfac and cpcor so that
            % c_expected = (craw * cfac)/(1 + t * ctcor + p * cpcor)
            % so cpcor * p - cfac * (craw/c_expected) = - (1 + t*ctocr)
            % This is a least squares problem similar to linear regression;
            % borrow QR factorisation from polyfit
            % in vector terms below
            % v * [cpcor; cfac] = b;
            
            rat = -fcraw(kok)./fc_expected(kok);
            b = -1 - ctcor0*ft(kok);
            v = [p(:)/1e8 rat(:)];
            b = b(:);
            [Q R] = qr(v);
            coefs = R\(Q'*b);
            cpcor_n = coefs(1); % cpcor * 1e8
            cfac_n = coefs(2); % best cfac for this profile;
            
            figure(100*kl+5)
            
            cpcor_est = 1e8*fpterm./fp; % crude estimate of cpcor if there is no cfac.
            % Ascribes all cond error to cpcor. If cfac has been found and
            % entered at the start of the program, this quantify will be
            % uniform in the vertical.
            
            plot(cpcor_est,-fp,[cols(kp) '-']);
            hold on; grid on;
            title(fstr{kl})
            h = gca;
            set(h,'xlim',[-20 20]);

            figure(100*kl+6)
            
            plot(35*(fc_expected./fcnew - 1),-fp,[cols(kp) '-']); hold on; grid on
            set(gca,'xlim',[-0.01 0.01])
            title(fstr{kl})
            
            
            cpcor_new(kl,kp) = cpcor_n;
            cfac_new(kl,kp) = 35*(cfac_n-1); % normalise to be approx equivalent to slainity offset.
            
            
            figure(1000)
            plot( prctile(cpcor_est(kok),[25 75]),kl+kp/10 + [0 0],'k-','linewidth',2); hold on; grid on;
            plot(cpcor_n,kl+kp/10,'r+','markersize',10); hold on; grid on;
%             plot(1000*cfac_new(kl,kp),kl+kp/10,'c+','markersize',10);
            set(gca,'ylim',[0 6]);
            set(gca,'xlim',[-15 5]);
            xlabel('Cpcor');
            ylabel('Float number + cycle number/10')
            title({'Deep APEX s/n 15,14,12,13,24';'Black line: inter-quartile range of point-by-point estimates of Cpcor';...
                'Red symbol: best fit of Cpcor and cell CNDR factor from p > 3000 dbar'})
            
            figure(1001)
            plot(cpcor_new(kl,kp),cfac_new(kl,kp),'k+'); hold on; grid on;
            
            % slope in fig 1001 is 2 in cpcor is equivalent to .0028 in
            % cfac. Could adjust points in this figure to cpcor = 11.5
            
        end
        
        fs_on_theta(kl,kp) = interp1(fth,fs,theta_test);
        cs_on_theta(kl) = interp1(csth,css,theta_test);
        
        if kl == 3; continue; end
        
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
    
    figure(1002)
    plot(1:10,fs_on_theta(kl,:),[cols(kl) '+-']); hold on; grid on;
    plot(1,cs_on_theta(kl),[cols(kl) '*']); hold on; grid on;
    plot(1,cs_on_theta(kl),'ko'); hold on; grid on;
    title('S on theta = 1.6; ''krcmb''');
    xlabel('cycle');
    
end

