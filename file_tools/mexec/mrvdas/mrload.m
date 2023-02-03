function [dd,varnames,varunits] = mrload(varargin)
% function [dd,varnames,varunits] = mrload(table,dv1,dv2,qflag,varlist)
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
table = argot.table;
qflag = argot.qflag;
def = mrdefine('this_cruise', 'has_mstarpre');
if isempty(table)
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
table = mrresolve_table(table); % table is now an RVDAS table name for sure.
tablemap = def.tablemap;
ktable = strcmp(table,tablemap(:,2));
mtable = tablemap{ktable,1}; % mtable is the mexec tablename

%get command
[sqlcom, fnin, units] = mr_make_psql(table,dv1,dv2,varstring); % it should be fine if varstring is empty

%now run
mr_try_psql(sqlcom);

clear ds dd 
ds = dataset('file',fnin,'delimiter',',');

names = ds.Properties.VarNames(:); 

% now fix variable names in the dataset, so variables have the correct names
% when moved to a structure.

if ~isempty(find(strcmp(table,def.renametables_list), 1)) % some vars to be renamed for this table
    rlist = def.renametables.(table); % rlist now has the list of renaming to be done
    for kl = 1:size(rlist,1)
        nold = rlist{kl,1};
        uold = rlist{kl,2};
        nnew = rlist{kl,3};
        unew = rlist{kl,4};
        kvar = find(strcmpi(nold,names));
        if ~isempty(kvar) % This renaming variable hasn't been read in
            ds.Properties.VarNames{kvar} = nnew;
            names{kvar} = nnew;
            units{kvar} = unew;
        end
    end
end


% now fix variable names for variables that will be named raw

if ~isempty(find(strcmp(table,def.rawlist), 1)) % this table has all variabls renamed raw
    nvars = size(ds,2);
    for kv = 2:nvars % no need to rename time, which is always first
        dsname = [ds.Properties.VarNames{kv} '_raw'];
        ds.Properties.VarNames{kv} = dsname;
    end
    names = ds.Properties.VarNames; 
    names = names(:);
end

names(1) = []; % variable 1 is always time
units(1) = [];

% make all variable names lowercase in mexec
ds.Properties.VarNames = lower(ds.Properties.VarNames);
names = lower(names);


for kl = 1:length(names)
    dd.(names{kl}) = ds.(names{kl}); % convert to structure; time is always present; extract it separately.
end


ts = ds.time;% This is massively faster if we extract ts, and don't access ds.time inside the loop

if numel(ts) == 0
    dd.dnum = nan(size(ts));
else
    dd.dnum = mrconverttime(ts);
end


names = [names; {'dnum'}];
units = [units; {'matlab_datenum'}];



% now check for lat and lon that need to be converted from ddmm.mmm to
% decimal degrees
% Any variables requiring this conversion should have been renamed to
% variable name latdegm, londegm. 
% strncmp compares first 7 characters in case raw has been added.

klat1 = find(strncmp('latdegm',names,7));
klat2 = find(strncmp('latdir',names,6));
if ~isempty(klat1) && ~isempty(klat2) % latitude variables found
        lat1 = dd.(names{klat1});
        lath = dd.(names{klat2});
        deg = floor(lat1/100);
        min = lat1-100*deg;
        
        lathc = char(lath); lathc = lathc(:)';
        klats = strfind(lathc,'s');
        
        dd.latitude = deg+min/60;
        dd.latitude(klats) = -dd.latitude(klats);
        names = [names;{'latitude'}];
        units = [units;{'decimaldegrees'}];
        dd = rmfield(dd,names{klat1});
        dd = rmfield(dd,names{klat2});
        names([klat1 klat2]) = [];
        units([klat1 klat2]) = [];

end

klon1 = find(strncmp('londegm',names,7));
klon2 = find(strncmp('londir',names,6));
if ~isempty(klon1) && ~isempty(klon2) % longitude variables found
        lon1 = dd.(names{klon1}); % use dynamic field names
        lonh = dd.(names{klon2});
        deg = floor(lon1/100);
        min = lon1-100*deg;
        
        lonhc = char(lonh); lonhc = lonhc(:)';
        klons = strfind(lonhc,'w');
        
        dd.longitude = deg+min/60;
        dd.longitude(klons) = -dd.longitude(klons);
        names = [names;{'longitude'}];
        units = [units;{'decimaldegrees'}];
        dd = rmfield(dd,names{klon1});
        dd = rmfield(dd,names{klon2});
        names([klon1 klon2]) = [];
        units([klon1 klon2]) = [];

end


if isempty(qflag)
    fprintf(MEXEC_A.Mfidterm,'%d %s%s%s\n',length(fieldnames(dd)),' vars loaded from ''',mtable,''' including time');
    numdc = size(ds,1);
    if numdc > 0
        fprintf(MEXEC_A.Mfidterm,'%d %s %s %s %s\n',size(ds,1),' data cycles loaded from ',datestr(dd.dnum(1),'yyyy-mm-dd HH:MM:SS'), ' to ',datestr(dd.dnum(end),'yyyy-mm-dd HH:MM:SS'));
    else
        fprintf(MEXEC_A.Mfidterm,'%d %s %s %s %s\n',size(ds,1),' data cycles loaded from ',datestr(dv1,'yyyy-mm-dd HH:MM:SS'), ' to ',datestr(dv2,'yyyy-mm-dd HH:MM:SS'));
    end
end

delete(fnin);

clear ds

switch nargout
    case 3
        varnames = names;
        varunits = units;
    otherwise % unless exactly 3 output arguments are specified, add the names and units to the structure
        dd.varnames = names;
        dd.varunits = units;
end


return







