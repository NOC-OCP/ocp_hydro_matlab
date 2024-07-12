function moxy_01
% moxy_01: read in bottle oxy data from csv or spreadsheet files, parse and
% calculate concentrations if required, and save to appended mstar file
% oxy_cruise_01.nc
%
% The input data files contain one or more header rows; the fields to look
% for to identify the header rows as well as connect them to standard
% variable names are set in setdef_cropt_sam or opt_{cruise}
%
% If concentrations are not included in file or in the list of columns to
% parse in opt_cruise, uses parameters set under oxy_calc to compute them

m_common
if MEXEC_G.quiet<=1; fprintf(1, 'loading bottle oxygens from file specified in opt_%s, computing concentrations (if specified), writing to oxy_%s_01.nc\n',mcruise,mcruise); end

% find list of files and information on variables
root_oxy = mgetdir('M_BOT_OXY');
ofpat = ['oxy_' mcruise '_*.csv'];
ofiles = dir(fullfile(root_oxy, ofpat));
ofiles = struct2cell(ofiles); ofiles = ofiles(1,:)';
hcpat = {'Niskin' 'Bottle' 'Number'}; 
chrows = 1:2; chunits = 3;
clear iopts numhead
opt1 = 'botoxy'; opt2 = 'oxy_files'; get_cropt
if ~exist('sheets','var')
    sheets = 1:99;
end
if isempty(ofiles)
    warning(['no oxygen data files found in ' root_oxy '; skipping'])
    return
end

%load data
if exist('iopts','var') && isstruct(iopts)
    [ds_oxy, ~] = load_samdata(ofiles, iopts);
elseif exist('numhead','var') && ~isempty(numhead)
    %[ds_oxy, ~] = load_samdata(ofiles, 'numhead', numhead);
else
    [ds_oxy, ~] = load_samdata(ofiles, 'hcpat', hcpat, 'icolhead', chrows, 'icolunits', chunits, 'sheets', sheets);
end
if isempty(ds_oxy)
    error('no data loaded')
end
opt1 = 'check_sams'; get_cropt

%rename variables (if necessary)
varmap.statnum = {'cast_number'};
varmap.position = {'niskin_bottle'};
varmap.conc_o2 = {'c_o2_','c_o2'};
varmap.vol_blank = {'blank_titre'};
varmap.vol_std = {'std_vol'};
varmap.vol_titre_std = {'standard_titre'};
varmap.fix_temp = {'fixing_temp'};
varmap.oxy_bottle = {'bottle no'};
varmap.date_titre = {'dnum'};
varmap.bot_vol_tfix = {'botvol_at_tfix'};
opt1 = 'botoxy'; opt2 = 'oxy_parse'; get_cropt %edit map for renaming variables, and flag whether to calculate conc_o2
[ds_oxy, ~] = var_renamer(ds_oxy, varmap);
%statnum, sampnum, and remove extra lines
ds_oxy = fill_samdata_statnum(ds_oxy,'statnum');
ds_oxy.sampnum = ds_oxy.statnum*100 + ds_oxy.position;
m = isnan(ds_oxy.sampnum); ds_oxy(m,:) = [];
%create flags if necessary, then make sure they match available data
ds_oxy_fn = ds_oxy.Properties.VariableNames;
if sum(strcmp('flag',ds_oxy_fn))==0
    ds_oxy.flag = NaN+zeros(size(ds_oxy.sampnum));
end

if calcoxy
    %parse, for instance combining duplicates, or getting information from header
    cellT = 25; %default
    ds_oxy(isnan(ds_oxy.position),:) = [];

    %check units
    clear oxyunits
    oxyunits.vol_blank = {'ml' 'mls'};
    oxyunits.vol_std = {'ml' 'mls'};
    oxyunits.vol_titre_std = {'ml' 'mls'};
    oxyunits.bot_vol_tfix = {'ml' 'mls'};
    oxyunits.sample_titre = {'ml' 'mls'};
    oxyunits.fix_temp = {'c' 'degc' 'deg_c'};
    oxyunits.conc_o2 = {'umol/l' 'umol_per_l' 'umols_per_l'};
    if ~isempty(chunits) && ~isempty(ds_oxy.Properties.VariableUnits)
        [ds_oxy, ~] = check_units(ds_oxy, oxyunits);
    end

    %fill in flags to be consistent 
    ds_oxy_fn = ds_oxy.Properties.VariableNames;
    if sum(strcmp('sample_titre',ds_oxy_fn))
        dname = 'sample_titre';
    else
        dname = 'conc_o2';
    end
    ds_oxy.flag(ds_oxy.flag<=0) = NaN;
    bd = isnan(ds_oxy.(dname));
    bt = isnan(ds_oxy.fix_temp);
    %both oxy and temp, no flag: 2
    ds_oxy.flag(~bd & ~bt & isnan(ds_oxy.flag)) = 2;
    %both oxy and temp, flag 5 or 9: NaN oxy
    ds_oxy.(dname)(~bd & ~bt & ismember(ds_oxy.flag, [5 9])) = NaN;
    %temp but no oxy: 5 or 9
    ds_oxy.flag(bd & ~bt & ds_oxy.flag<9) = 5;
    %oxy but no temp: 5 and NaN oxy (no good without temp)
    if sum(~bd & bt)>0; warning('oxy values without fix_temp will be discarded'); end
    ds_oxy.flag(~bd & bt) = 5;
    ds_oxy.flag(~bd & bt) = NaN;
    %neither oxy nor temp: 9
    ds_oxy.flag(bd & bt) = 9;

    %compute bottle volumes at fixing temperature if not present
    if sum(strcmp('bot_vol_tfix',ds_oxy_fn))==0 && sum(strcmp('bot_vol',ds_oxy_fn))
        if sum(strcmp('bot_cal_temp',ds_oxy_fn))==0
            ds_oxy.bot_cal_temp = cellT+zeros(size(ds_oxy.sampnum));
        end
        ds_oxy.bot_vol_tfix = ds_oxy.bot_vol.*(1+9.75e-5*(ds_oxy.fix_temp-ds_oxy.bot_cal_temp));
    end

    %compute concentration if not present
    if sum(strcmp('conc_o2',ds_oxy_fn))==0
        mol_std = 1.667*1e-6;   % molarity (mol/mL) of standard KIO3
        std_react_ratio = 6;       % # Na2S2O3/ KIO3 (mol/mol)
        sample_react_ratio = 1./4; % # O2/Na2S2O3 (mol/mol)
        mol_o2_reag = 0.5*7.6e-8; %mol/mL of dissolved oxygen in pickling reagents
        opt1 = 'botoxy'; opt2 = 'oxy_calc'; get_cropt
        n_o2_reag = mol_o2_reag*vol_reag_tot;
        % molarity (mol/mL) of titrant
        mol_titrant = (std_react_ratio*ds_oxy.vol_std*mol_std)./(ds_oxy.vol_titre_std - ds_oxy.vol_blank);
        % moles of O2 in sample
        ds_oxy.n_o2 = (ds_oxy.sample_titre - ds_oxy.vol_blank).*mol_titrant*sample_react_ratio;
        % volume of sample, accounting for pickling reagent volumes.
        sample_vols = ds_oxy.bot_vol_tfix - vol_reag_tot; %mL
        % concentration of O2 in sample, accounting for concentration in pickling reagents
        %a = 1.5*(ds_oxy.sample_titre-ds_oxy.vol_blank).*(ds_oxy.vol_std/1000).*(1.667e-4./(ds_oxy.vol_titre_std-ds_oxy.vol_blank));
        ds_oxy.conc_o2 = (ds_oxy.n_o2 - n_o2_reag)./sample_vols*1e6*1e3; %mol/mL to umol/L
    end
end

ds_oxy.flag(isnan(ds_oxy.flag) & ~isnan(ds_oxy.conc_o2)) = 2; %default
ds_oxy.flag(isnan(ds_oxy.conc_o2)) = max(ds_oxy.flag(isnan(ds_oxy.conc_o2)),4);
ds_oxy_fn = ds_oxy.Properties.VariableNames;
if ismember(ds_oxy_fn,'sample_titre')
    if ismember(ds_oxy_fn,'bot_vol_tfix')
        ds_oxy.conc_o2(isnan(ds_oxy.sample_titre+ds_oxy.bot_vol_tfix)) = NaN;
    end
    if ismember(ds_oxy_fn,'fix_temp')
        ds_oxy.flag(isnan(ds_oxy.fix_temp) & ~isnan(ds_oxy.sample_titre)) = max(ds_oxy.flag(isnan(ds_oxy.fix_temp) & ~isnan(ds_oxy.sample_titre)), 5);
        ds_oxy.flag((isnan(ds_oxy.sample_titre) | isnan(ds_oxy.conc_o2)) & ~isnan(ds_oxy.fix_temp)) = 5; %drawn but not analysed
    end
end
ds_oxy_fn = ds_oxy.Properties.VariableNames;

%now put into structure and output
clear d hnew
hnew.dataname = ['oxy_' mcruise '_01'];
hnew.comment = ['data loaded from ' fullfile(root_oxy, ofpat) ' \n '];
hnew.fldnam = {'sampnum' 'statnum' 'position'};
hnew.fldunt = {'number' 'number' 'on.rosette'};
[d.sampnum, iia, ~] = unique(ds_oxy.sampnum, 'stable');
d.statnum = floor(d.sampnum/100); d.position = d.sampnum-d.statnum*100;
if sum(strcmp('conc_o2',ds_oxy_fn))
    d.botoxya_per_l = ds_oxy.conc_o2(iia);
    hnew.fldnam = [hnew.fldnam 'botoxya_per_l' 'botoxya_flag'];
    hnew.fldunt = [hnew.fldunt 'umol/L' 'woce_9.4'];
else
    d.botoxya = ds_oxy.botoxy_umol_per_kg;
    hnew.fldnam = [hnew.fldnam 'botoxya' 'botoxya_flag'];
    hnew.fldunt = [hnew.fldunt 'umol/kg' 'woce_9.4'];
end
d.botoxya_flag = ds_oxy.flag(iia);
if sum(strcmp('fix_temp',ds_oxy_fn))
    d.botoxya_temp = ds_oxy.fix_temp(iia);
    hnew.fldnam = [hnew.fldnam 'botoxya_temp'];
    hnew.fldunt = [hnew.fldunt 'degC'];
end

iib = setdiff(1:length(ds_oxy.sampnum),iia);
%***add code to handle duplicates in different columns on same line? 
if ~isempty(iib) 
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

opt1 = 'botoxy'; opt2 = 'oxy_flags'; get_cropt

opt1 = 'check_sams'; get_cropt
if check_oxy
    m0 = abs(d.botoxya_per_l-d.botoxyb_per_l)>0.75;
    if isfield(d,'botoxyc_per_l')
        m0 = m0 | abs(d.botoxyc_per_l-d.botoxya_per_l)>0.75 | abs(d.botoxyc_per_l-d.botoxyb_per_l)>0.75;
    end
    if sum(m0)
        stns = unique(d.statnum(m0));
        ds = mloadq(fullfile(mgetdir('ctd'),sprintf('sam_%s_all.nc',mcruise)),'sampnum statnum uoxygen position ');
        for sno = 1:length(stns)
            ii = find(d.statnum==stns(sno));
            [~,~,iis] = intersect(d.sampnum(ii),ds.sampnum,'stable');
            disp('some replicates differ')
            if isfield(d,'botoxyc_per_l')
                disp([num2str(stns(sno)) ': Niskin, CTD oxy (umol/kg), botoxya (umol/L), botoxyb (umol/L), botoxyc (umol/L), Niskin, flag a, flag b, flag c'])
                [ds.position(iis) ds.uoxygen(iis) d.botoxya_per_l(ii) d.botoxyb_per_l(ii) d.botoxyc_per_l(ii), d.position(ii) d.botoxya_flag(ii) d.botoxyb_flag(ii), d.botoxyc_flag(ii)]
            else
                disp([num2str(stns(sno)) ': Niskin, CTD oxy (umol/kg), botoxya (umol/L), botoxyb (umol/L), Niskin, flag a, flag b'])
                [ds.position(iis) ds.uoxygen(iis) d.botoxya_per_l(ii) d.botoxyb_per_l(ii) d.position(ii) d.botoxya_flag(ii) d.botoxyb_flag(ii)]
            end
            disp('enter to continue'); pause
        end
        opt1 = 'botoxy'; opt2 = 'oxy_flags'; get_cropt
    end
    clear ds stns m0
end

mfsave(fullfile(root_oxy, ['oxy_' mcruise '_01.nc']), d, hnew);

moxy_to_sam
