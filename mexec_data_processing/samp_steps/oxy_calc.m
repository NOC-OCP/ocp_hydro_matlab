% ds_oxy = oxy_calc(ds_oxy)
%
% compute bottle oxygen concentration botoxy (umol/l) from sample_titre
% and other winkler parameters (***)
% labT is only used if bot_vol_tfix not supplied
%
% ds_oxy is a table

function ds_oxy = oxy_calc(ds_oxy)

ds_oxy(isnan(ds_oxy.sampnum),:) = [];

%check units
clear oxyunits

%fill in flags to be consistent
ds_oxy_fn = ds_oxy.Properties.VariableNames;
if sum(strcmp('sample_titre',ds_oxy_fn))
    dname = 'sample_titre';
else
    dname = 'botoxy';
end
ds_oxy.flag(ds_oxy.flag<=0) = NaN;
bd = isnan(ds_oxy.(dname));
bt = isnan(ds_oxy.fix_temp);
%both oxy and temp, no flag: 2
ds_oxy.flag(~bd & ~bt & isnan(ds_oxy.flag)) = 2;
%both oxy and temp, flag 5 or 9: NaN oxy
ds_oxy.(dname)(~bd & ~bt & ismember(ds_oxy.flag, [5 9])) = NaN;
%temp but no oxy: 5 or 9
ds_oxy.flag(bd & ~bt & ds_oxy.flag<9) = 5;
%oxy but no temp: 5 and NaN oxy (no good without temp)
if sum(~bd & bt)>0; warning('oxy values without fix_temp will be discarded'); end
ds_oxy.flag(~bd & bt) = 5;
ds_oxy.(dname)(~bd & bt) = NaN;
%neither oxy nor temp: 9
ds_oxy.flag(bd & bt) = 9;

samtyp = 'oxy'; opt1 = 'samp_proc'; opt2 = 'calc'; run(MEXEC_G.opt_cruise)
ds_oxy = oxy_from_titre(ds_oxy);

