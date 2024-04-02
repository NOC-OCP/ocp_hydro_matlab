mctd_01(stn); %read in sbe .cnv data to mstar
mfir_01(stn) %sbe .bl file to mstar

%apply corrections (e.g. oxygen hysteresis) and calibrations, as specified in opt_cruise
mctd_02(stn); 

mctd_03(stn); %average to 1 hz, compute salinity

if MEXEC_G.ix_ladcp
    mout_1hzasc(stn) %output 1 hz data in ascii format (required for LDEO IX LADCP processing)
end

mdcs_01(stn); % now does mdcs_01 and mdcs_02 in one step
