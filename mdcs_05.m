% mdcs_05: apply positions to set of files
%
% Use: mdcs_05        and then respond with station number, or for station 16
%      stn = 16; mdcs_05;

scriptname = 'mdcs_05';
cruise = MEXEC_G.MSCRIPT_CRUISE_STRING;

if ~exist('stn','var')
    stn = input('type stn number ');
end
stn_string = sprintf('%03d',stn);
stnlocal = stn; clear stn % so that it doesn't persist

mdocshow(scriptname, ['pastes lat and lon into ctd_' cruise '_' stn_string '*.nc']);

root_win = mgetdir('M_CTD_WIN');
root_sal = mgetdir('M_BOT_SAL');
root_ctd = mgetdir('M_CTD'); % change working directory

prefix1 = ['ctd_' cruise '_'];
prefix2 = ['fir_' cruise '_'];
prefix3 = ['sal_' cruise '_']; 
prefix4 = ['sam_' cruise '_'];
prefix5 = ['dcs_' cruise '_'];
prefix6 = ['win_' cruise '_'];

clear fn
fn{1} = [root_ctd '/' prefix5 stn_string];

%modified YLF jr15003
if exist([root_ctd '/' prefix1 stn_string '_raw_original.nc'], 'file');
   fn{2} = [root_ctd '/' prefix1 stn_string '_raw_original'];
   fn{18} = [root_ctd '/' prefix1 stn_string '_raw_cleaned'];
else
   fn{2} = [root_ctd '/' prefix1 stn_string '_raw'];
end
fn{3} = [root_ctd '/' prefix1 stn_string '_24hz'];
fn{4} = [root_ctd '/' prefix1 stn_string '_1hz'];
fn{5} = [root_ctd '/' prefix1 stn_string '_psal'];
fn{6} = [root_ctd '/' prefix1 stn_string '_surf'];
fn{7} = [root_ctd '/' prefix1 stn_string '_2db'];

fn{8} = [root_ctd '/' prefix2 stn_string '_bl'];
fn{9} = [root_ctd '/' prefix2 stn_string '_time'];
fn{10} = [root_ctd '/' prefix2 stn_string '_winch'];
fn{11} = [root_ctd '/' prefix2 stn_string '_ctd'];

fn{12} = [root_sal '/' prefix3 stn_string];

fn{13} = [root_ctd '/' prefix4 stn_string];
fn{14} = [root_ctd '/' prefix4 stn_string '_resid'];
fn{15} = [root_ctd '/' prefix5 stn_string '_pos'];
fn{16} = [root_win '/' prefix6 stn_string];
fn{17} = [root_ctd '/' prefix1 stn_string '_2up']; % extra file, upcast 2db on jc069, where profile corresponding to upcast tracer data is required


filename = m_add_nc(fn{1});
if ~exist(filename,'file')
    m = ['File ' filename ' does not exist yet'];
    fprintf(MEXEC_A.Mfider,'%s\n',m)
    return
end

% bak on jr281 april 2013. If the position isnt available from the dcs
% file, take it from the raw file instead, which should have been set using
% posinfo at the time that file was created
if exist(m_add_nc(fn{15}),'file') == 2
    
    % jr193 at noc revert to collecting position from dcs file
    [d h] = mload(fn{15},'statnum','lat_bot','lon_bot',' ');
    
    % allow for the possibility that the dcs file contains many stations
    
    kf = find(d.statnum == stnlocal);
    latbot = d.lat_bot(kf(1));
    lonbot = d.lon_bot(kf(1));
elseif exist(m_add_nc(fn{2}),'file') == 2
    h = m_read_header(fn{2});
    latbot = h.latitude;
    lonbot = h.longitude; % bak on jr302 jun 2014: bug fix typo in name longitude. Obviously this branch of code had never been entered before
else
    msg = ['No source found for position on station ' stn_string];
    fprintf(MEXEC_A.Mfider,'%s\n',msg);
    return
end

for kfile = 1:length(fn)
    mputpos(fn{kfile},latbot,lonbot)
end
