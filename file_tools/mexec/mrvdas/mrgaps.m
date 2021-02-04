function mrgaps(varargin)
% function mrgaps(table,dn1,dn2,qflag,gap)
%
% *************************************************************************
% mexec interface for RVDAS data acquisition
% First drafts of scripts for start jc211 28 jan 2021, alongside in Stanley
% 
% Evolution on that cruise by bak, ylf, pa
% *************************************************************************
%
% Load data from rvdas into matlab and search for gaps of greater than
% 'gap' seconds. Calls mrload(table,dn1,dn2,qflag)
%
% Examples
%
%   mrgaps tsg 10     % Search for gaps longer than 10 seconds
%
%   mrgaps tsg q  10  % Setting  will suppress info about number of cycles
%                       loaded in call to mrload.
%
%   mrgaps tsg [2021 1 28 0 0 0] [2021 1 28 12 00 00] 60 % search for gaps
%                                                          longer than 60 
%                                                          seconds in a 
%                                                          time range.
%
% Input:
%
% The input arguments are parsed through mrparseargs. See the extensive
%   help in that function for descriptions of the arguments.
% table: is the rvdas table name or the mexec shorthand
% dn1 and dn2 are datevecs or datenums for the start and end of data.
%   Default is far in the past and far in the future, so the whole file is
%   searched.
% If qflag is 'q', fprintf will be suppressed. Default is ''.
% gap: search interval in seconds. Gaps in time longer than this 
%   are reported. Default is 10 seconds.
%
% Output:
%
% Listing to screen

m_common

argot = mrparseargs(varargin); % varargin is a cell array, passed into mrparseargs
table = argot.table;
qflag = argot.qflag;

if length(argot.othernums) < 1
    gap = 10; % seconds default
else
    gap = argot.othernums(1);
end

def = mrdefine;

switch length(argot.dnums)
    case 2
        dn1 = argot.dnums(1);
        dn2 = argot.dnums(2);
    case 1
        dn1 = argot.dnums(1);
        dn2 = now+50*365; % far in future
    case 0
        dn1 = now-50*365; % far in past
        dn2 = now+50*365; % far in future
end

[d,n,u] = mrload(table,dn1,dn2,qflag);

mtime = d.dnum;
mtime = [dn1 ; mtime(:) ; dn2];
dtime = diff(mtime)*86400;

kgaps = find(dtime > gap);
ng = length(kgaps);



yyyy = MEXEC_G.MDEFAULT_DATA_TIME_ORIGIN(1);
doffset = datenum([yyyy 1 1 0 0 0]);

fprintf(MEXEC_A.Mfidterm,'\n%s %s %d %s %s %s\n\n',table,' has ',ng,' gaps greater than ',num2str(gap),' seconds');

for k = 1:ng
    t1 = mtime(kgaps(k)); 
    t2 = mtime(kgaps(k)+1);
    dt = dtime(kgaps(k));
    daynum1 = floor(t1) - doffset + 1;
    daynum2 = floor(t2) - doffset + 1;
    str1 = datestr(t1,'yy/mm/dd');
    str1a = datestr(t1,'HH:MM:SS');
    daystr1 = sprintf('%03d',daynum1);
    str2 = datestr(t2,'yy/mm/dd');
    str2a = datestr(t2,'HH:MM:SS');
    daystr2 = sprintf('%03d',daynum2);
    % don't print the actual time if the end of the last gap was the end
    % of the search interval, since to do so might imply data started again
    % fill the elements of the end time string with other text. Likewise
    % at the start of the search period
    if kgaps(k)+1 == length(mtime)
        daystr2 = 'end';
        str2a = 'search  ';
        str2 = 'period  ';
    end
    if kgaps(k) == 1
        daystr1 = 'search';
        str1a = 'period  ';
        str1 = '  start ';
    end
    % use %6s on daystr1 to fake the "start search period" format
    fprintf(MEXEC_A.Mfidterm,'%11s  %8s%6s %8s  %s  %3s %8s   %8s %15.3f %s\n','time gap : ',str1,daystr1,str1a,'to',daystr2,str2a,str2,dt,'seconds');
end
    






return