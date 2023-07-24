% compare tsg and ctd near surface en705

stns = [1 2 3 4 5 6 7];

d45 = msload('sbe45');
t45 = d45.time;
s45 = d45.TSG2_SBE45_psal;

d21 = msload('sbe21');
t21 = d21.time;
s21 = d21.TSG1_SBE21_psal;
temp21 = d21.TSG1_SBE21_hulltemp;
% s21 = s21-.006;

twindow = 60/86400; % seconds either side

s45ddif = nan(7,0);
s45udif = nan(7,0);
s21ddif = nan(7,0);
s21udif = nan(7,0);

figure(101); clf
figure(102); clf

for kstn = stns
    stnstr = sprintf('%03d',kstn);
    fndn = ['/local/users/pstar/projects/rpdmoc/en705/mcruise/data/ctd/ctd_en705_' stnstr '_2db.nc'];
    fnup = ['/local/users/pstar/projects/rpdmoc/en705/mcruise/data/ctd/ctd_en705_' stnstr '_2up.nc'];

    [d2db h2db] = mload(fndn,'/');
    [d2up h2up] = mload(fnup,'/');

    d = d2db;
    h = h2db;

    p = d.press;
    s = d.psal;
    t = d.time/86400+datenum(h.data_time_origin);
    temp = d.temp;
    kuse = find(p==5);
    suse = s(kuse);
    tuse = t(kuse);
    tempuse = temp(kuse);
    
    k45use = find(t45 >= tuse-twindow & t45 <= tuse+twindow);
    s45use = nanmedian(s45(k45use));
    
    k21use = find(t21 >= tuse-twindow & t21 <= tuse+twindow);
    s21use = nanmedian(s21(k21use));
    temp21use = nanmedian(temp21(k21use));

     if isempty(kuse)
        tuse = [];
        suse = nan;
        tempuse = nan;
        s45use = nan;
        s21use = nan;
        temp21use = nan;
     end

     s45ddif(kstn) = suse-s45use;
     s21ddif(kstn) = suse-s21use;

    fprintf(1,'\n%2d %4s %20s %7.3f %7.3f %7.3f %7.3f %7.3f %7.3f %7.3f %7.3f\n',kstn,'down',datestr(tuse),suse,s45use,suse-s45use,s21use,suse-s21use,tempuse,temp21use,tempuse-temp21use);

    figure(101)
    plot(kstn,suse-s45use,'k+'); hold on; grid on;
    plot(kstn,suse-s21use,'r+'); hold on; grid on;
    figure(102)
    plot(kstn,tempuse-temp21use,'r+'); hold on; grid on;
    
    d = d2up;
    h = h2up;

    p = d.press;
    s = d.psal;
    t = d.time/86400+datenum(h.data_time_origin);
    temp = d.temp;
    kuse = find(p==5);
    suse = s(kuse);
    tuse = t(kuse);
    tempuse = temp(kuse);
    
    k45use = find(t45 >= tuse-twindow & t45 <= tuse+twindow);
    s45use = nanmedian(s45(k45use));
    
    k21use = find(t21 >= tuse-twindow & t21 <= tuse+twindow);
    s21use = nanmedian(s21(k21use));
    temp21use = nanmedian(temp21(k21use));

    if isempty(kuse)
        tuse = [];
        suse = nan;
        tempuse = nan;
        s45use = nan;
        s21use = nan;
        temp21use = nan;
    end

    s45udif(kstn) = suse-s45use;
    s21udif(kstn) = suse-s21use;


    fprintf(1,'%2d %4s %20s %7.3f %7.3f %7.3f %7.3f %7.3f %7.3f %7.3f %7.3f\n',kstn,'up',datestr(tuse),suse,s45use,suse-s45use,s21use,suse-s21use,tempuse,temp21use,tempuse-temp21use);

    figure(101)
    plot(kstn,suse-s45use,'ko'); hold on; grid on;
    plot(kstn,suse-s21use,'ro'); hold on; grid on;
    figure(102)
    plot(kstn,tempuse-temp21use,'ro'); hold on; grid on;

end
figure(101)
xlabel('station')
ylabel('ctd-tsg psal')
title({'EN705 CTD-TSG psal';'k: sbe45;  r: sbe21';'+ ctd start';'o ctd end'})
axis([0 8 -0.02 0.02])

figure(102)
xlabel('station')
ylabel('ctd-tsg temp')
title({'EN705 CTD-TSG temp';'r: sbe21';'+ ctd start';'o ctd end'})
axis([0 8 -0.2 0.2])