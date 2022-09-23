function [samtable, samhead] = load_samdata(infile, varargin)
% function [samtable, samhead] = load_samdata(infile, hcpat)
% function [samtable, samhead] = load_samdata(infile, hcpat, 'parameter', value)
% function [samtable, samhead] = load_samdata(infile, opts)
%
% read in sample data from spreadsheet or comma delimited files listed in
%   cell array infile
%   tries to use readtable and if that fails uses mtextdload
% parses to find header or blank lines, column header line(s), units line
%   if specified, and data lines
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
% hcpat gives the contents of an indicative column header over one or more
%   rows; the number of elements in hcpat determines how many rows are in
%   each column header before switching to data rows
%
% you must supply at least one of iopts.VariableNames and hcpat***
%
% to use only the first N column header rows as data fieldnames,
%   supply the parameter-value pair 'chrows', N (where N<=length(hcpat))
%
% to also save column units found in the Pth row of the column header rows
%   as samtable.Properties.VariableUnits, supply the parameter-value pair
%   'chunits', P
%
% sheets gives the list of sheets to read in and append; if you specify
%     hcpat it will detect when you've reached the end of the data sheets
%
% 2) oxygen csv file with multiple column header rows, e.g.
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
% [ds, hs] = load_samdata(infile, {'Niksin'; 'Bottle'; 'Number'}, 'chrows', 2, 'chunits', 3);
%

sheets = 1;
chunits = [];

%inputs
n = 1;
while n<=length(varargin)
    if isstruct(varargin{n})
        iopts = varargin{n};
        n = n+1;
    elseif iscell(varargin{n})
        hcpat = varargin{n};
        n = n+1;
    elseif ischar(varargin{n})
        eval([varargin{n} '= varargin{n+1};'])
        n = n+2;
    end
end
if exist('hcpat','var') && ~exist('chrows','var')
    chrows = 1:length(hcpat);
end

nhead = 1;
for fno = 1:length(infile)
    [~,~,ext] = fileparts(infile{fno});
    if strncmp(ext(2:end),'xls',3); isss = 1; else; isss = 0; end
    
    try %using readtable
        
        %loop through sheets
        for sno = 1:length(sheets)
            
            %first load as char cells to get header
            warning('off','MATLAB:table:ModifiedAndSavedVarnames')
            warning('off','MATLAB:textscan:AllNatSuggestFormat')
            opts = detectImportOptions(infile{fno});
            opts = setvartype(opts,'char');
            if isss
                hdr = readtable(infile{fno}, opts, 'sheet', sheets(sno));
            else
                hdr = readtable(infile{fno}, opts);
            end
            keyboard
            hdr = hdr{:,:};
            %identify header lines and parse variable names and units
            try
                if exist('hcpat','var')
                    [iih, ch, un] = sd_find_colhead(hdr, hcpat, chrows, chunits);
                end
            catch
                warning('did not find hcpat on sheet %d, stopping loop',sno)
                %not a data sheet, stop loop here
                break
            end
            if size(ch,1)>1
                error('readtable branch of load_samdata does not work with concatenated files')
            end
            samhead{nhead} = hdr(1:iih(end),:); nhead = nhead+1;

            %read in data
            opts = detectImportOptions(infile{fno},'NumHeaderLines',iih(end));
            %if input to function, overwrite detected version
            if exist('iopts','var')
                fn = fieldnames(iopts);
                for no = 1:length(fn)
                    if strcmp(fn{no},'VariableTypes')
                        opts = setvartype(opts,iopts.VariableTypes);
                    else
                        opts.(fn{no}) = iopts.(fn{no});
                    end
                end
            else
                opts = setvartype(opts,'double');
            end
            if isss
                opts.Sheet = sheets(sno);
            end
            dat = readtable(infile{fno}, opts);
            if ~exist('iopts','var') || ~isfield(iopts,'VariableTypes')
                %if we didn't specify check if some need to be strings
                dat = sd_get_char_vars(dat, opts, infile{fno});
            end
            if exist('hcpat','var')
                m = ~cellfun('isempty',ch);
                dat.Properties.VariableNames(m) = ch(m);
            end
            if ~isempty(chunits)
                m = ~cellfun('isempty',un);
                dat.Properties.VariableUnits(m) = un(m);
            end
            warning('on','MATLAB:table:ModifiedAndSavedVarnames')
            warning('on','MATLAB:textscan:AllNatSuggestFormat')
            
            %put in or append to samtable
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
        
    catch me
        
        warning(me.message)
        if exist('hcpat','var')
            warning('readtable failed; using mtextdload')
            maxcol = 2e3;
            %load as cell array
            indata = mtextdload(infile{fno}, ',', maxcol);
            [iih, ch, un] = sd_find_colhead(indata, hcpat, chrows, chunits);
            nb = size(ch,1);
            %figure out data indices
            mn = sum(cellfun(@(x) ~isnan(str2double(x)), indata(10:end,:)),2);
            iid1 = iih(:,end)+1;
            iid2 = [iih(2:end,1)-1; find(mn>0, 1, 'last')];
            %loop through blocks
            for bno = 1:nb
                dat = array2table(cellfun(@(x) str2double(x), indata(iid1(bno):iid2(bno),:)));
                dat.Properties.VariableNames = ch(bno,:);
                if ~isempty(chunits)
                    dat.Properties.VariableUnits = un(bno,:);
                end
                samhead{nhead} = indata(iih(1,:),:); nhead = nhead+1;
                if ~exist('samtable','var')
                    %initialise
                    samtable = dat;
                else
                    %append
                    samtable = sd_combine_tables(samtable, dat);
                end
            end           
        else
            warning('to use mtextdload branch of load_samdata, must supply input hcpat')
            warning('skipping %s',infile{fno})
        end
        
    end %catch
    
    disp(['loaded ' infile{fno}])
    
end %loop through files



function varargout = sd_find_colhead(hdr, hcpat, chrows, chunits)
% function [iih, ch, un] = sd_find_colhead(hdr, hcpat, chrows, chunits);
% hdr is cell array
%
% outputs:
% iih, contiguous row indices in hdr where hcpat was found
% ch, column headers constructed by turning each column of
% hdr(iih(chrows),:) into acceptable matlab variable names
% un, units constructed by same process on hdr(iih(chunits),:)
%
% e.g.
% hdr = {'this is file', '', '' '';
%        'one of one', 'or two', ''
%        'cast no.', 'niskin', 'data'
%        '', 'bottle', ''
%        '', '', '(units)'
%        '1', '5', '21.5729'};
% hcpat = {'niskin';'bottle'}; chrows = 1:2; chunits = 3;
% produces
% iih = 3:5;
% ch = {'cast_no_', 'niskin_bottle', 'data'};
% un = {'', '', '_units_'};
%
% if hcpat occurs N times, iih will contain all N sets of indices
% (concatenated) and ch and un will be Nxncol
%
% length([chrows; chunits]) must = length(hcpat)

nhl = length(hcpat);
if length(chrows)+length(chunits)~=nhl
    error('chrows and chunits must cover hcpat')
end
s = size(hdr);

%get rid of leading and trailing whitespace
hdr = strtrim(hdr);

%header rows are those where one column matches rows of hcpat
m = true(s(1)-nhl+1,s(2));
for no = 1:nhl
    m = m & strcmp(hcpat{no}, hdr(no+[0:s(1)-nhl],:));
end
[iih,~] = find(m); %first row in header rows
iih = repmat(iih,1,nhl)+repmat([chrows chunits]-1,length(iih),1);
varargout{1} = iih;
nb = size(iih,1);

%convert these to matlab variable name forms
if nargout>1
    ch = cell(nb,size(hdr,2));
    un = ch;
    npat = cellstr(['()=-:.?><][{}#~$%^&*!;']');
    npat = [npat; ' '];
    hdr = replace(hdr, npat, '_');
    hdr = replace(replace(replace(hdr,'+','_plus_'),'/','_per_'),'%','_percent');
    hdr = replace(hdr, '__', '_');
    %loop through blocks/occurrences
    for bno = 1:nb
        h = hdr(iih(bno,chrows), :);
        if ~isempty(chunits)
            u = hdr(iih(bno,chunits),:);
        end
        %loop through columns
        for no = 1:size(hdr,2)
            a = replace(lower(sprintf('%s_', h{:,no})),'__','_');
            ch{bno,no} = a(1:end-1);
            if ~isempty(chunits)
                a = replace(lower(sprintf('%s_', u{:,no})),'__','_');
                un{bno,no} = a(1:end-1);
            end
        end
        varargout{2} = ch;
        varargout{3} = un;
    end
end


function dat = sd_get_char_vars(dat, opts, filename)
% function dat = sd_get_char_vars(dat, opts, filename);
%
% if necessary, replace some columns with string equivalents

m = sum(isnan(table2array(dat)))==size(dat,1);
if sum(m)
    optss = setvartype(opts,'string');
    dats = readtable(filename, optss);
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
% concatentate table2 onto end of table1
% matching variable names (and units, if applicable) and adding new
% variables as necessary
% may also change type of variable if necessary
%
% ***keep track of rearrangements and put info in header?

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
