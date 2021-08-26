% mfir_to_sam: paste ctd fir data into sam file
%
% Use: mfir_to_sam        and then respond with station number, or for station 16
%      stn = 16; mfir_to_sam;
%
% formerly mfir_04

scriptname = 'castpars'; oopt = 'minit'; get_cropt
mdocshow(mfilename, ['pastes CTD data at bottle firing times from fir_' mcruise '_' stn_string '.nc to sam_' mcruise '_all.nc']);

root_ctd = mgetdir('M_CTD'); % change working directory
infile = fullfile(root_ctd, ['fir_' mcruise '_' stn_string]);
otfile = fullfile(root_ctd, ['sam_' mcruise '_all']);

if exist(m_add_nc(infile),'file') == 2
    [d,h] = mloadq(infile,'/');
    d.sampnum = stnlocal*100+d.position;
    h.fldnam = ['sampnum' h.fldnam]; h.fldunt = ['number' h.fldunt];
    if sum(~isnan(d.sampnum))>0
        h.comment = []; % BAK fixing comment problem: Don't pass in this comment string
        MEXEC_A.Mprog = mfilename;
        mfsave(otfile, d, h, '-merge', 'sampnum');
    end
end
