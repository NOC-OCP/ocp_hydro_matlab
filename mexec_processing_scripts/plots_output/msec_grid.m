function msec_grid(section)
% make gridded section(s) by calling maphsec; save to .mat file
%
% ylf jc238, based on msec_run_mgridp (calling mgridp)
%
% mapping grid defaults for commonly-used sections are given below, but
%   can be overwritten in opt_cruise (outputs, grid)
%
% specify section to map: either profile_only, or one of the sections with
%   stations listed in opt_{cruise} (outputs, grid)
%
% this replaces hydro_tools/gridhsec specifically for cruises processed
%   with mexec (when you are loading mstar-format files and have the
%   section-station list mapping coded into opt_cruise)

m_common
mcruise = MEXEC_G.MSCRIPT_CRUISE_STRING;

root_ctd = mgetdir('M_CTD');

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

%get section parameters
if strcmp(section,'profiles_only')
    mgrid.xlim = 0.01; %each station effectively independent
    mgrid.zpressgrid = zpressgrid_deep; %***
    kstns = 1:200;
else
    clear kstns
end
sam_gridlist = {'botoxy'};
opt1 = 'outputs'; opt2 = 'grid'; get_cropt     

if ~isfield(mgrid,'zpressgrid') || isempty(mgrid.zpressgrid) %find defaults by section
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
            mgrid.zpressgrid = zpressgrid_deep;
    end
else
    if size(mgrid.zpressgrid,2)>size(mgrid.zpressgrid,1)
        mgrid.zpressgrid = mgrid.zpressgrid';
    end
end

otfile = fullfile(root_ctd, ['grid_' mcruise '_' section '.mat']);
if ~exist(otfile,'file') || ~exist('ctd_regridlist','var')
    ctd_regridlist = {'temp' 'psal' 'oxygen'};
end
%load the ctd data
if isempty(ctd_regridlist)
    load(otfile,'cdata') %use version from previous run
else
    clear cdata
    cdata.statnum = kstns;
    pmin = 1;
    pmax = floor((mgrid.zpressgrid(end,1)*1.5-mgrid.zpressgrid(end-1)*.5)/2)*2-1;
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
            cdata.statnum(kstn:end) = [];
            for vno = 1:length(ctd_regridlist)
                cdata.(ctd_regridlist{vno})(:,kstn:end) = [];
            end
            break
        end
        if isfield(d,'latitude')
            cdata.lat(1,kstn) = m_nanmean(d.latitude);
            cdata.lon(1,kstn) = m_nanmean(d.longitude);
        else
            cdata.lat(1,kstn) = h.latitude;
            cdata.lon(1,kstn) = h.longitude;
        end
        [~,ii,iic] = intersect(d.press,cdata.press(:,1),'stable');
        for vno = 1:length(ctd_regridlist)
            cdata.(ctd_regridlist{vno})(iic,kstn) = d.(ctd_regridlist{vno})(ii);
        end
    end
    [~,~,ia] = intersect(ctd_regridlist,h.fldnam,'stable');
    cdata.vars = ctd_regridlist;
    cdata.unts = h.fldunt(ia);
    m = sum(isnan(cdata.temp),2)==size(cdata.temp,2);
    cdata.press(m) = [];
    for vno = 1:length(ctd_regridlist)
        cdata.(ctd_regridlist{vno})(m,:) = [];
    end
end
if ~isfield(mgrid,'xstatnumgrid') || isempty(mgrid.xstatnumgrid)
    mgrid.xstatnumgrid = cdata.statnum;
end

%load the bottle sample data
clear sdata
[d,h] = mload(fullfile(root_ctd,sprintf('sam_%s_all',mcruise)),'/');
mstn = ismember(d.statnum,kstns);
sdata.statnum = d.statnum(mstn);
sdata.position = d.position(mstn);
sdata.press = d.upress(mstn);
sdata.ctdtmp = d.utemp(mstn);
sdata.ctdsal = d.upsal(mstn);
sdata.ctdoxy = d.uoxygen(mstn);
mv = false(1,length(sam_gridlist));
for vno = 1:length(sam_gridlist)
    if isfield(d,sam_gridlist{vno})
        sdata.(sam_gridlist{vno}) = d.(sam_gridlist{vno})(mstn);
        mv(vno) = true;
    else
        warning('sample variable %s not found; skipping',sam_gridlist{vno})
    end
end
sdata.vars = sam_gridlist(mv);
[~,~,ia] = intersect(sam_gridlist(mv),h.fldnam,'stable');
sdata.unts = h.fldunt(ia);

if strcmp(section,'ungridded') %this is just a way to compile some or all of the stations into a .mat file
    save(otfile,'cdata','sdata')
else
    %run the gridding
    mgrid = maphsec(cdata, sdata, mgrid);

    %save
    readme = 'gridded using maphsec calling map_as_mstar';
    save(otfile, 'cdata', 'sdata', 'mgrid', 'readme');
end
