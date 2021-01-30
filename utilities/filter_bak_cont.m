function y = filter_bak(b,x)
% function y = filter_bak(b,x)
%
% x is a 1-D vector
% b is a set of weights and its length must be an odd number
%
% eg b = [1 1 1]
% or b = [1 2 3 2 1]
%
% If b is of length 2*n+1
%
% sum(b)*y(k) = sum over [k = -n:1:n], x(k+k)*b(n+1+k)
% ie
% sum(b)*y(k) = b(1)*x(k-n)+ ... + b(1+k)*x(k-n+k) + ... + b(n+1)*x(k) + ... + b(2n+1)*x(k+n)
 
% The vector x is first extended at each end with NaNs so that the centered filter can 
% be applied conveniently at all values of x.
% Wherever NaN appears in x the weight is ignored.
% If the sum of the weights is zero (ie no good values of x) the result in y is
% nan
%
% The sums use nansum, so that NaNs are handled as gracefully as possible
% BAK 14 nov 2008



% b = [1 2 3 2 1];
% b = [1 1 1];
nx = length(x);

n = (length(b)-1)/2; % should ensure length(b) is an odd number
del = length(b) - (2 * floor(n) + 1);
if del > 0
    error('filter ''b'' must have an odd number of elements')
end

y = nan+x; % initialise y
xadd1 = nan+ones(1,n);
xadd2 = xadd1;
% FILTFILT uses the following option, which ensures
% y(1) = x(1) and y(end) = x(end). This may or may not be a good thing.
%---
xp = x(2:n+1);
xp = xp(:)';
xp = fliplr(xp);
xadd1 = 2*x(1)-xp;
xp = x(nx-n:nx-1);
xp = xp(:)';
xp = fliplr(xp);
xadd2 = 2*x(nx)-xp;
%---

xe = [xadd1 x(:)' xadd2];
for kx = 1:nx
    xpart = xe(kx:kx+2*n);
    w = b;
    w(isnan(xpart)) = nan; % discard weight where x is NaN
    s = m_nansum(xpart.*w); % bak on di346 jan 2010; use m_nansum in place of nansum.
    ws = m_nansum(w);
    if ws > 0
        y(kx) = s/ws;
    end
end
