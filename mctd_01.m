% mctd_01: read in ctd data from .cnv file to _raw.nc
%
% Use: mctd_01        and then respond with station number, or for station 16
%      stn = 16; mctd_01;

minit; scriptname = mfilename;
mdocshow(scriptname, ['converts from .cnv to ctd_' mcruise '_' stn_string '_raw.nc']);

% resolve root directories for various file types
root_cnv = mgetdir('M_CTD_CNV');
root_ctd = mgetdir('M_CTD'); % change working directory

prefix = ['ctd_' mcruise '_'];

oopt = 'redoctm'; get_cropt
if ~redoctm %default: operate on file which had the cell thermal mass correction applied in SBE Processing
   infile = [root_cnv '/' prefix stn_string '_align_ctm.cnv'];
   otfile = [root_ctd '/' prefix stn_string '_raw'];
else %in some cases, operate on pre-CTM file (to remove large spikes), then apply CTM in mexec
   infile = [root_cnv '/' prefix stn_string '_align_noctm.cnv'];
   otfile = [root_ctd '/' prefix stn_string '_raw_noctm'];
   disp('starting from noctm file')
end


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
MEXEC_A.MARGS_IN = {
infile
'y'
'y'
otfile
};
msbe_to_mstar;
%--------------------------------

%--------------------------------
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
