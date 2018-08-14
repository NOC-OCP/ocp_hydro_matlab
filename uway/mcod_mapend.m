% mcod_mapend.m
%
% gdm on di346; script to append and sort the various mstar vmadcp files into one
% sorting became necessary when vmdas files failed to batch process
% sequentially and needed to be processed separately

m_common
m_margslocal
m_varargs

scriptname='mcod_mapend';
mcruise = MEXEC_G.MSCRIPT_CRUISE_STRING;

if exist('os','var')
    m = ['Running script ' scriptname ' for OS ' sprintf('%d',os)];
    fprintf(MEXEC_A.Mfidterm,'%s\n',m)
else
    os = input('Enter OS type: 75 or 150 ');
end

if ~exist('nbb'); nbb = input('Enter narrowband (1) or broadband (2) '); end
if nbb==1; nbbstr='nb';
else; nbbstr='bb'; end

root_vmadcp = mgetdir('M_VMADCP');
cd([root_vmadcp '/' mcruise '_os' sprintf('%d',os)])
unix(['/bin/rm nc_files*']);
unix(['/bin/rm *_01.nc']);
unix(['ls -1 ' mcruise '*' nbbstr(1) 'benx/*_spd.nc > nc_files']);

wkfile = ['wk_' datestr(now,30)];
otfile = ['os' sprintf('%d',os) '_' mcruise nbbstr(1) 'nx_01'];
clear os    % To be able to run the script with another OS type right away. CFL

%--------------------------------
% 2010-01-16 10:35:31
% mapend
MEXEC_A.MARGS_IN = {
wkfile
otfile
'f'
'nc_files'
'/'
'/'
};
mapend
%--------------------------------

%--------------------------------
% 2010-01-17 07:47:07
% msort
% calling history, most recent first
%    msort in file: msort.m line: 163
% input files
% Filename wkfile.nc   Data Name :  os75_di346nnx_01 <version> 6 <site> di346_atsea
% output files
% Filename os75_di346nnx_01.nc   Data Name :  os75_di346nnx_01 <version> 9 <site> di346_atsea
MEXEC_A.MARGS_IN = {
wkfile
otfile
'time'
'c'
};
msort
%--------------------------------

unix(['/bin/rm ' wkfile '.nc']);

