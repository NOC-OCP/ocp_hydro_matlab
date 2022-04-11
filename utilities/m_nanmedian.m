function y = m_nanmedian(x,dim)

% function y = m_nanmedian(x,[dim]); % version of nanmedian to avoid stats toolbox
%
% Can be used in a matlab session or called from mcalib or mcalc, or in
% other mexec functions
%
% In this function, columns with no non-NaN values returns NaN.
% This function allows -inf and inf, because they behave sensibly in the
%   call to Matlab 'sort'.
% It is allowable for the median value to be -inf or inf.
% If the median value lies midway between a finite value and inf, the
%   result is inf. If the median value lies midway between -inf and inf,
%   the result is NaN.
%
% This version excludes NaN, then uses m_prctile to find the 50th
%   percentile. If the number of non-NaN values in a column is odd, the 
%   result is the middle value. If the number of non-NaN values is even, 
%   the result is half the sum of the two middle values.
%
% INPUT:
%   x: data to be processed; can be N-Dimensional
%   dim: dimension of x used for direction of processing
%        If dim is not specified, the first non-unity dimension is used.
%        If all dimensions are unity, dim defaults to 1
%
% OUTPUT:
%   y: Often has the same number of dimensions as x
%      The dimension number dim is collapsed to length 1.
%      Since a call is made to the Matlab 'sum' function,
%      if dim > 2 and if dim is the last dimension, then
%      the resulting dimension of length 1 is squeezed.
%
% EXAMPLES:
%   y = m_nanmedian(x,1);
%   y = m_nanmedian(x,2);
%
% UPDATED:
%   Initial version BAK 2008-10-17 at NOC
%   Help updated by BAK 2009-08-11 on macbook
%

if nargin==1,
    dim = min(find(size(x)~=1)); % default is first non-unity dimension
    if isempty(dim), dim = 1; end
end

y = m_nanprctile(x,50,dim);

return
