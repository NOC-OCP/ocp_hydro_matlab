function mfir_to_sam(stn)
% mfir_to_sam: paste ctd fir data into sam file
%
% Use: mfir_to_sam        and then respond with station number, or for station 16
%      stn = 16; mfir_to_sam;
%
% formerly mfir_04

m_common
opt1 = 'setup'; opt2 = 'mstar'; run(MEXEC_G.opt_cruise)
opt1 = 'setup'; opt2 = 'pfiles'; run(MEXEC_G.opt_cruise)
if ~exist(pfiles.ctd_nisk,'file')
    warning('no bottle firing file for %s',f)
    return
end
if MEXEC_G.quiet<=1; fprintf(1,'pasting CTD data at bottle firing times from fir_%s_%s.nc to sam_%s_all.nc\n',mcruise,stn_string,mcruise); end

if exist(pfiles.samp_ctd,'file')
    h0 = m_read_header(pfiles.samp_ctd);
    if isfield(h0,'data_time_origin') && ~isempty(h0.data_time_origin)
        tu = [h0.fldunt(strcmp('utime',h0.fldnam)) ' since ' sprintf('%d-%d-%d %d:%d:%d', h0.data_time_origin)];
    else
        tu = h0.fldunt(strcmp('utime',h0.fldnam));
    end
else
    tu = ['seconds since ' MEXEC_G.data_time_origin_string];
end

[d,h] = mloadq(pfiles.ctd_nisk,'/');
%fill in statnum and sampnum fields
sp = size(d.position);
d.statnum = repmat(stn,sp);
d.sampnum = stn*100+d.position;
h.fldnam = [h.fldnam 'statnum' 'sampnum']; h.fldunt = [h.fldunt 'number' 'number'];
if isfield(h,'fldserial')
    %move serial numbers from header (fldserial) into data vectors
    h.fldserial = [h.fldserial ' ' ' '];
    for no = 1:length(h.fldserial)
        if ~isempty(replace(h.fldserial{no},' ',''))
            d.(['sn_' h.fldnam{no}]) = repmat(str2double(h.fldserial{no}),sp);
        end
    end
else
    %for backward compatibility, parse from h.comment here? ***
end
if sum(~isnan(d.sampnum))>0
    ns = size(d.sampnum);
    d.utime = m_commontime(d, 'utime', h, tu);
    h.fldunt{strcmp('utime',h.fldnam)} = tu;
    %add station parameters
    d.stnlat = repmat(h.latitude,ns);
    h.fldnam = [h.fldnam 'stnlat']; h.fldunt = [h.fldunt 'degrees'];
    d.stnlon = repmat(h.longitude,ns);
    h.fldnam = [h.fldnam 'stnlon']; h.fldunt = [h.fldunt 'degrees'];
    d.stndepth = repmat(h.water_depth_metres,ns);
    h.fldnam = [h.fldnam 'stndepth']; h.fldunt = [h.fldunt 'metres'];
    h.latitude = -999; h.longitude = -999; h.water_depth_metres = -999; % sam file has multiple stations
    h.comment = sprintf('CTD data from station %s added',stn_string);
    h.dataname = ['sam_' MEXEC_G.mcruise '_all'];
    mfsave(pfiles.samp_ctd, d, h, '-merge', 'sampnum');
end
