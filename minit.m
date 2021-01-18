% a few lines of code to be run at the top of most mexec scripts
% sets station number if unconventional (using cruise options file)

mcruise = MEXEC_G.MSCRIPT_CRUISE_STRING;
scriptname = mfilename;

if ~exist('stn', 'var')
   stn = input('type stn number ');
end
stnlocal = stn; 
stn_string = sprintf('%03d', stnlocal);
get_cropt %do something special if necessary (e.g. dy111)
clear stn
