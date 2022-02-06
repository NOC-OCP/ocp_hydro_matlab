function sw_addpath(ld);

global MEXEC_G

MEXEC_G.exsw_paths = {};

for lno = 1:size(ld,1)
    
    mpath = fullfile(ld.predir{lno}, [ld.lib{lno} ld.verstr{lno}]);
    if exist(mpath,'dir')==7 %presume subdirectories will also be present
        
        disp('adding to path: ')
        disp(mpath)
        addpath(mpath, '-end')
        MEXEC_G.exsw_paths = [MEXEC_G.exsw_paths; mpath];

        %subdirectories
        s = ld.subdirs{lno};
        if ischar(s)
            disp(fullfile(mpath,s))
            addpath(fullfile(mpath,s), '-end')
        else
            for sno = 1:length(s)
                disp(fullfile(mpath,s{sno}))
                addpath(fullfile(mpath,s{sno}), '-end')
            end
        end
        
    else
        warning([mpath ' not found'])
    end
    
end
