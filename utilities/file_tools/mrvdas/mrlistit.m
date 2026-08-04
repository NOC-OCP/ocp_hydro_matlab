function mrlistit(varargin)
% function mrlistit(table,interval,dn1,dn2,qflag,varlist)
%
% *************************************************************************
% mexec interface for RVDAS data acquisition
% First drafts of scripts for start jc211 28 jan 2021, alongside in Stanley
% 
% Evolution on that cruise by bak, ylf, pa
% *************************************************************************
%
% Load data from rvdas into matlab and list it to the screen. 
%   Calls mrload(table,dn1,dn2,qflag,varlist)
%   
%
% Examples
%
%   mrlistit surfmet 120 now-1/24 now 'flow' q % get the last hour of data at 2 minute intervals
%
%   mrlistit surfmet 60 [28 0 0 0] [29 0 0 0] % print all variables of 1-minute data for day 28
%
%   mrlistit('surfmet',60,[28 0 0 0],[29 0 0 0],'flow,fluor','q'); 
%
% Input:
%
% The input arguments are parsed through mrparseargs. See the extensive
%   help in that function for descriptions of the arguments.
%
% The arguments can be provided in any order, except that dn1 must come
%   before dn2. The table, interval, qflag and varlist will be found by
%   mrparseargs.
%
% table: is the rvdas table name or the mexec shorthand
% interval: listing interval. The function steps through the file in 
%   steps of 'interval' seconds, starting at dn1, and in each interval 
%   prints the earliest cycle found.  If no data are found in an interval,
%   nothing is printed for that interval.
% dn1 and dn2 are datevecs or datenums for the start and end of data.
%   Default is far in the past and far in the future, so the whole file is
%   listed.
% If qflag is 'q', fprintf will be suppressed in the call to mrload. Default is ''.
% varlist is a list of rvdas variable names to be loaded. Default is all.
%
% Output:
%
% Listing to screen

m_common

argot = mrparseargs(varargin); % varargin is a cell array, passed into mrparseargs

if length(argot.othernums) < 1
    tint = 0; % print all by default
else
    tint = argot.othernums(1); % seconds
end

tintd = tint/86400; % days

[d,n,u] = mrload('noparse',argot);
varstring = argot.otherstrings;

% find the dnum
kdnum = find(strcmp('dnum',n));
% for the rest, add the rvdas name if it appears in the varlist
kvaruse = kdnum;
for kl = 1:length(n)
    if kl == kdnum; continue; end
    if ~isempty(strfind(varstring,n{kl})); kvaruse = [kvaruse kl]; end
end

% if no matches found in user supplied list of variables, print them all
if length(kvaruse) == 1
    kall = setdiff(1:length(n),kdnum);
    kvaruse = [kvaruse kall(:)'];
end


% now step through times. For each time interval, print the first cycle that
% falls in that time interval.


mtime = d.dnum;
kprint = [];
if tintd == 0 % print all
    kprint = 1:length(d.dnum);
else
    tstart = dn1+tintd*floor((mtime(1)-dn1)/tintd);
    while tstart < mtime(end)
        tend = tstart+tintd;
        kok = find(mtime >= tstart & mtime < tend);
        if ~isempty(kok)
            kprint = [kprint ; kok(1)];
        end
        tstart = tend;
    end
end

% start with header, unitline and format for time, and then add other
% variables

header0 = '                       ';
header = '                   time';
header1 = '';
header2 = '';
unitline = 'yy-mo-dd dnum  hh:mm:ss';
format = '%23s'; % for date string

% now add header, unitline, output format, and a column of data, for each
% variable to be printed, not including dnum which is included always

kvaruse = kvaruse(:)';
varvals = [];
fprintf(MEXEC_A.Mfidterm,'\n')

for kv = kvaruse(2:end)
    % column headers
    vn = n{kv};
    vu = u{kv};
     
    if iscell(d.(vn))
        continue
    end
    varvals = [varvals d.(vn)(:)];% add this variable to the varvals array
    
    pad = '                                                         ';
    
    s1 = [pad vn]; s1 = s1(end-30:end);
    s2 = [vu pad];
    fprintf(MEXEC_A.Mfidterm,'%s %s %s\n',s1,' : ',s2);
    
    
    % create the column headers; Allow two rows per variable name
    % Make each line of text right-justified in the available 12 characters
    vnpad = [vn pad];
    vnp = reshape(vnpad(1:36)',[12 3])';
    vnp1 = vnp(1,:);
    vnp1 = [pad vnp1];
    while strcmp(vnp1(end),' '); vnp1(end) = []; end 
    if isempty(vnp1); vnp1 = pad; end
    vnp1 = vnp1(end-11:end);
    vnp2 = vnp(2,:);
    while ~isempty(vnp2) && strcmp(vnp2(end),' '); vnp2(end) = []; end
    vnp2 = [pad vnp2];
    vnp2 = vnp2(end-11:end);

    vupad = [vu pad];
    vup = vupad(1:12);
    while ~isempty(vup) && strcmp(vup(end),' '); vup(end) = []; end
    vup = [pad vup];
    vup = vup(end-11:end);

    
    
    headerstr1 = sprintf(' %12s',vnp1);
    header1 = [header1 headerstr1];
    headerstr2 = sprintf(' %12s',vnp2);
    header2 = [header2 headerstr2];
    
    
    
    unitstr = sprintf(' %12s',vup);
    unitline = [unitline unitstr];
    varform = ' %12.5f';
    format = [format varform];    
end
format = [format '\n']; % add the newline once all the variables have been added
fprintf(MEXEC_A.Mfidterm,'\n')

np = length(kprint);


yyyy = MEXEC_G.MDEFAULT_DATA_TIME_ORIGIN(1);
doffset = datenum([yyyy 1 1 0 0 0]);
fprintf(MEXEC_A.Mfidterm,'%s\n',[header0 header1]);
fprintf(MEXEC_A.Mfidterm,'%s\n',[header header2]);
fprintf(MEXEC_A.Mfidterm,'%s\n',unitline);

for kl = 1:np
    kuse = kprint(kl);
    dnum = mtime(kuse);
    day = floor(dnum)-doffset+1;
    str1 = datestr(dnum,'yy-mm-dd  ');
    str2 = sprintf('%03d',day);
    str3 = datestr(dnum,'  HH:MM:SS');
    str = [str1 str2 str3];    
    
    fprintf(MEXEC_A.Mfidterm,format,str,varvals(kuse,:));

end




return