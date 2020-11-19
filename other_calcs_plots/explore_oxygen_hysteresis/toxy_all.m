clear do1 do2
for kl = 1:145
    
    
    if mod(kl,10) == 0; fprintf(1,'%s %d\n','kl = ',kl); end
    
    stn = kl;
    stnstr = sprintf('%03d',stn);
    fnctd = ['ctd_dy040_' stnstr '_24hz.nc'];
    fndcs = ['dcs_dy040_' stnstr '.nc'];
    
    if (exist(fnctd,'file') ~=2 ) | ( exist(fndcs,'file') ~= 2)
        continue
    end
    
    
    d = mload(fnctd,'time press oxygen_sbe1 oxygen_sbe2 scan ',' ');
    dcs = mload(fndcs,'/');
    
    scanbot = dcs.scan_bot;
    kdown = find(d.scan < scanbot & d.scan>dcs.scan_start);
    kup = find(d.scan > scanbot & d.scan < dcs.scan_end);
    kok = find(d.scan > dcs.scan_start & d.scan < dcs.scan_end);
    
    for sensor = 1:2
        
        
        
        % hyst_pars1 = [-0.033 5000 1450]; %sbe default
        hyst_pars1 = [-0.045 5000 1450]; %
        
        H1 = hyst_pars1(1) + zeros(size(d.oxygen_sbe1));
        H2 = hyst_pars1(2) + zeros(size(d.oxygen_sbe1));
        H3 = hyst_pars1(3) + zeros(size(d.oxygen_sbe1));
        
        clear resid resid_out hyst_out
        
        % d.oxygen1 = d.oxygen_sbe1+nan;
        iset = 0;
                
        switch sensor
            case 1 % primary, all sations so far
                %         hyst_pars1 = [-0.045 5000 1450]; %
                d.oxygen_sbe = d.oxygen_sbe1;
                h3tab =[
                    -10 300
                    1000 300
%                     1001 1500
%                     3000 1500
                    1001 1000
                    2000 1000
                    2001 1200
                    3000 1200
                    3001 2000
                    4000 2000
                    4001 3500
                    5000 3500
                    5001 4000
                    7000 4000
                    ];
            case 2 % secondary
                %         hyst_pars1 = [-0.045 5000 1450]; %
                d.oxygen_sbe = d.oxygen_sbe2;
                h3tab =[
                    -10 300
                    1000 300
                    1001 900
                    2000 900
                    2001 2000
                    3000 2000
                    3001 3000
                    4000 3000
                    4001 3900
                    5000 3900
                    7000 5000
                    ];
            otherwise
        end
        
        H3 = interp1(h3tab(:,1),h3tab(:,2),d.press);
        
        
        d.oxygen = d.oxygen_sbe1+nan;
        
        
        [d.oxygen(kok) C(kok) D(kok)] =mcoxyhyst(d.oxygen_sbe(kok),d.time(kok),d.press(kok),H1(kok),H2(kok),H3(kok),0);
        
        
        
        pbase = 1:7000;
        
        pdown = d.press(kdown);
        oxydown = d.oxygen(kdown);
        knan = find(isnan(pdown));
        pdown(knan) = [];
        oxydown(knan) = [];
        
        pup = d.press(kup);
        oxyup = d.oxygen(kup);
        knan = find(isnan(pup));
        pup(knan) = [];
        oxyup(knan) = [];
        
        [pdsort kd] = unique(pdown);
        odsort = oxydown(kd);
        [pusort ku] = unique(pup);
        ousort = oxyup(ku);

        
        
        
        d.oxdown = interp1(pdsort,odsort,pbase);
        d.oxup = interp1(pusort,ousort,pbase);
        d.oxupdown = d.oxup-d.oxdown;
        
        switch sensor
            case 1
                do1(kl).press = pbase;
                do1(kl).oxupdown = d.oxupdown;
            case 2
                do2(kl).press = pbase;
                do2(kl).oxupdown = d.oxupdown;
                
        end
        
        
        
        
%         close all
%         figure
%         
%         plot(d.press(kdown),d.oxygen_sbe(kdown),'k-','linewidth',2);
%         hold on; grid on;
%         plot(d.press(kup),d.oxygen_sbe(kup),'m-','linewidth',2);
%         
%         plot(d.press(kdown),d.oxygen_sbe(kdown)./D(kdown),'g-');
%         hold on; grid on;
%         plot(d.press(kup),d.oxygen_sbe(kup)./D(kup),'b-');
%         
%         plot(d.press(kdown),d.oxygen(kdown),'r-');
%         plot(d.press(kup),d.oxygen(kup),'c-');
%         
%         
%         plot(d.press(kok),200+400*(1-D(kok)),'k');
        
    end
    
    
end
