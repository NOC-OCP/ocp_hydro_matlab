% msam_apend: append a sam file to the _all file
% Use: msam_apend        and then respond with station number, or for station 16
%      stn = 16; msam_apend;
%
% bak on jr302

minit; scriptname = mfilename;
mdocshow(scriptname, ['appends contents of sam_' mcruise '_' stn_string '.nc to sam_' mcruise '_all.nc']);

root_ctd = mgetdir('M_CTD');
prefix = ['sam_' mcruise '_'];
infile1 = [root_ctd '/' prefix 'all'];
infile2 = [root_ctd '/' prefix stn_string];

dstring = datestr(now,30);
wkfile1 = ['wk1_' scriptname '_' dstring];

f1 = m_add_nc(infile1);
f2 = m_add_nc(wkfile1);
datnam = [prefix 'all'];

cmd = ['mv ' f1 ' ' f2]; unix(cmd);

%MEXEC_A.MARGS_IN = {'y'}; mreset(wkfile1)
%keyboard
% Filename dcs_jr302_050.nc   Data Name :  dcs_jr302_050 <version> 1 <site> jr302_atsea
% output files
% Filename dcsx.nc   Data Name :  dcs_jr302_all <version> 7 <site> jr302_atsea
MEXEC_A.MARGS_IN = {
infile1
datnam
't'
wkfile1
infile2
' '
'/'
'c'
};
mapend
%--------------------------------

cmd = ['/bin/rm ' f2]; unix(cmd);

