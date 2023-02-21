function y = m_nanstd(varargin)

% function y = m_nanstd(x,[dim]); % version of nanstd to avoid stats toolbox
%
% Can be used in a matlab session or called from mcalib or mcalc, or in
% other mexec functions
%
% In this function, columns with no finite values returns nan.
% In this function, columns with precisely one finite value returns 0.
% The normalisation of the denominator is 'n-1'.
% The standard deviation is the square root of the variance calculated
%   using m_nanvar
%
% This version looks for finite values, which are non-nan and non-inf.
% Arithmetic with inf may be unpredictable, eg
% inf + 1 = inf;
% inf - inf = NaN;
%
% m_nanstd is NaN if there are zero non-NaN values in the row or column
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
%   y = m_nanstd(x,1);
%   y = m_nanstd(x,2);
%
% UPDATED:
%   Initial version BAK 2008-10-17 at NOC
%   Help updated by BAK 2009-08-11 on macbook
%

y = sqrt(m_nanvar(varargin{:})); % require varargin to be column; otherwise arguments not passed properly.

return