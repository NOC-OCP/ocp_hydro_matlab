function mgrid = maphsec(cdata, sdata, mgrid)
% function mgrid = maphsec(cdata, sdata, mgrid);
%
% map hydrographic section data
%
% mgrid contains parameters
%
% for instance
%
% method
%   'msec_maptracer' (default) or 'om'
%   for msec_maptracer calls map_as_mstar
%       specify xlim [1] and zlim [4], distance in x and z coordinates (see below)
%       over which to average (gaussian-weighted by x and z distance and by potential density difference)
%   for om calls section_oi
%       specify xL [2], zL [4], sL [3] gaussian decorrelation length scales in x, z, and potential density sigma
%
% xstatnumgrid
%   row 1 is list of stations (should span cdata.statnum, but can be more
%       finely spaced) [default: cdata.statnum]
%   row 2 is list of mapping x coordinate corresponding to each [default: 1:length(cdata.statnum)]
%       the defaults produce a spatially-varying length scale reflecting how stations are usually closer
%       together over slopes where physical length scales are shorter. but if you want to use for instance
%       distance as horizontal mapping coordinate, put that in row 2 instead
% xlim or xL, see above
%
% zpressgrid
%   col 1 is list of pressures (should span cdata.press) [default: more closely spaced shallower, see code]
%   col 2 is list of mapping z coordinate corresponding to each [default: 1:length]
% zlim or zL, see above
%
% sL, see above
%
% by default, mapping is done using station index as x-coordinate, assuming
% that station spacing reflects expected decorrelation scales
% (e.g. stations are closer together over slopes)
%
% YLF, based on BAK's msec_run_mgridp.m



%%% set defaults, construct mapping coordinates mgrids, prepare data %%%

%method
if ~isfield(mgrid, 'method')
    mgrid.method = 'msec_maptracer';
end
if ~isfield(mgrid, 'background')
    mgrid.background = 'none';
end

%lengths
if sum(strcmp(mgrid.method, 'msec_maptracer'))
    if ~isfield(mgrid, 'xlim'); mgrid.xlim = 1; end
    if ~isfield(mgrid, 'zlim'); mgrid.zlim = 4; end
elseif sum(strcmp(mgrid.method, 'om')) && ~isfield(mgrid, 'xL')
    mgrid.xL = 2; mgrid.zL = 4; mgrid.xL = 3;
end

%station number and pressure coordinate mapping
if ~isfield(mgrid, 'xstatnumgrid')
    mgrid.xstatnumgrid = [cdata.statnum(:)'];
end
if size(mgrid.xstatnumgrid,1)==1
    mgrid.xstatnumgrid = [mgrid.xstatnumgrid; 1:length(cdata.statnum)];
    % or xstatnum mgrid can be some other mapping between station number 
    % and x coordinate, e.g. based on distance, or using a shifted station 
    % number to account for out of order or missing stations
end
if ~isfield(mgrid, 'zpressgrid')
    %pressure levels
    mgrid.zpressgrid = [0 5 25 50 75 100 175 250 375 500 ...
        625 750 875 1000 1250 1500 1750 2000 2250 2500 ...
        2750 3000 3250 3500 3750 4000 4250 4500 4750 ...
        5000 5250 5500 5750 6000]';
end
if size(mgrid.zpressgrid,2)==1
    mgrid.zpressgrid = [mgrid.zpressgrid [1:length(mgrid.zpressgrid)]'];
end

%and translate input coordinates
cdata.x = interp1(mgrid.xstatnumgrid(1,:),mgrid.xstatnumgrid(2,:),cdata.statnum);
sdata.x = interp1(mgrid.xstatnumgrid(1,:),mgrid.xstatnumgrid(2,:),sdata.statnum);
cdata.z = interp1(mgrid.zpressgrid(:,1),mgrid.zpressgrid(:,2),cdata.press);
sdata.z = interp1(mgrid.zpressgrid(:,1),mgrid.zpressgrid(:,2),sdata.press);
%remove the out-of-range ones with no mapping coordinates
cdata = remove_masked_rowcol(cdata);
m = isnan(sdata.x+sdata.z);
l = length(sdata.x);
fn = fieldnames(sdata);
for no = 1:length(fn)
    if length(sdata.(fn{no}))==l
        sdata.(fn{no})(m) = [];
    end
end
ncx = size(cdata.x,2); ncz = size(cdata.z,2);
nsx = size(sdata.x,2); nsz = size(sdata.z,2);


%output mgrid coordinates
if ~isfield(mgrid, 'x')
    mgrid.x = unique(cdata.x);
end
if ~isfield(mgrid, 'z')
    gstart = 10; gstep = 20;
    gstop = ceil(cdata.press(end)*1e3)/1e3;
    mgrid.z = interp1(mgrid.zpressgrid(:,1),mgrid.zpressgrid(:,2),[gstart:gstep:gstop]');
end
ngx = size(mgrid.x,2); ngz = size(mgrid.z,1);
if size(mgrid.x,1)==1
    mgrid.x = repmat(mgrid.x,ngz,1);
end
if size(mgrid.z,2)==1
    mgrid.z = repmat(mgrid.z,1,ngx);
end
mgrid.statnum = interp1(mgrid.xstatnumgrid(2,:),mgrid.xstatnumgrid(1,:),mgrid.x);
mgrid.press = interp1(mgrid.zpressgrid(:,2),mgrid.zpressgrid(:,1),mgrid.z);
mgrid.lon = interp1(cdata.statnum, cdata.lon, mgrid.statnum);
mgrid.lat = interp1(cdata.statnum, cdata.lat, mgrid.statnum);


%mask below bottom
mgrid.mask = ones(ngz,ngx);
for xno = 1:ngx
    iix = find(cdata.x==mgrid.x(1,xno));
    iib = find(~isnan(cdata.temp(:,iix)), 1, 'last' ); %last good point
    if ~isempty(iib)
        ii = find(mgrid.z(:,1)<=cdata.z(iib));
        mgrid.mask(ii,xno) = 0; %water points
    end
end

%%% map %%%
disp(['gridding/mapping data using ' mgrid.method])

switch mgrid.background
    %%%%% fill in gaps in cdata using wghc climatology (for now) %%%%%
    case 'wghc'
    load clim_flux/wghc_hydro/wghc_satl %***
    cdep = sw_depth(cdata.press, mean(cdata.lat));
    bg.temp = interp3(lon, dep, lat, hdata.temp, cdata.lon, cdep, cdata.lat); %***
    %psal, oxyg
    %***nearest-fill to surf? deep? nearest in vertical or interp3 after
    %converting lon, lat to distance? actually, do that above or not?
    keyboard
    
end

switch mgrid.method
    
    
    %%%%% same as in msec_run_mmgridp (which calls m_maptracer for sample data) %%%%%
    case 'msec_maptracer'
        mgrid = map_as_mstar(mgrid, cdata, sdata);
        if isfield(mgrid, 'sam_fill') && contains(mgrid.sam_fill, 'smooth')
            fac = 2; mgrid.sam_fill = [mgrid.sam_fill '_asymsig'];
            while fac<=10 && sum(mgrid.datam(:)>=0.8)>sum(mgrid.mask(:)==1)*size(mgrid.datam,3)
                mgrids = rmfield(mgrid,'datam');
                mgrids.xlim = fac*mgrid.xlim; mgrids.zlim = fac*mgrid.zlim;
                mgrids = map_as_mstar(mgrids, cdata, sdata);
                for vno = 1:length(mgrid.vars)
                    ii = find(mgrid.datam(:,:,vno)>=0.8 & mgrid.mask==0);
                    if ~isempty(ii)
                        v = mgrids.(mgrid.vars{vno}); 
                        v = gp_fillgaps(v, 0, 'first'); %replacement for fill_to_surf
                        mgrid.(mgrid.vars{vno})(ii) = v(ii);
                        mgrid.(mgrid.vars{vno})(mgrid.mask==1) = NaN;
                        m = mgrid.datam(:,:,vno); m(ii) = 0.5; m(mgrid.mask==1) = 1;
                        mgrid.datam(:,:,vno) = m;
                    end
                end
                fac = fac+2;
            end
            mgrid.maxfillfac = fac;
        end
        if isempty(which('gsw_SA_from_SP'))
            warning('not computing SA, CT, or dynamic height; add gsw to path?')
            isgsw = 0;
        else
            mgrid.SA = gsw_SA_from_SP(mgrid.psal, mgrid.press, mgrid.lon, mgrid.lat);
            mgrid.CT = gsw_CT_from_t(mgrid.SA, mgrid.temp, mgrid.press);
            isgsw = 1;
        end
        
        %%%%% objective map (2D gaussian weights) for cdata and sdata %%%%%
    case 'om'
        error('this option is not yet implemented')
        %gaussian decorrelation lengths
        mgrid = section_oi(mgrid, cdata, sdata);
        
end

for vno = 1:length(mgrid.vars)
    mgrid.(mgrid.vars{vno})(mgrid.mask==1) = NaN;
end

%%% compute variables from map %%%

%dynamic height relative to 2000 dbar (convenient for matching up to argo)
p_ref = 2000;
if isgsw
    mgrid.dh2000 = gsw_geo_strf_dyn_height(mgrid.SA,mgrid.CT,mgrid.press,p_ref);
end



function data = remove_masked_rowcol(data)

m = isnan(data.x);
if sum(m)
    data.x(m) = []; data.statnum(m) = [];
    for vno = 1:length(data.vars)
        data.(data.vars{vno})(:,m) = [];
    end
end

m = isnan(data.z);
if sum(m)
    data.z(m) = []; data.press(m) = [];
    for vno = 1:length(data.vars)
        data.(data.vars{vno})(m,:) = [];
    end
end


