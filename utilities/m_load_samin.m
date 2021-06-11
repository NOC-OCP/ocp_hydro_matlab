function [ds, hs] = m_load_samin(infile, hcpat, varargin)
% function [ds, hs] = m_load_samin(infile, hcpat)
% function [ds, hs] = m_load_samin(infile, hcpat, 'parameter', value)
%
% read in comma delimited files containing analysed sample data
% using mtextdload, then parse to find header or blank lines, column header
% line(s), and data lines
% header lines go into hs.header as text (sprintf(hs.header) to display)
% column header lines are combined (by default) and go into hs.colhead, as
% well as becoming fieldnames for dataset ds containing data (after being
% lower cased, having leading and trailing whitespace removed, and having
% other spaces and special characters replaced by '_' )
%
% works on single or concatenated files (there can be more than one
% occurrence of column header row(s), but all fields you wish to keep must
% appear in the first instance)
%
% if you know you only have one block of data, to save time you can supply
% the parameter-value pair 'single_block', 1
%
% hcpat gives the contents of an indicative column header over one or more
% rows; the number of elements in hcpat determines how many rows are in each
% column header before switching to data rows
%
% to use only the first N column header rows as data fieldnames,
% supply the parameter-value pair 'chrows', N (where N<=length(hcpat))
%
% to also save column units found in the Pth row of the column header rows
% as hs.colunt, supply the parameter-value pair
% 'chunits', P
%
% examples:
%
% 1) autosal salinity file with a sampnum column added, e.g.
%     SALINITY DATA FILE
%     Cruise Number: JC211
%     Crate: 6
%     Operator: DM
%     Date: 10 Feb 2021
%     Time: 06:53
%     Salinometer S/N: 71126
%     ZERO Reading -0.00005
%     Reference Value: 6150, Bath Temperature: 24<B0>C
%     Bottle number, Date, Time, Sample 1, Sample 2, Sample 3, Average offset, Salinity, sampnum
%     STD_900, 10/02/2021, 07:01:31, 1.999666, 1.999692, 1.999684, 1.999681, 0.000003, 34.9938, 999000
%     CTD_164, 10/02/2021, 07:08:53, 1.983232, 1.983257, 1.983261, 1.983250, 0.000003, 34.6707, 301
%
% [ds, hs] = m_parse_samin(infile, {'sampnum'});
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
% [ds, hs] = m_parse_samin(infile, {'Niksin'; 'Bottle'; 'Number'}, 'chrows', 2, 'chunits', 3);
%
%
% in theory this could be done with tableread, but since files often have
% irregularities that break that, it doesn't seem worthwhile

warning('off','all')
mver = version('-release');
if str2num(mver(1:4))>=2021 || strcmp(mver,'2020b')
    pver = 1;
else
    pver = 0;
end

single_block = 0; chrows = length(hcpat); %defaults
for no = 1:2:length(varargin)
    eval([varargin{no} '= varargin{no+1};'])
end

%load as Nx1 cell array
indata = mtextdload(infile);

%parse to find column header rows and data rows
nrows = length(indata);
ltype = zeros(nrows,1); %overall header (as opposed to column header) rows will stay 0
iih = []; iih0 = inf;
kskip = [];
for k = 1:nrows-length(hcpat)
    if ~ismember(k,kskip)
        %each row in hcpat describes what to search for in successive
        %rows of indata
        hm = true(size(indata{k}));
        for hno = 1:length(hcpat)
            nc = min(length(indata{k}),length(indata{k+hno-1}));
            hm(1:nc) = (hm(1:nc) & strncmp(hcpat{hno}, indata{k+hno-1}(1:nc), length(hcpat{hno})));
        end
        iih = find(hm); %column index for the indicative column
        if ~isempty(iih)
            ltype(k) = 1; %column header row
            iih0 = iih; %store, to use to check data rows (as opposed to header/blank rows)
            if length(hcpat)>1 %next rows are also part of the column header and already parsed
                ltype(k+[1:length(hcpat)-1]) = 1.5; %column header rows, but not new blocks
                kskip = [kskip k+[1:length(hcpat)-1]];
            end
            if single_block
                %now that we've found one set of column header rows, rest must be data
                ltype(k+length(hcpat):end) = 2;
                %except possibly last row
                if length(indata{end})<iih0 || isnan(str2double(indata{end}{iih0}))
                    ltype(end) = 0;
                end
                break;
            end
        elseif length(indata{k})>=iih0 && ~isnan(str2double(indata{k}{iih0})) %there's a number in the test column
            ltype(k) = 2; %data
        end
    end
end
if ~single_block
    for k = nrows-length(hcpat)+1:nrows
        if ~ismember(k,kskip)
            if length(indata{k})>=iih0 && ~isnan(str2double(indata{k}{iih0})) %there's a number in the test column
                ltype(k) = 2; %data
            end
        end
    end
end

if sum(ltype==1)==0
    error('no column header row found; check file vs input argument hcpat (check whitespace)')
end

%header info
ii0 = find(ltype==0)';
hs.header = [];
for no = ii0
    h = indata{no};
    for hno = 1:length(h)
        hs.header = [hs.header h{hno} ', '];
    end
    hs.header = [hs.header(1:end-2) ' \n'];
end
hs.header = hs.header(1:end-2);

%column header info; replace special characters and handle whitespace
ii1 = find(ltype>=1 & ltype<2)'; ii1 = ii1(1:length(hcpat));
for no = 1:length(ii1)
    hs.colhead(no,:) = parse_vnames(indata{ii1(no)});
end

%units
if exist('chunits','var') && ~isempty(chunits) && chunits>0
    h = indata{ii1(chunits)};
    for no = 1:length(h)
        if pver
            hs.colunit{no} = replace(h{no},whitespacePattern,''); %removes not only spaces but tabs
        else
            hs.colunit{no} = replace(h{no}," ",''); %removes spaces
        end
    end
end

%fieldnames
for no = 1:length(hs.colhead(1,:))
    a = hs.colhead(1:chrows,no);
    ch{no} = lower(sprintf('%s_', a{:}));
    %remove extra and trailing _
    ch{no} = replace(ch{no},'__','_');
    if strcmp(ch{no}(end), '_')
        ch{no} = ch{no}(1:end-1);
    end
    if isempty(ch{no}) || strcmp(ch{no},'_')
        error(['header for column ' num2str(no) ' has no non-special characters; maybe you have excess empty columns in file ' infile])
    end
end

%initialise dataset and populate
ds = dataset;
iih = [find(ltype==1); nrows+1];
for rno = 1:length(iih)-1 %step through blocks
    
    %find the sample lines for this block
    iis = find(ltype==2);
    iis = iis(iis>iih(rno) & iis<iih(rno+1));
    
    %find the relevant columns for this block
    for crno = 1:chrows
        h(crno,:) = parse_vnames(indata{iih(rno)+crno-1});
    end
    
    ls = size(ds,1);
    for cno = 1:length(ch)
        iic = true(1,size(h,2));
        for crno = 1:chrows
            iic = iic & strcmpi(hs.colhead{crno,cno}, h(crno,:));
        end
        iic = find(iic);
        
        if length(iic)==1
            %fill in values, row by row
            for sno = 1:length(iis)
                dat = indata{iis(sno)}{iic};
                if ~isempty(dat)
                    datt = replace(replace(dat,{'N/A';'#N/A';'#REF!'},'NaN'),{'/';':'},' ');
                    datt = str2num(datt);
                    if length(datt)~=1
                        datt = indata{iis(sno)}(iic);
                    end
                    try
                        ds.(ch{cno})(ls+sno,1) = datt;
                    catch
                        disp('unrecognised field'); disp(datt); disp(infile);
                        keyboard
                    end
                end
            end
        else %this variable isn't present in this block; fill
            ds.(ch{cno})(ls+[1:length(iis)],1) = NaN(length(iis),1);
        end
        
    end
    
end

[~,ii] = setdiff(ch,ds.Properties.VarNames);
if isfield(hs,'colunit')
    hs.colunit(ii) = [];
end

warning('on','all')


function namecell = parse_vnames(namecell)
% function namecell = parse_vnames(namecell);
% remove leading and trailing whitespace, and replace internal whitespace
% and special characters with '_', for each element of namecell so that
% they can serve as variable names

npat = cellstr(['()+=-/:.?><][{}#~$%^&*!;']');
npat = [npat; ' '];

for no = 1:length(namecell)
    
    nc = namecell{no};
    
    %remove leading and trailing whitespace
    iis = strfind(nc,' ');
    if ~isempty(iis) && length(iis)<length(nc)
        iic = setdiff(1:length(nc),iis);
        nc(iis(iis<iic(1) | iis>iic(end))) = [];
    end
    
    %replace special characters and internal whitespace
    nc = replace(nc, npat, '_');
    
    namecell{no} = nc;
    
end
