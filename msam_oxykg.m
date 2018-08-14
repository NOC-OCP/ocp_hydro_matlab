% msam_oxykg: convert from umol/L to umol/kg using draw temperature and (ideally, calibrated) ctd salinity
%
% Use: msam_oxykg        and then respond with station number, or for station 16
%      stn = 16; msam_oxykg;

scriptname = 'msam_oxykg';
minit
mdocshow(scriptname, ['converts bottle oxygen from umol/L to umol/kg in sam_' mcruise '_' stn_string '.nc']);

root_ctd = mgetdir('M_CTD');
prefix1 = ['sam_' mcruise '_'];
infile1 = [root_ctd '/' prefix1 stn_string ];
wkfile1 = ['wk1_' scriptname '_' datestr(now,30)];

% compute density and botoxy (umol/kg) from botoxy_per_l (umol/L)
% do this in one step because i think it's faster to compute (CT and) density twice than to access the file twice

MEXEC_A.MARGS_IN = {
infile1
'y'
'botoxydena'
'uasal botoxytempa '
'y = gsw_rho_CT(x1,gsw_CT_from_t(x1,x2,0),0);'
' '
'kg/m3'
'botoxydenb'
'uasal botoxytempb '
'y = gsw_rho_CT(x1,gsw_CT_from_t(x1,x2,0),0);'
' '
'kg/m3'
'botoxya'
'botoxya_per_l uasal botoxytempa'
'y = x1./(gsw_rho_CT(x2,gsw_CT_from_t(x2,x3,0),0)/1000);'
' '
'umol/kg'
'botoxyb'
'botoxyb_per_l uasal botoxytempb'
'y = x1./(gsw_rho_CT(x2,gsw_CT_from_t(x2,x3,0),0)/1000);'
' '
'umol/kg'
' '
};
mcalib2

%copy to botoxy_per_l, botoxy, botoxyden botoxyflag
oopt = 'oxyab'; get_cropt %sets iib, indices at which to use botoxy*b rather than botoxy*a
MEXEC_A.MARGS_IN = {
infile1
'y'
'botoxy_per_l'
'botoxya_per_l botoxyb_per_l'
sprintf('y = x1; y(%s) = x2(%s);', iib, iib)
' '
'umol/L'
'botoxy'
'botoxya botoxyb'
sprintf('y = x1; y(%s) = x2(%s);', iib, iib)
' '
'umol/kg'
'botoxyden'
'botoxydena botoxydenb'
sprintf('y = x1; y(%s) = x2(%s);', iib, iib)
' '
'kg/m^3'
'botoxyflag'
'botoxyflaga botoxyflagb'
sprintf('y = x1; y(%s) = x2(%s);', iib, iib)
' '
' '
' '
};
mcalib2
