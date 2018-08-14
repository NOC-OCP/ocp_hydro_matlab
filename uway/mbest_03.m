% mbest_03: create 30-second heading file from 1-Hz positions
%
% Use: mbest_03        and then respond with day number, or for day 20
%      day = 20; mbest_03;
% 2011 09 06 It has been added the Seapath heading (attsea) instead of
% gyros for James Cook cruises due its better accuracy. CFL/GDM

scriptname = 'mbest_03';
mcruise = MEXEC_G.MSCRIPT_CRUISE_STRING;
oopt = '';

clear infile* otfile* wkfile*

abbrev = MEXEC_G.default_hedstream;
root_dir = mgetdir(['M_' upper(abbrev)])
prefix = [abbrev '_' mcruise '_'];

mdocshow(scriptname, ['average 1-Hz navigation stream from ' abbrev '_' mcruise '_01.nc to 30 s in ' abbrev '_' mcruise '_ave.nc']);

infile = [root_dir '/' prefix '01'];
otfile = [root_dir '/' prefix 'ave'];

wkfile1 = ['wk1_' scriptname '_' datestr(now,30)];
wkfile2 = ['wk2_' scriptname '_' datestr(now,30)];
wkfile3 = ['wk3_' scriptname '_' datestr(now,30)];

tave_period = 30; % seconds
tave_period = round(tave_period);
tav2 = round(tave_period/2);

[d h] = mload(infile, 'time', ' ');

if strncmp(abbrev, 'gyro', 4); headstr = 'head_gyr'; elseif strcmp(MEXEC_G.Mship,'jcr'); headstr = 'heading'; else; headstr = 'head'; end

t1 = min(d.time);
tdays = floor(t1/86400);
t1 = tdays*86400;
% t1 = t1-tav2;
t1 = t1; % unlike positions files, make gyro average be vector average of period ending on final timestamp, not centered on timestamp.
tavstring = [sprintf('%d',t1) ' 1e10 ' sprintf('%d',tave_period)];
toffstring = ['y = x + ' sprintf('%d',tav2)];

MEXEC_A.MARGS_IN = {
    infile
    wkfile1
    '/'
    [headstr ' ' headstr]
    'y = 1+x1-x2'
    'dummy'
    'none'
    ' '
    };
mcalc

MEXEC_A.MARGS_IN = {
    wkfile1
    wkfile2
    '/'
    '2'
    ['dummy ' headstr]
    'dum_e'
    ' '
    'dum_n'
    ' '
    };
muvsd

MEXEC_A.MARGS_IN = {
wkfile2
wkfile3
'/'
'1'
tavstring
'b'
};
mavrge

MEXEC_A.MARGS_IN = {
wkfile3
otfile
'time'
'1'
'dum_e dum_n'
'dumspd'
' '
'heading_av'
' '
};
muvsd

MEXEC_A.MARGS_IN = {
otfile
'y'
'time'
toffstring
' '
' '
' '
};
mcalib

unix(['/bin/rm ' wkfile1 '.nc ' wkfile2 '.nc ' wkfile3 '.nc']);
