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
[headav_e, headav_n] = uvsd(ones(size(dn.heading_av)), dn.heading_av, 'sduv');
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
%interpolate to wind file timees
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

[~, h] = mloadq(otfile1, '/');
tstart = datenum([1900 1 1])-round(tave_period/2)/86400;
tend = datenum([2100 1 1]);
torg = datenum(h.data_time_origin);
tstart_secs = round((tstart-torg)*86400);
tend_secs = round((tend-torg)*86400);
tavstring = sprintf('%13.0f %13.0f %d',tstart_secs,tend_secs,tave_period);
%--------------------------------
MEXEC_A.MARGS_IN = {
otfile1
otfile2
'/'
'1'
tavstring
'/'
};
mavrge
%--------------------------------

% % %average everything
% % [d, h] = mloadq(otfile1, '/');
% % time_edges = min(d.time)-round(tave_period/2):tave_period:1e10;
% % %recalculate wind speed and direction from averaged vectors
% % [d.truwind_spd, d.truwind_dir] = uvsd(d.truwind_e, d.truwind_n, 'uvsd');

[d, h] = mloadq(otfile2, '/');
%recalculate wind speed and direction from averaged vectors
[d.truwind_spd, d.truwind_dir] = uvsd(d.truwind_e, d.truwind_n, 'uvsd');



%save
clear hnew
hnew.fldnam = h.fldnam; hnew.fldunt = h.fldunt;
hnew.comment = sprintf('truwind averaged over %d seconds from %s',tave_period,otfile1);
mfsave(otfile2, d, hnew);
