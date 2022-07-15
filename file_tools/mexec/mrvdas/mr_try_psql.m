function varargout = mr_try_psql(sqltext)
% constructs psql string and tries with and without LD_LIBRARY PATH

m_common

sqlroot = ['psql -h ' MEXEC_G.RVDAS.machine ' -U ' MEXEC_G.RVDAS.user ' -d ' MEXEC_G.RVDAS.database];

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
    error('failed executing: %s', psql_string);
end

if nargout>0
    varargout{1} = result;
end
if nargout>1
    varargout{2} = psql_string;
end