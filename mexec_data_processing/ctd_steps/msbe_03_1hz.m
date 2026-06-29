function mctd_03(stn)
% mctd_03:
%
% input: _24hz
%
%   copy data from sensors chosen in opt_cruise to temp, cond, and oxygen; 
%   calculate psal, asal, potemp using GSW;
%   average to 1 hz and fill gaps as set in opt_cruise
%
% outputs: _psal (1 hz, used for plots and ladcp)
%          wk_dvars_ (24 hz, used by mctd_04 to average to 2 dbar)
%
% Use: mctd_03        and then respond with station number, or for station 16
%      stn = 16; mctd_03;
%
% calls: 
%     mloadq
%     grid_profile
%     gsw functions
%     mfsave
% and via get_cropt:
%      setdef_cropt_cast (ctd_proc and mctd_03 cases)

m_common; MEXEC_A.mprog = mfilename;
opt1 = 'ctd_proc'; opt2 = 'minit'; get_cropt 
if MEXEC_G.quiet<=1; fprintf(1,'choosing preferred sensor, computing salinity, averaging to 1 hz for ctd_%s_%s_psal.nc\n',mcruise,stn_string); end

root_ctd = mgetdir('M_CTD');

prefix1 = ['ctd_' mcruise '_'];

infile = fullfile(root_ctd, [prefix1 stn_string '_24hz']);
otfile = fullfile(root_ctd, [prefix1 stn_string '_psal']);

%calculate derived variables
[d, h] = mloadq(infile,'/');
iig = find(d.press>-1.495); %gsw won't work on p<=-1.495
if length(iig)<length(d.press)
    m = {'negative pressures < -1.495 found, psal etc. will not be calculated for these points'};
    if min(d.press<-10)
        m = [m; 'you may also want to check in mctd_rawshow and set rangelim under mctd_02';
            'case in opt_' mcruise ' in case pressure spikes need to be edited out'];
        warning('%s\n',m{:});
    end
end
if ~strcmp('mS/cm',h.fldunt{strcmp('cond1',h.fldnam)})
    warning('cond units should be mS/cm for psal calc, they are %s',h.fldunt(strcmp('cond1',h.fldnam)))
    keyboard
end
d.psal1 = NaN+d.cond1; d.psal1(iig) = gsw_SP_from_C(d.cond1(iig),d.temp1(iig),d.press(iig));
d.psal2 = NaN+d.cond2; d.psal2(iig) = gsw_SP_from_C(d.cond2(iig),d.temp2(iig),d.press(iig));
d.asal1 = NaN+d.cond1; d.asal1(iig) = gsw_SA_from_SP(d.psal1(iig),d.press(iig),h.longitude,h.latitude);
d.asal2 = NaN+d.cond2; d.asal2(iig) = gsw_SA_from_SP(d.psal2(iig),d.press(iig),h.longitude,h.latitude);
d.potemp1 = NaN+d.cond1; d.potemp1(iig) = gsw_pt0_from_t(d.asal1(iig),d.temp1(iig),d.press(iig));
d.potemp2 = NaN+d.cond2; d.potemp2(iig) = gsw_pt0_from_t(d.asal2(iig),d.temp2(iig),d.press(iig));

%new variable names and units
h.fldnam = [h.fldnam 'psal1' 'psal2' 'asal1' 'asal2' 'potemp1' 'potemp2'];
h.fldunt = [h.fldunt 'pss-78' 'pss-78' 'g/kg' 'g/kg' 'degc90' 'degc90'];
h.fldserial = [h.fldserial repmat({' '},1,length(h.fldnam)-length(h.fldserial))];
[h.fldnam, ii] = unique(h.fldnam);
h.fldunt = h.fldunt(ii);
h.fldserial = h.fldserial(ii);
cstr = 'psal, asal, potemp, contemp calculated using gsw';
if ~contains(h.comment, cstr)
    h.comment = [h.comment '\n ' cstr];
end

%save to _24hz file
mfsave(infile, d, h);

%identify and copy preferred sensor (for this station) to variable without
%sensor number (e.g. psal = psal1)
[d, h] = copy_sensor(d, h, stn);

%find variables to copy, that are in both mcvars_list and the input file
var_copycell = mcvars_list(1);
var_copycell = intersect(h.fldnam, var_copycell, 'stable');
clear hnew dnew
hnew.data_time_origin = h.data_time_origin; 
hnew.dataname = h.dataname;
hnew.latitude = h.latitude;
hnew.longitude = h.longitude;
hnew.fldunt = {}; hnew.fldserial = {};
for no = 1:length(var_copycell)
    ii = find(strcmp(var_copycell{no},h.fldnam));
    hnew.fldunt = [hnew.fldunt h.fldunt{ii}];
    hnew.fldserial = [hnew.fldserial h.fldserial{ii}];
    dnew.(var_copycell{no}) = d.(var_copycell{no});
end
hnew.fldnam = var_copycell;
hnew = keep_hvatts(hnew, h);
hnew.comment = h.comment;

%average to 1hz, output to _psal file
opt1 = 'ctd_proc'; opt2 = '1hz_interp'; get_cropt
tg = [dnew.time(1):dnew.time(end)+1]; %end will be truncated anyway by setting grid_ends to 0
if size(dnew.time,1)>1; tg = tg'; end
dnew = grid_profile(dnew, 'time', tg, 'meannum', 'num', 24, 'prefill', maxfill24, 'grid_ends', [0 0], 'postfill', maxfill1);
mfsave(otfile, dnew, hnew);
