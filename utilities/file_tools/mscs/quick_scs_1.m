function d = quick_scs

fnin = '/mnt/en697data/scs/proc/Daily/Data1Sec_Daily_20230226-000000.csv';
fnot = '/local/users/pstar/projects/rpdmoc/en697/mcruise/data/quick_scs/en697_d057.mat';

fid=fopen(fnin);
tall = {};

fprintf(1,'%s\n','Starting read')
while 1
    tline = fgetl(fid);
    if ~ischar(tline), break, end
    tall = [tall {tline}];
end
fclose(fid);

nlines = length(tall);

t1 = tall{1};
kc = strfind(t1,':');

s1 = t1(kc+1:end);
n1 = str2double(s1); % first line of data

clear s d

d.dnum = nan(nlines-n1+1,1);
d.watdep = d.dnum;
d.lat = d.dnum;
d.lon = d.dnum;
d.gyr = d.dnum;
d.speedfa = d.dnum;
d.speedps = d.dnum;

fprintf(1,'%s\n','Starting parse')

for kl = 1:nlines-n1
    tt = tall{kl+n1};
    kc = strfind(tt,',');
    s.date = tt(1:kc(1)-1);
    s.watdep = tt(kc(58)+1:kc(59)-1);
    s.lat = tt(kc(4)+1:kc(5)-1); % 5
    s.lon = tt(kc(5)+1:kc(6)-1); % 6
    s.gyr = tt(kc(39)+1:kc(40)-1); % 40
	s.speedfa = tt(kc(65)+1:kc(66)-1); % 66
    s.speedps = tt(kc(66)+1:kc(67)-1); % 67
    d.dnum(kl) = datenum(s.date(1:20),'"yyyy-mm-ddTHH:MM:SS"');
    d.watdep(kl) = str2double(s.watdep);
    d.lat(kl) = str2double(s.lat);
    d.lon(kl) = str2double(s.lon);
    d.gyr(kl) = str2double(s.gyr);
    d.speedfa(kl) = str2double(s.speedfa);
    d.speedps(kl) = str2double(s.speedps);
end

save(fnot,'d');


