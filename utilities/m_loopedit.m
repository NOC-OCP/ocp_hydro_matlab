function pe = m_loopedit(p, varargin);
% function pe = m_loopedit(p, 'ptol', ptol, 'spdtol', spdtol)
%
% edit out periods where the CTD package reverses
% by more than ptol (default 0.08 dbar)
% or speed goes below spdtol (default 0.1 dbar/time step, or 0.24 m/s for
% 24 hz data)
%
% only suitable for downcast data
%
% once you've used this you can apply same NaNs to other fields
%
% see mctd_04

ptol = 0.08;
spdtol = 0.24;
for no = 1:2:length(varargin)
    eval([varargin{no} ' = varargin{no+1};'])
end
if ~isfinite(ptol) && ~isfinite(spdtol)
    error('at least one of ptol or spdtol must have a value')
end

if p(end)<p(1)
    error('only suitable for downcast data')
end

%make column vector
if size(p,1) == 1
    trp = 1;
    p = p';
else
    trp = 0;
end

if ~isempty(ptol) && ~isnan(ptol)
    %calculate max pressure above (before) each point
    %in chunks, otherwise matrix is too big
    np = length(p);
    pm = zeros(1,np); %this will contain max pressure above (before) each point
    %separate into chunks otherwise matrix is too big
    nm = 5000; ns = floor(np/nm); nr = np-nm*ns;
    %first chunk
    pm(1:nr) = max(triu(repmat(p(1:nr),1,nr),1)); %max p before each level
    %rest of them
    ii = nr+[1:nm];
    while(ii(end)<np)
        pm(ii) = max(triu(repmat(p(ii),1,nm),1)); %max p in this chunk at/before each level
        pm(ii) = max(pm(ii), max(pm(1:ii(1)-1))); %and test against earlier chunks
        ii = ii + nm;
    end
    flagp = (p<=pm'-ptol);
else
    flagp = zeros(size(p));
end

if ~isempty(spdtol) && ~isnan(spdtol)
    %speed to this point
    spd = [NaN; diff(p)];
    flags = (spd<spdtol);
else
    flags = zeros(size(p));
end

pe = p;
pe(flags | flagp) = NaN;

%same orientation as p originally
if trp
    pe = pe';
end
