% mctd_02b: oxygen hysteresis correction
%
% Use: mctd_02b        and then respond with station number, or for station 16
%      stn = 16; mctd_02;
%
% uses parameters set in mexec_processing_scripts/cruise_options/opt_${cruise}

scriptname = 'mctd_02b';
cruise = MEXEC_G.MSCRIPT_CRUISE_STRING;
oopt = '';

if ~exist('stn','var')
    stn = input('type stn number ');
end
stn_string = sprintf('%03d',stn);
stnlocal = stn; clear stn % so that it doesn't persist

mdocshow(scriptname, ['corrects for oxygen hysteresis (parameters set in opt_' cruise '.m) and writes to ctd_' cruise '_' stn_string '_24hz.nc']);

% resolve root directories for various file types
root_ctd = mgetdir('M_CTD');

prefix = ['ctd_' cruise '_'];

infile = [root_ctd '/' prefix stn_string '_raw'];
otfile2 = [root_ctd '/' prefix stn_string '_24hz'];

% di346 oxygen hysteresis reworked by GDM.
% SBE default coefficients are -0.033, 5000, 1450.
% for stations up to  and including 064, apply sbe_reverse first
% y = mcoxyhist_reverse(oxygen_sbe,time,press,{default_coeffs})
% Then apply forwards hysteresis adjustment with GDM's preferred
% parameters

oopt = 'hyst'; get_cropt %hyst_pars, hyst_var_string, hyst_execute_string, oxy1name

MEXEC_A.MARGS_IN = {
infile
otfile2
'/'
hyst_var_string
hyst_execute_string
oxy1name
' '
};
if exist('hyst_var_string2')
   MEXEC_A.MARGS_IN = [MEXEC_A.MARGS_IN;
   hyst_var_string2
   hyst_execute_string2
   oxy2name
   ' '
   ' '
   ];
else
   MEXEC_A.MARGS_IN = [MEXEC_A.MARGS_IN;
   ' '
   ];
end
mcalc

% cmd = ['!/bin/cp -p ' m_add_nc(infile) ' ' m_add_nc(otfile2)]; eval(cmd); % copy and write protect raw file



