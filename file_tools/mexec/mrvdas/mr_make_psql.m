function [sqltext,sqlunits]= mr_make_psql(varargin)
% function [sqltext,sqlunits]= mr_make_psql(table,dv1,dv2,varlist)
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
% csvname: The full pathname of a csv file that will be used for output
%   from rvdas and input to matlab load.
% 
% sqlunits: The units associated with the variables that will be retrieved
%
% Authentication on rvdas:
%
% The file /local/users/pstar/.pgpass contains authentication details so
% commands run on koaeula retrieve data from rvdas. No need to mount rvdas
% on koaeula.
%
% #hostname:port:database:username:password
% rvdas.cook.local:5432:preJC211_2:rvdas:rvdas
% rvdas.cook.local:5432:JC211:rvdas:rvdas


m_common
opt1 = 'ship'; opt2 = 'rvdas_database'; get_cropt

argot = mrparseargs(varargin); % varargin is a cell array, passed into mrparseargs
table = argot.table;
qflag = argot.qflag;

if length(argot.otherstrings) < 1
    varstring = '';
else
    varstring = argot.otherstrings{1};
end

def = mrdefine;

switch length(argot.dnums)
    case 2
        dv1 = argot.dnums(1);
        dv2 = argot.dnums(2);
    case 1
        dv1 = argot.dnums(1);
        dv2 = now+50*365; % far in future
    case 0
        dv1 = now-50*365; % far in past
        dv2 = now+50*365; % far in future
end



dv1 = datevec(datenum(dv1)); % this will convert a datenum to a datevec if it isn't already
dv2 = datevec(datenum(dv2));

% sort out the table name
table = mrresolve_table(table); % table is now an RVDAS table name for sure.

dv1str = datestr(dv1,'yyyy-mm-dd HH:MM:SS');
dv2str = datestr(dv2,'yyyy-mm-dd HH:MM:SS');

% get the definition for this table, and the list of variables we want from
% it

try
    vdef = def.mrtables.(table);
catch
    error([table ' is not defined in mrtable (see mrdefine and mrtables_from_json)']);
end

sqlname = vdef{1,1};
sqlvars = 'time';
sqlunits = {'string'};

% First get a list of variables numbers in the vdef array that we want
% Select variables from vdef that are found in varstring
% If no matching variables are found, get them all.
% If varstring is empty, there will be no matching, so get them all.
% If latitude and longitude are in the varstring, and if latdir and londir
% are also present, then they are needed by mrload to make sense of the lat
% and lon variables.

if ~isempty(varstring)
    latitude_in_varstring = contains(lower(varstring),'latitude');
    latdir_not_in_varstring = ~contains(lower(varstring),'latdir');
    latdir_in_vdef = sum(strcmpi('latdir',vdef(:,1)));
    if latitude_in_varstring && latdir_not_in_varstring && latdir_in_vdef
        % add latdir to varstring
        varstring = [varstring ' latdir'];
    end
    longitude_in_varstring = contains(lower(varstring),'longitude');
    londir_not_in_varstring = ~contains(lower(varstring),'londir');
    londir_in_vdef = sum(strcmpi('londir',vdef(:,1)));
    if longitude_in_varstring && londir_not_in_varstring && londir_in_vdef
        % add londir to varstring
        varstring = [varstring ' londir'];
    end
end

varnums = [];
ii = findstr(varstring,' ');
if ~isempty(ii)
    clear vars; vars{1,1} = lower(varstring(1:ii(1)-1));
    for no = 1:length(ii)-1
        vars{no+1,1} = lower(varstring(ii(no)+1:ii(no+1)-1));
    end
    if ii(end)<length(varstring)
        no = size(vars,1);
        vars{no+1,1} = lower(varstring(ii(end)+1:end));
    end
    for no = 1:size(vdef,1)
        vdef{no,1} = lower(vdef{no,1});
    end
    [~,varnums,~] = intersect(vdef(:,1),vars);
end
if isempty(varnums); varnums = 2:size(vdef,1); end

for kl = varnums(:)'
    thisvar = vdef{kl,1};
    thisunit = vdef{kl,2};
    sqlvars = [sqlvars ',' thisvar];
    if isempty(thisunit)
        thisunit = 'json_empty';
        vdef(kl,2) = {thisunit}; % don't want empty units string, even if json defs allow it.
    end
    sqlunits = [sqlunits; thisunit];
end

% where time between '2021-01-25' and '2021-01-27'
sqltext = ['"\copy (select ' sqlvars ' from ' sqlname ' where time between ''' dv1str ''' and ''' dv2str ''' order by time asc) to '''];

return
