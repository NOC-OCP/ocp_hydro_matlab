function [data, vars_wrong_units] = check_units(data, units_expected, varargin)
% [data, vars_wrong_units] = check_units(data, units_expected)
% [data, vars_wrong_units] = check_units(data, units_expected, quiet_flag)
%

if nargin>2
    quiet_flag = varargin{1};
else
    quiet_flag = 0;
end

if istable(data)
    fn = data.Properties.VariableNames;
    un = data.Properties.VariableUnits;
elseif isstruct(data)
    if isfield(data,'vars') && isfield(data,'unts')
        fn = data.vars;
        un = data.unts;
    elseif isfield(data,'fldnam') && isfield(data,'fldunt')
        fn = data.fldnam;
        un = data.fldunt;
    end
end

if ~exist('fn','var')
    error('input data must be a table with both VariableNames and VariableUnits set, or a structure containing vars and unts or fldnam and fldunt')
end

uvars = fieldnames(units_expected);

vars_wrong_units = {};

for no = 1:length(uvars)
    iiv = find(strcmp(uvars{no},fn));
    if ~isempty(iiv)
        if isempty(un{iiv})
        warning('assigning default units for %s',uvars{no})
        un{iiv} = units_expected.(uvars{no});
    elseif ~sum(strcmp(un{iiv}, units_expected.(uvars{no})))
        if ~quiet_flag
            warning('unit corresponding to %s, %s, does not match expected:',uvars{no},un{iiv})
        end
        disp(units_expected.(uvars{no}))
        vars_wrong_units = [vars_wrong_units; uvars{no}];
        end
    end
end

data.Properties.VariableUnits = un;
