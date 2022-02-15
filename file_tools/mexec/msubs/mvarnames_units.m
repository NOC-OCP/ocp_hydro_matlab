%convert cell array lists of variables (varnames) and units (varunits) 
%to format expected by msave (varnames_units)
%
%for any varnames that aren't in workspace, also extract from structure ds 
%(if it is found, otherwise warn)

varnames_units = {};
for k = 1:length(varnames)
    varnames_units = [varnames_units; varnames(k); {'/'}; varunits(k)];
    if (exist('force_set_var','var') & force_set_var) | ~exist(varnames{k}, 'var') 
        if exist('ds', 'var') & isstruct(ds) & isfield(ds, varnames{k})
            eval([varnames{k} ' = getfield(ds, ''' varnames{k} ''');']);
        else
            warning([varnames{k} ' in varnames_units but not available for msave?'])
        end
    end
end
