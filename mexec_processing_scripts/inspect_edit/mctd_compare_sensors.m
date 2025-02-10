function mctd_compare_sensors(param, ref_sns, compare_sns, klist)
%
% compare, and look for offsets (or scale factors) between different C (or
% O) sensors, as a function of potential temperature and pressure (or
% potential temperature and salinity), with background gradients/variance
% as context?? 
%
% can be used as another check in addition to mctd_checkplots; to check the
% results of applying calibrations; or to estimate an adjustment to apply
% to data from one sensor to make it line up better with the others (e.g.
% if calibration data are not available for all sensors)
%
% compare_sns should be length 1 

m_common
mcruise = MEXEC_G.MSCRIPT_CRUISE_STRING;

% check input s/ns
if ~isempty(intersect(ref_sns, compare_sns))
    error('ref_sns and compare_sns must not overlap')
end
load(fullfile(mgetdir('M_CTD'),'sensor_groups.mat'),'sn_list','sng')
sn_list = sn_list.(param);
a = union(ref_sns,compare_sns);
if ~isempty(setdiff(a,sn_list))
    disp(setdiff(a,sn_list))
    error('above S/Ns not found in sensor_groups.mat')
end
if ~isempty(setdiff(sn_list,a))
    disp('S/Ns being ignored:')
    disp(setdiff(sn_list,a))
end

%load all data and put in either reference or compare data structures
pg = [1:2:8000]';
dref.potemp = NaN+zeros(length(pg),length(klist)*3); %***
dref.psal = dref.potemp;
if strcmp(param,'oxygen')
    dooxy = 1;
else
    dooxy = 0;
end
dref.oxygen = dref.potemp;
dref.lat = dref.psal(1,:); dref.lon = dref.lat;
dcomp = dref;
nref = 1; ncomp = 1;
for kloop = klist
    infile = fullfile(mgetdir('M_CTD'),sprintf('ctd_%s_%03d_2db',mcruise,kloop));
    [d,h] = mload(infile,'press temp1 temp2 cond1 cond2 oxygen1 oxygen2 potemp1 potemp2 psal1 psal2');
    [~,ia,ib] = intersect(pg,d.press);
    s1 = h.fldserial(strcmp([param '1'],h.fldnam));
    if ismember(s1, ref_sns)
        dref.potemp(ia,nref) = d.potemp1(ib);
        dref.psal(ia,nref) = d.psal1(ib);
        dref.oxygen(ia,nref) = d.oxygen1(ib);
        dref.lat(1,nref) = h.latitude;
        dref.lon(1,nref) = h.longitude;
        nref = nref+1;
    elseif ismember(s1, compare_sns)
        dcomp.potemp(ia,ncomp) = d.potemp1(ib);
        dcomp.psal(ia,ncomp) = d.psal1(ib);
        dcomp.oxygen(ia,ncomp) = d.oxygen1(ib);
        dcomp.lat(1,ncomp) = h.latitude;
        dcomp.lon(1,ncomp) = h.longitude;
        ncomp = ncomp+1;
    end
    s2 = h.fldserial(strcmp([param '2'],h.fldnam));
    if ismember(s2, ref_sns)
        dref.potemp(ia,nref) = d.potemp2(ib);
        dref.psal(ia,nref) = d.psal2(ib);
        dref.oxygen(ia,nref) = d.oxygen2(ib); 
        dref.lat(1,nref) = h.latitude;
        dref.lon(1,nref) = h.longitude;
        nref = nref+1;
    elseif ismember(s2, compare_sns)
        dcomp.potemp(ia,ncomp) = d.potemp2(ib);
        dcomp.psal(ia,ncomp) = d.psal2(ib);
        dcomp.oxygen(ia,ncomp) = d.oxygen2(ib);
        dcomp.lat(1,ncomp) = h.latitude;
        dcomp.lon(1,ncomp) = h.longitude;
        ncomp = ncomp+1;
    end
end
iip = find(~isnan(dref.potemp) | ~isnan(dcomp.potemp));
dref.potemp(:,nref+1:end) = []; dref.psal(:,nref+1:end) = []; dref.oxygen(:,nref+1:end) = [];
dcomp.potemp(:,ncomp+1:end) = []; dcomp.psal(:,ncomp+1:end) = []; dcomp.oxygen(:,ncomp+1:end) = [];
dref.lat(nref+1:end) = []; dref.lon(nref+1:end) = [];
dcomp.lat(ncomp+1:end) = []; dcomp.lon(ncomp+1:end) = [];

% now use hydro_tools? ***

% plot locations
figure(1); clf
plot(dref.lon,dref.lat,'o',dcomp.lon,dcomp.lat,'s'); grid

% grid and compare data
dt = 0.1;
tg = ceil(min(dref.potemp)/dt)*dt:dt:floor(max(dref.potemp)/dt)*dt;
if dooxy
    pp = 'oxygen';
else
    pp = 'psal';
end
dref.([pp '_tg']) = NaN+zeros(length(tg),size(dref.potemp,2));
dcomp.([pp '_tg']) = NaN+zeros(length(tg),size(dcomp.potemp,2));
for tno = 1:length(tg)
    m = dref.potemp>tg(tno)-dt/2 & dref.potemp<=tg(tno)+dt/2;
    m(isnan(dref.(pp))) = 0;
    if sum(m)
        a = dref.(pp).*m;
        dref.([pp '_tg'])(tno) = sum(a(:))./sum(m(:));
    end
    m = dcomp.potemp>tg(tno)-dt/2 & dcomp.potemp<=tg(tno)+dt/2;
    m(isnan(dcomp.(pp))) = 0;
    if sum(m)
        a = dcomp.(pp).*m;
        dcomp.([pp '_tg'])(tno) = sum(a(:))./sum(m(:));
    end
end
x1 = dref.potemp; y1 = repmat(-pg,1,size(dref.potemp,2));
x2 = dcomp.potemp; y2 = repmat(-pg,1,size(dcomp.potemp,2));
z1 = dref.([pp '_tg']); z3 = dref.([pp '_tg']);

nc = size(dcomp.potemp,2);
m1s = NaN+dcomp.psal; m1t = m1s; m1o = m1s;
for no = 1:nc
    d = sqrt((dcomp.lat(no)-dref.lat).^2/4+(dcomp.lon(no)-dref.lon).^2); ii = find(d<=0.1);
    if ~isempty(ii)
    m1s(:,no) = nanmedian(dref.psal(:,ii),2);
    m1t(:,no) = nanmedian(dref.potemp(:,ii),2);
    m1o(:,no) = nanmedian(dref.oxygen(:,ii),2);
    end
end
dt = m1t-dcomp.potemp; ds = m1s-dcomp.psal; do = m1o-dcomp.oxygen; dor = m1o./dcomp.oxygen;
dt = dt(300:end,:); ds = ds(300:end,:); do = do(300:end,:); dor = dor(300:end,:);
format long; disp([nanmedian(dt(:)) nanmedian(ds(:)) nanmedian(do(:)) nanmedian(dor(:))]); format("default")
figure(1); clf
subplot(221); hist(dt(:))
subplot(222); hist(ds(:))
subplot(223); hist(do(:))
subplot(224); hist(dor(:))
figure(2); clf
if dooxy
    plot(dref.potemp,dref.oxygen,'.',dcomp.potemp,dcomp.oxygen,'k-');
else
    plot(dref.psal,-pg,'.',dcomp.psal,-pg,'x-');
end
keyboard

figure(2); clf
scatter(x1(:),y1(:),20,z1(:))
hold on
scatter(x2(:),y2(:),10,z2(:),'filled')


