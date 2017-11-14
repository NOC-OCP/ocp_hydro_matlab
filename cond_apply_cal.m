function condout = cond_apply_cal(sensor,stn,press,time,temp,cond)

% function to apply cond cals
% di 368 bak & aa
% called by mctd_condcal
% bak on jr281 added scan as a 6th argument. Should be backwards compatible
% adding scan as an argument allows adjustments (offsets) to fragments of a station
% ylf jc145 changed to time, changed order of inputs

m_common

cruise = MEXEC_G.MSCRIPT_CRUISE_STRING;
scriptname = 'cond_apply_cal';
get_cropt
