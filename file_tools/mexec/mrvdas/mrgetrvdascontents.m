function rvdas_contents = mrgetrvdascontents
% function rvdas_contents = mrgetrvdascontents
%
% *************************************************************************
% mexec interface for RVDAS data acquisition
% First drafts of scripts for start jc211 28 jan 2021, alongside in Stanley
% 
% Evolution on that cruise by bak, ylf, pa
% *************************************************************************
%
% Get a list of the entire contents of the rvdas database
%
%  Create a structure whose fieldnames are all the tables in rvdas. See
%  Output below.
%
%  Not presently used in any mrvdas command, but used for checking the
%    content of rvdas compared with the .json files.
%
%  Calls mrgettables to get the list of all table names.
%  Calls mrgettablevars to get the list of all the variables for a table.
%
% Examples
%
%   rvdas_contents = mrgetrvdascontents;
%
% Input:
%
%   None
%
% Output:
%
% The structure returned has fieldnames that are all the tables in rvdas
% Each field is a structure whose fielnames are the variables for that
%   table. Each variable consists of an empty array.
%
% So the table names are
%  fieldnames(rvdas_contents)
%
% And the variables are, for example
%  fieldnames(rvdas_contents.cnav_gps_gngga)

rvdas_tables = mrgettables;
rvdas_tables_list = fieldnames(rvdas_tables);
ntables = length(rvdas_tables_list);

clear rvdas_contents

for kl = 1:ntables
    tabname = rvdas_tables_list{kl};
    
    if strcmp(tabname,'logta')
        % this is not a proper variable
        continue
    end
    
    tablevars = mrgettablevars(tabname);
    tablevars_list = fieldnames(tablevars);
    nvars = length(tablevars_list);
    for kv = 1:nvars
        rvdas_contents.(tabname).(tablevars_list{kv}) = []; % Use dynamic filednames. Neat syntax.
    end
    
    
    
end

return