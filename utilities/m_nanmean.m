function y = m_nanmean(x,dim)

% function y = m_nanmean(x,[dim]); % version of nanmean to avoid stats toolbox
%
% Can be used in a matlab session or called from mcalib or mcalc, or in
% other mexec functions
%
% In this function, columns with no finite values returns nan.
%
% This version looks for finite values, which are non-nan and non-inf.
% Arithmetic with inf may be unpredictable, eg
% inf + 1 = inf;
% inf - inf = NaN;
%
% m_nanmean is NaN if there are zero non-NaN values in the row or column
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
%   y = m_nanmean(x,1);
%   y = m_nanmean(x,2);
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
n(n==0) = NaN; % ; avoid divide by zero; m_nanmean is nan if there are zero finite values
y = m_nansum(x,dim) ./ n;

return
