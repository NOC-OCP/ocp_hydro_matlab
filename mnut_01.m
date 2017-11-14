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
% The set of names is parsed and written back to ctd_jr193_varlist_out.csv
% The above line seems to have survived from some sort of cut and paste. bak on jr302.

scriptname = 'mnut_01';
cruise = MEXEC_G.MSCRIPT_CRUISE_STRING;

if ~exist('stn','var')
    stn = input('type stn number ');
end
stn_string = sprintf('%03d',stn);
stnlocal = stn; clear stn % so that it doesn't persist

mdocshow(scriptname, ['reads bottle nutrient data from .csv file into nut_' cruise '_' stn_string '.nc']);

% resolve root directories for various file types
root_nut = mgetdir('M_BOT_NUT');
prefix1 = ['nut_' cruise '_'];
prefix2 = ['nut_' cruise '_'];
infile1 = [root_nut '/' prefix1 stn_string '.csv'];
otfile2 = [root_nut '/' prefix2 stn_string];   % bak on jr302 use BOT_NUT instead of CTD

dataname = [prefix2 stn_string];
clear stn % so that it doesn't persist

% bak on jr302 19 jun 2014 some stations don't have any nut data; exit
% gracefully

if exist(infile1,'file')~=2;
    mess = ['File ' infile1 ' not found'];
    fprintf(MEXEC_A.Mfider,'%s\n',mess)
    return
end

indata = mtextdload(infile1,','); % load data from csv

nlines = length(indata);
nbottles = nlines-2; % allow for 2 header lines

varnames = indata{1};
varunits = indata{2};
varnames = {'position','statnum','sampnum','sio4','sio4_flag','po4','po4_flag','TP','TP_flag','TN','TN_flag','no3no2','no3no2_flag','no2','no2_flag','nh4','nh4_flag'};
varunits = {'number','number','number','umol/l','woceflag','umol/l','woceflag','umol/l','woceflag','umol/l','woceflag','umol/l','woceflag','umol/l','woceflag','umol/l','woceflag'};

nvars = length(varnames);
kount = 0;
for kvar = 1:nvars
    varnam = varnames{kvar};
    cmd = ['clear ' varnam];
    eval(cmd);
end
for krow = 3:nlines
    data_cell = indata{krow};
    cell1 = data_cell{1};
    if(isempty(cell1)); continue; end % skip for empty cells
    kount = kount+1;
    for kvar = 1:nvars
        varnam = varnames{kvar};
        vardata = data_cell{kvar};
        if isempty(vardata); vardata = '9'; end
        cmd = [varnam '(kount) = ' vardata ';']; eval(cmd);
    end
end


no3no2(no3no2 == -999) = NaN; % flag is never -999; use 9 for sample not drawn.
sio4(sio4 == -999) = NaN;
po4(po4 == -999) = NaN;
TN(TN == -999) = NaN;
TP(TP == -999) = NaN;
no2(no2 == -999) = NaN;
nh4(nh4 == -999) = NaN;

cruise_numeric = str2num(cruise(3:end)); % bak on jr302. Avoid hardwiring sampnum offset
nut_sampnum_offset = cruise_numeric*100000;

sampnum = sampnum-nut_sampnum_offset;

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

