% mctd_03: average to 1 hz,
%   copy data from chosen sensors (set in opt_cruise) to temp, cond, and
%   oxygen (if two oxygen sensors),
%   and calculate psal, potemp, asal, cons temp
%
% Use: mctd_03        and then respond with station number, or for station 16
%      stn = 16; mctd_03;

scriptname = 'mctd_03';
minit
mdocshow(scriptname, ['averages to 1 hz in ctd_' mcruise '_' stn_string '_1hz.nc; fills in choice of two sensors; computes SP, Theta, SA, CT in ctd_' mcruise '_' stn_string '_psal.nc']);

root_ctd = mgetdir('M_CTD');

prefix1 = ['ctd_' mcruise '_'];

infile1 = [root_ctd '/' prefix1 stn_string '_24hz'];
otfile1 = [root_ctd '/' prefix1 stn_string '_1hz'];
wkfile2 = ['wk_' scriptname '_' datestr(now,30)];
wkfile3 = ['wk2_' scriptname '_' datestr(now,30)];
wkfile4 = ['wk3_' scriptname '_' datestr(now,30)];
otfile5 = [root_ctd '/' prefix1 stn_string '_psal'];

% DAS add post jc174 because need h for latitude and longitude
% but only worked previously if o_choice = 2
h = m_read_header(infile1);

oopt = '24hz'; get_cropt; oopt = ''; %optionally edit bad data in 24hz file

% identify preferred sensor set for temperature and conductivity: set s_choice for default,
% and alternate as list of stations on which to use the other
oopt = 's_choice'; get_cropt
if ~isempty(find(alternate == stnlocal))
    s_choice = setdiff([1 2],s_choice);
end
if s_choice == 1
    extralist = 'temp1 cond1';
else
    extralist = 'temp2 cond2';
end

% identify preferred sensor set for oxygen: set o_choice for default, 
% and alternate as list of stations on which to use the other
oopt = 'o_choice'; get_cropt %note this defaults to 1 for a single oxygen sensor
if ~isempty(find(alternate == stnlocal))
   o_choice = setdiff([1 2],o_choice);
end
if o_choice == 1
   extralist = [extralist ' oxygen1'];
else
   %check whether sensor 2 exists
% DAS see above always need h
%   h = m_read_header(infile1);
   if sum(strcmp('oxygen2', h.fldnam))
      extralist = [extralist ' oxygen2'];
   else
      error(['no oxygen2 found; edit opt_' mcruise ' and/or templates/ctd_renamelist.csv and try again'])
   end
end

newnames = {'temp'; 'cond'; 'oxygen'};

var_copycell = mcvars_list(1);

MEXEC_A.MARGS_IN = {
infile1
otfile1
'/'
'time'
'-1e10 1e10 1'
'b'
};
mavrge

    
MEXEC_A.MARGS_IN = {
infile1   %otfile1  %HJV: to average straight from 24hz to 2db, not via 1hz
wkfile2
'/'
otfile1
extralist
newnames{1}
newnames{2}
newnames{3}
};
maddvars


% remove any vars from copy list that aren't available in the input file
numcopy = length(var_copycell);
h_input = m_read_header(wkfile2);

for kloop_scr = numcopy:-1:1
    if isempty(strmatch(var_copycell(kloop_scr),h_input.fldnam,'exact'))
        var_copycell(kloop_scr) = [];
    end
end
var_copystr = ' ';
for kloop_scr = 1:length(var_copycell)
    var_copystr = [var_copystr var_copycell{kloop_scr} ' '];
end
var_copystr(1) = [];
var_copystr(end) = [];

MEXEC_A.MARGS_IN = {
wkfile2
wkfile3
var_copystr
'press'
'y = -gsw_z_from_p(x1,h.latitude)'
'depth'
'metres'
'cond temp press'
'y = gsw_SP_from_C(x1,x2,x3)'
'psal'
'pss-78'
'cond1 temp1 press'
'y = gsw_SP_from_C(x1,x2,x3)'
'psal1'
'pss-78'
'cond2 temp2 press'
'y = gsw_SP_from_C(x1,x2,x3)'
'psal2'
'pss-78'
' '
};
mcalc

disp(h.longitude)
disp(h.latitude)
    
MEXEC_A.MARGS_IN = {
wkfile3
wkfile4
'/'
'psal press'
'y=gsw_SA_from_SP(x1,x2,h.longitude,h.latitude )'
'asal'
'g/kg'
'psal1 press'
'y=gsw_SA_from_SP(x1,x2,h.longitude,h.latitude )'
'asal1'
'g/kg'
'psal2 press'
'y=gsw_SA_from_SP(x1,x2,h.longitude,h.latitude )'
'asal2'
'g/kg'
' '
};
mcalc

    
MEXEC_A.MARGS_IN = {
wkfile4
otfile5
'/'
'asal temp press'
'y = gsw_pt0_from_t(x1,x2,x3)'
'potemp'
'degc90'
'asal1 temp1 press'
'y = gsw_pt0_from_t(x1,x2,x3)'
'potemp1'
'degc90'
'asal2 temp2 press'
'y = gsw_pt0_from_t(x1,x2,x3)'
'potemp2'
'degc90'
'asal temp press'
'y = gsw_CT_from_t(x1,x2,x3)'
'contemp'
'degc90'
'asal1 temp1 press'
'y = gsw_CT_from_t(x1,x2,x3)'
'contemp1'
'degc90'
'asal2 temp2 press'
'y = gsw_CT_from_t(x1,x2,x3)'
'contemp2'
'degc90'
' '
};
mcalc

oopt = 'psal'; get_cropt; oopt = ''; %optionally edit psal file

unix(['/bin/rm ' wkfile2 '.nc ' wkfile3 '.nc ' wkfile4 '.nc']);
