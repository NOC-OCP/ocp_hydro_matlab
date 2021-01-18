% mdcs_05: apply positions to set of files
%
% Use: mdcs_05        and then respond with station number, or for station 16
%      stn = 16; mdcs_05;
%
% from jc191 and jc211, maintain station summary file up to date and use
% as (editable) master file for positions as first choice
% if not available, from jc211, warn and use position from dcs file

minit; scriptname = mfilename;
mdocshow(scriptname, ['pastes lat and lon into header of ctd_' mcruise '_' stn_string '*.nc']);

root_win = mgetdir('M_CTD_WIN');
root_sal = mgetdir('M_BOT_SAL');
root_ctd = mgetdir('M_CTD'); % change working directory
root_sum = mgetdir('M_SUM');

%get position
latbot = []; lonbot = [];
writepos = 0;
try
    %first choice: station summary file
    d = mload([root_sum '/station_summary_' mcruise '_all.nc'],'statnum','lat','lon');
    ks = find(d.statnum == stnlocal);
    latbot = d.lat(ks);
    lonbot = d.lon(ks);
    if ~isfinite(latbot+lonbot); error; end
    writepos = 1;
catch
    warning(['no position in station_summary_ ' mcruise '_all.nc for station ' stn_string])
    try
        %second choice: dcs pos file position at bottom of cast (from
        %underway stream)
        d = mload([root_ctd '/dcs_' mcruise '_' stn_string '_pos.nc'],'statnum','lat_bot','lon_bot');
        ks = find(d.statnum == stnlocal);
        latbot = d.lat_bot(ks);
        lonbot = d.lon_bot(ks);
        if ~isfinite(latbot+lonbot); error; end
    catch
        %third choice: raw file header position (entered by CTD
        %operator)***keep this option or not?
        warning(['nor in dcs_' mcruise '_' stn_string '_pos; using header position from ctd_' mcruise '_' stn_sring '_raw.nc'])
        filer = [root_ctd '/ctd_' mcruise '_' stn_string '_raw'];
        if exist(filer, 'file')
            h = m_read_header(filer);
        elseif exist([filer '_cleaned'], 'file')
            h = m_read_header([filer '_cleaned']);
        else
            h.latitude = NaN; h.longitude = NaN;
        end
        latbot = h.latitude;
        lonbot = h.longitude;
        if ~isfinite(latbot+lonbot); error(['no position in any of the files in mdcs_05 for station ' stn_string]); end
    end
end

%files to which to add this position
clear fn
n = 1;
if writepos
    %only write to dcs pos file with "better" data from station summary
    fn{n} = [root_ctd '/dcs_' mcruise '_' stn_string '_pos']; n = n+1;
end
fn{n} = [root_ctd '/dcs_' mcruise '_' stn_string]; n = n+1;

if exist([root_ctd '/ctd_' mcruise '_' stn_string '_raw_original.nc'], 'file');
    fn{n} = [root_ctd '/ctd_' mcruise '_' stn_string '_raw_original']; n = n+1;
    fn{n} = [root_ctd '/ctd_' mcruise '_' stn_string '_raw_cleaned']; n = n+1;
else
    fn{n} = [root_ctd '/ctd_' mcruise '_' stn_string '_raw']; n = n+1;
end
fn{n} = [root_ctd '/ctd_' mcruise '_' stn_string '_24hz']; n = n+1;
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

for kfile = 1:length(fn)
    if exist(fn{kfile}, 'file')
        mputpos(fn{kfile},latbot,lonbot)
    end
end
