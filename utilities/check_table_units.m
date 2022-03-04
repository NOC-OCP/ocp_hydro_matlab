function check_table_units(data, units_expected)

fn = data.Properties.VariableNames;
un = data.Properties.VariableUnits;
uvars = fieldnames(units_expected);

for no = 1:length(uvars)
    iiv = find(strcmp(uvars{no},fn));
    if ~sum(strcmp(un{iiv}, units_expected.(uvars{no})))
        warning('unit corresponding to %s, %s, does not match expected:',uvars{no},un{iiv})
        disp(units_expected.(uvars{no}))
    end
end
