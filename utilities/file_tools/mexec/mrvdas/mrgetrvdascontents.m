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
% Get a list of the entire contents of the rvdas database
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
% The table returned has two columns, tablenames and tabelvars. Each row in
% tabelvars is a cell array list of the variables in that row's tablename.  
%
% So the table names are
%  rvdas_tables.tablenames
%
% And the variables are, for example
%  rvdas_tables.tablevars{strcmp('cnav_gngga',rvdas_tables.tablenames)}

quiet = 1; if nargin>0; quiet = varargin{1}; end
rvdas_tables = mrgettables(quiet);
ntables = length(rvdas_tables.tablenames);
rvdas_tables.tablevars = cell(ntables,1);

iis = [];
for kl = 1:ntables
    tabname = rvdas_tables.tablenames{kl};
    
    if strcmp(tabname,'logta')
        % this is not a proper variable
        continue
    end
    
    tablevars = mrgettablevars(tabname,quiet);
    if isempty(tablevars)
        warning('table %s does not exist or has no variables; skipping',tabname)
        iis = [iis kl];
    else
        rvdas_tables.tablevars{kl} = tablevars;
    end
        
end
rvdas_tables(iis,:) = [];
