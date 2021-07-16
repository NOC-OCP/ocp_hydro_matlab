function data = parse_load_hdata(infile, varnamesunits, varargin)
%
% infile is an Mx1 cell array containing name(s) of file(s) to load
%
% varnamesunits is a cell array with three columns:
%     invar (variable names/column headers in files to be read)
%     hvar (rename to these fieldnames in output structure data)
%     hunt (corresponding units)
%   hvar can contain repetitions, but invar cannot, and only one invar-hvar
%     pair should be found in a given file. each instance of a value for
%     hvar should have the same value for hunt***
%
% optional parameter-value input argument pairs used include
%     predir, directory for input file(s) (default './')
%     badflags, list of flag values which NaN corresponding variables (default [4 9])
%     hcpat, chrows, chunits (no defaults)
%         for csv files, information on column header (see help for m_load_samin)
%     cruisename (no default)
%         for matlab files, if the file contains multiple cruises in
%         structures by cruise name (e.g. a23), or in one multi-element
%         structure called data, with cruise or crname as one of the
%         variables (e.g. sr1b) %***use an optional cruisenamevar?
%     statnums, Mx1 vector of station numbers corresponding to each element
%         in infile (required if M>1 and the files themselves do not
%         contain station number; only works for single-cast ctd files)
%
%
% output structure data contains any of the variables present in the input
%     files and also in varnamesunits
%
% if multiple files have different variables, they will be combined using
%     statnum, niskin or statnum, press***tolerance?
%


%defaults and optional input arguments
opts.predir = './';
opts.badflags = [4 9];
if length(varargin)==1 %supplied single cell array containing par-val pairs
    varargin = varargin{:};
end
for na = 1:2:length(varargin)
    opts.(varargin{na}) = varargin{na+1};
end
if opts.predir(end)~='/'
    opts.predir = [opts.predir '/'];
end

warning off
%add flag fields to varnamesunits
for vno = 1:size(varnamesunits,1)
    varnamesunits.invar = [varnamesunits.invar; {[varnamesunits.invar{vno} '_flag']}];
    varnamesunits.hvar{end} = [varnamesunits.hvar{vno} '_flag'];
    varnamesunits.hunt{end} = 'woce_flag';
    varnamesunits.invar = [varnamesunits.invar; {[varnamesunits.invar{vno} '_flag_w']}];
    varnamesunits.hvar{end} = [varnamesunits.hvar{vno} '_flag'];
    varnamesunits.hunt{end} = 'woce_flag';
end
%add GLODAP names (and flags) to varnamesunits
if ~strcmp('G2',varnamesunits{1,1}(1:2))
    n0 = size(varnamesunits,1); n = n0+1;
    for vno = 1:n0
        ii = strfind(varnamesunits{vno,1},'_flag');
        if length(ii)==1
            varnamesunits.invar = [varnamesunits.invar; {['G2' varnamesunits{vno,1}(1:end-5) 'f']}];
            varnamesunits.hvar{end} = varnamesunits.hvar{vno};
            varnamesunits.hunt{end} = 'woce_flag';
        else
            varnamesunits.invar = [varnamesunits.invar; {['G2' varnamesunits{vno,1}]}];
            varnamesunits.hvar{end} = varnamesunits.hvar{vno};
            varnamesunits.hunt{end} = varnamesunits.hunt{vno};
        end
    end
end
warning on

for fno = 1:size(infile,1)
    
    %%%%% load, renaming variables and storing units %%%%%
    %%%%% either from file metadata/header or from varnamesunits %%%%%
    
    clear data0 ds hs
    
    if contains(infile{fno}, '.mat') || ~contains(infile{fno}, '.')
        
        %load, and get list of vars we have
        ds = load([opts.predir infile{fno}], '-mat');
        if isfield(ds, 'data');
            ds = ds.data;
        end
        %find GLODAP cruise *** this could also come up for csv data
        if isfield(opts, 'expocode') && ~isempty(opts.expocode) && isfield(ds, 'expocode')
            if isfield(ds, 'G2cruise')
                cruisevar = 'G2cruise';
            end
            iic = strcmp(opts.expocode, ds.expocode);
            if length(ds)>1
                ds = ds(iic); iic = NaN;
            elseif isfield(ds, 'expocodeno')
                iic = find(ds.(cruisevar)==ds.expocodeno(iic));
            else
                iic = NaN;
            end
        elseif isfield(opts, 'cruisename')
            if isfield(ds, opts.cruisename)
                ds = ds.(cruisename);
            elseif isfield(ds, 'cruise')
                iic = strcmp(opts.cruisename, ds.cruise);
                ds = ds(iic); iic = NaN;
            end
        end
        %***lowercase fieldnames?
        
    elseif contains(infile{fno}, '.nc')
        %%% netcdf (mstar or otherwise)
        
        a = ncinfo([opts.predir infile{fno}]);
        iin = strcmp('Name',fieldnames(a.Variables));
        iia = strcmp('Attributes',fieldnames(a.Variables));
        b = struct2cell(a.Variables);
        vars = squeeze(b(iin,:,:));
        att = squeeze(b(iia,:,:));
        d = struct2cell(att{1}); iiu = strcmpi('units',d(1,:));
        for vno = nv+1:length(vars) %***nv?
            d = struct2cell(att{vno});
            unts{vno} = lower(d{2,iiu}); %***always 2? probably always Name, Value so yes
        end
        %for non-mstar files, what about scale factor, add offset, Fill_Value, missing_value***
        [~,iiv,iinv] = intersect(vars, varnamesunits.invar);
        if length(unique(varnamesunits.hvar(iinv)))<length(varnamesunits.hvar(iinv))
            [~,ia,~] = intersect(varnamesunits.hvar(iinv),unique(varnamesunits.hvar(iinv)));
            warning('duplicate variables excluded: ')
            disp(varnamesunits.hvar(setdiff(iinv,iinv(ia))))
            iinv = iinv(ia); iiv = iiv(ia);
        end
        for vno = 1:length(iiv)
            ds.(varnamesunits.hvar{iinv(vno)}) = ncread([opts.predir infile{fno}], vars{iiv(vno)});
            hs.colunit{iinv(vno)} = unts{iiv(vno)};
        end
        
    else
        %%% csv with single or multiple header lines %%%
        if isfield(opts, 'hcpats') && length(opts.hcpats)==size(infile,1)
            opts.hcpat = opts.hcpats{fno};
        end
        if isfield(opts, 'hcpat')
            if ~isfield(opts, 'chrows')
                opts.chrows = 1; %default: variable names on single row
            end
            if ~isfield(opts, 'chunits')
                opts.chunits = length(hcpat); %default: last row of header is units
            end
            [ds, hs] = m_load_samin([opts.predir infile{fno}], opts.hcpat, 'chrows', opts.chrows, 'chunits', opts.chunits);
        else
            try
                %check if it's exchange format
                hcpate = {'CTDPRS'; 'DBAR'};
                [ds, hs] = m_load_samin([opts.predir infile{fno}], hcpate, 'chrows', 1, 'chunits', 2, 'single_block', 1);
            catch
                warning(['unknown file type or header not properly specified: ' infile{fno}])
                keyboard
            end
        end
        ds = dataset2struct(ds,'AsScalar',1);
        
    end %switch/case: mat, nc, or other
    
    %only keep the variables we might want, put them in data0
    vars = fieldnames(ds);
    [~,iiv,iinv] = intersect(vars, varnamesunits.invar);
    if length(unique(varnamesunits.hvar(iinv)))<length(varnamesunits.hvar(iinv))
        [~,ia,~] = intersect(varnamesunits.hvar(iinv),unique(varnamesunits.hvar(iinv)));
        warning('duplicate variables excluded: ')
        disp(varnamesunits.hvar(setdiff(iinv,iinv(ia))))
        iinv = iinv(ia); iiv = iiv(ia);
    end
    data0.vars = varnamesunits.hvar(iinv)';
    data0.unts = varnamesunits.hunt(iinv)';
    for vno = 1:length(iiv)
        data0.(varnamesunits.hvar{iinv(vno)}) = ds.(vars{iiv(vno)});
        if exist('hs', 'var') && ~isempty(hs.colunit{iiv(vno)})
            data0.unts{vno} = hs.colunit{iiv(vno)};
        end
    end
    
    
    %add station number (and lat, lon) if we don't already have them
    if ~isfield(data0, 'statnum')
        %STNNBR, LATITUDE, LONGITUDE from header?
        if exist('hs', 'var') && isfield(hs, 'header')
            iin = strfind(hs.header,'\n');
            hnames = {'LATITUDE' 'LONGITUDE' 'STNNBR'};
            hnames_new = {'lat' 'lon' 'statnum'};
            hunits = {'no' 'deg' 'deg'};
            for hno = 1:length(hnames)
                ii = strfind(hs.header,[hnames{hno} ' =']);
                if ~isempty(ii)
                    he = hs.header(ii:iin(iin>ii)-1);
                    iic = strfind(he, ',');
                    eval([he(1:iic(1)-1) ';'])
                    eval(['d = ' hnames{hno} ';']);
                    data0.(hnames_new{hno}) = repmat(d,size(data0.press,1),1);
                    data0.vars = [data0.vars hnames_new(hno)];
                    data0.unts = [data0.unts hunits(hno)];
                end
            end
        end
    end
    if ~isfield(data0, 'statnum')
        %station numbers for individual-cast files supplied?
        if isfield(opts, 'statnums') && length(opts.statnums)==size(infile,1)
            data0.statnum = repmat(opts.statnums(fno),size(data0.press));
        end
    end
    if ~isfield(data0, 'statnum')
        %either a way to get statnum from other fields was specified in set_hsecpars, or statnum is called event
        if isfield(opts, 'event_extract_string')
            eval(opts.event_extract_string);
        elseif isfield(data0, 'event') && isnumeric(data0.event)
            data0.statnum = data0.event;
        end
    end
    if ~isfield(data0, 'statnum')
        %nothing else to try (will error later)
        warning('station number unknown for file')
        disp(infile{fno})
    end
    
    %tile if necessary
    if isfield(data0, 'press') && size(data0.press,2)==1 && size(data0.statnum,1)==1
        data0.press = repmat(data0.press,1,length(data0.statnum));
    end
    for vno = 1:length(data0.vars)
        d = data0.(data0.vars{vno});
        if size(d,1)==1 && isfield(data0, 'press') && length(d)~=size(data0.press,1)
            d = repmat(d,size(data0.press,1),1);
        end
        data0.(data0.vars{vno}) = d(:);
    end
    nd = length(data0.press);
    if size(data0.statnum,1)>1 && ~isempty(data0.lat) %***???
        data0.lat(length(data0.lat)+1:nd,1) = data0.lat(end);
        data0.lon(length(data0.lon)+1:nd,1) = data0.lon(end);
    end
    if ~isfield(data0, 'press') && isfield(data0, 'depth') && isfield(data0, 'lat')
        data0.press = sw_pres(data0.depth, data0.lat);
    end
    if length(data0.statnum)==1 && isfield(data0, 'press')
        data0.statnum = repmat(data0.statnum,length(unique(data0.press)),1);
    end
    if isfield(data0, 'lat') && length(data0.lat)==1
        data0.lat = repmat(data0.lat,length(unique(data0.press)),1);
        data0.lon = repmat(data0.lon,length(unique(data0.press)),1);
    end
    
    
    %%%%% combine in data
    
    if fno==1
        data = data0;
        
    else
        %find what variables to merge on if there are repeated variable names
        
        if isfield(data, 'niskin') && isfield(data0, 'niskin')
            data.sampnum = data.statnum*100 + data.niskin;
            data0.sampnum = data0.statnum*100 + data0.niskin;
        elseif isfield(data, 'press') && isfield(data0, 'press')
            data.sampnum = data.statnum*100 + round(data.press)/1e2;
            data0.sampnum = data0.statnum*100 + round(data0.press)/1e2;
        else
            warning('will not be able to merge multiple files without either niskin or pressure')
            keyboard
        end
        
        %check existing variables and units
        [~, ia, ib] = intersect(data.vars, data0.vars);
        sameu = strcmp(data.unts(ia), data0.unts(ib));
        
        %variables with different units from before get new names
        iiu = find(~sameu);
        for no = 1:length(iiu)
            ii = ib(iiu(no));
            nname = sprintf('%s_%03d', data0.vars{ii}, fno);
            data0.(nname) = data0.(vars{ii});
            data0 = rmfield(data0, vars{ii});
            data0.vars(ii) = nname;
        end
        
        %rearrange for merge_mvars, and use to merge existing and new data
        clear h0 h
        h0.fldnam = data0.vars; h0.fldunt = data0.unts;
        d0 = rmfield(data0, {'vars', 'unts'});
        h.fldnam = data.vars; h.fldunt = data.unts;
        d = rmfield(data, {'vars', 'unts'});
        if length(unique(d0.sampnum))<length(d0.sampnum)
            [~,ii] = unique(d0.sampnum);
            fn = fieldnames(d0);
            for vno = 1:length(fn)
                d0.(fn{vno}) = d0.(fn{vno})(ii);
            end
        end
        [data, hnew] = merge_mvars(d0, h0, d, h, 'sampnum', 0); %***yessort?
        data.vars = hnew.fldnam; data.unts = hnew.fldunt;
        
    end
    
    fno
end


%clean up
if isfield(data, 'depth') && isfield(data, 'press')
    data = rmfield(data, 'depth');
    iid = find(strcmp('depth', data.vars)); data.vars(iid) = []; data.unts(iid) = [];
end
if isfield(data, 'sampnum')
    data = rmfield(data, 'sampnum');
    iid = find(strcmp('sampnum', data.vars)); data.vars(iid) = []; data.unts(iid) = []; %***
end
data.vars = data.vars(:)';
data.unts = data.unts(:)';


%NaN bad data, apply flags (mask), and make sure they match
data = hdata_flagnan(data, opts.badflags);
