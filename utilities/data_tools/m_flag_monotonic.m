function flag = m_flag_monotonic(data)
% function flag = m_flag_monotonic(data)
%
% set a flag to be zero where a variable is not strictly monotonic
% flag = 1 where the value is greater than the previous good value.
% first non-nan value is always good.

% unfinished should be made to work along rows or columns of 2-D file

flag = zeros(size(data));

n = length(data);
ki = 1:n;

knan = find(isnan(data));
ki(knan) = [];
data(knan) = [];



k = 2;
while k <= length(data)
%     keep the good ones, throw out the spikes; make a note of which data cycles are kept.
    if data(k) <= data(k-1)
        data(k) = [];
        ki(k) = [];
    else
        k = k+1;
    end

end

flag(ki) = 1;
return
