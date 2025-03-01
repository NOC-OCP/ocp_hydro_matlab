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
if MEXEC_G.quiet<=1; fprintf(1, 'loading bottle oxygens from file(s) specified in opt_%s, computing concentrations (if specified), writing to oxy_%s_01.nc\n',mcruise,mcruise); end

% find list of files and information on variables
root_oxy = mgetdir('M_BOT_OXY');
% defaults
ofiles = dir(fullfile(root_oxy, ['oxy_' mcruise '_*.csv']));
hcpat = {'Niskin' 'Bottle' 'Number'}; chrows = 1:2; chunits = 3;
clear iopts numhead
% change defaults in opt_cruise
opt1 = 'botoxy'; opt2 = 'oxy_files'; get_cropt
if ~exist('sheets','var')
    sheets = 1:99;
end
if isempty(ofiles)
    warning(['no oxygen data files found in ' root_oxy '; skipping'])
    return
end
if isstruct(ofiles)
    ofiles = fullfile({ofiles.folder}',{ofiles.name}');
end

%load data
if exist('iopts','var') && isstruct(iopts)
    [ds_oxy, ~] = load_samdata(ofiles, iopts);
elseif exist('numhead','var') && ~isempty(numhead)
    %[ds_oxy, ~] = load_samdata(ofiles, 'numhead', numhead);
else
    [ds_oxy, ~] = load_samdata(ofiles, 'hcpat', hcpat, 'icolunits', chunits, 'sheets', sheets);
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
%varmap.sample_titre = {'sample_titre'};
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
    %calculate concentration from titre, standard and 
    ds_oxy = oxy_calc(ds_oxy);
end

%make sure flags match where data are present/missing
ds_oxy.flag(isnan(ds_oxy.flag) & ~isnan(ds_oxy.conc_o2)) = 2; %default
ds_oxy.flag(isnan(ds_oxy.conc_o2)) = max(ds_oxy.flag(isnan(ds_oxy.conc_o2)),4);
ds_oxy_fn = ds_oxy.Properties.VariableNames;
if ismember(ds_oxy_fn,'sample_titre')
    if ismember(ds_oxy_fn,'bot_vol_tfix')
        ds_oxy.conc_o2(isnan(ds_oxy.sample_titre+ds_oxy.bot_vol_tfix)) = NaN;
    end
    if ismember(ds_oxy_fn,'fix_temp')
        %can't report without fix_temp, should be 5 if it's not 9?
        m = isnan(ds_oxy.fix_temp) & ~isnan(ds_oxy.sample_titre);
        ds_oxy.flag(m) = max(ds_oxy.flag(m), 5);
        ds_oxy.conc_o2(m) = NaN; ds_oxy.sample_titre(m) = NaN;
        m = isnan(ds_oxy.sample_titre) | isnan(ds_oxy.conc_o2);
        ds_oxy.flag(m & ~isnan(ds_oxy.fix_temp)) = 5; %drawn but not analysed
    end
end
ds_oxy_fn = ds_oxy.Properties.VariableNames;

%now put into structure and output
clear d hnew
hnew.dataname = ['oxy_' mcruise '_01'];
hnew.comment = ['data loaded from ' root_oxy ' \n '];
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

orth = 0.01; %ratio threshold for replicate agreement to be examined
opt1 = 'check_sams'; get_cropt
if check_oxy
    oxy_repl_check(d, mcruise, orth, check_oxy)
    %get flags again in case changed (does this update?)
    opt1 = 'botoxy'; opt2 = 'oxy_flags'; get_cropt
end

mfsave(fullfile(root_oxy, ['oxy_' mcruise '_01.nc']), d, hnew);

moxy_to_sam

%%%%%%%%%%%%%%%%%%%    subfunctions    %%%%%%%%%%%%%%%%%%%
%----------------------------------------------------------

%%% ds_oxy = oxy_calc(ds_oxy)
%
% labT is only used if bot_vol_tfix not supplied

function ds_oxy = oxy_calc(ds_oxy)

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
if ~isempty(ds_oxy.Properties.VariableUnits)
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
ds_oxy.(dname)(~bd & bt) = NaN;
%neither oxy nor temp: 9
ds_oxy.flag(bd & bt) = 9;

opt1 = 'botoxy'; opt2 = 'oxy_calc'; get_cropt

%compute bottle volumes at fixing temperature if not present
if sum(strcmp('bot_vol_tfix',ds_oxy_fn))==0 && sum(strcmp('bot_vol',ds_oxy_fn))
    if sum(strcmp('bot_cal_temp',ds_oxy_fn))==0
        ds_oxy.bot_cal_temp = labT+zeros(size(ds_oxy.sampnum));
    end
    ds_oxy.bot_vol_tfix = ds_oxy.bot_vol.*(1+9.75e-5*(ds_oxy.fix_temp-ds_oxy.bot_cal_temp));
end

%compute concentration if not present
if sum(strcmp('conc_o2',ds_oxy_fn))==0
    mol_std = 1.667*1e-6;   % molarity (mol/mL) of standard KIO3
    std_react_ratio = 6;       % # Na2S2O3/ KIO3 (mol/mol)
    sample_react_ratio = 1./4; % # O2/Na2S2O3 (mol/mol)
    mol_o2_reag = 0.5*7.6e-8; %mol/mL of dissolved oxygen in pickling reagents
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

function oxy_repl_check(d, mcruise, orth, stn_start)
% check where oxygen replicates in d differ by more than 1+/-orth (ratio)

orthp = orth*5;
m0 = abs(d.botoxya_per_l./d.botoxyb_per_l-1)>orth;
q = [d.botoxya_per_l d.botoxyb_per_l];
qf = [d.botoxya_flag d.botoxyb_flag];
if isfield(d,'botoxyc_per_l')
    m0 = m0 | abs(d.botoxyc_per_l./d.botoxya_per_l-1)>orth | abs(d.botoxyc_per_l./d.botoxyb_per_l-1)>orth;
    q = [q d.botoxyc_per_l]; qf = [qf d.botoxyc_flag];
end

if sum(m0)
    qb = q; qb(qf~=4) = NaN;
    qq = q; qq(qf~=3) = NaN;
    q = q(m0,:);
    qq = qq(m0,:);
    qb = qb(m0,:);
    stn0 = d.statnum(m0);
    samp0 = d.sampnum(m0);
    ds = mloadq(fullfile(mgetdir('ctd'),sprintf('sam_%s_all.nc',mcruise)),'sampnum statnum uoxygen position upress ');
    [~,ia,ib] = intersect(d.sampnum,ds.sampnum);
    [~,ia0,ib0] = intersect(samp0,ds.sampnum);

    r = d.botoxya_per_l(ia)./ds.uoxygen(ib);
    rint = [d.botoxya_per_l(ia)*(1-orthp) d.botoxya_per_l(ia)*(1+orthp)]./repmat(ds.uoxygen(ib),1,2);
    figure(1); clf
    y = repmat(ds.uoxygen(ib0),1,size(q,2)); nr = length(ia);
    hl = plot([d.sampnum(ia) d.sampnum(ia)]',rint',...
        ds.sampnum(ib0),qb./y,'x', ds.sampnum(ib0),qq./y,'+',...
        d.sampnum(ia),r,'.b', ds.sampnum(ib0),q(ia0,:)./y,'o');
    ylabel('oxygen bot/ctd'); xlabel('sampnum'); grid
    title('all values, questionable replicates highlighted')
    legend(hl([1 end-3:end]),['+/-' num2str(orthp) ' factor on bottle value'],'all (a)','a','b','c','location','southwest'); 
    set(hl(1:nr),'color',[.5 .5 .5]); set(hl(nr+1:end-4),'color',[0 0 0])
    title('o differing replicates (x if flagged bad, + if flagged questionable)')

    %display values for each station
    stns = unique(stn0); stns = stns(stns>=stn_start);
    for sno = 1:length(stns)
        ii = find(d.statnum==stns(sno));
        [~,~,iis] = intersect(d.sampnum(ii),ds.sampnum,'stable');
        disp('some replicates differ')
        if isfield(d,'botoxyc_per_l')
            disp(['CTD statnum ' num2str(stns(sno)) ': Niskin position, CTD oxy (umol/kg), botoxya (umol/L), botoxyb (umol/L), botoxyc (umol/L), Niskin, flag a, flag b, flag c'])
            [ds.position(iis) ds.uoxygen(iis) d.botoxya_per_l(ii) d.botoxyb_per_l(ii) d.botoxyc_per_l(ii), d.position(ii) d.botoxya_flag(ii) d.botoxyb_flag(ii), d.botoxyc_flag(ii)]
        else
            disp([num2str(stns(sno)) ': Niskin, CTD oxy (umol/kg), botoxya (umol/L), botoxyb (umol/L), Niskin, flag a, flag b'])
            [ds.position(iis) ds.uoxygen(iis) d.botoxya_per_l(ii) d.botoxyb_per_l(ii) d.position(ii) d.botoxya_flag(ii) d.botoxyb_flag(ii)]
        end
        c = input('k for keyboard or enter to continue to next  ','s');
        if strcmp(c,'k'); keyboard; end
    end

end
