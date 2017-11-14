function yi = m_interp(x,y,xi,e1,e2)
% function yi = m_interp(x,y,xi,e1,e2)
% 
% Interpolate x,y onto xi.
% first remove any absent data in x,y
% if e1 and e2 exist they control extrapolation at left and right end

m_common

if nargin < 5
    e1 = 0;
    e2 = 0; 
end

ok = find(~isnan(x+y));
if length(ok) < 2
    yi = y;
    m = 'No interpolation performed because there were less than 2 good values';
    fprintf(MEXEC_A.Mfider,'%s\n',m);
    return
end
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