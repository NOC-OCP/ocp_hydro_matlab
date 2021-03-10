function ym = merge_avmed(x,y,xi,medav,absfill);
% function ym = merge_avmed(x,y,xi,medav,absfill);
%
% merge y (MxN) from x (Mx1) onto xi (Px1)
%
% if medav==0, linearly interpolate
% if medav is a tuple, it specifies the range (relative to each xi) over
%    which to compute the median
% absfill gives the maximum gap length to fill in y before interpolation
%
% note absfill is a number of points in x, while medav is in x units

if absfill > 0
    % fill any nans in z by interpolation
    for kfill = 1:size(y,2)
        ok = ~isnan(y(:,kfill));
        if sum(ok) < 2 ; continue; end % not enough good data to fill with interp1
        if sum(ok) == size(y,1); continue; end % all data are good; skip interp1
        % bak on jc159 28 March 2018; To handle the case of not
        % interpolating more than absfill values, construct a
        % mask to set back to NaN. absfill = 0 means interpolate max of
        % zero values, ie no interpolation. absfill NaNs will be filled;
        % absfill+1 NaNs will not be filled.
        zs = y(:,kfill);
        kmask = zeros(size(zs));
        kok = find(ok);
        gap = diff(kok); % gap size to next OK value
        kbiggap = find(gap > absfill+1); % when there are absfill values, which is acceptable to fill, the step between good values is absfill+1. Take action if this gap is exceeded.
        %kok(biggap) are the index in zs of the last good cycles before big
        %gaps
        for kl = 1:length(kbiggap)
            kmask((kok(kbiggap(kl))+1):(kok(kbiggap(kl))+gap(kbiggap(kl))-1)) = nan;
        end
        % fill them all, then mask out the ones that should not have been
        % filled.
        y(:,kfill) = interp1(x(ok),y(ok,kfill),x);
        y(:,kfill) = y(:,kfill)+kmask;
    end
end

if medav==0
    % bak on jc211, take care of non-finite values in x
    kok = find(isfinite(x));
    x = x(kok); y = y(kok,:);
    ym = interp1(x,y,xi);
else
    m = repmat(x(:),1,length(xi))-repmat(xi(:)',length(x),1);
    m = (m<medav(1) | m>medav(2));
    for k = 1:size(y,2)
        z = repmat(y(:,k),1,length(xi)); z(m) = NaN;
        ym(:,k) = nanmedian(z)';
    end
end