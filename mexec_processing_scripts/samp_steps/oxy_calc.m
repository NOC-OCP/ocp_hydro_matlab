%%% ds_oxy = oxy_calc(ds_oxy)
%
% labT is only used if bot_vol_tfix not supplied

function ds_oxy = oxy_calc(ds_oxy)

ds_oxy(isnan(ds_oxy.position),:) = [];

%check units
clear oxyunits
oxyunits.vol_blank = {'ml' 'mls'};
oxyunits.vol_std = {'ml' 'mls'};
oxyunits.vol_titre_std = {'ml' 'mls'};
oxyunits.bot_vol_tfix = {'ml' 'mls'};
oxyunits.sample_titre = {'ml' 'mls'};
oxyunits.fix_temp = {'c' 'degc' 'deg_c'};
oxyunits.conc_o2 = {'umol/l' 'umol_per_l' 'umols_per_l'};
if ~isempty(ds_oxy.Properties.VariableUnits)
    [ds_oxy, ~] = check_units(ds_oxy, oxyunits);
end

%fill in flags to be consistent
ds_oxy_fn = ds_oxy.Properties.VariableNames;
if sum(strcmp('sample_titre',ds_oxy_fn))
    dname = 'sample_titre';
else
    dname = 'conc_o2';
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

opt1 = 'samp_proc'; opt2 = 'oxy_calc'; get_cropt
ds_oxy = oxy_from_titre(ds_oxy,'vol_std',vol_std,'vol_reag_tot',vol_reag_tot);