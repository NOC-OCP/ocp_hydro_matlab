% scvript to calculate ships speed
% and expand 1D arrays into 2D
scriptname='mcod_02';
mcruise = MEXEC_G.MSCRIPT_CRUISE_STRING;

if exist('fl','var')
    m = ['Running script ' scriptname ' on station ' fl];
    fprintf(MEXEC_A.Mfidterm,'%s\n',m)
else
  fl = input('type file number ');
    fl=sprintf('%03d',fl);
end

if exist('os','var')
    m = ['Running script ' scriptname ' for OS ' sprintf('%d',os)];
    fprintf(MEXEC_A.Mfidterm,'%s\n',m)
else
    os = input('Enter OS type: 75 or 150 ');
end
inst=['os' sprintf('%d',os)];

if ~exist('nbb'); nbb = input('Enter narrowband (1) or broadband (2) '); end
if nbb==1; nbbstr='nb';
else; nbbstr='bb'; end

if ~exist('seqdbname'); seqdbname = [mcruise fl]; end
sdbname = [seqdbname nbbstr(1) 'nx'];

root_vmadcp = mgetdir('M_VMADCP');
cd([root_vmadcp '/' mcruise '_os' sprintf('%d',os)])
enxdir = [seqdbname nbbstr 'enx'];
if exist(enxdir,'dir') ~= 7; return; end
cmd=['cd ' enxdir]; eval(cmd);
%normally this:
infile = [inst '_' sdbname]; %might be different for bottom track files
wkfile = ['wk_' datestr(now,30)];
otfile = [infile '_spd'];
clear fl os; % so it doesn't persist

%--------------------------------

MEXEC_A.MARGS_IN = {
infile
wkfile
'uabs vabs/'
'time uabs'
'y=repmat(x1(1,1:end),size(x2,1),1)'
' '
' '
'lon uabs'
'y=repmat(x1(1,1:end),size(x2,1),1)'
' '
' '
'lat uabs'
'y=repmat(x1(1,1:end),size(x2,1),1)'
' '
' '
'uship uabs'
'y=repmat(x1(1,1:end),size(x2,1),1)'
' '
' '
'vship uabs'
'y=repmat(x1(1,1:end),size(x2,1),1)'
' '
' '
'depth uabs'
'y=repmat(x1(1:end,1),1,size(x2,2))'
' '
' '
'decday uabs'
'y=repmat(x1(1,1:end),size(x2,1),1)'
' '
' '
' '
};
mcalc

%--------------------------------
MEXEC_A.MARGS_IN = {
wkfile
otfile
'/'
'uabs vabs'
'y=sqrt(x1.*x1+x2.*x2)'
'speed'
' '
'uship vship'
'y=sqrt(x1.*x1+x2.*x2)'
'shipspd'
' '
' '
};
mcalc

%--------------------------------

cmd = ['/bin/rm ' wkfile '.nc']; unix(cmd);
