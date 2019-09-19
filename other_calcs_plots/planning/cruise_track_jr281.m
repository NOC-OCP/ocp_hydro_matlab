pchoose = 'tfc';
%t track
%f floats
%c ctds
pchoose = 'tfc';



figure
set(gcf,'defaultaxeslinewidth',2)

axis square
view = 'sr1b';
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
end
ywid = yl(2)-yl(1);
ymid = (yl(2)+yl(1))/2;
xwid = ywid/cos(ymid*pi/180);
xmid = (xl(2)+xl(1))/2;
xl = xmid - xwid/2 + [0 xwid];


load('/local/users/pstar/cruise/data/jc069/planning/p2/s_atlantic')
lon = sslon(1:sub:end);
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
title_str = {'jr281: 18 Mar to 27 Apr 2013'};
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
            nav = '/local/users/pstar/jr281/data/nav/seapos/bst_jr281_01.nc';
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
            dpos = mload('/noc/users/pstar/cruise/data/ctd/dcs_jr281_all_pos','/');
            stns = dpos.statnum;
            slat = dpos.lat_bot;
            slon = dpos.lon_bot;
            kcfc = load('/noc/users/pstar/cruise/data/ctd/lsamnums'); % station numbers with tracer
            numcfc = length(kcfc);
            cx = nan+ones(numcfc,1); cy = cx;
            for kl = 1:length(kcfc)
                ks = kcfc(kl);
                switch use
                    case 'psal'
                        fn = ['/local/users/pstar/cruise/data/ctd/ctd_' MEXEC_G.MSCRIPT_CRUISE_STRING '_' sprintf('%03d',ks) '_psal.nc'];
                        fprintf(1,'%s\n','Loading ',fn);
                        ch = m_read_header(fn);
                        cx(kl) = ch.longitude;
                        cy(kl) = ch.latitude;
                    case 'pos'
                        kindex = find(stns == ks);
                        if isempty(kindex); continue; end % position not available yet
                        cx(kl) = slon(kindex);
                        cy(kl) = slat(kindex);
                    case 'both'
                        kindex = find(stns == ks);
                        if isempty(kindex);
                            %get it from psal file
                            fn = ['/local/users/pstar/cruise/data/ctd/ctd_' MEXEC_G.MSCRIPT_CRUISE_STRING '_' sprintf('%03d',ks) '_psal.nc'];
                            fprintf(1,'%s\n','Loading ',fn);
                            ch = m_read_header(fn);
                            cx(kl) = ch.longitude;
                            cy(kl) = ch.latitude;
                            continue;
                        else
                            cx(kl) = slon(kindex);
                            cy(kl) = slat(kindex);
                        end % position not available yet
                end
                
            end
            horal = [];for kk = 1:200; horal{kk} = 'center'; end
            vertal = [];for kk = 1:200; vertal{kk} = 'bottom'; end
            
            llen(1:200) = 0.06;
            lphi(1:200) = 90;
            llen(34:66) = 0.18; % orkney pass default
            lphi(34:66) = 100; % orkney pass default
            lphi(123:128) = 70; % falk trough
            llen(123:2:127) = 0.12; % falk trough
            lphi(67:92) = 10; % a23
            lphi(113:122) = 10; % abas
            lphi(2:33) = 10; % sr1b
            lphi(93:112) = 40; % ridge
            lphi(103:107) = 135; % ridge
            others = [
                66 0.36 110 % orkney pass specials
                54 0.27 107
                55 0.36 105
                56 0.36 100
                61 0.18  -80
                35 0.18 -80
                1 0.06 130 % test
                92 0.06 180 % a23
                117 0.06 30 % a23
                2 0.06 50
                3 0.12 30
                4 0.06 10
                5 0.06 150
                6 0.12 180
                7 0.06 210
                8 0.12 20
                9 0.18 10
                19 0.06 190
                22 0.06 190
                28 0.06 170
                29 0.06 60
                30 0.12 35
                31 0.06 -20
                32 0.06 180
                33 0.06 200
                102 0.06 -90
                107 0.06 -90
                108 0.06 50
                110 0.12 60
                112 0.06 90
                ];
            
            for ko = 1:size(others,1)
                llen(others(ko,1)) = others(ko,2);
                lphi(others(ko,1)) = others(ko,3);
            end
            
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