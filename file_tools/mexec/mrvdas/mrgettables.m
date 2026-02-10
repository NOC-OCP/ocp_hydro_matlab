function rvdas_tables = mrgettables(varargin)
% rvdas_tables = mrgettables
% rvdas_tables = mrgettables(quiet)
% 
% *************************************************************************
% mexec interface for RVDAS data acquisition
% First drafts of scripts for start jc211 28 jan 2021, alongside in Stanley
% 
% Evolution on that cruise by bak, ylf, pa
% *************************************************************************
%
% Access the RVDAS database to make a list of all the tables
%  
% Examples
% 
%   rvdas_tables = mrgettables;
%
% Input:
% 
%   None
%
% Output:
%
%   A table with one column, tablenames, whose values are the names of
%   the tables in rvdas. The list of tables is determined from the psql \dt
%   command, or for the SDA, \dv (meaning that they will be prefixed with
%   cruise_ e.g. sda025_anemometer_metek_ ... etc.)
%
%   So rvdas_tables.tablenames is a cell array of the table names.


m_common
quiet = 1; if nargin>0; quiet = varargin{1}; end

opt1 = 'ship'; opt2 = 'rvdas_form'; get_cropt
if use_cruise_views
    sqltext = ['"\dv ' view_name '*" >'];
else
    sqltext = '"\dt" >';
end
if ismac
    sqltext = [sqltext '! '];
else
    sqltext = [sqltext ' '];
end
[csvname, ~, ~] = mr_try_psql(sqltext, quiet);

fid = fopen(csvname,'r');
tl = cell(0);
while 1
    tline = fgetl(fid);
    if ~ischar(tline); break; end
    tl = [tl; {tline}];
end
fclose(fid);

nlines = length(tl);

tablenames = cell(nlines,1);
n = 1;
for kl = 1:nlines
    t = tl{kl};
    kbar = strfind(t,'|');
    if length(kbar) < 3; continue; end
    s1 = t(kbar(2)+1:kbar(3)-1);
    s2 = t(kbar(1)+1:kbar(2)-1);
    if contains(s1,'table') || contains(s1,'view') % this line lists a table or a view
        tabname = s2;
        while strcmp(tabname(1),' '); tabname(1) = []; end
        while strcmp(tabname(end),' '); tabname(end) = []; end
        tablenames{n} = tabname; n = n+1;
    end
end
tablenames = tablenames(1:n-1);

rvdas_tables = cell2table(tablenames);

delete(csvname);

