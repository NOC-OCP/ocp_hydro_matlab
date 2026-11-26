function varargout = ctdnav_asc_for_ladcp(stn)
% ctdnav_asc_for_ladcp(stn)
% with no output argument, prints out ctd and (nmea) gps data to ascii
% files used by LADCP processing
%
% f = ctdnav_asc_for_ladcp(stn)
% with output argument, just returns structure describing the format, used
% by LADCP processing 
%

m_common

opt1 = 'setup'; opt2 = 'm_stn_string'; run(MEXEC_G.opt_cruise)
opt1 = 'setup'; opt2 = 'pfiles'; run(MEXEC_G.opt_cruise)
f.ctd = pfiles.ctd_1hz_asc;
f.ctd_header_lines      = 1; %***
f.ctd_fields_per_line	= 6;
f.ctd_time_base = 1; %year-day
f.ctd_time_field = 1;
f.ctd_pressure_field	= 2;
f.ctd_temperature_field = 3;
f.ctd_salinity_field	= 4;
f.nav = f.ctd;
f.nav_header_lines	= f.ctd_header_lines;
f.nav_fields_per_line	= f.ctd_fields_per_line;
f.nav_time_base = f.ctd_time_base;
f.nav_time_field	= f.ctd_time_field;
f.nav_lat_field 	= 5;
f.nav_lon_field 	= 6;

if nargout>0
    varargout{1} = f;
    return
end

if MEXEC_G.quiet<=1; fprintf(1, 'saving 1 hz t,P,T,S,lat,lon to ladcp/ctd/ctd.%s.02.asc\n',stn_string); end

%%%%%%%%% write ctd data %%%%%%%%%

if exist(pfiles.ctd_1hz,'file') ~= 2
    disp(['file not found: ' pfiles.ctd_1hz ', not writing 1 hz ascii file'])
    return
end

dh = m_read_header(pfiles.ctd_1hz);
if sum(strcmp(dh.fldnam, 'latitude'))
    [dd, dh] = mload(pfiles.ctd_1hz,'time press temp psal latitude longitude','0');
else
    [dd, dh] = mload(pfiles.ctd_1hz,'time press temp psal','0');
    dd.dnum = m_commontime(dd,'time',dh,'datenum');
    dv1 = datevec(dd.dnum(1)-1/24);
    dv2 = datevec(dd.dnum(end)+1/24);
    opt1 = 'ship'; opt2 = 'datasys_best'; run(MEXEC_G.opt_cruise)
    switch MEXEC_G.Mshipdatasystem
        case 'rvdas'
            try
                [dn, ~, ~] = mrload(default_navstream,dv1,dv2,'q');
            catch
                warning('could not load data from %s; skipping',default_navstream)
                return
            end
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
if isfield(dh,'data_time_origin') && ~isempty(dh.data_time_origin)
    y0 = dh.data_time_origin(1);
else
    [~,to] = timeunits_mstar_cf(dh.fldunt{strcmp('time',dh.fldnam)});
    y0 = to(1);
end
dd.yearday = m_commontime(dd,'time',dh,sprintf('days since %d 1 1 0 0 0',y0));

kok = find(isfinite(dd.temp) & isfinite(dd.psal) & isfinite(dd.press));

fid = fopen(f.ctd,'w'); mfixperms(f.ctd);
fprintf(fid,'%s\n','TimeJ, press, temp, psal, latitude, longitude');

for kl = 1:length(kok)
   fprintf(fid,'%12.7f %8.2f %8.4f %8.4f %11.6f %10.6f\n', dd.yearday(kok(kl)), dd.press(kok(kl)), dd.temp(kok(kl)), dd.psal(kok(kl)), dd.latitude(kok(kl)), dd.longitude(kok(kl)));
end

fclose(fid); mfixperms(f.ctd);


