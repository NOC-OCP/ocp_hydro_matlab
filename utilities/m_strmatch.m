function kmat = strmatch(str, strarray, varargin);

% mexec replacement for matlab strmatch because it will eventually be
% withdrawn.
%
% here is the old matlab help. 
%
%
% % I = STRMATCH(STR, STRARRAY) looks through the rows of the character
% %     array or cell array of strings STRARRAY to find strings that begin
% %     with the string contained in STR, and returns the matching row indices. 
% %     Any trailing space characters in STR or STRARRAY are ignored when 
% %     matching. STRMATCH is fastest when STRARRAY is a character array. 
% %  
% %     I = STRMATCH(STR, STRARRAY, 'exact') compares STR with each row of
% %     STRARRAY, looking for an exact match of the entire strings. Any 
% %     trailing space characters in STR or STRARRAY are ignored when matching.
% %  
% %     Examples
% %       i = strmatch('max',strvcat('max','minimax','maximum'))
% %     returns i = [1; 3] since rows 1 and 3 begin with 'max', and
% %       i = strmatch('max',strvcat('max','minimax','maximum'),'exact')
% %     returns i = 1, since only row 1 matches 'max' exactly.
% %     
% %     STRMATCH will be removed in a future release. Use STRNCMP instead.
%
% bak during jc191; 19 Feb 2020
% The action in the matlab strmatch seems to be that if exact is specified,
% and the strarray end in either null or space, the str is padded to the
% same length as strarray with null or space. The help text only refers to
% 'space'.

% first figure out if it is required ot be an exact match

vargs = varargin(:);
nvargs = length(vargs);

if nargin < 3
    if nargin ~= 2
        fprintf(2,'%s\n',' This mexec version of strmatch expects precisely 2 or 3 arguments')
        error('mexec strmatch wrong number of arguments')
    end
end

eflag = 0;
if nargin == 3
    if strcmp(vargs{1},'exact')
        eflag = 1;
    else
        fprintf(2,'%s\n',' In this mexec version of strmatch, ''exact'' is the only allowable third argument')
        error('mexec strmatch wrong third argument')
    end
end

if nargin > 3
        fprintf(2,'%s\n',' In this mexec version of strmatch, more than three arguments are not allowed')
        error('mexec strmatch too many arguments')
end

% check if str is 1 1-D char string

if ischar(str)
    s1 = size(str);
    if min(s1) == 0
        kmat = []; % input string empty
        return
    elseif min(s1) ~= 1
        fprintf(2,'%s\n',' In this mexec version of strmatch, the first string should be a Mx1 or 1XN char array')
        error('mexec strmatch first argument is not Mx1 or 1xN')
    end
else
    fprintf(2,'%s\n',' In this mexec version of strmatch, the first string should be a Mx1 or 1XN char array')
    error('mexec strmatch first argument not of type char')
end

% if we get here str is a 1-D char string

% check if strarray is a str array or a cell
nu = char(0);
sp = ' ';

if ischar(strarray)
    s2 = size(strarray);
    nr = s2(1); nc = s2(2); % nr number of rows of char array
    if nc == 0; % make sure it has at least one row, even when nc is zero.
        strarray = reshape(strarray,max(nr,1),nc);
        s2 = size(strarray);
        nr = s2(1); nc = s2(2); % number of rows of char array
    end
    kmat = [];
    for kr = 1:nr
        str2 = strarray(kr,:); 
        lendif = length(str2) - length(str);
        if lendif < 0; continue; end
        if eflag == 1  % If str2 ends in null or space, pad str with null or space before testing for match
            if strcmp(str2(end),sp)
                str = [str(:)' sp(ones(1,lendif))];
            end
            if strcmp(str2(end),nu)
                str = [str(:)' nu(ones(1,lendif))];
            end
        end
        if eflag == 1
            if strcmp(str,str2) % find when strarray exactly matches str
                kmat = [kmat; kr];
            end
        else
            if strcmp(str,str2(1:length(str))) % find when strarray starts with str
                kmat = [kmat; kr];
            end
        end
    end
elseif iscell(strarray)
    nr = length(strarray); % number of elements of cell
    kmat = [];
    for kr = 1:nr
        str2 = strarray{kr};
        lendif = length(str2) - length(str);
        if lendif < 0; continue; end
        if eflag == 1  % If str2 ends in null or space, pad str with null or space before testing for match
            if strcmp(str2(end),sp)
                str = [str(:)' sp(ones(1,lendif))];
            end
            if strcmp(str2(end),nu)
                str = [str(:)' nu(ones(1,lendif))];
            end
        end
        if eflag == 1
            if strcmp(str,str2) % find when strarray exactly matches str
                kmat = [kmat; kr];
            end
        else
            if strcmp(str,str2(1:length(str))) % find when strarray starts with str
                kmat = [kmat; kr];
            end
        end
    end
    
else
    fprintf(2,'%s\n',' In this mexec version of strmatch, the second string string should be char array or cell array')
    error('mexec strmatch second argument is not char array or cell array')
    
end

kmat = reshape(kmat,size(kmat,1),1); % Ensure it has 1 col, like old matlab version.



