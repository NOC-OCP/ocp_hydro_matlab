% mctd_condcal
% overhaul of cond calibration function by bak and aa on di368 to try to
% improve/simplify logic
% need to specify station number: stn
%
% and
% sensor to calibrate: senscal
% these will be prompted for if unset.

scriptname = 'mctd_condcal';
minit
mdocshow(scriptname, ['applies conductivity calibration set in opt_' mcruise ' to ctd_' mcruise '_' stn_string '_24hz.nc']);

clear stn % so that it doesn't persist

root_ctd = mgetdir('M_CTD');
prefix1 = ['ctd_' mcruise '_'];
infile = [root_ctd '/' prefix1 stn_string '_24hz'];

if exist('senscal','var')
    m = ['Running script ' scriptname ' on sensor ' sprintf('%03d',senscal)];
    fprintf(MEXEC_A.Mfidterm,'%s\n',m)
else
    senscal = input('type choice of sensor to calibrate, reply 1 or 2 : ');
end

senslocal = senscal; clear senscal; % so it doesnt persist.

if senslocal ~= 1 & senslocal ~= 2
    m = ['Must specify sensor as 1 or 2. Sensor was sepcified as ' sprintf('%d',senslocal)];
    fprintf(2,'%s\n',m)
    return
end

condname=['cond' num2str(senslocal)];
tempname=['temp' num2str(senslocal)];
invarnames = ['press time ' tempname ' ' condname];

% Apply bottle/ctd conductivity ratio correction in 24 hz file

mcalib_str=['y = cond_apply_cal(' num2str(senslocal) ',' num2str(stnlocal) ',x1,x2,x3,x4)'];

MEXEC_A.MARGS_IN = {
infile
'y'
condname
invarnames
mcalib_str
' '
' '
' '
};
mcalib2

%add comments

ncfile.name=[infile '.nc'];
comment = ['cond calibration applied to sensor ' num2str(senslocal) ' using cond_apply_cal.m for this cruise.'];
m_add_comment(ncfile,comment);


