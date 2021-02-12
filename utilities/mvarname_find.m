function varname = mvarname_find(varname_choices, namelist);
% function varname = mvarname_find(varname_choices, namelist);
% find matches to varname_choices (cell array) in cell array namelist

cmatch = intersect(varname_choices,namelist);
if length(cmatch) == 1
    varname = char(cmatch);
else
    varname = [];
end
