function gvel = mcgeost(s,t,p,lat,lon,pref)

% function gvel = mcgeost(s,t,p,lat,lon,pref)
%
% quick-ish version of geost for jc032
% for use in mcalc
% inputs are s,t,p,lat,lon from mgridp
% pref is reference pressure
% output in cm/s, positive to right of track

lat = lat(1,:);
lon = lon(1,:);

for k = 1:size(s,2);
    % allow one shallow level to be missing; fill that level from
    % next deepest level
    if isnan(s(1,k)); s(1,k) = s(2,k); end
    if isnan(t(1,k)); t(1,k) = t(2,k); end
end

ga = sw_gpan(s,t,p);
gvel = sw_gvel(ga,lat,lon); % geost vel relative to surface

for k = 1:size(gvel,2);
    % adjust geost relative to reference pressure
    gv = gvel(:,k);
    kok = find(~isnan(gv));
    psub = p(kok,1);
    gvsub = gv(kok,1);
    puse = min(pref,max(psub)); % if pref exceeds depth of good data, use deepest common level
    g_off = interp1(psub,gvsub,puse);
%     keyboard
    gvel(:,k) = gv-g_off;
end

gvel = 100*gvel; % output in cm/s