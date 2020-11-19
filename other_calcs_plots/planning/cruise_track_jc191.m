pchoose = 'tfc';
pchoose = 'nre'; % o Ovide; r Rapid; n osNap; e EEL; p PAP
pchoose = 'aone'; % o Ovide; r Rapid; n osNap; e EEL; p PAP; a AR7W
% pchoose = 'ne'; % o Ovide; r Rapid; n osNap; e EEL; p PAP; a AR7W
%t track
%f floats
%c ctds

pchoose = 'Maone'; % o Ovide; r Rapid; n osNap; e EEL; p PAP; a AR7W; M osnap moorings
pchoose = 'wXMne'; % o Ovide; r Rapid; n osNap; e EEL; p PAP; a AR7W; M osnap moorings
pchoose = 'tc'; % track and CTD
pchoose = 'tfc'; % track and CTD

% load('./topo/GMRTv3_5_201802200912topo.mat');
load('/local/users/pstar/programs/general_sw/topo_grids/topo_jc191_2020/GMRTv3_7_20200110topo_1954metres.mat');

lonlim = [-90 20];
latlim = [-20 80];



view = 'jc191_27nfs';
view = 'jc191_24nwbdy';
view = 'jc191_24n';
% view = 'jc191_24nebdy';
% view = 'jc191_floats';

switch view
    case 'rockall'
        clev = [-6000:500:500];
    otherwise
        clev = [-6000:1000:1000];
end


kuselon = find(lonlim(1) <= top.lon & top.lon <= lonlim(2));
kuselat = find(latlim(1) <= top.lat & top.lat <= latlim(2));

lon = top.lon(kuselon);
lat = top.lat(kuselat);
alt = top.altitude(kuselat,kuselon);

switch view
    case {'jc191_27nfs' 'jc191_24nwbdy' 'jc191_24nebdy' }
        sub = 1;
    case {'jc191_floats'}
        sub = 5;
    case {'jc191_24n'}
        sub = 10;
    otherwise
        sub = 20;
end

lon = lon(1:sub:end);
lat = lat(1:sub:end);
dep = alt(1:sub:end,1:sub:end);
dep(dep>0) = 100;

figure
set(gcf,'defaultaxeslinewidth',2)

axis square
grid on
% % view = 'greenland';
% % view = '60n_west';
% % % view = '60n_greenland';
% % % view = 'rockall';
% % view = '60n_all';
% % % view = 'stjohns';
% % % view = '60n_east2';
% % % view = '60n_west';
% % % view = 'jr302_c2';
% % view  = 'jc159_24s';
% % view  = 'jc159_mar';
% % view  = 'jc159_walvis';
% % % view  = 'jc159_bc';
% % view = 'jc191_24n';
% % view = 'jc191_fs';
% % % view = 'jc191_wbdy';


statlabel = 1;
% secset = [92:95 110:112 115:5:200 161 162 163 179 180 184 186 187 193:194 195 196 197 198 ]; %1:500;
secset = [0:10:100 3 4 10 11 16 21 26 29 33 67 75 110 113 114 122 123 124 125]; %1:500;
secset = [1:500];
secset = unique(secset);

switch view
    case 'all'
        yl = [-65 -30]; xl = [-55 -55];
    case 'south'
        yl = [-65 -50]; xl = [-70 -45];
    case 'shag'
        yl = [-56 -53]; xl = [-50 -50];  % only need to define mid longitude
    case 'west_pass'
        yl = [-56 -53]; xl = [-55 -55];
    case 'scotia'
        yl = [-62 -52]; xl = [-50 -50];
    case 'ghgtap'
        yl = [5 75]; xl = [-45 -45];
    case '60n_west'
        yl = [50 65]; xl = [-43 -43];
    case 'stjohns'
        yl = [45 55]; xl = [-52 -52];
    case '60n_greenland'
        yl = [56 63]; xl = [-45 -45];
    case '60n_all'
        yl = [35 70]; xl = [-30 -30];
    case 'greenland'
        yl = [55 63]; xl = [-43 -43];
    case '60n_east'
        yl = [50 65]; xl = [-20 -20];
    case '60n_east2'
        yl = [50 65]; xl = [-18 -18];
    case 'rockall'
        yl = [55 59]; xl = [-10 -10];
    case 'jr302_c1' 
        yl = [46 56]; xl = [-52 -52]; % near st johns
    case 'jr302_c2' 
        yl = [52 54]; xl = [-51 -51]; % lab exit slope
    case {'jc159_24s' 'jc159_mar' 'jc159_walvis'};
        yl = [-70 20]; xl = [-12 -12]; % jc159 24s
    case {'jc159_bc'};
        yl = [-40 -8]; xl = [-40 -40]; % jc159 24s
    case {'jc191_24n'};
        yl = [-20 50]; xl = [-85 -10]; % jc191 24n
    case {'jc191_27nfs'};
        yl = [20 30]; xl = [-82 -74]; % jc191 24n % adjust later in adjust_size
%         secset = 1:13;
    case {'jc191_24nwbdy'};
        yl = [20 30]; xl = [-82 -74]; % jc191 24n
    case {'jc191_24nebdy'};
        yl = [10 40]; xl = [-30 0]; % jc191 24n e bdy
%         secset = [14:24 26 27 28];
    case {'jc191_floats'};
        yl = [10 40]; xl = [-80 -35]; % jc191 24n e bdy
%         secset = [14:24 26 27 28];
end
if xl(1) == xl(2)
    ywid = yl(2)-yl(1);
    ymid = (yl(2)+yl(1))/2;
    xwid = ywid/cos(ymid*pi/180);
    xmid = (xl(2)+xl(1))/2;
    xl = xmid - xwid/2 + [0 xwid];
end
% bak on jc191: define xl instead of calculating it. The plot is resized
% using adjust_size.m, which sets the plotsize, xlims, and y lower lim
% The program calculates y upper lim to be mercator with xlims and defined
% plot size. So at this point, simply set xl and yl to contour the region
% required for the final plot after adjust_size.
% The angle set lower down the code will no longer be quite right, because
% it assume square mercator axes. But on jc191 it seems to be more or less
% ok. This could be fixed to work properly.


% if xl(2) > 0
%     fprintf(2,'%s\n','Attempt to select longitude greater than zero')
%     fprintf(2,'%s\n','Program needs modification')
%     fprintf(1,'%10.4f %10.4f\n',xl)
%     return
% end

kx = find(lon >= xl(1) & lon <= xl(2));
ky = find(lat >= yl(1) & lat <= yl(2));

switch view
    case 'rockall'
        clev = [-6000:500:500];
    case 'jc191_27nfs'
        clev = [-6000:1000:1000 -500 -200];
    otherwise
        clev = [-6000:1000:1000]; clev = unique(clev);
%         clev = [-6000 -5000 -4000 -3000:200:1000];
%         clev = [-2500:100:100];
end
contourf(lon(kx),lat(ky),dep(ky,kx),clev);
colorbar;
cm = 1-0.2*(1-jet(9));
colormap(cm(1:7,:));
caxis([-6000 1000]);
title_str = {'James Cook Cruise 191 '; 'Stations'};
h_title = title(title_str,'fontsize',16);
xlabel('Lon','fontsize',16); ylabel('Lat','fontsize',16);

hax = gca;
set(hax,'fontsize',16)
set(hax,'xlim',xl);
set(hax,'ylim',yl);
hold on
grid on

latn = []; lonn = [];
late = []; lone = [];

for kadd = 1:length(pchoose)
    choice = pchoose(kadd);
    switch choice
        case 't'
            % cruise track
            
            nav = '/local/users/pstar/cruise/data/nav/posmvpos/bst_jc191_01.nc';
            [d h] = mload(nav,'/');
            d.dn = datenum(h.data_time_origin)+d.time/86400;            
            
            subn = 60;
            
            x = d.long(1:subn:end);
            y = d.lat(1:subn:end);
            
            plot(x,y,'k-','linewidth',3);
            title_str = [title_str; {'Cruise track'}];
            set(h_title,'string',title_str);
        case 'f'
            % floats
            float_times = [
                %                 2018 03 14 17 13 00 % provor
                %                 2018 03 16 13 55 00 % provor
                %                 2018 03 21 12 58 00 % arvor
                %                 2018 03 24 15 45 00 % arvor
                %                 2018 03 28 11 15 00 % apex 8145 navis 0656
                %                 2018 03 31 14 16 00 % apex 8144 navis 0653
                2020 01 31 19 49 00 % deep 14
                2020 02 02 14 02 00 % deep 12
                2020 02 04 00 10 00 % deep 24
                2020 02 05 11 00 00 % deep 15
                2020 02 06 22 43 00 % deep 13
                ];
            numfloat = size(float_times,1);
            float_dn = nan+ones(numfloat);
            for kl = 1:numfloat
                float_dn(kl) = datenum(float_times(kl,:));
            end
            floatlat = interp1(d.dn,d.lat,float_dn);
            floatlon = interp1(d.dn,d.long,float_dn);
            
            for kl = 1:numfloat
                h = plot(floatlon(kl),floatlat(kl),'y^');
                set(h,'markersize',7)
                set(h,'markerfacecolor','y')
            end
            title_str = [title_str; {'Deep APEX floats (yellow triangle)'}];
            set(h_title,'string',title_str);
%             f46 = load('/local/users/pstar/cruise/data/floats/f0046_latest_positions.mat');
%             plot(f46.lon,f46.lat,'k-'); plot(f46.lon(end),f46.lat(end),'ro','markersize',7,'markerfacecolor','r');
%             f47 = load('/local/users/pstar/cruise/data/floats/f0047_latest_positions.mat');
%             plot(f47.lon,f47.lat,'k-'); plot(f47.lon(end),f47.lat(end),'ro','markersize',7,'markerfacecolor','r');
%             f48 = load('/local/users/pstar/cruise/data/floats/f0048_latest_positions.mat');
%             plot(f48.lon,f48.lat,'k-'); plot(f48.lon(end),f48.lat(end),'ro','markersize',7,'markerfacecolor','r');
%             f49 = load('/local/users/pstar/cruise/data/floats/f0049_latest_positions.mat');
%             plot(f49.lon,f49.lat,'k-'); plot(f49.lon(end),f49.lat(end),'ro','markersize',7,'markerfacecolor','r');
%             f60 = load('/local/users/pstar/cruise/data/floats/f00060_latest_positions.mat');
%             plot(f60.lon,f60.lat,'k-'); plot(f60.lon(end),f60.lat(end),'ro','markersize',7,'markerfacecolor','r');
            
%             sio_deep_solo = [
%                 24.41 -69.74
%                 24.35 -69.10
%                 21.80 -59.27
%                 26.88 -61.27
%                 28.09 -57.70
%                 ]; % latest positions 28 feb 2020
%                 plot(sio_deep_solo(:,2),sio_deep_solo(:,1),'ks','markersize',7,'markerfacecolor','r');
        
        case 'c'
            
            % tracer ctds
            use = 'psal';
            use = 'pos';
            %             dpos = mload('/noc/users/pstar/cruise/data/ctd/dcs_jc191_all_pos','/');
            %             stns = dpos.statnum;
            %             slat = dpos.lat_bot;
            %             slon = dpos.lon_bot;
            % % jc191: we keep the station summary file more or less up to date
            dpos = mload('/local/users/pstar/cruise/data/collected_files/station_summary_jc191_all','/');
            stns = dpos.statnum;
            slat = dpos.lat;
            slon = dpos.lon;
%             kcfc = load('/noc/users/pstar/cruise/data/ctd/lsamnums'); % station numbers with tracer
            kcfc = [1:999];
            numcfc = length(kcfc);
            cx = nan+ones(numcfc,1); cy = cx;
            for kl = 1:length(kcfc)
                ks = kcfc(kl);
                switch use
                    case 'psal'
                        fn = ['/local/users/pstar/cruise/data/ctd/ctd_jc191_' sprintf('%03d',ks) '_psal.nc'];
                        fprintf(1,'%s\n','Loading ',fn);
                        try
                            ch = m_read_header(fn);
                            cx(kl) = ch.longitude;
                            cy(kl) = ch.latitude;
                        catch
                            cx(kl) = nan;
                            cy(kl) = nan;
                        end
                    case 'pos'
                        kindex = find(stns == ks);
                        if ~isempty(kindex);
                            cx(kl) = slon(kindex);
                            cy(kl) = slat(kindex);
                        end
                        if ~isnan(cx(kl)); continue; end
                        fn = ['/local/users/pstar/cruise/data/ctd/ctd_jc191_' sprintf('%03d',ks) '_psal.nc'];
                        if exist(fn,'file') ~= 2; continue; end
                        fprintf(1,'%s\n','Loading ',fn);
                        ch = m_read_header(fn);
                        cx(kl) = ch.longitude;
                        cy(kl) = ch.latitude;
                end
                
            end
            
%             for kl = 1:numcfc
%                 h = plot(cx(kl),cy(kl),'ro');
%                 set(h,'markersize',4)
%                 set(h,'markerfacecolor','r')
%             end
%             title_str = [title_str; {'CTD stations (filled red circle)'}];
%             set(h_title,'string',title_str);
            
            horal = [];for kk = 1:500; horal{kk} = 'center'; end
            vertal = [];for kk = 1:500; vertal{kk} = 'middle'; end
            
            % default
            llen(1:500) = 0.02;
            lphi(1:500) = 90;
            
            
%             ko = 1; llen(ko) = 0.02; lphi(ko) = 0;
%             ko = [3 4 5 6 7 8]; llen(ko) = 0.02; lphi(ko) = [-130 -110 -90 -70 -50 -30];
%             ko = [9 10 11 12 13 14]; llen(ko) = 0.02; lphi(ko) = [155 145 130 110 90 80];
%             ko = [15 16 17 18 19]; llen(ko) = 0.02; lphi(ko) = [-135 -115 -95 -75 -55];
%             
%             ko = [20 21 22 2 23]; llen(ko) = [0.02 0.02 0.02 0.04 0.02]; lphi(ko) = [135 115 95 -30 75]; 
%             ko = [24:26]; llen(ko) = 0.02; lphi(ko) = [-20 -10 10];
%             ko = [27 28]; llen(ko) = 0.02; lphi(ko) = 0;
%             ko = [29 30]; llen(ko) = 0.02; lphi(ko) = [-10 10];
%             ko = [35 36]; llen(ko) = 0.02; lphi(ko) = [190 170];
%             ko = [37 38 39 40 41]; llen(ko) = 0.02; lphi(ko) = [180 180 173 187 180];
%             ko = [42 43 44 45 46 47]; llen(ko) = 0.02; lphi(ko) = [165 165 165 145 145 135];
%             ko = [53 52 51 50 49 48]; llen(ko) = 0.02; lphi(ko) = [45 60 75 90 105 120];
%             ko = [54:57]; llen(ko) = 0.02; lphi(ko) = 20;
%             ko = [58 59 60]; llen(ko) = 0.02; lphi(ko) = [-135 -115 -95];
%             ko = [63 64 65 66 67 68 69]; llen(ko) = 0.02; lphi(ko) = [20 20 20 170 180 185 190];
%             ko = [70]; llen(ko) = 0.015; lphi(ko) = [190];
%             ko = [77:94 110:112]; llen(ko) = 0.02; lphi(ko) = 30;
%             ko = [90 91 92]; llen(ko) = 0.02; lphi(ko) = 70;
%             ko = [93 94 110 111 ]; llen(ko) = [0.02 0.02 0.015 0.015]; lphi(ko) = [40 40 20 20];
%             ko = [61 62 71:76]; llen(ko) = 0.02; lphi(ko) = -45;
%             ko = [95:101]; llen(ko) = 0.02; lphi(ko) = -30;
%             ko = [102 103 104 105 106 107 108 109]; llen(ko) = 0.02; lphi(ko) = [5 5 5 0 10 20 -90 -100];
%             ko = [105]; llen(ko) = 0.02; lphi(ko) = 0;
%             ko = [78 77 79 80 81 82]; llen(ko) = 0.02; lphi(ko) = [100 85 70 60 45 30];
%             ko = [113:300]; llen(ko) = 0.01; lphi(ko) = 70;
%             ko = [112 115]; llen(ko) = [0.02 0.01]; lphi(ko) = [-40 30];
%             ko = [160 161]; llen(ko) = 0.01; lphi(ko) = 250;
%             ko = [130]; llen(ko) = 0.01; lphi(ko) = -90;
%             ko = [162:165]; llen(ko) = 0.03; lphi(ko) = [250 240 240 245 ];
%             ko = [166:178]; llen(ko) = 0.01; lphi(ko) = [-160];
%             ko = [179 180]; llen(ko) = 0.02; lphi(ko) = [-150 180];
%             ko = [184 185 186 187 188 ]; llen(ko) = 0.01; lphi(ko) = [ 190 190 150 80 30];
%             ko = [190 191 192 193 194 195 196 197 198]; llen(ko) = [0.01 0.01 0.01 0.03 0.03 0.01 0.01 0.02 0.01]; lphi(ko) = [0 0 0 10 -10 -5 0 0 0];
%             ko = [199 200]; llen(ko) = [0.01 0.015]; lphi(ko) = [90 50];
%             ko = [214 215 216]; llen(ko) = [0.015]; lphi(ko) = [-160 -110 -60];
%             ko = [220 225 230 234]; llen(ko) = [0.015 0.015 0.01 0.015]; lphi(ko) = [120 120 100 -145];
            ko = [1:999]; llen(ko) = 0.02; lphi(ko) = -90;
            ko = [1:13]; llen(ko) = 0.005; lphi(ko) = -90;
           
            ko = 1; llen(ko) = 0.02; lphi(ko) = -135;
            ko = 2; llen(ko) = 0.02; lphi(ko) = 160;
            ko = 3; llen(ko) = 0.02; lphi(ko) = 110;
            ko = 7; llen(ko) = 0.02; lphi(ko) = -90;
            ko = 8; llen(ko) = 0.02; lphi(ko) = -90;
            ko = 11; llen(ko) = 0.02; lphi(ko) = -80;
            ko = 12; llen(ko) = 0.02; lphi(ko) = -60;
            ko = 13; llen(ko) = 0.02; lphi(ko) = -20;
            ko = 14; llen(ko) = 0.02; lphi(ko) = 180;
            ko = 15; llen(ko) = 0.02; lphi(ko) = 125;
            ko = 16; llen(ko) = 0.02; lphi(ko) = 90;
            ko = 17; llen(ko) = 0.02; lphi(ko) = -120;
            ko = 18; llen(ko) = 0.02; lphi(ko) = -90;
            ko = 19; llen(ko) = 0.02; lphi(ko) = -60;
            ko = 20; llen(ko) = 0.02; lphi(ko) = 110;
            ko = 21; llen(ko) = 0.02; lphi(ko) = 70;
            ko = 22; llen(ko) = 0.02; lphi(ko) = -90;
            ko = 23; llen(ko) = 0.02; lphi(ko) = -90;
            ko = 24; llen(ko) = 0.02; lphi(ko) = -110;
            ko = 26; llen(ko) = 0.02; lphi(ko) = -70;
            ko = 27; llen(ko) = 0.02; lphi(ko) = -100;
            ko = 30; llen(ko) = 0.02; lphi(ko) = 90;
            ko = 33; llen(ko) = 0.02; lphi(ko) = 90;
            ko = 46; llen(ko) = 0.02; lphi(ko) = 45;
            ko = 51; llen(ko) = 0.02; lphi(ko) = -110;
            ko = 74; llen(ko) = 0.02; lphi(ko) = 110;
            ko = 90; llen(ko) = 0.02; lphi(ko) = -110;
            ko = 94; llen(ko) = 0.02; lphi(ko) = -110;
            ko = 95; llen(ko) = 0.02; lphi(ko) = 90;
            ko = 96; llen(ko) = 0.02; lphi(ko) = -70;
            ko = 100; llen(ko) = 0.02; lphi(ko) = -70;
            ko = 104; llen(ko) = 0.02; lphi(ko) = 110;
            ko = 118; llen(ko) = 0.02; lphi(ko) = -80;
            ko = 120; llen(ko) = 0.02; lphi(ko) = 110;
            ko = 125; llen(ko) = 0.02; lphi(ko) = -70;
            ko = 131; llen(ko) = 0.02; lphi(ko) = -70;
            ko = 134; llen(ko) = 0.02; lphi(ko) = -70;
            ko = 135; llen(ko) = 0.02; lphi(ko) = -50;
            
% % %             ko = 122; llen(ko) = 0.02; lphi(ko) = -110;
% % %             ko = 123; llen(ko) = 0.02; lphi(ko) = 120;
% % %             ko = 124; llen(ko) = 0.02; lphi(ko) = 90;
% % %             ko = 125; llen(ko) = 0.02; lphi(ko) = 110;
            
%             llen(15:26) = 0.06;
%             lphi(15:2:26) = 120;
%             lphi(16:2:26) = -60;
            
            for kl = 1:numcfc
                snum = kcfc(kl);                    
                if mcrange(lphi(snum),-180,180) >= -45  & mcrange(lphi(snum),-180,180) <= 45
                    horal{snum} = 'left';
                end
                if mcrange(lphi(snum),0,360) >= 135  & mcrange(lphi(snum),0,360) <= 225
                    horal{snum} = 'right';
                end
                if mcrange(lphi(snum),-180,180) > -170  & mcrange(lphi(snum),-180,180) < -10
                    vertal{snum} = 'top';
                end
                if mcrange(lphi(snum),-180,180) > 10  & mcrange(lphi(snum),-180,180) < 170
                    vertal{snum} = 'bottom';
                end
            end
            
            hlines = []; hts = [];
            
            for kl = 1:numcfc
                h = plot(cx(kl),cy(kl),'ro');
                set(h,'markersize',4)
                set(h,'markerfacecolor','r')
                snum = kcfc(kl);
                stxt = sprintf('%d',snum);
                
                if statlabel == 1
                    if isempty(find(secset == snum)); continue; end
%                     if snum > 1; continue; end
                 try
                     [hlines(snum) hts(snum)] = m_add_statnum(cy(kl),cx(kl),'r',2,llen(snum),lphi(snum),stxt,'r',10,horal{snum},vertal{snum});
                 catch
                     keyboard
                 end
                else
                end
            end
            title_str = [title_str; {'CTD stations (filled red circle)'}];
            set(h_title,'string',title_str);
            
        case 'r'
            %rapid 24n line
            a5_pos
            h = plot(lon,lat,'ro');
            set(h,'markersize',4)
            set(h,'markerfacecolor','r')
            title_str = [title_str; {'24N (filled red circle, southern line) 2015'}];
            set(h_title,'string',title_str);
        case 'o'
            %ovide line
            ovide_pos
            h = plot(lon,lat,'ko');
            set(h,'markersize',4)
            set(h,'markerfacecolor','k')
            %             title_str = [title_str; {'Ovide (filled black circle) 2014'}];
            %             set(h_title,'string',title_str);
        case 'a'
            %AR7W line
            ar07w_pos
            h = plot(lon,lat,'ko');
            set(h,'markersize',4)
            set(h,'markerfacecolor','k')
            %             title_str = [title_str; {'Ovide (filled black circle) 2014'}];
            %             set(h_title,'string',title_str);
        case 'n'
            %osnap line
            osnap_pos6
            h = plot(lon,lat,'ro');
            lonn = lon; latn = lat;
            set(h,'markersize',6)
            set(h,'markerfacecolor','r')
            %             title_str = [title_str; {'OSNAP+EEL (filled red circle, northern line) 2014'}];
            %             title_str = [title_str; {'Subpolar (filled red circle, northern line) 2014'}];
            % %             title_str = [title_str; {'17 May to 4 July 2014'}];
            set(h_title,'string',title_str);
        case 'e'
            %eel line
            eel_pos3
            h = plot(lon,lat,'ro');
            lone = lon; late = lat;
            set(h,'markersize',6)
            set(h,'markerfacecolor','r')
            %             title_str = [title_str; {'OSNAP (filled red circle, northern line) 2014'}];
            %             set(h_title,'string',title_str);
        case 'p'
            %pap site
            pap_pos
            h = plot(lon,lat,'ro');
            set(h,'markersize',4)
            set(h,'markerfacecolor','r')
            %             title_str = [title_str; {'OSNAP (filled red circle, northern line) 2014'}];
            %             set(h_title,'string',title_str);
        case 'M'
            %osnap moorings
            %             osnap_mooring_pos
            moor
            h = plot(lon,lat,'k^');
            set(h,'markersize',7)
            set(h,'markerfacecolor','k')
            %             title_str = [title_str; {'OSNAP (filled red circle, northern line) 2014'}];
            %             set(h_title,'string',title_str);
        case 'X'
            %OSNAP other suggestions
            osnap_other
            h = plot(lon,lat,'m^');
            set(h,'markersize',7)
            set(h,'markerfacecolor','m')
            %             title_str = [title_str; {'OSNAP (filled red circle, northern line) 2014'}];
            %             set(h_title,'string',title_str);
        case 'w'
            %jr302 waypoints
            jr302_waypoints
            h = plot(lon,lat,'ko');
            set(h,'markersize',6)
            set(h,'markerfacecolor','k')
            %             title_str = [title_str; {'OSNAP (filled red circle, northern line) 2014'}];
            %             set(h_title,'string',title_str);
        otherwise
            
    end
end

axis square
% grid on



% adjust_size





