function [dn, up] = cast_split(d, varargin)
% [dn, up] = cast_split(d)
% structure d contains data time series, including scan number
% cast will be divided at deepest point
% 
% [dn, up] = cast_split(d, [start, bot, end])
% cast will be divided on scans closes to start, bot, end
% 
% [dn, up] = cast_split(d, [], pg)
% cast will be divided at deepest point and linearly interpolated from
% d.press to pg 
% 
% output structures dn and up contain down and up parts of the cast
%

if nargin>1 && ~isempty(varargin{1})
    sb = varargin{1};
    [~,iis] = min(abs(d.scan-sb(1)));
    [~,iie] = min(abs(d.scan-sb(3)));
    [~,iib] = min(abs(d.scan-sb(2)));
    iid = iis:iib;
    iiu = iib:iie;
else
    iib = find(d.press==max(d.press)); iib = iib(1);
    iid = 1:iib;
    iiu = iib:length(d.press);
end

d = struct2table(d);
dn = d(iid,:);
up = d(iiu,:);
if nargin>2 && ~isempty(varargin{2})
    pg = varargin{2};
    t = interp1(dn.press,dn{:,:},pg);
    dn = array2table(t,'VariableNames',dn.Properties.VariableNames);
    t = interp1(up.press,up{:,:},pg);
    up = array2table(t,'VariableNames',up.Properties.VariableNames);
end

dn = table2struct(dn,'ToScalar',true);
up = table2struct(up,'ToScalar',true);