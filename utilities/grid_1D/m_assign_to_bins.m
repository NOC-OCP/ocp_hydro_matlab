function [klo khi] = m_assign_to_bins(z,bins)
% function [klo khi] = m_assign_to_bins(z,bins)
%
% Find index boundaries of elements of z that lie in each bin
% Length of klo,khi is one less than length of bins
% The first element of klo,khi correspond to the first bin and are the
% the indices in the sorted z that satisfy bins(1) <= z < bins(2)
% 
% z should be sorted before calling the function. Otherwise the index
% boundaries don't make sense.
% 
% indices returned as nan if no data in that bin


if length(find(size(z) > 1)) > 1
    m1 = 'Input data array must only have one dimension greater than 1';
    m2 = ['Dimensions of input array are ' num2str(size(z))];
    m = sprintf('\n%s\n',m1,m2);
    error(m);
end

if ~issorted(z)
    m1 = 'Input data array must be monotonic. Yours are not !';
    m = sprintf('\n%s\n',m1);
    error(m)
end

if length(find(size(bins) > 1)) > 1
    m1 = 'Input bins array must only have one dimension greater than 1';
    m2 = ['Dimensions of input array are ' num2str(size(bins))];
    m = sprintf('\n%s\n',m1,m2);
    error(m);
end

if ~issorted(bins)
    m1 = 'Input bins array must be monotonic. Yours are not !';
    m = sprintf('\n%s\n',m1);
    error(m)
end

nz = length(z);
nbins = length(bins);

% find first bin that contains data
zmin = z(1);
kb1 = find(bins <= zmin);
if isempty(kb1); kb1 = 1; end
kblo = max(kb1); % index of left edge of bin that contains first z
% find last bin
zmax = z(end);
kb2 = find(bins > zmax);
if isempty(kb2); kb2 = nbins; end
kbhi = min(kb2)-1; % index of left edge of bin that contains last z
numusebins = kbhi-kblo+1;


klo = nan+zeros(1,nbins-1); % create empty arrays
khi = klo;

binoff = kblo-1;

kbstart = 1+binoff;
kbend = kbstart+1;
blo = bins(kbstart);
bhi = bins(kbstart+1);
% scan through all the z values lower than the first bin
k = 1;
while z(k) < blo
    k = k+1;
end

while kbstart <= numusebins+binoff
    kbend = kbstart+1;
    blo = bins(kbstart);
    bhi = bins(kbstart+1);
    
    if z(k) < bhi & isnan(klo(kbstart))
        klo(kbstart) = k;
    end

    while z(k) < bhi
        khi(kbstart) = k;
        k = k+1;
        if k > nz; break; end % reached the end of the z array, so don't look at any more z values
    end
    kbstart = kbstart+1;
    if k > nz; break; end % reached the end of the z array, so quit looking in more bins

end
return
