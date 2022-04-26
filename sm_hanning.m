function datas = sm_hanning(data, nw, varargin);
%function datas = sm_hanning(data, nw, edgefill);
%
%smooth data in the first dimension by running averaging with a hanning window of length nw
%(or if nw is even, nw-1)
%
%if edgefill==0 or is not specified
%   the (nw-1)/2 points at the edges of good data regions (including the top and bottom) will be NaNs
%if edgefill==1
%   nansum will be used to fill all points

if iseven(nw); nw = nw-1; end
w = hanning(nw); sw = sum(w); ned = (nw+1)/2;

datas = NaN+data;

ne = numel(data);
n1 = size(data, 1);
n2 = ne/n1;

ef = 0; if length(varargin)>0 & varargin{1}==1; ef = 1; end %no new NaNs

if n1>=n2 %more rows than columns, loop through columns
   ii = repmat([1:nw]', 1, n1-nw+1) + repmat([0:n1-nw], nw, 1);
   w = repmat(w, 1, n1-nw+1);
   for no = 1:ne/n1
      a = data(:, no); a = a(ii);
      datas(ned:n1-ned+1, no) = sum(a.*w).'/sw;
   end
else %fewer rows than columns, loop through rows
   w = repmat(w, 1, n2);
   for no = ned:n1-ned+1
      a = data(no-ned+1:no+ned-1, :);
      datas(no, :) = sum(a.*w)/sw;
   end
end

if ef %fill to edges of original good data with as much smoothing as possible for each point
   nw0 = nw;
   for nw = nw0-2:-2:1
      ned = (nw-1)/2; w = hanning(nw); sw = sum(w);
      [iib, jjb] = find(isnan(datas(ned+1:end-ned,:)) & ~isnan(data(1:end-nw+1,:)) & ~isnan(data(nw:end,:)));
      iib = iib+ned;
      iib = iib(:)'; jjb = jjb(:)'; nj = length(jjb);
      indb = sub2ind([n1 n2], iib, jjb);
      iiin = repmat(iib, nw, 1) + repmat([-ned:ned]', 1, nj); indin = sub2ind([n1 n2], iiin, repmat(jjb, nw, 1));
      datas(indb) = sum(data(indin).*repmat(w, 1, nj), 1)/sw;
   end
end