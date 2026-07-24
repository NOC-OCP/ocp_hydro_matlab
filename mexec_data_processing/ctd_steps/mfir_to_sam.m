function mfir_to_sam(stn)
% mfir_to_sam: paste ctd fir data into sam file
%
% Use: mfir_to_sam        and then respond with station number, or for station 16
%      stn = 16; mfir_to_sam;
%
% formerly mfir_04

m_common

opt1 = 'setup'; opt2 = 'procfiles'; get_cropt
f = m_add_nc(sprintf(firfile.fir,firfile.dataname));
if ~exist(f,'file')
    warning('no bottle firing file for %s',f)
    return
end
if MEXEC_G.quiet<=1; fprintf(1,'pasting CTD data at bottle firing times from fir_%s_%s.nc to sam_%s_all.nc\n',mcruise,stn_string,mcruise); end

opt1 = 'mstar'; get_cropt
if exist(samfile,'file')
    h0 = m_read_header(samfile);
else
    clear h0
    if docf
        h0.data_time_origin = [];
    else
        h0.data_time_origin = MEXEC_G.MDEFAULT_DATA_TIME_ORIGIN;
    end
end

[d,h] = mloadq(f,'/');
d.statnum = repmat(stn,size(d.position));
d.sampnum = stn*100+d.position;
h.fldnam = [h.fldnam 'statnum' 'sampnum']; h.fldunt = [h.fldunt 'number' 'number'];
if sum(~isnan(d.sampnum))>0
    ns = size(d.sampnum);
    d.utime = m_commontime(d,'utime',h,MEXEC_G.MDEFAULT_DATA_TIME_ORIGIN);
    h.data_time_origin = h0.data_time_origin;
    %add station parameters
    d.stnlat = repmat(h.latitude,ns);
    h.fldnam = [h.fldnam 'stnlat']; h.fldunt = [h.fldunt 'degrees'];
    d.stnlon = repmat(h.longitude,ns);
    h.fldnam = [h.fldnam 'stnlon']; h.fldunt = [h.fldunt 'degrees'];
    d.stndepth = repmat(h.water_depth_metres,ns);
    h.fldnam = [h.fldnam 'stndepth']; h.fldunt = [h.fldunt 'metres'];
    h.latitude = -999; h.longitude = -999; h.water_depth_metres = -999; % sam file has multiple stations
    h.comment = sprintf('CTD data from station %03d added',stn);
    h.dataname = ['sam_' mcruise '_all'];
    MEXEC_A.Mprog = mfilename;
    mfsave(samfile, d, h, '-merge', 'sampnum');
end
