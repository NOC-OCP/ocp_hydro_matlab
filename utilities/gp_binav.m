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

xm = .5*(xe(:,1)+xe(:,2));

s = size(y);

yg = nan(length(xm),s(2));
%loop through bins
for bno = 1:length(xm)
    
    xmask = (x>=xe(bno,1) & x<=xe(bno,2));
    if sum(xmask)
    
        xb = x(xmask);
        if (min(xb)<xm(bno) && max(xb)>xm(bno)) || bin_partial
        
            yb = y(xmask,:);
            if ignore_nan
                m = ~isnan(yb);
            else
                m = true(size(yb));
            end
            
            switch method
                case 'mean'
                    w = sum(double(m));
                    yb(~m) = 0;
                    yg(bno,:) = sum(yb)./w;
                    yg(bno,w==0) = NaN;
                    
                case 'median'
                    mid = sum(m)/2;
                    ii1 = find(mid==0.5); %for nanmedian, only one good point
                    ii0 = find(mid==0); %for nanmedian, no good points
                    mid([ii0 ii1]) = size(yb,1); %these will be NaN but will fill in ii1 after
                    yb = sort(yb);
                    s2 = size(yb,2);
                    if s2==1
                        ind1 = floor(mid);
                        ind2 = ceil(mid);
                    else
                        ind1 = sub2ind(size(yb),floor(mid),1:s2);
                        ind2 = sub2ind(size(yb),ceil(mid),1:s2);
                    end
                    yg(bno,:) = .5*(yb(ind1)+yb(ind2));
                    yg(bno,ii1) = min(yb(:,ii1)); %for nanmedian, only good value
                    
                case 'lfit'
                    yg = NaN(1,s(2));
                    w = sum(double(m));
                    for no2 = 1:s(2)
                        if w(no2)>0
                            b = [ones(w,1) xb(m(:,no2))]\yb(m(:,no2),no2);
                            yg(bno,no2) = b(1)+b(2)*xm;
                        end
                    end        
            end
            
        end
    end
end


