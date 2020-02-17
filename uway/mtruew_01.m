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
%
% BAK di368 edit for Discovery variable names
% GDM jc145 edit for Cook variable names
% 
% bak on jr281 23 march 2013
% apparently the di368 version was also in use on jc069.
% edited on jr281 to reflect choice of ship, so hopefully useable
% on all 3 ships.
%
% bak on jr302 july 2014: in an effort to tidy up, a collection of previous wind analysis scripts
% was moved to directory "wind_scripts_old". Hopefully this script is all
% that is needed, and can be applied on any of the ships by use of
% switches. Apologies to anyone who finds that their favourite script has
% been moved down to the "old" directory.
%
% sometime earlier than jr302 this was altered to run the entire cruise
% using the appended met file and appended nav file. Previously, the "Use"
% instruction suggested it coudl be run one day at a time.

scriptname = 'mtruew_01';

root_pos = mgetdir('M_POS');
root_met = mgetdir('M_SURFMET');
prefix1 = ['surfmet_' MEXEC_G.MSCRIPT_CRUISE_STRING '_'];
if length(root_met)==0
    root_met = mgetdir('M_ANEMOMETER'); 
    prefix1 = ['anemometer_' MEXEC_G.MSCRIPT_CRUISE_STRING '_'];
end

prefix2 = ['bst_' MEXEC_G.MSCRIPT_CRUISE_STRING '_'];

infile1 = [root_met '/' prefix1 '01'];
infile2 = [root_pos '/' prefix2 '01'];
otfile1 = [root_met '/' prefix1 'true'];
otfile2 = [root_met '/' prefix1 'trueav'];

dstring = datestr(now,30);
wkfile1 = ['wk1_' scriptname '_' dstring];
wkfile2 = ['wk2_' scriptname '_' dstring];
wkfile2a = ['wk2a_' scriptname '_' dstring];
wkfile2b = ['wk2b_' scriptname '_' dstring];
wkfile2c = ['wk2c_' scriptname '_' dstring];
wkfile3 = ['wk3_' scriptname '_' dstring];
wkfile4 = ['wk4_' scriptname '_' dstring];
wkfile5 = ['wk5_' scriptname '_' dstring];
wkfile6 = ['wk6_' scriptname '_' dstring];
wkfile7 = ['wk7_' scriptname '_' dstring];
wkfile8 = ['wk8_' scriptname '_' dstring];
wkfile9 = ['wk9_' scriptname '_' dstring];
wkfile10 = ['wk10_' scriptname '_' dstring];
wkfile11 = ['wk11_' scriptname '_' dstring];
wkfile12 = ['wk12_' scriptname '_' dstring];
wkfile13 = ['wk13_' scriptname '_' dstring];
wkfile14 = ['wk14_' scriptname '_' dstring];
wkfile15 = ['wk15_' scriptname '_' dstring];
wkfile16 = ['wk16_' scriptname '_' dstring];


tave_period = 60; % seconds
tave_period = round(tave_period);
tav2 = round(tave_period/2);

[d h] = mload(infile1,'time',' ');

t1 = min(d.time);
tdays = floor(t1/86400);
t1 = tdays*86400;
t1 = t1-tav2;
tavstring = [sprintf('%d',t1) ' 1e10 ' sprintf('%d',tave_period)];


%--------------------------------------------
% convert wind speed to m/s
%--------------------------------------------

switch MEXEC_G.Mship
    case 'cook'
        speedname = 'speed';
        speedcal = ['y = x1'];
        lon_name = 'long'; % name of longitude variable in nav file
    case 'discovery'
        speedname = 'speed';
        speedcal = ['y = x1'];% di368 speed is m/s already, even though labelled as knots in techsas. Keep this conversion step for clarity and to avoid having to change code later in this script
        lon_name = 'long';
    case 'jcr'
        %speedname = 'wind_speed';
        %speedcal = ['y = x1*1852/3600']; % knots to m/s
        speedname = 0; %YLF edited 12/2015; jcr already has wind_speed_ms
        speedcal = 0;
        lon_name = 'lon';
    otherwise
        speedname = 'speed';
        speedcal = ['y = x1'];
        lon_name = 'long';
end

MEXEC_A.MARGS_IN = {
infile1
wkfile1
'/'
speedname
% 'y = x1*1852/3600' % 'y=x1*0.512' % bim used 0.512 on jc032, but the correct answer is (BAK thinks) 0.5144444
speedcal
'wind_speed_ms'
'm/s'
' '
};

mcalc

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
wkfile1
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
switch MEXEC_G.Mship
    case {' '}%'discovery'} %***why not query for which variable is which?
        MEXEC_A.MARGS_IN = {
            wkfile2
            'y'
            '8'
            % 'direct speed wind_speed_ms ve vn'
            'speed direct wind_speed_ms ve vn' % di368, order of vars in file is speed & direction
            'relwind_spd'
            ' '
            'relwind_dirship'
            'degrees relative to ship 0 = from bow'
            'relwind_spd_ms'
            ' '
            'ship_u'
            ' '
            'ship_v'
            ' '
            '-1'
            '-1'
            };
        mheadr
    case {'cook', 'discovery'}
        MEXEC_A.MARGS_IN = {
            wkfile2
            'y'
            '8'
            'direct speed wind_speed_ms ve vn' % jc145, cook vars different
%             'speed direct wind_speed_ms ve vn' % di368, order of vars in file is speed & direction
            'relwind_dirship'
            'degrees relative to ship 0 = from bow'
            'relwind_spd'
            ' '
            'relwind_spd_ms'
            ' '
            'ship_u'
            ' '
            'ship_v'
            ' '
            '-1'
            '-1'
            };
        mheadr
    case 'jcr'
        MEXEC_A.MARGS_IN = {
            wkfile2
            'y'
            '8'
            'wind_dir wind_speed wind_speed_ms ve vn'
            'relwind_dirship'
            'degrees relative to ship 0 = from bow'
            'relwind_spd'
            ' '
            'relwind_spd_ms'
            ' '
            'ship_u'
            ' '
            'ship_v'
            ' '
            '-1'
            '-1'
            };
        mheadr
end

%--------------------------------

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
'relwind_spd_ms relwind_direarth'
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
MEXEC_A.MARGS_IN = {
otfile1
wkfile6
['time lat ' lon_name ' ship_u ship_v heading_av relwind_u relwind_v truwind_u truwind_v/']
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

MEXEC_A.MARGS_IN = {
otfile2
wkfile14
'/'
'time'
infile2
'time'
['lat ' lon_name ' distrun/']
'k'
};

mmerge

%--------------------------------

%-----------------------------------------
% clean up files
%----------------------------------------

unix(['/bin/rm wk*mtruew_01*.nc'])

