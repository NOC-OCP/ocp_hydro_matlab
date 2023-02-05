% moxy_to_sam: read in bottle oxy data from oxy_cruise_01.nc, convert from 
% umol/L to umol/kg, average replicates, save to sam_cruise_all.nc
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
    hnew.comment = sprintf('\n data appended from oxy_%s_???.nc \n ',mcruise);
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

%average replicates?
scriptname = mfilename; oopt = 'use_oxy_repl'; get_cropt
if use_oxy_repl>1 && ~isfield(d, 'botoxyc_per_l')
    use_oxy_repl = 1;
end
if use_oxy_repl>0 && ~isfield(d, 'botoxyb_per_l')
    use_oxy_repl = 0;
end

%convert to umol/kg
dens = gsw_rho(ds.uasal(iis),gsw_CT_from_t(ds.uasal(iis),d.botoxya_temp(iio),0),0);
botoxya = d.botoxya_per_l(iio)./(dens/1000);
if use_oxy_repl>0
    dens = gsw_rho(ds.uasal(iis),gsw_CT_from_t(ds.uasal(iis),d.botoxyb_temp(iio),0),0);
    botoxyb = d.botoxyb_per_l(iio)./(dens/1000);
    if use_oxy_repl>1
        dens = gsw_rho(ds.uasal(iis),gsw_CT_from_t(ds.uasal(iis),d.botoxyc_temp(iio),0),0);
        botoxyc = d.botoxyc_per_l(iio)./(dens/1000);
    end
end

ds.botoxy = zeros(size(ds.sampnum));
ds.botoxy_flag = 9+zeros(size(ds.sampnum));
ds.botoxy(iis) = botoxya;
ds.botoxy_flag(iis) = d.botoxya_flag(iio);
if use_oxy_repl>0
    nav = ones(size(ds.sampnum));

    %for sam file, average 'a' and 'b' samples if they have the same flag
    av = find(ds.botoxy_flag(iis)==d.botoxyb_flag(iio) & ~isnan(botoxyb));
    ds.botoxy(iis(av)) = ds.botoxy(iis(av)) + botoxyb(av);
    nav(iis(av)) = nav(iis(av))+1;
    ds.botoxy_flag(iis(av)) = 6; %mean of replicates
    %and if 'b' flag is better just use 'b'
    replace = find(d.botoxyb_flag(iio)<ds.botoxy_flag(iis) & ds.botoxy_flag(iis)~=6);
    ds.botoxy(iis(replace)) = botoxyb(replace);
    ds.botoxy_flag(iis(replace)) = d.botoxyb_flag(iio(replace));
    
    if use_oxy_repl>1
        %add 'c'
        av = find(ds.botoxy_flag(iis)==d.botoxyc_flag(iio) & ~isnan(botoxyc));
        ds.botoxy(iis(av)) = ds.botoxy(iis(av)) + botoxyc(av);
        nav(iis(av)) = nav(iis(av))+1;
        ds.botoxy_flag(iis(av)) = 6; %mean of replicates
        %if 'c' is better just use 'c'
        replace = find(d.botoxyc_flag(iio)<ds.botoxy_flag(iis) & ds.botoxy_flag(iis)~=6);
        ds.botoxy(iis(replace)) = botoxyc(replace);
        ds.botoxy_flag(iis(replace)) = d.botoxyc_flag(iio(replace));
    end
    
    %average replicates
    ds.botoxy = ds.botoxy./nav;
end
%for temperature it's not meaningful to average, so in sam_all file just
%report botoxya temp as diagnostic of good bottle closing
ds.botoxya_temp = NaN+ds.sampnum;
ds.botoxya_temp(iis) = d.botoxya_temp(iio);
hnew.fldnam = [hnew.fldnam 'botoxy' 'botoxya_temp' 'botoxy_flag'];
hnew.fldunt = [hnew.fldunt 'umol/kg' 'degC' 'woce_9.4'];
hnew.comment = [h.comment ' converted to umol/kg using CTD salinity (uasal) and fixing temperature \n '];

%apply niskin flags (and also confirm consistency between sample and flag)
ds = hdata_flagnan(ds, 'keepempty', 1);
%just keep the fields set above (don't need to keep niskin_flag etc. here)
fn = fieldnames(ds);
[~, ia, ib] = intersect(fn, hnew.fldnam, 'stable');
if length(ia)<length(fn)
    ds = rmfield(ds, fn(setdiff(1:length(fn),ia)));
end
hnew.fldnam = hnew.fldnam(ib); hnew.fldunt = hnew.fldunt(ib);

%save
mfsave(samfile, ds, hnew, '-merge', 'sampnum');
