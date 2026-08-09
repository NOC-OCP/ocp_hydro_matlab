function msbe_03_derive_tbin(stn)
% mctd_03:
%
% input: _24hz
%
%   copy data from sensors chosen in opt_cruise to temp, cond, and oxygen; 
%   calculate psal, asal, potemp using GSW;
%   average to 1 hz and 0.1 hz and fill gaps as set in opt_cruise
%
% outputs: _24hz with added variables
%          _1hz (1 hz, used for plots and ladcp)
%          _10s (approx 10 dbar on downcase; used for quick plots to check msbe_02 corrections)
%
%
% calls: 
%     mloadq
%     grid_profile
%     gsw functions
%     mfsave

m_common; MEXEC_A.mprog = mfilename;
if MEXEC_G.quiet<=1; fprintf(1,'choosing preferred sensor, computing salinity, averaging to 1 hz for ctd_%s_%s_psal.nc\n',mcruise,stn_string); end

pd = mexec_file_locations('procfiles','ctd');
file24 = sprintf(pd.ctd24,stn_string);
file1 = sprintf(pd.ctd1,stn_string);
file10 = sprintf(pd.ctd10s,stn_string);
filesv = sprintf(pd.svel,stn_string);

%calculate derived variables
[d, h] = mloadq(file24,'/');
iig = find(d.press>-1.495); %gsw won't work on p<=-1.495
if length(iig)<length(d.press)
    m = {'negative pressures < -1.495 found, psal etc. will not be calculated for these points'};
    if min(d.press<-10)
        m = [m; 'you may also want to check in mctd_rawshow and set rangelim under mctd_02';
            'case in opt_' mcruise ' in case pressure spikes need to be edited out'];
        warning('%s\n',m{:});
    end
end
cu = {'S/m', 'mS/cm'; 10, 1};
m = strcmp(cu(1,:),h.fldunt{strcmp(h.fldnam,'cond1')});
if sum(m)
    csc = cu{2,m};
else
    warning('conductivity units not recognised, should be S/m or mS/cm')
    csc = NaN;
end
d.psal1 = NaN+d.cond1; d.psal1(iig) = gsw_SP_from_C(d.cond1(iig)*csc,d.temp1(iig),d.press(iig));
d.psal2 = NaN+d.cond2; d.psal2(iig) = gsw_SP_from_C(d.cond2(iig)*csc,d.temp2(iig),d.press(iig));
d.asal1 = NaN+d.cond1; d.asal1(iig) = gsw_SA_from_SP(d.psal1(iig),d.press(iig),h.longitude,h.latitude);
d.asal2 = NaN+d.cond2; d.asal2(iig) = gsw_SA_from_SP(d.psal2(iig),d.press(iig),h.longitude,h.latitude);
d.potemp1 = NaN+d.cond1; d.potemp1(iig) = gsw_pt0_from_t(d.asal1(iig),d.temp1(iig),d.press(iig));
d.potemp2 = NaN+d.cond2; d.potemp2(iig) = gsw_pt0_from_t(d.asal2(iig),d.temp2(iig),d.press(iig));
% d.psal1_flag = max([d.cond1_flag,d.temp1_flag,d.press_flag],2);
% d.psal2_flag = max([d.cond2_flag,d.temp2_flag,d.press_flag],2);
% d.potemp1_flag = d.psal1_flag; d.potemp2_flag = d.psal2_flag;
% d.asal1_flag = d.psal1_flag; d.asal2_flag = d.psal2_flag;

%new variable names and units
hnew.fldnam = {'psal1' 'psal2' 'asal1' 'asal2' 'potemp1' 'potemp2'};
hnew.fldunt = {'pss-78' 'pss-78' 'g/kg' 'g/kg' 'degc90' 'degc90'};
% hnew.fldnam = [hnew.fldnam 'psal1_flag' 'psal2_flag' 'asal1_flag' 'asal2_flag' 'potemp1_flag' 'potemp2_flag'];
% hnew.fldunt = [hnew.fldunt 'woce' 'woce' 'woce' 'woce' 'woce' 'woce'];
hnew.fldserial = repmat({' '},1,6);
[h.fldnam,ia,ib] = union(h.fldnam,hnew.fldnam,'stable'); 
h.fldunt = [h.fldunt(ia) hnew.fldunt(ib)];
h.fldserial = [h.fldserial(ia) hnew.fldserial(ib)];
d = orderfields(d,h.fldnam);
cstr = 'psal, asal, potemp calculated using gsw';
if ~contains(h.comment, cstr)
    h.comment = [h.comment '\n ' cstr];
end

tic
%save to _24hz file
mfsave(file24, d, h);
toc

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
opt1 = 'ctd_proc'; opt2 = '1hz_interp'; get_cropt
tg = [dnew.time(1):dnew.time(end)+1]; %end will be truncated anyway by setting grid_ends to 0
if size(dnew.time,1)>1; tg = tg'; end
dnew0 = dnew;
dnew = grid_profile(dnew, 'time', tg, 'meannum', 'num', 24, 'prefill', maxfill24, 'grid_ends', [0 0], 'postfill', maxfill1);
%at this stage all the input flag fields were either 2 or 7, so anything > 2 becomes 7
dnew = struct2table(dnew);
% m = cellfun(@(x) endsWith(x,'_flag'),dnew.Properties.VariableNames);
% f = dnew{:,m}; f(f>2) = 7; dnew{:,m} = f;
dnew = table2struct(dnew,'ToScalar',true);
mfsave(file1, dnew, hnew);

%average to 0.1hz, output to _10s file and svel.csv file
tg = [dnew0.time(1):10:dnew0.time(end)+1]; %end will be truncated anyway by setting grid_ends to 0
if size(dnew0.time,1)>1; tg = tg'; end
dnew = grid_profile(dnew0, 'time', tg, 'meannum', 'num', 240, 'prefill', 240, 'grid_ends', [0 0], 'postfill', 0);
%at this stage all the input flag fields were either 2 or 7, so anything > 2 becomes 7
dnew = struct2table(dnew);
% m = cellfun(@(x) endsWith(x,'_flag'),dnew.Properties.VariableNames);
% f = dnew{:,m}; f(f>2) = 7; dnew{:,m} = f;
md = dnew.press<max(dnew.press);
ds = [sw_dpth(dnew.press(md),dnew.latitude(md)) sw_svel(dnew.psal(md),dnew.temp(md),dnew.press(md))]';
dnew = table2struct(dnew,'ToScalar',true);
mfsave(file10, dnew, hnew);
fid = fopen(filesv,'w');
fprintf(fid,'depth (m), sound speed (m/s)\n');
fprintf(fid, '%f, %f\n', ds(:));
fclose(fid);
