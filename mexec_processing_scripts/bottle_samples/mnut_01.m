mcruise = MEXEC_G.MSCRIPT_CRUISE_STRING;

root_nut = mgetdir('bot_nut');
npat = ['*.xlsx']; files = [];
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

hcpat = {'Nitrate+Nit'};
chrows = 1; chunits = 1; sheets = 1;
[ds_nut, nuthead] = load_samdata(files, 'hcpat', hcpat, 'icolhead', chrows, 'icolunits', chunits, 'sheets', sheets);

%parse***
for no = 1:size(ds_nut,1)
    a = ds_nut.ctdbot(no);
    a = replace(replace(a{1},'CTD',''),'BOT','');
    ii = strfind(a,'_');
    if length(ii)<3; ii(3) = length(a)+1; end
    s = str2double(a(ii(1)+1:ii(2)-1))*100 + str2double(a(ii(2)+1:ii(3)-1));
    ds_nut.sampnum(no) = s;
end
ds_nut.flag = 2+zeros(size(ds_nut.sampnum));
ds_nut.flag(ismember(ds_nut.sampnum,[1002 1612 1604 1924 2602 2802])) = 3;

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
clear dnew hnew
hnew.fldnam = {'sampnum' 'statnum' 'position'}; hnew.fldunt = {'number' 'number' 'on.rosette'};
dnew.sampnum = ds_nut.sampnum;
dnew.statnum = floor(dnew.sampnum/100);
dnew.position = dnew.sampnum-dnew.statnum*100;
for no = 1:size(varnamesunits,1)
    m = strcmp(varnamesunits{no,3},ds_nut.Properties.VariableNames);
    if sum(m)
        hnew.fldnam = [hnew.fldnam varnamesunits{no,1}];
        hnew.fldunt = [hnew.fldunt varnamesunits{no,2}];
        dnew.(varnamesunits{no,1}) = ds_nut.(varnamesunits{no,3});
    end
end
hnew.dataname = sprintf('nut_%s_01',mcruise);
hnew.comment = sprintf('variables loaded from files %s in %s',npat,root_nut);


root_nut = mgetdir('bot_nut');
otfile = fullfile(root_nut,[hnew.dataname '.nc']);
mfsave(otfile, dnew, hnew);

mnut_to_sam
