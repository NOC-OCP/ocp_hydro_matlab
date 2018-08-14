% mctd_fluorcal
% adapted from mctd_condcal by bak on jc069; 16 feb 2012
% applies fluor calibration in 24hz file
%
% need to specify station number: stn

scriptname = 'mctd_fluorcal';
minit
mdocshow(scriptname, ['applies fluorescence calibration set in opt_' mcruise ' to ctd_' mcruise '_' stn_string '_24hz.nc']);

root_ctd = mgetdir('M_CTD');
prefix1 = ['ctd_' mcruise '_'];
infile = [root_ctd '/' prefix1 stn_string '_24hz'];

% may need to get times of data from ctd or dcs files dcs file sometimes
% won't exist on first pass, so maybe get it from the 24hz file itself

invarnames = ['fluor press temp1'];

% Apply bottle/fluor correction in 24 hz file

mcalib_str=['y = fluor_apply_cal(' num2str(stnlocal) ',x1,x2,x3)']; % allow for station differences, and press/temp correction, as a template

MEXEC_A.MARGS_IN = {
infile
'y'
'fluor'
invarnames
mcalib_str
' '
'mg/l'
' '
};
mcalib2

%add comments

ncfile.name=[infile '.nc'];
comment = ['fluor calibration applied using fluor_apply_cal.m for this cruise.'];
m_add_comment(ncfile,comment);


