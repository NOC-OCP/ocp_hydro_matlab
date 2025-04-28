function tabl = fill_samdata_statnum(tabl, varnames)
% function tabl = fill_samdata_statnum(tabl, varnames)
%
% fill in missing (NaN) values from columns/variables given by varnames
% (cell array of multiple variables or char array for single) in table (or
% dataset, or structure) tabl by looking for the last good value above each
% missing value
%
% e.g. if you have a file of bottle sample data where the station number
%   has only been filled in on the first line for each station:
%   CTDCastNo, NiskinBottleNo, No_Nuts_Samples
%           1,              1,               2
%            ,              2,               1
%            ,              3,               1
%           2,              1,               2
%            ,              2,               1,
%            ,              5,               1,
%            ,              7,               2,
%            ,              8,               1,
%           3,              2,               1,
%            ,              5,               1,
%   etc.,
% >> tabl = readtable(filename);
% >> tabl = fill_samdata_statnum(tabl, 'CTDCastNo');
%   will produce 
%     CTDCastNo    NiskinBottleNo    No_Nuts_Samples
%   ------------  ----------------  -----------------
%         1              1                 2
%         1              2                 1
%         1              3                 1
%         2              1                 2
%         2              2                 1
%         2              5                 1
%         2              7                 2
%         2              8                 1
%         3              2                 1
%         3              5                 1
%

%***could probably be replaced with fillmissing with method 'previous'

if ischar(varnames)
    varnames = {varnames};
end

for vno = 1:length(varnames)
    a = tabl.(varnames{vno});
    m = isnan(a);
    iim = find(m); iiv = find(~m);
    b = iiv'<iim;
    c = repmat(iiv',length(iim),1);
    d = c; d(~b) = NaN;
    f = max(d,[],2);
    iim = iim(~isnan(f)); f = f(~isnan(f));
    tabl.(varnames{vno})(iim) = a(f);
end
