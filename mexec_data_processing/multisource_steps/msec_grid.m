function msec_grid(section)
% compile CTD and Niskin sample data and make gridded section(s) by calling
%   maphsec; save to .mat file
%
% ylf jc238, based on msec_run_mgridp (calling mgridp)
%
% section is a string corresponding to one of the fields of kstns set in
%   opt_cruise (outputs, station_lists), or is 'quick' to compile the 10s
%   averaged CTD files only, or 'ungridded' to compile the 2 dbar
%   downcast CTD files only, for the stations in kstns.all
%
% this can be used instead of hydro_tools/gridhsec specifically for cruises
%   processed with mexec (when you are loading mstar-format files and have
%   the section-station list mapping coded into the opt_cruise file)
%
% mapping grid defaults for commonly-used sections are given below, but
%   can be overwritten in opt_cruise (outputs, grid)
%

m_common

clear mgrid
mgrid.method = 'msec_maptracer';
mgrid.sam_fill = '';
mgrid.ctd_fill = '';

%get section parameters
opt1 = 'outputs'; opt2 = 'station_lists'; run(MEXEC_G.opt_cruise)
if strcmp(section,'profiles_only')
    mgrid.xlim = 0.01; %each station effectively independent
    mgrid.zpressgrid = section_grid_params(' ');
    kstns = kstns.all;
elseif ismember(section,{'ungridded','quick'}) %compile all the 10 s files
    kstns = kstns.all;
    ms = true(size(kstns));
else
    opt1 = 'outputs'; opt2 = 'grid'; run(MEXEC_G.opt_cruise)
    clear kstns
end
sam_gridlist = {'botoxy'};
opt1 = 'outputs'; opt2 = 'grid'; run(MEXEC_G.opt_cruise)

if ~isfield(mgrid,'zpressgrid') || isempty(mgrid.zpressgrid) %find defaults by section
    mgrid.zpressgrid = section_grid_params(section);
else
    if size(mgrid.zpressgrid,2)>size(mgrid.zpressgrid,1)
        mgrid.zpressgrid = mgrid.zpressgrid';
    end
end

opt1 = 'pfiles'; run(MEXEC_G.opt_cruise)
if ~exist(otfile,'file') || ~exist('ctd_regridlist','var')
    ctd_regridlist = {'temp' 'psal' 'oxy'};
    if strcmp(section,'quick')
        ctd_regridlist = {'temp','psal','oxy','fluor','turbidity','transmissivity','par'};
    end
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
    cdata.lat = nan(1,length(kstns)); cdata.lon = cdata.lat;
    for kstn = 1:length(kstns)
        stn = kstns(kstn); opt1 = 'setup'; opt2 = 'm_stn_string'; run(MEXEC_G.opt_cruise)
        if strcmp(section,'quick')
            cfile = sprintf(pfiles.ctd_10s,stn_string);
        else
            cfile = sprintf(pfiles.ctd_2db_dn,stn_string);
        end
        if ~exist(m_add_nc(cfile),'file')
            if strcmp(section,'quick')
                ms(kstn) = false;
                continue
            else
                %if we get to a station we don't have, assume we haven't
                %done the rest of the list yet either
                cdata.statnum(kstn:end) = [];
                for vno = 1:length(ctd_regridlist)
                    cdata.(ctd_regridlist{vno})(:,kstn:end) = [];
                end
                break
            end
        end
        [d,h] = mloadq(cfile,'/');
        [~,~,ia] = intersect(ctd_regridlist,h.fldnam,'stable');
        cdata.vars = ctd_regridlist;
        cdata.unts = h.fldunt(ia);
        if isfield(d,'latitude') && ~isnan(m_nanmean(d.latitude))
            cdata.lat(1,kstn) = m_nanmean(d.latitude);
            cdata.lon(1,kstn) = m_nanmean(d.longitude);
        else
            cdata.lat(1,kstn) = h.latitude;
            cdata.lon(1,kstn) = h.longitude;
        end
        if strcmp(section,'quick')
            %using 10 s average time series, just cut and interpolate to
            %consistent 2 dbar grid
            [~,ii] = unique(d.press);
            for vno = 1:length(ctd_regridlist)
                cdata.(ctd_regridlist{vno})(:,kstn) = interp1(d.press(ii),d.(ctd_regridlist{vno})(ii),cdata.press(:,1));
            end
        else
            %already on same 2 dbar grid as output
            [~,ii,iic] = intersect(d.press,cdata.press(:,1),'stable');
            for vno = 1:length(ctd_regridlist)
                cdata.(ctd_regridlist{vno})(iic,kstn) = d.(ctd_regridlist{vno})(ii);
            end
        end
    end
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
if exist(pfiles.samp_ctd,'file')
    [d,h] = mload(pfiles.samp_ctd,'/');
    mstn = ismember(d.statnum,kstns);
    sdata.statnum = d.statnum(mstn);
    sdata.position = d.position(mstn);
    sdata.press = d.upress(mstn);
    sdata.ctdtmp = d.utemp(mstn);
    sdata.ctdsal = d.upsal(mstn);
    sdata.ctdoxy = d.uoxy(mstn);
    sdata.ctdfluo = d.ufluor(mstn);
    mv = false(1,length(sam_gridlist));
    for vno = 1:length(sam_gridlist)
        if isfield(d,sam_gridlist{vno})
            sdata.(sam_gridlist{vno}) = d.(sam_gridlist{vno})(mstn);
            fl = d.([sam_gridlist{vno} '_flag'])(mstn);
            if isfield(mgrid,'sdata_flag_accept')
                mbf = ~ismember(fl,mgrid.sdata_flag_accept);
                sdata.(sam_gridlist{vno})(mbf) = NaN;
            end
            mv(vno) = true;
        else
            warning('sample variable %s not found; skipping',sam_gridlist{vno})
        end
    end
    sdata.vars = sam_gridlist(mv);
    [~,~,ia] = intersect(sam_gridlist(mv),h.fldnam,'stable');
    sdata.unts = h.fldunt(ia);
end

if ismember(section,{'ungridded','quick'}) %this is just a way to compile some or all of the stations into a .mat file
    fn = fieldnames(cdata);
    for no = 1:length(fn)
        if size(cdata.(fn{no}),2) == length(ms)
            cdata.(fn{no}) = cdata.(fn{no})(:,ms);
        end
    end
    if exist('sdata','var')
        save(otfile,'cdata','sdata'); mfixperms(otfile);
    else
        save(otfile,'cdata'); mfixperms(otfile);
    end
elseif exist('sdata','var')
    %run the gridding
    mgrid = maphsec(cdata, sdata, mgrid);

    %save
    readme = 'gridded using maphsec calling map_as_mstar';
    save(otfile, 'cdata', 'sdata', 'mgrid', 'readme'); mfixperms(otfile);
else
    error('no sample data (%s) found, skipping gridding (try running with section ''ungridded'')',pfiles.samp_ctd)
end
