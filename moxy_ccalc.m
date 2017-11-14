function ds_oxy = moxy_ccalc(ds_oxy);
% function ds_oxy = moxy_ccalc(ds_oxy);
% compute concentrations in umol/l from titre volumes and other parameters
% given in dataset ds_oxy and/or in opt_cruise
% 
% YLF jr15003 based on moxy_01_jr302 and jc145 modified to separate out moxy_01 and moxy_ccalc
%
% called by moxy_01 (if necessary)

scriptname = 'moxy_ccalc';
cruise = MEXEC_G.MSCRIPT_CRUISE_STRING;
oopt = '';

oopt = 'oxypars'; get_cropt
vol_reag_tot = vol_reag1+vol_reag2;
n_O2_reag = mol_O2_reag*vol_reag_tot; % mol of dissolved O2 in reag

oopt = 'blstd'; get_cropt

% calculate molarity (mol/mL) of titrant
mol_titrant = std_react_ratio*vol_std*mol_std/(vol_titre_std - vol_blank); 

%bottle volumes as database
oopt = 'botvols'; get_cropt
ds_bottle = dataset('File', fname_bottle, 'Delimiter', ',');
mb = max(ds_bottle.bot_num); a = NaN+zeros(mb, 1);
a(ds_bottle.bot_num) = ds_bottle.bot_vol;
obot_vol = a(ds_oxy.oxy_bot); %mL

%-------------------------------------------------------------------------%
% calculate moles of O2 in sample
%-------------------------------------------------------------------------%
n_O2 = (ds_oxy.oxy_titre - vol_blank)*mol_titrant*sample_react_ratio;


%-------------------------------------------------------------------------%
% calculate volume of sample, accounting for pickling reagent volumes.
% assuming 9.75e-5 is expansion/contraction coefficient of the flask(?)
%-------------------------------------------------------------------------%
coeff_expand = 1+9.75e-5*(ds_oxy.oxy_temp-cal_temp);
sample_vols = obot_vol.*coeff_expand - vol_reag_tot; %mL

%-------------------------------------------------------------------------%
% calculate concentration of O2 in sample, accounting for concentration of
% O2 in pickling reagents 
%-------------------------------------------------------------------------%
conc_O2 = (n_O2 - n_O2_reag)./sample_vols*1e6*1e3; %umol/L

prefix2 = ['oxy_' cruise '_'];
otfile2 = [root_oxy '/' prefix2 stn_string];
dataname = [prefix2 stn_string];


% fill in to 24 places
statnum = repmat(stnlocal, 24, 1);
position = [1:24]';
botoxya = NaN+zeros(24, 1); botoxytempa = botoxya; botoxyflaga = 9+botoxya; %flags default to no data
botoxyb = botoxya; botoxyflagb = 9+botoxya; botoxytempb = botoxya;
%first set of values
[c, ia, ib] = intersect(position, ds_oxy.niskin);
botoxya(ia) = conc_O2(ib); %umol/L
botoxytempa(ia) = ds_oxy.oxy_temp(ib);
botoxyflaga(ia) = 2;
%now find duplicates
ds_oxy.niskin(ib) = NaN; [c, ia, ib] = intersect(position, ds_oxy.niskin);
botoxyb(ia) = conc_O2(ib); %umol/L
botoxytempb(ia) = ds_oxy.oxy_temp(ib);
botoxyflagb(ia) = 2;

botoxyflaga(isnan(botoxya+botoxytempa)) = 9;
botoxyflagb(isnan(botoxyb+botoxytempb)) = 9;
oopt = 'flag'; get_cropt %set additional flags

ds_oxy.botoxytempa = botoxytempa; ds_oxy.botoxya = botoxya; ds_oxy.botoxyflaga = botoxyflaga;
ds_oxy.botoxytempb = botoxytempb; ds_oxy.botoxyb = botoxyb; ds_oxy.botoxyflagb = botoxyflagb;

