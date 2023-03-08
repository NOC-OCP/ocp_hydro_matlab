function mtsg_merge_av(days)
% mtsg_merge_av: combine tsg and other uncontaminated seawater supply and
% surface ocean variables from multiple files, and average over 1 minute

m_common
mcruise = MEXEC_G.MSCRIPT_CRUISE_STRING;

opt1 = 'ship'; opt2 = 'ship_data_sys_names'; get_cropt
% bak jc211 ship_data_sys_names sets metpre and tsgpre

%get the files
root_dir1 = fullfile(MEXEC_G.mexec_data_root, 'met', 'ocn');
root_dir2 = fullfile(MEXEC_G.mexec_data_root, 'wnd', 'met');
f1 = dir(fullfile(root_dir1, '*_all_raw.nc'));
f2 = dir(fullfile(root_dir2, 'surfmet*_all_raw.nc'));
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

avocn = 60; %average tsg etc. data over 60 s
opt1 = 'uway_proc'; opt2 = 'avtime'; get_cropt
tave_period = round(avocn); % seconds
tav2 = round(tave_period/2);

%first figure out time grid
tmin = inf; tmax = -inf;
to = ['seconds since ' datestr(MEXEC_G.MDEFAULT_DATA_TIME_ORIGIN,'yyyy-mm-dd HH:MM:SS')];
for fno = 1:length(files)
    h = m_read_header(files{fno});
    m = strcmp('time',h.fldnam);
    tmin = min(tmin,m_commontime(h.alrlim(m),'time',h,to));
    tmax = max(tmax,m_commontime(h.uprlim(m),'time',h,to));
end
tg = floor(tmin)-tav2:tave_period:ceil(tmax)+tav2;
if ~isempty(days)
    yd = floor(tg/86400)+1;
    tg = tg(ismember(yd,days));
end
opt1 = 'mstar'; get_cropt

opt1 = 'ship'; opt2 = 'rvdas_form'; get_cropt
for fno = 1:length(files)

    %load
    [d,h] = mload(files{fno},'/');
    d.time = m_commontime(d,'time',h,to);
    %choose only selected variables from surfmet
    if sum(strfind(files{fno},'surfmet'))
        ovars = munderway_varname({'salvar' 'tempvar' 'condvar' 'sstvar' 'svelvar'}, h.fldnam, 's');
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
    opts.grid_extrap = [0 0];
    opts.postfill = 30;
    opts.bin_partial = 0;
    dg = grid_profile(d, 'time', tg, 'medbin', opts);
    dg.time = .5*(tg(1:end-1)+tg(2:end))'; %need regular time for merging, grid_profile outputs median

    %metadata and save
    clear hnew
    hnew.comment = [h.comment 'variables added from ' files{fno} '\n'];
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
    %track the source in hnew.fldin
    [~,inst,~] = fileparts(files{fno}); inst = inst(1:end-(9+length(mcruise)));
    ii = strfind(inst,'_'); 
    if npre>0 && ~isempty(ii)
        inst = inst(ii(npre)+1:end); 
    end
    hnew.fldin = repmat({inst},1,length(hnew.fldnam));
    %sort out repeated variable names
    if exist(otfile,'file')
        h = m_read_header(otfile);
        %for previously-loaded variables from this source, rename the same
        [~,ia,ib] = intersect(hnew.fldin,h.fldin,'stable'); 
        if ~isempty(ia)
            for vno = 1:length(ia)
                nold = hnew.fldnam{ia(vno)};
                nnew = h.fldnam{ib(vno)};
                dg.(nnew) = dg.(nold); dg = rmfield(dg,nold);
            end
            hnew.fldnam(ia) = h.fldnam(ib);
            dg = orderfields(dg,hnew.fldnam);
        end
        %where there is a name conflict (with a different instrument),
        %attach inst to both existing and new variables
        [~,ia,ib] = intersect(hnew.fldnam,h.fldnam,'stable');
        ia = ia(~strcmp('time',hnew.fldnam(ia)));
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
                    nnew = [nold(1:iu(1)-1) '_' h.fldin{ib(vno)}];
                    nc_varrename(ncfile.name,nold,nnew);
                end
            end
            dg = orderfields(dg,hnew.fldnam);
        end
        mfsave(otfile, dg, hnew, '-merge', 'time')
    else
        hnew.comment = [hnew.comment 'all medians over bins of width ' num2str(tave_period) '\n'];
        mfsave(otfile, dg, hnew)
    end
    for vno = 1:length(hnew.fldnam)
        if ~strcmp('time',hnew.fldnam{vno})
            nc_attput(ncfile.name,hnew.fldnam{vno},'inst',inst);
        end
    end

end

%now edit combined file
check_tsg = 1;
% opt1 = 'uway_rawedits'; get_cropt
if check_tsg
    [d, h] = mload(otfile, '/');
    d.dday = m_commontime(d,'time',h,['days since ' datestr(MEXEC_G.MDEFAULT_DATA_TIME_ORIGIN,'yyyy-mm-dd HH:MM:SS')]);
    if isempty(days)
        ds = unique(floor(d.dday));
    else
        ds = days;
    end
    iis_all = {}; n = 1;
    for dno = 1:length(ds)
        iis = find(floor(d.dday)==ds(dno));
        if ~isempty(iis)
            iis_all{n} = iis; n = n+1;
        end
    end
    d0 = d; d0 = rmfield(d0,'time');
    m = strncmp('count',h.fldunt,5);
    d0 = rmfield(d0,[h.fldnam(m) 'soundvelocity']);
    fn = fieldnames(d0);
    scale = [zeros(1,length(fn)); ones(1,length(fn))];
    edfile = fullfile(root_dir1,'editlogs','ucsw_');
    disp(fn)
    bads = gui_editpoints(d,'dday','edfilepat',edfile,'xgroups',iis_all,'scale','yes');
    if ~isempty(bads) %new edits to apply
        [d, ~] = apply_guiedits(d, 'time', [edfile '*']);
        mfsave(otfile, d, h)
    end
end
