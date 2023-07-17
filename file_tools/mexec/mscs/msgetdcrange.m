function [dc1 dc2 timem] = msgetdcrange(techsasfn,dn1,dn2)
% function [dc1 dc2 timem] = msgetdcrange(techsasfn,dn1,dn2)
%
% get range of data cycles from file techsasfn that are enclosed by (or equal to) matlab datenums dn1 and dn2 
% return time of data as matlab datenum so we don't have to read it again later
%
% 8 Sep 2009: SCS version of original techsas script, for JR195
% The searched directory is MEXEC_G.uway_root, which for example can be
% /data/cruise/jcr/20090310/scs_copy/Compress
% The var names and units are taken from ascii file
% seatex-gga.TPL
% for example.
%
% 2009-09-22 fixed at noc to work with either standard (comma delimited) or 
% sed-revised (space delimited) ACO files

m_common

opt1 = 'ship'; opt2 = 'datasys_best'; get_cropt
fullfn = [uway_sed '/' techsasfn];

dns = sort([dn1 dn2]); % just in case user reverses order

% timet = nc_varget(fullfn,'time'); % techsas time
% fullfn_mat = [fullfn(1:end-4) '.mat']; % replace .ACO with .mat
%     bak for jr195: allow different read and write dirs for scs
fullfn_mat = [uway_mat '/' techsasfn(1:end-4) '.mat']; % replace .ACO with .mat
vin_cell = load(fullfn_mat,'time_all');
timet = vin_cell.time_all; % techsas time
timem = timet + MEXEC_G.uway_torg;
dc1 = min(find(timem >= dns(1)));
dc2 = max(find(timem <= dns(2)));

