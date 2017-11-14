function tempout = temp_apply_cal(sensor,stn,press,time,temp)

% function to apply temp cals 
% bak on jr302 1 july 2014
% adapted from cond_apply_cal to do temp calibration

m_common

cruise = MEXEC_G.MSCRIPT_CRUISE_STRING;
scriptname = 'temp_apply_cal';
get_cropt
