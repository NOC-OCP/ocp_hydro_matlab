function yf = gp_fillgaps(y, varargin)
% yf = gp_fillgaps(y, varargin);
% yf = gp_fillgaps(y, x, maxgap);
% yf = gp_fillgaps(y, 'first');
% yf = gp_fillgaps(y, 'last');
%
% fill NaNs in columns of y depending on the one or more other input
%   arguments: 
% maxgap, a scalar ([0,inf]), with or without x, a vector: fill runs of
%   NaNs up to maxgap points, or if x is also supplied up to maxgap
%   distance in x, by linear interpolation
% 'first': fill NaNs at the beginning of each column with first good value
%   in that column (e.g. for extrapolating a surface mixed layer) 
% 'last': fill NaNs at the end of each column with last good value in that
%   column 

s = size(y);

maxgap = 0;
dofirst = 0;
dolast = 0;
x = [1:s(1)]';
for no = 1:length(varargin)
    if isnumeric(varargin{no})
        if isscalar(varargin{no})
            maxgap = varargin{no};
        else
            x = varargin{no};
        end
    elseif strcmp(varargin{no},'first')
        dofirst = 1;
    elseif strcmp(varargin{no},'last')
        dolast = 1;
    end
end

yf = y;

if maxgap>0
    for no = 1:s(2)
        iib = find(isnan(y(:,no)));
        if ~isempty(iib) && length(iib)<s(1)-1
            iig = setdiff([1:s(1)]',iib);
            %add to list of good indices, indices at start of (in) too-long
            %gaps; this will put NaNs in interpolation for these gaps
            d = diff(x(iig));
            iig = unique([iig; iig(d>maxgap)+1]); 
            %now interpolate
            yf(iib,no) = interp1(iig, yf(iig,no), iib);
        end
    end
end

if dofirst
    ind = repmat([1:s(1)]',1,s(2));
    indm = ind; indm(isnan(yf)) = inf;
    [fv, ii] = min(indm);
    yfill = repmat(fv,s(1),1);
    yfill(ind>repmat(ii,s(1),1)) = NaN;
    yfill(isnan(yf)) = NaN;
    yfill = sub2ind(size(yf),yfill,repmat(1:s(2),s(1),1));
    m = isnan(yf) & ~isnan(yfill);
    yf(m) = yf(yfill(m));
end

if dolast
    ind = repmat([1:s(1)]',1,s(2));
    indm = ind; indm(isnan(yf)) = 0;
    [fv, ii] = max(indm);
    yfill = repmat(fv,s(1),1);
    yfill(ind<repmat(ii,s(1),1)) = NaN;
    yfill(isnan(yf)) = NaN;
    yfill = sub2ind(size(yf),yfill,repmat(1:s(2),s(1),1));
    m = isnan(yf) & ~isnan(yfill);
    yf(m) = yf(yfill(m));
end
