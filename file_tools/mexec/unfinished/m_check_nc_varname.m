function vname = m_check_nc_varname(vname, varargin)
% function vname = m_check_nc_varname(vname)
% function vname = m_check_nc_varname(vname,[printsummary=1])
%
% convert any characters found in var names in nc files that are illegal or troublesome in matlab
% called from mload which tries to dump all nc file variables into matlab
% variables of the same name

% pretty much cut and pasted from name checking in pload

if nargin==1
    printsummary = 1;
else
    printsummary = varargin{1};
end

varnames = '';

vn = vname;
vnold = vn;
renamed = 0;
%list of problem characters that may occur in pstar  or nc file names
%you can add to the list as new ones are discovered.
%Blanks are simply discarded.
if strcmp(vn,'        ') % if the pstar fldnam was all blanks, rename the variable.
    vn = ['blank_' num2str(k) '_'];
    renamed = 1;
end

%remove trailing blanks;
while strcmp(vn(end),' ')
    vn(end) = [];
end

swap = {
    ' ' '_space_'
    '-' '_minus_'
    '+' '_plus_'
    '/' '_slash_'
    '*' '_star_'
    '.' '_dot_'
    '#' '_hash_'
    '$' '_dollar_'
    '^' '_hat_'
    '&' '_amp_'
    '(' '_lparen_'
    ')' '_rparen_'
    '[' '_lbrac_'
    ']' '_rbrac_'
    } ;
nswaps = size(swap,1);
for k2 = 1:nswaps
    s1 = char(swap(k2,1));
    s2 = char(swap(k2,2));
    sindex = findstr(vn,s1);
    if ~isempty(sindex)
        vnew = '';
        count = 1;
        for kswap = 1:length(sindex)
            vnew = [vnew vn(count:sindex(kswap)-1) s2];
            count = sindex(kswap)+1;
        end
        vnew = [vnew vn(count:end)];
        vn = vnew;
        renamed = 1;
    end
end

%replace any other odd characters with underscore. We'll permit alphanumeric and underscore in matlab var names.
okchars = '_0123456789abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ';
for k2 = 1:length(vn)
    if isempty(findstr(okchars,vn(k2)))
        vn(k2) = '_';
        renamed = 1;
    end
end

okfirstchar = 'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ'; %must start with an alpha; if not, insert 'v_'
if isempty(findstr(okfirstchar,vn(1)))
    vn = ['v_' vn];
    renamed = 1;
end

if length(vn) > 26 %truncate. Allow for later addition of _nnn_ and still keep
    %total var name to shorter than 31, which seems to be needed in
    % Matlab fieldnames in a structure.
    vn = vn(1:26);
    renamed = 1;
end


smatch = strmatch(vn,varnames,'exact');
if ~isempty(smatch)
    vn = [vn '_' num2str(k) '_'];
    renamed = 1;
end
if renamed == 1 && printsummary == 1
%     disp(['Variable number ' sprintf('%3d',k) ':''' vnold ''' renamed to ''' vn '''']);
    disp(['Variable number :''' vnold ''' renamed to ''' vn '''']);
end
vname = vn;

