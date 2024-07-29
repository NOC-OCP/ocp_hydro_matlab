function [csvname, result, psql_string] = mr_try_psql(sqltext,varargin)
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
quiet = 1; if nargin>1; quiet = varargin{1}; end

%if we haven't checked before in this session, first see if we have the
%credentials, either in ~/.pgpass (with correct, user-only permissions) or
%in another (shared) file specified in opt_cruise 
if ~isfield(MEXEC_G,'RVDAS_checked') || isempty(MEXEC_G.RVDAS_checked)
    mrvdas_check_dbaccess(RVDAS);
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
        warning('LD_LIBRARY_PATH?')
        [stat, result] = system(['unsetenv LD_LIBRARY_PATH; ' psql_string]);
        if stat~=0
            fid = fopen('/data/pstar/psqls_f','w');
            fprintf(fid,'%s\n',psql_string);
            fclose(fid);
            [s,r] = system('/usr/bin/chmod ug+x /data/pstar/psqls_f');
            if s==0
                [stat,result] = system('/data/pstar/psqls_f');
                if stat~=0
                    fprintf(1,'in terminal, execute /data/pstar/psqls_f \n then press enter to continue')
                    pause
                    if exist(csvname,'file')
                        stat = 0;
                    else
                        warning('check /data/pstar/psqls_f')
                    end
                end
            else
                keyboard
            end
        end
    end
catch
    keyboard
end

if stat~=0
    error('failed at executing\n %s\n does your ~/.pgpass or RVDAS login file contain the correct machine:port:database:user:password?', psql_string);
elseif ~quiet
    disp(['ran: ' psql_string])
end
