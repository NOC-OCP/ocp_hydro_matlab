function scs_to_mstar2
% function scs_to_mstar2(tstream,dn1,dn2)
% function ncfile = scs_to_mstar2(scs_in,ncfile,dataname)

% load scs file into mstar file
%
% 8 Sep 2009: SCS version of original techsas script, for JR195
% The searched directory is MEXEC_G.uway_root, which for example can be
% /data/cruise/jcr/20090310/scs_copy/Compress
% The var names and units are taken from ascii file
% seatex-gga.TPL
% for example.
%

m_common
m_margslocal
m_varargs

MEXEC_A.Mprog = 'scs_to_mstar2';
m_proghd


instream = m_getinput('Type scs stream name or mexec short name eg gyro_s or gyro : ','s');
tstream = msresolve_stream(instream);
ms_update_aco_to_mat(tstream); % ensure mat file is up to date before loading
dv1 = m_getinput('Type start datevec eg [2009 4 3 0 0 0] : ','s');
dv2 = m_getinput('Type end   datevec eg [2009 4 3 23 59 59] : ','s');

cmd = ['dn1 = datenum(' dv1 ');']; eval(cmd);
cmd = ['dn2 = datenum(' dv2 ');']; eval(cmd);

varlist =  m_getinput('Type the list of vars to load ( return or ''/'' for all)  : ','s'); % no checking at present
% get var list
[vars units] = msgetvars(tstream);
vars{end+1} = 'time'; % time is always a variable in scs
units{end+1} = 'matlab';
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

% bak for jr195 2009-sep-17
% load data before creating mstar file in case no data cycles found
[tdata tunits] = msload(tstream,dn1,dn2,loadvlist);
if isempty(tdata.time) % no data cycles found
    return
end

ncfile.name = mstar_fn;

ncfile = m_openot(ncfile); %check it is not an open mstar file
% techsas_in.name = techsas_fn;

nc_attput(ncfile.name,nc_global,'dataname',dataname); %set the dataname
nc_attput(ncfile.name,nc_global,'instrument_identifier',instrument);

nc_attput(ncfile.name,nc_global,'platform_type',MEXEC_G.PLATFORM_TYPE); %eg 'ship'
nc_attput(ncfile.name,nc_global,'platform_identifier',MEXEC_G.PLATFORM_IDENTIFIER); %eg 'James_Cook'
nc_attput(ncfile.name,nc_global,'platform_number',MEXEC_G.PLATFORM_NUMBER); %eg 'Cruise 31'

% [tdata tunits] = msload(tstream,dn1,dn2,loadvlist);

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
m_add_comment(ncfile,'This mstar file created from scs stream');
m_add_comment(ncfile,tstream);
m_add_comment(ncfile,['at ' nowstring]);
m_add_comment(ncfile,['Time converted from matlab day number to seconds after mstar time origin']);
    
m_finis(ncfile);

h = m_read_header(ncfile);
m_print_header(h);

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
