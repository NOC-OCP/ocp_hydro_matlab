function [varlist, var_copystr, iiv] = mvars_in_file(varlist_in, varargin)
% [varlist, var_copystr, iiv] = mvars_in_file(varlist_in, infile);
% [varlist, var_copystr, iiv] = mvars_in_file(varlist_in, varlist_check);
% [varlist, var_copystr, iiv] = mvars_in_file(varlist_in, infile, prestr, poststr);
%
% check varlist_in (1-D cell array of strings) against either varlist_check
%   (1-D cell array of strings) or the variables in infile (mstar .nc
%   filename with path)
% 
% returns:
%   varlist, only the variables that are present in varlist_check or infile; 
%   var_copystr, the concatenation of these variables into a single string,
%     prefixing and/or suffixing each with the optional 3rd and 4th input
%     arguments, respectively, e.g. 
%     'var1 var2 var3' with only 2 input arguments
%     'uvar1 uvar2 uvar3' if the 3rd input is 'u'
%     'var1g var2g var3g' if the 3rd in put is '' and the 4th is 'g'
%  iiv the indices of varlist in varlist_in

if iscell(varargin{1})
    flds = varargin{1};
else
    h = m_read_header(varargin{1});
    flds = h.fldnam;
end

prestr = ''; poststr = '';
if nargin>2
    prestr = varargin{2};
    if nargin>3
        poststr = varargin{3};
    end
end

nv = length(varlist_in);
iiv = []; var_copystr = ' ';
for no = nv:-1:1
    if sum(strcmp(varlist_in{no},flds))>0
        iiv = [iiv no];
        var_copystr = [var_copystr prestr varlist_in{no} poststr ' '];
    end
end
var_copystr = var_copystr(2:end-1);
varlist = varlist_in(iiv);
