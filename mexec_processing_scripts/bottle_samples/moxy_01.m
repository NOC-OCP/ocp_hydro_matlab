% moxy_01: read in bottle oxy data from csv or spreadsheet files, and save to appended
% mstar file oxy_cruise_01.nc, and to sam_cruise_all.nc
%
% The input data files contain one or more header rows; the fields to look
% for to identify the header rows as well as connect them to standard
% variable names are set in setdef_cropt_sam or opt_{cruise} 
%
% If concentrations are not included in file or in the list of columns to
% parse in opt_cruise, calls moxy_ccalc to compute them

m_common
mdocshow(mfilename, ['loads bottle oxygens from file specified in opt_' mcruise ', optionally calls moxy_ccalc to compute concentration from titration, and writes to oxy_' mcruise '_01.nc']);

% find list of files and information on variables
root_oxy = mgetdir('M_BOT_OXY');
scriptname = mfilename; oopt = 'oxy_files_parse'; get_cropt 
if isempty(ofiles)
    warning(['no files matching ' ofpat ' found in ' root_oxy '; skipping'])
    return
else
    for flno = 1:length(ofiles)
        ofiles{flno} = fullfile(root_oxy,ofiles{flno});
    end
end

%load data
[ds_oxy, oxyhead] = load_samdata(ofiles, hcpat, 'chrows', chrows, 'chunits', chunits, 'sheets', sheets);
if isempty(ds_oxy)
    error('no data loaded')
end
%special code, for instance to get information from header
cellT = 25; %default
scriptname = mfilename; oopt = 'oxy_parse_files'; get_cropt

%rename according to lookup table
ds_oxy_fn = ds_oxy.Properties.VariableNames;
[~,ia,ib] = intersect(oxyvarmap(:,2)',ds_oxy_fn);
ds_oxy_fn(ib) = oxyvarmap(ia,1)';
ds_oxy.Properties.VariableNames = ds_oxy_fn;

%check units
clear oxyunits
oxyunits.vol_blank = {'ml' 'mls'};
oxyunits.vol_std = {'ml' 'mls'};
oxyunits.vol_titre_std = {'ml' 'mls'};
oxyunits.bot_vol_tfix = {'ml' 'mls'};
oxyunits.sample_titre = {'ml' 'mls'};
oxyunits.fix_temp = {'c' 'degc' 'deg_c'};
oxyunits.conc_o2 = {'umol/l' 'umol_per_l' 'umols_per_l'};
if ~isempty(chunits)
    check_table_units(ds_oxy, oxyunits)
end

%compute or fill some fields
if sum(strcmp('sampnum',ds_oxy_fn))==0
    ds_oxy.sampnum = 100*ds_oxy.statnum + ds_oxy.position;
else
    if sum(strcmp('statnum',ds_oxy_fn))==0
        ds_oxy.statnum = floor(ds_oxy.sampnum/100);
    end
    if sum(strcmp('position',ds_oxy_fn))==0
        ds_oxy.position = ds_oxy.sampnum - ds_oxy.statnum*100;
    end
end
if sum(strcmp('flag',ds_oxy_fn))==0
    ds_oxy.flag = 9+zeros(size(ds_oxy.sampnum));
    ds_oxy.flag(~isnan(ds_oxy.sample_titre)) = 2;
    ds_oxy.flag(isnan(ds_oxy.sample_titre) & ~isnan(ds_oxy.fix_temp)) = 5;
else
    ds_oxy.flag(ds_oxy.flag==0) = NaN;
    if sum(isnan(ds_oxy.flag))>0
        ds_oxy.flag(isnan(ds_oxy.flag) & isnan(ds_oxy.sample_titre)) = 9;
        ds_oxy.flag(isnan(ds_oxy.flag) & ~isnan(ds_oxy.sample_titre)) = 2;
        ds_oxy.flag(isnan(ds_oxy.flag) & isnan(ds_oxy.sample_titre) & ~isnan(ds_oxy.fix_temp)) = 5;
    end
end

%compute bottle volumes at fixing temperature if not present
if sum(strcmp('bot_vol_tfix',ds_oxy_fn))==0
    if sum(strcmp('bot_cal_temp',ds_oxy_fn))==0
        ds_oxy.bot_cal_temp = cellT+zeros(size(ds_oxy.sampnum));
    end
    ds_oxy.bot_vol_tfix = ds_oxy.bot_vol.*(1+9.75e-5*(ds_oxy.fix_temp-ds_oxy.bot_cal_temp));
end

%compute concentration if not present
if sum(strcmp('conc_o2',ds_oxy_fn))==0
    scriptname = mfilename; oopt = 'oxycalcpars'; get_cropt
    n_o2_reag = mol_o2_reag*vol_reag_tot;
    % molarity (mol/mL) of titrant
    mol_titrant = (std_react_ratio*ds_oxy.vol_std*mol_std)./(ds_oxy.vol_titre_std - ds_oxy.vol_blank);
    % moles of O2 in sample
    ds_oxy.n_o2 = (ds_oxy.sample_titre - ds_oxy.vol_blank).*mol_titrant*sample_react_ratio;
    % volume of sample, accounting for pickling reagent volumes.
    sample_vols = ds_oxy.bot_vol_tfix - vol_reag_tot; %mL
    % concentration of O2 in sample, accounting for concentration in pickling reagents
    a = 1.5*(ds_oxy.sample_titre-ds_oxy.vol_blank).*(ds_oxy.vol_std/1000).*(1.667e-4./(ds_oxy.vol_titre_std-ds_oxy.vol_blank));
    ds_oxy.conc_o2 = (ds_oxy.n_o2 - n_o2_reag)./sample_vols*1e6*1e3; %mol/mL to umol/L
end
ds_oxy.conc_o2(isnan(ds_oxy.sample_titre+ds_oxy.bot_vol_tfix)) = NaN;
ds_oxy.flag(isnan(ds_oxy.fix_temp) & ~isnan(ds_oxy.sample_titre)) = max(ds_oxy.flag(isnan(ds_oxy.fix_temp) & ~isnan(ds_oxy.sample_titre)), 5);
ds_oxy.flag(isnan(ds_oxy.conc_o2)) = max(ds_oxy.flag(isnan(ds_oxy.conc_o2)),4);
ds_oxy.flag((isnan(ds_oxy.sample_titre) | isnan(ds_oxy.conc_o2)) & ~isnan(ds_oxy.fix_temp)) = 5; %drawn but not analysed

%now put into structure and output
clear d hnew
[d.sampnum, iia, iic] = unique(ds_oxy.sampnum);
d.statnum = floor(d.sampnum/100); d.position = d.sampnum-d.statnum*100;
hnew.dataname = ['oxy_' mcruise '_01'];
hnew.comment = ['data loaded from ' fullfile(root_oxy, ofpat)];
hnew.fldnam = {'sampnum' 'statnum' 'position'};
hnew.fldunt = {'number' 'number' 'on.rosette'};

d.botoxya_per_l = ds_oxy.conc_o2(iia);
d.botoxya_temp = ds_oxy.fix_temp(iia);
d.botoxya_flag = ds_oxy.flag(iia);
hnew.fldnam = [hnew.fldnam 'botoxya_per_l' 'botoxya_temp' 'botoxya_flag'];
hnew.fldunt = [hnew.fldunt 'umol/L' 'degC' 'woce_9.4'];

iib = setdiff(1:length(ds_oxy.sampnum),iia);
if ~isempty(iib) %***do something different for different input, like duplicates on same line? or don't allow this
    d.botoxyb_per_l = NaN+d.botoxya_per_l; 
    d.botoxyb_temp = d.botoxyb_per_l;
    d.botoxyb_flag = 9+zeros(size(d.sampnum));
    [~,ii,iid] = intersect(ds_oxy.sampnum(iib),d.sampnum);
    d.botoxyb_per_l(iid) = ds_oxy.conc_o2(iib(ii));
    d.botoxyb_temp(iid) = ds_oxy.fix_temp(iib(ii));
    d.botoxyb_flag(iid) = ds_oxy.flag(iib(ii));
    hnew.fldnam = [hnew.fldnam 'botoxyb_per_l' 'botoxyb_temp' 'botoxyb_flag'];
    hnew.fldunt = [hnew.fldunt 'umol/L' 'degC' 'woce_9.4'];
    iic = setdiff(1:length(ds_oxy.sampnum),[iia' iib(ii)]);
    if ~isempty(iic)
        d.botoxyc_per_l = NaN+d.botoxya_per_l;
        d.botoxyc_temp = d.botoxyc_per_l;
        d.botoxyc_flag = 9+zeros(size(d.sampnum));
        [~,ii,iid] = intersect(ds_oxy.sampnum(iic),d.sampnum);
        d.botoxyc_per_l(iid) = ds_oxy.conc_o2(iic(ii));
        d.botoxyc_temp(iid) = ds_oxy.fix_temp(iic(ii));
        d.botoxyc_flag(iid) = ds_oxy.flag(iic(ii));
        hnew.fldnam = [hnew.fldnam 'botoxyc_per_l' 'botoxyc_temp' 'botoxyc_flag'];
        hnew.fldunt = [hnew.fldunt 'umol/L' 'degC' 'woce_9.4'];
    end
end

scriptname = mfilename; oopt = 'oxyflags'; get_cropt

mfsave(fullfile(root_oxy, ['oxy_' mcruise '_01.nc']), d, hnew);

% compute botoxy_per_kg (umol/kg) from botoxy (umol/L) and save to samfile
clear hnew
samfile = fullfile(mgetdir('M_CTD'), ['sam_' mcruise '_all.nc']);
[ds,hs] = mloadq(samfile,'sampnum','niskin_flag','uasal',' ');
[~,iis,iio] = intersect(ds.sampnum,d.sampnum);
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
ds = hdata_flagnan(ds, [4 9]);
%don't need to rewrite them though, nor uasal
ds = rmfield(ds, {'niskin_flag', 'uasal'});

%save
mfsave(samfile, ds, hnew, '-merge', 'sampnum');
