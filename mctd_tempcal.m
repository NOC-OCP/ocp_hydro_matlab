% mctd_tempcal
% overhaul of cond calibration function by bak and aa on di368 to try to
% improve/simplify logic
% need to specify station number: stn
%
% and
% sensor to calibrate: senscal
% these will be prompted for if unset.
%
% bak on jr302 1 july 2014: adapt condcal into tempcal, so we can adjust
% temp1 and temp2 to close t1-t2 differences.

minit; scriptname = mfilename;
mdocshow(scriptname, ['applies temperature calibration set in opt_' mcruise ' to ctd_' mcruise '_' stn_string '_24hz.nc']);

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
invarnames = ['press time ' tempname];

% Apply temp correction in 24 hz file % no reason not to supply same
% arguments as for cond cal, even though only temp is needed

mcalib_str=['y = temp_apply_cal(' num2str(senslocal) ',' num2str(stnlocal) ',x1,x2,x3)'];
fprintf(1,'\n%s\n\n',mcalib_str);

MEXEC_A.MARGS_IN = {
    infile
    'y'
    tempname
    invarnames
    mcalib_str
    ' '
    ' '
    ' '
    };
mcalib2

%add comments

ncfile.name=[infile '.nc'];
comment = ['temp calibration applied to sensor ' num2str(senslocal) ' using temp_apply_cal.m for this cruise.'];
m_add_comment(ncfile,comment);


