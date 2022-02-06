% mem120_from_posprocessed: read in em120/122 data from post-processing
% Use: mem120_from_posprocessed        
% 
% fist draft for em122 data on jr281, April 2013. Data provided by Gwen
% Buys.

scriptname = 'mem120_from_posprocessed';

% resolve root directories for various file types
root_em120 = mgetdir('M_EM122'); 

prefix1 = ['em122_' MEXEC_G.MSCRIPT_CRUISE_STRING '_'];

infile1 = fullfile(root_em120, [MEXEC_G.MSCRIPT_CRUISE_STRING '_centrebeam.dat']);
otfile1 = fullfile(root_em120, [prefix1 'post']);

if ~exist(infile1, 'file')
    msg = ['Input file ' infile1 ' missing'];
    fprintf(MEXEC_A.Mfider,'%s\n',msg)
    return
end

dat = load(infile1);

yyyy = dat(:,1);
dnum = dat(:,2);
hh = dat(:,3);
mm = dat(:,4);
ss = dat(:,5);
lat = dat(:,6);
lon = dat(:,7);
cordep = dat(:,8);
t0 = datenum([yyyy(1) 1 1 0 0 0]);
t1 = (dnum-1) + hh/24 + mm/1440 + ss/86400;
dn = t0+t1;

dataname = [prefix1 'postprocessed'];
%
em_comment_string = 'em122 centre beam depths from postprocessing';

otvars={
    'time'
    'lat'
    'lon'
    'cordep'
    };
otunits={
    'seconds'
    'degrees'
    'desgrees'
    'metres'
    };


% sorting out units for msave
varnames = [otvars(:)];
varunits = [otunits(:)];

varnames_units = {};
for k = 1:length(varnames)
    varnames_units = [varnames_units; varnames(k)];
    varnames_units = [varnames_units; {'/'}];
    varnames_units = [varnames_units; varunits(k)];
end

timestring = ['[' sprintf('%d %d %d %d %d %d',MEXEC_G.MDEFAULT_DATA_TIME_ORIGIN) ']'];
torg = datenum(MEXEC_G.MDEFAULT_DATA_TIME_ORIGIN);
time = 86400*(dn-torg);

%--------------------------------
% 2009-03-09 20:49:09
% msave
MEXEC_A.MARGS_IN_1 = {
    otfile1
    };
MEXEC_A.MARGS_IN_2 = varnames(:);
MEXEC_A.MARGS_IN_3 = {
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
    '7'
    '-1'
    em_comment_string
    ' '
    ' '
    '8'
    };
MEXEC_A.MARGS_IN_4 = varnames_units(:);
MEXEC_A.MARGS_IN_5 = {
    '-1'
    '-1'
    };
MEXEC_A.MARGS_IN = [MEXEC_A.MARGS_IN_1; MEXEC_A.MARGS_IN_2; MEXEC_A.MARGS_IN_3; MEXEC_A.MARGS_IN_4; MEXEC_A.MARGS_IN_5];
msave
%--------------------------------

