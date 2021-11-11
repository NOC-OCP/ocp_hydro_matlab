function verstr = sw_vers(lib_tab, varargin)
% verstr = sw_vers(lib_tab)
% verstr = sw_vers(lib_tab, '-end')
% verstr = sw_vers(lib_tab, 'nochange')
%
% find highest version of a library in a given directory
% (unless 'nochange' is an input argument)
% and add to path
%
% verstr: Nx1 cell array
%
% lib_tab is a table with fields:
%     predir (where to look),
%     lib (library name),
%     exmfile (optional; if specified, search will only be performed if it
%         is not an m-file on the path already; if it is, verstr will be
%         empty string for this row)

nochange = 0;
position = '-begin';
for no = 1:length(varargin)
    if strcmp(varargin{no},'nochange')
        nochange = 1;
    else
        position = varargin{no};
    end
end
verstr = {};

for lno = 1:size(lib_tab,1)
    
    if ~sum(strcmp('exmfile',fieldnames(lib_tab))) || isempty(which(lib_tab.exmfile{lno}))
        
        if ~nochange %find highest version, update lib_tab.verstr
            
            %get list of matching directory names
            d = dir(fullfile(lib_tab.predir{lno}, [lib_tab.lib{lno} '*']));
            a = {d.name};
            a = a(cell2mat({d.isdir}));
            
            if length(a)==1 && strcmp(a{1},lib_tab.lib{lno})
                lib_tab.verstr{lno} = '';
                
            elseif ~isempty(a)
                %get version numbers
                b = replace(a,{[lib_tab.lib{lno} '_ver'];[lib_tab.lib{lno} '_v'];[lib_tab.lib{lno} '_'];lib_tab.lib{lno}},''); %remove initial part
                b = replace(b,'_','.'); %so we can compare numbers
                try
                    ver = cellfun(@str2num,b);
                    if iscell(ver)
                        ver = cell2mat(cellfun(@str2num,b));
                    end
                catch
                    ver = cellfun(@str2num,b,'UniformOutput',false);
                    disp('warning: ignoring possible libraries:')
                    disp(a{cellfun('isempty',ver)})
                    ver = cell2mat(ver);
                    if isempty(ver)
                        continue
                    end
                end
                %save string corresponding to highest version
                [~,ii] = max(ver);
                lib_tab.verstr{lno} = replace(a{ii},lib_tab.lib{lno},'');
                verstr{lno,1} = lib_tab.verstr{lno};
                disp(['adding ' a{ii}])
            end
            
        end
        
        % add to path
        mpath = fullfile(lib_tab.predir{lno}, [lib_tab.lib{lno} lib_tab.verstr{lno}]);
        if exist(mpath,'dir')==7 %presume subdirectories will also be present
            addpath(mpath, position)
            s = lib_tab.subdirs{lno};
            if ischar(s)
                addpath(fullfile(mpath,s), position)
            else
                for sno = 1:length(s)
                    addpath(fullfile(mpath,s{sno}), position)
                end
            end
        else
            warning([mpath ' not found'])
        end
    end
    
end
