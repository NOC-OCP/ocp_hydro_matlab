% script mvad_01 to replace mcod_01 an mcod_02 using outout from
% python version of codas for vmadcp
%
% first draft bak jc159 1 April 2018
% based on previous mcod_01
%
% Unlike previous versions, runs on a single appended file for a whole
% cruise, input file example is os150nb.nc
% to run on os75nb without prompts type
%
% inst = 'os75nb'; mvad_01


m_common
m_margslocal
m_varargs

scriptname = 'mvad_01';
mcruise = MEXEC_G.MSCRIPT_CRUISE_STRING;

if exist('inst','var')
    m = ['Running script ' scriptname ' for OS ' sprintf('%d',inst)];
    fprintf(MEXEC_A.Mfidterm,'%s\n',m)
else
    inst = input('Enter instrument type inst: e.g. os150nb, os75nb, os150bb : ', 's');
end
instlocal = inst; clear inst; % so it doesnt persist

root_vmadcp = mgetdir('M_VMADCP');
fnin = [root_vmadcp '/mproc/' mcruise '/' instlocal '/contour/' instlocal '.nc'];
dataname = [instlocal '_' mcruise '_01'];

if ~exist(fnin, 'file')
    error(['input file ' fnin ' not found'])
end
otfile = [root_vmadcp '/mproc/' dataname '.nc'];
clear allin 

allin.decday = nc_varget(fnin,'time');
tu = nc_attget(fnin,'time','units');
allin.lon = nc_varget(fnin,'lon');
allin.lat = nc_varget(fnin,'lat');
allin.depth = nc_varget(fnin,'depth');
allin.uabs = 100*nc_varget(fnin,'u'); % we have used cm/s in the past; codas netcdf uses m/s
allin.vabs = 100*nc_varget(fnin,'v');
allin.uship = nc_varget(fnin,'uship');
allin.vship = nc_varget(fnin,'vship');
% CODAS uses missing_value = 1.0e38 turn these into NaN now.
allin.uabs(allin.uabs > 1e10) = nan;
allin.vabs(allin.vabs > 1e10) = nan;
allin.uship(allin.uship > 1e10) = nan;
allin.vship(allin.vship > 1e10) = nan;
kf = strfind(tu,'since');
torgstr = tu(kf+5:end);
cotorg = datenum(torgstr);
torgstr = datestr(cotorg,'yyyy mm dd HH MM SS');
allin.time = 86400*allin.decday; % input time is decimal days past cotorg

% expand the 1-D vars to 2-D

clear allot

ndeps = size(allin.depth,2);
allot = allin;
allot.time = repmat(allin.time,1,ndeps);
allot.lat = repmat(allin.lat,1,ndeps);
allot.lon = repmat(allin.lon,1,ndeps);
allot.decday = repmat(allin.decday,1,ndeps);
allot.uship = repmat(allin.uship,1,ndeps);
allot.vship = repmat(allin.vship,1,ndeps);
allot.speed = sqrt(allot.uabs.*allot.uabs + allot.vabs.*allot.vabs);
allot.shipspd = sqrt(allot.uship.*allot.uship + allot.vship.*allot.vship);

% have to move the variables from structure to vars before we can save

varnames = fieldnames(allot);
for kl = 1:length(varnames)
    kv = varnames{kl};
    cmd = ['clear ' kv]; eval(cmd);
    cmd = [kv ' = double(allot.' kv ')'';']; eval(cmd);
end

%This fits with vmadpc_proc

timestring = torgstr;

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
    'speed'
    'shipspd'
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
    'speed'
    '/'
    'cm/s'
    'shipspd'
    '/'
    'm/s'
    '-1'
    '-1'
    };
msave

