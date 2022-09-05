% moxy_to_sam: read in bottle oxy data from oxy_cruise_01.nc, convert from 
% umol/L to umol/kg, save to sam_cruise_all.nc
%

m_common
if MEXEC_G.quiet<=1; fprintf(1, 'converting bottle oxy from oxy_%s_01.nc to /kg and writing to sam_%s_all.nc\n',mcruise,mcruise); end

% load from oxy file(s), load sam sal for converting to /kg
root_oxy = mgetdir('M_BOT_OXY');
oxyfile = fullfile(root_oxy, ['oxy_' mcruise '_01.nc']);
if ~exist(oxyfile,'file')
    %backwards compatibility: first make an appended oxy file
    fnames = dir(fullfile(root_oxy, ['oxy_' mcruise '_*.nc']));
    fnames = {fnames.name};
    %initialise
    [d,h] = mload(fullfile(root_oxy,fnames{1}),'/');
    h.dataname = ['oxy_' mcruise '_01'];
    mfsave(oxyfile, d, h);
    %append
    clear hnew
    for fno = 2:length(fnames)-1
       [d0,h0] = mload(fullfile(root_oxy,fnames{fno}),'/');
       hnew.fldnam = h0.fldnam; hnew.fldunt = h0.fldunt; 
       mfsave(oxyfile, d0, hnew, '-merge', 'sampnum');
    end
    [d0,h0] = mload(fullfile(root_oxy,fnames{end}),'/');
    hnew.fldnam = h0.fldnam; hnew.fldunt = h0.fldunt;
    hnew.comment = sprintf('\n data appended from oxy_%s_???.nc',mcruise);
    mfsave(oxyfile, d0, hnew, '-merge', 'sampnum');
    h = m_read_header(oxyfile);
    renamevars = {'botoxytempa' 'botoxya_temp'
        'botoxytempb' 'botoxyb_temp'
        'botoxytempc' 'botoxyc_temp'
        'botoxyflaga' 'botoxya_flag'
        'botoxyflagb' 'botoxyb_flag'
        'botoxyflagc' 'botoxyc_flag'};
    oxyfile = m_add_nc(oxyfile);
    for vno = 1:size(renamevars,1)
        if sum(strcmp(h.fldnam,renamevars{vno,1}))
            nc_varrename(oxyfile, renamevars{vno,1}, renamevars{vno,2});
        end
    end
end
d = mloadq(oxyfile, '/');

samfile = fullfile(mgetdir('M_CTD'), ['sam_' mcruise '_all.nc']);
[ds,hs] = mloadq(samfile,'sampnum','niskin_flag','uasal',' ');

[~,iis,iio] = intersect(ds.sampnum,d.sampnum);
clear hnew
hnew.fldnam = {'sampnum'};
hnew.fldunt = {'number'};

%convert to umol/kg
dens = gsw_rho(ds.uasal(iis),gsw_CT_from_t(ds.uasal(iis),d.botoxya_temp(iio),0),0);
botoxya = d.botoxya_per_l(iio)./(dens/1000);
if isfield(d, 'botoxyb_per_l')
    dens = gsw_rho(ds.uasal(iis),gsw_CT_from_t(ds.uasal(iis),d.botoxyb_temp(iio),0),0);
    botoxyb = d.botoxyb_per_l(iio)./(dens/1000);
end

ds.botoxy = NaN+ds.sampnum;
ds.botoxy_flag = 9+zeros(size(ds.sampnum));
if isfield(d, 'botoxyb_per_l')
    %for sam file, average 'a' and 'b' samples depending on flag
    av = find(d.botoxya_flag(iio)==d.botoxyb_flag(iio));
    ds.botoxy(iis(av)) = .5*(botoxya(av)+botoxyb(av));
    ds.botoxy_flag(iis(av)) = 6;
    a = find(d.botoxya_flag(iio)<d.botoxyb_flag(iio));
    ds.botoxy(iis(a)) = botoxya(a);
    ds.botoxy_flag(iis(a)) = d.botoxya_flag(iio(a));
    b = find(d.botoxyb_flag(iio)<d.botoxya_flag(iio));
    ds.botoxy(iis(b)) = botoxyb(b);
    ds.botoxy_flag(iis(b)) = d.botoxyb_flag(iio(b));
else
    %only 'a' samples
    ds.botoxy(iis) = botoxya;
    ds.botoxy_flag(iis) = d.botoxya_flag(iio);
end
%for temperature it's not meaningful to average, just report botoxya
%temp as diagnostic of good bottle closing
ds.botoxya_temp = NaN+ds.sampnum;
ds.botoxya_temp(iis) = d.botoxya_temp(iio);
hnew.fldnam = [hnew.fldnam 'botoxy' 'botoxya_temp' 'botoxy_flag'];
hnew.fldunt = [hnew.fldunt 'umol/kg' 'degC' 'woce_9.4'];

%apply niskin flags (and also confirm consistency between sample and flag)
ds = hdata_flagnan(ds, [3 4 9]);
%just keep the fields set above (don't need to keep niskin_flag etc. here)
fn = fieldnames(ds);
[~, ia, ib] = intersect(fn, hnew.fldnam, 'stable');
if length(ia)<length(fn)
    ds = rmfield(ds, fn(setdiff(1:length(fn),ia)));
end
hnew.fldnam = hnew.fldnam(ib); hnew.fldunt = hnew.fldunt(ib);

%save
mfsave(samfile, ds, hnew, '-merge', 'sampnum');
