function fluorout = fluor_apply_cal(stn,fluor,press,time,temp)

% function to apply fluor cals 
% jc069 by bak
% called by mctd_fluorcal

m_common

mcruise = MEXEC_G.MSCRIPT_CRUISE_STRING;
scriptname = 'fluor_apply_cal';
oopt = ''; get_cropt
