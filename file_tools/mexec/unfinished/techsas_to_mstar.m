function ncfile = techsas_to_mstar(techsas_in,ncfile,dataname)

% load techsas file into mstar file

m_common
m_margslocal
m_varargs

MEXEC_A.Mprog = 'techsas_to_mstar';
if ~MEXEC_G.quiet; m_proghd; end

techsas_fn = m_gettechsasfilename;
mstar_fn = m_getfilename;
dataname = m_getinput('Type required dataname : ','s');
instrument = m_getinput('Type instrument indetifier : ','s');

ncfile.name = mstar_fn;
ncfile = m_openot(ncfile); %check it is not an open mstar file
techsas_in.name = techsas_fn;

nc_attput(ncfile.name,nc_global,'dataname',dataname); %set the dataname
nc_attput(ncfile.name,nc_global,'instrument_identifier',instrument);

nc_attput(ncfile.name,nc_global,'platform_type',MEXEC_G.PLATFORM_TYPE); %eg 'ship'
nc_attput(ncfile.name,nc_global,'platform_identifier',MEXEC_G.PLATFORM_IDENTIFIER); %eg 'James_Cook'
nc_attput(ncfile.name,nc_global,'platform_number',MEXEC_G.PLATFORM_NUMBER); %eg 'Cruise 31'


techsas_names = m_unpack_varnames(techsas_in);

techsas_time_dim = nc_getdiminfo(techsas_in.name,'time'); % bak jc032 need to know present number of records in growing techsas file
techsas_time_length = techsas_time_dim.Length;

m = ['About to read ' sprintf('%d',techsas_time_length)  ' records'];
fprintf(MEXEC_A.Mfidterm,'%s\n',m);

for k = 1:length(techsas_names)
    m = ['Reading variable ' techsas_names{k}];
    fprintf(MEXEC_A.Mfidterm,'%s\n',m)
    clear techsas_data techsas_units v
    techsas_data = nc_varget(techsas_in.name,techsas_names{k},0,techsas_time_length);
    techsas_units = nc_attget(techsas_in.name,techsas_names{k},'units');
    v.name = techsas_names{k}; v.data = techsas_data; v.units = techsas_units;
    m_write_variable(ncfile,v);
end

m_set_data_time_origin(ncfile,1899,12,30,0,0,0)

nowstring = datestr(now,31);
m_add_comment(ncfile,'This mstar file created from techsas file');
m_add_comment(ncfile,techsas_in.name);
m_add_comment(ncfile,['at ' nowstring]);


m_finis(ncfile);

h = m_read_header(ncfile);
if ~MEXEC_G.quiet; m_print_header(h); end

hist = h;
hist.filename = ncfile.name;
MEXEC_A.Mhistory_ot{1} = hist;
% fake the input file details so that write_history works
histin = h;
histin.filename = techsas_in.name;
histin.dataname = [];
histin.version = [];
histin.mstar_site = [];
MEXEC_A.Mhistory_in{1} = histin;
m_write_history;
return