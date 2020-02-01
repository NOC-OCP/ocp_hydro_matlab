% mctd_04: extract downcast data from psal file using index information in dcs file; 
%          sort, average to 2dbar, interpolate gaps and recalculate potemp.
%
% Use: mctd_04        and then respond with station number, or for station 16
%      stn = 16; mctd_04;

minit; scriptname = mfilename;
mdocshow(scriptname, ['averages to 2 dbar in ctd_' mcruise '_' stn_string '_2db.nc (downcast) and _2up.nc (upcast)']);

root_ctd = mgetdir('M_CTD');

prefix1 = ['ctd_' mcruise '_'];
prefix2 = ['dcs_' mcruise '_'];

infile1 = [root_ctd '/' prefix1 stn_string '_psal'];
infile2 = [root_ctd '/' prefix2 stn_string];
otfile1 = [root_ctd '/' prefix1 stn_string '_2db'];
wkfile1 = ['wk1_' scriptname '_' datestr(now,30)];
wkfile2 = ['wk2_' scriptname '_' datestr(now,30)];
wkfile3 = ['wk3_' scriptname '_' datestr(now,30)];
%jc069: need upcast 2db file as well, to map press to density on upcast
otfile2 = [root_ctd '/' prefix1 stn_string '_2up'];
wkfile4 = ['wk4_' scriptname '_' datestr(now,30)];
wkfile5 = ['wk5_' scriptname '_' datestr(now,30)];
wkfile6 = ['wk6_' scriptname '_' datestr(now,30)];

if exist(m_add_nc(infile1),'file') ~= 2
    mess = ['File ' m_add_nc(infile1) ' not found'];
    fprintf(MEXEC_A.Mfider,'%s\n',mess)
    return
end

[d h] = mload(infile2,'statnum','dc_start','dc_bot','dc_end',' ');

% allow for the possibility that the dcs file contains many stations

kf = find(d.statnum == stnlocal);
dcstart = d.dc_start(kf);
dcbot = d.dc_bot(kf);
dcend = d.dc_end(kf);
copystr = {[sprintf('%d',round(dcstart)) ' ' sprintf('%d',round(dcbot))]};
copystrup = {[sprintf('%d',round(dcbot)) ' ' sprintf('%d',round(dcend))]};


var_copycell = mcvars_list(1);

%might have to remove some contaminated data or substitute upcast data before averaging
oopt = 'pretreat'; get_cropt


% remove any vars from copy list that aren't available in the input file
numcopy = length(var_copycell);
h_input = m_read_header(infile1);
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

%--------------------------------
MEXEC_A.MARGS_IN_1 = {
infile1
wkfile1
var_copystr
};
MEXEC_A.MARGS_IN_2 = copystr;
MEXEC_A.MARGS_IN_3 = {
' '
' '
};
MEXEC_A.MARGS_IN = [MEXEC_A.MARGS_IN_1; MEXEC_A.MARGS_IN_2; MEXEC_A.MARGS_IN_3];

mcopya
%--------------------------------

%--------------------------------
MEXEC_A.MARGS_IN = {
wkfile1
wkfile2
'press'
};
msort
%--------------------------------

%--------------------------------
MEXEC_A.MARGS_IN = {
wkfile2
wkfile3
'/'
'press'
'0 10000 2'
'b'
};
mavrge
%--------------------------------

%--------------------------------
MEXEC_A.MARGS_IN = {
wkfile3
'y'
'/'
'press'
'0'
'0'
};
mintrp
%--------------------------------

%--------------------------------
MEXEC_A.MARGS_IN = {
wkfile3
otfile1
var_copystr
'press'
'y = -gsw_z_from_p(x1,h.latitude)'
'depth'
'metres'
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
' '
};
mcalc
%--------------------------------

%--------------------------------
MEXEC_A.MARGS_IN_1 = {
infile1
wkfile4
var_copystr
};
MEXEC_A.MARGS_IN_2 = copystrup;
MEXEC_A.MARGS_IN_3 = {
' '
' '
};
MEXEC_A.MARGS_IN = [MEXEC_A.MARGS_IN_1; MEXEC_A.MARGS_IN_2; MEXEC_A.MARGS_IN_3];
mcopya
%--------------------------------

%--------------------------------
MEXEC_A.MARGS_IN = {
wkfile4
wkfile5
'press'
};
msort
%--------------------------------

%--------------------------------
MEXEC_A.MARGS_IN = {
wkfile5
wkfile6
'/'
'press'
'0 10000 2'
'b'
};
mavrge
%--------------------------------

%--------------------------------
MEXEC_A.MARGS_IN = {
wkfile6
'y'
'/'
'press'
'0'
'0'
};
mintrp
%--------------------------------

%--------------------------------
MEXEC_A.MARGS_IN = {
wkfile6
otfile2
var_copystr
'press'
'y = -gsw_z_from_p(x1,h.latitude)'
'depth'
'metres'
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
' '
};
mcalc
%--------------------------------


unix(['/bin/rm ' wkfile1 '.nc ' wkfile2 '.nc ' wkfile3 '.nc']);
unix(['/bin/rm ' wkfile4 '.nc ' wkfile5 '.nc ' wkfile6 '.nc']);
