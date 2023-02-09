function table1 = sd_combine_tables(table1, table2)
% function table_out = sd_combine_tables(table1, table2);
%
% concatentate table2 onto end of table1,
%   matching variable names (and units, if applicable) and adding new
%   variables where no match is found. may also change type of variable if
%   necessary
%

s0 = size(table1);

ch0 = table1.Properties.VariableNames;
ch = table2.Properties.VariableNames;
un0 = table1.Properties.VariableUnits;
un = table2.Properties.VariableUnits;

%compare to existing
[~, iio, iin] = intersect(ch0, ch, 'stable');
if ~isempty(un)
    iinu = find(~strcmp(un0(iio), un(iin)));
    if ~isempty(iinu)
        %change names (append units of "new" variable to its name to distinguish from original)
        for cno = 1:length(iinu)
            ch{cno} = [ch{cno} '_' un{cno}];
        end
        %recalculate intersection
        [~, iio, iin] = intersect(ch0, ch, 'stable');
    end
end

%check if any variables were chars before but should now be numeric
iict = find(~sum(cellfun(@(x) isnumeric(x), table2cell(table1(:,iio)))) & sum(cellfun(@(x) isnumeric(x), table2cell(table2(:,iin)))));
if ~isempty(iict)
    iict = iio(iict(sum(cellfun('isempty', table2cell(table1(:,iio(iict)))))==size(table1,1)));
    for no = 1:length(iict)
        table1.(ch0{iict(no)}) = nan(size(table1,1),1);
    end
end
%add same-name variables
table1(s0(1)+[1:size(table2,1)],iio) = table2(:,iin);

%default pad is 0, fill with NaNs instead
iiof = setdiff(1:length(ch0), iio);
if ~isempty(iiof)
    table1{s0(1)+[1:size(table2,1)],iiof} = NaN;
end

%add any new ones
iinn = setdiff(1:length(ch), iin);
if ~isempty(iinn)
    for cno = iinn
        table1.(ch{cno}) = [nan(s0(1),1); table2.(ch{cno})];
        if ~isempty(un)
            table1.Properties.VariableUnits{end} = un{cno};
        end
    end
end
