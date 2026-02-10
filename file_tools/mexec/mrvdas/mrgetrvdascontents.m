function rvdas_tables = mrgetrvdascontents(varargin)
% rvdas_tables = mrgetrvdascontents
% rvdas_tables = mrgetrvdascontents(quiet)
%
% *************************************************************************
% mexec interface for RVDAS data acquisition
% First drafts of scripts for start jc211 28 jan 2021, alongside in Stanley
% 
% Evolution on that cruise by bak, ylf, pa
% *************************************************************************
%
% Access the RVDAS database to get a list of the tables and their variables
%
%  Create a table with columns for tablenames and tablevars
%
%  Used by mrdefine
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
% The table returned has two columns, tablenames and tablevars. Each row in
% tabelvars is a cell array list of the variables in that row's tablename.  
%
% So the table names are
%  rvdas_tables.tablenames
%
% And the variables are, for example
%  rvdas_tables.tablevars{strcmp('cnav_gngga',rvdas_tables.tablenames)}

quiet = 1; if nargin>0; quiet = varargin{1}; end

%list of tables
rvdas_tables = mrgettables(quiet);

ntables = length(rvdas_tables.tablenames);
rvdas_tables.tablevars = cell(ntables,1);
keep = true(ntables,1);
for kl = 1:ntables
    %variables for each table
    tablevars = mrgettablevars(rvdas_tables.tablenames{kl},quiet);
    if isempty(tablevars)
        warning('table %s does not exist or has no variables; skipping',rvdas_tables.tablenames{kl})
        keep(kl) = false;
    else
        rvdas_tables.tablevars{kl} = tablevars;
    end
        
end
rvdas_tables = rvdas_tables(keep,:);
