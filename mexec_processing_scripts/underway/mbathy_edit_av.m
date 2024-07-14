function mbathy_edit_av(days,varargin)
%edit bathymetry data (ideally by comparing two streams)
%then average each for _01 file, with time in days

global MEXEC_G
mcruise = MEXEC_G.MSCRIPT_CRUISE_STRING;
avfile = fullfile(MEXEC_G.mexec_data_root,'bathy',sprintf('bathy_%s_av',mcruise));
uway_set_streams
mint = inf; maxt = -inf;
timun = ['days since ' datestr(MEXEC_G.MDEFAULT_DATA_TIME_ORIGIN,'yyyy-mm-dd HH:MM:SS')];
tave_period = 5/24/60;
btol = tave_period/10; %10% of spacing of gridded data

if nargin>1
    regrid = varargin{1};
else
    regrid = 1;
end

if regrid

    %load singlebeam if we have it
    iss = 0;
    [~,iis,~] = intersect(shortnames,{'sim' 'ea600' 'ea640' 'singleb' 'sbm' 'singlebeam_kongsberg'});
    if ~isempty(iis)
        filesbin = fullfile(mgetdir(shortnames{iis}), [shortnames{iis} '_' mcruise '_all_edt.nc']);
        if ~exist(filesbin,'file')
            filesbin = fullfile(MEXEC_G.mexec_data_root,'bathy','sbm',[shortnames{iis} '_' mcruise '_all_edt.nc']);
            %there should always be an _edt file because of sound speed
            %correction
        end
        if exist(filesbin,'file')
            [ds,hs] = mload(filesbin,'/');
            ds.time = m_commontime(ds, 'time', hs, timun);
            hs.fldunt{strcmp(hs.fldnam,'time')} = timun;
            hs.data_time_origin = [];
            mint = min(mint,ds.time(1));
            maxt = max(maxt,ds.time(end));
            iss = 1;
            sbvar = munderway_varname('depvar',hs.fldnam,1,'s');
            hs.fldnam{strcmp(sbvar,hs.fldnam)} = [sbvar '_sb'];
            ds.([sbvar '_sb']) = ds.(sbvar); ds = rmfield(ds,sbvar); 
            ds = orderfields(ds,hs.fldnam);
            sbvar = [sbvar '_sb'];
        end
    end

    %load multibeam if we have it
    ism = 0;
    [~,iim,~] = intersect(shortnames,{'em120' 'em122' 'multib' 'mbm' 'multibeam_kongsberg_em122'});
    if ~isempty(iim)
        filembin = fullfile(mgetdir(shortnames{iim}), [shortnames{iim} '_' mcruise '_all_edt.nc']);
        if ~exist(filembin,'file')
            filembin = fullfile(MEXEC_G.mexec_data_root,'bathy','mbm',[shortnames{iim} '_' mcruise '_all_edt.nc']);
            if ~exist(filembin,'file')
                filembin = fullfile(MEXEC_G.mexec_data_root,'bathy','mbm',[shortnames{iim} '_' mcruise '_all_raw.nc']);
            end
        end
        if exist(filembin,'file')
            [dm,hm] = mload(filembin,'/');
            dm.time = m_commontime(dm, 'time', hm, timun);
            hm.fldunt{strcmp(hm.fldnam,'time')} = timun;
            hm.data_time_origin = [];
            mint = min(mint,dm.time(1));
            maxt = max(maxt,dm.time(end));
            ism = 1;
            mbvar = munderway_varname('depvar',hm.fldnam,1,'s');
            hm.fldnam{strcmp(mbvar,hm.fldnam)} = [mbvar '_mb'];
            dm.([mbvar '_mb']) = dm.(mbvar); dm = rmfield(dm,mbvar); 
            dm = orderfields(dm,hm.fldnam);
            mbvar = [mbvar '_mb'];
        end
    end

    if ~iss && ~ism
        return
    end

    %average to common time vector
    tg = mint-tave_period/4:tave_period:maxt+tave_period/4;
    m = true(size(tg));
    clear opts
    opts.ignore_nan = 1;
    opts.grid_extrap = [0 0];
    opts.postfill = 30;
    %if exist(m_add_nc(avfile),'file')
    %    delete(m_add_nc(avfile))
    %end
    if iss
        [~,ii] = setdiff(hs.fldnam,{'time' sbvar});
        ds = rmfield(ds,hs.fldnam(ii));
        hs.fldnam(ii) = []; hs.fldunt(ii) = [];
        dg = grid_profile(ds, 'time', tg, 'medbin', opts);
        mfsave(avfile, dg, hs, '-merge', 'time')
        m = m | sum(~isnan(dg.(sbvar)));
    end
    if ism
        [~,ii] = setdiff(hm.fldnam,{'time' mbvar});
        dm = rmfield(dm,hm.fldnam(ii));
        hm.fldnam(ii) = []; hm.fldunt(ii) = [];
        dg = grid_profile(dm, 'time', tg, 'medbin', opts);
        mfsave(avfile, dg, hm, '-merge', 'time')
        m = m | sum(~isnan(dg.(mbvar)));
    end
    disp('bathy averaged')

end

[dg, hg] = mloadq(avfile, '/');
opt1 = 'uway_proc'; opt2 = 'bathy_grid'; get_cropt
if ~exist('zbathy','var')
    disp('no gridded bathymetry set in opt_cruise')
elseif ~isempty(zbathy)
    opt1 = 'ship'; opt2 = 'datasys_best'; get_cropt
    [dn, hn] =  mloadq(fullfile(mgetdir(default_navstream),sprintf('bst_%s_01_av',mcruise)),'/');
    dn.time = m_commontime(dn, 'time', hn, timun);
    %hn.data_time_orign should already be MEXEC_G.MDEFAULT_DATA_TIME_ORIGIN
    %(done in mnav_best)
    lonvar = 'lon';
    latvar = 'lat';
    lon = interp1(dn.time,dn.(lonvar),dg.time);
    lat = interp1(dn.time,dn.(latvar),dg.time);
    clear dn hn
    xbathy = [xbathy-360 xbathy]; zbathy = [zbathy zbathy];
    iix = find(xbathy>=min(lon)-1 & xbathy<=max(lon)+1);
    iiy = find(ybathy>=min(lat)-1 & ybathy<=max(lat)+1);
    dg.bathymap = interp2(xbathy(iix),ybathy(iiy),zbathy(iiy,iix),lon,lat);
end

edfile = fullfile(MEXEC_G.mexec_data_root,'bathy','editlogs',sprintf('bathy_%s',mcruise));
[dg, comment] = apply_guiedits(dg, 'time', [edfile '*'], 0, btol);
if ~isempty(comment)
    mfsave(avfile, dg, hg);
end
if ~isempty(comment)
    hg.comment = [hg.comment comment];
end
iis_all = {};
m = true(size(dg.time));
if iss && isfield(dg,sbvar)
    m = m | sum(~isnan(dg.(sbvar)));
end
if ism && isfield(dg,mbvar)
    m = m | sum(~isnan(dg.(mbvar)));
end
for no = 1:length(days)
    ii = find(dg.time>=days(no)-1.042 & dg.time<=days(no)+.042);
    if sum(m(ii))
        iis_all = [iis_all; ii];
    end
end
%markers, lines
%+ or -?
bads = gui_editpoints(dg,'time','edfilepat',edfile,'xgroups',iis_all);

%apply them again
comment0 = comment; dg0 = dg;
[dg, comment] = apply_guiedits(dg, 'time', [edfile '*'], 0, btol);
if isempty(comment0) && ~isempty(comment)
    hg.comment = [hg.comment comment];
end

mfsave(avfile, dg, hg);
