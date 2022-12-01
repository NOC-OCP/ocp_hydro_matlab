function status = mout_csv(in, out)
% status = mout_csv(in, out)
%
% write selected data from mstar file(s) to csv, optionally bin-averaging,
% changing time coordinate, and/or computing additional variables
%
% in is a structure with fields:
%   type: 'sam' or 'ctd'
%   stnlist (optional): list of stations to include/loop through (defaults
%     to all)
%
% out is a structure with fields:
%   type: 'mstar' to keep mstar variable names and include mstar file
%     global attributes in header, or 'exch' to use exchange-format
%     parameter names and header information
%   csvpre: prefix, including path for output csv file(s)
%   vars_units (optional): Nx1 or Nx4 cell array containing list of
%   variables to write (see m_exch_varlist.m)
%   extras (optional): structure giving values of variables not in (or
%   calculated from) file to be repeated on every row (e.g. expocode)
%   header (optional): cell array or string (possibly containing '\n') to
%     print at top of file (before additional header information depending
%     on file type)
%   bin_size (only used if in.type=='ctd'): integer scalar (default 2)
%   bin_units (only used if in.type=='ctd'): 'dbar', 'm', or 'hz' (default
%     dbar)
%   bin_prof (only used if in.type=='ctd' & out.bin_units is 'm' or 'hz'):
%     'down' or 'up' to average down (default) or upcast
%   time_units (optional, only used if out.type=='mstar'): CF-format time
%     unit string, e.g. 'days since 1900-01-01' or 'seconds since
%     2022-07-30'
%


m_common; mcruise = MEXEC_G.MSCRIPT_CRUISE_STRING;
status = 0;

if isfield(out,'header') && ischar(out.header)
    out.header = {out.header};
end

%files to load
if strcmp(in.type, 'sam')
    issam = 1;
    klist = 0;
    dobin = 0;
else
    issam = 0;
    dobin = 0;
    if ~isfield(out,'bin_size') || (out.bin_size==2 && strcmp(out.bin_units,'dbar'))
        in.suf = '_2db';
    elseif out.bin_size==1 && strcmp(out.bin_units,'hz')
        in.suf = '_psal';
    else
        in.suf = '_24hz';
        if out.bin_size~=24 || ~strcmp(out.bin_units,'hz')
            dobin = 1;
        end
    end
    if isfield(in,'stnlist')
        klist = in.stnlist(:)';
    else
        %all available stations
        d = dir(fullfile(mgetdir(in.type),sprintf('%s_%s_*%s.nc',in.type,mcruise,in.suf)));
        d = replace({d.name},[in.type '_' mcruise '_'],'');
        d = cell2mat(d(:));
        klist = str2num(d(:,1:3))';
    end
end

%indicative variable
if issam
    timvar = 'utime';
    dvar = 'udepth';
    pvar = 'upress';
    lvar = 'ulatitude';
else
    timvar = 'time';
    dvar = 'depth';
    pvar = 'press';
    lvar = 'latitude';
end

%fields to list in header
if strcmp(out.type,'exch')
    isw = 1;
else
    isw = 0;
    %these are already in h
    varsh = {'mstar_string', '%s', ' '
        'dataname', '%s', ' '
        'version', '%d', ' '
        'platform_type', '%s', ' '
        'platform_identifier', '%s', ' '
        'platform_number', '%s', ' '
        'water_depth_metres', '%d', ' '
        'latitude', '%9.5f', ' '
        'longitude', '%9.5f', ' '
        'comment', '%s', ' '
        'last_update_string', '%s', ' '};
    varsh = varsh(:,[1 3 1 2]);
    if issam
        %no header depth, lat, lon for multi-station file
        varsh = varsh([1:6 10:11],:);
    end
end

for kloop = klist
    
    tic
    %load file
    if ~issam
        stn = kloop;
        scriptname = 'castpars'; oopt = 'minit'; get_cropt
        fname = sprintf('%s_%s_%s%s.nc',in.type,mcruise,stn_string,in.suf);
    else
        fname = sprintf('%s_%s_all.nc',in.type,mcruise);
    end
    infile = fullfile(mgetdir(in.type),fname);
    if ~exist(infile,'file')
        infile = fname;
        if ~exist(infile,'file')
            warning('skipping %s',fname)
            continue
        end
    end
    [d, h] = mloadq(infile, '/');
    toc
    
    
    %%% add/convert variables %%%
    
    %truncate
    if ~issam && (strcmp(in.suf,'_24hz') || strcmp(in.suf,'_psal'))
        dfile = fullfile(mgetdir(in.type),sprintf('dcs_%s_%s.nc',mcruise,stn_string));
        dd = mloadq(dfile,'statnum scan_start scan_bot scan_end ');
        if isfield(out,'bin_units') && strcmp(out.bin_units,'hz')
            in.iiav = find(d.scan>=dd.scan_start(dd.statnum==stnlocal)&d.scan<=dd.scan_end(dd.statnum==stnlocal));
        elseif isfield(out,'bin_prof') && strcmp(out.bin_prof,'up')
            in.iiav = find(d.scan>=dd.scan_bot(dd.statnum==stnlocal)&d.scan<=dd.scan_end(dd.statnum==stnlocal));
        else
            in.iiav = find(d.scan>=dd.scan_start(dd.statnum==stnlocal)&d.scan<=dd.scan_bot(dd.statnum==stnlocal));
        end
        fn = fieldnames(d);
        for fno = 1:length(fn)
            dg.(fn{fno}) = d.(fn{fno})(in.iiav);
        end
        d = dg;
    end   
    
    %average
    if dobin
        disp('binning')
        switch out.bin_units
            case 'hz'
                tg = [d.time(1):d.time(end)+out.bin_size*24];
                if size(d.time,1)>1; tg = tg'; end
                d = grid_profile(d, 'time', tg, 'meannum', 'num', out.bin_size*24, 'grid_extrap', [0 0]);
            case 'dbar'
                pg = [0:out.bin_size:1e4]';
                d = grid_profile(d, 'press', pg, 'lfitbin', 'grid_extrap', [0 0]);
            case 'm'
                zg = [0:out.bin_size:1e4]';
                d = grid_profile(d, 'depth', zg, 'lfitbin', 'grid_extrap', [0 0]);
        end
    end
    
    %flags and missing data values
    if issam
        d = hdata_flagnan(d,'nanval',[NaN -999],'addflags',0,'keepemptysamps',0);
    else
        d = hdata_flagnan(d,'nanval',[NaN -999],'keepemptysamps',0);
        h.comment = [h.comment '\n default flags used'];
        scriptname = 'mout_exch'; oopt = 'woce_ctd_flags'; get_cropt
    end
    
    %(constant) station positions and depths
    if isw && issum
        d = get_station_constants(d, mcruise);
    end
    
    %convert time units
    if isfield(out,'time_units')
        d.(timvar) = m_commontime(d.(timvar),h.data_time_origin,out.time_units);
    else
        out.time_units = sprintf('seconds since %s 00:00:00',datestr(h.data_time_origin,'yyyy-mm-dd'));
    end
    m = strcmp(timvar,h.fldnam); h.fldunt{m} = out.time_units;
    
    %pressure to depth
    if isfield(out,'vars_units')
        if sum(strcmpi(dvar,out.vars_units(:,1))) && ~isfield(d,dvar)
            d.(dvar) = sw_dpth(d.(pvar),d.(lvar));
            h.fldnam = [h.fldnam 'depth']; h.fldunt = [h.fldunt 'm'];
        end
        if sum(strcmpi('dens',out.vars_units(:,1))) && ~isfield(d,'dens')
            d.dens = sw_dens(d.psal,d.temp,d.press);
            h.fldnam = [h.fldnam 'dens']; h.fldunt = [h.fldunt 'kg/m3'];
        end
        if sum(strcmpi('pden0',out.vars_units(:,1))) && ~isfield(d,'pden0')
            d.pden0 = sw_pden(d.psal,d.temp,d.press,0);
            h.fldnam = [h.fldnam 'pden0']; h.fldunt = [h.fldunt 'kg/m3'];
        end
    end
    
    
    %tile extra variables
    if isfield(out,'extras')
        fn = fieldnames(out.extras);
        for fno = 1:length(fn)
            d.(fn{fno}) = repmat(out.extras.(fn{fno}),size(d.(timvar)));
        end
    end
    
    
    %%% which variables to write? %%%
    fn = fieldnames(d);
    if isfield(out,'vars_units') && size(out.vars_units,2)==4
        m = ismember(out.vars_units(:,3),fn);
        out.vars_units = out.vars_units(m,:);
        %make sure there are no duplicate column names
        [~,ia,~] = unique(out.vars_units(:,1),'stable');
        out.vars_units = out.vars_units(ia,:);
    else
        %write all, try to get format strings from m_exch_vars_list.m
        if issam
            [evars, ~] = m_exch_vars_list(2);
        else
            [evars,~] = m_exch_vars_list(1);
        end
        if ~isfield(out,'vars_units')
            out.vars_units = fn;
        else
            [~,ia,~] = intersect(out.vars_units,fn,'stable');
            out.vars_units = out.vars_units(ia,:);
        end
        out.vars_units(:,3) = out.vars_units(:,1);
        [~,ia,ib] = intersect(out.vars_units(:,1),evars(:,3));
        out.vars_units(ia,4) = evars(ib,4);
        ic = setdiff(1:size(out.vars_units,1),ia);
        out.vars_units(ic,4) = {'%f'};
        [~,ia,ib] = intersect(out.vars_units(:,1),h.fldnam);
        out.vars_units(ia,2) = h.fldunt(ib)';
        ic = setdiff(1:size(out.vars_units,1),ia);
        out.vars_units(ic,2) = {'woce_table_4.9'};
        m = strncmp('woce_table_4',out.vars_units(:,2),12);
        out.vars_units(m,4) = {'%d'};
        ii = find(strcmp(timvar,out.vars_units(:,1)));
        if strncmp(out.vars_units{ii,2},'seconds',7)
            out.vars_units{ii,4} = '%20.3f';
        end
        m = strcmp(pvar,out.vars_units(:,1));
        out.vars_units{m,4} = '%5.2f';
        m = strcmp('depth',out.vars_units(:,1));
        out.vars_units{m,4} = '%5.2f';
    end
    
    %%% write %%%
    
    %open csv file
    if kloop>0 && ~isw
        outfile = sprintf('%s_%s.csv',out.csvpre,stn_string);
    else
        outfile = sprintf('%s.csv',out.csvpre);
    end
    fid = fopen(outfile,'w');
    
    %write header
    if isfield(out,'header')
        fprintf(fid, '%s\n', out.header{:})
    end
    if ~isw
        [~,fn,ext] = fileparts(infile);
        if dobin
            avstr = sprintf('(averaged to % %s)',out.bin_size,out.bin_units);
        else
            avstr = '';
        end
        fprintf(fid, 'from file %s%s %s\n', fn, ext, avstr);
    end
    for hno = 1:size(varsh,1)
        fprintf(fid, ['%s = ' varsh{hno,4} '\n'], upper(varsh{hno,1}), h.(varsh{hno,3}));
    end
    
    %column headers
    fprintf(fid, '%s, ', out.vars_units{1:end-1,1});
    fprintf(fid, '%s\n', out.vars_units{end,1});
    fprintf(fid, '%s, ', out.vars_units{1:end-1,2});
    fprintf(fid, '%s\n', out.vars_units{end,2});
    
    tic
    %data rows
    iir = 1:length(d.(timvar));
    if issam && isfield(in,'stnlist')
        iir = find(ismember(d.statnum,in.stnlist));
        iir = iir(:)';
    end
    for sno = iir
        for cno = 1:size(out.vars_units,1)-1
            fprintf(fid, [out.vars_units{cno,4} ', '], d.(out.vars_units{cno,3})(sno,:));
        end
        fprintf(fid, [out.vars_units{end,4} '\n'], d.(out.vars_units{end,3})(sno,:));
    end
    toc
    %finish up
    if isw
        fprintf(fid, '%s', 'END_DATA');
    end
    fclose(fid);
    
    status = 1;
    
    disp(['file ' num2str(kloop) '/' num2str(length(klist)) ' written'])
end


function d = get_station_constants(d, mcruise)
stns = unique(d.statnum); ns = length(stns);
if ~isfield(d,'stnlat')
    if isfield(d,'lat')
        d.stnlat = d.lat; d.stnlon = d.lon;
    elseif isfield(d,'latitude')
        d.stnlat = d.latitude; d.stnlon = d.longitude;
    elseif isfield(d,'ulatitude') %will replace with single pos below
        d.stnlat = d.ulatitude; d.stnlon = d.ulongitude;
    else
        d.stnlat = NaN+d.statnum; d.stnlon = d.stnlat;
    end
end
if ~isfield(d,'stndepth')
    if isfield(d,'depth')
        d.stndepth = d.depth;
    else
        d.stndepth = NaN+d.statnum;
    end
end
%check single pos for each station and if not, fill or estimate; also fill
%depth if necessary
sumfn = [mgetdir('M_SUM') '/station_summary_' mcruise '_all.nc'];
if exist(sumfn,'file')
    [dsum, ~] = mloadq(sumfn,'/');
else
    clear dsum; dsum.statnum = [];
end
for sno = 1:ns
    m = d.statnum==stns(sno);
    ms = dsum.statnum==stns(sno);
    if length(unique(d.stnlat(m)))~=1 || length(unique(d.stnlon(m)))~=1 || ~sum(~isnan(d.stnlat(m)) & d.stnlat(m)>-999)
        if sum(ms)
            d.stnlat(m) = dsum.lat(ms);
            d.stnlon(m) = dsum.lon(ms);
        else
            %pos at deepest bottle
            mp = m & d.upress==max(d.upress(m));
            d.stnlat(m) = d.stnlat(mp);
            d.stnlon(m) = d.stnlon(mp);
        end
    end
    if length(unique(d.stndepth(m)))~=1 || ~sum(~isnan(d.stndepth(m)) & d.stndepth(m)>-999)
        if sum(ms)
            d.stndepth(m) = dsum.cordep(ms);
        else
            d.stndepth(m) = max(d.stndepth(m));
        end
    end
end

