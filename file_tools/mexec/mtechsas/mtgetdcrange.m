function [dc1 dc2 timem] = mtgetdcrange(techsasfn,dn1,dn2)
% function [dc1 dc2 timem] = mtgetdcrange(techsasfn,dn1,dn2)
%
% get range of data cycles from file techsasfn that are enclosed by (or equal to) matlab datenums dn1 and dn2 
% return time of data as matlab datenum so we don't have to read it again later

m_common

fullfn = fullfile(MEXEC_G.uway_root, techsasfn);

dns = sort([dn1 dn2]); % just in case user reverses order

timet = nc_varget(fullfn,'time'); % techsas time
timem = timet + MEXEC_G.uway_torg;
dc1 = min(find(timem >= dns(1)));
dc2 = max(find(timem <= dns(2)));

