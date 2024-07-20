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
%   argot.table = 'pospmv'; argot.dnums = [now-1 now]; 
%     argot.varlist = 'latitude,longitude'; dd = mrload('noparse',argot);
%
% Input:
%
% If the first input argument is 'noparse', the required inputs (rtable,
%   dnums = [dv1 dv2], varlist, mrtv) must be supplied as parameter-value
%   pairs (and optional inputs qflag may be supplied also as a
%   parameter-value pair). In this case dnums must be datenums (not
%   datevecs)
%   Otherwise, the input arguments are parsed through mrparseargs. See the
%   extensive help in that function for descriptions of the arguments.
%   The arguments can be provided in any order, except that dv1 must come
%   before dv2. The table, qflag and varlist will be found by
%   mrparseargs.
%
% rtable: is the rvdas table name or the mexec shorthand
% dv1 and dv2 are datevecs or datenums for the start and end of data.
%   Default dv1 is far in the past; default dv2 is far in the future.
% If qflag is 'q', fprintf will be suppressed. Default is ''
% varlist is a list of rvdas variable names to be loaded. Default (if
%   varlist = '') is all. 
% mrtv is the output of mrdefine, a lookup table for rvdas tablenames and
%   variables, and mstar files and variables
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

if nargin>0 && strcmp(varargin{1},'noparse')
    argot = varargin{2};
else
    argot = mrparseargs(varargin); % varargin is a cell array, passed into mrparseargs
end
rtable = argot.table;
mrtv = argot.mrtv;
if isfield(argot,'qflag') && isempty(argot.qflag)
    quiet = 0; 
else
    quiet = 1; 
end

% sort out the table name
rtable = mrresolve_table(rtable,mrtv); % table is now an RVDAS table name for sure.
ktable = strcmp(rtable,mrtv.tablenames);

%get command
sqlcom = mr_make_psql('noparse',argot);

%now run
[fnin, ~, ~] = mr_try_psql(sqlcom,quiet);

clear ds dd 
ds = readtable(fnin,'Delimiter',',');

% now fix variable names in the table, as well as the units array
names = ds.Properties.VariableNames;
units = repmat({' '},size(names));
[~,ia,ib] = intersect(names,mrtv.tablevars{ktable});
%change to mstarnames
names(ia) = mrtv.mstarvars{ktable}(ib);
units(ia) = mrtv.mstarunts{ktable}(ib);

%switch time to datenum
if numel(ds.time) == 0
    ds.dnum = nan(size(ds.time));
else
    ds.dnum = mrconverttime(ds.time);
end
l = length(names);
names(l+1) = {'dnum'};
units(l+1) = {'days since 0000-00-00 00:00:00'};

%reassign names to ds
ds.Properties.VariableNames = names;

% now check for lat and lon that need to be converted from ddmm.mmm to
% decimal degrees
% Any variables requiring this conversion should have been renamed to
% variable name latdegm, londegm. 
[ds, names, units] = lldegm_fix(ds, names, units, 'lat');
[ds, names, units] = lldegm_fix(ds, names, units, 'lon');

%convert to structure
dd = table2struct(ds,'ToScalar',true);
dd = rmfield(dd,'time');
[names,ii] = setdiff(names,'time');
units = units(ii);


if ~quiet
    fprintf(MEXEC_A.Mfidterm,'%d %s%s%s\n',length(fieldnames(dd)),' vars loaded from ''',rtable,''' including time');
    numdc = size(ds,1);
    if numdc > 0
        d1 = dd.dnum(1); d2 = dd.dnum(end);
    else
        d1 = dv1; d2 = dv2;
    end
    d1 = datestr(d1,'yyyy-mm-dd HH:MM:SS');
    d2 = datestr(d2,'yyyy-mm-dd HH:MM:SS');
    fprintf(MEXEC_A.Mfidterm,'%d data cycles loaded from %s to %s\n',size(ds,1),d1,d2);
end

%delete temporary .csv file
delete(fnin);


switch nargout
    case 3
        varnames = names';
        varunits = units';
    otherwise % unless exactly 3 output arguments are specified, add the names and units to the structure
        dd.varnames = names';
        dd.varunits = units';
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
end
