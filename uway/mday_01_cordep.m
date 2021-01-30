%%%%% apply carter table soundspeed correction to single-beam bathymetry %%%%%

%work on the latest file, which may already be an edited version; always output to otfile
if exist([otfile '.nc'])
    unix(['/bin/mv ' otfile '.nc ' wkfile '.nc']); infile1 = wkfile;
else
    infile1 = infile;
end

navname = MEXEC_G.default_navstream; navdir = mgetdir(navname);
navfile = [navdir '/' navname '_' mcruise '_d' day_string '_raw.nc'];
if exist(navfile)
    [dn,hn] = mload(navfile,'/'); if ~isfield(dn, 'lon'); dn.lon = dn.long; end
    lon = nanmean(dn.lon); lat = nanmean(dn.lat); clear dn hn
else
    warning(['no pos file for day ' day_string ' found, using current position to select carter area for echosounder correction'])
    if strcmp(MEXEC_G.Mshipdatasystem, 'techsas')
        pos = mtlast(navname); lon = pos.long; lat = pos.lat; clear pos
    elseif strcmp(MEXEC_G.Mshipdatasystem, 'scs')
        pos = mslast(navname); lon = pos.long; lat = pos.lat; clear pos
    end
end

calcstr = ['y = mcarter(' num2str(lat) ', ' num2str(lon) ', x1); y = y.cordep;'];
MEXEC_A.MARGS_IN = {infile1; otfile; '/'; 'depth_uncor'; calcstr; 'depth'; 'metres'; '0'};
mcalc


