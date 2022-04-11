function cond = ctd_apply_celltm(time,temp,cond);

% dy040 bak 21 dec 2015
% code up celltm algorithm

alpha = 0.03; % sbe default values are alpha = 0.03; 1/beta = 7;
beta = 1/7;

num = numel(time);

ctm = zeros(size(cond));

kfirst = min(find(isfinite(time+temp)));

if isempty(kfirst)
    msg = ['No finite time+temp data found for celltm calculation in ' mfilename];
    fprintf(2,'%s\n',msg);
    cond = cond+nan;
    return
end

timelast = time(kfirst);
templast = temp(kfirst);
ctmlast = ctm(kfirst);

for kl = kfirst+1:num
    if ~isfinite(time(kl)+temp(kl))
        ctm(kl) = ctm(kl-1); % keep ctm fixed if not possible to update it due to missing temperature
        ctmlast = ctm(kl);
        continue
    end
    dtime = time(kl)-timelast;
    dtemp = temp(kl)-templast;
    
    a = 2 * alpha/(dtime*beta + 2);
    b = 1 - (2 * a/alpha);
    dcdt = 0.1*(1+0.006*(temp(kl)-20));
    ctm(kl) = -1 * b * ctmlast + a*dcdt*dtemp;
    timelast = time(kl);
    templast = temp(kl);
    ctmlast = ctm(kl);
end


ctm = 10 * ctm;

cond = cond+ctm;

return
