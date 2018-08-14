% msam_02: calculate residuals in sam file
%
% Use: msam_02        and then respond with station number, or for station 16
%      stn = 16; msam_02;

scriptname = 'msam_02';
minit
mdocshow(scriptname, ['calculates CTD-calibration sample residuals in sam_' mcruise '_' stn_string '.nc']);

root_ctd = mgetdir('M_CTD');

prefix1 = ['sam_' mcruise '_'];

infile1 = [root_ctd '/' prefix1 stn_string];
otfile1 = [root_ctd '/' prefix1 stn_string '_resid'];




%--------------------------------
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
'botoxya uoxygen'
'y = x1-x2'
'botoxya_m_uoxygen'
' '
'botoxyb uoxygen'
'y = x1-x2'
'botoxyb_m_uoxygen'
' '
' '
};
mcalc
%--------------------------------
