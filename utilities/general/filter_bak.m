function y = filter_bak(b, x, varargin)
% function y = filter_bak(b, x)
% function y = filter_bak(b, x, filttype)
%
% x is a 1-D vector
% b gives weights or filter length
% optional input filttype is
%     'nonorm', 'cont', 'median', or (default) 'default'
%
% filttype default:
%     b is a set of weights and its length must be an odd number
%         e.g. b = [1 1 1]
%         or b = [1 2 3 2 1]
%     The vector x is first extended at each end with NaNs so that the
%         centered filter can be applied conveniently at all values of x.
%         Wherever NaN appears in x the weight is ignored. If the sum of
%         the weights is zero (ie no good values of x) the result in y is
%         NaN. 
%     Filter (if b is of length 2*n+1): 
%         sum(b)*y(k) = sum over [k = -n:1:n], x(k+k)*b(n+1+k)
%         i.e.
%         sum(b)*y(k) = b(1)*x(k-n)+ ... 
%                     + b(1+k)*x(k-n+k) + ... 
%                     + b(n+1)*x(k) + ... 
%                     + b(2n+1)*x(k+n)
%
% filttype nonorm:
%     same as default except weights can be negative***
%
% filttype cont:
%     same as default except (like filtfilt) 
%
% filttype median:
%     same as default except b gives the length of the filter and must be
%         an odd number 
%         e.g. b = 101
%     The output y is the same length as x and each value is the median of
%         a centred subset of x of length b.
%
% BAK 14 nov 2008, 17 jan 2016 dy040
% feb 2022 dy146: ylf combined filter_bak_* into this single function with
% optional filttype

if ~isempty(varargin)
    filttype = varargin{1};
else
    filttype = 'default';
end

nx = length(x);

y = NaN+x; % initialise y

%check filter length
switch filttype
    case 'median'
        n = (b-1)/2; % should ensure b is an odd number
        del = b - (2 * floor(n) + 1);
        if del > 0
            error('filter ''b'' must be an odd number')
        end
    case {'default' 'nonorm' 'cont'}
        n = (length(b)-1)/2; % should ensure length(b) is an odd number
        del = length(b) - (2 * floor(n) + 1);
        if del > 0
            error('filter ''b'' must have an odd number of elements')
        end
end

%deal with ends
switch filttype
    case {'default' 'nonorm' 'median'}
        xadd1 = nan+ones(1,n);
        xadd2 = xadd1;
    case 'cont'
        %options from filtfilt, ensuring y(1) = x(1) and y(end) = x(end)
        xp = x(2:n+1);
        xp = xp(:)';
        xp = fliplr(xp);
        xadd1 = 2*x(1)-xp;
        xp = x(nx-n:nx-1);
        xp = xp(:)';
        xp = fliplr(xp);
        xadd2 = 2*x(nx)-xp;
end
xe = [xadd1 x(:)' xadd2];

%step through x to calculate
switch filttype
    case 'median'
        for kx = 1:nx
            xpart = xe(kx:kx+2*n);
            y(kx) = m_nanmedian(xpart);
        end
    case {'default' 'cont'}
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
    case 'nonorm'
        for kx = 1:nx
            xpart = xe(kx:kx+2*n);
            w = b;
            w(isnan(xpart)) = nan; % discard weight where x is NaN
            s = m_nansum(xpart.*w); % bak on di346 jan 2010; use m_nansum in place of nansum.
            ws = m_nansum(w);
            if ws ~= 0
                y(kx) = s/ws;
            else
                y(kx) = s;
            end
        end
end