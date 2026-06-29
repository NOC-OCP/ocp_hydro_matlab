function [data, unfound] = var_renamer(data, varmap, varargin)
% [data, unfound] = var_renamer(data, varmap)
% [data, unfound] = var_renamer(data, varmap, 'copyvar', copyvar, 'keep_othervars', keep_othervars)
%
% rename variables in table (or fields in structure) data
% using the mapping in structure varmap
%
% the fieldnames of varmap are the new variable names
%
% each field in varmap contains a cell array list of "old" names
%   corresponding to the "new" name given by the fieldname
%   varmap.speed_forward = {'fspeed_m_s','speed_fwd','spd_fwd_mps'};
% if the "new" name is already in data it will not be overwritten,
%   otherwise the first match from the "old" names will be renamed to the
%   "new" name 
%
% "new" names with no match in data are output in cell array unfound
% 
% optional parameter-value input arguments:
%   'copyvar', 0 (default) to rename the first "old" variable found to the
%     "new" name, or 
%   'copyvar', 1 to copy an "old" variable to potentially multiple "new"
%     names 
%   'keep_othervars', 1 (default) to keep un-renamed variables, or
%   'keep_othervars', 0 to (after renaming) remove any variables/fields
%     that are not fieldnames of varmap 

copyvar = 0; 
keep_othervars = 1;
if nargin>2
    for no = 1:2:length(varargin)
        eval([varargin{no} ' = varargin{no+1};']);
    end
end

nvn = fieldnames(varmap);
if isstruct(data)
    isstrc = true;
    data = struct2table(data);
else
    isstrc = false;
end
fn = data.Properties.VariableNames;

for nvno = 1:length(nvn)
    newname = nvn{nvno};
    if isempty(intersect(fn, newname)) %don't have this one yet
        [~, ~, ib] = intersect(varmap.(newname), fn, 'stable');
        if isempty(ib)
            warning('no variable for %s',newname)
            continue
        end
        ib = ib(1);
        if ~copyvar
            %change name in place
            data.Properties.VariableNames{ib} = newname;
        else
            %copy
            data.(newname) = data.(fn{ib});
        end
    end
end

if ~keep_othervars
    %remove fields/variables not in varmap
    m = ismember(data.Properties.VariableNames,nvn);
    data = data(:,m);
end

%which ones do we still not have?
unfound = setdiff(nvn,data.Properties.VariableNames);

%return same type as input
if isstrc
    data = table2struct(data,'ToScalar',true);
end

