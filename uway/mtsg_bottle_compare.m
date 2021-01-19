% bak jc069 compare bottles and tsg data
% overhauled on jr281, based on jr069 version, to be suitable for any ship
%
% choose calibrated or uncalibrated data for comparison

minit

oopt = 'usecal'; scriptname = mfilename; get_cropt;
usecallocal = usecal; clear usecal

oopt = 'shiptsg'; scriptname = mfilename; get_cropt
switch MEXEC_G.Mship
    case {'cook','discovery'}
        salvar = 'psal'; % salinity var in tsg data stream
        tempvar = 'temp_h'; % housing temp
        tempsst = 'temp_r'; % remote temp
        condvar = 'cond'; % conductivity
    case 'jcr'
        salvar = 'salinity'; % salinity var in tsg data stream
        tempvar = 'tstemp'; % housing temp
        condvar = 'conductivity'; % conductivity
        tempsst = 'sstemp'; % "sea surface" temperature?
end
root_tsg = mgetdir(prefix);
root_bot = mgetdir('M_BOT_SAL');
prefix1 = [prefix '_' mcruise '_'];

if usecallocal
    tsgfn = [root_tsg '/' prefix1 '01_medav_clean_cal']; % median averaged file
    salvar = [salvar '_cal'];
    calstr = 'cal';
else
    tsgfn = [root_tsg '/' prefix1 '01_medav_clean']; % median averaged file
    calstr = 'uncal';
end

botfn = [root_bot '/' 'tsg_' mcruise '_all'];

[dt, ht] = mload(tsgfn, '/');
[db, hb] = mload(botfn, '/');
[db.time, iibot] = sort(db.time);
db.run1 = db.run1(iibot); db.run2 = db.run2(iibot); db.run3 = db.run3(iibot);
db.runavg = db.runavg(iibot); db.flag = db.flag(iibot);
db.salinity = db.salinity(iibot); db.salinity_adj = db.salinity_adj(iibot);
dt.time = dt.time/3600/24+1; 
db.time = db.time/3600/24+1;
[Y,ii] = min(abs(repmat(dt.time,[length(db.time),1])-repmat(db.time,[1,length(dt.time)])),[].2);
db.temp_h = dt.temp_h(ii); %jc191? dy120? dy129?***why are we doing this?***

tsal = getfield(dt, salvar);
tsals = interp1(dt.time, tsal, db.time);
nsp = 2;
if exist('tempsst')
    tsst = getfield(dt, tempsst);
    tssts = interp1(dt.time, tsst, db.time);
    nsp = 4;
end

oopt = 'dbbad'; scriptname = mfilename; get_cropt %NaN some of the db.salinity_adj points

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
oopt = 'sdiff'; scriptname = mfilename; get_cropt
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
