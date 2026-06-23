function yg = gp_binav(y, x, xe, method, varargin)
% yg = gp_binav(y, x, xe, method)
% yg = gp_binav(y, x, xe, method, bin_partial)
%
% grid columns of y in x bins with edges [xe(:,1) xe(:,2)]
% x is Nx1, y is NxM, xe is Px1
%
% method: 
% 'mean' or 'median' average
% 'lfit', midpoint value of linear fit to y in each bin
% optional inputs (parameter-value pairs):
%   ignore_nan (default 0) whether to exclude NaNs from calculations
%   bin_partial (default 1) whether to produce a value for bins with data
%     in only one half 
%
% ylf dy146

ignore_nan = 0;
bin_partial = 1;
for no = 1:2:length(varargin)
    eval([varargin{no} ' = varargin{no+1};'])
end

if size(xe,2)==1
    error('xe must have two columns, giving low and high edges of bins')
end
xm = .5*(xe(:,1)+xe(:,2));

s = size(y);
yg = nan(length(xm),s(2));

%first sort x, y on x
m = ~isnan(x); x = x(m); y = y(m,:);
[x, ii] = sort(x); y = y(ii,:);
%and for xm, xe, list bins that are within x range, to loop through in order
[~,iib] = sort(xm);
if bin_partial
    iib = iib(xe(:,2)>x(1) & xe(:,1)<x(end));
else
    iib = iib(xm>x(1) & xm<x(end));
end
iib = iib(:)';


%loop through bins
for bno = iib
    
    xmask = (x>=xe(bno,1) & x<=xe(bno,2));
    if sum(xmask)
    
        xb = x(xmask);
        if bin_partial || (xb(1)<xm(bno) && xb(end)>xm(bno))
        
            yb = y(xmask,:);
            if ignore_nan
                m = ~isnan(yb);
            else
                m = true(size(yb));
            end
            
            switch method
                case 'mean'
                    w = sum(double(m),1);
                    yb(~m) = 0;
                    yg(bno,:) = sum(yb,1)./w;
                    yg(bno,w==0) = NaN;
                    
                case 'med'
                    mid = sum(m,1)/2;
                    ii1 = find(mid==0.5); %for nanmedian, only one good point
                    ii0 = find(mid==0); %for nanmedian, no good points
                    mid([ii0 ii1]) = size(yb,1); %these will be NaN but will fill in ii1 after
                    yb = sort(yb,1);
                    if s(2)==1
                        ind1 = floor(mid);
                        ind2 = ceil(mid);
                    else
                        ind1 = sub2ind(size(yb),floor(mid),1:s(2));
                        ind2 = sub2ind(size(yb),ceil(mid),1:s(2));
                    end
                    yg(bno,:) = .5*(yb(ind1)+yb(ind2));
                    yg(bno,ii1) = min(yb(:,ii1),[],1); %for nanmedian, only good value

                case 'lfit'
                    w = sum(double(m),1);
                    for no2 = 1:s(2)
                        if w(no2)>1
                            try
                                b = [ones(w(no2),1) xb(m(:,no2))]\yb(m(:,no2),no2);
                                yg(bno,no2) = b(1)+b(2)*xm(bno);
                            catch
                                keyboard
                            end
                        end
                    end    

            end
            
        end
        %discard the already-used x, y (okay because they are in order)
        iiu = 1:find(xmask, 1, 'last');
        x(iiu) = []; y(iiu, :) = [];

    end
end
