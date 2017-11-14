% mctd_depest: estimate bottom depth
%
% Use: mctd_depest        and then respond with station number, or for station 16
%      stn = 16; mctd_depest;

scriptname = 'mctd_depest';
cruise = MEXEC_G.MSCRIPT_CRUISE_STRING;

if exist('stn','var')
    m = ['Running script ' scriptname ' on station ' sprintf('%03d',stn)];
    fprintf(MEXEC_A.Mfidterm,'%s\n',m)
else
    stn = input('type stn number ');
end
stn_string = sprintf('%03d',stn);
clear stn % so that it doesn't persist

root_ctd = mgetdir('M_CTD');
prefix1 = ['ctd_' cruise '_'];
infile1 = [root_ctd '/' prefix1 stn_string '_psal'];
otfile1 = [root_ctd '/' prefix1 stn_string '_depest'];

%--------------------------------
% 2009-11-18 16:43:04
% mcalc
% input files
% Filename ctd_jr194_018_psal.nc   Data Name :  ctd_jr194_018 <version> 21 <site> jr193_atnoc
% output files
% Filename gash.nc   Data Name :  ctd_jr194_018 <version> 28 <site> jr193_atnoc
MEXEC_A.MARGS_IN = {
infile1
otfile1
'time press depth altimeter/'
'depth altimeter'
'y = x1+x2'
'bottom'
' '
' '
};
mcalc
%--------------------------------


