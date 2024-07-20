function sqltext = mr_make_psql(varargin)
% function sqltext = mr_make_psql(table,dv1,dv2,varlist)
% 
% *************************************************************************
% mexec interface for RVDAS data acquisition
% First drafts of scripts for start jc211 28 jan 2021, alongside in Stanley
% 
% Evolution on that cruise by bak, ylf, pa
% *************************************************************************
%
% Make the psql command string for mrload
%
% Examples:
%
%   mr_make_psql('pospmv',[2021 1 27 0 0 0],[2021 1 27 23 59 59])  % to get day 27
%
%   mr_make_psql('pospmv',now-1/24,now)                            % to get the most recent hour
% 
%   mr_make_psql('pospmv','latitude,longitude')    % to get just lat and lon for all times
%
% Input:
%
% The input arguments are parsed through mrparseargs. See the extensive
%   help in that function for descriptions of the arguments.
%
% The arguments can be provided in any order, except that dv1 must come
%   before dv2. The table, qflag and varlist will be found by
%   mrparseargs.
%
% table: is the rvdas table name or the mexec shorthand
% dv1 and dv2 are datevecs or datenums for the start and end of data.
%   Default dv1 is far in the past; default dv2 is far in the future.
% qflag is not presently used. Default is ''.
% varlist is a list of rvdas variable names to be loaded. Default is all.
%   If latitude and longitude are requested, and latDir and 
%   lonDir (ie hemispheres) are available and needed to interpret lat and
%   lon, they are automatically added to the list.
%
% Output:
%
% sqltext: command for the psql string to be executed
%


m_common
opt1 = 'ship'; opt2 = 'rvdas_database'; get_cropt

if nargin>0 && strcmp('noparse',varargin{1})
    argot = varargin{2};
    if isfield(argot,'varstring')
        varstring = argot.varstring;
    else
        varstring = '';
    end
else
    argot = mrparseargs(varargin); % varargin is a cell array, passed into mrparseargs
    if isempty(argot.otherstrings)
        varstring = '';
    else
        varstring = argot.otherstrings{1};
    end
end
rtable = mrresolve_table(argot.table);
dnums = argot.dnums;
mrtv = argot.mrtv;
if isfield(argot,'qflag')
    qflag = argot.qflag;
else
    qflag = 'q';
end

switch length(dnums)
    case 2
        dv1 = dnums(1);
        dv2 = dnums(2);
    case 1
        dv1 = dnums(1);
        dv2 = now+50*365; % far in future
    case 0
        dv1 = now-50*365; % far in past
        dv2 = now+50*365; % far in future
end


%dv1 = datevec(datenum(dv1)); % this will convert a datenum to a datevec if it isn't already
%dv2 = datevec(datenum(dv2));

dv1str = datestr(dv1,'yyyy-mm-dd HH:MM:SS');
dv2str = datestr(dv2,'yyyy-mm-dd HH:MM:SS');

% get the definition for this table, and the list of variables we want from
% it

try
    m = strcmp(rtable,mrtv.tablenames);
    mrtv = mrtv(m,:);
    sqlname = mrtv.tablenames{1};
catch
    error('%s is not defined; if it is in the database, add to \nmstar_dirs_tables and mstar_by_table and rerun mrdefine(''reload'')',rtable);
end

% select the variables we want (if varstring is empty or has no matches, select all)
if isempty(varstring)
    vars = mrtv.tablevars{1};
else
    varcell = strsplit(lower(varstring),' ');
    varcell = varcell(~cellfun('isempty',varcell)); %in case empty string at end
    vars = {};

    %first try rvdas variable names
    [~,ia,ib] = intersect(lower(mrtv.tablevars{1}),varcell);
    if ~isempty(ia)
        vars = [vars mrtv.tablevars{1}(ia)];
        varcell(ib) = [];
    end

    %next try mstar names
    [~,ia,ib] = intersect(lower(mrtv.mstarvars{1}),varcell);
    if ~isempty(ia)
        vars = [vars mrtv.tablevars{1}(ia)];
        varcell(ib) = [];
    end

    if ~isempty(varcell)
        warning('these vars not found in %s:',rtable)
        disp(varcell)
    end

    if ~sum(strcmp('time',vars))
        vars = ['time' vars];
    end

end


% If latitude and longitude are in the varstring, and if latdir and londir
% are also present, then they are needed by mrload to make sense of the lat
% and lon variables.
if sum(strcmpi('latitude',vars)) && ~sum(strcmpi('latdir',vars)) && sum(strcmpi('latdir',mrtv.tablevars))
    vars = [vars 'latdir'];
end
if sum(strcmpi('longitude',vars)) && ~sum(strcmpi('londir',vars)) && sum(strcmpi('londir',mrtv.tablevars))
    vars = [vars 'londir'];
end

sqlvars = cell2mat(cellfun(@(x) [x ','], vars, 'UniformOutput', false));
sqlvars = sqlvars(1:end-1);

% where time between '2021-01-25' and '2021-01-27'
sqltext = ['"\copy (select ' sqlvars ' from ' sqlname ' where time between ''' dv1str ''' and ''' dv2str ''' order by time asc) to '''];

return
