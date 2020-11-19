% mctd_oxycal
% overhaul of oxy calibration function by bak and gre on di368
% need to specify station number: stn

minit; scriptname = mfilename;
mdocshow(scriptname, ['applies oxygen calibration set in opt_' mcruise ' to ctd_' mcruise '_' stn_string '_24hz.nc']);

root_ctd = mgetdir('M_CTD');
prefix1 = ['ctd_' mcruise '_'];
infile = [root_ctd '/' prefix1 stn_string '_24hz'];

h = m_read_header(infile);

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

oxyname = ['oxygen' num2str(senslocal)];
tempname=['temp' num2str(senslocal)];
invarnames = ['press time ' tempname ' ' oxyname]; % bak jc191 should use temp1 or temp2; previously hardwired to temp1

% Apply oxygen correction in 24 hz file
mcalib_str=['y = oxy_apply_cal(' num2str(senslocal) ',' num2str(stnlocal) ',x1,x2,x3,x4)']
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
comment = ['oxygen calibration applied using oxy_apply_cal.m for this cruise for sensor ' num2str(senslocal) '.'];
m_add_comment(ncfile,comment);


