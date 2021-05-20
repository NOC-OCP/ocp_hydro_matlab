% mtsg_01: read in the bottle salinities from the underway samples
%
% Use: mtsg_01
%
% read in tsg data from the concatenated bottle salinity file
% and save to tsg_cruise_01.nc
%
% calls msal_standardise_avg to
%    read in input file(s),
%    compute (or extract from opt_cruise) fields not set in the input files
%    plot and flag standards
%    apply offsets
%    plot and flag samples
%    
%
% *** later should modify to allow loading a single crate file (rather than an appended
%     file) and appending to tsg all .nc file ***
%
%   uses gsw: salinity = gsw_SP_salinometer((runavg+offset)/2, cellT);

scriptname = 'mtsg_01';
mcruise = MEXEC_G.MSCRIPT_CRUISE_STRING;
mdocshow(scriptname, ['loads bottle salinities from file specified in opt_' mcruise ', calls msal_standardise_avg to optionally interactively choose standards offsets and readings to exclude, and writes to tsg_' mcruise '_all.nc']);

%root directory and filenames
root_sal = mgetdir('M_BOT_SAL');
otfile = fullfile(root_sal, ['tsg_' mcruise '_all']);
oopt = 'indata'; get_cropt; %sal_mat_file
fname_sal = fullfile(root_sal, sal_mat_file]);

%get the standardised salinity sample dataset for TSG samples
msal_standardise_avg; %this loads the file, plots standards, sets flags, applies offsets, and averages samples
load(fname_sal, 'ds_sal')

%set any different/additional flags (besides those set in msal_standardise_avg)
oopt = 'flag'; get_cropt

%extract tsg samples
ii = find(ds_sal.sampnum>=1e6); %these are TSG samples
time = (ds_sal.station_day(ii)-1)*86400 + ds_sal.cast_hour(ii)*3600 + floor(ds_sal.niskin_minute(ii))*60; %***doesn't do seconds, but are they ever recorded (meaningfully) on bottle log?
run1 = ds_sal.r1(ii);
run2 = ds_sal.r2(ii);
run3 = ds_sal.r3(ii);
runavg = ds_sal.rval(ii); %this is calculated in msal_standardise_avg (not always the average of all 3 values)
salinity = gsw_SP_salinometer(ds_sal.rval(ii)/2, ds_sal.cellT(ii));
salinity_adj = gsw_SP_salinometer((ds_sal.rval(ii)+ds_sal.offset(ii))/2, ds_sal.cellT(ii));
sal_adj_comment_string = ['Adjusted for salinometer standards readings'];
flag = ds_sal.flag(ii);


%%%%%%%%% set output variables and units, and msave to .nc file %%%%%%%%%

varnames = {'time','run1','run2','run3','runavg','salinity','flag'};
varunits = {'seconds','number','number','number','number','pss-78','woce table'};
%losing salbot here, is that ok? is it used anywhere?***

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
dataname = ['tsg_' mcruise '_all'];

%----
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
