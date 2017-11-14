function y = m_nancumsum(x,dim)

% version of cumsum to handle nans
%
% columns with no finite values returns nan for every element of the
% cumsum. If there is at least one finite value in the column, non-finite
% values are replaced by zero before calling matlab cumsum.
%
% The matlab version of cumsum returns nan or inf depending on whether
% there is some combination of nan, inf, -inf in the array.
%
% this version looks for finite values, which are non-nan and non-inf
% arithmetic with inf may be unpredictable, eg
% inf + 1 = inf;
% inf - inf = nan;
%
% BAK at noc 18 Nov 2009


if nargin==1,
    dim = min(find(size(x) > 1)); % default is first non-unity dimension
    if isempty(dim), dim = 1; end
end

ok = isfinite(x);
x(~ok) = 0;
y = cumsum(x,dim);

n = sum(ok,dim);
n(n==0) = NaN; % set nans if there are zero non-nan values included in the sum
n = 0*n; % elements are now zeros with nans; this is a ( 0 or nan) mask for columns with zero non-nan values

% now create a template to set columns with zero finite values to nan
% thrughout the column
tiles = 1+0*size(x);
tiles(dim) = size(x,dim);
rep_n = repmat(n,tiles); % repmat in the direction of dim.

y = y + rep_n;% mask out the columns that contain zero finite values

return
