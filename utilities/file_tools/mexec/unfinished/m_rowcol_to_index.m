function k = m_rowcol_to_index(row,col,h,varnum)
% function k = m_rowcol_to_index(row,col,h,varnum)
%
% convert row and col to k

nrows = h.dimrows(varnum);
ncols = h.dimcols(varnum);

k = row + nrows * (col-1);
return