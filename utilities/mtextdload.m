function c = mtextdload(infile,varargin)
%
% Use: c = mtextdload(infile,[delim],[dim])
%
% mtextdload: load text rows in file, and divide according to delimiter
%           matlab version of csvread only handles numeric data
%
% infile is any file name; contents must be rows of text
%               each row is unpacked around commas
% delim is a text delimiter used to divide input lines of text; default is comma
% dim specifies how to arrange output cell array c: 
%     0 (or not specified): output as nrows x 1 cell array, where each row
%         is itself a cell array containing text from each row of input
%         file
%     positive integer: output as nrows x max(ncols), where
%     max(ncols)<=dim, cell array, filling with empty string%

if nargin < 1
    error('No input file')
end
if ~exist(infile,'file')
    m = ['File ''' infile ''' does not exist'];
    m1 = sprintf('%s\n','',m);
    error(m1)
end

delim = ','; % default delimiter is comma
dim = 1;
if nargin>=2
    delim = varargin{1};
    if nargin>=3
        dim = varargin{2};
    end
end

if dim>0 %initialise
    nline1 = 2e3;
    c = repmat({''}, nline1, dim); %adding more rows shouldn't be a problem
    maxcol = 0;
end

fid = fopen(infile);
klines = 0;
while 1
    s = fgets(fid);
    if ~ischar(s); break; end
    klines = klines+1;
    knl = strfind(s,sprintf('\n')); s(knl) = []; % strip out newline chars
    kcr = strfind(s,sprintf('\r')); s(kcr) = []; % strip out carriage return chars
    kc = strfind(s,delim);
    
    kparts = 0;
    % bak on JC032: set cell to empty; relevant if not all lines have the
    % same number of parts.
    kcell = {};
    while length(kc) > 0
        kparts = kparts+1;
        kcell{kparts} = s(1:kc(1)-1);
        s(1:kc(1)) = [];
        kc = strfind(s,delim);
    end
    % now parse last part
    kparts = kparts+1;
    kcell{kparts} = s;
    if dim==0
        c{klines,1} = kcell;
    else
        nc = length(kcell);
        if nc>dim
            error([num2str(nc) ' columns on line ' num2str(klines) ' of file ' infile ', more than specified ' num2str(dim)])
        end
        c(klines,1:nc) = kcell;
        if klines>nline1
            c(klines,nc+1:end) = repmat({''}, 1, dim-nc);
        end
        maxcol = max(maxcol, nc);
    end
    
end
if dim>0
    c = c(1:klines,1:maxcol);
end

fclose(fid);
