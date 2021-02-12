function ds_oxy = moxy_ccalc(ds_oxy, stn);
% function ds_oxy = moxy_ccalc(ds_oxy, stn);
% compute concentrations in umol/l from titre volumes and other parameters
% given in dataset ds_oxy and/or in opt_cruise
% 
% YLF jr15003 based on moxy_01_jr302 and jc145 modified to separate out moxy_01 and moxy_ccalc
%
% called by moxy_01 (if necessary)

m_common
stn = ds_oxy.statnum(1);
if length(unique(ds_oxy.statnum))>1
   error('moxy_ccalc is meant to operate on data from a single station')
end
minit; scriptname = mfilename;

ds_oxy_fn = ds_oxy.Properties.VarNames;

mol_std = 1.667*1e-6;   % molarity (mol/mL) of standard KIO3
std_react_ratio = 6;       % # Na2S2O3/ KIO3 (mol/mol)
sample_react_ratio = 1./4; % # O2/Na2S2O3 (mol/mol)
oopt = 'oxypars'; get_cropt
vol_reag_tot = vol_reag1+vol_reag2;
n_O2_reag = mol_O2_reag*vol_reag_tot; % mol of dissolved O2 in reag

oopt = 'blstd'; get_cropt

%-------------------------------------------------------------------------%
% calculate molarity (mol/mL) of titrant
%-------------------------------------------------------------------------%
mol_titrant = (std_react_ratio*vol_std.*mol_std)./(vol_titre_std - vol_blank); 


%bottle volumes
oopt = 'botvols'; get_cropt
if ~exist('obot_vol','var')
    obot_vol = ds_oxy.bot_vol;
end

%-------------------------------------------------------------------------%
% calculate moles of O2 in sample
%-------------------------------------------------------------------------%
n_O2 = (ds_oxy.oxy_titre - vol_blank).*mol_titrant*sample_react_ratio;

%-------------------------------------------------------------------------%
% calculate volume of sample, accounting for pickling reagent volumes.
% assuming 9.75e-5 is expansion/contraction coefficient of the flask(?)
%-------------------------------------------------------------------------%
coeff_expand = 1+9.75e-5*(ds_oxy.oxy_temp-cal_temp);
%coeff_expand = 1+10e-5*(ds_oxy.oxy_temp-cal_temp);
sample_vols = obot_vol.*coeff_expand - vol_reag_tot; %mL

%-------------------------------------------------------------------------%
% calculate concentration of O2 in sample, accounting for concentration of
% O2 in pickling reagents 
%-------------------------------------------------------------------------%
conc_O2 = (n_O2 - n_O2_reag)./sample_vols*1e6*1e3; %umol/L
conc_O2(ds_oxy.oxy_titre==-999 | isnan(ds_oxy.oxy_titre) | obot_vol==-999 | isnan(obot_vol)) = NaN;

if sum(strcmp('conc_O2', ds_oxy_fn))
   conc_O2_orig = ds_oxy.conc_O2;
   conc_O2_orig(ds_oxy.conc_O2==-999 | ds_oxy.oxy_titre==-999 | isnan(ds_oxy.oxy_titre)) = NaN;
elseif sum(strcmp('botoxy', ds_oxy_fn))
   conc_O2_orig = ds_oxy.botoxy;
   conc_O2_orig(ds_oxy.botoxy==-999) = NaN;
end
if exist('conc_O2_orig')
   oopt = 'compcalc'; get_cropt
   if compcalc; disp('compare loaded and calculated O2 concentrations');
   plot(conc_O2, conc_O2-conc_O2_orig, 'o'); title(stnlocal)
   keyboard
   end
   %conc_O2 = conc_O2_orig;
end

%flags
ii = find(strncmp('flag', ds_oxy_fn, 4));
if length(ii)>0
   flag = getfield(ds_oxy, ds_oxy_fn{ii});
else
   flag = 2+zeros(size(conc_O2));
end
flag(isnan(flag) & ~isnan(conc_O2)) = 2; flag(isnan(flag) & isnan(conc_O2)) = 5;
flag(isnan(obot_vol) | isnan(ds_oxy.oxy_temp)) = 9; %not meaningfully sampled if there's no volume listed***
ii = find(isnan(ds_oxy.oxy_titre) & ~isnan(obot_vol)); %sampled but not titrated
flag(ii) = min(5, flag(ii));
conc_O2(flag==5 | flag==9) = NaN;

%output
ds_oxy.conc_o2 = conc_O2; ds_oxy.flag = flag;
