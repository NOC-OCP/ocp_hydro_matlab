% mfir_03: merge ctd upcast data including time onto fir file
%
% Use: mfir_03        and then respond with station number, or for station 16
%      stn = 16; mfir_03;

minit; 
mdocshow(mfilename, ['adds CTD upcast data at bottle firing times to fir_' mcruise '_' stn_string '.nc']);

root_ctd = mgetdir('M_CTD');
infile1 = fullfile(root_ctd, ['fir_' mcruise '_' stn_string]);
%not using 24hz because we want at least some averaging
infile2 = fullfile(root_ctd, ['ctd_' mcruise '_' stn_string '_psal']); 

var_copycell = mcvars_list(2);
% remove any vars from copy list that aren't available in the input file
[var_copycell, var_copystr] = mvars_in_file(var_copycell, infile2);

scriptname = mfilename; oopt = 'fir_fill'; get_cropt
if strcmp(fillstr,'f')
    absfill = inf;
elseif strcmp(fillstr,'k')
    absfill = 0;
else
    absfill = fillstr;
end

[dfir, hfir] = mloadq(infile1,'scan',' ');
[dc, hc] = mloadq(infile2,'/');
clear dnew hnew
hnew.fldnam = {}; hnew.fldunt = {};
data = NaN+zeros(length(dc.scan),length(var_copycell));
for no = 1:length(var_copycell)
    ii = find(strcmp(var_copycell{no}, hc.fldnam));
    hnew.fldnam = [hnew.fldnam ['u' var_copycell{no}]];
    hnew.fldunt = [hnew.fldunt hc.fldunt{ii}];
    data(:,no) = dc.(var_copycell{no});
end
data = merge_avmed(dc.scan, data, dfir.scan, avi_opt, absfill);
for no = 1:length(var_copycell)
    dnew.(['u' var_copycell{no}]) = data(:,no);
end
% bak: need to fix time offset
dnew.utime = m_commontime(dnew.utime,hc.data_time_origin,hfir.data_time_origin);

hnew.latitude = hc.latitude; hnew.longitude = hc.longitude; hnew.water_depth_metres = hc.water_depth_metres;

MEXEC_A.Mprog = mfilename;
mfsave(infile1, dnew, hnew, '-addvars');

