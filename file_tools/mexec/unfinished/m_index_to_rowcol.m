function [row col] = m_index_to_rowcol(k,h,varnum)
% function [row col] = m_index_to_rowcol(k,h,varnum)
%
% convert k to row and col

nrows = h.dimrows(varnum);
ncols = h.dimcols(varnum);

col = 1 + floor((k-1)/nrows);
row = k - nrows*(col-1);
return