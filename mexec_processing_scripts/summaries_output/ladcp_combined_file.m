rootdir = '~/cruises/sd025/mcruise/data/';
%y0 = MEXEC_G.MDEFAULT_DATA_TIME_ORIGIN(1);
y0 = 2023;
ldir = fullfile(rootdir,'ladcp','ix');
sumfile = fullfile(rootdir,'collected_files','ladcp_best_profile.mat');

if exist(sumfile,'file')
    load(sumfile)
    cast = l.cast;
    proc_version = l.proc_version;
end

%initialise
clear l
l.cast = cast;
l.proc_version = proc_version;
l.proc_version_readme = {'DLUL = both downlooker and uplooker were used';
    'GPS = ship navigation and CTD pressure were used to constrain instrument motion in inverse';
    'BT = bottom tracking was used to constrain instrument motion in inverse';
    'SADCP = SADCP upper ocean velocity was used to constrain inverse'};
nc = length(cast);
a1 = nan(1,nc);
l.dday = a1; l.dday_units = sprintf('days since %d-01-01 00:00:00',y0);
l.lat = a1; l.lon = a1; l.botz = a1;
l.z = [8:8:5584]'; nz = length(l.z);
a2 = nan(nz,nc);
l.best_profile.u = a2; l.best_profile.v = a2; l.best_profile.uverr = a2;
l.best_profile.readme = 'ocean velocity from inverse solution (see proc_version for instruments and constraints) (u, v, uerr in original)';
l.downcast_profile.u = a2; l.downcast_profile.v = a2; l.upcast_profile = l.downcast_profile;
l.downcast_profile.readme = 'ocean velocity from inverse solution during downcast_profile (see proc_version for instruments and constraints) (u_do, v_do in original)';
l.upcast_profile.readme = 'ocean velocity from inverse solution during upcast_profile (see proc_version for instruments and constraints) (u_up, v_up in original)';
nzb = 40; ab = nan(nzb,nc);
l.bottr_profile.z = ab; l.bottr_profile.u = ab; l.bottr_profile.v = ab; l.bottr_profile.uverr = ab;
l.bottr_profile.readme = 'ocean velocity from instrument bottom tracking solution when in range (zbot, ubot, vbot, uerrbot in original)';
clear a1 a2 ab

for no = 1:nc
    lfile = fullfile(ldir,proc_version{no},'processed',sprintf('%03d.mat',cast(no)));
    load(lfile,'dr','p')

    l.dday(no) = datenum(dr.date)-datenum(y0,1,1)+mean(dr.tim_hour/24,'omitmissing');
    l.lat(no) = dr.lat;
    l.lon(no) = dr.lon;
    l.botz(no) = p.zbottom;

    [~,ia,ib] = intersect(l.z, dr.z);
    if length(ib)<length(dr.z)
        warning('new z')
        keyboard
    end
    l.best_profile.u(ia,no) = dr.u(ib);
    l.best_profile.v(ia,no) = dr.v(ib);
    l.best_profile.uverr(ia,no) = dr.uerr(ib);
    l.downcast_profile.u(ia,no) = dr.u_do(ib);
    l.downcast_profile.v(ia,no) = dr.v_do(ib);
    l.upcast_profile.u(ia,no) = dr.u_up(ib);
    l.upcast_profile.v(ia,no) = dr.v_up(ib);

    if isfield(dr,'zbot')
        nb = length(dr.zbot);
        l.bottr_profile.z(1:nb,no) = dr.zbot;
        l.bottr_profile.u(1:nb,no) = dr.ubot;
        l.bottr_profile.v(1:nb,no) = dr.vbot;
        l.bottr_profile.uverr(1:nb,no) = dr.uerrbot;
    end

end

%estimates of velocity closest to bottom
nbin = 1;
z = repmat(l.z,1,nc); z(isnan(l.best_profile.u)) = NaN;
[mda,iia] = max(z); 
[mdb,iib] = max(l.bottr_profile.z); 
if nbin==1
    l.botvel.readme = 'velocity closest to the bottom';
    inda = sub2ind([nz nc],iia,1:nc);
    indb = sub2ind([nzb nc],iib,1:nc);
    l.botvel.best.z = mda;
    l.botvel.best.zrange_to_bot = l.botz-mda;
    l.botvel.best.u = l.best_profile.u(inda);
    l.botvel.best.v = l.best_profile.v(inda);
    l.botvel.best.uverr = l.best_profile.uverr(inda);
    l.botvel.bottr.z = mdb;
    l.botvel.bottr.zrange_to_bot = l.botz-mdb;
    l.botvel.bottr.u = l.bottr_profile.u(indb);
    l.botvel.bottr.v = l.bottr_profile.v(indb);
    l.botvel.bottr.uverr = l.bottr_profile.uverr(indb);
else
l.botvel.readme = sprintf('velocity within %d bins of deepest',nbin);
ma = (z >= repmat(mda-nbin*8,nz,1));
mb = (l.bottr_profile.z >= repmat(mdb-nbin*8,nzb,1));
d = z; d(~ma) = NaN; l.botvel.best.z = mean(d,'omitmissing');
d = l.best_profile.u; d(~ma) = NaN; l.botvel.best.u = mean(d,'omitmissing');
d = l.best_profile.uv; d(~ma) = NaN; l.botvel.best.v = mean(d,'omitmissing');
d = l.best_profile.uverr; d(~ma) = NaN; l.botvel.best.uverr = mean(d,'omitmissing');
d = l.bottr_profile.z; d(~ma) = NaN; l.botvel.bottr.z = mean(d,'omitmissing');
d = l.bottr_profile.u; d(~ma) = NaN; l.botvel.bottr.u = mean(d,'omitmissing');
d = l.bottr_profile.uv; d(~ma) = NaN; l.botvel.bottr.v = mean(d,'omitmissing');
d = l.bottr_profile.uverr; d(~ma) = NaN; l.botvel.bottr.uverr = mean(d,'omitmissing');
end

save(sumfile,'l')