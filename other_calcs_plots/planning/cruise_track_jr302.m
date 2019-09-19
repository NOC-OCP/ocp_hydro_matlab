pchoose = 'tfc';
%t track
%f floats
%c ctds
pchoose = 'c';



figure
set(gcf,'defaultaxeslinewidth',2)

axis square
view = 'labsouth';
statlabel = 1; % 1 for adding labels, zero for not.
secset = 1:200;
switch view
    case 'all'
        yl = [-65 -30]; xl = [-55 -55]; sub = 5;
    case 'south'
        yl = [-66 -47]; xl = [-45 -45]; sub = 5;
        pchoose = 'tfc';
        secset = [];
    case 'shag'
        yl = [-55 -51]; xl = [-48 -48]; sub = 2; % only need to define mid longitude
    case 'west_pass'
        yl = [-56 -53]; xl = [-55 -55]; sub = 2;
    case 'scotia'
        yl = [-62 -52]; xl = [-50 -50]; sub = 2;
        pchoose = 'tc';
    case 'ridge'
        yl = [-55 -50]; xl = [-46 -46]; sub = 2;
        pchoose = 'tc';
        secset = [93:2:101 102 103:2:107 108:2:112];
    case 'abas'
        yl = [-53 -47]; xl = [-42 -42]; sub = 2;
        pchoose = 'tc';
        secset = 113:122;
    case 'sr1b'
        yl = [-62 -54]; xl = [-56 -56]; sub = 5;
        pchoose = 'tfc';
        secset = [2:9 10:2:28 19 29:33];
    case 'a23'
        yl = [-65 -54]; xl = [-32 -32]; sub = 2;
        pchoose = 'tc';
        secset = [67:2:91 92];
    case 'falkt'
        yl = [-55 -51]; xl = [-55 -55]; sub = 2;
        pchoose = 'tc';
        secset = [1 123:128];
    case 'ork'
        yl = [-60.8 -60.35]; xl = [-42 -42]; sub = 1;
        pchoose = 'tc';
        secset = 34:66;
    case 'labsouth'
        yl = [50 56]; xl = [-54 -48]; sub = 1;
        pchoose = 'tc';
        secset = 1:26;
end
ywid = yl(2)-yl(1);
ymid = (yl(2)+yl(1))/2;
xwid = ywid/cos(ymid*pi/180);
xmid = (xl(2)+xl(1))/2;
xl = xmid - xwid/2 + [0 xwid];


load('/local/users/pstar/cruise/data/tracks/n_atlantic')
lon = sslon(1:sub:end); lon = lon-360;
lat = sslat(1:sub:end);
dep = ssdep(1:sub:end,1:sub:end);
dep(dep>0) = 100;

kx = find(lon >= xl(1) & lon <= xl(2));
ky = find(lat >= yl(1) & lat <= yl(2));


clev = [-6000:1000:1000 -1500]; clev = unique(clev);
contourf(lon(kx),lat(ky),dep(ky,kx),clev);
colorbar;
cm = 1-0.3*(1-jet(9));
colormap(cm(1:7,:));
caxis([-6000 1000]);
% title_str = {'jc069: 31 Jan to 19 Mar 2012'};
title_str = {'jr302: 6 Jun to 22 Jul 2014'};
h_title = title(title_str,'fontsize',16);
xlabel('Lon','fontsize',16); ylabel('Lat','fontsize',16);

hax = gca;
set(hax,'fontsize',16)
hold on

for kadd = 1:length(pchoose)
    choice = pchoose(kadd);
    switch choice
        case 't'
            % cruise track

%             nav = '/local/users/pstar/jc069/data/nav/posmvpos/bst_jc069_01.nc';
            nav = '/local/users/pstar/cruise/data/nav/seapos/pos_jr302_01.nc';
            [d h] = mload(nav,'/');
            d.dn = datenum(h.data_time_origin)+d.time/86400;
%             d = mtload('posmvpos',now-100,now,'time lat long');
%             d.dn = d.time+Mtechsas_torg;

            subn = 60;

            x = d.lon(1:subn:end);
            y = d.lat(1:subn:end);

            plot(x,y,'k-','linewidth',3);
            title_str = [title_str; {'Cruise track'}];
            set(h_title,'string',title_str);
        case 'f'
            % floats
            float_times = [
                2013 03 20 08 50 00
                2013 03 20 16 15 00
                2013 03 21 11 53 00
                2013 03 22 01 20 00
                2013 03 22 17 35 00
                2013 03 24 02 06 00
                2013 03 25 23 15 00
             ];
            numfloat = size(float_times,1);
            float_dn = nan+ones(numfloat);
            for kl = 1:numfloat
                float_dn(kl) = datenum(float_times(kl,:));
            end
            floatlat = interp1(d.dn,d.lat,float_dn);
            floatlon = interp1(d.dn,d.lon,float_dn);

            for kl = 1:numfloat
                h = plot(floatlon(kl),floatlat(kl),'y^');
                set(h,'markersize',7)
                set(h,'markerfacecolor','y')
            end
            title_str = [title_str; {'APEX floats (yellow triangle)'}];
            set(h_title,'string',title_str);
        case 'c'

            % tracer ctds
%             use = 'psal';
%             use = 'pos';
            use = 'both';
%             dpos = mload('/noc/users/pstar/cruise/data/ctd/dcs_jr281_all_pos','/');
            
            xx = [
                001 140608 0858 52 00.00   49 24.01   -999  2003   99  
002 140608 2157 53 11.70   50 37.61   -999  3029   14  
003 140609 2244 52 11.01   55 33.91   -999    82    3  
004 140610 0237 52 12.89   55 20.34   -999   160    4  
005 140610 0520 52 14.50   55 07.24   -999   152    4  
006 140610 0823 52 16.14   54 54.18   -999   187    5  
007 140610 1039 52 17.77   54 41.04   -999   190    5  
008 140610 1339 52 19.37   54 28.02   -999   189    6  
009 140610 1545 52 20.98   54 14.89   -999   254    5  
010 140610 2010 52 24.24   53 48.67   -999   354    4  
011 140611 0004 52 27.42   53 22.44   -999   187    6  
012 140611 0437 52 30.62   52 56.21   -999   246    4  
013 140611 0840 52 33.89   52 29.76   -999   248    6  
014 140611 1238 52 37.09   52 03.41   -999   293    3  
015 140611 1630 52 45.32   51 42.79   -999   490    5  
016 140611 1919 52 47.70   51 36.56   -999   990    6  
017 140611 2213 52 50.93   51 28.97   -999  1477    4  
018 140612 0105 52 53.32   51 23.01   -999  2000    5  
019 140612 0724 52 59.36   51 08.17   -999  2401    9  
020 140612 1044 53 05.48   50 52.85   -999   507  100  
021 140612 1242 53 05.48   50 52.85   -999  2884    6  
022 140612 1706 53 11.67   50 37.57   -999  3147    5  
023 140612 2113 53 17.81   50 22.34   -999  3290    5  
024 140613 0355 53 24.02   50 07.11   -999  3456   10  
025 140613 0805 53 32.51   49 45.19   -999   504  100  
026 140613 1010 53 32.51   49 45.19   -999  3577   12  
];

dpos.statnum = xx(:,1);
dpos.lat_bot = xx(:,4)+xx(:,5)/60;
dpos.lon_bot = -xx(:,6)-xx(:,7)/60;
            
            
            stns = dpos.statnum;
            slat = dpos.lat_bot;
            slon = dpos.lon_bot;
            kcfc = [1:19 21:24 26];
%             kcfc = load('/noc/users/pstar/cruise/data/ctd/lsamnums'); % station numbers with tracer
            numcfc = length(kcfc);
            cx = nan+ones(numcfc,1); cy = cx;
            for kl = 1:length(kcfc)
                ks = kcfc(kl);
%                 switch use
%                     case 'psal'
%                         fn = ['/local/users/pstar/cruise/data/ctd/ctd_' MEXEC_G.MSCRIPT_CRUISE_STRING '_' sprintf('%03d',ks) '_psal.nc'];
%                         fprintf(1,'%s\n','Loading ',fn);
%                         ch = m_read_header(fn);
%                         cx(kl) = ch.longitude;
%                         cy(kl) = ch.latitude;
%                     case 'pos'
%                         kindex = find(stns == ks);
%                         if isempty(kindex); continue; end % position not available yet
%                         cx(kl) = slon(kindex);
%                         cy(kl) = slat(kindex);
%                     case 'both'
%                         kindex = find(stns == ks);
%                         if isempty(kindex);
%                             %get it from psal file
%                             fn = ['/local/users/pstar/cruise/data/ctd/ctd_' MEXEC_G.MSCRIPT_CRUISE_STRING '_' sprintf('%03d',ks) '_psal.nc'];
%                             fprintf(1,'%s\n','Loading ',fn);
%                             ch = m_read_header(fn);
%                             cx(kl) = ch.longitude;
%                             cy(kl) = ch.latitude;
%                             continue;
%                         else
                            cx(kl) = slon(ks);
                            cy(kl) = slat(ks);
%                         end % position not available yet
%                 end
%                 
            end
            horal = [];for kk = 1:200; horal{kk} = 'center'; end
            vertal = [];for kk = 1:200; vertal{kk} = 'bottom'; end
            
            llen(1:200) = 0.06;
            lphi(1:200) = 0;
            llen(2) = 0.12;
            lphi(2) = -40;
            llen(4:2:14) = 0.06;
            lphi(4:2:14) = -80;
            llen(3:2:14) = 0.06;
            lphi(3:2:14) = 100;
            llen(15:26) = 0.06;
            lphi(15:2:26) = 120;
            lphi(16:2:26) = -60;
            
% % % %             llen(34:66) = 0.18; % orkney pass default
% % % %             lphi(34:66) = 100; % orkney pass default
% % % %             lphi(123:128) = 70; % falk trough
% % % %             llen(123:2:127) = 0.12; % falk trough
% % % %             lphi(67:92) = 10; % a23
% % % %             lphi(113:122) = 10; % abas
% % % %             lphi(2:33) = 10; % sr1b
% % % %             lphi(93:112) = 40; % ridge
% % % %             lphi(103:107) = 135; % ridge
%             others = [
%                 66 0.36 110 % orkney pass specials
%                 54 0.27 107
%                 55 0.36 105
%                 56 0.36 100
%                 61 0.18  -80
%                 35 0.18 -80
%                 1 0.06 130 % test
%                 92 0.06 180 % a23
%                 117 0.06 30 % a23
%                 2 0.06 50
%                 3 0.12 30
%                 4 0.06 10
%                 5 0.06 150
%                 6 0.12 180
%                 7 0.06 210
%                 8 0.12 20
%                 9 0.18 10
%                 19 0.06 190
%                 22 0.06 190
%                 28 0.06 170
%                 29 0.06 60
%                 30 0.12 35
%                 31 0.06 -20
%                 32 0.06 180
%                 33 0.06 200
%                 102 0.06 -90
%                 107 0.06 -90
%                 108 0.06 50
%                 110 0.12 60
%                 112 0.06 90
%                 ];
%             
%             for ko = 1:size(others,1)
%                 llen(others(ko,1)) = others(ko,2);
%                 lphi(others(ko,1)) = others(ko,3);
%             end
            
            for kl = 1:numcfc
                snum = kcfc(kl);                    
                if mcrange(lphi(snum),-180,180) >= -45  & mcrange(lphi(snum),-180,180) <= 45
                    horal{snum} = 'left';
                end
                if mcrange(lphi(snum),0,360) >= 135  & mcrange(lphi(snum),0,360) <= 225
                    horal{snum} = 'right';
                end
                if mcrange(lphi(snum),-180,180) > -180  & mcrange(lphi(snum),-180,180) < 0
                    vertal{snum} = 'top';
                end
            end
            

            
            
            for kl = 1:numcfc
                h = plot(cx(kl),cy(kl),'ro');
                set(h,'markersize',4)
                set(h,'markerfacecolor','r')
                snum = kcfc(kl);
                stxt = sprintf('%d',snum);

                if statlabel == 1
                    if isempty(find(secset == snum)); continue; end
                    m_add_statnum(cy(kl),cx(kl),'r',1,llen(snum),lphi(snum),stxt,'r',10,horal{snum},vertal{snum});
                else
                end
            end
            title_str = [title_str; {'Tracer stations (filled red circle)'}];
            set(h_title,'string',title_str);
        otherwise

    end
end

axis square
grid on

psname = [MEXEC_G.MSCRIPT_CRUISE_STRING '_track_' view '.ps'];
cmd = ['print -dpsc ' psname]; eval(cmd)