function varargout = check_units(data, units_expected)
% check_units(data, units_expected)
% vars_wrong_units = check_units(data, units_expected)
%
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
    if ~sum(strcmp(un{iiv}, units_expected.(uvars{no})))
        warning('unit corresponding to %s, %s, does not match expected:',uvars{no},un{iiv})
        disp(units_expected.(uvars{no}))
        vars_wrong_units = [vars_wrong_units; uvars{vno}];
    end
end

if nargout>0
    varargout{1} = vars_wrong_units;
end
