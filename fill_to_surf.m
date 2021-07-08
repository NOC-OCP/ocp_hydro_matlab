function data = fill_to_surf(data);
%function data = fill_to_surf(data);
%
%fill to first row with constant values from first good point in each column (going down)

n = size(data);

%reshape
if length(n)>2
   n0 = n;
   n(2) = numel(n)/n(1);
   data = reshape(data, n(1), n(2));
else
   n0 = [];
end

%first good points
m = repmat([1:n(1)]',1,n(2));
m(isnan(data)) = NaN; m = min(m);
m(isnan(m)) = 1;
indb = sub2ind(n, m, 1:n(2));

%tile
dataf = repmat(data(indb),n(1),1);

%where to fill (above first good points)
mf = repmat([1:n(1)]',1,n(2));
mf(mf>repmat(m,n(1),1)) = NaN;
nf = repmat(1:n(2), n(1), 1);
indf = sub2ind(n, mf(~isnan(mf)), nf(~isnan(mf)));

%fill
data(indf) = dataf(indf);

%reshape
if length(n0)>0
   data = reshape(data, n0);
end