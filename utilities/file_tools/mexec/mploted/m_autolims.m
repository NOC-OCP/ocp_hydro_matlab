function lims = m_autolims(x,nti)
% function lims = m_autolims(x,nti)
%
% return auto scaled lims for plotting 
% x is the data; nti is the required number of intervals
% defualt number of intervals is 10

if nargin < 2; nti = 10; end

x1 = min(x);
x2 = max(x);

if isnan(x1) | isnan(x2)
    % all data absent so make arbitrary choice for lims
    x1 = -1;
    x2 = 1;
end

r = x2-x1;

if r < 1e-10 % trap cases where data has small or no range; can set yax explicitly
    % is needed.
    x1 = x1-1;
    x2 = x2+1;
    r = x2-x1;
end
    
r2 = r/nti; % lower bound for size of tick interval
% r2 = max(1e-10,r2); %trap cases where data has no range

round_1 = 10;
scl = (10^ceil(log10(r2)))/round_1; % a scaling to ensure there is reasonable rounding in the tick interval
% to allow finer rounding in tick interval, set round_1 to a higher number,
% eg round_1 = 10.

ok = 0;
while ok >= 0

    ti = scl*ceil(r2/scl) + ok*2*scl; %first guess at tick interval; above lower bound.

    x1b = floor(x1/ti);
%     x2b = ceil(x2/ti);

    x1c = x1b*ti;
    x2c = x1c + ti*nti;
    
    
    while x1c <= x1
        x2c = x1c + ti*nti;
        if x2c >= x2
            ok = -1; % we have found a suitable tick origin and interval
            break
        else
            round_2 = 1;
%             disp('shifting phase')
            x1c = x1c + ti/round_2; % shift the tick origin by a small amount.
           % to allow smaller shifts in the tick origin set round_2 to a
           % smaller number.
        end
    end
    if ok >= 0; % failed to find satisfactory ticks with this ti; iterate with larger ti.
        ok = ok + 1;
%         disp('increasing ti')
    end
end
    
lims = [x1c x2c];