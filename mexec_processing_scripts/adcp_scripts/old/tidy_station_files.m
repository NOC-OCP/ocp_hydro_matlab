% tidy up the ladcp station files
%
% stations.asc
% latlon.asc
% mag_var.tab
%
% bak jc150 1 april 2018. NERC is no more. Hello UKRI.
%

mcruise = MEXEC_G.MSCRIPT_CRUISE_STRING;

pro = [MEXEC_G.MEXEC_DATA_ROOT '/ladcp/uh/pro/' ];
prodir = [];
[d1 d2] = system(['ls ' pro]);
% hope to get a single 6-char directory name
d2 = d2(1:end-1); % truncate the LF (ascii 10) at end of d2.
while exist(prodir,'dir') ~= 7
    while length(d2) ~= 6
    m1 = 'There was a problem identifying the 6-character name of the cruise directory';
    m2 = 'eg jc1802';
    d2 = input([m1 '\n' m2 '\nType in the name now: '],'s');
    end
ldir = d2;
prodir = [pro ldir];
d2 = [];
end

fprintf(1,'%s %s %s\n','Directory',prodir,'identified')

latlon = [MEXEC_G.MEXEC_DATA_ROOT '/ladcp/uh/pro/' ldir '/ladcp/proc/latlon.asc'];
magvar = [MEXEC_G.MEXEC_DATA_ROOT '/ladcp/uh/pro/' ldir '/ladcp/proc/mag_var.tab'];
stations = [MEXEC_G.MEXEC_DATA_ROOT '/ladcp/uh/pro/' ldir '/ladcp/proc/stations.asc'];
latlon2 = [MEXEC_G.MEXEC_DATA_ROOT '/ladcp/uh/pro/' ldir '/ladcp/proc/latlon2.asc'];
magvar2 = [MEXEC_G.MEXEC_DATA_ROOT '/ladcp/uh/pro/' ldir '/ladcp/proc/mag_var2.tab'];
stations2 = [MEXEC_G.MEXEC_DATA_ROOT '/ladcp/uh/pro/' ldir '/ladcp/proc/stations2.asc'];

%latlon

indata = load(latlon);
% 5 columns
[lls lli] = unique(indata(:,1));
otdata = indata(lli,:);

fid = fopen(latlon2,'w');
for kl = 1:length(lli)
    fprintf(fid,'%06.2f %10.6f %11.6f %9.0f %10.4f \n',otdata(kl,:));
end
fclose(fid);

%stations

indata = load(stations);
% 10 columns
[lls lli] = unique(indata(:,1));
otdata = indata(lli,:);

fid = fopen(stations2,'w');
for kl = 1:length(lli)
    fprintf(fid,'%03d %3.0f %5.2f %2d %3.0f %5.2f %2d %5d  %2d  %2d \n',otdata(kl,:));
end
fclose(fid);

%magvar

indata1 = mtextdload(magvar,',');
indata2 = mtextdload(magvar,'/'); % one element per line
% sort out the nesting of cells
tc = cell(0);
for kl = 1:length(indata1)
    tc1 = indata1{kl};
    tc2 = tc1{1};
    tc{kl} = tc2;
end
[tcsu tcsi] = unique(tc);
tcm = cell(0);

for kl = 1:length(tcsi)
    tc1 = indata2{tcsi(kl)};
    tcm{kl} = tc1{1};
end


fid = fopen(magvar2,'w');
for kl = 1:length(tcm)
    fprintf(fid,'%s\n',tcm{kl});
end
fclose(fid);

return

