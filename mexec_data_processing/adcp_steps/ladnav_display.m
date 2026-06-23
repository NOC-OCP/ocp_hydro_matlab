% display time and nav infor for ladcp laptop
% bak jr302

dnow = now;

posdata = mslast('seatex-gll');

dnum = posdata.time;

tdiffsecs = 86400*(dnow-dnum);

if tdiffsecs > 20
    m = 'There is a problem with the time in the datastreams. Exiting.';
    fprintf(1,'%s\n',m)
    return
end

dv = datevec(dnum);

yyyy = dv(1);

torg = datenum([yyyy 1 1 0 0 0]);

daynum = 1+floor(dnum-torg);

m = 'Date and time of most recent position follows (time is a few seconds old)';
fprintf(1,'\n%s\n\n',m)

m = ['Day number  ' sprintf('%03d',daynum)];
fprintf(1,'\n%s\n',m)

m = ['Date        ' sprintf('%4d/%02d/%02d',dv(1:3))];
fprintf(1,'\n%s\n',m)

m = ['Time          ' sprintf('%02d:%02d:%02d',round(dv(4:6)))];
fprintf(1,'%s\n',m)

[latd latm] = m_degmin_from_decdeg(posdata.seatex_gll_lat);
m = ['Lat         ' sprintf('%4d %6.3f',latd,latm)];
fprintf(1,'\n%s\n',m)

[lond lonm] = m_degmin_from_decdeg(posdata.seatex_gll_lon);
m = ['Lon         ' sprintf('%4d %6.3f',lond,lonm)];
fprintf(1,'%s\n',m)


