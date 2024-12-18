function sw_paths = sw_addpath(other_programs_root,varargin)
% sw_paths = sw_addpath(other_programs_root,'force_vers',force_vers)
% sw_paths = sw_addpath(other_programs_root,'addladcp',addladcp)
%
% add external software directories listed below (seawater toolbox, etc.)
% to path
% finds the highest version available in other_programs_root/ unless
% 'force_vers' is set to 1, in which case versions listed below will be
% used 
% if 'addladcp' is set to 0, LADCP code will not be included

force_vers = 0;
addladcp = 1;
for no = 1:2:length(varargin)
    eval([varargin{no} ' = varargin{no+1};']);
end

ld = table('Size', [1 4], 'VariableTypes', {'string' 'string' 'string' 'string'}, 'VariableNames', {'predir' 'lib' 'exmfile' 'verstr'});
n = 1;
ld(n,:) = {other_programs_root 'seawater', 'sw_dpth' '_ver3_2'}; n = n+1;
ld(n,:) = {other_programs_root 'm_map' 'm_gshhs_i' '_v1_4'}; n = n+1;
ld(n,:) = {other_programs_root 'gamma_n' 'gamma_n' '_v3_05_10'}; n = n+1;
%ld(n,:) = {other_programs_root 'eos80_legacy_gamma_n' 'eos80_legacy_gamma_n' ''}; n = n+1;
ld(n,:) = {other_programs_root 'gsw_matlab', 'gsw_SA_from_SP' '_v3_03'}; n = n+1;
if addladcp
    ld(n,:) = {other_programs_root 'LDEO_IX' 'loadrdi' '_13'}; n = n+1;
    ld(n,:) = {fullfile(other_programs_root, 'ladcp') 'LDEO_IX' 'loadrdi' '_13'}; n = n+1;
end
if ~force_vers
    ld = sw_vers(ld); %replace verstr with highest version of each library found in mstar_root
end

sw_paths = {};

for lno = 1:size(ld,1)
    
    mpath = fullfile(ld.predir{lno}, [ld.lib{lno} ld.verstr{lno}]);
    if isempty(ld.exmfile{lno}) || isempty(which(ld.exmfile{lno}))
        if exist(mpath,'dir')==7 %presume subdirectories will also be present     
            fprintf(1,'adding to path: %s\n',mpath)
            addpath(genpath(mpath), '-end')
            sw_paths = [sw_paths; mpath];
        else
            warning([mpath ' not found'])
        end
    end
    
end


function lib_tab = sw_vers(lib_tab)
% lib_tab = sw_vers(lib_tab)
%
% find highest version of a library in a given directory
%
% verstr: Nx1 cell array
%
% lib_tab is a table with fields:
%     predir (where to look),
%     lib (library name),
%     exmfile (optional; if specified, search will only be performed if it
%         is not an m-file on the path already; if it is, verstr will be
%         empty string for this row)

notfound = [];

for lno = 1:size(lib_tab,1)
    
    if ~sum(strcmp('exmfile',fieldnames(lib_tab))) || isempty(which(lib_tab.exmfile{lno}))
        
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
            lib_tab.verstr{lno} = replace(a{ind},lib_tab.lib{lno},'');
        end
        
    end
    
end

lib_tab(notfound,:) = [];

