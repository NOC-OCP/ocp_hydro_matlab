function dataout = median_despike(data,s)
% function dataout = median_despike(data,s)
%
% 1-D data and spike amplitude s (absolute, not relative)
% 5-point median despike
%
% based on m_median_despike BAK

dataout = nan+data;

n = length(data);
ki = 1:n;

knan = find(isnan(data));
ki(knan) = [];
data(knan) = [];

% not central window for data at ends
k = 1;
while k <= length(data)
%     keep the good ones, throw out the spikes; make a note of which data cycles are kept.
    if k < 3
        kw = 3;
    elseif  k > length(data)-2
        kw = length(data)-2;
    else
        kw = k;
    end
    d5 = data(kw-2:kw+2);
    s5 = sort(d5);
    if abs(d5(3+k-kw)-s5(3)) > s
        data(k) = [];
        ki(k) = [];
        continue
    else
        k = k+1;
        continue
    end
end

dataout(ki) = data;
return
