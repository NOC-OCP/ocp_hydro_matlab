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

if exist(otfile,'file')
    h0 = m_read_header(otfile);
else
    clear h0; h0.data_time_origin = MEXEC_G.MDEFAULT_DATA_TIME_ORIGIN;
end

if exist(m_add_nc(infile),'file') == 2
    [d,h] = mloadq(infile,'/');
    d.statnum = repmat(stnlocal,size(d.position));
    d.sampnum = stnlocal*100+d.position;
    h.fldnam = ['statnum' 'sampnum' h.fldnam]; h.fldunt = ['number' 'number' h.fldunt];
    if sum(~isnan(d.sampnum))>0
        d.utime = m_commontime(d.utime,h.data_time_origin,h0.data_time_origin);
        h.data_time_origin = h0.data_time_origin;
        h.comment = []; % BAK fixing comment problem: Don't pass in this comment string
        MEXEC_A.Mprog = mfilename;
        mfsave(otfile, d, h, '-merge', 'sampnum');
    end
end
