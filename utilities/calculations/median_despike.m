function dataout = median_despike(data,s,n)
% function dataout = median_despike(data,s,n)
%
% 1-D data and spike amplitude s (absolute, not relative)
% n-point median despike
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

ind = [1:nd-(n-1)] + [0:n-1]';
mi = (n+1)/2;
med = sort(data(ind)); 
med = med(mi,:);
ki = ki(mi:end-(mi-1));
data = data(mi:end-(mi-1));
m = [abs(data-med)>s];
if sum(m)
    data(m) = NaN;
end
dataout(ki) = data;
