% mbest_02: calculate speed, course, distrun from the 30-s averages
%
% Use: mbest_02        and then respond with day number, or for day 20
%      day = 20; mbest_02;

scriptname = 'mbest_02';
mcruise = MEXEC_G.MSCRIPT_CRUISE_STRING;

clear infile* otfile* wkfile*

%there may be a bst file in this directory but we want the other (original) one
abbrev = MEXEC_G.default_navstream;
root_dir = mgetdir(['M_' upper(abbrev)])
prefix = [abbrev '_' mcruise '_'];

mdocshow(scriptname, ['calculates speed, course, distrun from 30 s averages in ' abbrev '_' mcruise '_ave.nc, writes to ' abbrev '_' mcruise '_spd.nc']);

infile = [root_dir '/' prefix 'ave'];
otfile = [root_dir '/' prefix 'spd'];
wkfile1 = ['wk1_' scriptname '_' datestr(now,30)];
wkfile2 = ['wk2_' scriptname '_' datestr(now,30)];

if strncmp(MEXEC_G.Mshipdatasystem,'scs',3)
    latlonstr = 'lat lon';
else % techsas
    latlonstr = 'lat long';
end

MEXEC_A.MARGS_IN = {
infile
wkfile1
['time ' latlonstr]
['time ' latlonstr]
'm'
've'
'vn'
};
mposspd

MEXEC_A.MARGS_IN = {
wkfile1
wkfile2
'/'
'1'
've vn'
'smg'
' '
'cmg'
' '
};
muvsd

MEXEC_A.MARGS_IN = {
wkfile2
otfile
'/'
latlonstr
'y = m_nancumsum(sw_dist(x1,x2,''km'')); y(2:length(y)+1) = y; y(1) = 0;'
'distrun'
'km'
' '
};
mcalc

unix(['/bin/rm ' wkfile1 '.nc ' wkfile2 '.nc']);
