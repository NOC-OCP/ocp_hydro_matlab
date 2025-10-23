function opts = spv_argparse(defs, inputs)
% opts = spv_argparse(defs, inputs)
%
% produce option structure opts, starting with defaults structure defs and
%   overwriting its fields (or adding new fields) from cell array inputs
% going in order through the elements of inputs: 
%   if element n is a structure, copy its fields to opts
%   if element n is a string, treat it and the following element as a
%     parameter-value pair, assigning opts.(inputs{n}) = inputs{n+1}; 
%
% all structures are scalar

opts = defs;
n = 1;
while n<=length(inputs)
    if isstruct(inputs{n})
        fn = fieldnames(inputs{n});
        for fno = 1:length(fn)
            opts.(fn{fno}) = inputs{n}.(fn{fno});
        end
        n = n+1;
    elseif ischar(inputs{n})
        opts.(inputs{n}) = inputs{n+1};
    else
        error('inputs can only contain structures or parameter-value pairs')
    end
end
