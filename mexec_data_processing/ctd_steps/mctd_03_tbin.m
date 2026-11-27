function mctd_03_tbin(stn)
% mctd_03:
%
% input: _cleancal (original frequency, edited and calibrated data
%   including derived parameters, such as produced by
%   msbe_02_cleancal_derive.m)
%
%   copy data from preferred temp, cond, oxygen sensor, chosen in 
%   opt_cruise, to temp, cond, and oxygen (no 1/2 suffix); 
%   average to 1 hz and and fill gaps as set in opt_cruise
%
% outputs: _1hz (1 hz, used for plots and ladcp)
%
%
% calls: 
%     mloadq
%     grid_profile
%     gsw functions
%     mfsave

m_common; 
if MEXEC_G.quiet<=1; fprintf(1,'choosing preferred sensor, computing salinity, averaging to 1 hz for ctd_%s_%s_psal.nc\n',mcruise,stn_string); end
opt1 = 'setup'; opt2 = 'pfiles'; run(MEXEC_G.opt_cruise);

%load data and copy preferred sensor e.g. psal = psal1
[d, h] = mloadq(pfiles.ctd_cleancal,'/');
timunt = ['seconds since ' MEXEC_G.data_time_origin_string];
d.time = m_commontime(d, 'time', h, timunt);
h.fldunt{strcmp('time',h.fldnam)} = timunt;
[d, h] = copy_sensor(d, h, stn);

%find variables to copy, that are in both mcvars_to_average and the input file
var_copycell = mcvars_to_average(1);
var_copycell = intersect(h.fldnam, var_copycell, 'stable');
clear hnew dnew
hnew.dataname = h.dataname;
hnew.latitude = h.latitude;
hnew.longitude = h.longitude;
hnew.fldunt = {}; hnew.fldserial = {}; hnew.fldnam = {};
for no = 1:length(var_copycell)
    m = strcmp(var_copycell{no},h.fldnam);
    hnew.fldnam = [hnew.fldnam h.fldnam{m}];
    hnew.fldunt = [hnew.fldunt h.fldunt{m}];
    hnew.fldserial = [hnew.fldserial h.fldserial{m}];
    dnew.(var_copycell{no}) = d.(var_copycell{no});
    % m = strcmp([var_copycell{no} '_flag'],h.fldnam);
    % if sum(m)
    %     hnew.fldnam = [hnew.fldnam h.fldnam{m}];
    %     hnew.fldunt = [hnew.fldunt h.fldunt{m}];
    %     hnew.fldserial = [hnew.fldserial h.fldserial{m}];
    %     dnew.([var_copycell{no} '_flag']) = d.([var_copycell{no} '_flag']);
    % end
end
hnew = keep_hvatts(hnew, h);
hnew.comment = h.comment;

%average to 1hz, output to _1hz file
opt1 = 'ctd_proc'; opt2 = 'ctd_infiles'; run(MEXEC_G.opt_cruise) %what was the original frequency?
opt1 = 'ctd_proc'; opt2 = '1hz_interp'; run(MEXEC_G.opt_cruise) %parameters for averaging
tg = dnew.time(1):dnew.time(end)+1; %end will be truncated anyway by setting grid_ends to 0
if size(dnew.time,1)>1; tg = tg'; end
dnew0 = dnew;
dnew = grid_1D(dnew, 'time', tg, 'meannum', 'num', infiles.ctd_raw_hz, 'prefill', maxfillr, 'grid_ends', [0 0], 'postfill', maxfill1);
%at this stage all the input flag fields were either 2 or 7, so anything > 2 becomes 7
dnew = struct2table(dnew);
% m = cellfun(@(x) endsWith(x,'_flag'),dnew.Properties.VariableNames);
% f = dnew{:,m}; f(f>2) = 7; dnew{:,m} = f;
dnew = table2struct(dnew,'ToScalar',true);
mfsave(pfiles.ctd_1hz, dnew, hnew);

%average to 0.1hz, output to _10s file and svel.csv file
tg = [dnew0.time(1):10:dnew0.time(end)+1]; %end will be truncated anyway by setting grid_ends to 0
if size(dnew0.time,1)>1; tg = tg'; end
dnew = grid_1D(dnew0, 'time', tg, 'meannum', 'num', infiles.ctd_raw_hz*10, 'prefill', infiles.ctd_raw_hz*10, 'grid_ends', [0 0], 'postfill', 0);
%at this stage all the input flag fields were either 2 or 7, so anything > 2 becomes 7
dnew = struct2table(dnew);
% m = cellfun(@(x) endsWith(x,'_flag'),dnew.Properties.VariableNames);
% f = dnew{:,m}; f(f>2) = 7; dnew{:,m} = f;
md = dnew.press<max(dnew.press);
ds = [sw_dpth(dnew.press(md),dnew.latitude(md)) sw_svel(dnew.psal(md),dnew.temp(md),dnew.press(md))]';
dnew = table2struct(dnew,'ToScalar',true);
mfsave(file10, dnew, hnew);

fid = fopen(pfiles.svel,'w');
fprintf(fid,'depth (m), sound speed (m/s)\n');
fprintf(fid, '%f, %f\n', ds(:));
fclose(fid);
