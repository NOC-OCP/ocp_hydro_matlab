function ncfile = cchdo_botnc_to_mstar(cchdo_in,ncfile,dataname)
% function ncfile = cchdo_botnc_to_mstar(cchdo_in,ncfile,dataname)
%
%
% load cchdo data from cchdo_in and write to mstar file ncfile

cchdo_in
ncfile.name
dataname

m_common
m_margslocal
m_varargs

MEXEC_A.Mprog = 'cchdo_botnc_to_mstar';
m_proghd;

ncfile = m_openot(ncfile); %check it is not an open mstar file

nc_attput(ncfile.name,nc_global,'dataname',dataname); %set the dataname

nc_attput(ncfile.name,nc_global,'platform_type',MEXEC_G.PLATFORM_TYPE); %eg 'ship'
nc_attput(ncfile.name,nc_global,'platform_identifier',MEXEC_G.PLATFORM_IDENTIFIER); %eg 'James_Cook'
nc_attput(ncfile.name,nc_global,'platform_number',MEXEC_G.PLATFORM_NUMBER); %eg 'Cruise 31'

cchdo_names = m_unpack_varnames(cchdo_in);

cchdo_time_dim = nc_getdiminfo(cchdo_in.name,'pressure'); 
cchdo_time_length = cchdo_time_dim.Length;

for k = 1:length(cchdo_names)
    m = ['Reading variable ' cchdo_names{k}];
    fprintf(MEXEC_A.Mfidterm,'%s\n',m)
    clear cchdo_data cchdo_units v
    if strmatch(cchdo_names{k},'time','exact');  time = nc_varget(cchdo_in.name,cchdo_names{k},0,1); continue; end
    if strmatch(cchdo_names{k},'latitude','exact');  latitude = nc_varget(cchdo_in.name,cchdo_names{k},0,1); continue; end
    if strmatch(cchdo_names{k},'longitude','exact');  longitude = nc_varget(cchdo_in.name,cchdo_names{k},0,1); continue; end
    if strmatch(cchdo_names{k},'woce_date','exact');  woce_date = nc_varget(cchdo_in.name,cchdo_names{k},0,1); continue; end
    if strmatch(cchdo_names{k},'woce_time','exact');  woce_time = nc_varget(cchdo_in.name,cchdo_names{k},0,1); continue; end
    if strmatch(cchdo_names{k},'station','exact');  woce_time = nc_varget(cchdo_in.name,cchdo_names{k},0,1); continue; end
    if strmatch(cchdo_names{k},'cast','exact');  woce_time = nc_varget(cchdo_in.name,cchdo_names{k},0,1); continue; end
    cchdo_data = nc_varget(cchdo_in.name,cchdo_names{k},0,cchdo_time_length);
    cchdo_units = nc_attget(cchdo_in.name,cchdo_names{k},'units');
    if ~ischar(cchdo_data); cchdo_data(cchdo_data == -999) = nan; end
    v.name = cchdo_names{k}; v.data = cchdo_data; v.units = cchdo_units;
    if ischar(v.data); continue; end % skip char data
    m_write_variable(ncfile,v);
end

dd = rem(woce_date,100);
w2 = woce_date-dd;
mo = rem(w2,10000)/100;
yyyy = floor(woce_date/10000);
mm = rem(woce_time,100);
w2 = woce_time-mm;
hh = rem(w2,10000)/100;
% m_set_data_time_origin(ncfile,1899,12,30,0,0,0)
m_set_data_time_origin(ncfile,yyyy,mo,dd,hh,mm,00)
nc_attput(ncfile.name,nc_global,'latitude',latitude);
nc_attput(ncfile.name,nc_global,'longitude',longitude);


nowstring = datestr(now,31);
m_add_comment(ncfile,'This mstar file created from cchdo file');
m_add_comment(ncfile,cchdo_in.name);
m_add_comment(ncfile,['at ' nowstring]);


m_finis(ncfile);

h = m_read_header(ncfile);
if ~MEXEC_G.quiet; m_print_header(h); end

hist = h;
hist.filename = ncfile.name;
MEXEC_A.Mhistory_ot{1} = hist;
% fake the input file details so that write_history works
histin = h;
histin.filename = cchdo_in.name;
histin.dataname = [];
histin.version = [];
histin.mstar_site = [];
MEXEC_A.Mhistory_in{1} = histin;
m_write_history;
return