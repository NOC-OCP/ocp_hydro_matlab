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

%parse to get sampnum, set flags, and change variable names
varmap.statnum = {'cast_number'};
varmap.position = {'niskin_bottle'};
varmap.totnit_per_l = {'nitrate_plus_nit','no3_plus_no2'};
varmap.nitrite_per_l = {'nitrite','no2'};
varmap.nitrate_per_l = {'nitrate','no3'};
varmap.silc_per_l = {'silicate'};
varmap.phos_per_l = {'phosphate'};
varmap.amon_per_l = {'ammonium'};
varmap.totnit_flag = {'flag'};
varmap.nitrite_flag = {'flag'};
varmap.silc_flag = {'flag'};
varmap.phos_flag = {'flag'};
varmap.amon_flag = {'flag'};
opt1 = 'botnut'; opt2 = 'nut_parse'; get_cropt %edit map for renaming variables, and flag whether to calculate conc_o2
[ds_nut, ~] = var_renamer(ds_nut, varmap);
ds_nut.sampnum = 100 * ds_nut.statnum + ds_nut.position;
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
