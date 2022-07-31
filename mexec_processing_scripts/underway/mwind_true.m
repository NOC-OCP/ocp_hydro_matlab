% mtruew_01: add smoothed nav to met wind to make true wind
% where directions are in the wind vector sense (direction to)
%
% acts on appended files; requires mbest_all to have been run first to
% generate bst_cruise_01.nc


mcruise = MEXEC_G.MSCRIPT_CRUISE_STRING;

scriptname = 'ship'; oopt = 'ship_data_sys_names'; get_cropt
root_pos = mgetdir('M_POS');
root_met = mgetdir(metpre);
infilen = fullfile(root_pos, ['bst_' mcruise '_01.nc']);
infilew = fullfile(root_met, [metpre '_' mcruise '_01.nc']);
otfile1 = fullfile(root_met, [metpre '_' mcruise '_01_true.nc']);
otfile2 = fullfile(root_met, [metpre '_' mcruise '_01_trueav.nc']);

scriptname = 'ship'; oopt = 'avtime'; get_cropt
tave_period = round(avmet);

clear dnew hnew

%wind data
[dw, hw] = mloadq(infilew, '/');

%variable names
ws = munderway_varname('rwindsvar',hw.fldnam,1,'s');
wd = munderway_varname('rwinddvar',hw.fldnam,1,'s');

%nav data
filenav = [mgetdir('M_POS') '/bst_' mcruise '_01'];
[dn, hn] = mloadq(infilen, '/'); 

%nav times in time coordinate of dw
dn.timew = m_commontime(dn.time, hn.data_time_origin, hw.data_time_origin);


%ship heading as a vector
[headav_e, headav_n] = uvsd(ones(size(dn.heading)), dn.heading, 'sduv');
%interpolate to wind file times
headav_e = interp1(dn.timew, headav_e, dw.time);
headav_n = interp1(dn.timew, headav_n, dw.time);
%back to ship heading
[~, merged_heading] = uvsd(headav_e, headav_n, 'uvsd');

%add to relative wind direction to get wind direction in degrees_to earth
%coordinates
relwind_direarth = mcrange(180+(dw.(wd)+merged_heading), 0, 360);

%vector wind relative to ship (in earth coordinates)
[relwind_e, relwind_n] = uvsd(dw.(ws), relwind_direarth,'sduv');

%ship velocity
[shipv_e, shipv_n] = uvsd(dn.smg, dn.cmg, 'sduv');

%interpolate to wind file times
shipv_e = interp1(dn.timew, shipv_e, dw.time);
shipv_n = interp1(dn.timew, shipv_n, dw.time);

%vector wind over earth
dnew.truwind_e = relwind_e + shipv_e;
dnew.truwind_n = relwind_n + shipv_n;

%speed and direction
[dnew.truwind_spd, dnew.truwind_dir] = uvsd(dnew.truwind_e, dnew.truwind_n, 'uvsd');

%save
hnew.fldnam = {'truwind_e' 'truwind_n' 'truwind_spd' 'truwind_dir'};
hnew.fldunt = {'m/s eastward' 'm/s northward' 'm/s' 'degrees_to'};
hnew.comment = sprintf('truwind calculated using %d-second average nav and heading data from %s along with %s',avnav,infilen,infilew);
copyfile(m_add_nc(infilew), m_add_nc(otfile1))
mfsave(otfile1, dnew, hnew, '-addvars');

[d, h] = mloadq(otfile1, '/');
%get rid of the variables we shouldn't average
excl = {ws wd 'truwind_dir' 'truwind_spd'};
[excl,~,iie] = intersect(excl,h.fldnam);
h.fldnam(iie) = []; h.fldunt(iie) = [];
d = rmfield(d,excl);
tg = (floor(min(d.time)/86400)*86400 - tav2):tave_period:(ceil(max(d.time)/86400)*86400+1);
clear opts
opts.ignore_nan = 1;
opts.grid_extrap = [0 0];
dg = grid_profile(d, 'time', tg, 'lfitbin', opts);
h.comment = [h.comment '\n averaged to by finding midpoint of linear fit in bins of width ' num2str(tave_period)];

%recalculate wind speed and direction from averaged vectors
[dg.truwind_spd, dg.truwind_dir] = uvsd(dg.truwind_e, dg.truwind_n, 'uvsd');
h.fldnam = [h.fldnam 'truwind_spd']; h.fldunt = [h.fldunt 'm/s'];
h.fldnam = [h.fldnam 'truwind_dir']; h.fldunt = [h.fldunt 'degrees N of E'];

%save
clear hnew
[~,ia,ib] = intersect(fieldnames(dg),h.fldnam);
hnew.fldnam = h.fldnam(ib); hnew.fldunt = h.fldunt(ib);
hnew.comment = [h.comment sprintf('\n truwind averaged over %d seconds from %s',tave_period,otfile1)];
mfsave(otfile2, dg, hnew);
