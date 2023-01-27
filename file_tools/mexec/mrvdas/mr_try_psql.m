function varargout = mr_try_psql(sqltext)
% constructs psql string and tries with and without LD_LIBRARY PATH

m_common

%if we haven't checked before this session, first see if we're connected to
%the database, and if we have a .pgpass file with the correct permissions
%and entries 
if ~isfield(MEXEC_G.RVDAS, 'checked') || ~MEXEC_G.RVDAS.checked

    [stat, ~] = system(['ping ' MEXEC_G.RVDAS.machine ' -c 1']);
    if stat~=0
        [stat, ~] = system(['ping ' MEXEC_G.RVDAS.machine ' -c 10']);
        if stat~=0
            error('%s not responding, cannot access RVDAS database', MEXEC_G.RVDAS.machine);
        end
    end
    
    [stat, result] = system('ls -l ~/.pgpass');
    if stat~=0 || ~strcmp(result(5:10),'------')
        error('your ~/.pgpass file is not found or has group or world access;\n %s','try (in shell): chmod 0600 ~/.pgpass');
    end
    
    fid = fopen('~/.pgpass','r');
    MEXEC_G.RVDAS.checked = 0;
    while fid>0
        tline = fgetl(fid);
        if isempty(tline)
            fclose(fid); fid = -2;
        elseif contains(tline,MEXEC_G.RVDAS.machine) && contains(tline,MEXEC_G.RVDAS.database(2:end-1)) && contains(tline,MEXEC_G.RVDAS.user)
            MEXEC_G.RVDAS.checked = 1;
            fclose(fid); fid = -2;
        end
    end
    if ~MEXEC_G.RVDAS.checked
        error('your ~/.pgpass file does not appear to contain an entry with the correct\n%s\n%s','machine, database, and/or user','(format should be: machine:port:database:user:password)');
    end
end
        
%now construct the string and try first without then with changes to
%LD_LIBRARY_PATH
sqlroot = [MEXEC_G.RVDAS.psql_path 'psql -h ' MEXEC_G.RVDAS.machine ' -U ' MEXEC_G.RVDAS.user ' -d ' MEXEC_G.RVDAS.database];
 
psql_string = [sqlroot ' -c ' sqltext ];  

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

if nargout>0
    varargout{1} = result;
end
if nargout>1
    varargout{2} = psql_string;
end
