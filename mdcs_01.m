% mdcs_01: create empty data cycles file
%
% Use: mdcs_01        and then respond with station number, or for station 16
%      stn = 16; mdcs_01;
%
% The input list of variable names, example filename dcs_jr193_varlist.csv
%    is a comma-delimeted list of vars and units to be created
%    The format of each line is
%    varname,newunits
% The set of names is parsed and written back to dcs_jr193_varlist_out.csv
% The set of names can be prepared in any unix text editor.
% It can also be prepared in excel and saved as csv, but on BAK's
% mac this generates csv files with c/r instead of n/l. Thus the
% _out.csv file is more suitable for editing on unix.

minit; scriptname = mfilename;
mdocshow(scriptname, ['creates empty data cycles file dcs_' mcruise '_' stn_string '.nc based on templates/dcs_varlist.csv']);

% resolve root directories for various file types
root_templates = mgetdir('M_TEMPLATES');
root_ctd = mgetdir('M_CTD');

varfile = [root_templates '/dcs_' mcruise '_varlist.csv']; % read list of var names and units for empty sam template
dsv = dataset('File',varfile,'Delimiter',',');
varnames = dsv.varname; varunits = dsv.varunit;
mvarnames_units
for vno = 1:length(varnames)
    eval([varnames{vno} ' = NaN']);
end
statnum = stnlocal;

%save 

dataname = ['dcs_' stn_string];
otfile = [root_ctd '/' dataname];
timestring = ['[' sprintf('%d %d %d %d %d %d',MEXEC_G.MDEFAULT_DATA_TIME_ORIGIN) ']']; 
%--------------------------------
MEXEC_A.MARGS_IN_1 = {
    otfile
};
MEXEC_A.MARGS_IN_2 = snames(:);
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
MEXEC_A.MARGS_IN_4 = snames_units(:);
MEXEC_A.MARGS_IN_5 = {
'-1'
'-1'
};
MEXEC_A.MARGS_IN = [MEXEC_A.MARGS_IN_1; MEXEC_A.MARGS_IN_2; MEXEC_A.MARGS_IN_3; MEXEC_A.MARGS_IN_4; MEXEC_A.MARGS_IN_5];
msave
%--------------------------------

