%apply temperature and conductivity calibrations (set in temp_apply_cal and cond_apply_cal)
%and rerun scripts to incorporate them
    
scriptname = 'smallscript';
cruise = MEXEC_G.MSCRIPT_CRUISE_STRING;
oopt = '';

if ~exist('klist'); oopt = 'klist'; get_cropt; end

for kloop = klist
    stn = kloop;
    stn_string = sprintf('%03d',stn);

    stn = kloop; mctd_02b
    
%    stn = kloop; senscal = 1; mctd_tempcal
%    stn = kloop; senscal = 2; mctd_tempcal

    stn = kloop; senscal = 1; mctd_condcal
    stn = kloop; senscal = 2; mctd_condcal

    stn = kloop; mctd_03;
    stn = kloop; mctd_04;
    
    stn = kloop; mfir_03;
    stn = kloop; mfir_04;

%   %rerun msal to incorporate any flags changed based on ctd_evaluate_sensors
%    stn = kloop; msal_01
%    stn = kloop; msal_02
    
    stn = kloop; msam_02;
    if kloop==1
       eval(['!/bin/cp sam_' cruise '_001.nc sam_' cruise '_all.nc'])
    else
       stn = kloop; msam_apend
    end
%    stn = kloop; msam_updateall;
     
end

%can run ctd_evaluate_sensors again after this (with corrections commented out/turned off) to check that corrections were applied. then can run caldata_all_part2 etc. 
