% winch_analysis: analyse bottle stop times
%
% Use: winch_analysis        and then respond with station number, or for station 16
%      stn = 16; winch_analysis;
% 
% fills variables all_s1 and all_s2 which are the number of seconds winch
% is stopped (as measured by rate = 0) before bottle fire and after bottle
% fire. One way to use this script is to create empty vars all_s1 and
% all_s2, and then run this script for a series of stations.

scriptname = 'approach_station_analysis';

if exist('stn','var')
    m = ['Running script ' scriptname ' on station ' sprintf('%03d',stn)];
    fprintf(MEXEC_A.Mfidterm,'%s\n',m)
else
    stn = input('type stn number ');
end
stn_string = sprintf('%03d',stn);
stnlocal = stn;
clear stn % so that it doesn't persist

mcd('M_CTD_WIN'); root_win = MEXEC_G.MEXEC_CWD;
mcd('M_CTD'); % change working directory
% root_win = './WINCH';
% MEXEC_G.MSCRIPT_CRUISE_STRING = 'jc032';

% temporary hardwire
bstfile = ['../nav/gps4000/bst_' MEXEC_G.MSCRIPT_CRUISE_STRING '_01'];

prefix1 = [root_win '/win_' MEXEC_G.MSCRIPT_CRUISE_STRING '_'];
prefix2 = ['dcs_' MEXEC_G.MSCRIPT_CRUISE_STRING '_'];

% prefix2 = ['/noc/users/pstar/archive_from_jc/JC032/done_tars/z/ctd/dcs_jc032_']
% prefix1 = ['/noc/users/pstar/archive_from_jc/JC032/done_tars/z/rvsrawdatapup/bestnav.nc']


infile1 = [prefix1 stn_string];
infile1 = bstfile;
infile2 = [prefix2 stn_string];

if exist(m_add_nc(infile1)) ~= 2; return; end
if exist(m_add_nc(infile2)) ~= 2; return; end

[db hb] = mload(infile1,'/'); % nav
[dd hd] = mload(infile2,'/'); % dcs

stn_start = datenum(hd.data_time_origin) + dd.time_start/86400;
stn_end = datenum(hd.data_time_origin) + dd.time_end/86400;

nav_time = datenum([2010 1 1 0 0 0]) + db.time/86400; 
nav_smg = db.smg; 

window = 3000; % forward and backward look window in seconds to look for slowing ship
window = window/86400;

w_s1 = nan; w_s2 = w_s1;

    if isnan(stn_start); continue; end
    w_dc1 = min(find(nav_time > (stn_start-window) & nav_smg < 4)); % 2 m/s = 4 knots
    if isempty(w_dc1); continue; end
    w_t1 = nav_time(w_dc1);
    w_s1 = 86400*(stn_start-w_t1); % duration of slowing before start of cast

    w_dc2 = max(find(nav_time < (stn_end+window) & nav_smg < 4));
    if isempty(w_dc2); continue; end
    w_t2 = nav_time(w_dc2);
    w_s2 = 86400*(w_t2 - stn_end); % duration of stop after bottle

w_tot = round(w_s1+w_s2);

all_s1(stnlocal) = w_s1;
all_s2(stnlocal) = w_s2;
