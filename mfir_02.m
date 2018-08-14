% mfir_02: merge time from ctd onto fir file using scan number
%
% Use: mfir_02        and then respond with station number, or for station 16
%      stn = 16; mfir_02;

scriptname = 'mfir_02';
minit
mdocshow(scriptname, ['add time from ctd_' mcruise '_' stn_string '.nc to fir_' mcruise '_' stn_string '.nc based on scan number']);

root_ctd = mgetdir('M_CTD');
prefix1 = ['fir_' mcruise '_'];
prefix2 = ['ctd_' mcruise '_'];
infile1 = [root_ctd '/' prefix1 stn_string '_bl'];
infile2 = [root_ctd '/' prefix2 stn_string '_1hz'];
otfile2 = [root_ctd '/' prefix1 stn_string '_time'];


%--------------------------------
% 2009-01-26 05:50:54
% mmerge
% input files
% Filename fir_jr193_016_bl.nc   Data Name :  fir_jr193_016 <version> 4 <site> bak_macbook
% Filename ctd_jr193_016.nc   Data Name :  ctd_jr193_016 <version> 5 <site> bak_macbook
% output files
% Filename fir_jr193_016_time.nc   Data Name :  fir_jr193_016 <version> 6 <site> bak_macbook
MEXEC_A.MARGS_IN = {
otfile2
infile1
'/'
'scan'
infile2
'scan'
'time'
'f'
};
mmerge
%--------------------------------