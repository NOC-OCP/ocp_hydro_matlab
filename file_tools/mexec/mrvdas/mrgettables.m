function rvdas_tables = mrgettables
% function rvdas_tables = mrgettables;
% 
% *************************************************************************
% mexec interface for RVDAS data acquisition
% First drafts of scripts for start jc211 28 jan 2021, alongside in Stanley
% 
% Evolution on that cruise by bak, ylf, pa
% *************************************************************************
%
% Make a list of all the tables in the rvdas database.
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
%   A structure in which the fieldnames are the names of the tables in
%   rvdas. The list of tables is determined from the psql \dt command.
%   ***for sda, needs to be updated to just look for current tables***
%
%   So fieldnames(rvdas_tables) is a cell array of the table names.
%   Each field is []

m_common

% place to temporarily put list of tables

csvname = fullfile(MEXEC_G.RVDAS.csvroot, ['table_list' '_' datestr(now,'yyyymmddHHMMSSFFF') '.csv']);
if ismac
    sqltext = ['"\dt" > ' csvname];
else
    sqltext = ['"\dt" >! ' csvname];
end
mr_try_psql(sqltext);

fid = fopen(csvname,'r');
tl = cell(0);
while 1
    tline = fgetl(fid);
    if ~ischar(tline); break; end
    tl = [tl; {tline}];
end
fclose(fid);

nlines = length(tl);

clear rvdas_tables

for kl = 1:nlines
    t = tl{kl};
    kbar = strfind(t,'|');
    if length(kbar) < 3; continue; end
    s1 = t(kbar(2)+1:kbar(3)-1);
    s2 = t(kbar(1)+1:kbar(2)-1);
    if strfind(s1,'table') % this line lists a table
        tabname = s2;
        while strcmp(tabname(1),' '); tabname(1) = []; end
        while strcmp(tabname(end),' '); tabname(end) = []; end
        rvdas_tables.(tabname) = [];
    end
    
end


delete(csvname);


return