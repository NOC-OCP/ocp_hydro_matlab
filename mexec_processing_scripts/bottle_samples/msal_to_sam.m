m_common
if MEXEC_G.quiet<1; fprintf(1, 'loading bottle salinities from sal_%s_01.nc, writing to sam_%s_all.nc',mcruise,mcruise); end

% input files
root_sal = mgetdir('M_BOT_SAL');
dataname = ['sal_' mcruise '_01'];
salfile = fullfile(root_sal, [dataname '.nc']);
samfile = fullfile(mgetdir('M_CTD'), ['sam_' mcruise '_all.nc']);
[d, hc] = mloadq(salfile, '/');
ds = mloadq(samfile, 'sampnum', 'niskin_flag', ' ');

%find if adj data available
clear hnew
hnew.fldnam = {'sampnum' 'botpsal' 'botpsal_flag'};
hnew.fldunt = {'number' 'psu' 'woce_9.4'}; %***
hnew.comment = ['salinity data from sal_' mcruise '_01.nc. ' hc.comment];
[~,isam,isal] = intersect(ds.sampnum,d.sampnum);
ds.botpsal = NaN+ds.sampnum; ds.botpsal_flag = 9+zeros(size(ds.sampnum));
if isfield(d, 'salinity_adj') && sum(~isnan(d.salinity_adj(isal)))
    ds.botpsal(isam) = d.salinity_adj(isal);
else
    ds.botpsal(isam) = d.salinity(isal);
end
ds.botpsal_flag(isam) = d.flag(isal);

%apply niskin flags (and also confirm consistency between sample and flag)
ds = hdata_flagnan(ds, 'keepempty', 1);
%don't need to rewrite them though
ds = rmfield(ds,'niskin_flag');

%save
mfsave(samfile, ds, hnew, '-merge', 'sampnum');
