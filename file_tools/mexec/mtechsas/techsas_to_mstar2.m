function techsas_to_mstar2
% function techsas_to_mstar(tstream,dn1,dn2,ncfile,dataname)
%
% YLF edited Feb 2017 (JC145) to not try to write with no input file
% and to be less verbose
    
% load techsas file into mstar file

m_common
m_margslocal
m_varargs

MEXEC_A.Mprog = 'techsas_to_mstar2';
if ~MEXEC_G.quiet; m_proghd; end


instream = m_getinput('Type techsas stream name or mexec short name eg SBE-SBE45.TSG or posmvpos : ','s');
tstream = mtresolve_stream(instream);
dv1 = m_getinput('Type start datevec eg [2009 4 3 0 0 0] : ','s');
dv2 = m_getinput('Type end   datevec eg [2009 4 3 23 59 59] : ','s');
    
cmd = ['dn1 = datenum(' dv1 ');']; eval(cmd);
cmd = ['dn2 = datenum(' dv2 ');']; eval(cmd);

varlist =  m_getinput('Type the list of vars to load ( return or ''/'' for all)  : ','s'); % no checking at present
% get var list
[vars units] = mtgetvars(tstream);
nv = length(vars);

% sort out the var list
if ~exist('varlist','var'); varlist = '/'; end
if strcmp(varlist,'-'); varlist = '/'; end % for compatibility with old rvs defailt for "all"
if strcmp(varlist,' '); varlist = '/'; end 

th.fldnam = vars;
th.noflds = nv; % create a structure equivalent to the mstar headers to parse for var names
varnums = m_getvlist(varlist,th);
% time always seems to be last in the techsas list; put it first if it is
% in the load list.
loadvarnames = vars(varnums);
ktime = strmatch('time',loadvarnames);
if ~isempty(ktime)
    timevarnum = varnums(ktime);
    varnums(ktime) = []; % remove time from list
%     varnums = [timevarnum varnums];
end
    
% always need to load time for mtlistit
loadvlist = ['time ' num2str(varnums)]; % add time first; the rest are resolved to numbers but must be added as a string


% techsas_fn = m_gettechsasfilename;
mstar_fn = m_getfilename;
dataname = m_getinput('Type required dataname : ','s');
% instrument = m_getinput('Type instrument indetifier : ','s');
instrument = ' '; % null for the time being

[tdata tunits] = mtload(tstream,dn1,dn2,loadvlist);
if ~isempty(tdata) %YLF added JC145
    
ncfile.name = mstar_fn;
ncfile = m_openot(ncfile); %check it is not an open mstar file
% techsas_in.name = techsas_fn;

nc_attput(ncfile.name,nc_global,'dataname',dataname); %set the dataname
nc_attput(ncfile.name,nc_global,'instrument_identifier',instrument);

nc_attput(ncfile.name,nc_global,'platform_type',MEXEC_G.PLATFORM_TYPE); %eg 'ship'
nc_attput(ncfile.name,nc_global,'platform_identifier',MEXEC_G.PLATFORM_IDENTIFIER); %eg 'James_Cook'
nc_attput(ncfile.name,nc_global,'platform_number',MEXEC_G.PLATFORM_NUMBER); %eg 'Cruise 31'

% techsas_names = m_unpack_varnames(techsas_in);
techsas_names =fieldnames(tdata);

% techsas_time_dim = nc_getdiminfo(techsas_in.name,'time'); % bak jc032 need to know present number of records in growing techsas file
% techsas_time_length = techsas_time_dim.Length;
% 
% m = ['About to read ' sprintf('%d',techsas_time_length)  ' records'];
% fprintf(MEXEC_A.Mfidterm,'%s\n',m);

for k = 1:length(techsas_names)
    if ~MEXEC_G.quiet    
    m = ['Writing variable ' techsas_names{k}];
    fprintf(MEXEC_A.Mfidterm,'%s\n',m)
    end
    clear techsas_data techsas_units v
%     techsas_data = nc_varget(techsas_in.name,techsas_names{k},0,techsas_time_length);
%     techsas_units = nc_attget(techsas_in.name,techsas_names{k},'units');
    cmd = ['techsas_data = tdata.' techsas_names{k} ';']; eval(cmd);
    cmd = ['techsas_units = tunits.' techsas_names{k} ';']; eval(cmd);
    
    % adjust time to a more conventional mstar time
    if strcmp(techsas_names{k},'time')
        techsas_data = 86400*(techsas_data + MEXEC_G.uway_torg - datenum(MEXEC_G.MDEFAULT_DATA_TIME_ORIGIN));
        techsas_units = 'seconds';
    end
    v.name = techsas_names{k}; v.data = techsas_data; v.units = techsas_units;
    m_write_variable(ncfile,v);
end

yyyy = MEXEC_G.MDEFAULT_DATA_TIME_ORIGIN(1);
mo = MEXEC_G.MDEFAULT_DATA_TIME_ORIGIN(2);
dd = MEXEC_G.MDEFAULT_DATA_TIME_ORIGIN(3);
hh = MEXEC_G.MDEFAULT_DATA_TIME_ORIGIN(4);
mm = MEXEC_G.MDEFAULT_DATA_TIME_ORIGIN(5);
ss = MEXEC_G.MDEFAULT_DATA_TIME_ORIGIN(6);

m_set_data_time_origin(ncfile,yyyy,mo,dd,hh,mm,ss)

nowstring = datestr(now,31);
m_add_comment(ncfile,'This mstar file created from techsas stream');
m_add_comment(ncfile,tstream);
m_add_comment(ncfile,['at ' nowstring]);
m_add_comment(ncfile,['Time converted from days after techsas time origin to seconds after mstar time origin']);
    

m_finis(ncfile);

h = m_read_header(ncfile);
if ~MEXEC_G.quiet; m_print_header(h); end

hist = h;
hist.filename = ncfile.name;
MEXEC_A.Mhistory_ot{1} = hist;
% fake the input file details so that write_history works
histin = h;
% histin.filename = techsas_in.name;
histin.filename = [];
histin.dataname = [];
histin.version = [];
histin.mstar_site = [];
MEXEC_A.Mhistory_in{1} = histin;
m_write_history;
return

end %end of only creating/writing to file if input file was found