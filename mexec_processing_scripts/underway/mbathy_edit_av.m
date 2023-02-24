%edit bathymetry data (ideally by comparing two streams)
%then average each for _01 file

avfile = fullfile(root_u,'bathy','bathy_%s_av',mcruise);
mint = inf; maxt = -inf;

%load singlebeam if we have it
iss = 0;
[~,iis,~] = intersect(shortnames,{'sim' 'ea600' 'ea640' 'singleb' 'sbm' 'singlebeam_kongsberg'});
if ~isempty(iis)
    filesbin = fullfile(root_u, udirs{iis}, [shortnames{iis} '_' mcruise '_01.nc']);
    if exist(filesbin,'file')
        [ds,hs] = mload(filesbin,'/');
        ds.time = m_commontime(ds,'time',hs,MEXEC_G.MDEFAULT_DATA_TIME_ORIGN);
        hs.data_time_origin = MEXEC_G.MDEFAULT_DATA_TIME_ORIGIN;
        mint = min(mint,ds.time(1));
        maxt = max(maxt,ds.time(end));
        iss = 1;
    end
end

%load multibeam if we have it
ism = 0;
[~,iim,~] = intersect(shortnames,{'em120' 'em122' 'multib' 'mbm' 'multibeam_kongsberg_em122'});
if ~isempty(iim)
    filembin = fullfile(root_u, udirs{iim}, [shortnames{iim} '_' mcruise '_01.nc']);
    if exist(filembin,'file')
        [dm,hm] = mload(filembin,'/');
        dm.time = m_commontime(dm,'time',hs,MEXEC_G.MDEFAULT_DATA_TIME_ORIGN);
        hm.data_time_origin = MEXEC_G.MDEFAULT_DATA_TIME_ORIGIN;
        mint = min(mint,dm.time(1));
        maxt = max(maxt,dm.time(end));
        ism = 1;
    end
end

if ~iss && ~ism
    return
end

%sbvar and mbvar***
keyboard

%average to common time vector
tave_period = 5/24/60;
tg = mint-tave_period/4:tave_period:maxt+tave_period/4;
m = true(size(tg));
clear opts
opts.ignore_nan = 1;
opts.grid_extrap = [0 0];
opts.postfill = 30;
if iss
    dg = grid_profile(ds, 'time', tg, 'medbin', opts);
    mfsave(avfile, dg, hs, '-merge', 'time')
    m = m | sum(~isnan(dg.(sbvar)));
end
if ism
    dg = grid_profile(dm, 'time', tg, 'medbin', opts);
    mfsave(avfile, dg, hm, '-merge', 'time')
    m = m | sum(~isnan(dg.(mbvar)));
end
%***what about variable names?

[dg, hg] = mloadq(avfile, '/');
opt1 = mfilename; opt2 = 'bathy_grid'; get_cropt
if exist('zbathy','var') && ~isempty(zbathy)
    opt1 = 'ship'; opt2 = 'datasys_best'; get_cropt
    [dn, hn] =  mloadq(fullfile(mgetdir(default_navstream),sprintf('bst_%s_01_av',mcruise)),'/');
    %hn.data_time_orign should already be MEXEC_G.MDEFAULT_DATA_TIME_ORIGIN
    %(done in mnav_best)
    lonvar = 'lon';
    latvar = 'lat';
    lon = interp1(dn.time,dn.(lonvar),dg.time);
    lat = interp1(dn.time,dn.(latvar),dg.time);
    xbathy = [xbathy-360 xbathy]; zbathy = [zbathy zbathy];
    iix = find(xbathy>=min(lon)-1 & xbathy<=max(lon)+1);
    iiy = find(ybathy>=min(lat)-1 & ybathy<=max(lat)+1);
    dg.bathymap = interp2(xbathy(iix),ybathy(iiy),zbathy(iiy,iix),lon,lat);
end

%***take out extra variables?
keyboard

edfile = fullfile(MEXEC_G.mexec_data_root,'bathy','editlogs',sprintf('bathy_%s',mcruise));
[dg, comment] = apply_guiedits(dg, 'time', [edfile '*']);
if ~isempty(comment)
    hg.comment = [hg.comment comment];
end
t = dg.time/86400;
iis_all = {};
for no = 1:length(days)
    ii = find(t>=days(no)-1.042 & t<=days(no)+.042);
    if sum(m(ii))
        iis_all = [iis_all; ii];
    end
    %markers, lines
    %+ or -?
    bads = gui_editpoints(dg,'time','edfilepat',edfile,'xgroups',iis_all);
    keyboard
end
%apply them again
comment0 = comment;
edfile = fullfile(MEXEC_G.mexec_data_root,'bathy','editlogs',sprintf('bathy_%s',mcruise));
[dg, comment] = apply_guiedits(dg, 'time', [edfile '*']);
if isempty(comment0) && ~isempty(comment)
    hg.comment = [hg.comment comment];
end

mfsave(avfile, dg, hg);
