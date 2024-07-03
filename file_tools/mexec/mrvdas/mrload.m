function [dd,varnames,varunits] = mrload(varargin)
% function [dd,varnames,varunits] = mrload(rtable,dv1,dv2,qflag,varlist)
%
% *************************************************************************
% mexec interface for RVDAS data acquisition
% First drafts of scripts for start jc211 28 jan 2021, alongside in Stanley
% 
% Evolution on that cruise by bak, ylf, pa
% *************************************************************************
%
% Load data from rvdas into a matlab structure
%
% Examples
%
%   dd = mrload('pospmv',now-1,now,'q','latitude,longitude');
%
%   [dd,varnames,varunits] = mrload('pospmv',now-1,now,'q','latitude,longitude');
%
%   mrload pospmv now-1 now q 'latitude,longitude'; dd = ans;
%
%   mrload 'salinity' tsg [28 0 0 0] [28 23 59 59]; dd = ans;
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
% If qflag is 'q', fprintf will be suppressed. Default is ''
% varlist is a list of rvdas variable names to be loaded. Default is all.
%
% Output:
%
% dd   : data structure, in which the fieldnames should match the variable
%          names in the names cell array.
% varnames: cell array of names of the fields in the data structure. All
%          variable names are converted to lowercase.
% varunits: cell array of units that correspond to the names, with the same indexing
% 
% Unless exactly 3 output variables are specified in the call, varnames and
%   varunits are added to the dd structure.
%
% If no data are found, empty arrays of size [0x1 double] are returned in
%   the fields in dd.

m_common

argot = mrparseargs(varargin); % varargin is a cell array, passed into mrparseargs
rtable = argot.table;
qflag = argot.qflag;
def = mrdefine('this_cruise');
if isempty(rtable)
    disp(def.tablemap)
    error('none of the input arguments matches an rvdas table name or its mexec short equivalent; try again with a table from either column of the list above')
end

if length(argot.otherstrings) < 1
    varstring = '';
else
    varstring = argot.otherstrings{1};
end

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
rtable = mrresolve_table(rtable); % table is now an RVDAS table name for sure.
tablemap = def.tablemap;
ktable = strcmp(rtable,tablemap(:,2));
mtable = tablemap{ktable,1}; % mtable is the mexec tablename

%get command
[sqlcom, units] = mr_make_psql(rtable,dv1,dv2,varstring); % it should be fine if varstring is empty

%now run
[fnin, ~, ~] = mr_try_psql(sqlcom);

clear ds dd 
ds = readtable(fnin,'Delimiter',',');

% now fix variable names in the table, as well as the units array
names = ds.Properties.VariableNames;
if ~isempty(find(strcmp(rtable,def.renametables_list), 1)) % some vars to be renamed for this table
    rlist = def.renametables.(rtable)(:)'; % rlist now has the list of renaming to be done
    [~,ia,ib] = intersect(names,rlist(1,:),'stable');
    %***check for units matching rlist(2,:)?
    names(ia) = rlist(2,ib);
    units(ia) = rlist(4,ib);
end
% make all variable names lowercase in mexec
names = lower(names);
% make all empty units ' '
m = cellfun('isempty', units);
units{m} = ' ';

%switch time to datenum
if numel(ds.time) == 0
    ds.dnum = nan(size(ds.time));
else
    ds.dnum = mrconverttime(ds.time);
end
names{1} = 'dnum';
units{1} = 'days since 0000-00-00 00:00:00';

%reassign names to ds
ds.Properties.VariableNames = names;

% now check for lat and lon that need to be converted from ddmm.mmm to
% decimal degrees
% Any variables requiring this conversion should have been renamed to
% variable name latdegm, londegm. 
[ds, names, units] = lldegm_fix(ds, names, units, 'lat');
[ds, names, units] = lldegm_fix(ds, names, units, 'lon');

%convert to structure
dd = table2struct(ds);

if isempty(qflag)
    fprintf(MEXEC_A.Mfidterm,'%d %s%s%s\n',length(fieldnames(dd)),' vars loaded from ''',mtable,''' including time');
    numdc = size(ds,1);
    if numdc > 0
        fprintf(MEXEC_A.Mfidterm,'%d %s %s %s %s\n',size(ds,1),' data cycles loaded from ',datestr(dd.dnum(1),'yyyy-mm-dd HH:MM:SS'), ' to ',datestr(dd.dnum(end),'yyyy-mm-dd HH:MM:SS'));
    else
        fprintf(MEXEC_A.Mfidterm,'%d %s %s %s %s\n',size(ds,1),' data cycles loaded from ',datestr(dv1,'yyyy-mm-dd HH:MM:SS'), ' to ',datestr(dv2,'yyyy-mm-dd HH:MM:SS'));
    end
end

%delete temporary .csv file
delete(fnin);


switch nargout
    case 3
        varnames = names;
        varunits = units;
    otherwise % unless exactly 3 output arguments are specified, add the names and units to the structure
        dd.varnames = names;
        dd.varunits = units;
end


function [data, names, units] = lldegm_fix(data, names, units, pre)
%fix lat or lon that were read in as deg.minutes

v1 = [pre 'degm'];
v2 = [pre 'dir'];
k1 = find(strncmp(v1,names,length(v1)));
k2 = find(strncmp(v2,names,length(v2)));
if ~isempty(k1) && ~isempty(k2) %found londegm and londir, or latdegm and latdir
    l1 = data(:,k1);
    lh = data(:,k2);
    deg = floor(data(:,k1)/100);
    mins = data(:,k1) - deg*100;
    data = [data deg + mins/60];
    mn = strcmpi('s',lh) | strcmpi('w',lh);
    data(mn,end) = -data(mn,end);
end
if strncmp(pre,'lat',3)
    names = [names 'latitude'];
else
    names = [names 'longitude'];
end
units = [units 'decimaldegrees'];
data.Properties.VariableNames = names;
ii = [k1 k2];
data(:,ii) = [];
names(ii) = [];
units(ii) = [];









