function vlist = m_getvlist(list,h)
% function vlist = m_getvlist(list,h)
%
% getvlist: compare character string 'list' with mstar variable names in h.fldnam, and produce list of variable numbers
% vlist = getvlist(list,h)
%
% list is comma or space delimited
% list contains variable numbers or names, or a range defined by n~m,
% or a range defined by n:m
%    where n and m are variable numbers.
% list has an optional trailing slash '/'
% if list is empty, vlist is all variables.
%
% h is a pstar header
%
% BAK at SOC 31 March 2005

vlist = [];

% convert : to ~ because tilde is handled correctly below
% handling of tilde is legacy from pexec.
kcolon = strfind(list,':');
list(kcolon) = '~';

for k = 1:h.noflds %remove blanks from var names
    sname = h.fldnam{k};
    i = strfind(sname,' ');
    sname(i) = [];
    fldnam{k} = sname;
end

% first swap comma to space
i = strfind(list,',');
while ~isempty(i)
    list(i) = ' ';
    i = strfind(list,',');
end

%remove trailing slash or space. Add trailing space first in case list
%starts empty
list = [list ' '];
while strcmp(list(end),' ') | strcmp(list(end),'/')
    list(end) = [];
    if isempty(list); break; end
end

%remove all leading spaces
list = [' ' list];
while strcmp(list(1),' ')
    list(1) = [];
    if isempty(list); break; end
end

if isempty(list) % Empty variable list so return list of all variables
    vlist = [1:h.noflds];
    return
end

% remove multiple space
i = strfind(list,'  ');
while ~isempty(i)
    list(i) = [];
    i = strfind(list,'  ');
end

% The list should now be delimited by single spaces. Add one at each end
list = [' ' list ' '];
isp = strfind(list,' ');
numv = length(isp)-1;

badstr = 0;
for k = 1:numv
    vstr = list(isp(k)+1:isp(k+1)-1); %This is a string representing one of the elements of the input list
    
    i = findstr(vstr,'~'); %First look for range match
    if isempty(i)  % No tilde
    elseif length(i) > 1 % More than one tilde
    elseif i == 1 | i == length(vstr) %tilde out of place
    else %we have precisely one tilde, in a sensible place. Now look for valid variable numbers either side of it
        vstr1 = vstr(1:i-1);
        vstr2 = vstr(i+1:end);
        t1 = testnum(vstr1,h.noflds);
        t2 = testnum(vstr2,h.noflds);
        if t1 == 1 & t2 == 1
            vnum1 = str2num(vstr1);
            vnum2 = str2num(vstr2);
            vlist = [vlist vnum1:vnum2];
            continue            
        end
    end
        
    % Now try for a simple variable number
    t = testnum(vstr,h.noflds);
    if t == 1
        vnum = str2num(vstr);
        vlist = [vlist vnum];
        continue
    end
    
    % Now try a string match
    
    vnum = [];
    vnum = strmatch(vstr,fldnam,'exact');
    if ~isempty(vnum) %variable string recognised; select the first if multiple matches.
        vlist = [vlist vnum(1)];
        continue
    end
    
    % String not recognised
    badstr = 1;
    disp(['Variable string    ' vstr '    not recognised.']);
end

if badstr == 1
    disp(' ');
    error('One or more of the user-provided variable strings not recognised');
end


function t = testnum(str,noflds)

% Test if the string represents a simple number in the range 1 to noflds
% returns t = 1 if number is Ok. 0 otherwise.

numerals = '0123456789';
t = 1;
for k = 1:length(str)
    if isempty(findstr(numerals,str(k)))
        t = 0;
        return
    end
end

num = str2num(str);
if isempty(num)
    t = 0;
    return
end

if round(num) ~= num
    t = 0;
    return
end

if num < 1 | num > noflds
    t = 0;
    return
end
