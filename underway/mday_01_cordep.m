%%%%% apply carter table soundspeed correction to single-beam bathymetry %%%%%

%work on the latest file, which may already be an edited version; always output to otfile
if ~exist([otfile '.nc'],'file')
    copyfile(m_add_nc(infile1), m_add_nc(otfile));
end
[d,h] = mload(otfile,'time','depth_uncor',' ');

navname = MEXEC_G.default_navstream; navdir = mgetdir(navname);
navfile = fullfile(navdir, [navname '_' mcruise '_d' day_string '_raw.nc']);
if exist(navfile,'file')
    
    [dn,hn] = mload(navfile,'/');
    latstr = munderway_varname('latvar', hn.fldnam, 1, 's');
    lonstr = munderway_varname('lonvar', hn.fldnam, 1, 's');
    lon = dn.(lonstr);
    lat = dn.(latstr);

    dn.time = m_commontime(dn.time,hn.data_time_origin,hn.data_time_origin);
    lon = interp1(dn.time, lon, d.time);
    lat = interp1(dn.time, lat, d.time);
    
else
    warning(['no pos file for day ' day_string ' found, using current position to select carter area for echosounder correction'])
    if strcmp(MEXEC_G.Mshipdatasystem, 'techsas')
        pos = mtlast(navname); lon = pos.long; lat = pos.lat; clear pos
    elseif strcmp(MEXEC_G.Mshipdatasystem, 'scs')
        pos = mslast(navname); lon = pos.long; lat = pos.lat; clear pos
    end
end

y = mcarter(lat, lon, d.depth_uncor);
dnew.depth = y.cordep;
hnew.fldnam = {'depth'}; hnew.fldunt = {'metres'};
mfsave(otfile, dnew, hnew, '-addvars')
