function mnut_01
%
% load bottle nutrient data, parse, flag, put into appended file
% nut_cruise_01.nc

m_common
mcruise = MEXEC_G.MSCRIPT_CRUISE_STRING;

%find files and load
root_nut = mgetdir('bot_nut');
npat = ['*.xlsx']; files = [];
hcpat = {'Nitrate+Nit'};
chrows = 1; chunits = 1; sheets = 1;
opt1 = 'botnut'; opt2 = 'nut_files'; get_cropt
if isempty(files)
    files = dir(fullfile(root_nut,npat));
    files = struct2cell(files); files = files(1,:)';
end
if isempty(files)
    warning(['no nut files matching ' npat ' found in ' root_nut])
    return
end
for flno = 1:length(files)
    files{flno} = fullfile(root_nut,files{flno});
end
[ds_nut, nuthead] = load_samdata(files, 'hcpat', hcpat, 'icolhead', chrows, 'icolunits', chunits, 'sheets', sheets);
if ~ismember(ds_nut.Properties.VariableNames,'flag')
    ds_nut.flag = 2+zeros(size(ds_nut,1),1);
end

%parse to get sampnum, set flags, and set lookup table for variable names
%in regular forms (first column) from variable names in ds_nut (3rd column)
varnamesunits = {'totnit_per_l', 'umol/l', 'nitrate_plus_nit';...
    'nitrite_per_l', 'umol/l', 'nitrite'; ...
    'silc_per_l', 'umol/l', 'silicate'; ...
    'phos_per_l', 'umol/l', 'phosphate'; ...
    'amon_per_l', 'umol/l', 'ammonium'; ...
    'totnit_flag', 'woce_9.4', 'flag';...
    'nitrite_flag', 'woce_9.4', 'flag';...
    'silc_flag', 'woce_9.4', 'flag';...
    'phos_flag', 'woce_9.4', 'flag';...
    'amon_flag', 'woce_9.4', 'flag';...
    };
opt1 = 'botnut'; opt2 = 'nut_parse_flag'; get_cropt
varnamesunits = varnamesunits(ismember(varnamesunits(:,3),ds_nut.Properties.VariableNames),:);
ds_nut = ds_nut(isfinite(ds_nut.sampnum),:);

% check_nut = 0;
% opt1 = 'check_sams'; get_cropt
%***

%***replicates

clear dnew hnew
hnew.fldnam = {'sampnum' 'statnum' 'position'}; 
hnew.fldunt = {'number' 'number' 'on.rosette'};
[dnew.sampnum, iia, ~] = unique(ds_nut.sampnum,'stable');
dnew.statnum = floor(dnew.sampnum/100); dnew.position = dnew.sampnum-dnew.statnum*100;
rlet = 'a';
%change names, separating out replicates if necessary
for vno = 1:size(varnamesunits,1)
    if contains(varnamesunits{vno,1},'_per_l') && ~contains(varnamesunits{vno,1},'_flag')
        vname = varnamesunits{vno,1}(1:end-6); %without the _per_l
        mf = strcmp([vname '_flag'],varnamesunits(:,1));
        nname = [vname rlet '_per_l'];
        fname = [vname rlet '_flag'];
        dnew.(nname) = ds_nut.(varnamesunits{vno,3})(iia);
        dnew.(fname) = ds_nut.(varnamesunits{mf,3})(iia);
        hnew.fldnam = [hnew.fldnam nname fname];
        hnew.fldunt = [hnew.fldunt varnamesunits{vno,2} varnamesunits{mf,2}];
    end
end

iib = setdiff(1:length(ds_nut.sampnum),iia);
if ~isempty(iib)
    rlet = 'b';
    for vno = 1:size(varnamesunits,1)
        if contains(varnamesunits{vno,1},'_per_l') && ~contains(varnamesunits{vno,1},'_flag')
            vname = varnamesunits{vno,1}(1:end-6); %without the _per_l
            mf = strcmp([vname '_flag'],varnamesunits(:,1));
            nname = [vname rlet '_per_l'];
            fname = [vname rlet '_flag'];
            dnew.(nname) = nan(size(dnew.sampnum));
            dnew.(fname) = dnew.(nname);
            [~,ii,iid] = intersect(ds_nut.sampnum(iib),dnew.sampnum);
            dnew.(nname)(iid) = ds_nut.(varnamesunits{vno,3})(iib(ii));
            dnew.(fname)(iid) = ds_nut.(varnamesunits{mf,3})(iib(ii));
            hnew.fldnam = [hnew.fldnam nname fname];
            hnew.fldunt = [hnew.fldunt varnamesunits{vno,2} varnamesunits{mf,2}];
        end
    end
end

hnew.dataname = sprintf('nut_%s_01',mcruise);
hnew.comment = sprintf('variables loaded from files %s in %s',npat,root_nut);

opt1 = 'botnut'; opt2 = 'nut_param_flag'; get_cropt

root_nut = mgetdir('bot_nut');
otfile = fullfile(root_nut,[hnew.dataname '.nc']);
mfsave(otfile, dnew, hnew);

mnut_to_sam
