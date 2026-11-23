function o = oxy_spikeclean(o, n, r)
% oxygen spikes tend to be double-sided (e.g. valley-peak). where they are
% longer, a relatively long-windowed despiker leaves behind runs of
% bad (though near local median) data visible as sharply slanting, nearly
% straight lines 
% removes runs of remaining data (between NaNs) of length no more than
% n with mean curvature/mean slope less than r


g = [0; diff(o)];
g2 = [0; diff(diff(o)); 0];
iig = find(~isnan(o)); 
iid = find(diff(iig)>1); 
iid = [[iig(1); iig(iid+1)] [iig(iid); iig(end)]]';
iid = iid(:,diff(iid)<=n);
gm = repmat(g,1,size(iid,2));
g2m = repmat(g2,1,size(iid,2));
inds = repmat([1:length(o)]',1,size(iid,2));
m = inds>=iid(1,:) & inds<=iid(2,:);
gm(~m) = NaN;
g2m(~m) = NaN;
s = abs(sum(gm,'omitnan')./sum(m)); %average slope, looking for all in one direction
c = sum(abs(g2m),'omitnan')./sum(m); %average magnitude of curvature, looking for nearly straight lines
ms = m & (c./s < r);
o(sum(double(m),2)>0) = NaN;
