% mctd_oxycal
% overhaul of oxy calibration function by bak and gre on di368
% need to specify station number: stn

minit; scriptname = mfilename;
mdocshow(scriptname, ['applies oxygen calibration set in opt_' mcruise ' to ctd_' mcruise '_' stn_string '_24hz.nc']);

root_ctd = mgetdir('M_CTD');
prefix1 = ['ctd_' mcruise '_'];
infile = [root_ctd '/' prefix1 stn_string '_24hz'];

h = m_read_header(infile);

if length(senscal)==0; senscalstr = '[]'; else; senscalstr = num2str(senscal); end
oxyname = ['oxygen' num2str(senscal)];
invarnames = ['press time temp1 ' oxyname];

% Apply oxygen correction in 24 hz file
mcalib_str=['y = oxy_apply_cal(' senscalstr ',' num2str(stnlocal) ',x1,x2,x3,x4)']
MEXEC_A.MARGS_IN = {
infile
'y'
oxyname
invarnames
mcalib_str
' '
' '
' '
};
mcalib2

%add comments

ncfile.name=[infile '.nc'];
comment = ['oxygen calibration applied using oxy_apply_cal.m for this cruise.'];
m_add_comment(ncfile,comment);


