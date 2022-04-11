function c = mtextdload(infile,delim)
%
% Use: c = mtextdload(infile,[delim])
%
% mcsvload: load text rows in file, and divide according to delimeter
%           matlab version of csvload only handles numeric data
%
% infile is any file name; contents must be rows of text
%               each row is unpacked around commas
% delim is a text delimeter used to divide input lines of text; default is comma
% output c is a cell array. Length(c) is the number of lines of text in the
%               input file; each row of cell c is a set of cells containing the text from
%               that row of the input file, divided at delimeter 'delim'
%

if nargin < 1
    error('No input file')
elseif nargin <2
    delim = ','; % default delimeter is comma
end

if ~exist(infile,'file')
    m = ['Error in mcsvload: File ''' infile ''' does not exist'];
    m1 = sprintf('%s\n','',m);
    error(m1)
end

fid = fopen(infile);
klines = 0;
while 1
    s = fgets(fid);
    if ~ischar(s); break; end
    klines = klines+1;
    if mod(klines,10000) == 0; disp(num2str(klines));end
%     knl = strfind(s,sprintf('\n')); s(knl) = []; % strip out newline chars
%     kcr = strfind(s,sprintf('\r')); s(kcr) = []; % strip out carriage return chars
%     kc = strfind(s,delim);
%     kparts = 0;
%     % bak on JC032: set cell to empty; relevant if not all lines ahve the
%     % same number of parts.
%     cell = {};
%     while length(kc) > 0
%         kparts = kparts+1;
%         cell{kparts} = s(1:kc(1)-1);
%         s(1:kc(1)) = [];
%         kc = strfind(s,delim);
%     end
%     % now parse last part
%     kparts = kparts+1;
%     cell{kparts} = s;
%     c{klines} = cell;

end
% c = c(:);

fclose(fid);
