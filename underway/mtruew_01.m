% mtruew_01: add smoothed nav to met wind to make true wind
%
% this version put together by BAK for JR195 based on bim's version for JC032
% As far as I can tell, and after discussion with bim, bim's version
% produced true wind whose direction was in the meteorological sense
% (dirn from) rather than the vector wind stress sense (direction to)
%
% Use: mtruew_01   acts on appended cruise file.
%                  Requires mbest_all to be run first to generate cruise
%                  bst_xxxxx_01.nc
%


mcruise = MEXEC_G.MSCRIPT_CRUISE_STRING;

root_pos = mgetdir('M_POS');
root_met = mgetdir('surfmet');
prefix1 = ['surfmet_' mcruise '_'];
if length(root_met)==0
    root_met = mgetdir('anemometer'); 
    prefix1 = ['anemometer_' mcruise '_'];
end

prefix2 = ['bst_' mcruise '_'];

infile1 = fullfile(root_met, [prefix1 '01']);
infile2 = fullfile(root_pos, [prefix2 '01']);
otfile1 = fullfile(root_met, [prefix1 'true']);
otfile2 = fullfile(root_met, [prefix1 'trueav']);

dstring = datestr(now,30);
wscriptname = mfilename;
wkfile2 = ['wk2_' wscriptname '_' dstring];
wkfile2a = ['wk2a_' wscriptname '_' dstring];
wkfile2b = ['wk2b_' wscriptname '_' dstring];
wkfile2c = ['wk2c_' wscriptname '_' dstring];
wkfile3 = ['wk3_' wscriptname '_' dstring];
wkfile4 = ['wk4_' wscriptname '_' dstring];
wkfile5 = ['wk5_' wscriptname '_' dstring];
wkfile6 = ['wk6_' wscriptname '_' dstring];
wkfile7 = ['wk7_' wscriptname '_' dstring];
wkfile8 = ['wk8_' wscriptname '_' dstring];
wkfile9 = ['wk9_' wscriptname '_' dstring];
wkfile10 = ['wk10_' wscriptname '_' dstring];
wkfile11 = ['wk11_' wscriptname '_' dstring];
wkfile12 = ['wk12_' wscriptname '_' dstring];
wkfile13 = ['wk13_' wscriptname '_' dstring];
wkfile14 = ['wk14_' wscriptname '_' dstring];

tave_period = 60; % seconds
tave_period = round(tave_period);
tav2 = round(tave_period/2);

[d h] = mload(infile1,'time',' ');

t1 = min(d.time);
tdays = floor(t1/86400);
t1 = tdays*86400;
t1 = t1-tav2;
tavstring = [sprintf('%d',t1) ' 1e10 ' sprintf('%d',tave_period)];

%wind should already be in m/s (update at the namesunits or fcal stage***)

% fix by bak on jr281 march 2013. old code merged on averaged heading,
% which could cause problems at 0/360. No idea how this error survived so
% long !
%--------------------------------
MEXEC_A.MARGS_IN = {
    infile2
    wkfile2a
    '/'
    'heading_av_corrected heading_av_corrected'
    'y  = 1+x1-x2'
    'unity'
    'none'
    ' '
    };
mcalc
%--------------------------------
%
MEXEC_A.MARGS_IN = {
    wkfile2a
    wkfile2b
    '/'
    '2'
    'unity heading_av'
    'headav_e'
    ' '
    'headav_n'
    ' '
    };
muvsd
% headav_e and headav_n can now be merged and averaged
%-------------------------------------------

%---------------------------------------------
% merge nav onto surfmet
%---------------------------------------------

MEXEC_A.MARGS_IN = {
wkfile2c
infile1 %  jc211 there is no longer a wkfile1 % wkfile1
'/'
'time'
wkfile2b
'time'
'/'
'k'
};
mmerge

%--------------------------------
% reconstruct ship heading after merging % part of jr281 fix
MEXEC_A.MARGS_IN = {
    wkfile2c
    wkfile2
    '/'
    '1'
    'headav_e headav_n'
    'dumspd'
    ' '
    'merged_heading'
    ' '
    };
muvsd
%--------------------------------


%--------------------------------
% change some input var names for later clarity
%
% bak jc211, all the cases replaced by the following code
hwk2 = m_read_header(wkfile2); 
relwind_speed_ms_choices = {'windspeed_raw' 'wind_speed_ms' 'relwind_spd_raw'}; % rvdas = windspeed_raw; jcr & techsas probably = wind_speed_ms;
relwind_speed_ms = varname_find(relwind_speed_ms_choices, hwk2.fldnam);
if length(relwind_speed_ms)==0
    error('windspeed raw not found uniquely in input file; error in mtruew_01.m')
end
relwind_dir_choices = {'winddirection_raw' 'direct' 'wind_dir' 'relwind_dirship_raw'}; % rvdas = winddirection_raw; jcr & techsas direct or wind_dir
relwind_dir = varname_find(relwind_dir_choices, hwk2.fldnam);
if length(relwind_dir)==0
    error('wind direction raw not found uniquely in input file; error in mtruew_01.m')
end
MEXEC_A.MARGS_IN = { % if the variables are offered in one at a time after option 8, then it doesn't matter what order they are in the data file
    wkfile2
    'y'
    '8'
    relwind_speed_ms % This is the correct variable name in rvdas, scs, techsas.
    'relwind_spd'
    ' '
    relwind_dir
    'relwind_dirship'
    'degrees relative to ship 0 = from bow'
    've'
    'ship_u'
    ' '
    'vn'
    'ship_v'
    ' '
    '-1'
    '-1'
    };
mheadr


%--------------------------------------------
%calculate true wind direction 
%-------------------------------------------
% add in ships gyro to relative wind direction
% multiply direction by -1 so that relwind_gyro is degrees_to
MEXEC_A.MARGS_IN = {
wkfile2
wkfile3
'/'
'relwind_dirship merged_heading'
'y = mcrange(180+(x1+x2),0,360)'
'relwind_direarth'
'degrees_to'
' '
};

mcalc

% split wind + Gyro into  u v components
MEXEC_A.MARGS_IN = {
wkfile3
wkfile4
'/'
'2'
'relwind_spd relwind_direarth' % 'relwind_spd_ms relwind_direarth' % on jc211
'relwind_u'
'm/s towards'
'relwind_v'
'm/s towards'
};

muvsd
%-------------------------------------------



% wind components plus the ship direction components
MEXEC_A.MARGS_IN = {
wkfile4
wkfile5
'/'
'relwind_u ship_u'
'y=x2+x1'
'truwind_u'
'm/s towards'
'relwind_v ship_v'
'y=x2+x1'
'truwind_v'
'm/s towards'
'0'
};

mcalc

%--------------------------------
% calculate truewind speed and direction full time series
MEXEC_A.MARGS_IN = {
wkfile5
otfile1
'/'
'1'
'truwind_u truwind_v'
'truwind_spd'
'm/s'
'truwind_dir'
'degrees_to'
};

muvsd
%-------------------------------------------


% Full time series now processed. Next do averaging.

%-------------------------------------------

% prepare to re-average interpolated ship heading
hot1 = m_read_header(otfile1); % find any lat or lon string; bak on jc211
lat_choices = {'lat' 'latitude'}; % find either
latstr = varname_find(lat_choices, hot1.fldnam);
if length(latstr)==0
    error('lat not found uniquely in input file; error in mtruew_01.m')
end
lon_choices = {'lon' 'long' 'longitude'}; % find any
lonstr = varname_find(lon_choices, hot1.fldnam);
if length(lonstr)==0
    error('lon not found uniquely in input file; error in mtruew_01.m')
end

MEXEC_A.MARGS_IN = {
otfile1
wkfile6
% ['time lat ' lon_name ' ship_u ship_v heading_av relwind_u relwind_v truwind_u truwind_v/']
['time ' latstr ' ' lonstr ' ship_u ship_v heading_av relwind_u relwind_v truwind_u truwind_v/'] % jc211
'heading_av heading_av'
'y = 1+x1-x2'
'dummy2'
'none'
' '
};
mcalc
%-------------------------------------------

%
MEXEC_A.MARGS_IN = {
wkfile6
wkfile7
'/'
'2'
'dummy2 heading_av'
'dum2_e'
' '
'dum2_n'
' '
};

muvsd
%-------------------------------------------

MEXEC_A.MARGS_IN = {
wkfile7
wkfile8
'/'
'time'
tavstring
'b'
};

mavrge
%--------------------------------

MEXEC_A.MARGS_IN = {
wkfile8
wkfile9
'/'
'1'
'dum2_e dum2_n'
'dumspd'
' '
'ship_hdg'
' '
};
muvsd
%--------------------------------

MEXEC_A.MARGS_IN = {
wkfile9
wkfile10
'/'
'1'
'truwind_u truwind_v'
'truwind_spd'
'm/s'
'truwind_dir'
'degrees_to'
};

muvsd
%-------------------------------------------


MEXEC_A.MARGS_IN = {
wkfile10
wkfile11
'/'
'1'
'relwind_u relwind_v'
'relwind_spd'
' '
'relwind_direarth'
'degrees_to relative to earth'
};
muvsd
%-------------------------------------------

MEXEC_A.MARGS_IN = {
wkfile11
wkfile12
'/'
'relwind_direarth ship_hdg'
'y = mcrange(x1-x2,0,360)'
'relwind_dirship'
'degrees relative to ship 0 = towards bow'
' '
};
mcalc
%-------------------------------------------
%-------------------------------------------

MEXEC_A.MARGS_IN = {
wkfile12
wkfile13
'/'
'1'
'ship_u ship_v'
'ship_spd'
' '
'ship_dir'
'degrees'
};
muvsd
%--------------------------------

%--------------------------------
%Copy subset of variables
MEXEC_A.MARGS_IN = {
wkfile13
wkfile14
'time ship_u ship_v ship_spd ship_dir ship_hdg truwind_u truwind_v truwind_spd truwind_dir relwind_u relwind_v relwind_spd relwind_direarth relwind_dirship/'
' '
' '
' '
};
mcopya
%--------------------------------

%---------------------------------------------
% re-merge navigation
hin2 = m_read_header(infile2); % find any lat or lon string; bak on jc211
lat_choices = {'lat' 'latitude'}; % find either
latstr = varname_find(lat_choices, hin2.fldnam);
if length(latstr)==0
    error('lat not found uniquely in input file; error in mtruew_01.m')
end
lon_choices = {'lon' 'long' 'longitude'}; % find any
lonstr = varname_find(lon_choices, hin2.fldnam);
if length(lonstr)==0
    error('lon not found uniquely in input file; error in mtruew_01.m')
end


MEXEC_A.MARGS_IN = {
otfile2
wkfile14
'/'
'time'
infile2
'time'
% ['lat ' lon_name ' distrun/']
[latstr ' ' lonstr ' distrun/'] % jc211
'k'
};

mmerge

%--------------------------------

%-----------------------------------------
% clean up files
%----------------------------------------

delete(['wk*' wscriptname '*.nc']);

