%apply temperature and conductivity calibrations (set in temp_apply_cal and cond_apply_cal)
%and rerun scripts to incorporate them
    
scriptname = 'smallscript';
mcruise = MEXEC_G.MSCRIPT_CRUISE_STRING;
oopt = '';

if ~exist('klist'); oopt = 'klist'; get_cropt; end
root_sbe35 = mgetdir('M_SBE35');
if exist(root_sbe35, 'dir'); sbe35 = 1; else; sbe35 = 0; end

for kloop = klist

    %stn = kloop; mctd_02b %uncomment this line if you modify the calibration
    %and need to regenerate the 24hz from the raw file before applying the
    %new one to previously-calibrated stations
    
    if sbe35
       stn = kloop; senscal = 1; mctd_tempcal
       stn = kloop; senscal = 2; mctd_tempcal
    end
    
    stn = kloop; senscal = 1; mctd_condcal
    stn = kloop; senscal = 2; mctd_condcal

    stn = kloop; mctd_03;
    mout_1hzasc(kloop)
    stn = kloop; mctd_04;
    
    stn = kloop; mfir_03;
    stn = kloop; mfir_04;

    stn = kloop; msam_02b;
    stn = kloop; msam_updateall;
     
end