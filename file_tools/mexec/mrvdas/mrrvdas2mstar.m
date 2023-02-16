function mrrvdas2mstar(varargin)
% function mrrvdas2mstar(table, dn1, dn2, otfile, dataname, varlist, qflag);
%
% *************************************************************************
% mexec interface for RVDAS data acquisition
% First drafts of scripts for start jc211 28 jan 2021, alongside in Stanley
% 
% Evolution on that cruise by bak, ylf, pa
% *************************************************************************
%
% Load data from rvdas table and save it to an mexec file. This is done
% with a call to mrload.
%
% Examples
%
%   mrrvdas2mstar('surfmet',[28 0 0 0],[28 23 59 59],'surfmetwind_jc211_d028_raw','surfmet_jc211_d028','windspeed,winddirection','q');
%
%   mrrvdas2mstar surfmet [28 0 0 0] [29 23 59 59] surfmetflow_jc211_d028_raw surfmet_jc211_d028 'flow,fluo'
%
% Input:
% 
% The input arguments are parsed through mrparseargs. See the extensive
%   help in that function for descriptions of the arguments.
% table: is the rvdas table name or the mexec shorthand
% dn1 and dn2 are datevecs or datenums for the start and end of data.
% If qflag is 'q', fprintf will be suppressed in the call to mrload. Note
%   that this does not suppress the mexec processing output from msave.
% otfile is the mexec file name. Default is the same as the mexec table
%   name
% dataname is the mexec dataname. Default is the same as the mexec table
%   name
% varlist is a list of rvdas variable names to be loaded. Default is all.
%
% otfile, dataname and varlist are read off the list of arguments in order.
% So to use dataname, otfile must be present. To use varlist, otfile and
% dataname must both be present.
%
% Output: 
% 
% Saves an mexec NetCDF file

 
m_common
 
argot = mrparseargs(varargin); % varargin is a cell array, passed into mrparseargs
table = argot.table; 
if isempty(table)
    disp(varargin)
    error('no rvdas table or mstar shorthand found in inputs (above)');
end
qflag = argot.qflag;
clear varargin % because otherwise they confuse msave

if length(argot.otherstrings) < 1
    otfile = argot.table;
else
    otfile = argot.otherstrings{1};
end

if length(argot.otherstrings) < 2
    dataname = otfile;
else
    dataname = argot.otherstrings{2};
end

if length(argot.otherstrings) < 3
    varstring = '';
else
    varstring = argot.otherstrings{3};
end

otfile = m_add_nc(otfile);

switch length(argot.dnums)
    case 2
        dn1 = argot.dnums(1);
        dn2 = argot.dnums(2);
    case 1
        dn1 = argot.dnums(1);
        dn2 = now+50*365; % far in future
    case 0
        dn1 = now-50*365; % far in past
        dn2 = now+50*365; % far in future
end


[dd, names, units] = mrload(table,dn1,dn2,varstring,qflag);

if numel(dd.dnum) == 0
    % no data found, quit without writing a file
    error('No data cycles loaded with mrload')
end

%change dnum to mexec time in seconds
dd.time = (dd.dnum-datenum(MEXEC_G.MDEFAULT_DATA_TIME_ORIGIN))*86400;
names = [names; 'time'];
units = [units; 'seconds'];
dd = rmfield(dd, 'dnum');
[names, ia] = setdiff(names, {'dnum'}, 'stable');
units = units(ia);

%add variable names and units to hnew, or remove from dd
%also remove repeated times
[~,iit] = unique(dd.time,'stable');
clear hnew
hnew.fldnam = {}; hnew.fldunt = {};
for kl = 1:length(names)
    vname = names{kl};
    if isnumeric(dd.(vname))
        hnew.fldnam = [hnew.fldnam vname];
        hnew.fldunt = [hnew.fldunt units(kl)];
        dd.(vname) = dd.(vname)(iit);
    else
        dd = rmfield(dd,vname);
        warning('skipping non-numeric variable %s from table %s',vname,table)
    end
end

hnew.dataname = dataname;
hnew.comment = ['Variables written from rvdas to mstar at ' datestr(now,31) ' by ' MEXEC_G.MUSER ' calling msave'];
if exist(m_add_nc(otfile),'file')
    mfsave(otfile, dd, hnew, '-merge', 'time')
else
    mfsave(otfile, dd, hnew);
end

