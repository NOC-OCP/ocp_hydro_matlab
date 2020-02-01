% a few lines of code to be run at the top of most mexec scripts

mcruise = MEXEC_G.MSCRIPT_CRUISE_STRING;
scriptname0 = scriptname; scriptname = 'minit';

if ~exist('stn', 'var')
   stn = input('type stn number ');
end
get_cropt
stnlocal = stn; clear stn % so that it doesn't persist
scriptname = scriptname0;
