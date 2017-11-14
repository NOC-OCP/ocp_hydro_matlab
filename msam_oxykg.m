% msam_oxykg: convert from umol/L to umol/kg using draw temperature and (ideally, calibrated) ctd salinity
%
% Use: msam_oxykg        and then respond with station number, or for station 16
%      stn = 16; msam_oxykg;

scriptname = 'msam_oxykg';
cruise = MEXEC_G.MSCRIPT_CRUISE_STRING;

if ~exist('stn','var')
    stn = input('type stn number ');
end
stn_string = sprintf('%03d',stn);
stnlocal = stn; clear stn % so that it doesn't persist

mdocshow(scriptname, ['converts bottle oxygen from umol/L to umol/kg in sam_' cruise '_' stn_string '.nc']);

root_ctd = mgetdir('M_CTD');

prefix1 = ['sam_' cruise '_'];

infile1 = [root_ctd '/' prefix1 stn_string ];

wkfile1 = ['wk1_' scriptname '_' datestr(now,30)];
wkfile2 = ['wk2_' scriptname '_' datestr(now,30)];
wkfile3 = ['wk3_' scriptname '_' datestr(now,30)];


%--------------------------------
% 2010-02-04 16:15:27
% mcalib2
MEXEC_A.MARGS_IN = {
infile1
'y'
'botoxyden'
'uasal botoxytemp '
'y = gsw_rho_CT(x1,gsw_CT_from_t(x1,x2,0),0);'
' '
'kg/m3'
' '
};
mcalib2
%--------------------------------

%--------------------------------
% 2010-02-04 16:17:04
% mcalib2
MEXEC_A.MARGS_IN = {
infile1
'y'
'botoxy'
'botoxy_per_l botoxyden'
'y = x1./(x2/1000);'
' '
'umol/kg'
' '
};
mcalib2
%--------------------------------
