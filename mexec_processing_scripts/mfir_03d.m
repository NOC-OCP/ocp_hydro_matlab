% mfir_03d: merge ctd downcast data onto fir file, accounting for heave:
%     first smooth and match 2 dbar up- and down-cast data on neutral
%     density, then interpolate shifted downcast data to upcast Niskin
%     firing pressures
%
% Use: mfir_03d        and then respond with station number, or for station 16
%      stn = 16; mfir_03d;

scriptname = 'castpars'; oopt = 'minit'; get_cropt
mdocshow(mfilename, ['adds CTD downcast data corresponding to upcast neutral densities at bottle firing times to fir_' mcruise '_' stn_string '.nc']);

root_ctd = mgetdir('M_CTD');
infilef = fullfile(root_ctd, ['fir_' mcruise '_' stn_string]);
otfilef = infilef;
if ~exist(infilef,'file')
    infilef = [infilef '_ctd');
end
infiled = fullfile(root_ctd, ['ctd_' mcruise '_' stn_string '_2db']); 
infileu = fullfile(root_ctd, ['ctd_' mcruise '_' stn_string '_2up']);

var_copycell = mcvars_list(2);
[var_copycell, var_copystr] = mvars_in_file(var_copycell, infiled);

%get down and up T and S on common pressure grid
[dn,h] = mloadq(infiled,'/');
[up,~] = mloadq(infileu,'/');
iigd = find(~isnan(dn.temp+dn.psal));
iigu = find(~isnan(up.temp+up.psal));
[pg,id,iu] = intersect(dn.press(iigd),up.press(iigu));
dn_psal = dn.psal(iigd(id));
dn_temp = dn.temp(iigd(id));
up_psal = up.psal(iigu(iu));
up_temp = up.temp(iigu(iu));

%call heaveND to find pressure offsets to make filtered dn T,S match up T,S
dpn = heaveND(dn_psal,dn_temp,up_psal,up_temp,pg,h.longitude,h.latitude);
%and corresponding pressures
pup = pg + dpn;

%interpolate downcast data from pup to upress
[df,hf] = mloadq(infilef,'upress',' ');
clear dnew hnew
hnew.fldnam = {}; hnew.fldunt = {};
for vno = 1:length(var_copycell)
    vmsk = strcmp(var_copycell{vno},h.fldnam);
    dnew.(['d' var_copycell{vno}]) = interp1(pup, dn.(var_copycell{vno}), df.upress);
    hnew.fldnam = [hnew.fldnam ['d' var_copycell{vno}]];
    hnew.fldunt = [hnew.fldunt hd.fldunt(vmsk)];
end
hnew.comment = 'downcast data matched on neutral density (smoothed using heaveND.m)';

%save
mfsave(otfilef, dnew, hnew, '-addvars');
