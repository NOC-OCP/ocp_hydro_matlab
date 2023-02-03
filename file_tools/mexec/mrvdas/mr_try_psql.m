function [csvname, result, psql_string] = mr_try_psql(sqltext)
% constructs psql string and tries with and without LD_LIBRARY PATH
% psql string is constructed by combining: 
% 1) the database/access information, set here (using mrvdas_ingest,
%   rvdas_database cruise options);
% 2) the query in sqltext specifying what to get from what table
% 3) the csv file to which to write output, set here (using mrvdas_ingest,
%   rvdas_database cruise options)
%

m_common
scriptname = 'mrvdas_ingest'; oopt = 'rvdas_database'; get_cropt

%if we haven't checked before in this session, first see if we're connected to
%the database, and if we have a .pgpass file with the correct permissions
%and entries 
if ~isfield(MEXEC_G,'RVDAS_checked') || ~MEXEC_G.RVDAS_checked

    [stat, ~] = system(['ping ' RVDAS.machine ' -c 1']);
    if stat~=0
        [stat, ~] = system(['ping ' RVDAS.machine ' -c 10']);
        if stat~=0
            error('%s not responding, cannot access RVDAS database', RVDAS.machine);
        end
    end
    
    [stat, result] = system('ls -l ~/.pgpass');
    if stat~=0 || ~strcmp(result(5:10),'------')
        error('your ~/.pgpass file is not found or has group or world access;\n %s','try (in shell): chmod 0600 ~/.pgpass');
    end
    
    fid = fopen('~/.pgpass','r');
    MEXEC_G.RVDAS_checked = 0;
    while fid>0
        tline = fgetl(fid);
        if isempty(tline)
            fclose(fid); fid = -2;
        elseif contains(tline,RVDAS.machine) && contains(tline,RVDAS.database(2:end-1)) && contains(tline,RVDAS.user)
            MEXEC_G.RVDAS_checked = 1;
            fclose(fid); fid = -2;
        end
    end
    if ~MEXEC_G.RVDAS_checked
        error('your ~/.pgpass file does not appear to contain an entry with the correct\n%s\n%s','machine, database, and/or user','(format should be: machine:port:database:user:password)');
    end
end
        
%now construct the string and try first without then with changes to
%LD_LIBRARY_PATH
sqlroot = [RVDAS.psql_path 'psql -h ' RVDAS.machine ' -U ' RVDAS.user ' -d ' RVDAS.database];
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
