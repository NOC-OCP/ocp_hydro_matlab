function opts = spv_argparse(defs, inputs)
% opts = spv_argparse(defs, input_struct)
% opts = spv_argparse(defs, input_parameter_value_array)
%
% (optionally, first) assign parameter-value pair input arguments to a
% structure (then)
% fill in any unset defaults in inputs using defaults contained in
% structure defs

if ~isstruct(inputs)
    if ~iseven(length(inputs))
        error('inputs must be structure or cell array of parameter-value pairs')
    end
    inputs = cell2struct(inputs(2:2:end),inputs(1:2:end),2);
end

opts = inputs;
fn = fieldnames(defs);
for fno = 1:length(fn)
    if ~isfield(opts, fn{fno})
        opts.(fn{fno}) = defs.(fn{fno});
    end
end
