% mtsg_01: read in the bottle salinities from the underway samples
%
% Use: mtsg_01
%
% read in tsg data from the concatenated bottle salinity file
%
%    as input requires a comma-delimited file, which will be loaded as a dataset (that is, column order is unimportant)
%       see msal_standardise_avg for required column headers and data format
%       if cellT and/or offset are not included in the file, they must be specified in opt_cruise
%       so they can be added to the dataset before passing to msal_standardise_avg
%
%   uses gsw: salinity = gsw_SP_salinometer((runavg+offset)/2, cellT);

scriptname = 'mtsg_01';
cruise = MEXEC_G.MSCRIPT_CRUISE_STRING;
oopt = '';

mdocshow(scriptname, ['loads bottle salinities from file specified in opt_' cruise ', calls msal_standardise_avg to optionally interactively choose standards offsets and readings to exclude, and writes to tsg_' cruise '_all.nc']);

%resolve root directories for various file types
root_sal = mgetdir('M_BOT_SAL');
otfile = [root_sal '/tsg_' cruise '_all'];

%load salinity sample and autosal reading information
oopt = 'salcsv'; get_cropt; %sal_csv_file
fname_sal = [root_sal '/' sal_csv_file];
ds_sal = dataset('File', fname_sal, 'Delimiter', ',');
if sum(strcmp('cellT', ds_sal.Properties.VarNames))==0; oopt = 'cellT'; get_cropt; end
if sum(strcmp('offset', ds_sal.Properties.VarNames))==0; oopt = 'offset'; get_cropt; end

%apply standards and obtain best average autosal values
ds_sal = msal_standardise_avg(ds_sal); %the standards offset (or "adjustment") is applied here
oopt = 'sstdagain'; get_cropt
if sstdagain; ds_sal = msal_standardise_avg(ds_sal); end %run again to check choices of which readings to use

%set any different/additional flags (besides those set in sal_standardise_avg)
oopt = 'flag'; get_cropt

ii = find(ds_sal.sampnum<0); %these are TSG samples

varnames = {'time','run1','run2','run3','runavg','salinity','flag'};
varunits = {'seconds','number','number','number','number','pss-78','woce table'};

time = (ds_sal.station_day(ii)-1)*24*3600 + ds_sal.cast_hour(ii)*3600 + ds_sal.niskin_minute(ii)*60;
run1 = ds_sal.sample1(ii);
run2 = ds_sal.sample2(ii);
run3 = ds_sal.sample3(ii);
runavg = ds_sal.rval(ii);
salinity = gsw_SP_salinometer(ds_sal.rval(ii)/2, ds_sal.cellT(ii));
flag = ds_sal.flag(ii);

salinity_adj = salinity;
sal_adj_comment_string = ['Adjustments already applied by msal_standardise_avg'];
varnames=[varnames 'salinity_adj'];
varunits=[varunits 'pss-78'];

% sorting out units for msave
varnames_units = {};
for k = 1:length(varnames)
    varnames_units = [varnames_units; varnames(k)];
    varnames_units = [varnames_units; {'/'}];
    varnames_units = [varnames_units; varunits(k)];
end

timestring = ['[' sprintf('%d %d %d %d %d %d',MEXEC_G.MDEFAULT_DATA_TIME_ORIGIN) ']'];
dataname = ['tsg_' cruise '_all'];

%--------------------------------
% 2009-03-09 20:49:09
% msave
% input files
% Filename    Data Name :   <version>  <site>
% output files
% Filename oxy_jc032_001.nc   Data Name :  oxy_jc032_001 <version> 1 <site> jc032MEXEC_A.MARGS_IN_1 = {
MEXEC_A.MARGS_IN_1 = {
    otfile
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
    sal_adj_comment_string
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
%----
