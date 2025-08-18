function dc = ctds_from_level(pmid, ptol, varargin)
% dc = ctds_from_level(pmid, ptol)
% dc = ctds_from_level(pmid, ptol, dday_range)
%
% get all (1hz) ctd data from a specified pressure range, optionally where
% the cast falls within a time range (otherwise from all available ctds
% from the cruise)
%
% called by mtsg_bottle_ctd_compare so extracts t, s, and fluo

m_common

[dsum,~] = mload(fullfile(mgetdir('M_SUM'),['station_summary_' mcruise '_all']),'/');
if nargin>2
    ii = find(dsum.time_start/86400>varargin{1}(1) & dsum.time_end/86400<varargin{1}(end));
    statnum = dsum.statnum(ii);
else
    statnum = dsum.statnum;
end
ns = length(statnum);

dc.dday = nan(ns,1);
dc.tctdd = dc.dday; dc.sctdd = dc.dday; dc.fctdd = dc.dday;
dc.tctdu = dc.dday; dc.sctdu = dc.dday; dc.fctdu = dc.dday;
for sno = 1:ns
    %load 1hz
    [d, h] = mload(fullfile(mgetdir('M_CTD'),sprintf('ctd_%s_%03d_psal',mcruise,statnum(sno))),'/');
    d.dday = m_commontime(d, 'time', h, ['days since ' num2str(MEXEC_G.MDEFAULT_DATA_TIME_ORIGIN(1)) '-01-01 00:00:00']);
    %limit to good data
    [ddcs, ~] = mload(fullfile(mgetdir('M_CTD'),sprintf('dcs_%s_%03d',mcruise,statnum(sno))),'/');
    ml = d.press>pmid-ptol & d.press<pmid+ptol;
    md = ml & d.scan>ddcs.scan_start & d.scan<ddcs.scan_bot;
    mu = ml & d.scan>ddcs.scan_bot & d.scan<ddcs.scan_end;
    %average
    dc.dday(sno,:) = mean(d.dday(md | mu),'omitnan');
    dc.tctdd(sno,:) = mean(d.temp(md),'omitnan');
    dc.sctdd(sno,:) = mean(d.psal(md),'omitnan');
    dc.fctdd(sno,:) = mean(d.fluor(md),'omitnan');
    dc.tctdu(sno,:) = mean(d.temp(mu),'omitnan');
    dc.sctdu(sno,:) = mean(d.psal(mu),'omitnan');
    dc.fctdu(sno,:) = mean(d.fluor(mu),'omitnan');
end
