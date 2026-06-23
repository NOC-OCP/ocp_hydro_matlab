function pst2nc(pstfile,ncfile)

% pst2nc: copy contents of pstar file to netcdf file
% requires pload.m, plisth.m, punpack.m
%
% Use:
%  pst2nc(pstfile,ncfile)
%
% BAK at SOC 31 March 2005


if exist(pstfile,'file') ~= 2
    disp(['File ' pstfile ' does not exist. Stopping']);
    return
end

if exist(ncfile,'file') == 2
    disp(['File ' ncfile ' already exists. Stopping']);
    return  %do not allow overwriting for the time being
end

[d h] = pload(pstfile,'');

f = netcdf(ncfile,'clobber');

nrows = max(1,h.nrows);
ncols = h.norecs/nrows;
attnames = fieldnames(h);
nglobals = length(attnames);
varnames = fieldnames(d);
noflds = length(varnames);

%dimensions rows & cols
f('rows') = nrows;
f('cols') = ncols;

for k3 = 1:noflds
    vn = varnames{k3};
    eval(['data = d.' vn ';']);
    f{vn} = {'rows','cols'};
    f{vn}(1:nrows,1:ncols) = data;
    f{vn}.pstarname = char(h.fldnam(k3));
    f{vn}.units = char(h.fldunt(k3));
    f{vn}.min = h.alrlim(k3);
    f{vn}.max = h.uprlim(k3);
    fillval(ncvar(vn,f),h.absent(k3));
end

strskip = {'coment' 'fldnam' 'fldunt' 'alrlim' 'uprlim' 'absent'}; %we don't need these pstar header items in the global attributes
for k2 = 1:nglobals
    an = attnames{k2};
    if strmatch(an,strskip,'exact')
        continue
    else
        eval(['f.' an ' = h.' an ';'])
    end
end

for k1 = 1:size(h.coment,1)
    comname = ['coment' sprintf('%02d',k1)];
    eval(['f.' comname ' = h.coment(k1,:);']);
end

close(f)
return