% mtruew_01: add smoothed nav to met wind to make true wind
% where directions are in the wind vector sense (direction to)
%
% acts on appended files; requires mbest_all to have been run first to
% generate bst_cruise_01.nc


mcruise = MEXEC_G.MSCRIPT_CRUISE_STRING;

scriptname = 'ship'; oopt = 'ship_data_sys_names'; get_cropt
root_pos = mgetdir('M_POS');
root_met = mgetdir(metpre);
infilen = fullfile(root_pos, ['bst_' mcruise '_01.nc']);
infilew = fullfile(root_met, [metpre '_' mcruise '_01.nc']);
otfile1 = fullfile(root_met, [prefix1 'true']);
otfile2 = fullfile(root_met, [prefix1 'trueav']);

tave_period = 60; % seconds
tave_period = round(tave_period);
tav2 = round(tave_period/2);

[dw, hw] = mloadq(infilew, '/');
dw.timec = dw.time/3600/24+datenum(dw.data_time_origin);

filenav = [mgetdir('M_POS') '/bst_' mcruise '_01'];
[dn, hn] = mloadq(infilen, '/'); %***
dn.timec = dn.time/3600/24+datenum(hn.data_time_origin); 

% change wind input var names for later clarity
%rename ve to ship_u and vn to ship_v, but where do they come in?
%convert from compass direction relative to ship, to vector (to) direction relative to earth

speed and compass direction relative to ship to wind vector***
ws = 'relwind_speed'; if ~isfield(dw,ws); ws = 'relwind_speed_raw'; end
wd = 'relwind_dirship'; if ~isfield(dw,wd); wd = 'relwind_dirship_raw'; end
i = sqrt(-1);
dw.relwindvel = dw.(ws).*exp(i*(dw.(wd)+180)*pi/180);

%load ship heading to get , and sog and cog and get ship motion vector

dn.shipvel = dn.sog.*exp(i*(dn.cog)*pi/180); %cog should already be degrees-to

'relwind_dirship merged_heading'
'y = mcrange(180+(x1+x2),0,360)'
'relwind_direarth'
'degrees_to'

%interpolate nav onto wind times
dw.shipvel = interp1(dn.timec, dn.shipvel, dw.timec);
%and get truewind by subtracting ship motion from relative wind
d.wind_true = dw.windvel - dw.shipvel; 

%header and save
hnew.fldnam = {'wind_true'}; hnew.fldunt = {'m/s (vector)'}' %***
hnew.comment = 'vector interpolated *** bst file ***';
otfile = [infile(1:end-3) '_true.nc'];
mfsave(otfile, d, hnew, '-addvars');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


t1 = min(dw.time);
tdays = floor(t1/86400);
t1 = tdays*86400;
t1 = t1-tav2;
tavstring = [sprintf('%d',t1) ' 1e10 ' sprintf('%d',tave_period)];





%--------------------------------------------
%calculate true wind direction 
%-------------------------------------------
% add in ships gyro to relative wind direction
% multiply direction by -1 so that relwind_gyro is degrees_to
MEXEC_A.MARGS_IN = {
wkfile2
wkfile3
'/'
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
latstr = mvarname_find(lat_choices, hot1.fldnam);
if length(latstr)==0
    error('lat not found uniquely in input file; error in mtruew_01.m')
end
lon_choices = {'lon' 'long' 'longitude'}; % find any
lonstr = mvarname_find(lon_choices, hot1.fldnam);
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
latstr = mvarname_find(lat_choices, hot1.fldnam);
if length(latstr)==0
    error('lat not found uniquely in input file; error in mtruew_01.m')
end
lon_choices = {'lon' 'long' 'longitude'}; % find any
lonstr = mvarname_find(lon_choices, hot1.fldnam);
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

