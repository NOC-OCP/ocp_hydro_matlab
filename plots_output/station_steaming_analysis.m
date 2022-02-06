% analysis of steaming and station times; bak di346

scriptname = 'station_steaming_analysis';

if exist('stn','var')
    m = ['Running script ' scriptname ' on station ' sprintf('%03d',stn)];
    fprintf(MEXEC_A.Mfidterm,'%s\n',m)
else
    stn = input('type stn number ');
end
stn_string = sprintf('%03d',stn);
stnlocal = stn;
clear stn % so that it doesn't persist


mcd('M_CTD'); % change working directory

prefix1 = ['ctd_' MEXEC_G.MSCRIPT_CRUISE_STRING '_'];
prefix2 = ['dcs_' MEXEC_G.MSCRIPT_CRUISE_STRING '_'];

infile1 = [prefix1 stn_string '_2db'];
infile2 = [prefix2 stn_string '_pos'];

[dctd hctd] = mload(infile1,'press',' ');
[ddcs hdcs] = mload(infile2,'/',' ');

if ~exist('maxp','var'); maxp = nan+ones(200,1); end
maxp(stnlocal) = max(dctd.press);

for dcsvar = {'time_start' 'time_end'};
    vv = char(dcsvar);
    if ~exist(vv,'var'); cmd = [vv ' = nan+ones(200,1);']; eval(cmd); end
    cmd = [vv '(stnlocal) = ddcs.' vv '/86400 + datenum(hdcs.data_time_origin);']; eval(cmd)
end

for dcsvar = {'lat_start' 'lat_end' 'lon_start' 'lon_end'};
    vv = char(dcsvar);
    if ~exist(vv,'var'); cmd = [vv ' = nan+ones(200,1);']; eval(cmd); end
    cmd = [vv '(stnlocal) = ddcs.' vv ';']; eval(cmd)
end

for dcsvar = {'station_duration' 'steaming_duration' 'steaming_dist'};
    vv = char(dcsvar);
    if ~exist(vv,'var'); cmd = [vv ' = nan+ones(200,1);']; eval(cmd); end
end


station_duration(stnlocal) = (time_end(stnlocal)-time_start(stnlocal));
steaming_duration(stnlocal) = (time_start(stnlocal)-time_end(stnlocal-1));
lat2 = [lat_end(stnlocal-1) lat_start(stnlocal)];
lon2 = [lon_end(stnlocal-1) lon_start(stnlocal)];
steaming_dist(stnlocal) = sw_dist(lat2,lon2,'nm');