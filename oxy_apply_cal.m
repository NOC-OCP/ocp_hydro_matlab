function oxyout = oxy_apply_cal(sensor,stn,press,time,temp,oxyin)

% function to apply oxy cals
% di 368 bak & gre
% called by mctd_oxycal

m_common

cruise = MEXEC_G.MSCRIPT_CRUISE_STRING;
scriptname = 'oxy_apply_cal';
get_cropt
