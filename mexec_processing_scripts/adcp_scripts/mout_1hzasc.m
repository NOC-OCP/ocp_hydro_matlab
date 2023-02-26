function mout_1hzasc(stn)
% function mout_1hzasc(stn)
%
% prints out ctd and gps data to ascii files
% used by LADCP processing
%
% replaces make_sm

m_common

opt1 = 'castpars'; opt2 = 'minit'; get_cropt
if MEXEC_G.quiet<=1; fprintf(1, 'saving 1 hz t,P,T,S,lat,lon to ladcp/ctd/ctd.%s.02.asc\n',stn_string); end

%%%%%%%%% write ctd data %%%%%%%%%

root_ctd = mgetdir('M_CTD');
infile = fullfile(root_ctd, ['ctd_' mcruise '_' stn_string '_psal']);

if exist(m_add_nc(infile),'file') ~= 2
    disp(['file not found: ' infile ', not writing 1 hz ascii file'])
    return
end

dh = m_read_header(infile);
if sum(strcmp(dh.fldnam, 'latitude'))
    [dd, dh] = mload(infile,'time press temp psal latitude longitude','0');
else
    [dd, dh] = mload(infile,'time press temp psal','0');
    dd.dnum = m_commontime(dd,'time',dh,'datenum');
    dv1 = datevec(dd.dnum(1)-1/24);
    dv2 = datevec(dd.dnum(end)+1/24);
    opt1 = 'ship'; opt2 = 'datasys_best'; get_cropt
    switch MEXEC_G.Mshipdatasystem
        case 'rvdas'
            [dn, ~, ~] = mrload(default_navstream,dv1,dv2,'q');
            m = diff(dn.dnum)<=0;
            if sum(m)
                warning('removing %d repeated or backwards times',sum(m))
                ii = 1+find(~m); ii = [1; ii(:)];
            else
                ii = 1:length(dn.dnum);
            end
            dn.dnum = dn.dnum(ii);
            dn.latitude = dn.latitude(ii);
            dn.longitude = dn.longitude(ii);
        case 'techsas'
            [dn, ~, ~] = mtload(default_navstream,dv1,dv2);
        case 'scs'
            [dn, ~, ~] = msload(default_navstream,dv1,dv2);
    end
    dd.latitude = interp1(dn.dnum,dn.latitude,dd.dnum);
    dd.longitude = interp1(dn.dnum,dn.longitude,dd.dnum);
end
opt1 = 'mstar'; get_cropt
if docf
    [~,to] = timeunits_mstar_cf(dh.fldunt{strcmp('time',dh.fldnam)});
    y0 = to(1);
else
    y0 = dh.data_time_origin(1);
end
dd.decday = m_commontime(dd,'time',dh,sprintf('days since %d 1 1 0 0 0',y0)); % decimal day of year
dd.yearday = dd.decday + 1; %noon on 1 jan = 1.5

kok = find(isfinite(dd.temp) & isfinite(dd.psal) & isfinite(dd.press));

cfg.stnstr = stn_string;
opt1 = 'outputs'; opt2 = 'ladcp'; get_cropt
fid = fopen(f.ctd,'w');
%fprintf(fid,'%s\n',ctdh);
for kl = 1:length(kok)
   fprintf(fid,'%12.7f %8.2f %8.4f %8.4f %11.6f %10.6f\n', dd.yearday(kok(kl)), dd.press(kok(kl)), dd.temp(kok(kl)), dd.psal(kok(kl)), dd.latitude(kok(kl)), dd.longitude(kok(kl)));
end
fclose(fid);


if 0 %***should this be a cruise-specific option whether uh processing is used?
    %%%%%%%%% write nav data only %%%%%%%%%

if strcmp(MEXEC_G.Mshipdatasystem, 'techsas')
   data = mtload(MEXEC_G.default_navstream);
   lonname = 'long'; latname = 'lat';
else
   data = msload(MEXEC_G.default_navstream);
   %lonname = 'lon'; latname = 'lat'; %***Y
   lonname = 'seatex_gll_lon'; latname = 'seatex_gll_lat'; %***Y
end

lon = getfield(data, lonname);
lat = getfield(data, latname);


%convert time to decimal days
data.time = data.time + MEXEC_G.uway_torg;
dv = datevec(data.time(1));
torg = datenum([dv(1) 1 1 0 0 0]);
data.time = data.time - torg + 1;

nt = length(data.time);
t1 = nan+ones(nt,1);
lat1 = t1;
lon1 = t1;

t1(1) = data.time(1);
lat1(1) = lat(1);
lon1(1) = lon(1);
kount = 1;

%get monotonic position(time) series
for kloop = 2:nt
    if data.time(kloop) > t1(kount)
        kount = kount+1;
        t1(kount) = data.time(kloop);
        lat1(kount) = lat(kloop);
        lon1(kount) = lon(kloop);
    end
end

m = [sprintf('%d',nt-kount) ' time non-monotonic data cycles discarded'];
fprintf(MEXEC_A.Mfider,'%s\n',m);

t1(kount+1:end) = [];
lat1(kount+1:end) = [];
lon1(kount+1:end) = [];

sm = [t1 lon1 lat1];

pre = mgetdir('ladcp');
d = dir(fullfile(pre, 'uh', 'raw'));
save(fullfile(pre, 'uh', 'raw', [d(end).name '/gps/sm']), 'sm')

end
