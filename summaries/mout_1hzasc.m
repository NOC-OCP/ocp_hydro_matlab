function mout_1hzasc(stn)
% function mout_1hzasc(stn)
%
% prints out ctd and gps data to ascii files
% used by LADCP processing
%
% replaces m***
% and make_sm

m_common

minit; scriptname = mfilename; mdocshow(scriptname, ['saves 1 hz t,P,T,S,lat,lon to ladcp/ctd/ctd.' stn_string '.02.asc, and navstream to ladcp/gps/sm']);

%%%%%%%%% write ctd data %%%%%%%%%

root_ctd = mgetdir('M_CTD');
root_out = [mgetdir('M_LADCP')];
infile = [root_ctd '/ctd_' mcruise '_' stn_string '_psal'];

if exist(m_add_nc(infile),'file') ~= 2
    return
end

[dd dh] = mload(infile,'time press temp psal latitude longitude','0');

dd.decday = datenum(dh.data_time_origin) + dd.time/86400 - datenum([dh.data_time_origin(1) 1 0 0 0 0]); % decimal day of year; noon on 1 jan = 1.5
% noon on 1 jan = 1.5, to agree with loadctd and loadnav

kok = find(isfinite(dd.temp) & isfinite(dd.psal) & isfinite(dd.press));

fnot = [root_out '/ctd/ctd.' stn_string '.02.asc'];
fid = fopen(fnot,'w');
for kl = 1:length(kok)
   fprintf(fid,'%10.2f %8.2f %8.4f %8.4f %11.6f %10.6f %12.7f\n', dd.time(kok(kl)), dd.press(kok(kl)), dd.temp(kok(kl)), dd.psal(kok(kl)), dd.latitude(kok(kl)), dd.longitude(kok(kl)), dd.decday(kok(kl))); 
end
fclose(fid);


if 1
    %%%%%%%%% write nav data only %%%%%%%%%

if strcmp(MEXEC_G.Mshipdatasystem, 'techsas')
   data = mtload(MEXEC_G.default_navstream);
   lonname = 'long'; latname = 'lat';
else
   data = msload(MEXEC_G.default_navstream);
   lonname = 'lon'; latname = 'lat';
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
    if data.time(kloop) > t1(kount);
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

save /local/users/pstar/cruise/data/ladcp/uh/raw/jc1802/gps/sm sm

end