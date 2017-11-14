% mctd_04: extract downcast data from psal file using index information in dcs file; 
%          sort, average to 2dbar, interpolate gaps and recalculate potemp.
%
% Use: mctd_04        and then respond with station number, or for station 16
%      stn = 16; mctd_04;

scriptname = 'mctd_04';
cruise = MEXEC_G.MSCRIPT_CRUISE_STRING;
oopt = '';

if ~exist('stn','var')
    stn = input('type stn number ');
end
stn_string = sprintf('%03d',stn);
stnlocal = stn; clear stn % so that it doesn't persist

mdocshow(scriptname, ['averages to 2 dbar in ctd_' cruise '_' stn_string '_2db.nc (downcast) and _2up.nc (upcast)']);

root_ctd = mgetdir('M_CTD');

prefix1 = ['ctd_' cruise '_'];
prefix2 = ['dcs_' cruise '_'];

infile1 = [root_ctd '/' prefix1 stn_string '_psal'];
infile2 = [root_ctd '/' prefix2 stn_string];
otfile1 = [root_ctd '/' prefix1 stn_string '_2db'];
wkfile2 = ['wk_' scriptname '_' datestr(now,30)];
wkfile3 = ['wk2_' scriptname '_' datestr(now,30)];
wkfile4 = ['wk3_' scriptname '_' datestr(now,30)];
%jc069: need upcast 2db file as well, to map press to density on upcast
otfile5 = [root_ctd '/' prefix1 stn_string '_2up'];
wkfile6 = ['wk4_' scriptname '_' datestr(now,30)];
wkfile7 = ['wk5_' scriptname '_' datestr(now,30)];
wkfile8 = ['wk6_' scriptname '_' datestr(now,30)];

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
% 2009-01-28 16:26:57
% mcopya
% input files
% Filename ctd_jr193_016_psal.nc   Data Name :  ctd_jr193_016 <version> 31 <site> bak_macbook
% output files
% Filename wk_20090128T162509.nc   Data Name :  ctd_jr193_016 <version> 40 <site> bak_macbook
MEXEC_A.MARGS_IN_1 = {
infile1
wkfile2
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
% 2009-01-28 16:27:33
% msort
% input files
% Filename wk_20090128T162509.nc   Data Name :  ctd_jr193_016 <version> 40 <site> bak_macbook
% output files
% Filename wk2_20090128T162509.nc   Data Name :  ctd_jr193_016 <version> 41 <site> bak_macbook
MEXEC_A.MARGS_IN = {
wkfile2
wkfile3
'press'
};
msort
%--------------------------------

%--------------------------------
% 2009-01-28 16:34:31
% mavrge
% input files
% Filename wk2_20090128T162509.nc   Data Name :  ctd_jr193_016 <version> 41 <site> bak_macbook
% output files
% Filename wk3_20090128T163406.nc   Data Name :  ctd_jr193_016 <version> 45 <site> bak_macbook
MEXEC_A.MARGS_IN = {
wkfile3
wkfile4
'/'
'press'
'0 10000 2'
'b'
};
mavrge
%--------------------------------

%--------------------------------
% 2009-01-28 16:36:34
% mintrp
% input files
% Filename wk3_20090128T163406.nc   Data Name :  ctd_jr193_016 <version> 45 <site> bak_macbook
% output files
% Filename wk3_20090128T163406.nc   Data Name :  ctd_jr193_016 <version> 46 <site> bak_macbook
MEXEC_A.MARGS_IN = {
wkfile4
'y'
'/'
'press'
'0'
'0'
};
mintrp
%--------------------------------

%--------------------------------
% 2009-01-28 16:38:18
% mcalc
% input files
% Filename wk3_20090128T163406.nc   Data Name :  ctd_jr193_016 <version> 46 <site> bak_macbook
% output files
% Filename ctd_jr193_016_2db.nc   Data Name :  ctd_jr193_016 <version> 47 <site> bak_macbook
MEXEC_A.MARGS_IN = {
wkfile4
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

%jc069
% repeat steps for upcast
%--------------------------------
% 2009-01-28 16:26:57
% mcopya
% input files
% Filename ctd_jr193_016_psal.nc   Data Name :  ctd_jr193_016 <version> 31 <site> bak_macbook
% output files
% Filename wk_20090128T162509.nc   Data Name :  ctd_jr193_016 <version> 40 <site> bak_macbook
MEXEC_A.MARGS_IN_1 = {
infile1
wkfile6
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
% 2009-01-28 16:27:33
% msort
% input files
% Filename wk_20090128T162509.nc   Data Name :  ctd_jr193_016 <version> 40 <site> bak_macbook
% output files
% Filename wk2_20090128T162509.nc   Data Name :  ctd_jr193_016 <version> 41 <site> bak_macbook
MEXEC_A.MARGS_IN = {
wkfile6
wkfile7
'press'
};
msort
%--------------------------------

%--------------------------------
% 2009-01-28 16:34:31
% mavrge
% input files
% Filename wk2_20090128T162509.nc   Data Name :  ctd_jr193_016 <version> 41 <site> bak_macbook
% output files
% Filename wk3_20090128T163406.nc   Data Name :  ctd_jr193_016 <version> 45 <site> bak_macbook
MEXEC_A.MARGS_IN = {
wkfile7
wkfile8
'/'
'press'
'0 10000 2'
'b'
};
mavrge
%--------------------------------

%--------------------------------
% 2009-01-28 16:36:34
% mintrp
% input files
% Filename wk3_20090128T163406.nc   Data Name :  ctd_jr193_016 <version> 45 <site> bak_macbook
% output files
% Filename wk3_20090128T163406.nc   Data Name :  ctd_jr193_016 <version> 46 <site> bak_macbook
MEXEC_A.MARGS_IN = {
wkfile8
'y'
'/'
'press'
'0'
'0'
};
mintrp
%--------------------------------

%--------------------------------
% 2009-01-28 16:38:18
% mcalc
% input files
% Filename wk3_20090128T163406.nc   Data Name :  ctd_jr193_016 <version> 46 <site> bak_macbook
% output files
% Filename ctd_jr193_016_2db.nc   Data Name :  ctd_jr193_016 <version> 47 <site> bak_macbook
MEXEC_A.MARGS_IN = {
wkfile8
otfile5
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


unix(['/bin/rm ' wkfile2 '.nc ' wkfile3 '.nc ' wkfile4 '.nc']);
unix(['/bin/rm ' wkfile6 '.nc ' wkfile7 '.nc ' wkfile8 '.nc']);
