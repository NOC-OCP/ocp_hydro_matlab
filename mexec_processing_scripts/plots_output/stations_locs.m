% stations: read water depth for ctd cast from ldeo ladcp or combined
% altimeter and depth readings
%
% Use: stations        and then respond with station number, or for station 16
%      stn = 16; stations;

scriptname = 'stations';

% resolve root directories for various file types
root_sal = mgetdir('M_CTD');
root_ctd = mgetdir('M_CTD');

stnlist=1:11;
otdata=ones(3,length(stnlist))+nan;

prefix1 = ['dcs_' MEXEC_G.MSCRIPT_CRUISE_STRING '_'];

for k=stnlist
    infile=[root_ctd '/' prefix1 sprintf('%03d',k)];
    p=m_read_header(infile);
    otdata(1,k)=k;
    otdata(2,k)=p.latitude;
    otdata(3,k)=p.longitude;
end;

root_sum = mgetdir('M_SUM');
fid = fopen([root_sum '/stations_locs.dat'],'wt');
fprintf(fid,'%03d  %f %f\n',otdata);
fclose(fid);