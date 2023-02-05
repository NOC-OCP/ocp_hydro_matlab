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
% 
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

samhead = cell(length(infile),length(sheets));
maxsheets = 1;
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
        maxsheets = max(maxsheets,sno);
        
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
                maxsheets = max(maxsheets,bno);
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
samhead(:,maxsheets+1:end) = [];

warning('on','MATLAB:table:ModifiedAndSavedVarnames')
warning('on','MATLAB:textscan:AllNatSuggestFormat')
