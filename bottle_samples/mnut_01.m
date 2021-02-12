% mnut_01: read in bottle nut data from csv file
%
% Use: mnut_01        and then respond with station number, or for station 16
%      stn = 16; mnut_01;
%
% The input nutrient data, example filename nut_jc032_016.csv
%    is a comma-delimeted list of nutrient data
%    The format of each line is
%    2 lines with var names and var units, followed by an unlimited number
%    of lines of sample data
% The above line seems to have survived from some sort of cut and paste. bak on jr302.

minit; scriptname = mfilename;
mdocshow(scriptname, ['reads bottle nutrient data from .csv file into nut_' mcruise '_' stn_string '.nc']);

% resolve root directories for various file types
root_nut = mgetdir('M_BOT_NUT');

% load
prefix1 = ['nut_' mcruise '_'];
otfile2 = [root_nut '/' prefix1 stn_string];
dataname = [prefix1 stn_string];
clear stn % so that it doesn't persist
oopt = 'nutcsv'; get_cropt
if ~exist(infile, 'file'); warning(['file ' infile ' not found']); return; end
ds_nut = dataset('File', infile, 'Delimiter', ',');
ds_nut_fn = ds_nut.Properties.VarNames;

%find this station
if sum(strcmp('station', ds_nut_fn)) & sum(strcmp('niskin', ds_nut_fn))
   ds_nut.sampnum = ds_nut.station*100 + ds_nut.niskin;
else
   oopt = 'sampnum_parse'; get_cropt
end
iig = find(ds_nut.station==stnlocal);
if length(iig)==0; warning(['no nuts data for station ' stn_string]); return; end

ds_nut = ds_nut(iig,:);

oopt = 'vars'; get_cropt %set vars: {varnames varunits origvarnames}
ds_nut_fn = ds_nut.Properties.VarNames;
oopt = 'flags'; get_cropt %set default (missing) flag

%assign values to vars, and flags
nvars = size(vars,1);
for kvar = 1:nvars
   if sum(strcmp(vars{kvar,3}, ds_nut_fn))
      eval([vars{kvar,1} ' = ds_nut.' vars{kvar,3} ';']);
      if sum(strfind(vars{kvar,1}, '_flag'))
         eval([vars{kvar,1} '(' vars{kvar,1} ' <= -900) = 9;'])
      else
         eval([vars{kvar,1} '(' vars{kvar,1} ' <= -900) = NaN;'])
      end
   else
      %if it's a flag field that's not in ds_nut, set flags to 2 when data present, or 5 for missing
      ii = strfind(vars{kvar,1}, '_flag');
      if length(ii)>0
         eval([vars{kvar,1} ' = ' num2str(flag0) '+zeros(length(iig),1);'])
	     eval([vars{kvar,1} '(~isnan(' vars{kvar,1}(1:ii-1) ')) = 2;'])
      else
         warning(['no values found for nut variable ' vars{kvar,1}])
	     eval([vars{kvar,1} ' = NaN+zeros(length(iig),1);'])
      end
   end
end

oopt = 'flags'; get_cropt %modify flags if required

varnames = vars(:,1); varunits = vars(:,2); 
mvarnames_units

timestring = ['[' sprintf('%d %d %d %d %d %d',MEXEC_G.MDEFAULT_DATA_TIME_ORIGIN) ']'];
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
