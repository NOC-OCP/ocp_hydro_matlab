function [sdata, varargout] = oxy_from_titre(sdata, varargin)
% sdata = oxy_from_titre(sdata);
% [sdata, tpar] = oxy_from_titre(sdata);
% sdata = oxy_from_titre(sdata, parameter, value);
%
% compute oxygen concentration conc_o2 (umol/L) from variables in table
%   sdata or supplied as optional parameter-value input pairs: 
%     vol_std (volume of iodate added for a standard, ml, default = 5),
%     titre_std (volume of titrant added for a standard, ml),
%     blank (result of a blank titre, ml),
%     titre_samp (volume of titrant added for the sample, ml   
%     vol_reag_tot (total volume of pickling reagents per sample, ml,
%       default = 2)
%     and either:
%       bot_vol_tfix (volume of flask at the pickling temperature, ml)
%     or: 
%       bot_cal_vol (volume of flask at bot_cal_temp, ml)
%       bot_cal_temp (temperature at which flasks were calibrated, degrees
%         C, may also be supplied as a parameter-value input pair)
%       fix_temp (pickling temperature, degrees C)
%
% molarity of the standard defaults to 
% default titration parameters but optionaltly these can be changed
%   using parameter-value input pairs, e.g.
%   oxy_from_titre(sdataa, 'vol_reag_tot', 1.98, 'vol_std', 10)
%
% outputs sdata with new variable conc_o2 (and optionally bot_vol_tfix)
% optionally outputs titration parameters tpar

% titration parameters
tpar.std_react_ratio = 6;       % # Na2S2O3/ KIO3 (mol/mol)
tpar.sample_react_ratio = 1./4; % # O2/Na2S2O3 (mol/mol)
tpar.molar_std = 1.667*1e-6; % molarity (mol/mL) of standard KIO3
tpar.molar_o2_reag = 0.5*7.6e-8; %mol/mL of dissolved oxygen in pickling reagents
% user may overwrite standard and reagent parameters, but warn
if nargin>1
    allowtp = {'vol_std','vol_reag_tot'};
    warntp = {'molar_std','molar_o2_reag'};
    for no = 1:2:length(varargin)
        if ismember(varargin{no}, allowtp)
            tpar.(varargin{no}) = varargin{no+1};
        elseif ismember(varargin{no}, warntp)
            warning('overwriting default for %s',varargin{no})
            tpar.(varargin{no}) = varargin{no+1};
        end
    end
end
tpar.n_std_std = tpar.molar_std*tpar.vol_std; %mol KIO3 added in standardisation
%output tpar?
if nargout>1
    varargout{1} = tpar;
end

if isempty(sdata)
    %just want titration parameters
    return
else
    ov = sdata.Properties.VariableNames;
    rv = {'std_titre','blank','sample_titre'};
    if ~isempty(setdiff(rv,ov))
        warning('required variables not in sdata, no calculation')
        return
    end
end

% check and standardise units
oxyunits.vol_blank = {'ml' 'mls'};
oxyunits.vol_std = {'ml' 'mls'};
oxyunits.vol_titre_std = {'ml' 'mls'};
oxyunits.bot_vol_tfix = {'ml' 'mls'};
oxyunits.sample_titre = {'ml' 'mls'};
oxyunits.fix_temp = {'c' 'degc' 'deg_c'};
oxyunits.botoxy = {'umol/l' 'umol_per_l' 'umols_per_l'};
if ~isempty(sdata.Properties.VariableUnits)
    [sdata, ~] = check_units(sdata, oxyunits, 'replace');
else
    warning('no units given for oxygen variables, assuming')
end

% if necessary, calculate bottle volumes at fixing temperatures
if ~sum(strcmp('bot_vol_tfix',ov))
    if nargin>1
        ii = find(strcmp('bot_cal_temp',varargin));
    else
        ii = [];
    end
    if isempty(ii)
        error('either bot_vol_tfix must be a variable in sdata, or bot_cal_temp must be passed in input arguments as a parameter-value pair')
    end
    bot_cal_temp = varargin{ii+1};
    bot_thermex = 1.0000975; % thermal expansion of sample bottles
    sdata.bot_vol_tfix = sdata.bot_cal_vol.*(sdata.fix_temp-bot_cal_temp)*bot_thermex;
end

% molarity (mol/mL) of titrant, determined by standardisation and blank
mol_titrant = tpar.std_react_ratio*tpar.n_std_std./(sdata.std_titre - sdata.blank); %mol Na2SO3 / mL
% moles of O2 in sample bottle
n_o2 = (sdata.sample_titre - sdata.blank).*mol_titrant*tpar.sample_react_ratio;
% moles of O2 that came from seawater
n_o2_sw = n_o2 - tpar.molar_o2_reag*tpar.vol_reag_tot;
% volume (mL) of seawater in sample bottle
vol_sw = sdata.bot_vol_tfix - tpar.vol_reag_tot;
% concentration of seawater O2 (1 mol/mL = 1e9 umol/L)
sdata.botoxy = 1e9*n_o2_sw./vol_sw;
m = strcmp('botoxy',sdata.Properties.VariableNames);
sdata.Properties.VariableUnits(m) = 'umol/L';