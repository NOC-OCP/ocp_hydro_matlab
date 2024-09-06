function [data, unfound] = var_renamer(data, varmap, varargin)
% [data, unfound] = var_renamer(data, varmap)
% [data, unfound] = var_renamer(data, varmap, keepold)
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
% if you want to copy an existing variable ("old" name) to multiple "new"
%   names, set optional third input argument to 1, e.g.
%   [data, unfound] = var_renamer(data, varmap, 1);

keepold = 0; 
if nargin>2
    keepold = varargin{1};
end

nvn = fieldnames(varmap);
if istable(data)
    fn = data.Properties.VariableNames;
    renamed = zeros(length(nvn),1);
elseif isstruct(data)
    fn = fieldnames(data);
end

for nvno = 1:length(nvn)
    newname = nvn{nvno};
    if isempty(intersect(fn, newname)) %don't have this one yet
        [~, ia, ib] = intersect(varmap.(newname), fn, 'stable');
        if ~isempty(ia)
            if isstruct(data)
                %rename here (copy to new name)
                data.(newname) = data.(fn{ib});
                fn = fieldnames(data);
            else
                %save to rename all later
                if ~renamed(ib) && ~keepold
                    fn{ib} = newname;
                    renamed(ia) = 1;
                else
                    %need to copy
                    data.(newname) = data.(fn{ib});
                    fn = [fn newname];
                end
            end
        end
    end
end

if istable(data)
    %rename all
    data.Properties.VariableNames = fn;
end

%which ones do we still not have?
unfound = setdiff(nvn,fn);

