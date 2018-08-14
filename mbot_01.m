% mbot_01: prepare data about niskin bottles, based on csv bottle file(s)
%
% Use: mbot_01        and then respond with station number, or for station 16
%      stn = 16; mbot_01;
%
% Loads information on Niskin bottles from either opt_cruise or a concatenated, comma-delimited file
%    with fields including either station, niskin OR sampnum = 100*station+niskin
%    and optionally
%        bottle_number, which otherwise will be set equal to niskin, and
%        bottle_qc_flag, which otherwise may be set in opt_cruise
%
% YLF jr16002 and jc145 modified heavily to use database and cruise-specific options

scriptname = 'mbot_01';
minit

mdocshow(scriptname, ['puts Niskin bottle information from file specified in opt_' mcruise ' (by default, bot_' mcruise '_' stn_string '.csv) into bot_' mcruise '_' stn_string '.nc']);

% resolve root directories for various file types
root_bot = mgetdir('M_CTD_CNV'); % the csv bottle file(s) is/are in the ascii files directory
root_ctd = mgetdir('M_CTD');

%load the sample information
oopt = 'infile'; get_cropt
ds_bot = dataset('File', infile, 'Delimiter', ',');

if ~sum(strcmp('sampnum', ds_bot.Properties.VarNames))
   ds_bot.sampnum = ds_bot.sta*100 + ds_bot.niskin;
end
if ~sum(strcmp('sta', ds_bot.Properties.VarNames))
   ds_bot.sta = floor(ds_bot.sampnum/100);
   ds_bot.niskin = ds_bot.sampnum - 100*ds_bot.sta;
end

%extract info for this station
ii1 = find(ds_bot.sta==stnlocal);
%eliminate lines about duplicate samples from the same bottle
[c, ii2] = unique(ds_bot.sampnum(ii1)); ii = ii1(ii2);

if length(ii)>0
    
statnum = ds_bot.sta(ii);
position = ds_bot.niskin(ii);
if sum(strcmp('bottle_number', ds_bot.Properties.VarNames))
   bottle_number = ds_bot.bottle_number(ii);
else
   bottle_number = ds_bot.niskin(ii);
end
if sum(strcmp('bottle_qc_flag', ds_bot.Properties.VarNames))
   bottle_qc_flag = ds_bot.bottle_qc_flag(ii);
end

oopt = 'botflags'; get_cropt

sampnum = ds_bot.sampnum(ii);

else
    statnum = 0; sampnum = 0; position = 0; bottle_number = 0; bottle_qc_flag = NaN;
end

prefix = ['bot_' mcruise '_'];
otfile = [root_ctd '/' prefix stn_string];
dataname = [prefix stn_string];

varnames = {'statnum','position','bottle_number','bottle_qc_flag'};
varunits = {'number','on rosette','number', 'woce table 4.8','number'};

varnames=[varnames 'sampnum'];

clear stn % so that it doesn't persist

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
% Filename bot_jc032_001.nc   Data Name :  oxy_jc032_001 <version> 1 <site> jc032MEXEC_A.MARGS_IN_1 = {
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
