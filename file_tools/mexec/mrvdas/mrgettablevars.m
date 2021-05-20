function tablevars = mrgettablevars(table)
% function tablevars = mrgettablevars(table)
%
% *************************************************************************
% mexec interface for RVDAS data acquisition
% First drafts of scripts for start jc211 28 jan 2021, alongside in Stanley
% 
% Evolution on that cruise by bak, ylf, pa
% *************************************************************************
%
% Look in the rvdas database and find the vars that are present for a table
%
% Examples
% 
%   tablevars = mrgettablevars('pospmv');
%
%   tablevars = mrgettablevars('posmv_pos_gpgga');
%
%   mrgettablevars pospmv; tablevars = ans;
% 
% Input:
% 
%   table: rvdas or mexec table name. It can be any of the rvdas table
%     names, not just the ones with mexec equivalents.
% 
% Output:
% 
%   tablevars is a structure whose fieldnames are the variables found in the rvdas table 


m_common

tablemap = mrnames('q');
ktable = find(strcmp(table,tablemap(:,1)));
if length(ktable) == 1
    % if table matches an mexec table name, convert it to rvdas table name.
    table = tablemap{ktable,2}; 
end


rootcsv = MEXEC_G.RVDAS_CSVROOT;
csvname = [rootcsv 'table_list' '_' datestr(now,'yyyymmddHHMMSSFFF') '.csv'];
sqlroot = ['psql -h ' MEXEC_G.RVDAS_MACHINE ' -U ' MEXEC_G.RVDAS_USER ' -d ' MEXEC_G.RVDAS_DATABASE];

sqltext = ['\copy (select * from ' table ' order by time asc limit 0) to ''' csvname ''' csv header'];
psql_string = [sqlroot ' -c "' sqltext '"'];
system(psql_string);

fid = fopen(csvname,'r');
t = fgetl(fid);  % t is now the comma delimited list of variable names
fclose(fid);
rmfile(csvname);

t = [',' t ','];
kc = strfind(t,',');
varlist = cell(0);
for kl = 1:length(kc)-1
    varlist = [varlist; {t(kc(kl)+1:kc(kl+1)-1)}];
end

varlist(2:3) = []; % remove 'sensorid' and 'messageid'

%typically there will now be time, followed by a number of variables
%followed by the same number of flag variables

clear tablevars
for kl = 1:length(varlist)
    tablevars.(varlist{kl}) = []; % create an empty field with this name. 
end

return

