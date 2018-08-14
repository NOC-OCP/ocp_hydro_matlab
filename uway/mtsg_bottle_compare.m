% bak jc069 compare bottles and tsg data
% overhauled on jr281, based on jr069 version, to be suitable for any ship
%
% choose calibrated or uncalibrated data for comparison

scriptname = 'mtsg_bottle_compare';
mcruise = MEXEC_G.MSCRIPT_CRUISE_STRING;
oopt = '';

%cal = 'cal';
cal = 'uncal';

switch MEXEC_G.Mship
    case 'cook'
        prefix = 'met_tsg';
        salvar = 'psal'; % salinity var in tsg data stream
        tempvar = 'temp_h'; % housing temp
        condvar = 'cond'; % conductivity
    case 'discovery'
        prefix = 'met_tsg';
	salvar = 'salin';
	tempvar = 'temp_h';
	condvar = 'cond';
    case 'jcr'
        prefix = 'oceanlogger';
        salvar = 'salinity'; % salinity var in tsg data stream
        tempvar = 'tstemp'; % housing temp
        condvar = 'conductivity'; % conductivity
end
root_tsg = mgetdir(prefix);
root_bot = mgetdir('M_BOT_SAL');
prefix1 = [prefix '_' mcruise '_'];

switch cal
   case 'uncal'
      tsgfn = [root_tsg '/' prefix1 '01_medav_clean']; % median averaged file
   case 'cal'
      tsgfn = [root_tsg '/' prefix1 '01_medav_clean_cal']; % median averaged file
      salvar = [salvar '_cal'];
end

botfn = [root_bot '/' 'tsg_' mcruise '_all'];

[dt, ht] = mload(tsgfn, '/');
[db, hb] = mload(botfn, '/');
[db.time, iibot] = sort(db.time);
db.run1 = db.run1(iibot); db.run2 = db.run2(iibot); db.run3 = db.run3(iibot);
db.runavg = db.runavg(iibot); db.flag = db.flag(iibot);
db.salinity = db.salinity(iibot); db.salinity_adj = db.salinity_adj(iibot); 
dt.time = dt.time/3600/24+1; db.time = db.time/3600/24+1;

tsal = getfield(dt, salvar);
tsals = interp1(dt.time, tsal, db.time);

oopt = 'dbbad'; get_cropt %NaN some of the db.salinity_adj points

sdiff = db.salinity_adj-tsals;
sdiffall = sdiff;

%smoothed difference--default is a two-pass filter on the whole time series
clear sdiffsm
oopt = 'sdiff'; get_cropt
if exist('sc1') & exist('sc2') & ~exist('sdiffsm')
   sdiffsm = filter_bak(ones(1,21),sdiff); % first filter
   sdiff(abs(sdiff-sdiffsm) > sc1) = NaN;
   sdiffsm = filter_bak(ones(1,21),sdiff); % harsh filter to determine smooth adjustment
   sdiff(abs(sdiff-sdiffsm) > sc2) = NaN;
   sdiffsm = filter_bak(ones(1,41),sdiff); % harsh filter to determine smooth adjustment
   if strcmp(cal, 'uncal'); t = db.time-1; save([root_tsg '/sdiffsm'], 't', 'sdiffsm'); end
else
   warning(['sdiffsm not set; check opt_' mcruise])
   sdiffsm = NaN+sdiff;
end

figure(1); clf
subplot(211)
hl = plot(dt.time, tsal, db.time, db.salinity, '.y', db.time, db.salinity_adj, 'o', db.time, tsals, '<'); grid
legend(hl([1 3 4]), 'TSG','bottle','TSG')
ylabel('salinity (psu)'); xlabel('yearday')
title([cal ' TSG'])
subplot(212)
plot(db.time, sdiffall, 'r+-',db.time, sdiffsm,' kx-'); grid
ylabel('bottle salinity - TSG salinity (psu)'); xlabel('yearday')

disp('RMS of residuals:')
rms_res = sqrt(sum(sdiff(~isnan(sdiff)).^2))
disp('stderr:')
stde = sqrt(sum(sdiff(~isnan(sdiff)).^2)/(sum(~isnan(sdiff))-1))

if strcmp(cal, 'cal')
   disp(['choose a constant or simple time-dependent correction for TSG, add to tsgsal_apply_cal case of opt_' mcruise])
   disp(['you can set it so tsgsal_apply_cal calculates the smooth function shown here'])
end
