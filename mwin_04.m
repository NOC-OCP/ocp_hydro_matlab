% mwin_04: paste winch fir data into sam file
%
% Use: mwin_04        and then respond with station number, or for station 16
%      stn = 16; mwin_04;

minit; scriptname = mfilename;
mdocshow(scriptname, ['adds winch data from bottle firing times to sam_' mcruise '_' stn_string '.nc']);

root_ctd = mgetdir('M_CTD');
prefix1 = ['fir_' mcruise '_'];
prefix2 = ['sam_' mcruise '_'];

infile1 = [root_ctd '/' prefix1 stn_string '_winch'];
otfile2 = [root_ctd '/' prefix2 stn_string];


%--------------------------------
% 2009-01-26 12:14:38
% mpaste
% input files
% Filename fir_jr193_016_ctd.nc   Data Name :  fir_jr193_016 <version> 21 <site> bak_macbook
% output files
% Filename sam_jr193_016.nc   Data Name :  sam_jr193_016 <version> 16 <site> bak_macbook
MEXEC_A.MARGS_IN = {
otfile2
infile1
'y'
'position'
'position'
'wireout'
'wireout'
};
mpaste
%--------------------------------