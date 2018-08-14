% msam_01b: create empty sam file from a blank template
%
% Use: msam_01b        and then respond with station number, or for station 16
%      stn = 16; msam_01b;
%
% bak jr302 13 jun 2014
%
% msam_01 is very slow when the number of empty vars is large.
% Therefore use msam_01 to make an empty file at the start of the cruise, 
% eg station number 999, then
% copy that file to eg sam_jr302_template.nc and use msam_01b
% to edit the dataname, station number and sample number.
%

scriptname = 'msam_01b';
minit
mdocshow(scriptname, ['copies empty sam_ file to sam_' mcruise '_' stn_string '.nc, editing station number']);

% resolve root directories for various file types
root_sam = mgetdir('M_SAM');

prefix1 = ['sam_' mcruise '_'];

rawfile = [root_sam '/' prefix1 'template'];
infile = [root_sam '/' prefix1 stn_string];

dataname = [prefix1 stn_string];

cmd = ['/bin/cp -p ' m_add_nc(rawfile) ' ' m_add_nc(infile)]; unix(cmd);

%--------------------------------
% 2014-06-13 14:42:29
% mheadr
% calling history, most recent first
%    mheadr in file: mheadr.m line: 49
% input files
% Filename sam_jr302_998.nc   Data Name :  sam_jr302_999 <version> 2 <site> jr302_atsea
% output files
% Filename sam_jr302_998.nc   Data Name :  sam_jr302_998 <version> 1 <site> jr302_atsea
MEXEC_A.MARGS_IN = {
infile
'y'
'1'
dataname
'/'
'/'
};
mheadr
%--------------------------------


statstr = ['y = ' stn_string ' + 0 * x1'];
sampstr = ['y = 100 * x1 + x2'];

%--------------------------------
% 2014-06-13 14:47:31
% mcalib2
% calling history, most recent first
%    mcalib2 in file: mcalib2.m line: 156
% input files
% Filename sam_jr302_998.nc   Data Name :  sam_jr302_998 <version> 1 <site> jr302_atsea
% output files
% Filename sam_jr302_998.nc   Data Name :  sam_jr302_998 <version> 2 <site> jr302_atsea
MEXEC_A.MARGS_IN = {
infile
'y'
'statnum'
'statnum'
statstr
'/'
'/'
'sampnum'
'statnum position'
sampstr
' '
' '
' '
};
mcalib2
%--------------------------------

