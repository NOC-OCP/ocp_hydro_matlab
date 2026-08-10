function sensor_corr_evaluations(param, klist)
%
% compare, and look for offsets (or scale factors) between different C (or
% O) sensors, as a function of potential temperature and pressure (or
% potential temperature and salinity), with background gradients/variance
% as context
%
% if param == 'oxy', first compare down- and up-cast data for each sensor
% to look for alignment and hysteresis adjustments/corrections
%
% can be used as another check in addition to mctd_checkplots; to check the
% results of applying calibrations; or to estimate an adjustment to apply
% to data from one sensor to make it line up better with the others (e.g.
% if calibration data are not available for all sensors)
%
% compare_sns should be length 1 

m_common
mcruise = MEXEC_G.MSCRIPT_CRUISE_STRING;

pd = mexec_file_locations('procfiles','ctd');
load(pd.sg)
sn_list = sn_list.(param);

%load all data
nstn = length(klist); nsns = length(sn_list); ncols = nstn*nsns;
pg = [1:2:8000]';
all2.potemp = nan(length(pg),ncols); 
all2.psal = all2.potemp; all2.oxy = all2.potemp;
if strcmp(param,'oxy')
    sr = [-24*5:24*5]; lr = length(sr);
    allr.cond = nan+zeros(length(sr),ncols);
    allr.oxy = nan+zeros(length(sr),ncols);
    pg10 = [5:10:8000]';
    all10.oxyd = NaN+zeros(length(pg10),ncols); all10.oxyu = all10.oxyd;
    all10.potemp = all10.oxyd;
    all10.timed = all10.oxyd; all10.timeu = all10.oxyd; 
    all10.pressd = all10.oxyd; all10.pressu = all10.oxyu;
end
nc = 1;
for stn = klist
    opt1 = 'setup'; opt2 = 'm_stn_string'; get_cropt
    infile = sprintf(pd.ctd2d,stn_string);
    if ~exist(infile,'file')
        continue
    end
    [d2,h2] = mload(infile,'press oxy1 oxy2 potemp1 potemp2 psal1 psal2');
    if strcmp(param,'oxy')
        infile = sprintf(pd.ctd10s,stn_string);
        [d10,h10] = mload(infile,'press oxy1 oxy2 potemp1 potemp2 time');
        infile = sprintf(pd.ctdraw,stn_string);
        [dr,hr] = mload(infile,'scan cond1 cond2 oxy1 oxy2 pumps');
    end
    [~,ia,ib] = intersect(pg,d2.press,'stable');
    v = 'potemp';
    all2.(v)(ia,nc:nc+1) = [d2.([v '1'])(ib) d2.([v '2'])(ib)];
    m1 = strcmp(h2.fldnam, 'temp1'); m2 = strcmp(h2.fldnam, 'temp2');
    all.('sn_potemp')(nc:nc+1) = [str2double(h2.fldserial{m1}) str2double(h2.fldserial{m2})];
    v = 'psal';
    all2.(v)(ia,nc:nc+1) = [d2.([v '1'])(ib) d2.([v '2'])(ib)];
    m1 = strcmp(h2.fldnam,'cond1'); m2 = strcmp(h2.fldnam,'cond2');
    all.(['sn_' v])(nc:nc+1) = [str2double(h2.fldserial{m1}) str2double(h2.fldserial{m2})];
    v = 'oxy';
    all2.(v)(ia,nc:nc+1) = [d2.([v '1'])(ib) d2.([v '2'])(ib)];
    m1 = strcmp(h2.fldnam,[v '1']); m2 = strcmp(h2.fldnam,[v '2']);
    all.(['sn_' v])(nc:nc+1) = [str2double(h2.fldserial{m1}) str2double(h2.fldserial{m2})];
    all.place(nc:nc+1) = [1 2]; all.stn(nc:nc+1) = stnlocal;
    %all.lat(nc:nc+1) = h.latitude; all.lon(nc:nc+1) = h.longitude;
    if strcmp(param,'oxy')
        ii0 = find(dr.pumps(1:end-1)==1 & dr.pumps(2:end)==0); 
        ii = ii0(end)+sr; ii = ii(ii<length(dr.pumps));
        if length(ii)<length(sr)/2
            ii = ii0(end-1)+sr; ii = ii(ii<length(dr.pumps));
        end
        allr.cond(1:length(ii),nc:nc+1) = [dr.cond1(ii) dr.cond2(ii)];
        allr.oxy(1:length(ii),nc:nc+1) = [dr.oxy1(ii) dr.oxy2(ii)];
        ii = find(d10.press==max(d10.press)); ii = ii(1);
        ptd = d10.potemp1(1:ii); ptu = d10.potemp1(ii:end);
        [ptd,iid] = sort(ptd,'descend'); iid = iid(~isnan(ptd)); ptd = ptd(~isnan(ptd));
        [ptu,iiu] = sort(ptu,'descend'); iiu = iiu(~isnan(ptu)); ptu = ptu(~isnan(ptu));
        nd = length(iid);
        all10.oxyd(1:nd,nc) = d10.oxy1(iid); all10.oxyu(1:nd,nc) = interp1(ptu,d10.oxy1(iiu),ptd);
        all10.timed(1:nd,nc) = d10.time(iid); all10.timeu(1:nd,nc) = interp1(ptu,d10.time(iiu),ptd);
        all10.pressd(1:nd,nc) = d10.press(iid); all10.pressu(1:nd,nc) = interp1(ptu,d10.press(iiu),ptd);
        ptd = d10.potemp2(1:ii); ptu = d10.potemp2(ii:end);
        [ptd,iid] = sort(ptd,'descend'); iid = iid(~isnan(ptd)); ptd = ptd(~isnan(ptd));
        [ptu,iiu] = sort(ptu,'descend'); iiu = iiu(~isnan(ptu)); ptu = ptu(~isnan(ptu));
        nd = length(iid);
        all10.oxyd(1:nd,nc+1) = d10.oxy1(iid); all10.oxyu(1:nd,nc+1) = interp1(ptu,d10.oxy2(iiu),ptd);
        all10.timed(1:nd,nc+1) = d10.time(iid); all10.timeu(1:nd,nc+1) = interp1(ptu,d10.time(iiu),ptd);
        all10.pressd(1:nd,nc+1) = d10.press(iid); all10.pressu(1:nd,nc+1) = interp1(ptu,d10.press(iiu),ptd);
    end
    nc = nc+2;
end
all = struct2table(all);
all2 = struct2table(all2);
all2 = varfun(@(x) x(:,1:nc-1), all2);
all2.Properties.VariableNames = cellfun(@(x) replace(x,'Fun_',''),all2.Properties.VariableNames,'UniformOutput',false);
if strcmp(param,'oxy')
    allr = struct2table(allr);
    all10 = struct2table(all10);
    allr = varfun(@(x) x(1:nc-1),allr);
    all10 = varfun(@(x) x(1:nc-1),all10);
    allr.Properties.VariableNames = cellfun(@(x) replace(x,'Fun_',''),allr.Properties.VariableNames,'UniformOutput',false);
    all10.Properties.VariableNames = cellfun(@(x) replace(x,'Fun_',''),all10.Properties.VariableNames,'UniformOutput',false);
end

keyboard
iip = find(~isnan(dref.potemp) | ~isnan(dcomp.potemp));
dref.potemp(:,nref+1:end) = []; dref.psal(:,nref+1:end) = []; dref.oxy(:,nref+1:end) = [];
dcomp.potemp(:,ncomp+1:end) = []; dcomp.psal(:,ncomp+1:end) = []; dcomp.oxy(:,ncomp+1:end) = [];
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
    pp = 'oxy';
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
    m1o(:,no) = nanmedian(dref.oxy(:,ii),2);
    end
end
dt = m1t-dcomp.potemp; ds = m1s-dcomp.psal; do = m1o-dcomp.oxy; dor = m1o./dcomp.oxy;
dt = dt(300:end,:); ds = ds(300:end,:); do = do(300:end,:); dor = dor(300:end,:);
format long; disp([nanmedian(dt(:)) nanmedian(ds(:)) nanmedian(do(:)) nanmedian(dor(:))]); format("default")
figure(1); clf
subplot(221); hist(dt(:))
subplot(222); hist(ds(:))
subplot(223); hist(do(:))
subplot(224); hist(dor(:))
figure(2); clf
if dooxy
    plot(dref.potemp,dref.oxy,'.',dcomp.potemp,dcomp.oxy,'k-');
else
    plot(dref.psal,-pg,'.',dcomp.psal,-pg,'x-');
end
keyboard

figure(2); clf
scatter(x1(:),y1(:),20,z1(:))
hold on
scatter(x2(:),y2(:),10,z2(:),'filled')


