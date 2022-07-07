%median average bathymetry

[~,iis,~] = intersect(shortnames,{'sim' 'ea600' 'ea640' 'singleb'});
[~,iim,~] = intersect(shortnames,{'em120' 'em122' 'multib'});
iss = 0; ism = 0;

if ~isempty(iis)
    filesbin = fullfile(root_u, udirs{iis}, [shortnames{iis} '_' mcruise '_d' daystr '_edt.nc']);
    filesbot = fullfile(root_u, udirs{iis}, [shortnames{iis} '_' mcruise '_d' daystr '_edt_av.nc']);
    if exist(filesbin,'file')
        wkfile = 'wkfile_bathyav1.nc';
        MEXEC_A.MARGS_IN = {filesbin; wkfile; '/'; 'time'; '-150,1e10,300'; '/'};
        mavmed
        movefile(wkfile, filesbot);
        iss = 1;
    end
end

if ~isempty(iim)
    filembin = fullfile(root_u, udirs{iim}, [shortnames{iim} '_' mcruise '_d' daystr '_edt.nc']);
    filembot = fullfile(root_u, udirs{iim}, [shortnames{iim} '_' mcruise '_d' daystr '_edt_av.nc']);
    if exist(filembin,'file')
        wkfile = 'wkfile_bathyav2.nc';
        MEXEC_A.MARGS_IN = {filembin; wkfile; '/'; 'time'; '-150,1e10,300'; '/'};
        mavmed
        movefile(wkfile, filembot);
        ism = 1;
    end
end

if (iss || ism) && MEXEC_G.quiet<=1; fprintf(1,'5-minute median averaging bathymetry streams'); end
