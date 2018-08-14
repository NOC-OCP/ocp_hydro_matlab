% mbest_01: create 30-second nav file from 1-Hz positions
%
% Use: mbest_01        and then respond with day number, or for day 20
%      day = 20; mbest_01;

scriptname = 'mbest_01';
mcruise = MEXEC_G.MSCRIPT_CRUISE_STRING;

clear infile* otfile* wkfile*

%start with the original data in the same directory
abbrev = MEXEC_G.default_navstream;
root_dir = mgetdir(['M_' upper(abbrev)])
prefix = [abbrev '_' mcruise '_'];

mdocshow(scriptname, ['average 1-Hz navigation stream from ' abbrev '_' mcruise '_01.nc to 30 s in ' abbrev '_' mcruise '_ave.nc']);

infile = [root_dir '/' prefix '01'];
otfile = [root_dir '/' prefix 'ave'];
wkfile = ['wk_' scriptname '_' datestr(now,30)];

tave_period = 30; % seconds
tav2 = round(tave_period/2);

[d h] = mload(infile,'time',' ');

t1 = min(d.time);
tdays = floor(t1/86400);
t1 = tdays*86400;
t1 = t1-tav2;
tavstring = [sprintf('%d',t1) ' 1e10 ' sprintf('%d',tave_period)];

if strncmp(MEXEC_G.Mshipdatasystem,'scs',3)
    latlonstr = 'time lat lon';
else % techsas
    latlonstr = 'time lat long';
end

MEXEC_A.MARGS_IN = {
infile
wkfile
latlonstr
' '
' '
' '
};
mcopya


MEXEC_A.MARGS_IN = {
wkfile
otfile
'/'
'time'
tavstring
'b'
};
msmoothnav

unix(['/bin/rm ' wkfile '.nc']);
