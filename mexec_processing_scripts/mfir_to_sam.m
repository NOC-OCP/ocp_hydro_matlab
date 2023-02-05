% mfir_to_sam: paste ctd fir data into sam file
%
% Use: mfir_to_sam        and then respond with station number, or for station 16
%      stn = 16; mfir_to_sam;
%
% formerly mfir_04

scriptname = 'castpars'; oopt = 'minit'; get_cropt
if MEXEC_G.quiet<=1; fprintf(1,'pasting CTD data at bottle firing times from fir_%s_%s.nc to sam_%s_all.nc\n',mcruise,stn_string,mcruise); end

root_ctd = mgetdir('M_CTD'); % change working directory
infile = fullfile(root_ctd, ['fir_' mcruise '_' stn_string]);
if ~exist(m_add_nc(infile), 'file')
    infile = [infile '_ctd'];
    if ~exist(m_add_nc(infile),'file')
        warning('station %s fir file not found; skipping',stn_string)
        return
    end
end
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
        ns = size(d.sampnum);
        d.utime = m_commontime(d.utime,h.data_time_origin,h0.data_time_origin);
        h.data_time_origin = h0.data_time_origin;
        %add station parameters
        d.stnlat = repmat(h.latitude,ns); 
        h.fldnam = [h.fldnam 'stnlat']; h.fldunt = [h.fldunt 'degrees'];
        d.stnlon = repmat(h.longitude,ns);
        h.fldnam = [h.fldnam 'stnlon']; h.fldunt = [h.fldunt 'degrees'];
        d.stndepth = repmat(h.water_depth_metres,ns);
        h.fldnam = [h.fldnam 'stndepth']; h.fldunt = [h.fldunt 'metres'];
        h.latitude = -999; h.longitude = -999; h.water_depth_metres = -999; % sam file has multiple stations
        h.comment = sprintf('CTD data from station %03d added',stnlocal); 
        h.dataname = ['sam_' mcruise '_all'];
        MEXEC_A.Mprog = mfilename;
        mfsave(otfile, d, h, '-merge', 'sampnum');
    end
end
