function sw_addpath(ld);

global MEXEC_G

MEXEC_G.exsw_paths = {};

for lno = 1:size(ld,1)
    
    mpath = fullfile(ld.predir{lno}, [ld.lib{lno} ld.verstr{lno}]);
    if exist(mpath,'dir')==7 %presume subdirectories will also be present

        if isempty(ld.exmfile{lno}) || isempty(which(ld.exmfile{lno}))
            disp('adding to path: ')
            disp(mpath)
            addpath(genpath(mpath), '-end')
            MEXEC_G.exsw_paths = [MEXEC_G.exsw_paths; mpath];
        end
        
    else
        warning([mpath ' not found'])
    end
    
end
