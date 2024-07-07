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

    hasc = 0;
    
    %file with postgresql:// address(es)
    if isfield(RVDAS,'loginfile') && exist(RVDAS.loginfile,'file')
        fid = fopen(RVDAS.loginfile,'r');
        c = textscan(fid,'%s\n'); c = c{1};
        fclose(fid);
        while hasc==0 && ~isempty(c)
            if contains(c{1},RVDAS.database(2:end-1)) && contains(c{1},'postgresql')
                hasc = 1; MEXEC_G.RVDAS_checked = c{1};
                ii1 = findstr(c{1},'@');
                ii2 = [findstr(c{1},':') findstr(c{1},'/')];
                ii2 = ii2(ii2>ii1); ii2 = min(ii2);
                RVDAS.machine = c{1}(ii1+1:ii2-1);
            else
                c(1) = [];
            end
        end
    end

    %user's .pgpass
    if ~hasc
        if isfield(RVDAS,'machine') && isfield(RVDAS,'user')
            [stat, result] = system('ls -l ~/.pgpass');
            if stat==0 && strcmp(result(5:10),'------')
                fid = fopen('~/.pgpass','r');
                while fid>0
                    tline = fgetl(fid);
                    if isempty(tline)
                        fclose(fid); fid = -2;
                    elseif contains(tline,RVDAS.machine) && contains(tline,RVDAS.database(2:end-1)) && contains(tline,RVDAS.user)
                        MEXEC_G.RVDAS_checked = 1;
                        fclose(fid); fid = -2;
                    end
                end
            end
        end
    end

    if ~isfield(MEXEC_G,'RVDAS_checked') || isempty(MEXEC_G.RVDAS_checked)
        error('found no credentials for RVDAS server for this cruise')
    else
        %try connecting
        [stat, ~] = system(['ping ' RVDAS.machine ' -c 1']);
        if stat~=0
            [stat, ~] = system(['ping ' RVDAS.machine ' -c 10']);
            if stat~=0
                MEXEC_G.RVDAS_checked = 0;
                error('%s not responding, cannot access RVDAS database', RVDAS.machine);
            end
        end
    end

end
        
%now construct the string and try first without then with changes to
%LD_LIBRARY_PATH
if ismac
    RVDAS.psql_path = '/usr/local/bin/';
else
    RVDAS.psql_path = ''; %'/usr/bin/' but on linux matlab finds it on path on its own
end
if isnumeric(MEXEC_G.RVDAS_checked)
    sqlroot = [RVDAS.psql_path 'psql -h ' RVDAS.machine ' -U ' RVDAS.user ' -d ' RVDAS.database];
else
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
end

function check_rvdas