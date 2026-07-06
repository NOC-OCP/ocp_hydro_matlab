function mpath = addpath_library_version(libs, rootdirs, check_lmfirst)
%
% add external software toolboxes specified by table ld to path
%
% defaults to finding the highest version available in swroot,
%   unless force_vers is a structure 
%     (e.g. force_vers.gsw_matlab = 'gsw_matlab_v3_06_16';),
%   in which case uses any hard-coded versions listed there

check_lmfirst = 1;
libs.seawater = 'latest';
libs.gsw_matlab = 'latest';
libs.gamma_n = 'latest';
libs.m_map = 'latest';
libs.LDEO_IX = 'latest';
libs.m_moorproc_toolbox = 'latest';
if isstruct(rootdirs)
    rootdirs = orderfields(rootdirs,fieldnames(libs));
    libs = struct2table(libs);
    libs(2,:) = rootdirs(1,:);
else
    
if istable(rootdirs)
    [~,ia,ib] = intersect(libs.Properties.VariableNames,rootdirs.Properties.VariableNames);
    libs(2,ia) = 
if nargin>2
    check_lmfirst = varargin{1};
end

if check_lmfirst==1
    if isfield(libs,'LDEO_IX') && isfield(libs,'m_moorproc_toolbox')
        %these toolboxes are known to have functions with the same names,
        %so only add one at a time
        tc = input('in this session, processing LADCP (1), moored data (2), or neither (0)?   ');
        if tc==1
            libs = rmfield(libs,'m_moorproc_toolbox');
        elseif tc==2
            libs = rmfield(libs,'LDEO_IX');
        elseif tc==0
            libs = rmfield(libs,{'LDEO_IX','m_moorproc_toolbox'});
        end
    end
end


if isstruct(force_vers)
    % replace empty vers with force_vers
    fn = fieldnames(force_vers);
    for no = 1:length(fn)
        m = strcmp(fn{no},ld.lib);
        ld.vers(m) = replace(force_vers.(fn{no}),ld.lib{no},'');
    end
end

% find highest version available for the rest, based on directory names
ld = sw_vers_parse(ld);

% add to path where not already on path
mpath = cellfun(@(x,y,z) fullfile(x,[y z]),...
    ld.predir, ld.lib, ld.vers,...
    'UniformOutput',false);
isnew = ~ismember(mpath,split(path,':'));
for lno = 1:length(mpath)
    if exist(mpath{lno},'dir')==7 %presume subdirectories will also be present     
        if isnew(lno)
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

