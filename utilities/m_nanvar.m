function y = m_nanvar(x,dim)

% function y = m_nanvar(x,[dim]); % version of nanvar to avoid stats toolbox
%
% Can be used in a matlab session or called from mcalib or mcalc, or in
% other mexec functions
%
% In this function, columns with no finite values returns nan.
% In this function, columns with precisely one finite value returns 0.
% The normalisation of the denominator is 'n-1'.
%
% This version looks for finite values, which are non-nan and non-inf.
% Arithmetic with inf may be unpredictable, eg
% inf + 1 = inf;
% inf - inf = NaN;
%
% m_nanvar is NaN if there are zero non-NaN values in the row or column
% This is a cut down version of system nanvar;
%   no weights;
%   no choice about n or n-1 denominator
%
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
%   y = m_nanvar(x,1);
%   y = m_nanvar(x,2);
%
% UPDATED:
%   Initial version BAK 2008-10-17 at NOC
%   Help updated by BAK 2009-08-11 on macbook
%

if nargin==1,
    dim = min(find(size(x)~=1)); % default is first non-unity dimension
    if isempty(dim), dim = 1; end
end

ok = isfinite(x);
n = sum(ok,dim);

% the array 'tile' is ones except in the dimension that has been collapsed by
% the summing. Expand xm back in that dimension to make the subtract
% easier.
sx = size(x);
tile = ones(size(sx));
tile(dim) = sx(dim);
xm = m_nanmean(x,dim);
xm2 = repmat(xm, tile);
x0 = x-xm2; % subtract mean

y = m_nansum(x0.*x0,dim); % sum of squares about the mean


% if n = 0; set n = nan so var is nan.
% if n = 1, there is only one finite value contributing to the mean and variance so y is already zero. set n1 = 1
% to avoide divide by zero error.
n(n==0) = NaN;
n1 = n-1;
n1(n1==0) = 1;

y = y ./ n1;

return
