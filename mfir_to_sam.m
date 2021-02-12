% mfir_to_sam: paste ctd fir data into sam file
%
% Use: mfir_to_sam        and then respond with station number, or for station 16
%      stn = 16; mfir_to_sam;
%
% formerly mfir_04

minit; 
mdocshow(mfilename, ['pastes CTD data at bottle firing times from fir_' mcruise '_' stn_string '.nc to sam_' mcruise '_all.nc']);

root_ctd = mgetdir('M_CTD'); % change working directory
infile = [root_ctd '/fir_' mcruise '_' stn_string '_ctd'];
otfile = [root_ctd '/sam_' mcruise '_all'];

if exist(m_add_nc(infile),'file') == 2
    [d,h] = mloadq(infile,'/');
    d.sampnum = stnlocal*100+d.position;
    h.fldnam = ['sampnum' h.fldnam]; h.fldunt = ['number' h.fldunt];
    if sum(~isnan(d.sampnum))>0
        h.comment = []; % BAK fixing comment problem: Don't pass in this comment string
        mfsave(otfile, d, h, '-merge', 'sampnum');
    end
end
