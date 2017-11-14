% msal_01: read in the bottle salinities from digitized autosal logs
%
% Use: msal_01        and then respond with station number, or for station 16
%      stn = 16; msal_01;
% 
%    as input requires a comma-delimited file, which will be loaded as a dataset (that is, column order is unimportant)
%       see msal_standardise_avg for required column headers and data format
%       if cellT and/or offset are not included in the file, they must be specified in opt_cruise
%       so they can be added to the dataset before passing to msal_standardise_avg
%

scriptname = 'msal_01';
cruise = MEXEC_G.MSCRIPT_CRUISE_STRING;
oopt = '';

if ~exist('stn','var')
    stn = input('type stn number ');
end
stn_string = sprintf('%03d',stn);
stnlocal = stn; clear stn % so that it doesn't persist

mdocshow(scriptname, ['loads bottle salinities from file specified in opt_' cruise ', calls msal_standardise_avg to optionally interactively choose standards offsets and readings to exclude, and writes to sal_' cruise '_' stn_string '.nc']);

% resolve root directories for various file types
root_sal = mgetdir('M_BOT_SAL');

%load salinity sample and autosal reading information
oopt = 'salcsv'; get_cropt %sal_csv_file
fname_sal = [root_sal '/' sal_csv_file];
ds_sal = dataset('File', fname_sal, 'Delimiter', ',');
if sum(strcmp('cellT', ds_sal.Properties.VarNames))==0; oopt = 'cellT'; get_cropt; end
if sum(strcmp('offset', ds_sal.Properties.VarNames))==0; oopt = 'offset'; get_cropt; end

%apply standards and obtain best average autosal values
ds_sal = msal_standardise_avg(ds_sal); %the standards offset (or "adjustment") is applied here
oopt = 'sstdagain'; get_cropt
if sstdagain; ds_sal = msal_standardise_avg(ds_sal); end %run again to check choices of which readings to use

station = repmat(stnlocal, 24, 1);
salbot = [1:24]';

sampnum = 100*station + salbot;
sampnuma = ds_sal.sampnum;
sampnuma(sampnuma<=0) = NaN; %these are TSG samples

[c, ia, ib] = intersect(sampnum, sampnuma);
runavg = NaN+zeros(size(station)); runavg(ia) = ds_sal.rval(ib);
flag = 9+zeros(size(station)); flag(ia) = ds_sal.flag(ib); %flags default to no data
cellT = NaN+zeros(size(station)); cellT(ia) = ds_sal.cellT(ib); 
salinity = gsw_SP_salinometer(runavg/2, cellT); %changed on JC103 in rapid branch, after JR16002 in JCR branch
%salinity = sw_sals(runavg/2, cellT);

%set any different/additional flags (besides those set in sal_standardise_avg)
oopt = 'flag'; get_cropt

prefix2 = ['sal_' cruise '_'];
otfile2 = [root_sal '/' prefix2 stn_string];
dataname = [prefix2 stn_string];

% now load the data to an array and assign variable names
varnames={'station','salbot','runavg','salinity','sampnum', 'flag'};
varunits={'number','number','number','pss-78','number','woce table'};

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

%--------------------------------
% 2009-03-09 20:49:09
% msave
% input files
% Filename    Data Name :   <version>  <site>
% output files
% Filename oxy_jc032_001.nc   Data Name :  oxy_jc032_001 <version> 1 <site> jc032MEXEC_A.MARGS_IN_1 = {
MEXEC_A.MARGS_IN_1 = {
    otfile2
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
%--------------------------------

