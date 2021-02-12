function [varlist, var_copystr, iiv] = mvars_in_file(varlist, infile, varargin);
% [varlist, var_copystr, iiv] = mvars_in_file(varlist, infile);
% [varlist, var_copystr, iiv] = mvars_in_file(varlist, infile, prestr, poststr);
%
% exclude any variables in varlist (1-D cell array of strings)
%     that aren't in mstar .nc file infile; indices of those that are are
%     in iiv
%
% concatenate remaining variables into string var_copystr, 
%     with 2 input arguments, looks like 'var1 var2 var3' etc.
%     if the 3rd input argument exists it is prefixed to each of the
%     variable names; if the 4th exists it is suffixed
%     e.g. [varlist, var_copystr] = mvars_in_file(varlist, infile, 'u');
%     produces something like 'uvar1 uvar2 uvar3' etc.
%     and  [varlist, var_copystr] = mvars_in_file(varlist, infile, '', 'g');
%     produces something like 'var1g var2g var3g' etc.

prestr = ''; poststr = '';
if nargin>2
    prestr = varargin{1};
    if nargin>3
        poststr = varargin{2};
    end
end

h = m_read_header(infile);

nv = length(varlist);
iiv = []; var_copystr = ' ';
for no = nv:-1:1
    if sum(strcmp(varlist{no},h.fldnam))>0
        iiv = [iiv no];
        var_copystr = [var_copystr prestr varlist{no} poststr ' '];
    end
end
var_copystr = var_copystr(2:end-1);
varlist = varlist(iiv);
