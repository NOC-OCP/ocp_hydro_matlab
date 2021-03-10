function salout = tsgsal_apply_cal(time,salin)
% function salout = tsgsal_apply_cal(time,salin)
%
% adjust tsg salinity using a simple time-dependent offset
% function to be called in mcalc from mtsg_apply_salcal

m_common

mcruise = MEXEC_G.MSCRIPT_CRUISE_STRING;
switch MEXEC_G.Mship
   case {'cook','discovery'} % used on jc069
      prefix = 'met_tsg';
   case 'jcr'
      prefix = 'oceanlogger';
end
root_tsg = mgetdir(prefix);
scriptname = mfilename; oopt = 'tsgsaladj'; get_cropt
