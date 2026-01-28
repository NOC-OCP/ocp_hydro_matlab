function ploopflag = m_loopedit(p, maxshoal, minpstep)
%function ploopflag = m_loopedit(p, maxshoal, minpstep)
%
% for downcast data, flag periods where the CTD package either:
%   has reversed more than maxshoal from any earlier point
%     (d1.press(i) < max(d1.press(1:i)) - maxshoal)
%   or
%   is not moving downward by at least minpstep from the last point 
%     (d1.press(i)-d1.press(i-1) < minpstep)
%
%
% see mctd_04

if maxshoal<=0
    error('maxshoal must be positive')
end
if ~isfinite(maxshoal) && ~isfinite(minpstep)
    error('at least one of maxshoal or minpstep must have a defined value')
end

if p(end)<p(1)
    error('only suitable for downcast data')
end

flagup = false(size(p)); flagslo = flagup;

if isfinite(maxshoal)
    %calculate max pressure above (before) each point, using chunks to keep
    %matrices manageable
    if size(p,1) == 1
        p = p';
    end
    np = length(p);
    nm = 5000; ns = ceil(np/nm);
    pm = p;
    for no = 1:ns
        ii = [1:nm]+(no-1)*nm; 
        if no==ns
            ii = ii(ii<=np); nm = length(ii);
        end
        %max pressure within this chunk and up to each time
        pm(ii) = max(triu(repmat(p(ii),1,nm),1))';
        %check against earlier chunks
        if no>1
            pm(ii) = max(pm(ii),max(pm(1:ii(1)-1)));
        end
    end
    flagup =(p<=pm-maxshoal);
end

if isfinite(minpstep)
    %speed to this point
    flagslo(2:end) = p(2:end)-p(1:end-1) < minpstep;
end

ploopflag = flagslo | flagup;
