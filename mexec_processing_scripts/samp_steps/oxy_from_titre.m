function [odat, varargout] = oxy_from_titre(odat, varargin)
% odat = oxy_from_titre(odat);
% [odat, tpar] = oxy_from_titre(odat);
% odat = oxy_from_titre(odat, parameter, value);
%
% compute oxygen concentration conc_o2 (umol/L) from variables vol_std,
%   titre_std, titre_blank, titre_samp, and bot_vol_tfix (all in mL) of
%   table odat, optionally after first computing bot_vol_tfix from
%   variables bot_cal_vol and fix_temp (with bot_cal_temp supplied as a
%   parameter-value input pair)
%
% uses default titration parameters but optionally these can be changed
%   using parameter-value input pairs, e.g.
%   oxy_from_titre(odata, 'vol_reag_tot', 1.98, 'vol_std', 10)
%
% outputs odat with new variable conc_o2 (and optionally bot_vol_tfix)
% optionally outputs titration parameters tpar

% titration parameters
tpar.std_react_ratio = 6;       % # Na2S2O3/ KIO3 (mol/mol)
tpar.sample_react_ratio = 1./4; % # O2/Na2S2O3 (mol/mol)
tpar.molar_std = 1.667*1e6; % molarity (mol/mL) of standard KIO3
tpar.molar_o2_reag = 0.5*7.6e-8; %mol/mL of dissolved oxygen in pickling reagents
tpar.vol_reag_tot = 2; %total volume of reagents (mL) added before closing bottle
tpar.vol_std = 5; %volume of standard added in standardisation
% user may overwrite some of them
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

if isempty(odat)
    %just want titration parameters
    return
else
    ov = odat.Properties.VariableNames;
    rv = {'titre_std','titre_blank','titre_samp'};
    if ~isempty(setdiff(rv,ov))
        warning('required variables not in od, no calculation')
        return
    end
end

% if necessary, calculate bottle volumes at fixing temperatures
if ~sum(strcmp('bot_vol_tfix',ov))
    if nargin>1
        ii = find(strcmp('bot_cal_temp',varargin));
    else
        ii = [];
    end
    if isempty(ii)
        error('either bot_vol_tfix must be a variable in odata, or bot_cal_temp must be passed in input arguments as a parameter-value pair')
    end
    bot_cal_temp = varargin{ii+1};
    bot_thermex = 1.0000975; % thermal expansion of sample bottles
    odat.bot_vol_tfix = odat.bot_cal_vol.*(odat.fix_temp-bot_cal_temp)*bot_thermex;
end

% molarity (mol/mL) of titrant, determined by standardisation and blank
mol_titrant = tpar.std_react_ratio*tpar.n_std_std./(odat.std_titre - odat.blank_titre); %mol Na2SO3 / mL
% moles of O2 in sample bottle
n_o2 = (odat.sample_titre - odat.blank_titre).*mol_titrant*tpar.sample_react_ratio;
% moles of O2 that came from seawater
n_o2_sw = n_o2 - tpar.molar_o2_reag*tpar.vol_reag_tot;
% volume (mL) of seawater in sample bottle
vol_sw = odat.bot_vol_tfix - tpar.vol_reag_tot;
% concentration of seawater O2 (1 mol/mL = 1e9 umol/L)
odat.conc_o2 = 1e9*n_o2_sw./vol_sw;
