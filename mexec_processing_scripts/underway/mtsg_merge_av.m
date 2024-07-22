function mtsg_merge_av(days,mtable)
% mtsg_merge_av: combine tsg and other uncontaminated seawater supply and
% surface ocean variables from multiple files, and average over 1 minute

m_common
mcruise = MEXEC_G.MSCRIPT_CRUISE_STRING;

opt1 = 'ship'; opt2 = 'ship_data_sys_names'; get_cropt
% bak jc211 ship_data_sys_names sets metpre and tsgpre

%get list of files
root_dir1 = fullfile(MEXEC_G.mexec_data_root, 'met');
f1 = dir(fullfile(root_dir, '*_all_raw.nc')); %will change to _edt later if available
f2 = dir(fullfile(root_dir, 'surfmet*_all_raw.nc')); %will change to _edt later if available
%merge into "surfocean" file? (tsg+, sst/dktemp, etc.)
streams = {'surfmet' 'tsg' 'ocl' 'flowmeter' 'fluorometer' 'platform' 'thermometer' 'thermosalinograph' 'transmissometer' 'sst' 'radiometer'};
fnames1 = {f1.name};
fnames2 = {f2.name};
files = {};
for no = 1:length(streams)
    ii = find(strncmp(streams{no},fnames1,length(streams{no})));
    for sno = 1:length(ii)
        files = [files; fullfile(root_dir1,fnames1{ii(sno)})]; 
    end
    ii = find(strncmp(streams{no},fnames2,length(streams{no})));
    for sno = 1:length(ii)
        files = [files; fullfile(root_dir1,fnames1{ii(sno)})]; 
    end
end
if isempty(files)
    warning('no tsg-related files found; skipping')
    return
end
if MEXEC_G.quiet<=1
    fprintf(1,'combining surface ocean/uncontaminated seawater variables and averaging\n')
end

otfile = fullfile(root_dir1,['surf_combined_' mcruise '.nc']);
ncfile.name = otfile; %for adding attributes and renaming variables

opt1 = 'uway_proc'; opt2 = 'uway_av'; get_cropt
tave_period = round(avocn.len)/86400; % seconds --> days
tav2 = round(avocn.len/2)/86400;

%first figure out time grid, and whether there is an _edt file to start
%from
tmin = inf; tmax = -inf;
%decimal days
to = ['days since ' datestr([MEXEC_G.MDEFAULT_DATA_TIME_ORIGIN(1) 1 1 0 0 0],'yyyy-mm-dd HH:MM:SS')];
for fno = 1:length(files)
    ename = [files{fno}(1:end-6) 'edt.nc'];
    if exist(ename,'file')
        files{fno} = ename;
    end
    h = m_read_header(files{fno});
    m = strcmp('time',h.fldnam);
    tmin = min(tmin,m_commontime(h.alrlim(m),'time',h,to));
    tmax = max(tmax,m_commontime(h.uprlim(m),'time',h,to));
end
tg = floor(tmin)-tav2:tave_period:ceil(tmax)+tav2;
if ~isempty(days)
    yd = floor(tg)+1;
    tg = tg(ismember(yd,days));
end
opt1 = 'mstar'; get_cropt

opt1 = 'ship'; opt2 = 'rvdas_form'; get_cropt
for fno = 1:length(files)

    %load
    [d,h] = mload(files{fno},'/');
    if ~isfield(d,'time')
        continue
    end
    d.time = m_commontime(d,'time',h,to);
    %choose only selected variables from surfmet
    if sum(strfind(files{fno},'surfmet'))
        ovars = munderway_varname({'salvar' 'tempvar' 'condvar' 'sstvar' 'svelvar'}, h.fldnam, 's');
        if isempty(ovars)
            continue
        end
        [othervars,ii] = setdiff(h.fldnam,ovars);
        h.fldnam(ii) = []; h.fldunt(ii) = [];
        d = rmfield(d,othervars);
    end
    if ~isempty(days)
        m = d.time>=tg(1)-tave_period & d.time<=tg(end)+tave_period;
        d = struct2table(d);
        d = table2struct(d(m,:),'ToScalar',true);
    end
    %grid (median average)
    clear opts
    opts.ignore_nan = 1;
    opts.grid_extrap = [1 1];
    opts.postfill = 30;
    opts.bin_partial = 0;
    dg = grid_profile(d, 'time', tg, avocn.method, opts);
    dg.time = .5*(tg(1:end-1)+tg(2:end))'; %need regular time for merging, grid_profile outputs median

    %metadata, rename, and save
    clear hnew
    hnew.comment = ['variables added from ' files{fno} '\n'];
    hnew.fldnam = fieldnames(dg)';
    [~,ia,ib] = intersect(h.fldnam,hnew.fldnam);
    hnew.fldunt(ib) = h.fldunt(ia);
    m = strcmp('time',hnew.fldnam);
    if docf
        hnew.data_time_origin = [];
        hnew.fldunt{m} = to;
    else
        hnew.data_time_origin = MEXEC_G.MDEFAULT_DATA_TIME_ORIGIN;
        hnew.fldunt{m} = 'seconds';
    end
    %track the source in hnew.fldinst
    [~,inst,~] = fileparts(files{fno}); 
    inst = inst(1:end-(9+length(mcruise)));
    ii = strfind(inst,'_');
    if npre>0 && ~isempty(ii)
        inst = inst(ii(npre)+1:end);
        ii = strfind(inst,'_');
        if length(ii)>2
            inst = inst([1:ii(1)-1 ii(3):end]);
        end
    end
    hnew.fldinst = repmat({inst},1,length(hnew.fldnam));
    hnew.fldinst(strcmp('time',hnew.fldnam)) = {' '};
    %sort out repeated variable names
    if exist(otfile,'file')
        h = m_read_header(otfile);
        %potential new names combining name and inst
        ni = cellfun(@(x,y) [y '_' x],hnew.fldinst,hnew.fldnam,'UniformOutput',false);
        %rename any that have been renamed this way before
        [~,ii] = intersect(ni,h.fldnam,'stable');
        for vno = 1:length(ii)
            dg.(ni{ii(vno)}) = dg.(hnew.fldnam{ii(vno)});
            dg = rmfield(dg,hnew.fldnam{ii(vno)});
        end
        hnew.fldnam(ii) = ni(ii);
        dg = orderfields(dg,hnew.fldnam);
        %where there is a name conflict (with a different instrument),
        %attach inst to both existing and new variables
        [~,ia,ib] = intersect(hnew.fldnam,h.fldnam,'stable');
        m = ~strcmp('time',hnew.fldnam(ia)) & ~strcmp(hnew.fldinst(ia),h.fldinst(ib));
        ia = ia(m); ib = ib(m);
        if ~isempty(ia)
            for vno = 1:length(ia)
                nold = hnew.fldnam{ia(vno)};
                if ~strcmp(nold,'time') %time is always the same (set above)
                    %rename new one (in dg and hnew)
                    iu = strfind(nold,'_'); 
                    if isempty(iu); iu = length(nold)+1; end
                    nnew = [nold(1:iu(1)-1) '_' inst];
                    dg.(nnew) = dg.(nold); dg = rmfield(dg,nold);
                    hnew.fldnam{ia(vno)} = nnew;
                    %rename existing one (in file)
                    nold = h.fldnam{ib(vno)};
                    iu = strfind(nold,'_'); 
                    if isempty(iu); iu = length(nold)+1; end
                    nnew = [nold(1:iu(1)-1) '_' h.fldinst{ib(vno)}];
                    nc_varrename(ncfile.name,nold,nnew);
                end
            end
            dg = orderfields(dg,hnew.fldnam);
        end
        hnew.fldinst(strcmp('time',hnew.fldnam)) = {' '};
        mfsave(otfile, dg, hnew, '-merge', 'time')
    else
        hnew.comment = [hnew.comment 'all medians over bins of width ' num2str(tave_period) '\n'];
        mfsave(otfile, dg, hnew)
    end

end

%now edit combined file
minflow = 0.4; pdel = 4; %pump rate, and how long after pumps back on to nan
check_tsg = 0;
opt1 = 'uway_proc'; opt2 = 'tsg_avedits'; get_cropt
pdel = round(pdel);
if ~isempty(minflow) && exist(m_add_nc(otfile),'file')
    [d, h] = mload(otfile, '/');
    fvar = munderway_varname('flowvar',h.fldnam,1,'s');
    if ~isempty(fvar)
        vars = setdiff(h.fldnam,{fvar 'time' 'ucsw_hoist'});
        m = d.(fvar)<minflow;
        if sum(m)
            iip = find(m);
            iip = repmat([0:pdel],length(iip),1) + repmat(iip(:),1,pdel+1);
            iip = unique(iip(iip<length(d.(fvar))));
            for vno = 1:length(vars)
                d.(vars{vno})(iip) = NaN;
            end
        end
        mfsave(otfile, d, h)
    end
end
if check_tsg
    [d, h] = mload(otfile, '/');
    if isempty(days)
        ds = unique(floor(d.time));
    else
        ds = days;
    end
    iis_all = {}; n = 1;
    for dno = 1:length(ds)
        iis = find(floor(d.time)==ds(dno));
        if ~isempty(iis)
            iis_all{n} = iis; n = n+1;
        end
    end
    d0 = d;
    m = strncmp('count',h.fldunt,5);
    vars_exclude = {'soundvelocity' 'flowrate' 'calculatedbeam' 'salinity' 'psal'};
    vars_exclude = [vars_exclude 'soundvelocity_raw' 'flowrate_raw' 'calculatedbeam_raw' 'salinity_raw' 'psal_raw'];
    vr = intersect(h.fldnam, vars_exclude); 
    d0 = rmfield(d0,[h.fldnam(m) vr]);
    fn = fieldnames(d0);
    edfile = fullfile(root_dir1,'editlogs',tsgpre);
    [d0, ~] = apply_guiedits(d0, 'time', [edfile '*'], 0, tav2);
    bads = gui_editpoints(d0,'time','edfilepat',edfile,'xgroups',iis_all);
    if ~isempty(bads) %new edits to apply
        [d, ~] = apply_guiedits(d, 'time', [edfile '*'], 0, tav2);
        mfsave(otfile, d, h)
    end
end
