function mpath = sw_addpath(swroot, force_vers, addladcp)
%
% add some external software toolboxes used by ocp_hydro_matlab to path:
%   seawater, Gibbs seawater, neutral density, m_map, and (optionally)
%   LDEO_IX  
%
% defaults to finding the highest version available in swroot,
%   unless force_vers is a structure 
%     (e.g. force_vers.gsw_matlab = 'gsw_matlab_v3_06_16';),
%   in which case uses any hard-coded versions listed there
%   only adds LDEO_IX if addladcp is 1

ld = {'seawater', '', swroot;...
    'gsw_matlab', '', swroot;...
    'gamma_n', '', swroot;...
    'm_map', '', swroot;...
    'LDEO_IX', '', swroot};
if addladcp
    d = dir(fullfile(swroot,'LDEO_IX*'));
    if isempty(d)
        ld(end,3) = fullfile(swroot, 'ladcp');
    end
else
    ld(end,:) = [];
end
ld = cell2table(ld,'VariableNames',{'lib','vers','predir'});

if isstruct(force_vers)
    % replace empty vers with force_vers
    fn = fieldnames(force_vers);
    for no = 1:length(fn)
        m = strcmp(fn{no},ld.lib);
        ld.vers(m) = replace(force_vers.(fn{no}),ld.lib{no},'');
    end
end

% find highest version available for the rest
ld = sw_vers_parse(ld);

% add to path where not already on path
mpath = cellfun(@(x,y,z) fullfile(x,[y z]),...
    ld.predir, ld.lib, ld.vers,...
    'UniformOutput',false);
isnew = ~ismember(mpath,split(path,':'));
for lno = 1:length(mpath)
    if exist(mpath{lno},'dir')==7 %presume subdirectories will also be present     
        if isnew
            fprintf(1,'adding to path: %s\n',mpath{lno})
            addpath(genpath(mpath{lno}), '-end')
        end
    else
        warning([mpath{lno} ' not found'])
        mpath{lno} = '';
    end
end
mpath = setdiff(mpath,{''},'stable');


function lib_tab = sw_vers_parse(lib_tab)
% lib_tab = sw_vers_parse(lib_tab)
%
% find highest version of a library in a given directory
%
% verstr: Nx1 cell array
%
% lib_tab is a table with fields:
%     predir (where to look),
%     lib (library name),
%     vers (empty string to search)

notfound = [];

for lno = find(cellfun('isempty',lib_tab.vers))'
    
    %get list of matching directory names
    d = dir(fullfile(lib_tab.predir{lno}, [lib_tab.lib{lno} '*']));
    a = {d.name};
    a = a(cell2mat({d.isdir}));
        
    if isempty(a)
        notfound = [notfound; lno];
    else
        if isscalar(a)
            ind = 1;
        else
            %get version numbers
            b0 = replace(a,{[lib_tab.lib{lno} '_ver'];[lib_tab.lib{lno} '_v'];[lib_tab.lib{lno} '_'];lib_tab.lib{lno}},''); %remove initial part
            b = replace(replace(b0,'_',' '),'.',' '); %so we can compare numbers
            c = cellfun(@(x) str2num(x), b, 'UniformOutput', false); %a cell array of numeric vectors of different lengths
            l = cellfun(@(x) length(x), c);
            ii = find(l>0);
            if isempty(ii) %all contain letters, so do alphanumeric sort
                [~,ind] = sort(b); ind = ind(end);
            else %ignore any letters and sort by numbers
                if max(l)==1 %single level
                    [~,ii1] = max(cell2mat(c(ii)));
                    ind = ii(ii1);
                else %put levels into matrix to find highest version
                    d = zeros(max(l),length(c));
                    for n = 1:max(l)
                        d(n,ii) = cellfun(@(x) [x(n)], c(ii));
                        n = n+1;
                        ii = find(l>=n);
                    end
                    n = 1; ind = 1:length(c);
                    while n<=size(d,1) && length(ind)>1
                        ii = find(d(n,:)==max(d(n,:)));
                        ind = ind(ii); d = d(:,ii);
                        n = n+1;
                    end
                end
            end
        end
           
        %save string corresponding to highest version
        lib_tab.vers{lno} = replace(a{ind},lib_tab.lib{lno},'');
        
    end
    
end

lib_tab(notfound,:) = [];

