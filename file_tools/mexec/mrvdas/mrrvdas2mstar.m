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
%   that this does not suppress the mexec processing outputfrom msave.
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
dv1 = datevec(dn1); % this will convert a datenum to a datevec if it isn't already
dv2 = datevec(dn2);


[dd names units] = mrload(table,dn1,dn2,varstring,qflag);

if numel(dd.dnum) == 0
    if isempty(qflag)
        % no data found, quit without writing a file
        fprintf(MEXEC_A.Mfidterm,'%s\n','No data cycles loaded with mrload')
    end
    return
end

% calculate mexec time in seconds and remove dnum from the names list for
% saving. dnum is always there as the matlab_datenum time variable.
torg = datenum(MEXEC_G.MDEFAULT_DATA_TIME_ORIGIN);
dd.time = (dd.dnum-torg)*86400;
names = [{'time'};names];
units = [{'seconds'};units];
kdnum = find(strcmp('dnum',names));
names(kdnum) = [];
units(kdnum) = [];

nvars = length(names);
namesunits = cell(0);
for kl = 1:nvars
    vname = names{kl};
    cmd = [vname ' = dd.(vname);']; eval(cmd);
    namesunits = [namesunits;{' '};units(kl)]; % will be used to set units in msave
end

MEXEC_A.MARGS_IN_1 = {otfile};
MEXEC_A.MARGS_IN_2 = names;
MEXEC_A.MARGS_IN_3 = {
    ' '
    ' '
    '8'
    '0'
    };
MEXEC_A.MARGS_IN_4 = namesunits;
MEXEC_A.MARGS_IN_5 = {
    '-1'
    '-1'
    };
    


MEXEC_A.MARGS_IN = [
    MEXEC_A.MARGS_IN_1
    MEXEC_A.MARGS_IN_2
    MEXEC_A.MARGS_IN_3
    MEXEC_A.MARGS_IN_4
    MEXEC_A.MARGS_IN_5
    ];
msave

MEXEC_A.MARGS_IN = {
otfile
'y'
'1'
dataname
' '
'2'
MEXEC_G.PLATFORM_TYPE
MEXEC_G.PLATFORM_IDENTIFIER
MEXEC_G.PLATFORM_NUMBER
' '
'4'
MEXEC_G.MDEFAULT_DATA_TIME_ORIGIN
' '
'-1'
'-1'
};
mheadr

nowstring = datestr(now,31);
ncfile_ot.name = otfile;
m_add_comment(ncfile_ot,['Variables written from rvdas to mstar at ' nowstring ' by ' MEXEC_G.MUSER ' calling msave']);
%--------------------------------
