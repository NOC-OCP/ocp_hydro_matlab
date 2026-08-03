function d = mrdfinfo(varargin)
% function d = mrdfinfo(table,qflag,fastflag,mrtv)
%
% *************************************************************************
% mexec interface for RVDAS data acquisition
% First drafts of scripts for start jc211 28 jan 2021, alongside in Stanley
% 
% Evolution on that cruise by bak, ylf, pa
% *************************************************************************
% 
% Get info about the start and end times of an RVDAS table, number of
% cycles, and the variable names and units.
%
% Examples
%
%   dd = mrdfinfo('pospmv','q','f');
%
%   mrdfinfo pospmv;
%
%   mrdfinfo pospmv q; dd = ans;
%
% Input:
%
% table: is the RVDAS table name or the mexec shorthand.
% qflag will suppress fprintf within the function if set to 'q'.
% fastflag will save time counting the number of cycles if set to 'f'.
%try
% Output:
%
% structure d has times of first and last cycle, number of cycles, and
% table definition of names and units
% If fastflag is set and the table has no cycles, the numberof cycles is
%   reported as zero, and times are nan.
% If fastflag is set and the table has a first and last time, the number of
%   cycles is set to -1 and times are read from rvdas.

m_common

if nargin>0 && strcmp(varargin{1},'noparse')
    %parameter-value inputs, must include table and mrtv
    for no = 2:2:length(varargin)
        eval([varargin{no} '= varargin{no+1};']);
    end
    if ~exist('fastflag','var'); fastflag = ''; end
else
    argot = mrparseargs(varargin); % varargin is a cell array, passed into mrparseargs
    rtable = argot.table;
    qflag = argot.qflag;
    mrtv = argot.mrtv;
    if length(argot.otherstrings) < 1
        fastflag = ''; 
    else
        fastflag = argot.otherstrings{1};
    end
end
if exist('qflag','var') && isempty(qflag)
    quiet = 0;
else
    quiet = 1;
end

% sort out the table name
rtable = mrresolve_table(rtable); % table is now an RVDAS table name for sure.
sqlname = rtable; 
%sqlname = mrtv.tablenames(strcmp(table,mrtv.tablenames)); %***construct differently for sda?

% Number of cycles. Skip if fastflag is set to 'f'
if ~strcmp('f',fastflag)
    sqltext = ['"\copy (select count(*) from ' sqlname ' ) to '''];
    [csvname, ~, ~] = mr_try_psql(sqltext,quiet);
    % bak on dy174 27 March 2024
    % It seems that the csv file now consists of 2 lines, the first line
    % contains the string 'count' and the second lien contains the number
    % we want. So load it all as a txt file and parse the last line
    fidcount = fopen(csvname,'r');
    while 1
        tline = fgetl(fidcount);
        if ~ischar(tline), break, end
        txtend = tline;
    end
    fclose(fidcount);
    ncyc = str2double(txtend);

%     ncyc = load(csvname); % Should just load a number
else
    ncyc = -1;
end

if isempty(ncyc) || ncyc == 0
    dn1 = nan;
    dn2 = nan;
%     fprintf(MEXEC_A.Mfidterm,'\n%s\n\n',table)
%     fprintf(MEXEC_A.Mfidterm,'%s %d\n\n','num cycles ',ncyc);
    d.dn1 = dn1;
    d.dn2 = dn2;
    d.ncyc = ncyc;
    d.vdef_expl = 'rvdas variables, mstar variables, mstar units';
    m = strcmp(rtable,mrtv.tablenames);
    d.vdef = [mrtv.tablevars{m}; mrtv.mstarvars{m}; mrtv.mstarunts{m}];
    
    delete(csvname);

    return
    
end
delete(csvname);



% Earliest time

% sqltext = ['"\copy (select time from ' sqlname ' order by time asc limit 1) to ''' csvname ''' csv "'];
sqltext = ['"\copy (select time from ' sqlname ' order by time asc limit 1) to '''];
[csvname, ~, ~] = mr_try_psql(sqltext,quiet);
fid = fopen(csvname,'r');
% t = fgetl(fid);  % t is now a RVDAS time string
while 1
    tline = fgetl(fid);
    if ~ischar(tline), break, end
    t = tline;
end
fclose(fid);

if ~ischar(t)
    % no cycles returned so csv file has zero bytes and t is numeral -1
    dn1 = nan;
    dn2 = nan;
    d.dn1 = dn1;
    d.dn2 = dn2;
    d.ncyc = 0;
    d.vdef = vdef;
    
    delete(csvname);

    return
end

dn1 = mrconverttime({t});
delete(csvname);


% Latest time

% sqltext = ['"\copy (select time from ' sqlname ' order by time desc limit 1) to ''' csvname ''' csv "'];
sqltext = ['"\copy (select time from ' sqlname ' order by time desc limit 1) to '''];
[csvname, ~, ~] = mr_try_psql(sqltext,quiet);
fid = fopen(csvname,'r');
% t = fgetl(fid);  % t is now a RVDAS time string
while 1
    tline = fgetl(fid);
    if ~ischar(tline), break, end
    t = tline;
end
fclose(fid);

dn2 = mrconverttime({t});


delete(csvname);

if isempty(qflag)
    fprintf(MEXEC_A.Mfidterm,'\n%s\n\n',rtable)
    fprintf(MEXEC_A.Mfidterm,'%s %s\n','File start ',datestr(dn1,31));
    fprintf(MEXEC_A.Mfidterm,'%s %s\n','File end   ',datestr(dn2,31));
    fprintf(MEXEC_A.Mfidterm,'%s %d\n\n','num cycles ',ncyc);
end



% now print names and units
m = find(strcmp(rtable,mrtv.tablenames));
vuse = [mrtv.tablevars{m}' mrtv.tableunts{m}' mrtv.mstarvars{m}' mrtv.mstarunts{m}'];
vuse{1,1} = 'time';
vuse{1,2} = 'string';

d.dn1 = dn1;
d.dn2 = dn2;
d.ncyc = ncyc;
d.vdef = vuse;

if ~isempty(qflag)
    return % skip printing
end

for kl = 1:size(vuse,1)
    pad = '                                                            ';
    q = '''';
    s1 = vuse{kl,1}; s1 = [pad q s1 q]; s1 = s1(end-30:end);
    s2 = vuse{kl,2}; s2 = [q s2 q pad]; s2 = s2(1:30);
    
    fprintf(MEXEC_A.Mfidterm,'%s %s %s\n',s1,':',s2);
end


return




