function d = quick_scs

date_string = datestr(now,'yyyymmdd');
day_num = sprintf('%3.3i',datenum(floor(now))-datenum(2023,01,01)+1);
fprintf(1,' ** quick_scs is fetching latest dat for day %s \n',date_string)

nget_lines = 5000;
nday_lines  = floor(86400*(now-floor(now))-400);
if nday_lines < nget_lines
	nget_lines = nday_lines
	disp(' It is early in the mornig and this program (quick_scs)')
	disp(' is not capable of getting data from yesterday')
	disp(' hope that is ok?')
end
% date_string = '20230719'
% day_num = '200'
% nget_lines = 5000
fnin = ['/mnt/cruisedata/scs/proc/Daily/Data1Sec_Daily_' date_string '-000000.csv'];
% fnin = '/mnt/en705data/scs/proc/Daily/Data1Sec_Daily_20230227-000000.csv';
ftem = ['/local/users/pstar/projects/rpdmoc/en705/mcruise/data/scs/quick_scs/en705_d' day_num '_temp.csv'];
%ftem = '/local/users/pstar/projects/rpdmoc/en705/mcruise/data/quick_scs/en705_d058_temp.csv';
cmd_str = ['\rm ' ftem];  % in cse previous crash left an old file
[status,cmdout] = system(cmd_str);
fnot = ['/local/users/pstar/projects/rpdmoc/en705/mcruise/data/scs/quick_scs/en705_d' day_num '.mat'];
%fnot = '/local/users/pstar/projects/rpdmoc/en705/mcruise/data/quick_scs/en705_d058.mat';

cmd_str = ['head -133 ' fnin ' > ' ftem];
[status,cmdout] = system(cmd_str);
cmd_str = sprintf('tail -%i %s >> %s',nget_lines,fnin,ftem);
[status,cmdout] = system(cmd_str);

fid=fopen(ftem);
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

d.dnum = nan(nlines-n1,1); % on en705 there are 132 lines of comment, line 133 is header, line 134 has data; n1 = 133
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
    s.watdep = tt(kc(58)+1:kc(59)-1); % 59
    s.lat = tt(kc(4)+1:kc(5)-1); % 5
    s.lon = tt(kc(5)+1:kc(6)-1); % 6
    s.gyr = tt(kc(39)+1:kc(40)-1); % 40
	s.speedfa = tt(kc(65)+1:kc(66)-1); % 66
    s.speedps = tt(kc(66)+1:kc(67)-1); % 67
    d.dnum(kl) = datenum(s.date(1:20),'"yyyy-mm-ddTHH:MM:SS');
    d.watdep(kl) = str2double(s.watdep);
    d.lat(kl) = str2double(s.lat);
    d.lon(kl) = str2double(s.lon);
    d.gyr(kl) = str2double(s.gyr);
    d.speedfa(kl) = str2double(s.speedfa);
    d.speedps(kl) = str2double(s.speedps);
end

save(fnot,'d');

cmd_str = ['\rm ' ftem];
[status,cmdout] = system(cmd_str);

