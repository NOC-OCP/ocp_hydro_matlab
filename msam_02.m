% msam_02: calculate residuals in sam file
%
% Use: msam_02        and then respond with station number, or for station 16
%      stn = 16; msam_02;

scriptname = 'msam_02';
cruise = MEXEC_G.MSCRIPT_CRUISE_STRING;

if ~exist('stn','var')
    stn = input('type stn number ');
end
stn_string = sprintf('%03d',stn);
stnlocal = stn; clear stn % so that it doesn't persist

mdocshow(scriptname, ['calculates CTD-calibration sample residuals in sam_' cruise '_' stn_string '.nc']);

root_ctd = mgetdir('M_CTD');

prefix1 = ['sam_' MEXEC_G.MSCRIPT_CRUISE_STRING '_'];

infile1 = [root_ctd '/' prefix1 stn_string];
otfile1 = [root_ctd '/' prefix1 stn_string '_resid'];




%--------------------------------
% 2009-01-26 08:21:32
% mcalc
% input files
% Filename sam_jr193_016.nc   Data Name :  sam_jr193_016 <version> 10 <site> bak_macbook
% output files
% Filename sam_jr193_016_resid.nc   Data Name :  sam_jr193_016 <version> 11 <site> bak_macbook
MEXEC_A.MARGS_IN = {
infile1
otfile1
'/'
'botpsal upsal'
'y = x1-x2'
'botpsala_m_upsal'
' '
'botpsal upsal1'
'y = x1-x2'
'botpsala_m_upsal1'
' '
'botpsal upsal2'
'y = x1-x2'
'botpsala_m_upsal2'
' '
'botoxy uoxygen'
'y = x1-x2'
'botoxy_m_uoxygen'
' '
' '
};
mcalc
%--------------------------------
