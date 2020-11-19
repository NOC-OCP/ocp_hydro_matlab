% mctd_transmisscal
% bak jc191 12 Feb 2020
% applies transmissometer calibration in 24hz file
%
% need to specify station number: stn

scriptname = 'mctd_transmisscal';
minit
mdocshow(scriptname, ['applies transmittance calibration set in opt_' mcruise ' to ctd_' mcruise '_' stn_string '_24hz.nc']);

root_ctd = mgetdir('M_CTD');
prefix1 = ['ctd_' mcruise '_'];
infile = [root_ctd '/' prefix1 stn_string '_24hz'];

% Apply transmittance correction in 24 hz file
% In the absence of other information, assume transmittance should be 100% (relative to pure water)
% in cleanest part of the water column.

mcalib_str=['y = transmiss_apply_cal(' num2str(stnlocal) ',x)']; % allow for station differences, and press/temp correction, as a template
fprintf(1,'\n%s\n\n',mcalib_str); % added jc191 to match other scripts

MEXEC_A.MARGS_IN = {
infile
'y'
'transmittance'
mcalib_str
' '
' '
' '
};
mcalib

%add comments

ncfile.name=[infile '.nc'];
comment = ['transmittance calibration applied using transmiss_apply_cal.m with options for this cruise.'];
m_add_comment(ncfile,comment);


