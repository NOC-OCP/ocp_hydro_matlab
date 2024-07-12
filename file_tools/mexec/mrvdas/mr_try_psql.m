function [csvname, result, psql_string] = mr_try_psql(sqltext)
% constructs psql string and tries with and without LD_LIBRARY PATH
% psql string is constructed by combining: 
% 1) the database/access information, set here (using ship,
%   rvdas_database cruise options);
% 2) the query in sqltext specifying what to get from what table
% 3) the csv file to which to write output, set here (using ship,
%   rvdas_database cruise options)
%

m_common
opt1 = 'ship'; opt2 = 'rvdas_database'; get_cropt

%if we haven't checked before in this session, first see if we have the
%credentials, either in ~/.pgpass (with correct, user-only permissions) or
%in another (shared) file specified in opt_cruise 
if ~isfield(MEXEC_G,'RVDAS_checked') || isempty(MEXEC_G.RVDAS_checked)
    mrvdas_check(RVDAS);
end

%now construct the string and try first without then with changes to
%LD_LIBRARY_PATH
if ismac
    RVDAS.psql_path = '/usr/local/bin/';
else
    RVDAS.psql_path = ''; %'/usr/bin/' but on linux matlab finds it on path on its own
end
if isnumeric(MEXEC_G.RVDAS_checked)
    %use .pgpass
    sqlroot = [RVDAS.psql_path 'psql -h ' RVDAS.machine ' -U ' RVDAS.user ' -d ' RVDAS.database];
else
    %use credentials now stored in RVDAS_checked
    sqlroot = [RVDAS.psql_path 'psql ' MEXEC_G.RVDAS_checked];
end
csvname = fullfile(RVDAS.csvroot, ['table_' datestr(now,'yyyymmddHHMMSSFFF') '.csv']);
psql_string = [sqlroot ' -c ' sqltext csvname];
if ~contains(psql_string,'\dt') && ~contains(psql_string,'\dv')
    psql_string = [psql_string ''' csv header"'];
end

try
    [stat, result] = system(psql_string);
    if stat~=0
        error('LD_LIBRARY_PATH?')
    end
catch
    [stat, result] = system(['unsetenv LD_LIBRARY_PATH; ' psql_string]);
end

if stat~=0
    error('failed at executing\n %s\n does your ~/.pgpass contain the correct machine:port:database:user:password?', psql_string);
else
    disp(['ran: ' psql_string])
end
