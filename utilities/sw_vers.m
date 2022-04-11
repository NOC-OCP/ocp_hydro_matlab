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
            if length(a)==1
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
