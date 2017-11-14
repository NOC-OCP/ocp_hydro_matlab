% bak jc069 compare bottles and tsg data
% overhauled on jr281, based on jr069 version, to be suitable for any ship
%
% choose calibrated or uncalibrated data for comparison

scriptname = 'mtsg_bottle_compare';
cruise = MEXEC_G.MSCRIPT_CRUISE_STRING;
oopt = '';

cal = 'cal';
%cal = 'uncal';

switch MEXEC_G.Mship
    case 'cook'
        prefix = 'met_tsg';
        salvar = 'psal'; % salinity var in tsg data stream
        tempvar = 'temp_h'; % housing temp
        condvar = 'cond'; % conductivity
    case 'jcr'
        prefix = 'ocl';
        salvar = 'salinity'; % salinity vars in tsg data stream
        tempvar = 'tstemp'; % housing temp
        condvar = 'conductivity'; % conductivity
end
root_tsg = mgetdir(prefix);
root_bot = mgetdir('M_BOT_SAL');
prefix1 = [prefix '_' cruise '_'];

switch cal
   case 'uncal'
      tsgfn = [root_tsg '/' prefix1 '01_medav_clean']; % median averaged file
   case 'cal'
      tsgfn = [root_tsg '/' prefix1 '01_medav_clean_cal']; % median averaged file
      salvar = [salvar '_cal'];
end

botfn = [root_bot '/' 'tsg_' cruise '_all'];

[dt, ht] = mload(tsgfn, '/');
[db, hb] = mload(botfn, '/');
dt.time = dt.time/3600/24+1; db.time = db.time/3600/24+1;

tsal = getfield(dt, salvar);
tsals = interp1(dt.time, tsal, db.time);

oopt = 'dbbad'; get_cropt %NaN some of the db.salinity_adj points

sdiff = db.salinity_adj-tsals;
sdiffall = sdiff;
oopt = 'sdiff'; get_cropt

figure(1); clf
subplot(211)
plot(dt.time, tsal, db.time, db.salinity_adj, 'o', db.time, tsals, '<')
legend('TSG','bottle','TSG')
ylabel('salinity (psu)'); xlabel('yearday')
subplot(212)
plot(db.time,sdiffall,'r+',db.time,sdiffsm,'kx')
ylabel('bottle salinity - TSG salinity (psu)'); xlabel('yearday')
disp(['choose a constant or simple time-dependent correction for TSG, add to tsgsal_apply_cal case of opt_' cruise])
