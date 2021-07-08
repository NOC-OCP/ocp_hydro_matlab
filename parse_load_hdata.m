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
%     cruise (no default)
%         for matlab files, if the file contains multiple cruises in
%         structures by cruise name (e.g. a23), or in one multi-element
%         structure called data, with cruise or crname as one of the
%         variable (e.g. sr1b) %***use an optional cruisenamevar?
%     statnum, Mx1 vector of station numbers corresponding to each element
%         in infile (required if M>1 and the files themselves do not
%         contain station number)
%
% output structure data contains any of the variables present in the input
%     files and also in varnamesunits
%
% if multiple files have different variables, they will be combined using
%     statnum, niskin or statnum, press***tolerance?
% 


%defaults and optional input arguments
predir = './';
badflags = [4 9];
for na = 1:2:length(varargin)
    eval([varargin{na} ' = varargin{na+1};'])
end
if predir(end)~='/'
    predir = [predir '/'];
end

%add flag fields to varnamesunits
warning off
for vno = 1:size(varnamesunits,1)
    varnamesunits.invar = [varnamesunits.invar; {[varnamesunits.invar{vno} '_flag']}];
    varnamesunits.hvar{end} = [varnamesunits.hvar{vno} '_flag'];
    varnamesunits.hunt{end} = 'woce_flag';
    varnamesunits.invar = [varnamesunits.invar; {[varnamesunits.invar{vno} '_flag_w']}];
    varnamesunits.hvar{end} = [varnamesunits.hvar{vno} '_flag'];
    varnamesunits.hunt{end} = 'woce_flag';
end
warning on

for fno = 1:size(infile,1)
    
    %%%%% load, renaming variables and storing units either from file
    %%%%% metadata/header or from varnamesunits 
    
    clear data0
    
    if contains(infile{fno}, '.mat') || ~contains(infile{fno}, '.')
    %%% matlab file
        
        %load, and get list of vars we have
        %m = matfile(infile);
        m = load([predir infile{fno}], '-mat');
        if isfield(m, 'data');
            m = m.data;
        end
        vars = fieldnames(m);
        %GLODAP
        if exist('expocode', 'var') && ~isempty(expocode) && isfield(m, 'expocode')
            if isfield(m, 'G2cruise')
                if ~strcmp('G2',varnamesunits{1,1}(1:2))
                    for vno = 1:size(varnamesunits,1)
                        ii = strfind(varnamesunits{vno,1},'_flag');
                        if length(ii)==1
                            varnamesunits{vno,1} = ['G2' varnamesunits{vno,1}(1:end-5) 'f']; %***
                        else
                            varnamesunits{vno,1} = ['G2' varnamesunits{vno,1}];
                        end
                    end
                end
                cruisevar = 'G2cruise';
            end
            iic = strcmp(expocode, m.expocode);
            if length(m)>1
                m = m(iic); iic = NaN;
            elseif isfield(m, 'expocodeno')
                iic = find(m.(cruisevar)==m.expocodeno(iic));
            else
                iic = NaN;
            end
        elseif exist('cruise', 'var')
            if isfield(m, cruise)
                m = m.(cruise);
                vars = fieldnames(m);
            elseif isfield(m, 'cruise')
                iic = strcmp(cruise, m.cruise);
                m = m(iic); iic = NaN;
            end
        end
        
        %add station number for ctd files that don't already have it
        if ~isfield(m, 'statnum') && exist('statnums', 'var') && length(statnums)==size(infile,1)
            m.statnum = repmat(statnums(fno),size(m.press)); %single-case file should be CTD and have press
            vars = [vars; 'statnum'];
        end

        %only keep the ones we want
        [~,iiv,iinv] = intersect(vars, varnamesunits.invar);
        if length(unique(varnamesunits.hvar(iinv)))<length(varnamesunits.hvar(iinv))
            [~,ia,~] = intersect(varnamesunits.hvar(iinv),unique(varnamesunits.hvar(iinv)));
            warning('duplicate variables excluded: ')
            disp(varnamesunits.hvar(setdiff(iinv,iinv(ia))))
            iinv = iinv(ia); iiv = iiv(ia);
        end
        data0.vars = varnamesunits.hvar(iinv)';
        data0.unts = varnamesunits.hunt(iinv)';
        if isfield(m, 'press') && size(m.press,2)==1 && size(m.statnum,1)==1
            m.press = repmat(m.press,1,length(m.statnum));
        end
        for vno = 1:length(iiv)
            d = m.(vars{iiv(vno)});
            if size(d,1)==1 && isfield(m, 'press') && length(d)~=size(m.press,1)
                d = repmat(d,size(m.press,1),1);
            end
            if exist('iic', 'var') && sum(~isnan(iic))>0
                d = d(iic);
            end
            data0.(varnamesunits.hvar{iinv(vno)}) = d(:);
        end
        nd = length(data0.press);
        if size(data0.statnum,1)>1 && ~isempty(data0.lat) %***???
            data0.lat(length(data0.lat)+1:nd,1) = data0.lat(end);
            data0.lon(length(data0.lon)+1:nd,1) = data0.lon(end);
        end
        
        
    elseif contains(infile{fno}, '.nc')
    %%% netcdf (mstar or otherwise)
    
        a = ncinfo([predir infile{fno}]);
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
                        %and add STNNBR, LATITUDE, LONGITUDE if found in header
                iin = strfind(hs.header,'\n');
                hnames = {'STNNBR' 'LATITUDE' 'LONGITUDE'};
                hunits = {'no' 'deg' 'deg'};
                for hno = 1:length(hnames)
                    ii = strfind(hs.header,[hnames{hno} ' =']);
                    if ~isempty(ii)
                        he = hs.header(ii:iin(iin>ii)-1);
                        iic = strfind(he, ',');
                        eval([he(1:iic(1)-1) ';'])
                        eval(['d = ' hnames{hno} ';']);
                        ds.(lower(hnames{hno})) = repmat(d,size(ds,1),1);
                        hs.colunit = [hs.colunit hunits{hno}];
                    end
                end
%for non-mstar files, what about scale factor, add offset, Fill_Value, missing_value***
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
            data0.(varnamesunits.hvar{iinv(vno)}) = ncread([predir infile{fno}], vars{iiv(vno)});
        end
        
        
    else
        %%% csv with single or multiple header lines (including but not limited
        %%% to exchange format)
        if exist('hcpats', 'var') && length(hcpats)==size(infile,1)
            hcpat = hcpats{fno};
        end
        if exist('hcpat', 'var')
            if ~exist('chrows', 'var')
                chrows = 1; %default: variable names on single row
            end
            if ~exist('chunits', 'var')
                chunits = length(hcpat); %default: last row of header is units
            end
            [ds, hs] = m_load_samin([predir infile{fno}], hcpat, 'chrows', chrows, 'chunits', chunits);
        else
            try
                %check if it's exchange format
                hcpate = {'CTDPRS'; 'DBAR'};
                [ds, hs] = m_load_samin([predir infile{fno}], hcpate, 'chrows', 1, 'chunits', 2, 'single_block', 1);
                %and add STNNBR, LATITUDE, LONGITUDE if found in header
                iin = strfind(hs.header,'\n');
                hnames = {'STNNBR' 'LATITUDE' 'LONGITUDE'};
                hunits = {'no' 'deg' 'deg'};
                for hno = 1:length(hnames)
                    ii = strfind(hs.header,[hnames{hno} ' =']);
                    if ~isempty(ii)
                        he = hs.header(ii:iin(iin>ii)-1);
                        iic = strfind(he, ',');
                        eval([he(1:iic(1)-1) ';'])
                        eval(['d = ' hnames{hno} ';']);
                        ds.(lower(hnames{hno})) = repmat(d,size(ds,1),1);
                        hs.colunit = [hs.colunit hunits{hno}];
                    end
                end
            catch
                warning(['unknown file type or header not properly specified: ' infile{fno}])
                keyboard
            end
        end
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
            if isempty(data0.unts{vno})
                %use default units
                data0.unts(vno) = varnamesunits.hunt(iinv(vno));
            end
        end
        
    end %switch/case: mat, nc, or other
    
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
data = hdata_flagnan(data, badflags);

