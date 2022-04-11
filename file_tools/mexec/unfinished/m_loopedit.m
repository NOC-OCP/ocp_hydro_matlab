function pe = m_loopeditp(p, ptol);
% function pe = m_loopeditp(p, ptol);
%
% edit out pressures that are not > previous max press - ptol
% 
% only suitable for downcast data
%
% once you've used this you can apply same NaNs to other fields
%
% see mctd_04

if size(p,1) == 1
    trp = 1;
    p = p';
else
    trp = 0;
end

np = length(p);
pm = zeros(1,np); %this will contain max pressure above (before) each point

%separate into chunks otherwise matrix is too big
nm = 30000; ns = floor(np/nm); nr = np-nm*ns;

m = repmat([1:nm]',1,nm)<repmat([1:nm],nm,1); %diagonal mask

%first chunk
pm(1:nr) = max(repmat(p(1:nr),1,nr).*m(1:nr,1:nr)); %max p at/before each level

%rest of them
for no = 1:ns
    ii = [nr+1:nr+nm]+(no-1)*nm;
    pm(ii) = max(repmat(p(ii),1,nm).*m); %max p in this chunk at/before each level
    pm(ii) = max(pm(ii), max(pm(1:ii(1)-1))); %and test against earlier chunks
end

ii = find(p'<=pm-ptol);
pe = p; pe(ii) = NaN;

if trp
    pe = pe';
end
