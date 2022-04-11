% winch_analysis: analyse bottle stop times
%
% Use: winch_analysis        and then respond with station number, or for station 16
%      stn = 16; winch_analysis;
% 
% fills variables all_s1 and all_s2 which are the number of seconds winch
% is stopped (as measured by rate = 0) before bottle fire and after bottle
% fire. One way to use this script is to create empty vars all_s1 and
% all_s2, and then run this script for a series of stations.

scriptname = 'winch_analysis';

if exist('stn','var')
    m = ['Running script ' scriptname ' on station ' sprintf('%03d',stn)];
    fprintf(MEXEC_A.Mfidterm,'%s\n',m)
else
    stn = input('type stn number ');
end
stn_string = sprintf('%03d',stn);
stnlocal = stn;
clear stn % so that it doesn't persist

root_win = mgetdir('M_CTD_WIN');
root_ctd = mgetdir('M_CTD');
prefix1 = fullfile(root_win, ['win_' MEXEC_G.MSCRIPT_CRUISE_STRING '_']);
prefix2 = fullfile(root_ctd, ['sam_' MEXEC_G.MSCRIPT_CRUISE_STRING '_']);

infile1 = [prefix1 stn_string];
infile2 = [prefix2 stn_string];

if exist(m_add_nc(infile1)) ~= 2; return; end
if exist(m_add_nc(infile2)) ~= 2; return; end

[dw hw] = mload(infile1,'/');
[ds hs] = mload(infile2,'/');

wrate = dw.rate;
wtime = datenum(hw.data_time_origin) + dw.time/86400;
wout = dw.cablout;

window = 300; % forward and backwood look window in seconds to look for stopped winch
window = window/86400;

nb = length(ds.time);
w_s1 = nan+zeros(nb,1); w_s2 = w_s1;

for kb = 1:nb
    bottle_time = datenum(hs.data_time_origin) + ds.time(kb)/86400;
    bottle_cablout = ds.wireout(kb);
    if isnan(bottle_time); continue; end
    if isnan(bottle_cablout); continue; end
    w_dc1 = min(find(wtime > (bottle_time-window) & wrate == 0 & abs(wout-bottle_cablout) < 10));
    if isempty(w_dc1); continue; end
    w_t1 = wtime(w_dc1);
    w_s1(kb) = 86400*(bottle_time-w_t1); % duration of stop before bottle

    w_dc2 = max(find(wtime < (bottle_time+window) & wrate == 0 & abs(wout-bottle_cablout) < 10));
    if isempty(w_dc2); continue; end
    w_t2 = wtime(w_dc2);
    w_s2(kb) = 86400*(w_t2 - bottle_time); % duration of stop after bottle
end

w_tot = round(w_s1+w_s2);

all_s1(:,stnlocal) = w_s1;
all_s2(:,stnlocal) = w_s2;
