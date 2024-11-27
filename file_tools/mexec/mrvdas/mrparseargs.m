function argot = mrparseargs(argsin)
% function argot = mrparseargs(argsin)
%
% *************************************************************************
% mexec interface for RVDAS data acquisition
% First drafts of scripts for start jc211 28 jan 2021, alongside in Stanley
%
% Evolution on that cruise by bak, ylf, epa
% *************************************************************************
%
% This function parses arguments to mrvdas functions. The intention is that
% mrvdas functions can be called from a matlab command prompt with arguments
% on the command line, or within a script with arguments as function
% arguments in the usual way.
%
% eg
%  >> mrload tsg now-1 now q;
%  >> d = ans;
% which will load data into a structure 'ans' that is then assigned to 'd'
% or
%  >> d = mrload('tsg',now-1,now,'q');
%
% The order of arguments is unimportant for this function, except that
% dnums, othernums and otherstrings will appear in the output structure
% in the same order as they appear in the input cell array.
% Some calling functions will need to process those numbers and strings in
% a particular order.
%
% Inputs are parsed and placed into the argot structure depending on their
% value: A table name; a 'q' flag; datenums; other nums; other strings;
%
% Input:
%
% argsin should be a cell array
%   Typically the mrvdas function that calls mrparseargs will have varargin
%   as the argument. This will collect a cell array from either the command
%   line or the function arguments, one element per argument.
%   Numerical values will be char strings if they were on a matlab
%   command line (example 1) and may have been read as numbers if they
%   were function arguments (example 2).
%
%   char strings are inspected to see if they could be numbers.
%   If the char string starts with 'now', then assume it is intended as a
%   matlab time, and try to evaluate it.
%
% In the examples above,
%   argsin will be a cell array with 4 elements with char strings 'tsg' and
%   'q', and numbers corresponding to the values of now-1 and now.
%
% The function attempts to convert strings to numbers with str2num
%   If the character string is a simple char representation of a number, it
%   will succeed. eg '10' '7200' '[2021 1 28]'
% If there is no conversion, the result is an empty double, and the
%   argument is then processed as a string.
% If the string begins with 'now', eg 'now' or 'now-1/24' then an attempt
%   is made to evaluate the string to turn it into a datenum. If the
%   attempt fails, processing continues with the original string.
%
% The parsing recognises the following kinds of argument
%
% A string that matches an rvdas table name or its mexec short equivalent,
%   returned in argot.table
% The string 'q', returned with argot.qflag = 'q' 
%   (otherwise, argot.qflag = '')
% A string beginning with 'now' which is evaluated as a datenum
% Any other datenum/datevec format, described below, converted to a
%   datenum. Any large number, greater that 693959 = datenum([1899 12 29]) is
%   assumed to be a datenum and added to the array argot.dnums.
% Any numbers smaller than the datenum limit are returned in
%   argot.othernums
% A string specifying one of the following types of operations -- 'mlast',
%   'mlookd', 'mlistit', 'mgaps', 'mposinfo' -- is returned in argot.oper
%   (see mrshow_info help)***
% Any other strings, not yet recognised, eg a string that is a variable
%   list, are returned in argot.otherstrings, in the order in which they
%   appeared in the argsin cell array.
%
%
% Datenums can be entered as
%   numbers: eg 738184.5 , which is unlikley
%   matlab dates: eg now-1, now, which turn into datenums
%   3, 4 or 6 element datevecs
%     [2021 1 28]:  zero hours on the day =  [yyy mm dd 0 0 0]; 28 Jan 2021
%     [100 23 59 59]: [daynum HH MM SS] on the day number. Year origin is
%                     MEXEC_G.MDEFAULT_DATA_TIME_ORIGIN(1)
%                     Noon on 1 January is [1 12 0 0];
%     [2021 1 28 23 59 59]: [yyyy mm dd HH MM SS];
%
% Variable lists
%   A variable list should be a single string, containing as many variable
%     names as are required.
%   The selection for copying from rvdas occurs in mr_make_psql.m
%   The selection works by looking at the list of variables in the rvdas
%   table.
%   def = mrdefine;
%   vdef = def.mrtables.(table);
%   and then search each variable in vdef to see if it matches strfind in
%     the varlist string.
%   Examples of varlist strings that would match salinity and conductivity would be
%     'salinity,conductivity'
%     'salinity, conductivity '
%     'salinity  conductivity'
%     'conductivitysalinity'
%     in each case, strfind(varlist,'salinity') produces a nonempty result.
%   In order to process lat and lon in the GGA messages, eg pospmv, where the format
%     of lat and lon are latitude = DDMM.MMMM and latdir = 's', the latdir
%     and londir variables are required in addition to latitude and
%     longitude. latDir and lonDir are added to the list automatically.

% Output:
%
% A structure with fields
%   qflag = 'q' if 'q' was found, '' otherwise
%   table = '' if no argument matched an mexec or rvdas table. This field
%      is the rvdas or mexec table name if a match was found
%   dnums   an array of matlab dnums if found, in the order in argsin
%   othernums an array of other numbers if found, in the order in argsin
%   otherstrings is an array of other strings, eg a varlist for mrload or
%     mrlistit, in the order in argsin
%
%  So calling programs can pull dnums, othernums and otherstrings out of
%    those fields in argot, in the order in which they were entered.


m_common

% argsin is a cell array of the varargs in a calling program

allargs = argsin; % make a local copy, so we can remove arguments once they have been parsed


% Search for any of the arguments to be 'q', and set qflag = 'q' or '';
qflag = '';
kq = find(strcmp('q',allargs));
if ~isempty(kq)
    qflag = 'q';
    allargs(kq) = [];
else
    qflag = '';
end


% Search for any of the arguments to be an mexec or rvdas table name
def = mrdefine;
tmap_mexec = def.tablemap(:,1);
tmap_rvdas = def.tablemap(:,2);
table = '';
nargs = length(allargs);
for ka = 1:nargs
    arg = allargs{ka};
    ftab = 0;
    if ~ischar(arg); continue; end % not a char argument
    if sum(strcmp(arg,tmap_mexec))>=1 || sum(strcmp(arg,tmap_rvdas))>=1
        ftab = 1;
        table = arg;
        allargs(ka) = [];
        break %only find up to one table name
    end
end


% If any of the arguments are character strings that start with the text 'now'
% these are probably times, so evaluate the string.
nargs = length(allargs);
for ka = 1:nargs
    arg = allargs{ka};
    if ~ischar(arg); continue; end % not a char argument
    arg = [arg '   '];
    if strncmp(arg(1:3),'now',3)
        try
            newtime = eval(arg); % if the string starts with 'now' try to evaluate it as a datenum
            allargs{ka} = newtime;
        catch
            % it wasn't able to be evaluated; leave it as it was
        end
    end
end


% search for any of the arguments to be date/times
% possible date/time arguments are
% datenum - single number that looks like a meaningful date
% datevec - 3,4 or 6-element date field
% [2021 1 28] [yyyy mm dd]
% [28 0 0 0] [dayofyear hh mm ss]
% [2021 1 28 0 0 0] [yyyy mm dd hh mm ss]
% The datvecs may appear as double arrays or as char strings
% Number arguments will come in as type char if just typed on the command
% line

nargs = length(allargs);
dnums = [];
othernums = [];
otherstrings = cell(0);
for ka = nargs:-1:1
    dnum = nan;
    othernum = nan;
    otherstring = '';
    arg = allargs{ka};
    if ischar(arg)
        % special trap for when the varlist == 'flow', because 'flow' is  a
        % matlab function, and str2num('flow') produces a 25 x 50 x 25
        % array. If we want to retrieve only 'flow' from the surmfet table,
        % then str2num(arg) succeeds in a non-empty conversion.
        if strcmp(arg,'flow')
            argn = [];
            otherstring = arg;
        else
            argn = str2num(arg); % char strings that aren't char representations of numbers return empty
            if isempty(argn)
                % it couldn't be turned into a number, so save it as an
                % otherstring
                otherstring = arg;
            end % it wasn't a number that was recognised
        end
    else
        argn = arg;
    end
    % if we get here, argn should be a scalar or vector number
    switch length(argn)
        case 6
            % 6-element datevec
            dnum = datenum(argn);
        case 4
            % 4-element datevec, expecting it to be a day of year, and time
            day = argn(1);
            hh = argn(2);
            mm = argn(3);
            ss = argn(4);
            year_org = MEXEC_G.MDEFAULT_DATA_TIME_ORIGIN(1);
            dnum = datenum([year_org 1 1 hh mm ss]) + (day-1);
        case 3
            dnum = datenum([argn 0 0 0]);
        case 1
            % If the number would decode into a date since 29 Dec 1899,
            % assume it is such a date. Allow a big range
            % in case someone uses the start of a century, or the TECHSAS time origin, to get
            % 'all data'
            if argn >= datenum([1899 12 29])
                dnum = argn;
            else
                othernum = argn;
            end
        otherwise
            % not parsed as a dnum
    end
    if ~isnan(dnum)
        dnums = [dnums dnum];
        allargs(ka) = [];
    end
    if ~isnan(othernum)
        othernums = [othernums othernum];
        allargs(ka) = [];
    end
    if ~isempty(otherstring)
        otherstrings = [otherstrings {otherstring}];
        allargs(ka) = [];
    end
    
    
end

argot.othernums = fliplr(othernums);  % flip because we parse from the end of the arguments
argot.otherstrings = fliplr(otherstrings);  % flip because we parse from the end of the arguments
argot.dnums = fliplr(dnums);
argot.table = table;
argot.qflag = qflag;
return