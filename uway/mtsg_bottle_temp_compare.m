% compare 5m CTD temperature (top bottle) with tsg
%
% choose calibrated or uncalibrated data for comparison
% is there a script for calibrating tsg temp?***

mcruise = MEXEC_G.MSCRIPT_CRUISE_STRING;

scriptname = mfilename; oopt = 'usecal'; get_cropt;
usecallocal = usecal; clear usecal

scriptname = 'ship'; oopt = 'ship_data_sys_names'; get_cropt
root_tsg = mgetdir(tsgprefix);
root_bot = mgetdir('M_SAM');

if usecallocal
    tsgfn = [root_tsg '/' prefix '_' mcruise '_01_medav_clean_cal']; % median averaged file
else
    tsgfn = [root_tsg '/' prefix '_' mcruise '_01_medav_clean']; % median averaged file
end
[dt, ht] = mload(tsgfn, '/');
tempvar = mvarname_find({'housingtemp' 'temp_h' 'tstemp'},ht.fldnam);
salvar = mvarname_find({'salinity' 'psal'},ht.fldnam);
tempsst = mvarname_find({'remotetemp' 'temp_4' 'sstemp'},ht.fldnam);

if usecallocal
    tempvar = [tempvar '_cal'];
    calstr = 'cal';
else
    calstr = 'uncal';
end
        
botfn = [root_bot '/sam_' mcruise '_all'];

%***this script was unfinished, have pasted in the salinity comparison
%code, modify for temperature

[db, hb] = mload(botfn, '/');
db.time = m_commontime(db.time, hb.data_time_origin, ht.data_time_origin);
[db.time, iibot] = sort(db.time);
db.run1 = db.run1(iibot); db.run2 = db.run2(iibot); db.run3 = db.run3(iibot);
db.runavg = db.runavg(iibot); db.flag = db.flag(iibot);
db.salinity = db.salinity(iibot); db.salinity_adj = db.salinity_adj(iibot);
dt.time = dt.time/3600/24+1; 
db.time = db.time/3600/24+1;
[Y,ii] = min(abs(repmat(dt.time,[length(db.time),1])-repmat(db.time,[1,length(dt.time)])),[].2);
db.temp_h = dt.temp_h(ii); %jc191? dy120? dy129?***why are we doing this?***

tsal = dt.(salvar);
tsals = interp1(dt.time, tsal, db.time);
nsp = 2;
if exist('tempsst')
    tssts = interp1(dt.time, dt.(tempsst), db.time);
    nsp = 4;
end

scriptname = mfilename; oopt = 'dbbad'; get_cropt %NaN some of the db.salinity_adj points

sdiff = db.salinity_adj-tsals; %offset is bottle minus tsg, so that it is correction to be added to tsg
stdiff_std = nanstd(sdiff); sdiff_mean = nanmean(sdiff);
idx = find(abs(sdiff)>3*sdiff_std);
% List and discard possible outliers
if ~isempty(idx)
	fprintf(1,'\n Std deviation of bottle tsg - differnces is %7.3f \n',sdiff_std)
	fprintf(1,' The following are outliers to be checked: \n')
	fprintf(1,' Sample  Jday Time    Difference  \n')
	for ii = idx
		jdx = floor(db.time(i));
		fprintf(1,'  %2d  -  %d  %s  %7.3f \n',idx,jdx,datestr(db.time(ii),15),sdiff(ii))
	end
end
sdiff(idx) = NaN;
sdiffall = sdiff;


%smoothed difference--default is a two-pass filter on the whole time series
clear sdiffsm
scriptname = mfilename; oopt = 'sdiff'; get_cropt
if exist('sc1') & exist('sc2') & ~exist('sdiffsm')
    sdiffsm = filter_bak(ones(1,21),sdiff); % first filter
    sdiff(abs(sdiff-sdiffsm) > sc1) = NaN;
    sdiffsm = filter_bak(ones(1,21),sdiff); % harsh filter to determine smooth adjustment
    sdiff(abs(sdiff-sdiffsm) > sc2) = NaN;
    sdiffsm = filter_bak(ones(1,41),sdiff); % harsh filter to determine smooth adjustment
    if ~usecallocal; t = db.time-1; save([root_tsg '/sdiffsm'], 't', 'sdiffsm'); end
else
    warning(['sdiffsm not set; check opt_' mcruise])
    sdiffsm = NaN+sdiff;
end

figure(1); clf
subplot(nsp,1,1)
hl = plot(dt.time, tsal, db.time, db.salinity, '.y', db.time, db.salinity_adj, 'o', db.time, tsals, '<'); grid
legend(hl([1 3 4]), 'TSG','bottle','TSG')
ylabel('Salinity (psu)'); xlabel('yearday')
title([calstr ' TSG'])
xlim(dt.time([1 end]))
subplot(nsp,1,2)
plot(db.time, sdiffall, 'r+-',db.time, sdiffsm,' kx-'); grid
ylabel([calstr ' TSG salinity - bottle salinity (psu)']); xlabel('yearday')
xlim(dt.time([1 end]))
if nsp==4
    subplot(nsp,1,3)
    plot(tssts, sdiffall, 'r+', tssts, sdiffsm, 'kx'); grid
    xlabel('Sea Surface Temperature (^\circC)')
    ylabel([calstr ' TSG salinity - bottle salinity (psu)'])
    legend('Total Difference', 'Smoothed Difference');
    subplot(nsp,1,4)
    plot(tsals, sdiffall, 'r+', tsals, sdiffsm, 'kx'); grid
    xlabel([calstr ' TSG salinity (psu)'])
    ylabel([calstr ' TSG salinity - bottle salinity (psu)'])
end

disp('mean diff, median diff')
[nanmean(sdiff) nanmedian(sdiff)]
disp('RMS of residuals:')
rms_res = sqrt(sum(sdiff(~isnan(sdiff)).^2))
disp('stderr:')
stde = sqrt(sum(sdiff(~isnan(sdiff)).^2)/(sum(~isnan(sdiff))-1))

if ~usecallocal
    disp(['choose a constant or simple time-dependent correction for TSG, add to tsgsal_apply_cal case of opt_' mcruise])
    disp(['you can set it so tsgsal_apply_cal calculates the smooth function shown here'])
end

