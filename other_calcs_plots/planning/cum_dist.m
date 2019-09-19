% simple prog on jc069 for cumulative distance of passing waypoints in any
% order bak 1 feb 2012

% p4 = [
%     1 -54 30 -36 30
%     2 -60 30 -38 30
%     3 -62 10 -40 00
%     4 -71 10 -20 00
%     5 -80 00 -40 00
%     6 -36 30 -36 00
%   ];

location = [
-56.17   -34.85   % 1 Monte Video
-56.1665 -54.4650 % 2 A
-50.0    -53.05   % 3 B
-39.6450 -53.9543 % 4 C
-45.5    -57.8    % 5 D
-56.1665 -54.4650 % 6 A
-58.0151 -55.5146 % 7 E
-55.4286 -59.6601 % 8 F
-53.6459 -58.0515 % 9 FSU III
-61.886  -58.014  % 10 FSU II
-65.9901 -59.9768 % 11 FSU I
-63.525  -62.857  % 12 H
-68      -60.832  % 13 I
-68      -56.5    % 14 J
-65.0    -55.0    % 15 Waypoint I
-65.0    -54.60   % 16 Waypoint II
-69.2    -52.4    % 17 Waypoint III
-70.9    -53.16 % 18 PA
-52.25974 -37.48630 % 19 032/1521
-48 -57 % 20 extra
-51-56/60 -37-50/60 % 21  waypoint
];


numl = size(location,1);

for kloop = 1:numl
    p4(kloop,1) = kloop;
    [deg min] = m_degmin_from_decdeg(location(kloop,2));
    p4(kloop,2) = deg;
    p4(kloop,3) = min;
    [deg min] = m_degmin_from_decdeg(location(kloop,1));
    p4(kloop,4) = deg;
    p4(kloop,5) = min;
end

plan = 102;
plan = input('which plan ? ')

switch plan
    case 101
        order = [19 21 2 3 4 5 2 7 8 9 10 11 12 13 14 15 ];
    case 102
        order = [19 21 4 3 2 5  9 8 7 10 11 12 13 14 15];
    case 103
        order = [19 21 4 3 2 5 9 8 7 10 12 13 11 13 14 15];
    case 104
        order = [19 21 2 3 4 5 2 7 8 9 12 13 11 13 14 10 15 ];
    otherwise
        return
end


ind = p4(:,1);
latdeg = p4(:,2);
latmin = p4(:,3);
londeg = p4(:,4);
lonmin = p4(:,5);

latsign = sign(latdeg);
lonsign = sign(londeg);

lat = (abs(latdeg)+latmin/60).*latsign;
lon = (abs(londeg)+lonmin/60).*lonsign;


numpoints = numel(order);

dist = nan+order(:); 
index = dist;
cumdist = dist;
dist(1) = 0;

for kloop = 1:numpoints
        kk = order(kloop); k = find(ind == kk);
        index(kloop) = k;
end

latall = lat(index);
lonall = lon(index);

for kloop = 2:numpoints
    dist(kloop) = sw_dist([latall(kloop-1) latall(kloop)],[lonall(kloop-1) lonall(kloop)],'nm');
    cumdist = cumsum(dist);
end

fprintf(1,'%4s %8s %8s %7s %5s %7s %5s\n','node','distance','cumdist','latdeg','min','londeg','min');

for kloop = 1:numpoints
    fprintf(1,'%4d %8.1f %8.1f %7.0f  %04.1f %7.0f  %04.1f\n',p4(index(kloop)),dist(kloop),cumdist(kloop),p4(index(kloop),2),p4(index(kloop),3),p4(index(kloop),4),p4(index(kloop),5));
end

m_figure

plot(lonall,latall,'+-')
axmerc2
hold on; grid on;
m1 = ['jc069 plan ' sprintf('%4d',plan)];
m2 = ['total dist = ' sprintf('%7.1f',cumdist(end)) ' nm'];
title({m1;m2});

plot(lon(9),lat(9),'ro');
plot(lon(10),lat(10),'ro');
plot(lon(11),lat(11),'ro');


