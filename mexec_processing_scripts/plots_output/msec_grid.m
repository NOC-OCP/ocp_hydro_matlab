% make gridded section(s) by calling maphsec; save to .mat file
%
% ylf jc238, based on msec_run_mgridp (calling mgridp)
%
% mapping grid defaults for commonly-used sections are given below, but
% can be overwritten in opt_cruise
%
% one or more possible sections from this cruise, and the station list for
% each, are set in opt_cruise file.
% when calling msec_grid, specify variable sections as a cell array list or
% as 'all' to loop through all of the sections in opt_cruise file
%
% this replaces hydro_tools/gridhsec specifically for cruises processed
% with mexec (when you are loading mstar-format files and have the
% section-station list mapping coded into opt_cruise)

m_common
mcruise = MEXEC_G.MSCRIPT_CRUISE_STRING;

root_ctd = mgetdir('M_CTD');

%get section parameters
if ~exist('sections','var') || strcmp(sections, 'all') %if list exists, don't overwrite
    scriptname = mfilename; oopt = 'sections_to_grid'; get_cropt %get list of sections from this cruise
end

clear mgrid
mgrid.method = 'msec_maptracer';
mgrid.sam_fill = '';
mgrid.ctd_fill = '';

zpressgrid_deep = [0 5 25 50 75 100 175 250 375 500 ...
    625 750 875 1000 1250 1500 1750 2000 2250 2500 ...
    2750 3000 3250 3500 3750 4000 4250 4500 4750 ...
    5000 5250 5500 5750 6000 6250 6500]';
zpressgrid_shal = [0 5 25 50 75 100 125 150 175 200 225 250 ...
    275 300 350 400 450 500 550 600 650 700 800 900 1000 ...
    1100 1200 1300 1400 1500 1600 1700 1800 1900 2000]';

for ksec = 1:length(sections)
    section = sections{ksec};

    scriptname = mfilename; oopt = 'sec_stns_grids'; get_cropt %see if zpressgrid or xstatnumgrid are set differently
    
    if isempty(zpressgrid) %find defaults by section
        switch section
            case {'24n', 'fc'}
                mgrid.zpressgrid = zpressgrid_deep(zpressgrid_deep<=6500);
            case {'abas' 'falk' '24s'}
                mgrid.zpressgrid = zpressgrid_deep(zpressgrid_deep<=6000);
            case {'sr1b' 'sr1bb' 'orkney' 'a23' 'srp' 'nsra23'}
                mgrid.zpressgrid = zpressgrid_deep(zpressgrid_deep<=5000);
            case {'osnapwall' 'laball' 'arcall' 'osnapeall' 'lineball' 'linecall' 'eelall' 'nsr'}
                mgrid.zpressgrid = zpressgrid_deep(zpressgrid_deep<=4000);
            case {'bc' 'ben' 'bc2' 'bc3'}
                mgrid.zpressgrid = zpressgrid_deep(zpressgrid_deep<=3000);
            case {'fs27n' 'fs27n2'}
                mgrid.zpressgrid = zpressgrid_shal(zpressgrid_shal<=1000);
            case {'osnapwupper' 'labupper' 'arcupper' 'osnapeupper' 'linebupper' 'linecupper' 'eelupper' 'cumb'}
                mgrid.zpressgrid = zpressgrid_shal(zpressgrid_shal<=500);
            otherwise
                mgrid.zpressgrid = zpressgrid_deep(zpressgrid_deep<=4000);
        end
    else
        mgrid.zpressgrid = zpressgrid;
    end
    
    if isempty(xstatnumgrid)
        mgrid.xstatnumgrid = kstns;
    else
        mgrid.xstatnumgrid = xstatnumgrid;
    end

    otfile = fullfile(root_ctd, ['grid_' mcruise '_' section]);

    %load the ctd data
    scriptname = mfilename; oopt = 'ctd_regridlist'; get_cropt
    if isempty(ctd_regridlist)
        load(otfile,'cdata') %use version from previous run
    else
        clear cdata
        cdata.statnum = kstns;
        pmin = floor(mgrid.zpressgrid(1,1)/2)*2+1; 
        pmax = floor(mgrid.zpressgrid(end,1)/2)*2-1;
        cdata.press = [pmin:2:pmax]';
        ctd_regridlist = setdiff(ctd_regridlist,'press');
        for vno = 1:length(ctd_regridlist)
            cdata.(ctd_regridlist{vno}) = NaN+zeros(length(cdata.press),length(kstns));
        end
        for kstn = 1:length(kstns)
            cfile = fullfile(root_ctd,sprintf('ctd_%s_%03d_2db',mcruise,kstns(kstn)));
            if exist(m_add_nc(cfile),'file')
                [d,h] = mloadq(cfile,'/');
            else
                %if we get to a station we don't have, assume we haven't
                %done the rest of the list yet either
                break
            end
            cdata.lat(1,kstn) = d.latitude(1);
            cdata.lon(1,kstn) = d.longitude(1);
            [~,ii,iic] = intersect(d.press,cdata.press(:,1));
            for vno = 1:length(ctd_regridlist)
                cdata.(ctd_regridlist{vno})(iic,kstn) = d.(ctd_regridlist{vno})(ii);
            end
        end
        [~,ia,~] = intersect(h.fldnam,ctd_regridlist);
        cdata.vars = ctd_regridlist;
        cdata.unts = h.fldunt(ia);
    end

    %load the bottle sample data
    scriptname = mfilename; oopt = 'sam_gridlist'; get_cropt
    clear sdata
    [d,h] = mload(fullfile(root_ctd,sprintf('sam_%s_all',mcruise)),'/');
    mstn = ismember(d.statnum,kstns) & d.upress>=pmin & d.upress<=pmax;
    sdata.statnum = d.statnum(mstn);
    sdata.position = d.position(mstn);
    sdata.press = d.upress(mstn);
    for vno = 1:length(sam_gridlist)
        sdata.(sam_gridlist{vno}) = d.(sam_gridlist{vno})(mstn);
    end
    sdata.vars = sam_gridlist;
    [~,ia,~] = intersect(h.fldnam,sam_gridlist);
    sdata.unts = h.fldunt(ia);

    %and run the gridding
    mgrid = maphsec(cdata, sdata, mgrid);

    %save
    readme = 'gridded using maphsec calling map_as_mstar';
    save(otfile, cdata, sdata, mgrid, readme);

end