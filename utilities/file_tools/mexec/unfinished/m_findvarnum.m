function varnum = m_findvarnum(vname,h)
% function varnum = m_findvarnum(vname,h)
%
% seek exact match for vname in h.fldnam

varnum = strmatch(vname,h.fldnam,'exact');
if length(varnum) ~= 1
    m= ['Failed to find a unique match in header for variable name ' vname];
    error(m)
end

return