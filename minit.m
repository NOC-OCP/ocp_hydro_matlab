% a few lines of code to be run at the top of most mexec scripts

mcruise = MEXEC_G.MSCRIPT_CRUISE_STRING;

if ~exist('stn', 'var')
   stn = input('type stn number ');
end
if stn>0
   stn_string = sprintf('%03d',stn);
   stnlocal = stn; clear stn % so that it doesn't persist
end

