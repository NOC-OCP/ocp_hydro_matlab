% mdcs_05: apply positions to set of files
%
% Use: mdcs_05        and then respond with station number, or for station 16
%      stn = 16; mdcs_05;

minit; scriptname = mfilename;
mdocshow(scriptname, ['pastes lat and lon into header of ctd_' mcruise '_' stn_string '*.nc']);

root_win = mgetdir('M_CTD_WIN');
root_sal = mgetdir('M_BOT_SAL');
root_ctd = mgetdir('M_CTD'); % change working directory

clear fn
n = 1;
fn{n} = [root_ctd '/dcs_' mcruise '_' stn_string '_pos']; n = n+1; iipos = n-1;
fn{n} = [root_ctd '/dcs_' mcruise '_' stn_string]; n = n+1; 

%modified YLF jr15003
if exist([root_ctd '/ctd_' mcruise '_' stn_string '_raw_original.nc'], 'file');
   fn{n} = [root_ctd '/ctd_' mcruise '_' stn_string '_raw_original']; n = n+1;
   fn{n} = [root_ctd '/ctd_' mcruise '_' stn_string '_raw_cleaned']; n = n+1;
else
   fn{n} = [root_ctd '/ctd_' mcruise '_' stn_string '_raw']; n = n+1;
end
iiraw = n-1;
fn{n} = [root_ctd '/ctd_' mcruise '_' stn_string '_24hz']; n = n+1;
fn{n} = [root_ctd '/ctd_' mcruise '_' stn_string '_1hz']; n = n+1;
fn{n} = [root_ctd '/ctd_' mcruise '_' stn_string '_psal']; n = n+1;
%fn{n} = [root_ctd '/ctd_' mcruise '_' stn_string '_surf']; n = n+1;
fn{n} = [root_ctd '/ctd_' mcruise '_' stn_string '_2db']; n = n+1;
fn{n} = [root_ctd '/ctd_' mcruise '_' stn_string '_2up']; n = n+1;

fn{n} = [root_win '/win_' mcruise '_' stn_string]; n = n+1;
fn{n} = [root_ctd '/fir_' mcruise '_' stn_string '_bl']; n = n+1;
fn{n} = [root_ctd '/fir_' mcruise '_' stn_string '_time']; n = n+1;
fn{n} = [root_ctd '/fir_' mcruise '_' stn_string '_winch']; n = n+1;
fn{n} = [root_ctd '/fir_' mcruise '_' stn_string '_ctd']; n = n+1;

fn{n} = [root_sal '/sal_' mcruise '_' stn_string]; n = n+1;
fn{n} = [root_ctd '/sam_' mcruise '_' stn_string]; n = n+1;
%fn{n} = [root_ctd '/sam_' mcruise '_' stn_string '_resid']; n = n+1;


filename = m_add_nc(fn{1});
if ~exist(filename,'file')
   m = ['File ' filename ' does not exist yet'];
   fprintf(MEXEC_A.Mfider,'%s\n',m)
   return
end

latbot = [];
useraw = 0;
if exist(m_add_nc(fn{iipos}),'file') == 2 %default is to get from dcs file
   h = m_read_header(fn{iipos}); 
   if sum(strcmp('lat_bot',h.fldnam))==0
       warning(['no cast bottom position in ' fn{iipos}])
       useraw = 1;
   else
      d = mload(fn{iipos},'statnum','lat_bot','lon_bot',' ');
      % allow for the possibility that the dcs file contains many stations
      kf = find(d.statnum == stnlocal);
      latbot = d.lat_bot(kf(1));
      lonbot = d.lon_bot(kf(1));
      if isnan(latbot+lonbot); useraw = 1; end
   end
elseif exist(m_add_nc(fn{iiraw}),'file') == 2; useraw = 1; end
if useraw %if position wasn't found in dcs file, take it from the raw file instead
   h = m_read_header(fn{iiraw});
   latbot = h.latitude;
   lonbot = h.longitude;
end
if isempty(latbot) | isnan(latbot)
   msg = ['No source found for position on station ' stn_string];
   fprintf(MEXEC_A.Mfider,'%s\n',msg);
   return
end

for kfile = 1:length(fn)
   mputpos(fn{kfile},latbot,lonbot)
end
