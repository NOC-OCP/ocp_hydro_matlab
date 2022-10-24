%called by m_setup: look for base directory for this cruise: first look in
%path of current directory, then in home directory

d = pwd;
cd('~'); hd = pwd; cd(d);
ii = strfind(d, MEXEC_G.MSCRIPT_CRUISE_STRING);
if ~isempty(ii)
    d = d(1:ii-1);
    mpath = {fullfile(d,MEXEC_G.MSCRIPT_CRUISE_STRING,'mcruise','data');
        fullfile(d,MEXEC_G.MSCRIPT_CRUISE_STRING,'data')
        fullfile(d,MEXEC_G.MSCRIPT_CRUISE_STRING)};
else
    mpath = {};
end
mpath = [mpath;
    fullfile(hd,MEXEC_G.MSCRIPT_CRUISE_STRING,'mcruise','data');
    fullfile(hd,MEXEC_G.MSCRIPT_CRUISE_STRING,'data')
    fullfile(hd,MEXEC_G.MSCRIPT_CRUISE_STRING)
    fullfile(hd,'cruises',MEXEC_G.MSCRIPT_CRUISE_STRING,'mcruise','data')];
fp = 0; n=1;
while fp==0 && n<=length(mpath)
    if exist(mpath{n},'dir')==7
        MEXEC_G.mexec_data_root = mpath{n};
        fp = 1;
    end
    n=n+1;
end
if fp==0 %none found; query
    disp('enter full path of cruise data processing directory')
    disp('e.g. /local/users/pstar/jc238/mcruise/data')
    MEXEC_G.mexec_data_root = input('  ', 's');
    disp('if you want, you can modify m_setup.m to hard-code this directory into MEXEC_G.mexec_data_root')
else
    disp(['MEXEC data root: ' MEXEC_G.mexec_data_root])
end
clear mpath d fp n ii
