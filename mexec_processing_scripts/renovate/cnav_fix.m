function ot = cnav_fix(in)

% function to fix problem with storage of data in cnav stream
% degrees and decimal minutes are stored with the minutes recorded as
% decimal degrees
% bak jc069 31 jan 2012 at montevideo


kneg = find(in < 0);
in(kneg) = -in(kneg);
indeg = floor(in);
inmin = 100*(in-indeg);
ot = indeg + inmin/60;
ot(kneg) = -ot(kneg);
return
