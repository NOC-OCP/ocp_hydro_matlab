function tablevars = mrgettablevars(table,varargin)
% tablevars = mrgettablevars(table)
% tablevars = mrgettablevars(table,quiet)
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
%   tablevars = mrgettablevars('posmv_pos_gpgga');
% 
% Input:
% 
%   table: rvdas table name. It can be any of the rvdas table
%     names, not just the ones with mexec equivalents.
% 
% Output:
% 
%   tablevars is a cell array listing the variables in the rvdas table 


m_common
quiet = 1; if nargin>1; quiet = varargin{1}; end

sqltext = ['"\copy (select * from ' table ' order by time asc limit 0) to '''];
[csvname, ~, ~] = mr_try_psql(sqltext,quiet);

fid = fopen(csvname,'r');
t = fgetl(fid);  % t is now the comma delimited list of variable names
fclose(fid);
delete(csvname);

%remove sensorid and messageid
t = replace(replace(t,'sensorid,',''),'messageid,','');
%turn into list of variables
tablevars = strsplit(t,',');

%typically there will now be time, followed by a number of variables
%sometimes followed by the same number of flag variables
