% jc191 24N 2020


fna = '/local/users/pstar/cruise/data/ctd/grid_jc191_24n.nc';
fnb = '/local/users/pstar/cruise/data/users/bak/past_cruises/grid_dy040_24n';
fnc = '/local/users/pstar/cruise/data/users/bak/past_cruises/grid_di346_24n.nc';
fnd = '/local/users/pstar/cruise/data/users/bak/past_cruises/ctd_di279_04.nc';
fne = '/local/users/pstar/cruise/data/users/bak/past_cruises/ctd_usa98_98.nc';
fnf = '/local/users/pstar/cruise/data/users/bak/past_cruises/ctd_he006_92.nc';
fng = '/local/users/pstar/cruise/data/users/bak/past_cruises/ctd_at109_81.nc';
fnh = '/local/users/pstar/cruise/data/users/bak/past_cruises/ctd_ds057_57.nc';

[da ha] = mload(fna,'/');
[db hb] = mload(fnb,'/');
[dc hc] = mload(fnc,'/');
[dd hd] = mload(fnd,'/');
[de he] = mload(fne,'/');
[df hf] = mload(fnf,'/');
[dg hg] = mload(fng,'/');
[dh hh] = mload(fnh,'/');

dd.psal = dd.salin;
dd.potemp = sw_ptmp(dd.psal,dd.temp,dd.press,0);
de.psal = de.salin;
de.potemp = sw_ptmp(de.psal,de.temp,de.press,0);
df.psal = df.salin;
df.potemp = sw_ptmp(df.psal,df.temp,df.press,0);
dg.psal = dg.salin;
dg.potemp = sw_ptmp(dg.psal,dg.temp,dg.press,0);
dh.psal = dh.salin;
dh.potemp = sw_ptmp(dh.psal,dh.temp,dh.press,0);

comp = 13; % to compare a minus b; or 13 or 23 etc

dc_2 = rem(comp,10); % second datset
dc_1 = (comp-dc_2)/10; % first dataset

allstr = 'abcdefgh';
dc1_str = allstr(dc_1);
dc2_str = allstr(dc_2);

cmd = ['d1 = d' dc1_str ';']; eval(cmd);
cmd = ['h1 = h' dc1_str ';']; eval(cmd);
cmd = ['d2 = d' dc2_str ';']; eval(cmd);
cmd = ['h2 = h' dc2_str ';']; eval(cmd);


if ~isfield(d1,'press') | ~isfield(d1,'longitude') | ~isfield(d2,'press') | ~isfield(d2,'longitude')
    fprintf(2,'\n%s\n\n','Source files must both contain both of press and longitude')
    return
end

basep = 10:20:6500; np = length(basep);
baselon = -80:.2:-10; nl = length(baselon);

% vars = {'potemp' 'psal' 'oxygen' 'botoxy' 'silc' 'phos' 'totnit' 'alk' 'dic' 'cfc11' 'cfc12' 'sf6' 'f113' 'ccl4' 'sf5cf3' 'fluor'};
vars = {'potemp' 'psal' 'oxygen' 'botoxy' 'silc' 'phos' 'totnit' 'alk' 'dic' };
% vars = {'potemp'};

for ks = 1:2
    
    switch ks
        case 1
            d = d1; h = h1;
        case 2
            d = d2; h = h2;
    end
    
    slon = d.longitude(1,:);
    
    for kv = 1:length(vars)
        
        if ~isfield(d,vars{kv}); continue; end % var doesn't exist in this file
        fprintf(1,'%s %s\n','Processing',vars{kv})
        
        cmd = ['v = d.' vars{kv} ';']; eval(cmd)
        
        vi = nan(np,nl);
        
        warning('off','MATLAB:interp1:NaNinY');
        
        for kp = 1:np
            vi(kp,:) = interp1(slon,v(kp,:),baselon);
        end
        
        switch ks
            case 1
                cmd = ['d1.' vars{kv} '_intrp = vi;']; eval(cmd)
                
            case 2
                cmd = ['d2.' vars{kv} '_intrp = vi;']; eval(cmd)
        end
        
        
    end
    
end


clear diff

diffs.press_intrp = basep;
diffs.longitude_intrp = baselon;
d1.press_intrp = basep;
d1.longitude_intrp = baselon;
d2.press_intrp = basep;
d2.longitude_intrp = baselon;
% d2.botoxy_intrp = d2.botoxy_intrp*1.03;
% d2.botoxy_intrp = d2.botoxy_intrp;

d1.oref = nanmean(d1.oxygen_intrp(190:210,:),1);
d2.oref = nanmean(d2.oxygen_intrp(190:210,:),1);
d2.oscale = d1.oref./d2.oref;
d2.oscale = filter_bak(ones(1,35),d2.oscale);
d2.oscale = repmat(d2.oscale,size(d1.oxygen,1),1);
d2.oxygen_intrp = d2.oxygen_intrp.*d2.oscale;

d1.dicref = nanmean(d1.dic_intrp(190:210,:),1);
d2.dicref = nanmean(d2.dic_intrp(190:210,:),1);
d2.dicscale = d1.dicref./d2.dicref;
d2.dicscale = filter_bak(ones(1,35),d2.dicscale);
d2.dicscale = repmat(d2.dicscale,size(d1.dic,1),1);
d2.dic_intrp = d2.dic_intrp.*d2.dicscale;

for kv = 1:length(vars)
    
    if(~isfield(d1,vars{kv}) | ~isfield(d2,vars{kv})); continue; end % var doesn't exist in both files
    
    fprintf(1,'%s %s\n','Processing',vars{kv})
    
    res = getfield(d1, [vars{kv} '_intrp']) - getfield(d2, [vars{kv} '_intrp']);
    diffs = setfield(diffs, [vars{kv} '_intrp'], res);
    
end


return

% carbon
% l1 = -14;
% l2 = 6;
l1 = -70;
l2 = -50;
p = d1.press(:,1);

d = d1;

kc = find(d.longitude(1,:) >= l1 & d.longitude(1,:) <=l2);
dic = nanmean(d.dic(:,kc),2);

kz = find(p >= 2000 & p <= 3000);
dic2000 = nanmean(dic(kz));
dicfac = 2182/dic2000;
dic = dic*dicfac;

dic1 = dic;
dic1fac = dicfac;

d = d2;

kc = find(d.longitude(1,:) >= l1 & d.longitude(1,:) <=l2);
dic = nanmean(d.dic(:,kc),2);


kz = find(p >= 2000 & p <= 3000);
dic2000 = nanmean(dic(kz));
dicfac = 2182/dic2000;
dic = dic*dicfac;

dic2 = dic;
dic2fac = dicfac;

figure(1); clf
plot(dic1,-p,'k-');
hold on; grid on
plot(dic2,-p,'r-');

figure(2); 
plot(dic1-dic2,-p,'k-');
hold on; grid on;

d1.dic_intrp_scl = d1.dic_intrp*dic1fac;
d2.dic_intrp_scl = d2.dic_intrp*dic2fac;
diffs.dic_intrp_scl = d1.dic_intrp_scl - d2.dic_intrp_scl;


return

figure
dsm = diffs.dic_intrp_scl;
w = ones(1,15);
for kl = 1:length(p)
    dsm(kl,:) = filter_bak(w,dsm(kl,:));
end
w = ones(1,11);
for kl = 1:size(dsm,2)
    dsm(:,kl) = filter_bak(w,dsm(:,kl));
end
    
contourf(d1.longitude_intrp(1,:),-p,dsm,[-16:4:24])
j40 = jet(20);
colormap([j40(1:4,:); j40(15:20,:)]);
colorbar;
caxis([-16 24]);
title('jc159 minus jc032 dic difference');


