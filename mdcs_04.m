% mdcs_04: merge positions onto ctd start bottom end times
%
% Use: mdcs_04        and then respond with station number, or for station 16
%      stn = 16; mdcs_04;

scriptname = 'mdcs_04';
cruise = MEXEC_G.MSCRIPT_CRUISE_STRING;

if ~exist('stn','var')
    stn = input('type stn number ');
end
stn_string = sprintf('%03d',stn);
stnlocal = stn; clear stn % so that it doesn't persist

mdocshow(scriptname, ['adds positions from concatenated best ship navigation file pos_' cruise '_01.nc to dcs_' cruise '_' stn_string '_pos.nc']);

% resolve root directories for various file types
root_gps = mgetdir('M_POS');
root_ctd = mgetdir('M_CTD');

prefix1 = ['dcs_' cruise '_'];
prefix2 = ['bst_' cruise '_'];

infile1 = [root_ctd '/' prefix1 stn_string];
infile2 = [root_gps '/' prefix2 '01'];   % this is supposed to be the nav file.
wkfile2 = ['wk2_' scriptname '_' datestr(now,30)];
wkfile3 = ['wk3_' scriptname '_' datestr(now,30)];
otfile4 = [root_ctd '/' prefix1 stn_string '_pos'];

% bak on jr281 april 2013
% trap case where this station number doesnt exist
if(exist(m_add_nc(infile1),'file') ~= 2); 
    msg = ['File ' m_add_nc(infile1) ' not found'];
    fprintf(2,'%s\n',msg);
    return; 
end

latname = 'lat';
%lonname = 'lon';
% lonname = 'long'; % for D344
% fix by bak aug 2010
if strncmp(MEXEC_G.Mshipdatasystem,'scs',3)
    lonname = 'lon';
else % techsas
    lonname = 'long';
end

%--------------------------------
% 2009-01-28 17:02:58
% mmerge
% input files
% Filename dcs_jr193_016.nc   Data Name :  dcs_jr193_016 <version> 14 <site> bak_macbook
% Filename gps_jr193_01.nc   Data Name :  193gps01 <version> 20 <site> pexec_jc
% output files
% Filename dcs_jr193_016_pos.nc   Data Name :  dcs_jr193_016 <version> 15 <site> bak_macbook
MEXEC_A.MARGS_IN = {
wkfile2
infile1
'/'
'time_start'
infile2
'time'
[latname ' ' lonname]
'f'
};
mmerge
%--------------------------------

%--------------------------------
% 2009-01-26 07:48:13
% mheadr
% input files
% Filename ctd_jr193_016_24hz.nc   Data Name :  sbe_ctd_rawdata <version> 51 <site> bak_macbook
% output files
% Filename ctd_jr193_016_24hz.nc   Data Name :  ctd_jr193_016 <version> 12 <site> bak_macbook
MEXEC_A.MARGS_IN = {
wkfile2
'y'
'8'
latname
'lat_start'
'degrees'
lonname
'lon_start'
'degrees'
'-1'
'-1'
};
mheadr
%--------------------------------

%--------------------------------
% 2009-01-28 17:02:58
% mmerge
% input files
% Filename dcs_jr193_016.nc   Data Name :  dcs_jr193_016 <version> 14 <site> bak_macbook
% Filename gps_jr193_01.nc   Data Name :  193gps01 <version> 20 <site> pexec_jc
% output files
% Filename dcs_jr193_016_pos.nc   Data Name :  dcs_jr193_016 <version> 15 <site> bak_macbook
MEXEC_A.MARGS_IN = {
wkfile3
wkfile2
'/'
'time_bot'
infile2
'time'
[latname ' ' lonname]
'f'
};
mmerge
%--------------------------------

%--------------------------------
% 2009-01-26 07:48:13
% mheadr
% input files
% Filename ctd_jr193_016_24hz.nc   Data Name :  sbe_ctd_rawdata <version> 51 <site> bak_macbook
% output files
% Filename ctd_jr193_016_24hz.nc   Data Name :  ctd_jr193_016 <version> 12 <site> bak_macbook
MEXEC_A.MARGS_IN = {
wkfile3
'y'
'8'
latname
'lat_bot'
'degrees'
lonname
'lon_bot'
'degrees'
'-1'
'-1'
};
mheadr
%--------------------------------

%--------------------------------
% 2009-01-28 17:02:58
% mmerge
% input files
% Filename dcs_jr193_016.nc   Data Name :  dcs_jr193_016 <version> 14 <site> bak_macbook
% Filename gps_jr193_01.nc   Data Name :  193gps01 <version> 20 <site> pexec_jc
% output files
% Filename dcs_jr193_016_pos.nc   Data Name :  dcs_jr193_016 <version> 15 <site> bak_macbook
MEXEC_A.MARGS_IN = {
otfile4
wkfile3
'/'
'time_end'
infile2
'time'
[latname ' ' lonname]
'f'
};
mmerge
%--------------------------------

%--------------------------------
% 2009-01-28 17:10:47
% mheadr
% input files
% Filename dcs_jr193_016_pos.nc   Data Name :  dcs_jr193_016 <version> 20 <site> bak_macbook
% output files
% Filename dcs_jr193_016_pos.nc   Data Name :  dcs_jr193_016 <version> 21 <site> bak_macbook
MEXEC_A.MARGS_IN = {
otfile4
'y'
'8'
latname
'lat_end'
'degrees'
lonname
'lon_end'
'degrees'
'-1'
'-1'
};
mheadr
%--------------------------------

unix(['/bin/rm ' wkfile2 '.nc ' wkfile3 '.nc'])

% need code for continuous updating nav file for merging
% better this than to use posinfo which needs to be linked to data files
% do something like updatesm but stores output in mstar files,
% so easier to control updates

% eg on jruj
% #
% source .cshrc > /dev/null
% source .login > /dev/null
% cd $P_CTD
% pwd
% dfinfo -l gps_nmea

% also, construct datapup commands to run remotely on cook3.


