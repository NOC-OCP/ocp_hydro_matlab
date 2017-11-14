% mctd_oxycal
% overhaul of oxy calibration function by bak and gre on di368
% need to specify station number: stn

scriptname = 'mctd_oxycal';
cruise = MEXEC_G.MSCRIPT_CRUISE_STRING;

if ~exist('stn','var')
    stn = input('type stn number ');
end
stn_string = sprintf('%03d',stn);
stnlocal = stn; clear stn % so that it doesn't persist

mdocshow(scriptname, ['applies oxygen calibration set in opt_' cruise ' to ctd_' cruise '_' stn_string '_24hz.nc']);

root_ctd = mgetdir('M_CTD');
prefix1 = ['ctd_' cruise '_'];
infile = [root_ctd '/' prefix1 stn_string '_24hz'];

scriptname0 = scriptname; scriptname = 'numoxy'; get_cropt; scriptname = scriptname0; clear scriptname0
if numoxy==1
   oxyname = 'oxygen';
else
   oxyname = ['oxygen' num2str(senscal)];
end
invarnames = ['press temp1 ' oxyname];

% Apply oxygen correction in 24 hz file

%***multiple sensors***

mcalib_str=['y = oxy_apply_cal(' num2str(stnlocal) ',x1,x2,x3)'];

MEXEC_A.MARGS_IN = {
infile
'y'
'oxygen'
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


