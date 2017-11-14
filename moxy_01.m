% moxy_01: read in bottle oxy data from csv file
%
% Use: moxy_01        and then respond with station number, or for station 16
%      stn = 16; moxy_01;
%
% The input data are in comma-delimited files suitable for loading as a database, with
%    fields/headers including either:
%        option 1:
%            statnum, niskin, botoxytempa, botoxya, botoxyflaga, botoxytempb, botoxyb, botoxyflagb
%            where units are degC, umol/l, and woce flag
%        or
%        option 2:
%            statnum, niskin, oxy_temp, oxy_titre
%            in the second case moxy_ccalc will be called to compute oxygen concentrations
%            using parameters set in opt_cruise, to and match up botoxya and botoxyb
%            flags will also be set in opt_cruise

scriptname = 'moxy_01';
cruise = MEXEC_G.MSCRIPT_CRUISE_STRING;
oopt = '';

if ~exist('stn','var')
    stn = input('type stn number ');
end
stn_string = sprintf('%03d',stn);
stnlocal = stn; clear stn % so that it doesn't persist

mdocshow(scriptname, ['loads bottle oxygens from file specified in opt_' cruise ', optionally calls moxy_ccalc to compute concentration from titration, and writes to oxy_' cruise '_' stn_string '.nc']);

% resolve root directories for various file types
root_oxy = mgetdir('M_BOT_OXY');

%load
oopt = 'oxycsv'; get_cropt
if exist(infile, 'file')
ds_oxy = dataset('File', infile, 'Delimiter', ',');

%find this station
iig = find(ds_oxy.statnum==stnlocal); 
ds_oxy = ds_oxy(iig,:);

%calculate concentrations if necessary
if sum(strcmp('oxy_titre', ds_oxy.Properties.VarNames))
   ds_oxy = moxy_ccalc(ds_oxy); %compute concentrations from titre, temperature, and other parameters
end

oopt = 'oxybotnisk'; get_cropt

sampnum = ds_oxy.statnum*100 + ds_oxy.niskin;
position = ds_oxy.niskin;
statnum = ds_oxy.statnum;
botoxya = ds_oxy.botoxya; botoxyflaga = ds_oxy.botoxyflaga; botoxytempa = ds_oxy.botoxytempa;
botoxyb = ds_oxy.botoxyb; botoxyflagb = ds_oxy.botoxyflagb; botoxytempb = ds_oxy.botoxytempb;

botoxyflaga(botoxyflaga == -999) = 9; % flag is never -999; use 9 for sample not drawn.
botoxyflagb(botoxyflagb == -999) = 9;

oopt = 'flags'; get_cropt

otfile = [root_oxy '/oxy_' cruise '_' stn_string];
dataname = ['oxy_' cruise '_' stn_string];

varnames = {'position','statnum','sampnum','botoxytempa','botoxya','botoxyflaga','botoxytempb','botoxyb','botoxyflagb'};
varunits = {'number','number','number','degC','umol/l','woceflag','degC','umol/l','woceflag'};
nvars = length(varnames);

varnames_units = {};
for k = 1:length(varnames)
    varnames_units = [varnames_units; varnames(k)];
    varnames_units = [varnames_units; {'/'}];
    varnames_units = [varnames_units; varunits(k)];
end

timestring = ['[' sprintf('%d %d %d %d %d %d',MEXEC_G.MDEFAULT_DATA_TIME_ORIGIN) ']'];


%--------------------------------
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
MEXEC_A.MARGS_IN = [MEXEC_A.MARGS_IN_1; MEXEC_A.MARGS_IN_2; MEXEC_A.MARGS_IN_3; ...
                    MEXEC_A.MARGS_IN_4;MEXEC_A.MARGS_IN_5];
msave
%--------------------------------

%--------------------------------
% 2009-03-09 20:52:10
% medita
% input files
% Filename oxy_jc032_001.nc   Data Name :  oxy_jc032_001 <version> 1 <site> jc032
% output files
% Filename oxy_jc032_001.nc   Data Name :  oxy_jc032_001 <version> 2 <site> jc032
MEXEC_A.MARGS_IN = {
otfile
'y'
'botoxytempa'
'-10 100'
'y'
'botoxya'
'0 500'
'y'
'botoxytempb'
'-10 100'
'y'
'botoxyb'
'0 500'
'y'
' '
};
medita
%--------------------------------

end
