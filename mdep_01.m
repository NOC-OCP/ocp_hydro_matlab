% mdep_01: read water depth for ctd cast from ldeo ladcp or combined
% altimeter and depth readings
%
% Use: mdep_01        and then respond with station number, or for station 16
%      stn = 16; mdep_01;

scriptname = 'mdep_01';
cruise = MEXEC_G.MSCRIPT_CRUISE_STRING;

if ~exist('stn','var')
    stn = input('type stn number ');
end
stn_string = sprintf('%03d',stn);
stnlocal = stn; clear stn % so that it doesn't persist

mdocshow(scriptname, ['adds water depth from station_depths/station_depths_' cruise '.mat to all the files for station ' stn_string]);

% resolve root directories for various file types
root_win = mgetdir('M_CTD_WIN');
root_sal = mgetdir('M_BOT_SAL');
root_ctd = mgetdir('M_CTD');
root_dep = mgetdir('M_CTD_DEP');

deps_fn = [root_dep '/station_depths_' cruise '.mat'];
load(deps_fn);

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

close all

for kfile = 1:length(fn)
    mputdep(fn{kfile},bestdeps(stnlocal))
end
