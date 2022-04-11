% ctd_station_plot: read in ctd data and display it in two ways
% Use: ctd_station_plot        and then respond with station number, or for station 16
%      stn = 16; ctd_station_plot;
%

scriptname = 'ctd_station_plot';

if exist('stn','var')
    m = ['Running script ' scriptname ' on station ' sprintf('%03d',stn)];
    fprintf(MEXEC_A.Mfidterm,'%s\n',m)
else
    stn = input('type stn number ');
end
stn_string = sprintf('%03d',stn);
clear stn % so that it doesn't persist

% resolve root directories for various file types
mcd('M_CTD'); % change working directory


prefix1 = ['dcs_' MEXEC_G.MSCRIPT_CRUISE_STRING '_'];
prefix2 = ['ctd_' MEXEC_G.MSCRIPT_CRUISE_STRING '_'];

infile1 = [prefix1 stn_string];
infile2 = [prefix2 stn_string '_psal'];
infile3 = [prefix2 stn_string '_2db'];

[ddcs hdcs] = mload(infile1,'/');

dntstart = datenum(hdcs.data_time_origin) + ddcs.time_start(1)/86400;
dntend = datenum(hdcs.data_time_origin) + ddcs.time_end(1)/86400;

close all
clear pdf pdf2 pdf3 pdf4 pdf5 pdf6

pdf5.ncfile.name = infile3;
pdf5.xlist = 'psal';
pdf5.ylist = 'potemp';
pdf5.cols = 'k';
pdf5.plotsize = [18 14];
mplotxy(pdf5)

pdf3.ncfile.name = infile3;
pdf3.xlist = 'press';
pdf3.ylist = 'fluor transmittance oxygen potemp psal';
pdf3.cols = 'cmbkr';
pdf3.plotsize = [18 14];
pdf3.xax = [-100 500];
pdf3.ntick = [6 10];
mplotxy(pdf3)

pdf2.ncfile.name = infile3;
pdf2.xlist = 'press';
pdf2.ylist = 'fluor transmittance oxygen potemp psal';
pdf2.cols = 'cmbkr';
pdf2.plotsize = [18 14];
mplotxy(pdf2)

pdf6.ncfile.name = infile2;
pdf6.xlist = 'press';
pdf6.ylist = 'fluor transmittance oxygen potemp psal';
pdf6.cols = 'cmbkr';
pdf6.startdc = datevec(dntstart);
pdf6.stopdc = datevec(dntend);
pdf6.plotsize = [18 14];
mplotxy(pdf6)

pdf.ncfile.name = infile2;
pdf.xlist = 'time';
pdf.ylist = 'fluor transmittance press oxygen potemp psal';
pdf.cols = 'cmgbkr';
pdf.time_scale = 2;
pdf.startdc = datevec(dntstart);
pdf.stopdc = datevec(dntend);
pdf.plotsize = [18 14];
mplotxy(pdf)

pdf4.ncfile.name = infile2;
pdf4.xlist = 'time';
pdf4.ylist = 'oxygen potemp psal press';
pdf4.cols = 'bkrg';
pdf4.time_scale = 2;
pdf4.startdc = datevec(dntstart);
pdf4.stopdc = datevec(dntstart+4.9/1440);
pdf4.plotsize = [18 14];
mplotxy(pdf4)
