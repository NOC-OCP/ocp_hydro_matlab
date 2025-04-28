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

%compute bottle volumes at fixing temperature if not present
if sum(strcmp('bot_vol_tfix',ds_oxy_fn))==0 && sum(strcmp('bot_vol',ds_oxy_fn))
    if sum(strcmp('bot_cal_temp',ds_oxy_fn))==0
        ds_oxy.bot_cal_temp = labT+zeros(size(ds_oxy.sampnum));
    end
    ds_oxy.bot_vol_tfix = ds_oxy.bot_vol.*(1+9.75e-5*(ds_oxy.fix_temp-ds_oxy.bot_cal_temp));
end

%compute concentration if not present
if sum(strcmp('conc_o2',ds_oxy_fn))==0
    mol_std = 1.667*1e-6;   % molarity (mol/mL) of standard KIO3
    std_react_ratio = 6;       % # Na2S2O3/ KIO3 (mol/mol)
    sample_react_ratio = 1./4; % # O2/Na2S2O3 (mol/mol)
    mol_o2_reag = 0.5*7.6e-8; %mol/mL of dissolved oxygen in pickling reagents
    n_o2_reag = mol_o2_reag*vol_reag_tot;
    % molarity (mol/mL) of titrant
    mol_titrant = (std_react_ratio*ds_oxy.vol_std*mol_std)./(ds_oxy.vol_titre_std - ds_oxy.vol_blank);
    % moles of O2 in sample
    ds_oxy.n_o2 = (ds_oxy.sample_titre - ds_oxy.vol_blank).*mol_titrant*sample_react_ratio;
    % volume of sample, accounting for pickling reagent volumes.
    sample_vols = ds_oxy.bot_vol_tfix - vol_reag_tot; %mL
    % concentration of O2 in sample, accounting for concentration in pickling reagents
    %a = 1.5*(ds_oxy.sample_titre-ds_oxy.vol_blank).*(ds_oxy.vol_std/1000).*(1.667e-4./(ds_oxy.vol_titre_std-ds_oxy.vol_blank));
    ds_oxy.conc_o2 = (ds_oxy.n_o2 - n_o2_reag)./sample_vols*1e6*1e3; %mol/mL to umol/L
end
