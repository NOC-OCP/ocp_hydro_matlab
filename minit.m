% a few lines of code to be run at the top of mexec scripts dealing with
% station data
% sets station number if unconventional (using cruise options file)

mcruise = MEXEC_G.MSCRIPT_CRUISE_STRING;

if ~exist('stn', 'var')
   stn = input('type stn number ');
end
stnlocal = stn; 
scriptname = mfilename; oopt = 'stn_string'; get_cropt
clear stn
