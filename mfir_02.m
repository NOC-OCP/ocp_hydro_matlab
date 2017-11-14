% mfir_02: merge time from ctd onto fir file using scan number
%
% Use: mfir_02        and then respond with station number, or for station 16
%      stn = 16; mfir_02;

scriptname = 'mfir_02';
cruise = MEXEC_G.MSCRIPT_CRUISE_STRING;

if ~exist('stn','var')
    stn = input('type stn number ');
end
stn_string = sprintf('%03d',stn);
stnlocal = stn; clear stn % so that it doesn't persist

mdocshow(scriptname, ['add time from ctd_' cruise '_' stn_string '.nc to fir_' cruise '_' stn_string '.nc based on scan number']);

root_ctd = mgetdir('M_CTD');
prefix1 = ['fir_' cruise '_'];
prefix2 = ['ctd_' cruise '_'];
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