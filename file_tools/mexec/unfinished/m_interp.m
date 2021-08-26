function yi = m_interp(x,y,xi,e1,e2,mg)
% function yi = m_interp(x,y,xi,e1,e2,mg)
% 
% Interpolate x,y onto xi.
% first remove any absent data in x,y
% if e1 and e2 exist they control extrapolation at left and right end
% else default to 0 (no extrapolation)
% if mg exists it sets max gap length to fill (else defaults to inf)
% 

m_common

if nargin < 5
    e1 = 0;
    e2 = 0; 
end
if nargin < 6
    mg = inf;
end

ok = find(~isnan(x+y));
if length(ok) < 2
    yi = y;
    m = 'No interpolation performed because there were fewer than 2 good values';
    fprintf(MEXEC_A.Mfider,'%s\n',m);
    return
end
%keep bad values in too-long gaps so they won't be interpolated over
d = diff(ok)-1;
ii = find(d>mg);
ok = sort([ok ok(ii)+1]);
x = x(ok);
y = y(ok);

yi = interp1(x,y,xi);

firstgood = min(ok);
lastgood = max(ok);

if firstgood > 1
    if e1 == 0;
        % do nothing
    elseif e1 == 1;
        % copy first good variable
        yi(1:firstgood-1) = yi(firstgood);
    else
        % linear extrapolation
        n = min(e1,length(ok));
        p = polyfit(x(1:n),y(1:n),1);
        yi(1:firstgood-1) = polyval(p,xi(1:firstgood-1));
    end
end

if lastgood < length(yi)
    if e2 == 0;
        % do nothing
    elseif e2 == 1;
        % copy first good variable
        yi(lastgood+1:end) = yi(lastgood);
    else
        % linear extrapolation
        n = min(e2,length(ok));
        p = polyfit(x(end-n+1:end),y(end-n+1:end),1);
        yi(lastgood+1:end) = polyval(p,xi(lastgood+1:end));
    end
end

return