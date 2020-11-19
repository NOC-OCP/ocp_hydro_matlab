% mpig_01: read in bottle filtering from csv file
%
% Use: mpig_01        and then respond with station number, or for station 16
%      stn = 16; mpig_01;
%
%      jc191 bak: filtering pigment data from Lukas
%

scriptname = 'mpig_01';
minit
mdocshow(scriptname, ['reads bottle filtering data from .csv file into pig_' mcruise '_' stn_string '.nc']);

% resolve root directories for various file types
root_pig = mgetdir('M_BOT_PIG');

% load
prefix1 = ['pig_' mcruise '_'];
otfile2 = [root_pig '/' prefix1 stn_string];
dataname = [prefix1 stn_string];
clear stn % so that it doesn't persist
oopt = 'pigcsv'; get_cropt
if ~exist(infile, 'file'); warning(['file ' infile ' not found']); return; end
ds_pig = dataset('File', infile, 'Delimiter', ',');
ds_pig_fn = ds_pig.Properties.VarNames;

%find this station
if sum(strcmp('station', ds_pig_fn)) & sum(strcmp('niskin', ds_pig_fn))
   ds_pig.sampnum = ds_pig.station*100 + ds_pig.niskin;
else
   oopt = 'sampnum_parse'; get_cropt
end
iig = find(ds_pig.station==stnlocal);
if length(iig)==0; warning(['no pigment data for station ' stn_string]); return; end

ds_pig = ds_pig(iig,:);

oopt = 'vars'; get_cropt %set vars: {varnames varunits origvarnames}
ds_pig_fn = ds_pig.Properties.VarNames;
oopt = 'flags'; get_cropt %set default (missing) flag

%assign values to vars, and flags
nvars = size(vars,1);
for kvar = 1:nvars
   if sum(strcmp(vars{kvar,3}, ds_pig_fn))
      eval([vars{kvar,1} ' = ds_pig.' vars{kvar,3} ';']);
      if sum(strfind(vars{kvar,1}, '_flag'))
         eval([vars{kvar,1} '(' vars{kvar,1} ' <= -900) = 9;'])
      else
         eval([vars{kvar,1} '(' vars{kvar,1} ' <= -900) = NaN;'])
      end
   else
      %if it's a flag field that's not in ds_pig, set flags to 2 when data present, or 5 for missing
      ii = strfind(vars{kvar,1}, '_flag');
      if length(ii)>0
         eval([vars{kvar,1} ' = ' num2str(flag0) '+zeros(length(iig),1);'])
	     eval([vars{kvar,1} '(~isnan(' vars{kvar,1}(1:ii-1) ')) = 2;'])
      else
         warning(['no values found for pig variable ' vars{kvar,1}])
	     eval([vars{kvar,1} ' = NaN+zeros(length(iig),1);'])
      end
   end
end

oopt = 'flags'; get_cropt %modify flags if required

varnames = vars(:,1); varunits = vars(:,2); varnames_units = {};
for k = 1:length(varnames)
    varnames_units = [varnames_units; varnames(k)];
    varnames_units = [varnames_units; {'/'}];
    varnames_units = [varnames_units; varunits(k)];
end

timestring = ['[' sprintf('%d %d %d %d %d %d',MEXEC_G.MDEFAULT_DATA_TIME_ORIGIN) ']'];

%--------------------------------
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
