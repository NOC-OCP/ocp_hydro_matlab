% mctd_03b:
%   copy data from chosen sensors (set in opt_cruise) to temp, cond, and
%   oxygen (if two oxygen sensors),
%   and calculate psal, asal
%   average to 1 hz and calculate potemp, contemp
%
% Use: mctd_03b        and then respond with station number, or for station 16
%      stn = 16; mctd_03b;
% input: _24hz
% output: _psal

minit; scriptname = mfilename;
mdocshow(scriptname, ['fills in choice of sensors, computes salinity, and averages to 1 hz in ctd_' mcruise '_' stn_string '_psal.nc']);

root_ctd = mgetdir('M_CTD');

prefix1 = ['ctd_' mcruise '_'];

infile1 = [root_ctd '/' prefix1 stn_string '_24hz'];
infile2 = [root_ctd '/dcs_' mcruise '_' stn_string];
otfile1 = [root_ctd '/' prefix1 stn_string '_psal'];
otfile2d = [root_ctd '/' prefix1 stn_string '_2db'];
otfile2u = [root_ctd '/' prefix1 stn_string '_2up'];
wkfile1 = ['wk1_' scriptname '_' datestr(now,30)];
wkfile2 = ['wk2_' scriptname '_' datestr(now,30)];
wkfile3 = ['wk3_' scriptname '_' datestr(now,30)];
wkfile_dvars = [root_ctd '/wk_dvars_' mcruise '_' stn_string];

h = m_read_header(infile1);


%%%%% optionally edit bad data (e.g. by scan range) and decide whether to interpolate over gaps %%%%%
oopt = '24hz'; get_cropt


%%%%% add variables to contain copy of data from preferred sensors %%%%%

% identify preferred sensor set for temperature and conductivity: set s_choice for default,
% and alternate as list of stations on which to use the other
oopt = 's_choice'; get_cropt
if ismember(stnlocal, alternate);
    s_choice = setdiff([1 2], s_choice);
end
extralist = sprintf('temp%d cond%d', s_choice, s_choice);

% identify preferred sensor set for oxygen: set o_choice for default, 
% and alternate as list of stations on which to use the other
oopt = 'o_choice'; get_cropt %note this defaults to 1 for a single oxygen sensor
if ismember(stnlocal, alternate)
   o_choice = setdiff([1 2],o_choice);
end
extralist = sprintf('%s oxygen%d', extralist, o_choice);
if o_choice == 2 & ~sum(strcmp('oxygen2', h.fldnam))
   error(['no oxygen2 found; edit opt_' mcruise ' and/or templates/ctd_renamelist.csv and try again'])
end

newnames = {'temp'; 'cond'; 'oxygen'};

MEXEC_A.MARGS_IN = {
infile1
wkfile1
'/'
infile1
extralist
newnames{1}
newnames{2}
newnames{3}
};
margsin = MEXEC_A.MARGS_IN;
maddvars


%%%%% interpolate over gaps %%%%%
if interp24 %set above in oopt = '24hz'
    MEXEC_A.MARGS_IN = {
    wkfile1
    'y'
    '/'
    'scan'
    num2str(maxgap)
    '0'
    '0'
    };
    mintrp2
end


%%%%% determine what variables will go into _psal 1 hz file, %%%%%
%%%%% copy those to working file and add newly calculated variables %%%%%
%%%%% does this in multiple steps because some calculations rely on others %%%%%

var_copycell = mcvars_list(1);
% remove any vars from copy list that aren't available in the input file
numcopy = length(var_copycell);
h_input = m_read_header(wkfile1);
var_copystr = ' ';
for kloop_scr = 1:numcopy
    if length(strmatch(var_copycell{kloop_scr},h_input.fldnam,'exact'))>0
        var_copystr = [var_copystr var_copycell{kloop_scr} ' '];
    end
end
var_copystr([1 end]) = [];

MEXEC_A.MARGS_IN = {
wkfile1
wkfile2
var_copystr
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
    
MEXEC_A.MARGS_IN = {
wkfile2
wkfile3
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
wkfile3
wkfile_dvars
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


%%%%% average to 1hz %%%%%

MEXEC_A.MARGS_IN = {
wkfile_dvars
otfile1
'/'
'time'
'-1e10 1e10 1'
'b'
};
mavrge

oopt = 'psal'; get_cropt; oopt = ''; %optionally edit psal file

unix(['/bin/rm ' wkfile1 '.nc ' wkfile2 '.nc ' wkfile3 '.nc']);
