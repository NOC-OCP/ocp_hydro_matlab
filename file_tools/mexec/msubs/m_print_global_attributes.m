function m_print_global_attributes(h)

% fix by bak on jc211. The old code won't correctly show a minus zero
% latd/lond
% when hemisphere is S or W and latd or lond is zero. By making it eps, it
% should print as "-0" degrees

s = sign(h.latitude);
latd = fix(h.latitude);
latm = abs(60*(h.latitude-latd));
keps = find(latd == 0 & s < 0);
latd(keps) = -eps(180);

s = sign(h.longitude);
lond = fix(h.longitude);
lonm = abs(60*(h.longitude-lond));
keps = find(lond == 0 & s < 0);
lond(keps) = -eps(180);

disp('************************************************************************************');
disp(['Data Name :  ' h.dataname ' <version> ' sprintf('%d',h.version) ' <site> ' h.mstar_site]);
disp(['Platform :   ' h.platform_type ' | ' h.platform_identifier ' | ' h.platform_number]);
disp(['Instrument : ' h.instrument_identifier '   dpthi ' sprintf('%8.2f',h.instrument_depth_metres) '   dpthw ' sprintf('%8.2f',h.water_depth_metres)]);
% disp(['Fields :    ' sprintf('%3d',h.noflds) '     Data Cycles ' sprintf('%8d',h.norecs) '     Rows ' sprintf('%4d',h.nrows) '   Planes ' sprintf('%4d',h.nplane)]);
disp(['Position (lat lon) : '  sprintf('%10.5f',h.latitude) '  ' sprintf('%10.5f',h.longitude)]);
disp(['Position (lat lon) : '  sprintf('%4.0f %06.3f',latd,latm) ' ' sprintf('%4.0f %06.3f',lond,lonm)]);
% disp(['Time origin : ' sprintf('%02d',h.icent/100) '/' sprintf('%06d',h.iymd) '/' sprintf('%06d',h.ihms)]);
disp(['Data time origin : ' h.data_time_origin_string]);
disp(['Fields :    ' sprintf('%3d',h.noflds)]);% '     Data Cycles ' sprintf('%8d',h.norecs) '     Rows ' sprintf('%4d',h.nrows) '   Planes ' sprintf('%4d',h.nplane)]);


return
