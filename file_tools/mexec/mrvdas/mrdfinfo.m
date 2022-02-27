function d = mrdfinfo(varargin)
% function d = mrdfinfo(table,qflag,fastflag)
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
%
% Output:
%
% structure d has times of first and last cycle, number of cycles, and
% table definition of names and units
% If fastflag is set and the table has no cycles, the numberof cycles is
%   reported as zero, and times are nan.
% If fastflag is set and the table has a first and last time, the number of
%   cycles is set to -1 and times are read from rvdas.

m_common

argot = mrparseargs(varargin); % varargin is a cell array, passed into mrparseargs
table = argot.table;
qflag = argot.qflag;
if length(argot.otherstrings) < 1
    fastflag = ''; 
else
    fastflag = argot.otherstrings{1};
end

% 
% if nargin < 1
%     error('error, no arguments in mrdfinfo')
% end

def = mrdefine;


% sort out the table name
table = mrresolve_table(table); % table is now an RVDAS table name for sure.
vdef = def.mrtables.(table);

rootcsv = [MEXEC_G.RVDAS_CSVROOT '/'];

csvname = [rootcsv table '_' datestr(now,'yyyymmddHHMMSSFFF') '.csv'];

sqlname = vdef{1,1};

sqlroot = ['psql -h ' MEXEC_G.RVDAS_MACHINE ' -U ' MEXEC_G.RVDAS_USER ' -d ' MEXEC_G.RVDAS_DATABASE];
sqlroot = ['psql -h ' '192.168.62.12' ' -U ' MEXEC_G.RVDAS_USER ' -d ' MEXEC_G.RVDAS_DATABASE];

% Number of cycles. Skip if fastflag is set to 'f'

if ~strcmp('f',fastflag)
    sqltext = ['\copy (select count(*) from ' sqlname ' ) to ''' csvname ''' csv '];
    psql_string = [sqlroot ' -c "' sqltext '"'];
    try
        [s1, ~] = system(psql_string);
        if s1~=0
            error('LD_LIBRARY_PATH?')
        end
    catch
        [s1, ~] = system(['unsetenv LD_LIBRARY_PATH ; ' psql_string]);
    end

    ncyc = load(csvname); % Should just load a number
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
    d.vdef = vdef;
    
    delete(csvname);

    return
    
end



% Earliest time

sqltext = ['\copy (select time from ' sqlname ' order by time asc limit 1) to ''' csvname ''' csv '];
psql_string = [sqlroot ' -c "' sqltext '"'];
try
    [s1, ~] = system(psql_string);
    if s1~=0
        error('LD_LIBRARY_PATH?')
    end
catch
    [s1, ~] = system(['unsetenv LD_LIBRARY_PATH ; ' psql_string]);
end
fid = fopen(csvname,'r');
t = fgetl(fid);  % t is now a RVDAS time string
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


% Latest time

sqltext = ['\copy (select time from ' sqlname ' order by time desc limit 1) to ''' csvname ''' csv '];
psql_string = [sqlroot ' -c "' sqltext '"'];
try
    [s1, ~] = system(psql_string);
    if s1~=0
        error('LD_LIBRARY_PATH?')
    end
catch
    [s1, ~] = system(['unsetenv LD_LIBRARY_PATH ; ' psql_string]);
end
fid = fopen(csvname,'r');
t = fgetl(fid);
fclose(fid);

dn2 = mrconverttime({t});


delete(csvname);

if isempty(qflag)
    fprintf(MEXEC_A.Mfidterm,'\n%s\n\n',table)
    fprintf(MEXEC_A.Mfidterm,'%s %s\n','File start ',datestr(dn1,31));
    fprintf(MEXEC_A.Mfidterm,'%s %s\n','File end   ',datestr(dn2,31));
    fprintf(MEXEC_A.Mfidterm,'%s %d\n\n','num cycles ',ncyc);
end



% now print names and units

vuse = vdef;
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




