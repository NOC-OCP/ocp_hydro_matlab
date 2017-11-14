% mcod_04
% top level function to split file into underway parts
m_common
m_margslocal
m_varargs

scriptname = 'mcod_04';
uway = 1.0;

if exist('stn1','var')
    m = ['Running script ' scriptname ' on station ' sprintf('%03d',stn1)];
    fprintf(MEXEC_A.Mfidterm,'%s\n',m)
else
    stn1 = input('type first stn number ');
end
stn1_string = sprintf('%03d',stn1);

if exist('stn2','var')
    m = ['Running script ' scriptname ' on station ' sprintf('%03d',stn2)];
    fprintf(MEXEC_A.Mfidterm,'%s\n',m)
else
    stn2 = input('type second stn number ');
end
stn2_string = sprintf('%03d',stn2);

if exist('os','var')
    m = ['Running script ' scriptname ' for OS ' sprintf('%d',os)];
    fprintf(MEXEC_A.Mfidterm,'%s\n',m)
else
    os = input('Enter OS type: 75 or 150 ');
end

mcd vmadcp
cmd=['cd ' MEXEC_G.MSCRIPT_CRUISE_STRING '_os' sprintf('%d',os)];eval(cmd);

infile=['os' sprintf('%d',os) '_' MEXEC_G.MSCRIPT_CRUISE_STRING 'nnx_01'];

wkfile = ['wk_' datestr(now,30)];

% construct output filename by removing last token
% delimited by '_'
otfile = fliplr(infile);
[atok,otfile] = strtok(otfile,'_');
otfile = fliplr(otfile);
otfile = [otfile  sprintf('stn%3.3d_to_stn%3.3d',stn1,stn2)];

%--------------------------------

[d1,d2] = station_range(stn1);
[e1,e2] = station_range(stn2);
[b1,b2] = m_info_var(infile,'time','range');
fmt1 = 'datafile: %12.2f to %12.2f\n';
fmt2 = 'passage : %12.2f to %12.2f\n';
fprintf([fmt1 fmt2],b1,b2,d2,e1);

if d2 < b1 | e1 > b2
  m = 'station not wholly contained in data file';
  error(m);
end
[r1,c1] = m_info_var(infile,'time',{'first-greater' d2});
[r2,c2] = m_info_var(infile,'time',{'last-less' e1});

grange = [num2str(c1) ' ' num2str(c2)]

%--------------------------------
% copy out part between the two stations in time

MEXEC_A.MARGS_IN = {
infile
wkfile
'/'
' '
' '
grange
' '
' '
};
mcopya

%--------------------------------

[r1,c1] = m_info_var(wkfile,'shipspd',{'first-greater' uway});
[r2,c2] = m_info_var(wkfile,'shipspd',{'last-greater' uway});

grange = [num2str(c1) ' ' num2str(c2)];

%--------------------------------
% copy out central part where shipspeed is greater than uway

MEXEC_A.MARGS_IN = {
wkfile
otfile
'/'
' '
' '
grange
' '
' '
};
mcopya

%--------------------------------

%--------------------------------
% gdm on di346 edited to fix up the dataname for the new variable 
%--------------------------------
% 2010-01-17 06:20:25
% mheadr
% calling history, most recent first
%    mheadr in file: mheadr.m line: 49
% input files
% Filename os75_di346nnx_007.nc   Data Name :  os75_di346nnx_01 <version> 7 <site> di346_atsea
% output files
% Filename os75_di346nnx_007.nc   Data Name :  os75_di346nnx_007 <version> 1 <site> di346_atsea

MEXEC_A.MARGS_IN = {
otfile
'y'
'1'
otfile
' '
' '
};
mheadr
%--------------------------------

unix(['/bin/rm ' wkfile '.nc']);
clear stn1 stn2 os
