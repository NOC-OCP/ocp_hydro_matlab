function y = filter_bak_median(b,x)
% function y = filter_bak_median(b,x)
%
% x is a 1-D vector
% b is a length and must be an odd number
%
% eg b = 101
%
% The output y is the same length as x and each value is the median of the centred subset of x
% of length b. 
% 
%
% The vector x is first extended at each end with NaNs so that the centred filter can 
% be applied conveniently at all values of x.
% Wherever NaN appears in x the value is ignored.
%
% The filter uses nanmedian, so that NaNs are handled as gracefully as possible
% BAK 14 nov 2008; based on filter_bak; new version with median filter bak 17 jan 2016 dy040



nx = length(x);

n = (b-1)/2; % should ensure b is an odd number
del = b - (2 * floor(n) + 1);
if del > 0
    error('filter ''b'' must be an odd number')
end

y = nan+x; % initialise y
xadd1 = nan+ones(1,n);
xadd2 = xadd1;

xe = [xadd1 x(:)' xadd2];
for kx = 1:nx
    xpart = xe(kx:kx+2*n);
    y(kx) = m_nanmedian(xpart); % bak on dy040
end
return % return added by bak dy040

