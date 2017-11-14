function salout = tsgsal_apply_cal(time,salin)
% function salout = tsgsal_apply_cal(time,salin)
%
% adjust tsg salinity using a simple time-dependent offset
% function to be called in mcalc from mtsg_apply_salcal

m_common

scriptname = 'tsgsal_apply_cal';
cruise = MEXEC_G.MSCRIPT_CRUISE_STRING;
get_cropt
