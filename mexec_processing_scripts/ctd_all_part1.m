msbe_01_load(stn); %read in sbe .cnv data to mstar
opt1 = 'ctd_proc'; opt2 = 'ctd_raw_extra'; get_cropt
if exist('ctd_raw_extra','var')
    eval(ctd_raw_extra)
end
mfir_01_load(stn) %sbe .bl file to mstar

%apply corrections (e.g. oxygen hysteresis) and calibrations, as specified in opt_cruise
msbe_02_edcal(stn); 

msbe_03_1hz(stn); %average to 1 hz, compute salinity

global MEXEC_G
if isfield(MEXEC_G,'ix_ladcp') && MEXEC_G.ix_ladcp
    mout_1hzasc(stn) %output 1 hz data in ascii format (required for LDEO IX LADCP processing)
end

mdcs_01_auto(stn); % now does mdcs_01 and mdcs_02 in one step