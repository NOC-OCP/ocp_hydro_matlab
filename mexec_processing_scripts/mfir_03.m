% mfir_03: merge ctd upcast data including time onto fir file
%
% Use: mfir_03        and then respond with station number, or for station 16
%      stn = 16; mfir_03;

opt1 = 'castpars'; opt2 = 'minit'; get_cropt

root_ctd = mgetdir('M_CTD');
infilef = fullfile(root_ctd, ['fir_' mcruise '_' stn_string]);
otfilef = infilef;
if ~exist(m_add_nc(infilef),'file')
    infilef = [infilef '_ctd'];
    if ~exist(m_add_nc(infilef),'file')
        warning('station %s fir file not found; skipping',stn_string)
        return
    end
end
if MEXEC_G.quiet<=1; fprintf(1,'adds CTD upcast data at bottle firing times to fir_%s_%s.nc\n', mcruise, stn_string); end
%not using 24hz because we want at least some averaging
infile1 = fullfile(root_ctd, ['ctd_' mcruise '_' stn_string '_psal']); 

var_copycell = mcvars_list(2); %which variables to copy from 24hz CTD file
% remove any vars from copy list that aren't available in the input file
[var_copycell, var_copystr] = mvars_in_file(var_copycell, infile1);
if ~sum(strcmp('scan',var_copycell)); var_copystr = ['scan ' var_copystr]; end

firmethod = 'medint';
clear firopts;
firopts.int = [-1 120]; %average over 5 s, like in .ros file
firopts.prefill = 24*5; %fill gaps up to 5 s first
opt1 = mfilename; opt2 = 'fir_fill'; get_cropt

[dfir, hfir] = mload(infilef,'scan',' ');
[dc, hc] = mload(infile1, var_copystr);
dc = grid_profile(dc, 'scan', dfir.scan, firmethod, firopts);
clear dnew hnew
hnew.fldnam = {}; hnew.fldunt = {};
for no = 1:length(var_copycell)
    ii = find(strcmp(var_copycell{no}, hc.fldnam));
    hnew.fldnam = [hnew.fldnam ['u' var_copycell{no}]];
    hnew.fldunt = [hnew.fldunt hc.fldunt{ii}];
    dnew.(['u' var_copycell{no}]) = dc.(var_copycell{no});
end

% bak: need to fix time offset
to = ['seconds since ' datestr(MEXEC_G.MDEFAULT_DATA_TIME_ORIGIN,'yyyy-mm-dd HH:MM:SS')];
opt1 = 'mstar'; get_cropt
if docf
    hnew.data_time_origin = [];
else
    hnew.data_time_origin = MEXEC_G.MDEFAULT_DATA_TIME_ORIGIN;
end
dnew.time = dnew.utime;
dnew.utime = m_commontime(dnew,'time',hc,to);
dnew = rmfield(dnew,'time');

hnew.latitude = hc.latitude; hnew.longitude = hc.longitude; hnew.water_depth_metres = hc.water_depth_metres;
hnew.comment = hc.comment;

MEXEC_A.Mprog = mfilename;
mfsave(otfilef, dnew, hnew, '-addvars');

