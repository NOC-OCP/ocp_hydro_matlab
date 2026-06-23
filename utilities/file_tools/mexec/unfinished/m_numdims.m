function d = m_numdims(data)
% function d = m_numdims(data)
%
% test if array is 1d or 2d

nrows = size(data,1);
ncols = size(data,2);

if min(nrows,ncols) > 1;
    d = 2;
else
    d = 1;
end

return


