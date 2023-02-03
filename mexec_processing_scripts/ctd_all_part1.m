mctd_01; %read in sbe .cnv data to mstar

root_ctd = mgetdir('M_CTD');
[d, h] = mloadq(otfile, 'press', ' ');
if min(d.press)<=-10
    m = {['negative pressures <-10 in ctd_' mcruise '_' stn_string '_raw']
    'check d.press here; if there are large spikes also affecting temperature, dbquit'
    ['here, edit mctd_01 case in opt_' mcruise ', and reprocess this station.']
    'Otherwise, you may want to edit mctd_02 case (rawedit_auto) to remove large'
    'outlier values in pressure before the mctd_rawedit gui stage.'};
    warning(sprintf('%s\n',m{:}));
    keyboard
end

%apply corrections (e.g. oxygen hysteresis) and calibrations, as specified in opt_cruise
stn = stnlocal; mctd_02; 

stn = stnlocal; mctd_03; %average to 1 hz, compute salinity

stn = stnlocal; mdcs_01; % now does mdcs_01 and mdcs_02 in one step

if MEXEC_G.ix_ladcp
    mout_1hzasc(stnlocal) %output 1 hz data in ascii format (required for LDEO IX LADCP processing)
end
