% moxy_02: paste oxy data into sam file
%
% modified to input bottle oxygen data to variable 'botoxy_per_l' from
% station 98 onwards.  msam_oxykg should be run afterwards to calculate
% bottle oxygen in umol/kg.  CPA 6/2/10

minit; scriptname = mfilename;
mdocshow(scriptname, ['pastes bottle oxygen from oxy_' mcruise '_' stn_string '.nc to sam_' mcruise '_' stn_string '.nc']);

root_oxy = mgetdir('M_BOT_OXY');
root_ctd = mgetdir('M_CTD');

prefix1 = ['oxy_' mcruise '_'];
prefix2 = ['sam_' mcruise '_'];

infile1 = [root_oxy '/' prefix1 stn_string];

if exist([infile1 '.nc'])

otfile2 = [root_ctd '/' prefix2 stn_string];

% bak on jr302 19 jun 2014 some stations don't have any oxy data; exit
% gracefully

if exist(m_add_nc(infile1),'file')~=2;
    mess = ['File ' m_add_nc(infile1) ' not found'];
    fprintf(MEXEC_A.Mfider,'%s\n',mess)
    return
end

    MEXEC_A.MARGS_IN = {
        otfile2
        infile1
        'y'
        'sampnum'
        'sampnum'
        'botoxya_per_l botoxyflaga botoxytempa botoxyb_per_l botoxyflagb botoxytempb'
        'botoxya_per_l botoxyflaga botoxytempa botoxyb_per_l botoxyflagb botoxytempb'
        };
    mpaste

end
