function dataout = median_despike(data, n, aspike, rspike)
% function dataout = median_despike(data, n, aspike, rspike)
%
% 1-D data
%
% using n-point windows for odd n, or (n+1)-point windows for even n, 
% removes points that differ from the median by more than aspike, if aspike
% is not empty, or by more than rspike*standard deviation, if aspike is
% empty 
% 
% based on m_median_despike BAK

dataout = data;
if size(data,2)==1
    data = data.';
end
if n/2==floor(n/2)
    n = n+1;
end

ki = 1:length(data);
knan = find(isnan(data));
ki(knan) = [];
data(knan) = [];
nd = length(data);

ind = [1:nd-(n-1)] + [0:n-1]'; %all possible consecutive n-point windows
mi = (n+1)/2; %index of midpoint in each n-point window
med = sort(data(ind)); 
med = med(mi,:); %median of each n-point window
ki = ki(mi:end-(mi-1)); %indices in original data that have these medians
data = data(mi:end-(mi-1)); %truncate start and end
if isempty(aspike)
    sig = std(data(ind),'omitmissing');
    m = [abs(data-med)>rspike*sig];
else
    m = [abs(data-med)>aspike];
end
if sum(m)
    data(m) = NaN;
end
dataout(ki) = data;
