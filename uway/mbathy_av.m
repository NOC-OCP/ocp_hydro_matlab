%median average bathymetry, then add data from one file to another by
%interpolation for comparison and editing

iis = find(strcmp('sim', shortnames) | strncmp('ea6',shortnames,3));
iim = find(strncmp('em12', shortnames, 4));
iss = 0; ism = 0;

if length(iis)>0
    filesbin = [root_u '/' udirs{iis} '/' shortnames{iis} '_' mcruise '_d' daystr '_edt.nc'];
    filesbot = [root_u '/' udirs{iis} '/' shortnames{iis} '_' mcruise '_d' daystr '_edt_av.nc'];
    if exist(filesbin,'file')
        wkfile = 'wkfile_bathyav1.nc';
        MEXEC_A.MARGS_IN = {filesbin; wkfile; '/'; 'time'; '-150,1e10,300'; '/'};
        mavmed
        unix(['/bin/mv ' wkfile ' ' filesbot]);
        iss = 1;
    end
end

if length(iim)>0
    filembin = [root_u '/' udirs{iim} '/' shortnames{iim} '_' mcruise '_d' daystr '_edt.nc'];
    filembot = [root_u '/' udirs{iim} '/' shortnames{iim} '_' mcruise '_d' daystr '_edt_av.nc'];
    if exist(filembin,'file')
        wkfile = 'wkfile_bathyav2.nc';
        MEXEC_A.MARGS_IN = {filembin; wkfile; '/'; 'time'; '-150,1e10,300'; '/'};
        mavmed
        unix(['/bin/mv ' wkfile ' ' filembot]);
        ism = 1;
    end
end

docstr = ['5-minute median average bathymetry streams'];
if iss | ism
    mdocshow(mfilename, docstr);
end
