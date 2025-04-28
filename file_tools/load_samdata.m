function [samtable, samhead] = load_samdata(infile, varargin)
% function [samtable, samhead] = load_samdata(infile, 'parameter', value)
% function [samtable, samhead] = load_samdata(infile, iopts)
%
% read in sample data from spreadsheet or comma delimited files listed in
%   cell array infile, 
% parses to find header or blank lines, column header line(s), units
%   line(s) if specified, and data lines,
% and outputs data as concatenated table samtable and header(s) in cell
%   array samhead 
%
%
% works on either:
%   single or concatenated csv files (that is, there can be more than one
%     occurrence of column header row(s), but all fields you wish to keep
%     must be present in the first one), or 
%   single or multiple sheets of a spreadsheet file, which may each have
%     different variables as well as different number of header lines
%
% optional inputs can be supplied in a structure or in some cases as
%   parameter-value pairs 
%
% optional inputs include: 
%   hcpat or numhead (if both are supplied, hcpat is ignored)
%     hcpat gives the contents of an indicative column header over one or
%     more rows, to be searched for (default: {}, don't search)
%     numhead sets how many lines to skip before column headers start on
%     the following line (default: 0) 
%   icolhead and icolunits or VariableNames and VariableUnits
%     if VariableNames are supplied, data are read starting on the line
%     after numhead, and the column order must be known/fixed
%     otherwise, column header line(s) start after numhead; icolhead gives
%     indices relative to numhead (with 1 being the line following numhead)
%     of column header lines and icolunits indices of column units lines 
%     contents of icolhead lines are turned into acceptable variable names
%     (leading and trailing whitespace removed, special characters and
%     other spaces replaced by '_') and made lowercase, while units are
%     ***; column order or variables present can be different on each
%     sheet.  
%     icolhead defaults to 1 or 1:length(hcpat), icolunits defaults to []
%   sheets giving the list of sheets to read in and append; if hcpat is
%     used, it will stop when it reaches a sheet where this pattern is not
%     found (i.e. detect when you've reached the end of the main data
%     sheets) 
%   other import options to be passed to readtable (these must be supplied
%     in a structure), e.g. VariableNamesLine/Range or
%     VariableUnitsLine/Range
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
%
% calls readtable and if that fails calls mtextdload (e.g. for
%   concatentated .csv files)

%inputs
n = 1;
while n<=nargin-1
    if isstruct(varargin{n})
        iopts = varargin{n};
        n = n+1;
    elseif ischar(varargin{n})
        nopts.(varargin{n}) = varargin{n+1};
        n = n+2;
    else
        error('input arguments can only be a structure and/or one or more parameter-value pairs')
    end
end
if exist('nopts','var')
    %combine types of inputs
    fn = fieldnames(nopts);
    for no = 1:length(nopts)
        iopts.(fn{no}) = nopts.(fn{no});
    end
end
if exist('iopts','var')
    %structure fields out into variables
    fn = fieldnames(iopts);
    eval(['[' strjoin(fn, ','), '] = deal(struct2cell(iopts));']);
else
    iopts = [];
end
if isfield(iopts,'VariableNames')
    iopts.icolhead = 0; %default: last line of header is column headers
elseif ~isfield(iopts,'icolhead')
    if ~isfield(iopts,'hcpat') || isempty(iopts.hcpat)
        iopts.icolhead = 1; %default: single column header line
    else
        iopts.icolhead = 1:length(iopts.hcpat); %default: all lines given in hcpat form column header
    end
end
if ~isfield(iopts,'VariableUnits') || ~isfield(iopts,'icolunits')
    iopts.icolunits = []; %default: no units line
end

warning('off','MATLAB:table:ModifiedAndSavedVarnames')
warning('off','MATLAB:textscan:AllNatSuggestFormat')

if ~iscell(infile)
    %loop length one
    infile = {infile};
end
for fno = 1:length(infile)

    %first try readtable
    [domtl, issh, sheetsl, fopts] = load_samdata_settableimport(infile{fno}, iopts);
    %loop through sheets
    for sno = 1:length(sheetsl)
        opts = fopts; clear ch un

        %read header
        if issh
            opts.Sheet = sheetsl{sno};
            hopts = opts; hopts.VariableTypes(:) = {'char'};
            hopts.DataRange = 'A1';
            if isfield(opts,'DataRange') %***
                he = str2double(opts.DataRange(2:end))-1;
            else
                he = inf;
            end
        else
            if isfield(opts,'DataLines')
                he = opts.DataLines(1)-1;
            else
                he = inf;
            end
            hopts.DataLines = [1 he];
        end
        hdr = readtable(infile{fno},hopts);
        hdr = hdr{:,:};
        if ~isfinite(he)
            %search for hcpat to find end of header
            [iih, ch, un] = sd_find_colhead(hdr, iopts.hcpat, iopts.icolhead, iopts.icolunits);
            if size(ch,1)>1
                if isss
                    error('header found more than once in spreadsheet file on sheet %s',sheetsl{sno});
                else
                    warning('looks like a concatenated file; trying mtextdload'); domtl = 1; break
                end
            elseif isempty(iih)
                if sno==1
                    error('did not find hcpat on sheet %s', sheetsl{sno});
                else
                    warning('did not find hcpat on sheet %s, stopping loop',sheetsl{sno}); break
                end
            else
                %succeeded; also adjust options for data
                he = iih(1)-1;
                if issh
                    opts.DataRange = ['A' num2str(iih(end)+1)]; %or 'row1:row2' can row2 be inf?
                else
                    opts.DataLines(1) = iih(end)+1;
                end
            end
        end
        if he>0
            samhead{fno} = hdr(1:he,:);
        else
            samhead{fno} = '';
        end

        %read data
        dat = readtable(infile{fno}, opts);
        %rename
        if isfield(iopts,'VariableNames')
            dat.Properties.VariableNames = iopts.VariableNames;
        elseif exist('ch','var')
            mc = ~cellfun('isempty',ch);
            dat = dat(:,mc);
            dat.Properties.VariableNames = ch(mc);
        end
        if isfield(iopts,'VariableUnits')
            dat.Properties.VariableUnits = iopts.VariableUnits;
        elseif exist('un','var') && ~isempty(iopts.icolunits)
            dat.Properties.VariableUnits = un;
        end
        %only keep rows with some numeric (non-nan) data
        mr = sum(~ismissing(dat),2)>0;
        dat = dat(mr,:);        
        %add to samtable
        if ~exist('samtable', 'var')
            samtable = dat;
        else
            %append, matching variables and adding new ones as necessary
            samtable = sd_combine_tables(samtable, dat);
        end

    end %loop through sheets
    
    if domtl
        if isempty(hcpat)
            warning('input hcpat required for mtextdload branch of load_samdata')
            warning('skipping %s',infile{fno})
        else
            warning('readtable failed; using mtextdload')
            [dat, sh] = load_samdata_loadtextcsv(infile{fno}, hcpat, icolhead, icolunits);
            if ~exist('samtable', 'var')
                samtable = dat;
            else
                samtable = sd_combine_tables(samtable, dat);
            end
            samhead(fno) = sh;
        end
    end
    
    disp(['loaded ' infile{fno}])
    
end %loop through files

warning('on','MATLAB:table:ModifiedAndSavedVarnames')
warning('on','MATLAB:textscan:AllNatSuggestFormat')


%%%%%%%%%%%%%%%%%%% subfunctions %%%%%%%%%%%%%%%%%%

function [domtl, issh, sheetsl, opts] = load_samdata_settableimport(infile, iopts)
%try to set import options for each file

domtl = 0;
try
    opts = detectImportOptions(infile);
catch
    domtl = 1; sheetsl = []; return
end

[~,~,ext] = fileparts(infile);
if strncmp(ext(2:end),'xls',3)

    issh = 1;
    sheetsl = sheetnames(infile);
    if isfield(iopts,'sheets')
        sheetsl = sheetsl(sheets);
    end
    try
        %overwrite from iopts
        fn = intersect(fieldnames(iopts),fieldnames(opts));
        for no = 1:length(fn)
            opts.(fn{no}) = iopts.(fn{no});
        end
        if isfield(iopts,'numhead')
            %force where to start reading
            if isempty(iopts.icolhead)
                opts.VariableNamesLine = iopts.numhead; 
                opts.DataRange = ['A' num2str(iopts.numhead+1)];
            else
                if isscalar(iopts.icolhead)
                    opts.VariableNamesLine = iopts.numhead + iopts.icolhead;
                end
                if isscalar(opts.icolunits)
                    opts.VariableUnitsLine = iopts.numhead + iopts.icolunits;
                end
                opts.DataRange = ['A' num2str(iopts.numhead+max(iopts.icolhead,iopts.icolunits)+1)];
            end
        end
    catch
        domtl = 1; sheetsl = []; %skip to loading as text csv
    end

else
    %text csv
    issh = 0;
    sheetsl = {' '};
    if exist('numhead','var')
        opts.NumHeaderLines = numhead;
        opts.DataLines(1) = numhead+1;
    end
end
if ~isfield(iopts,'DateLocale')
    %let user parse datetimes as we may not have information on locale in file
    m = strcmp('datetime',opts.VariableTypes);
    opts.VariableTypes(m) = {'char'};
end


function [samtable, samhead] = load_samdata_loadtextcsv(infile, hcpat, icolhead, icolunits)
maxcol = 2e3;
%load as cell array
indata = mtextdload(infile, ',', maxcol);
[iih, ch, un] = sd_find_colhead(indata, hcpat, icolhead, icolunits);
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
        samtable = sd_combine_tables(samtable, dat);
    end
end
if ~exist('samtable','var')
    samtable = [];
end
if ~exist('samhead','var')
    samhead = [];
end