function [samtable, samhead] = load_samdata(infile, varargin)
% function [samtable, samhead] = load_samdata(infile, 'parameter', value)
% function [samtable, samhead] = load_samdata(infile, opts)
%
% read in sample data from spreadsheet or comma delimited files listed in
%   cell array infile
%   tries to use readtable and if that fails uses mtextdload
% parses to find header or blank lines, column header line(s), units
%   line(s) if specified, and data lines
% csv files may be concatenated (that is, have  multiple repetitions of
%   [header]; column headers; data)
% xls* files may have one or more sheets
%
% samtable contains the data; variable names come either from header line(s)
%   or as specified in input argument iopts.VariableNames
%
% samhead is a cell array containing the header lines
%
% for column names, column header lines are combined and rectified (made
%   lower case, leading and trailing whitespace removed, special characters
%   and other spaces replaced by '_')
%
% works on single or concatenated csv files (in which there can be more
%   than one occurrence of column header row(s), but all fields you wish to
%   keep must be present in the first one) and on single or multiple sheets
%   of a spreadsheet file
%
% you can supply iopts, a structure, containing options for importing using
%   readtable (e.g. VariableNames, VariableTypes)
%
% other inputs are passed as parameter-value pairs
%
% if iopts is not supplied or does not set VariableNames, use either:
%   hcpat to give the contents of an indicative column header over one or
%     more rows, to be searched for, or
%   numhead (default 0) to set how many lines to skip before column headers
%     start on the following line
% in either case, icolhead (default 1) and icolunits (default []) set which
%   of the subsequent lines to turn into variable names and units,
%   respectively
%
% numhead can also be used if iopts.VariableNames is supplied, to specify
%   how many header lines including column headers to skip before data rows
%   start
%
% sheets gives the list of sheets to read in and append; if you specify
%   hcpat it will stop when it reaches a sheet where this patter is not
%   found (i.e. detect when you've reached the end of the data sheets)
%
% e.g., infile points to an oxygen csv file with multiple column header
%   rows:
%     Cruise,JC211,,,,,,,,,,,,,
%     Cast,3,,,Analysis Set,,,,,,,Volume (ml),,,
%     Sampler,EPA,,,Analyst,YF,,,,Manganese Chloride,,1,,,
%     Sample Date,05/02/2021,,,Analysis Date,06/02/2021,,,,Alkaline Iodide ,,0.99,,,
%     Sample Time,2224,,,Analysis Time,1550,,,,Total,,1.99,,,
%     ,,,,,,,,,,,,,,
%     ,,,,,,,,,,,,,,
%     Cast,Niskin ,Depth,Bottle ,Bottle ,Blank,Std,Standard,Fixing,Botvol,Sample,Iodate,n(O2),C(O2),Notes
%     Number,Bottle,(m),No.,vol (25C),titre,vol,titre,temp,at Tfix,titre,molarity,,,
%     ,Number,,,mls,mls,mls,mls,C,mls,mls,M,moles,umol/l,
%     8,1,,1013,139.8594804,0.01394,5,0.4619,0.8,137.835634405743,1.445,0.001667,3.99406814224484E-05,289.218978780914,
%     8,5,,25,137.8955138,0.01394,5,0.4619,0.8,135.87214308566,1.5295,0.001667,4.22990644253951E-05,310.755858165685,
%
% [ds, hs] = load_samdata(infile, 'hcpat', {'Niksin'; 'Bottle'; 'Number'}, 'icolhead', [1 2], 'icolunits', 3);
% or
% [ds, hs] = load_samdata(infile, 'numhead', 7, 'icolhead', [1 2], 'icolunits', 3);
% will return hs containing the first 7 lines, and table ds with
% ds.Properties.VariableNames = {'cast_number', 'niskin_bottle', 'depth__m_', ...}
% ds.Properties.VariableUnits = {'', 'number', '', ...}
% or
% iopts.VariableNames = {'statnum','position','depth','obot','botvol','blank','stdvol','standard','fixtemp','botvol_tfix','titre','iodmol','n_O2','c_O2','notes'};
% [ds, hs] = load_samdata(infile, iopts, 'numhead', 10);
% will return hs containing the first 10 lines, and table ds with
% ds.Properties.VariableNames = iopts.VariableNames
% ds.Properties.VariableUnits = {};

sheets = 1;
hcpat = {};
icolunits = [];
iopts = struct([]);
%inputs
n = 1;
while n<=length(varargin)
    if isstruct(varargin{n})
        iopts = varargin{n};
        n = n+1;
    elseif ischar(varargin{n})
        eval([varargin{n} '= varargin{n+1};'])
        n = n+2;
    else
        error('input arguments can only be a structure and/or one or more parameter-value pairs')
    end
end
if ~isempty(hcpat) && ~exist('icolhead','var')
    icolhead = 1:length(hcpat);
end
if isempty(hcpat) && (~exist('iopts','var') || ~isfield(iopts,'VariableNames'))
    icolhead = 1; %default is to get names from first row (error if these don't start with chars?)***
end
if ~iscell(infile)
    infile = {infile};
end

warning('off','MATLAB:table:ModifiedAndSavedVarnames')
warning('off','MATLAB:textscan:AllNatSuggestFormat')

for fno = 1:length(infile)
    [~,~,ext] = fileparts(infile{fno});
    if strncmp(ext(2:end),'xls',3); isss = 1; else; isss = 0; end
    domtl = 0;
    
    %first try using readtable, looping through sheets
    for sno = 1:length(sheets)
        
        if exist('icolhead','var')
            %first load as char cells to get header
            %[hdr, iih, ch, un] = sd_read_header(infile{fno}, hcpat);
            opts = detectImportOptions(infile{fno});
            opts = setvartype(opts,'char');
            if isss
                opts.DataRange = 'A1';
                hdr = readtable(infile{fno}, opts, 'sheet', sheets(sno));
            else
                opts.DataLines = [1 Inf];
                hdr = readtable(infile{fno}, opts);
            end
            hdr = hdr{:,:};
            [iih, ch, un] = sd_find_colhead(hdr, hcpat, icolhead, icolunits);
            if ~isempty(hcpat) && isempty(iih)
                warning('did not find hcpat on sheet %d, stopping loop',sno); break
            end
            if size(ch,1)>1
                if isss
                    error('header found more than once in spreadsheet file one sheet %d',sno);
                else
                    warning('looks like a concatenated file; trying mtextdload'); domtl = 1; break
                end
            elseif iih(1)>1
                h = hdr(1:iih(1)-1,:);
                h = cellfun(@(x) [x ','],h,'UniformOutput',false);
                %h(:,end) = cellfun(@(x) [x '\n'],h(:,end),'UniformOutput',false);
                %samhead{fno,sno} = strjoin(h');
                for no = 1:iih(1)-1
                    h{no,1} = strjoin(h(no,:));
                end
                samhead{fno,sno} = h(:,1);
                %sprintf('%s\n',samhead{fno,sno}{:})
            else
                samhead{fno,sno} = '';
            end
        else
            if exist('numhead','var') && numhead>0
                iih = 1:numhead;
            else
                iih = 0;
            end
        end
        
        %get parameters for reading in data rows
        opts = detectImportOptions(infile{fno},'NumHeaderLines',iih(1)-1); %exclude all before column header line
        vt = opts.VariableTypes;
        mt = strcmp(vt,'datetime');
        if ~sum(mt)
            mo = ~ismember(vt,{'double'});
            vt(mo) = {'double'};
            opts = setvartype(opts, vt); %***what was problem with datetimes before?
        else
            mo = [];
        end
        if ~isempty(hcpat)
            mc = ~cellfun('isempty',ch);
            opts.VariableNames(mc) = ch(mc);
        end
        %if options were passed as input args, use them
        if ~isempty(iopts)
            %change variable names first
            fn = fieldnames(iopts);
            if sum(strcmp(fn,'VariableNames'))
                if ~isempty(hcpat)
                    warning('overwriting variable names detected using hcpat with those passed in iopts')
                    mc = true(size(ch));
                end
                opts.VariableNames = iopts.VariableNames;
                fn = setdiff(fn,{'VariableNames'});
            end
            %now other parameters
            for no = 1:length(fn)
                if strcmp(fn{no},'VariableTypes')
                    opts = setvartype(opts,iopts.VariableTypes);
                    mo = [];
                elseif strcmp(fn{no},'datetimeformat')
                    opts = setvaropts(opts,opts.VariableNames(mt),'InputFormat',iopts.datetimeformat);
                else
                    opts.(fn{no}) = iopts.(fn{no});
                end
            end
        end
        if isss
            opts.Sheet = sheets(sno);
        end
        
        %get data
        dat = readtable(infile{fno}, opts);
        %only keep the columns with good variable names
        dat = dat(:,mc);
        %only keep rows with some numeric (non-nan) data
        mr = sum(~ismissing(dat),2)>0;
        dat = dat(mr,:);
        if ~isempty(mo)
            %if we made everything doubles, check if some cols need to be strings
            dat = sd_get_char_vars(dat, opts, infile{fno}, mr, mc);
        end
        if ~isempty(icolunits)
            %units are not a property of importoptions so set now
            mc = ~cellfun('isempty',un);
            dat.Properties.VariableUnits(mc) = un(mc);
        end
        
        %add to samtable
        if ~exist('samtable', 'var')
            samtable = dat;
        else
            if exist('ch','var')
                %append, matching variables and adding new ones as necessary
                warning off all
                samtable = sd_combine_tables(samtable, dat);
                warning on all
            else
                %hcpat was not supplied so assume columns always the same
                samtable(s0(1)+[1:size(dat,1)],:) = dat;
            end
        end
    end %loop through sheets
    
    if domtl
        if isempty(hcpat)
            warning('input hcpat required for mtextdload branch of load_samdata')
            warning('skipping %s',infile{fno})
        else
            warning('readtable failed; using mtextdload')
            maxcol = 2e3;
            %load as cell array
            indata = mtextdload(infile{fno}, ',', maxcol);
            [iih, ch, un] = sd_find_colhead(indata, hcpat, icolhead, icolunits);
            nb = size(ch,1);
            %figure out data indices
            mn = sum(cellfun(@(x) ~isnan(str2double(x)), indata(10:end,:)),2);
            iid1 = iih(:,end)+1;
            iid2 = [iih(2:end,1)-1; find(mn>0, 1, 'last')];
            %loop through blocks
            for bno = 1:nb
                dat = array2table(cellfun(@(x) str2double(x), indata(iid1(bno):iid2(bno),:)));
                dat.Properties.VariableNames = ch(bno,:);
                if ~isempty(icolunits)
                    dat.Properties.VariableUnits = un(bno,:);
                end
                samhead{fno,bno} = indata(iih(1,:),:);
                if ~exist('samtable','var')
                    %initialise
                    samtable = dat;
                else
                    %append
                    samtable = sd_combine_tables(samtable, dat);
                end
            end
        end
        
    end
    
    disp(['loaded ' infile{fno}])
    
end %loop through files

warning('on','MATLAB:table:ModifiedAndSavedVarnames')
warning('on','MATLAB:textscan:AllNatSuggestFormat')


function varargout = sd_find_colhead(hdr, hcpat, icolhead, icolunits)
% function [iih, ch, un] = sd_find_colhead(hdr, hcpat, icolhead, icolunits);
%
% find and parse 1 or more column header (and optionally column units)
%   lines from cell array hdr, optionally by searching for pattern hcpat
%
% hdr (MxN) and hcpat (Kx1, or empty) are cell arrays
% icolhead and icolunits are vector indices; if K>0 then
%   max([icolhead(:);icolunits(:)])<=K
%
% if hcpat is empty, iih = 1:max([icolhead(:);icolunits(:)])
% if hcpat is not empty, searches hdr for the rows where each element
%   of hcpat is found in a column, and iih starts from the first such row
%   (rather than from 1)
% hdr(iih(icolhead),:) are turned into acceptable matlab variable names
%   (appending contents of multiple rows for each column if
%   length(icolhead)>1) and output as ch;  hdr(iih(chunts),:) is parsed the
%   same way and output as un.
%
% e.g.
% hdr = {'this is file', '', '' '';
%        'one of one', 'or two', ''
%        'cast no.', 'niskin', 'data'
%        '', 'bottle', ''
%        '', '', '(units)'
%        '1', '5', '21.5729'};
% hcpat = {'niskin';'bottle'}; icolhead = 1:2; icolunits = 3;
% produces
% iih = 3:5;
% ch = {'cast_no_', 'niskin_bottle', 'data'};
% un = {'', '', '_units_'};
%
% if hcpat occurs P times, iih will contain all P sets of indices
% (concatenated) and ch and un will be Pxncol
%

if isempty(icolhead)
    error('icolhead must have at least one element')
end

nhl = max([icolhead(:);icolunits(:)]);
np = length(hcpat);
s = size(hdr);

%get rid of leading and trailing whitespace
hdr = strtrim(hdr);

if np==0
    iih = 1:nhl;
else
    %header rows are those where one column matches rows of hcpat
    m = true(s(1)-np+1,s(2));
    for no = 1:np
        m = m & strcmp(hcpat{no}, hdr(no+[0:s(1)-np],:));
    end
    [iih,~] = find(m); %first row in each instance of header rows
    if isempty(iih)
        return
    end
    %now for each of these, keep as many following as needed for icolhead and
    %icolunits
    iih = repmat(iih,1,nhl)+repmat([0:nhl-1],length(iih),1);
    varargout{1} = iih;
    nb = size(iih,1);
end

%convert the relevant rows from iih to matlab variable name forms
if nargout>1
    npat = cellstr(['()=-:.?><][{}#~$%^&*!;']');
    npat = [npat; ' '];
    hdr = replace(hdr, npat, '_');
    hdr = replace(replace(replace(hdr,'+','_plus_'),'/','_per_'),'%','_percent');
    hdr = replace(hdr, '__', '_');
    
    ch = cell(nb,size(hdr,2));
    un = ch;
    %loop through blocks/occurrences
    for bno = 1:nb
        h = hdr(iih(bno,icolhead), :);
        if ~isempty(icolunits)
            u = hdr(iih(bno,icolunits),:);
        end
        %loop through columns
        for no = 1:size(hdr,2)
            a = replace(lower(sprintf('%s_', h{:,no})),'__','_');
            if ~isvarname(a)
                warning('invalid variable name in row %d; unless variable names were supplied in input structure, column %d will be skipped',iih(icolhead(1)),no)
                a = '_'; %will make ch empty
            end
            ch{bno,no} = a(1:end-1);
            if ~isempty(icolunits)
                a = replace(lower(sprintf('%s_', u{:,no})),'__','_');
                un{bno,no} = a(1:end-1);
            end
        end
        varargout{2} = ch;
        varargout{3} = un;
    end
end


function dat = sd_get_char_vars(dat, opts, filename, mr, mc)
% function dat = sd_get_char_vars(dat, opts, filename, mr, mc);
%
% replace table columns with no valid numbers by reading in again as
%   strings

m = sum(isnan(table2array(dat)))==size(dat,1);
if sum(m)
    optss = setvartype(opts,'string');
    dats = readtable(filename, optss);
    dats = dats(:,mc);
    dats = dats(mr,:);
    m = m & sum(cellfun(@(x) ismissing(x),table2cell(dats)))<size(dats,1);
    iicc = find(m);
    fn = dat.Properties.VariableNames;
    for no = 1:length(iicc)
        dat.(fn{iicc(no)}) = dats.(fn{iicc(no)});
    end
end



function table1 = sd_combine_tables(table1, table2)
% function table_out = sd_combine_tables(table1, table2);
%
% concatentate table2 onto end of table1,
%   matching variable names (and units, if applicable) and adding new
%   variables where no match is found. may also change type of variable if
%   necessary
%

s0 = size(table1);

ch0 = table1.Properties.VariableNames;
ch = table2.Properties.VariableNames;
un0 = table1.Properties.VariableUnits;
un = table2.Properties.VariableUnits;

%compare to existing
[~, iio, iin] = intersect(ch0, ch);
if ~isempty(un)
    iinu = find(~strcmp(un0(iio), un(iin)));
    if ~isempty(iinu)
        %change names (append units of "new" variable to its name to distinguish from original)
        for cno = 1:length(iinu)
            ch{cno} = [ch{cno} '_' un{cno}];
        end
        %recalculate intersection
        [~, iio, iin] = intersect(ch0, ch);
    end
end

%check if any variables were chars before but should now be numeric
iict = find(~sum(cellfun(@(x) isnumeric(x), table2cell(table1(:,iio)))) & sum(cellfun(@(x) isnumeric(x), table2cell(table2(:,iin)))));
if ~isempty(iict)
    iict = iio(iict(sum(cellfun('isempty', table2cell(table1(:,iio(iict)))))==size(table1,1)));
    for no = 1:length(iict)
        table1.(ch0{iict(no)}) = nan(size(table1,1),1);
    end
end
%add same-name variables
table1(s0(1)+[1:size(table2,1)],iio) = table2(:,iin);

%default pad is 0, fill with NaNs instead
iiof = setdiff(1:length(ch0), iio);
if ~isempty(iiof)
    table1{s0(1)+[1:size(table2,1)],iiof} = NaN;
end

%add any new ones
iinn = setdiff(1:length(ch), iin);
if ~isempty(iinn)
    for cno = iinn
        table1.(ch{cno}) = [nan(s0(1),1); table2.(ch{cno})];
        if ~isempty(un)
            table1.Properties.VariableUnits{end} = un{cno};
        end
    end
end
