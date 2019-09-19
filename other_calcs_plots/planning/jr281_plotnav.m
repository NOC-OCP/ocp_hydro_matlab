% d = msload('seatex_gll',now-8,now);
% 
% lat = d.seatex_gll_lat;
% lon = d.seatex_gll_lon;

figure

plot(lon,lat,'k');


axis([-42.4 -41.5 -60.8 -60.4]);
axmerc

hold on; grid on;

ork = load('/local/users/pstar/cruise/data/planning/orkney_pos');

ork.lon(2) = ork.lon(2)+1;
ork.lon(3) = ork.lon(3)+1;
hm = plot(ork.lon,ork.lat,'bo','markersize',10);
set(hm,'MarkerEdgeColor','b','MarkerFaceColor','b');

amp(1:200) = 0.06;
phi(1:200) = 100; % degrees anticlockwise from east
offset= [
    66 0.12 120
    54 0.09 120
    55 0.12 110
    56 0.12 100
    61 0.06  -80
    ];
for ko = 1:size(offset,1)
    amp(offset(ko,1)) = offset(ko,2);
    phi(offset(ko,1)) = offset(ko,3);
end

for kl = [36 38 39 40 45 47 48 49 52:56 60:61 64 66];
    infn = ['/local/users/pstar/cruise/data/ctd/ctd_jr281_' sprintf('%03d',kl) '_2db'];
    h = m_read_header(infn);
    
    statlat = h.latitude;
    statlon = h.longitude;
    
    hm = plot(statlon,statlat,'ro','markersize',6,'MarkerEdgeColor','r','MarkerFaceColor','r');
    
    ax = axis;
    axy = ax(4)-ax(3);
    axx = ax(2)-ax(1);
    degrad = pi/180;
    dely = amp(kl)*sin(phi(kl)*degrad)*axy;
    delx = amp(kl)*cos(phi(kl)*degrad)*axx;
    
    hline = plot([statlon statlon+delx],[statlat statlat+dely],'r-','linewidth',1);
    
    ht = text(statlon+delx,statlat+dely,sprintf('%d',kl));
    set(ht,'fontsize',10,'color','r','HorizontalAlignment','center');
    if phi(kl) >= 0  & phi(kl) <= 180
        set(ht,'fontsize',10,'color','r','VerticalAlignment','bottom');
    else
        set(ht,'fontsize',10,'color','r','VerticalAlignment','top');
    end
    
end

