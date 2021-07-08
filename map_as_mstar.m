function mgrid = map_as_mstar(mgrid, cdata, sdata);
% function mgrid = map_as_mstar(mgrid, cdata, sdata);
%
% linearly interpolate CTD data, contained in structure cdata,
% from cdata.z onto mgrid.z
% cdata must contain at least the following fields:
%     z
%     press
%     temp
%     psal
%     vars, a cell array listing the variables to be mapped
%     (e.g. {'temp' 'psal'}
% in addition to CTD data, cdata must contain a field 'vars', a cell array
% listing the variables to be mapped (e.g. {'temp' 'psal'})
%
% sdata contains the corresponding fields, plus other quantities to be
%     mapped (also listed in sdata.vars)
%
% input mgrid contains x, z grid
%
% called by maphsec
%
% YLF
% based on BAK's scripts/functions for gridding CTD data (mgridp.m)
% and bottle sample data (m_maptracer.m)
%

ngz = size(mgrid.z,1); ngx = size(mgrid.x,2);
ns = length(sdata.x);
nvars = length(sdata.vars);

mgrid.vars = {}; mgrid.unts = {};

%ctd data: weighted average (using midpoint of linear fit), then
%interpolate in x to fill in missing profiles
for vno = 1:length(cdata.vars)
    data = smss(cdata.z, cdata.(cdata.vars{vno}), mgrid.z(:,1), 'smethod', 'lfitmid', 'init_extrap', 'surf', 'bin_extrap', 1);
    data(mgrid.mask==1) = NaN;
    m = double(isnan(data)); %might be NaNs in input ctdoxy; fill later
    %fill in missing profiles
    iimp = find(sum(~isnan(data))==0); 
    iimp = iimp(iimp>1 & iimp<size(data,2)); 
    if length(iimp)>0 %***stopgap!!! not a good thing to do for more than one profile in a row
        iigp = find(sum(~isnan(data))>0);
        data(:,iimp) = interp1(iigp, data(:,iigp)', iimp)';
        data(mgrid.mask==1) = NaN;
        m(m==1 & ~isnan(data)) = 0.5;
    end
    %%and repeat with nearest-neighbour
    %iimp = find(sum(~isnan(data))==0); 
    %if length(iimp)>0 %***stopgap!!! not a good thing to do for more than one profile in a row
    %    iigp = find(sum(~isnan(data))>0);
    %    data(:,iimp) = interp1(iigp, data(:,iigp)', iimp, 'nearest', 'extrap')';
    %    data(mgrid.mask==1) = NaN;
    %    m(m==1 & ~isnan(data)) = 0.5;
    %end
    mgrid.(cdata.vars{vno}) = data;
    mgrid.datam(:,:,vno) = m;
    mgrid.vars = [mgrid.vars cdata.vars{vno}];
    mgrid.unts = [mgrid.unts cdata.unts{vno}];
end

%sample data: average over close-enough points, weighted by gaussian in "distance" and by potential density

%use ctd values for sdata psal and temp (for density)
if isfield(sdata, 'psal'); psal0 = sdata.psal; end
if isfield(sdata, 'ctdsal')
   sdata.psal = sdata.ctdsal;
else
   sdata.psal = interp2(cdata.x, cdata.z, cdata.psal, sdata.x, sdata.z);
end
if exist('psal0','var'); sdata.psal(isnan(sdata.psal)) = psal0(isnan(sdata.psal)); end
if isfield(sdata, 'temp'); temp0 = sdata.temp; end
if isfield(sdata, 'ctdtmp')
   sdata.temp = sdata.ctdtmp;
else
   sdata.temp = interp2(cdata.x, cdata.z, cdata.temp, sdata.x, sdata.z);
end
if exist('temp0','var'); sdata.temp(isnan(sdata.temp)) = temp0(isnan(sdata.temp)); end

datag = NaN+zeros(ngz, ngx, nvars);
datam = ones(ngz, ngx, nvars);

%get mask for which grid points to map from which sample data
dx = repmat(sdata.x,1,ngx*ngz) - repmat(mgrid.x(:)',ns,1);
dz = repmat(sdata.z,1,ngx*ngz) - repmat(mgrid.z(:)',ns,1);
%not below bottom, and near enough in space, and have good TS
mr = (repmat(mgrid.mask(:)',ns,1)==0 & abs(dx)<=mgrid.xlim & abs(dz)<=mgrid.zlim & repmat(isfinite(sdata.temp+sdata.psal),1,ngx*ngz));

iig = find(sum(mr)>0); %grids with any good data
for gno = iig
    
    [zno, xno] = ind2sub([ngz ngx], gno);
    iis = find(mr(:,gno));
    
    %sigma of (nearby) sample data relative to this pressure
    sig = sw_pden(sdata.psal(iis), sdata.temp(iis), sdata.press(iis), mgrid.press(zno));
    if sum(~isfinite(sig))>0
        disp('bad points should already have been masked out')
        keyboard
    end
    
    %sigma of mgridded ctd data at this point
    sigref = sw_pden(mgrid.psal(gno), mgrid.temp(gno), mgrid.press(zno), mgrid.press(zno));
    
    %weights for fit
    s = sig-sigref;
    V = [ones(length(s),1) s s.^2];
    w = exp(-sqrt(dx(iis,gno).^2+dz(iis,gno).^2));
    Vw = repmat(w,1,size(V,2)).*V;
    
    %for each variable, fit and, if densities appropriate, average sample values
    for vno = 1:nvars
        data = sdata.(sdata.vars{vno});
        iisg = find(isfinite(data(iis)));
        if length(iisg)>3 %with few points it seems to maybe bias towards zero? not sure exactly what is happening actually. maybe zlim needs to be smaller relative to xlim? 
            yw = w(iisg).*data(iis(iisg));
            [Q,R] = qr(Vw(iisg,:),0); %V = QR, Q = Vinv(R)
            poly = R\(Q'*yw); % = inv(R)(Q'y)
            sw = s(iisg); 
            sw(w(iisg)==0) = []; %this will never be the case, right?***
            if min(sw)*max(sw) < 0 %grid point density bracketed by input point densities with non-zero weight
                datam(zno, xno, vno) = 0; %good point, set masking to zero (no mask)
                datag(zno, xno, vno) = poly(1); %***first coef is mean?
            end
            %if vno==6 && mgrid.z(gno)>=15 && poly(1)<2100; keyboard; end
        elseif length(iisg)>0 && isfield(mgrid, 'sam_fill') && contains(mgrid.sam_fill, 'nearby')
            datag(zno, xno, vno) = mean(data(iis(iisg)));
            datam(zno, xno, vno) = 0.7; %***
        end
    end %for vno
    
end %for gno

%fill in sample profiles using nearest neighbour, but flag 0.8 because we
%may want to overwrite with smooth mapping
if isfield(mgrid, 'sam_fill') && contains(mgrid.sam_fill, 'nnv')
    for vno = 1:nvars
        for xno = 1:ngx
            iib = find(datam(:,xno,vno)==1 & mgrid.mask(:,xno)==0);
            if length(iib)>0
                iig = find(datam(:,xno,vno)==0);
                if length(iig)>2
                    datag(iib,xno,vno) = interp1(iig, datag(iig,xno,vno), iib, 'nearest', 'extrap');
                    datam(iib,xno,vno) = 0.8;
                end
            end
        end
    end
end

%fill in gaps in ctd variables using mapped sample data
if isfield(mgrid, 'ctd_fill')
    if contains(mgrid.ctd_fill, 'sam')
        cvarsfill = {'oxygen' 'psal'}; %really unlikely to have something with which to fill T
        for vno = 1:length(cvarsfill)
            iic = find(strcmp(cvarsfill{vno}, mgrid.vars));
            if sum(sum(datam(:,:,iic)>0))>sum(sum(mgrid.mask))
                %first fill with masked sample oxygen
                iis = find(strcmp(cvarsfill{vno}, sdata.vars));
                dat = datag(:,:,iis);
                m = mgrid.datam(:,:,iic);
                iifs = find(m>0 & ~isnan(dat));
                mgrid.(cvarsfill{vno})(iifs) = dat(iifs);
                mgrid.(cvarsfill{vno})(mgrid.mask==1) = NaN;
                m(iifs) = 0.5; m(mgrid.mask==1) = 1;
                mgrid.datam(:,:,iic) = m;
            end
        end
    end
end

% add sample maps to mgrid for quantities not from ctd
for vno = 1:nvars
    if ~sum(strcmp(sdata.vars{vno}, mgrid.vars))
        mgrid = setfield(mgrid, sdata.vars{vno}, datag(:,:,vno));
        mgrid.vars = [mgrid.vars sdata.vars{vno}];
        mgrid.unts = [mgrid.unts sdata.unts{vno}];
        mgrid.datam(:,:,size(mgrid.datam,3)+1) = datam(:,:,vno);
    end
end
