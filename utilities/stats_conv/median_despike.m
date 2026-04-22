function dataout = median_despike(data,smax,varargin)
% function dataout = median_despike(data,smax)
% function dataout = median_despike(data,smax,l)
%
% 1-D data, NaN spikes larger than smax (absolute, not relative) over
% l-point median (default: 5)
%
% if l is even it will be increased by 1
%
% based on m_median_despike BAK

if nargin>2
    l = varargin{1};
    if floor(l/2)==l/2
        l = l+1;
    end
else
    l = 5;
end
wmid = ceil(l/2);
wid = wmid-1;

dataout = nan+data;

ki = 1:length(data);
m = isnan(data);
ki(m) = [];
data(m) = [];

% not central window for data at ends
k = 1;
while k <= length(data)
%     keep the good ones, throw out the spikes; make a note of which data cycles are kept.
    if k < wmid
        kwin = wmid;
    elseif  k > length(data)-wid
        kwin = length(data)-wid;
    else
        kwin = k;
    end
    dwin = data(kwin-wid:kwin+wid);
    swin = sort(dwin); 
    if abs(dwin(wmid+k-kwin)-swin(wmid)) > smax
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
