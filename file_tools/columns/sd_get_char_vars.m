function dat = sd_get_char_vars(dat, opts, filename, mr, mc)
% function dat = sd_get_char_vars(dat, opts, filename, mr, mc);
%
% replace table columns with no valid numbers by reading in again as
%   strings

m = sum(isnan(table2array(dat)))==size(dat,1);
if sum(m)
    optss = setvartype(opts,'string');
    dats = readtable(filename, optss);
    dats = dats(:,mc);
    dats = dats(mr,:);
    m = m & sum(cellfun(@(x) ismissing(x),table2cell(dats)))<size(dats,1);
    iicc = find(m);
    fn = dat.Properties.VariableNames;
    for no = 1:length(iicc)
        dat.(fn{iicc(no)}) = dats.(fn{iicc(no)});
    end
end
