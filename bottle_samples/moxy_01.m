% moxy_01: read in bottle oxy data from csv files, and save to appended
% mstar file oxy_cruise_01.nc, and to sam_cruise_all.nc
%
% The input data are in comma-delimited files, with one or more header
% rows; the fields to look for to identify the header rows as well as
% connect them to standard variable names are set in opt_cruise
%
% If concentrations are not included in file or in the list of columns to
% parse in opt_cruise, calls moxy_ccalc to compute them

m_common
mdocshow(mfilename, ['loads bottle oxygens from file specified in opt_' mcruise ', optionally calls moxy_ccalc to compute concentration from titration, and writes to oxy_' mcruise '_01.nc']);

% find list of files
root_oxy = mgetdir('M_BOT_OXY');
scriptname = mfilename; oopt = 'oxy_files'; get_cropt
if length(ofiles)==0
    warning(['no files matching ' ofpat ' found in ' root_oxy '; skipping'])
    return
end

%initialise
ds_oxy = dataset;

%information on header format and identification, and mapping between
%column headers and standard fieldnames
scriptname = mfilename; oopt = 'oxy_parse'; get_cropt

fn_unt_expect = {'vol_blank' {'ml' 'mls'}
    'vol_std' {'ml' 'mls'}
    'vol_titre_std' {'ml' 'mls'}
    'bot_vol_tfix' {'ml' 'mls'}
    'sample_titre' {'ml' 'mls'}
    'fix_temp' {'c' 'degc' 'deg_c'}
    'conc_o2' {'umol/l' 'umol_per_l' 'umols_per_l'}};

%load and store fields
ld = 0;
for flno = 1:length(ofiles)
    
    %load
    try
        [ds, hs] = m_load_samin(fullfile(root_oxy, ofiles(flno).name), hcpat, 'chrows', chrows, 'chunits', chunits);
    catch me
        warning(me.message)
        warning('moving on to next file')
        continue
    end
    ns = size(ds,1);
    iid = ld+[1:ns]';
    
    fn = ds.Properties.VarNames;
    if chunits>0
        for fno = 1:size(fn_unt_expect,1)
            ii1 = find(strcmp(fn_unt_expect{fno,1},mvar_fvar(:,1)));
            if length(ii1)>0
                ii = find(strcmp(mvar_fvar{ii1,2},fn));
                if length(ii)>0 && ~sum(strcmp(lower(hs.colunit{ii}),fn_unt_expect{fno,2}))
                    warning([ofiles(fno).name ' unit corresponding to ' fn_unt_expect{fno,1} ', ' hs.colunit{ii} ', does not match expected:'])
                    disp(fn_unt_expect{fno,2})
                end
            end
        end
    end
    
    scriptname = mfilename; oopt = 'oxy_parse_files'; get_cropt
    
    warning('off','all')
    for vno = 1:size(mvar_fvar,1)
        if sum(strcmp(mvar_fvar{vno,2},ds.Properties.VarNames))
            ds_oxy.(mvar_fvar{vno,1})(iid,1) = ds.(mvar_fvar{vno,2});
        else
            ds_oxy.(mvar_fvar{vno,1})(iid,1) = NaN;
        end
    end
    if sum(strcmp('notes',ds.Properties.VarNames))
        ds_oxy.comment(iid,1) = ds.notes;
    end
    warning('on','all')
    
    ld = ld+ns;
    
end

if isempty(ds_oxy)
    error('no data loaded')
end

%rearrange some fields
ds_oxy_fn = ds_oxy.Properties.VarNames;
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
        ds_oxy.bot_cal_temp = 25+zeros(size(ds_oxy.sampnum)); %assume*** put in cruise options
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
    ds_oxy.conc_o2(isnan(ds_oxy.sample_titre+ds_oxy.bot_vol_tfix)) = NaN;
end
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
    if length(ii)<length(iib)
        iic = setdiff(1:length(ds_oxy.sampnum),[iia(:); iib(:)]);
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
clear dnew hnew
samfile = fullfile(mgetdir('M_CTD'), ['sam_' mcruise '_all.nc']);
[ds,hs] = mloadq(samfile,'sampnum','uasal',' ');
[c,iio,iis] = intersect(d.sampnum, ds.sampnum);
dnew.sampnum = ds.sampnum;
hnew.fldnam = {'sampnum'}; 
hnew.fldunt = {'number'};

dens = gsw_rho(ds.uasal(iis),gsw_CT_from_t(ds.uasal(iis),d.botoxya_temp(iio),0),0);
dnew.botoxya = NaN+ds.sampnum; dnew.botoxya_temp = dnew.botoxya; dnew.botoxya_flag = 9+zeros(size(ds.sampnum));
dnew.botoxya(iis) = d.botoxya_per_l(iio)./(dens/1000);
dnew.botoxya_temp(iis) = d.botoxya_temp(iio);
dnew.botoxya_flag(iis) = d.botoxya_flag(iio);
hnew.fldnam = [hnew.fldnam 'botoxya' 'botoxya_temp' 'botoxya_flag'];
hnew.fldunt = [hnew.fldunt 'umol/kg' 'degC' 'woce_9.4'];

if isfield(d,'botoxyb_per_l')
    dens = gsw_rho(ds.uasal(iis),gsw_CT_from_t(ds.uasal(iis),d.botoxyb_temp(iio),0),0);
    dnew.botoxyb = NaN+ds.sampnum; dnew.botoxyb_temp = dnew.botoxyb; dnew.botoxyb_flag = 9+zeros(size(ds.sampnum));
    dnew.botoxyb(iis) = d.botoxyb_per_l(iio)./(dens/1000);
    dnew.botoxyb_temp(iis) = d.botoxyb_temp(iio);
    dnew.botoxyb_flag(iis) = d.botoxyb_flag(iio);
    hnew.fldnam = [hnew.fldnam 'botoxyb' 'botoxyb_temp' 'botoxyb_flag'];
    hnew.fldunt = [hnew.fldunt 'umol/kg' 'degC' 'woce_9.4'];
end

mfsave(samfile, dnew, hnew, '-addvars');

%station 14, 1034 --> 1.034
