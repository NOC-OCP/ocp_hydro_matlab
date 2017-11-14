function y = m_nansum(x,dim)

% function y = m_nansum(x,[dim]); % version of nansum to avoid stats toolbox
%
% Can be used in a matlab session or called from mcalib or mcalc, or in
% other mexec functions
%
% The matlab version returns zero if there are zero non-nan values
% In this function, columns with no finite values returns nan instead.
%
% This version looks for finite values, which are non-nan and non-inf.
% Arithmetic with inf may be unpredictable, eg
% inf + 1 = inf;
% inf - inf = nan;
%
% m_nansum is NaN if there are zero non-NaN values in the row or column
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
%   y = m_nansum(x,1);
%   y = m_nansum(x,2);
%
% UPDATED:
%   Initial version BAK 2008-10-17 at NOC
%   Help updated by BAK 2009-08-11 on macbook
%

if nargin==1,
    dim = min(find(size(x) > 1)); % default is first non-unity dimension
    if isempty(dim), dim = 1; end
end

ok = isfinite(x);
x(~ok) = 0;
y = sum(x,dim);

n = sum(ok,dim);
n(n==0) = NaN; % set nans if there are zero non-nan values included in the sum
n = 0*n; % elements are now zeros with nans; this is a ( 0 or nan) mask for columns with zero non-nan values
y = y + n;% mask out the columns that contain zero non-nan values

return