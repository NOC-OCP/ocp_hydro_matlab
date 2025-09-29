function [samtable, samhead] = load_samdata(infiles, varargin)
% function [samtable, samhead] = load_samdata(infiles, 'parameter', value)
% function [samtable, samhead] = load_samdata(infiles, iopts)
%
% reads in sample data from spreadsheet or comma delimited files,
% parses into header, column headers, column units, and data, 
% outputs data as concatenated table samtable and header in cell array
%   samhead
%
% data are read from from one or more single and/or concatenated (see
%   below) csv files, and/or one or more sheets of one or more spreadsheet
%   files
% infiles is a cell array list of filenames. without other input arguments,
%   data will be read using readtable. 
%
% optional inputs can be specified as a scalar structure or as
%   parameter-value pairs (if all inputs are laid out the same), or as a
%   vector structure (same length as infiles)
%
% infiles is a cell array list
% 
%
% concatenated csv files, see b  for concatenated csv files, calls mtextdload. 
%     requires: 
%       hcpat, the contents of an indicative column header over one or more
%         rows, to be searched for (default: {}, don't search). 
%     optional:
%       icolhead and icolunits, giving the indices from the start of the
%         first ocurrence of hcpat which correspond to variable names and
%         variable units, respectively.  
%     variable names line(s) will be parsed to Matlab variable names
%       (removing leading and trailing whitespace, replacing special
%       characters with '_')
%     e.g., for a file like: 
%       Cruise,JC211,,,,,,,,,,,,,
%       Cast,3,,,Analysis Set,,,,,,,Volume (ml),,,
%       Sampler,EPA,,,Analyst,YF,,,,Manganese Chloride,,1,,,
%       Sample Date,05/02/2021,,,Analysis Date,06/02/2021,,,,Alkaline Iodide ,,0.99,,,
%       Sample Time,2224,,,Analysis Time,1550,,,,Total,,1.99,,,
%       ,,,,,,,,,,,,,,
%       ,,,,,,,,,,,,,,
%       Cast,Niskin ,Depth,Bottle ,Bottle ,Blank,Std,Standard,Fixing,Botvol,Sample,Iodate,n(O2),C(O2),Notes
%       Number,Bottle,(m),No.,vol (25C),titre,vol,titre,temp,at Tfix,titre,molarity,,,
%       ,Number,,,mls,mls,mls,mls,C,mls,mls,M,moles,umol/l,
%       3,1,,1013,139.8594804,0.01394,5,0.4619,0.8,137.835634405743,1.445,0.001667,3.99406814224484E-05,289.218978780914,
%       3,5,,25,137.8955138,0.01394,5,0.4619,0.8,135.87214308566,1.5295,0.001667,4.22990644253951E-05,310.755858165685,
%       Cast,4,,,Analysis Set,,,,,,,Volume (ml),,,
%       Sample Date,05/02/2021,,,Analysis Date,06/02/2021,,,,Alkaline Iodide ,,0.99,,,
%       Sample Time,2224,,,Analysis Time,1550,,,,Total,,1.99,,,
%       Cast,Niskin ,Depth,Bottle ,Bottle ,Blank,Std,Standard,Fixing,Botvol,Sample,Iodate,n(O2),C(O2),Notes
%       Number,Bottle,(m),No.,vol (25C),titre,vol,titre,temp,at Tfix,titre,molarity,,,
%       ,Number,,,mls,mls,mls,mls,C,mls,mls,M,moles,umol/l,
%       4,2,,1013,139.8594804,0.01394,5,0.4619,0.8,137.835634405743,1.445,0.001667,3.99406814224484E-05,289.218978780914,
%       4,11,,25,137.8955138,0.01394,5,0.4619,0.8,135.87214308566,1.5295,0.001667,4.22990644253951E-05,310.755858165685,
%     [ds, hs] = load_samdata(infiles, 'hcpat', {'Niksin'; 'Bottle'; 'Number'}, 'icolhead', [1 2], 'icolunits', 3);
%     will return hs containing the lines 1-7 and first 7 lines, and table ds with
%     ds.Properties.VariableNames = {'cast_number', 'niskin_bottle', 'depth__m_', ...}
%     ds.Properties.VariableUnits = {'', 'number', '', ...}
%
%   for other files, calls readtable.
%   requires: 
%     numhead, how many lines to skip before column headers start
%   optional: 
%     icolhead and icolunits or VariableNames and VariableUnits
%       if VariableNames are supplied, data are read starting on the line
%         after numhead, and the column order must be known/fixed
%       otherwise, column header line(s) start after numhead; icolhead
%         gives indices relative to numhead (with 1 being the line
%         following numhead) of column header lines and icolunits indices
%         of column units lines (again relative to numhead). contents of
%         icolhead lines are turned into acceptable variable names (leading
%         and trailing whitespace removed, special characters and other
%         spaces replaced by '_') and made lowercase, while units are ***;
%         column order or variables present can be different on each sheet.
%       icolhead defaults to 1 or 1:length(hcpat), icolunits defaults to []
%   sheets (for spreadsheet files only), indices of sheets to read in and
%     append. this is only necessary if your data don't start on the first
%     sheet and end on the last. 
%   e.g., infiles as above
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
% [ds, hs] = load_samdata(infiles, 'hcpat', {'Niksin'; 'Bottle'; 'Number'}, 'icolhead', [1 2], 'icolunits', 3);
% or
% [ds, hs] = load_samdata(infiles, 'numhead', 7, 'icolhead', [1 2], 'icolunits', 3);
% will return hs containing the first 7 lines, and table ds with
% ds.Properties.VariableNames = {'cast_number', 'niskin_bottle', 'depth__m_', ...}
% ds.Properties.VariableUnits = {'', 'number', '', ...}
% or
% iopts.VariableNames = {'statnum','position','depth','obot','botvol','blank','stdvol','standard','fixtemp','botvol_tfix','titre','iodmol','n_O2','c_O2','notes'};
% [ds, hs] = load_samdata(infiles, iopts, 'numhead', 10);
% will return hs containing the first 10 lines, and table ds with
% ds.Properties.VariableNames = iopts.VariableNames
% ds.Properties.VariableUnits = {};
%
% in most cases uses readtable, but if usetextdload is set to 0 or if
%   readtable fails (e.g. for concatentated .csv files), calls mtextdload.m

warning('off','MATLAB:table:ModifiedAndSavedVarnames')
warning('off','MATLAB:textscan:AllNatSuggestFormat')

samhead = cell(length(infiles),1);

if ~iscell(infiles)
    %loop length one
    infiles = {infiles};
end

for fno = 1:length(infiles)

    if nargin>1 
        if iscell(varargin{1})
            %cell array of structures, one per file
            iopts = load_samdata_iopts(varargin{1}(fno));
        elseif fno==1
            %structure or parameter-value pairs, only need to parse once
            iopts = load_samdata_iopts(varargin);
        end
    else
        %just get the defaults
        iopts = load_samdata_iopts([]);
    end

    %can we use readtable? 
    [domtl, sheetsl] = load_samdata_checkrt(infiles{fno}, iopts);  

    if domtl
        warning('readtable failed; using mtextdload')
        [dat, sh] = load_samdata_loadtextcsv(infiles{fno}, iopts.hcpat, icolhead, icolunits);
        if ~exist('samtable', 'var')
            samtable = dat;
        else
            samtable = load_samdata_combine_tables(samtable, dat);
        end
        samhead(fno) = sh;

    else
        %use readtable; loop through sheets
        for sno = 1:length(sheetsl)
            %first read header
            [opts, hdr] = load_samdata_getopts(infiles{fno}, iopts, sheetsl{sno});
            if ~isempty(hdr)
                samhead(fno,sno) = hdr;
            end
            %next read data
            dat = readtable(infiles{fno}, opts);
            %overwrite names and units
            if isfield(iopts,'VariableNames')
                dat.Properties.VariableNames = iopts.VariableNames;
            elseif isfield(opts,'VariableNames')
                mc = ~cellfun('isempty',opts.VariableNames);
                dat = dat(:,mc);
                dat.Properties.VariableNames = opts.VariableNames(mc);
            end
            if isfield(iopts,'VariableUnits')
                dat.Properties.VariableUnits = iopts.VariableUnits;
            elseif isfield(opts,'VariableUnits') && ~isempty(iopts.icolunits)
                dat.Properties.VariableUnits = opts.VariableUnits;
            end
            %only keep rows with some numeric (non-nan) data
            mr = sum(~ismissing(dat),2)>0;
            dat = dat(mr,:);
            %add to samtable
            if ~exist('samtable', 'var')
                samtable = dat;
            else
                %append, matching variables and adding new ones as necessary
                samtable = load_samdata_combine_tables(samtable, dat);
            end
        end %loop through sheets
    end

    disp(['loaded ' infiles{fno}])

end %loop through files

warning('on','MATLAB:table:ModifiedAndSavedVarnames')
warning('on','MATLAB:textscan:AllNatSuggestFormat')


%%%%%%%%%%%%%%%%%%% subfunctions %%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function iopts = load_samdata_iopts(inargs)
%independent defaults
iopts.icolhead = 1; %first line is column headers
iopts.icolunits = []; %no units line
iopts.hcpat = {}; %don't search for hcpat
%inputs
if ~isempty(inargs)
    iopts = spv_argparse(iopts, inargs);
end
%dependent defaults
if isfield(iopts,'VariableNames')
    iopts.icolhead = 0; %default: last line of header is column headers and is ignored in favour of user-supplied names, or there is no column header row
end
if isempty(iopts.hcpat)
    if ~isfield(iopts,'numhead')
        iopts.numhead = 0; %can't set this before because it overrides hcpat
    end
elseif iopts.icolhead==1 && isempty(iopts.icolunits) && length(iopts.hcpat)>1
    iopts.icolhead = 1:length(iopts.hcpat); %all lines given in hcpat form column header
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [domtl, sheetsl] = load_samdata_checkrt(infile, iopts)
%check if readtable can be used, and find list of sheets if spreadsheet
%file

sheetsl = {0};
if isfield(iopts,'usetextdload') && iopts.usetextdload
    domtl = 1; return
else
    try
        detectImportOptions(infile);
        domtl = 0;
    catch
        domtl = 1; return
    end
end
[~,~,ext] = fileparts(infile);
if strncmp(ext(2:end),'xls',3)
    sheetsl = sheetnames(infile); %***
    if isfield(iopts,'sheets')
        sheetsl = sheetsl(iopts.sheets);
    end
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [opts, hdr] = load_samdata_getopts(infile, iopts, sheet)
% detect import options then overwrite from inputs
% use to read in header and find column headers if required

if sheet==0
    %text csv
    opts = detectImportOptions(infile);
    vnn = 'VariableNamesLine';
    vun = 'VariableUnitsLine';
else
    %spreadsheet
    opts = detectImportOptions(infile,'Sheet',sheet);
    vnn = 'VariableNamesRange';
    vun = 'VariableUnitsRange';
end
fn = intersect(fieldnames(iopts),fieldnames(opts));
for no = 1:length(fn)
    opts.(fn{no}) = iopts.(fn{no});
end

if isfield(iopts,'numhead') && isfinite(iopts.numhead)
    %force where to start reading
    searchhead = 0;
    if isempty(iopts.icolhead)
        opts.(vnn) = iopts.numhead;
        nd = iopts.numhead+1;
    else
        opts.(vnn) = iopts.numhead + iopts.icolhead;
        if ~isempty(iopts.icolunits)
            opts.(vun) = iopts.numhead + iopts.icolunits;
        end
        nd = iopts.numhead+max([iopts.icolhead(:);iopts.icolunits(:)])+1;
    end
    if sheet==0
        opts.DataLines(1) = nd;
        opts.NumHeaderLines = iopts.numhead;
    else
        opts.DataRange = ['A' num2str(nd)];
    end
else
    if isfield(iopts,'hcpat') && ~isempty(iopts.hcpat)
        %look for hcpat after reading header lines into cell
        searchhead = 1;
    else
        %use default import options (first line will be column headers?*** and no units)
        searchhead = 0;
    end
end

%read header
if sheet==0
    hdr = readcell(infile);
else
    hdr = readcell(infile,'Sheet',sheet);
end
if isfield(iopts,'numhead')
    if iopts.numhead==0
        hdr = {};
    else
        hdr = hdr{1:iopts.numhead,:};
    end
elseif searchhead
    %search for hcpat to find end of header
    [iih, ch, un] = load_samdata_find_colhead(hdr, iopts.hcpat, iopts.icolhead, iopts.icolunits);
    if size(ch,1)>1
        if sheet==0
            warning('looks like a concatenated file; trying mtextdload'); domtl = 1; return
        else
            warning('header found more than once in spreadsheet file on sheet %s',sheet); opts = []; return
        end
    elseif isempty(iih)
        warning('did not find hcpat on sheet %s, stopping loop',sheets); opts = []; return
    else
        %succeeded; also adjust options for data
        he = iih(1)-1;
        if issh
            opts.DataRange = ['A' num2str(iih(end)+1)]; %or 'row1:row2' can row2 be inf?
        else
            opts.DataLines(1) = iih(end)+1;
        end
    end
else
    hdr = {};
end

if ~isfield(iopts,'DateLocale') || isempty(iopts.DateLocale)
    %let user parse datetimes as we may not have information on locale in file
    m = strcmp('datetime',opts.VariableTypes);
    opts.VariableTypes(m) = {'char'};
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [samtable, samhead] = load_samdata_loadtextcsv(infile, hcpat, icolhead, icolunits)
maxcol = 2e3;
%load as cell array
indata = mtextdload(infile, ',', maxcol);
[iih, ch, un] = load_samdata_find_colhead(indata, hcpat, icolhead, icolunits);
nb = size(ch,1);
%figure out data indices
mn = sum(cellfun(@(x) ~isnan(str2double(x)), indata(10:end,:)),2);
iid1 = iih(:,end)+1;
iid2 = [iih(2:end,1)-1; find(mn>0, 1, 'last')];
%loop through blocks
samhead = cell(1,nb);
for bno = 1:nb
    dat = array2table(cellfun(@(x) str2double(x), indata(iid1(bno):iid2(bno),:)));
    dat.Properties.VariableNames = ch(bno,:);
    if ~isempty(icolunits)
        dat.Properties.VariableUnits = un(bno,:);
    end
    samhead{bno} = indata(iih(1,:),:);
    if ~exist('samtable','var')
        %initialise
        samtable = dat;
    else
        %append
        samtable = load_samdata_combine_tables(samtable, dat);
    end
end
if ~exist('samtable','var')
    samtable = [];
end
if ~exist('samhead','var')
    samhead = [];
end


function varargout = load_samdata_find_colhead(hdr, hcpat, icolhead, icolunits)
% function [iih, ch, un] = load_samdata_find_colhead(hdr, hcpat, icolhead, icolunits);
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

varargout = cell(1,nargout);

if np==0
    iih = 1:nhl;
else
    %header rows are those where one column matches rows of hcpat
    m = true(s(1)-np+1,s(2));
    for no = 1:np
        m = m & strcmp(hcpat{no}, hdr(no+(0:s(1)-np),:));
    end
    [iih,~] = find(m); %first row in each instance of header rows
    if isempty(iih)
        return
    end
    %now for each of these, keep as many following as needed for icolhead and
    %icolunits
    iih = repmat(iih,1,nhl)+repmat(0:nhl-1,length(iih),1);
    varargout{1} = iih;
end
nb = size(iih,1);

%convert the relevant rows from iih to matlab variable name forms
if nargout>1 && ~isempty(iih)
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
    end
    varargout{2} = ch;
    varargout{3} = un;
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function table1 = load_samdata_combine_tables(table1, table2)
% function table_out = load_samdata_combine_tables(table1, table2);
%
% concatentate table2 onto end of table1,
%   matching variable names (and units, if applicable) and adding new
%   variables where no match is found. may also change type of variable if
%   necessary
%

ch1 = table1.Properties.VariableNames;
ch2 = table2.Properties.VariableNames;
un1 = table1.Properties.VariableUnits;
un2 = table2.Properties.VariableUnits;
%compare table2 to table1: check units for same-name variables to make sure
%they can be concatenated
[~, iic1, iic2] = intersect(ch1, ch2, 'stable');
if ~isempty(iic1) && ~isempty(un1) && ~isempty(un2)
    iinu = find(~strcmp(un1(iic1), un2(iic2)));
    if ~isempty(iinu)
        %where names were the same but units were not, change names in
        %table2 (append units of "new" variable to its name to distinguish
        %from original)
        for cno = 1:length(iinu)
            ch2{cno} = [ch2{cno} '_' un2{cno}];
        end
        table2.Properties.VariableNames = ch2;
        %recalculate intersection
        [~, iic1, iic2] = intersect(ch1, ch2, 'stable');
    end
end

% pad beginning of table2 and end of table2 so they have the same rows
r1 = size(table1,1);
r2 = size(table2,1);
if isprop(table1.Properties,'VariableTypes')
    %R2025
    vt1 = strcmp('cell', table1.Properties.VariableTypes);
    vt2 = strcmp('cell', table2.Properties.VariableTypes);
else
    %R2023
    vt1 = structfun(@(x) iscell(x), table2struct(table1,'ToScalar',true));
    vt2 = structfun(@(x) iscell(x), table2struct(table2,'ToScalar',true));
end
table1 = table1([1:r1 repmat(r1,1,r2)],:);
table1{r1+1:end,vt1} = {''}; %cell doesn't allow 'missing'
table1{r1+1:end,~vt1} = missing;
table2 = table2([ones(1,r1) 1:r2],:);
table2{1:r1,vt2} = {''}; %cell doesn't allow 'missing'
table2{1:r1,~vt2} = missing;

%for same-name variables, fill in end rows in table1 with data from table2
iir2 = r1+1:r1+r2;
table1(iir2,iic1) = table2(iir2,iic2);

%for variables only in table2, add new columns to table1
m2 = ~ismember(ch2, ch1);
table1 = [table1 table2(:,m2)];
