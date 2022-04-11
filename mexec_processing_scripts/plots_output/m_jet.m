function out = m_jet(m,s,n)
%
% version of jet that repeats each color n times
%
% colours = m_jet(m,s,n)
%
% calls jet(m), but repeats each colour n times, to avoid too many
% colour changes with too little contrast
%
% s is an attempt at colour saturation. s = 1 is full jet colour
%
% bak on jr281 april 2013
%

if nargin == 1; s=1; n = 1; end
if nargin == 2;  n = 1; end

col1 = jet(m);
col2 = nan+ones(m*n,3);

for krep = 1:n
    col2(krep:n:end) = col1;
end

out = 1 - s * ( 1 - col2);
return