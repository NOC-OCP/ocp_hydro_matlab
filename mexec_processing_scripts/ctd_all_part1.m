mctd_01; %read in sbe .cnv data to mstar

%apply corrections (e.g. oxygen hysteresis) and calibrations, as specified in opt_cruise
stn = stnlocal; mctd_02; 

stn = stnlocal; mctd_03; %average to 1 hz, compute salinity

if MEXEC_G.ix_ladcp
%    mout_1hzasc(stnlocal) %output 1 hz data in ascii format (required for LDEO IX LADCP processing)
end

stn = stnlocal; mdcs_01; % now does mdcs_01 and mdcs_02 in one step
