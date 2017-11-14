% mctd_01: read in ctd data from .cnv file to _raw.nc
%
% Use: mctd_01        and then respond with station number, or for station 16
%      stn = 16; mctd_01;

scriptname = 'mctd_01'
cruise = MEXEC_G.MSCRIPT_CRUISE_STRING;

if ~exist('stn','var')
    stn = input('type stn number ');
end
stn_string = sprintf('%03d',stn);
stnlocal = stn; clear stn % so that it doesn't persist

mdocshow(scriptname, ['converts from .cnv to ctd_' cruise '_' stn_string '_raw.nc']);

% resolve root directories for various file types
root_cnv = mgetdir('M_CTD_CNV');
root_ctd = mgetdir('M_CTD'); % change working directory

prefix = ['ctd_' cruise '_'];

infile = [root_cnv '/' prefix  stn_string '_ctm.cnv'];

otfile = [root_ctd '/' prefix stn_string '_raw'];

dataname = [prefix stn_string];

otfile = m_add_nc(otfile);
if exist(otfile,'file')
    m = ['File' ];
    m1 = otfile ;
    m2 = ['already exists and is probably write protected'];
    m3 = ['If you want to overwrite it, you may need to delete it first'];
    fprintf(MEXEC_A.Mfider,'%s\n',m,' ',m1,' ',m2,m3)
    return
end

%--------------------------------
% 2009-01-28 12:22:39
% msbe_to_mstar
% input files
% Filename ASCII_FILES/jr193ctd_ctm016.cnv   Data Name :   <version>  <site> 
% output files
% Filename ctd_jr193_016_raw.nc   Data Name :  sbe_ctd_rawdata <version> 57 <site> bak_macbook
% 1st n is NMEA Latitude string found
% Do you want to use it in the mstar file header (y (default) or n) ? 
% NMEA Longitude string found
% Do you want to use it in the mstar file header (y (default) or n) ? 
%'n'
%'n'
MEXEC_A.MARGS_IN = {
infile
'y'
'y'
otfile
};
msbe_to_mstar;
%--------------------------------

%--------------------------------
% 2009-01-28 12:21:43
% mheadr
% input files
% Filename ctd_jr193_016_raw.nc   Data Name :  sbe_ctd_rawdata <version> 56 <site> bak_macbook
% output files
% Filename ctd_jr193_016_raw.nc   Data Name :  ctd_jr193_016 <version> 26 <site> bak_macbook
MEXEC_A.MARGS_IN = {
otfile
'y'
'1'
dataname
' '
'2'
MEXEC_G.PLATFORM_TYPE
MEXEC_G.PLATFORM_IDENTIFIER
MEXEC_G.PLATFORM_NUMBER
'/'
'8'
'-1'
'-1'
};
mheadr
%--------------------------------

% cmd = ['!cp -p ' m_add_nc(otfile) ' ' m_add_nc(otfile2)]; eval(cmd);
% cmd = ['!chmod 444 ' m_add_nc(otfile)]; eval(cmd)
