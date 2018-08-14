% get current adcp data from codas database and create mstar file
% for this to work currently, you have to be in the directory containing
% adcpdb for the chunk of data concerned
% edited by gdm on di346 to run from anywhere and add necessary paths

m_common
m_margslocal
m_varargs

scriptname = 'mcod_01';
mcruise = MEXEC_G.MSCRIPT_CRUISE_STRING;

if exist('fl','var')
    m = ['Running script ' scriptname ' on station ' fl];
    fprintf(MEXEC_A.Mfidterm,'%s\n',m)
else
    fl = input('type file number ');
    fl=sprintf('%03d',fl);
end
% stn_string = sprintf('%03d',stn);

if exist('os','var')
    m = ['Running script ' scriptname ' for OS ' sprintf('%d',os)];
    fprintf(MEXEC_A.Mfidterm,'%s\n',m)
else
    os = input('Enter OS type: 75 or 150 ');
end
inst=['os' sprintf('%d',os)];

if ~exist('nbb'); nbb = input('Enter narrowband (1) or broadband (2) '); end
if nbb==1; nbbstr='nb';
else; nbbstr='bb'; end

if ~exist('seqdbname'); seqdbname = [mcruise fl]; end
sdbname = [seqdbname nbbstr(1) 'nx'];

root_vmadcp = mgetdir('M_VMADCP');
cd([root_vmadcp '/' mcruise '_os' sprintf('%d',os)])
enxdir = [seqdbname nbbstr 'enx'];
if exist(enxdir,'dir') ~= 7; warning([enxdir ' not found']); return; end
cmd=['cd ' enxdir];eval(cmd);
clear fl os; % so it doesn't persist

codaspaths
[alldata,config]= run_agetmat('ddrange', [-10 400], 'editdir', 'edit');
data = apply_flags(alldata, alldata.pflag); %edit bad points

sec0 = datenum(MEXEC_G.MDEFAULT_DATA_TIME_ORIGIN);
secs = datenum(data.time) - sec0;
time = 86400 .* secs;
lon = data.lon;
lat = data.lat;
depth = data.depth;
uabs = data.uabs_sm;
vabs = data.vabs_sm;
uship = data.uship_sm;
vship = data.vship_sm;
time = reshape(time,size(lon));
decday = time/86400;

%This fits with vmadpc_proc
dataname = [inst '_' sdbname];
timestring = ['[' sprintf('%d %d %d %d %d %d',MEXEC_G.MDEFAULT_DATA_TIME_ORIGIN) ']'];
otfile = dataname;

MEXEC_A.MARGS_IN = {
otfile
'time'
'lon'
'lat'
'depth'
'uabs'
'vabs'
'uship'
'vship'
'decday'
' '
' '
'1'
dataname
'/'
'2'
MEXEC_G.PLATFORM_TYPE
MEXEC_G.PLATFORM_IDENTIFIER
MEXEC_G.PLATFORM_NUMBER
'/'
'4'
timestring
'/'
'8'
'time'
'/'
'seconds'
'lon'
'/'
'degrees'
'lat'
'/'
'degrees'
'depth'
'/'
'metres'
'uabs'
'/'
'cm/s'
'vabs'
'/'
'cm/s'
'uship'
'/'
'm/s'
'vship'
'/'
'm/s'
'decday'
'/'
'days'
'-1'
'-1'
};
msave



