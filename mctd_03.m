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

minit; 
mdocshow(mfilename, ['fills in choice of sensors, computes salinity, and averages to 1 hz in ctd_' mcruise '_' stn_string '_psal.nc']);

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
wkfile_dvars = [root_ctd '/wk_dvars_' mcruise '_' stn_string]; %this one persists through a later processing stage


%identify preferred sensors for (T,C) and O on this station
scriptname = mfilename; oopt = 's_choice'; get_cropt 
if ismember(stnlocal, stns_alternate_s);
    s_choice = setdiff([1 2], s_choice);
end
scriptname = mfilename; oopt = 'o_choice'; get_cropt 
if ismember(stnlocal, stns_alternate_o)
   o_choice = setdiff([1 2],o_choice);
end
h = m_read_header(infile1);
if o_choice == 2 & ~sum(strcmp('oxygen2', h.fldnam))
   error(['no oxygen2 found; edit opt_' mcruise ' and/or templates/ctd_renamelist.csv and try again'])
end


%optional: edit out bad scans, or replace data from specified sensor with data from the other
scriptname = mfilename; oopt = '24hz_edit'; get_cropt
if length(badscans24)+length(switchscans24)>0
    MEXEC_A.MARGS_IN = {infile1; 'y'};
    for no = 1:size(badscans24,1)
        MEXEC_A.MARGS_IN = [MEXEC_A.MARGS_IN;
            badscans24{no,1};
            sprintf('%s scan', badscans24{no,1});
            sprintf('y = x1; kbad = find(x2 >= %d & x2 <= %d); y(kbad) = NaN;', badscans24{no,2}, badscans24{no,3});
            ' ';
            ' '];
    end
    if sum(strcmp(switchscans24{no,1},{'cond','temp'}))
        sens1 = s_choice;
    elseif strncmp(switchscans24{no,1},'oxy',3)
        sens1 = o_choice;
    end
    sens2 = setdiff([1 2],sens1);
    for no = 1:size(switchscans24)
        MEXEC_A.MARGS_IN = [MEXEC_A.MARGS_IN;
            switchscans24{no,1};
            sprintf('%s%d %s%d scan', switchscans24{no,1}, sens1, switchscans24{no,1}, sens2)
            sprintf('y = x1; kbad = find(x3 >= %d & x3 <= %d); y(kbad) = x2(kbad);', switchscans24{no,2}, switchscans24{no,3});
            ' '
            ' '];
    end
    MEXEC_A.MARGS_IN = [MEXEC_A.MARGS_IN; ' '];
    mcalib2
end

%copy selected sensor to new names without sensor number
MEXEC_A.MARGS_IN = {
infile1
wkfile1
'/'
infile1
sprintf('temp%d cond%d oxygen%d', s_choice, s_choice, o_choice);
'temp'
'cond'
'oxygen'
};
maddvars

%optional: interpolate over gaps 
scriptname = mfilename; oopt = '24hz_interp'; get_cropt 
if interp24 
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


%calculate derived variables and make 1 hz averaged file, _psal.nc
%this happens in multiple steps, and involves a persisting working file, 
%because some calculations here and subsequently rely on others

%find variables to copy, that are in both mcvars_list and the input file
var_copycell = mcvars_list(1);
[var_copycell, var_copystr] = mvars_in_file(var_copycell, wkfile1);

MEXEC_A.MARGS_IN = {
wkfile1
wkfile2
var_copystr %copy these
'cond temp press' %use these
'y = gsw_SP_from_C(x1,x2,x3)' %in this equation
'psal' %to calculate this
'pss-78' %with these units
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
wkfile_dvars %this one persists
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

% average to 1hz, output to _psal file
MEXEC_A.MARGS_IN = {
wkfile_dvars
otfile1
'/'
'time'
'-1e10 1e10 1'
'b'
};
mavrge

%optional: interpolate over gaps in 1hz file
%optional: interpolate over gaps 
scriptname = mfilename; oopt = '1hz_interp'; get_cropt 
if interp1hz 
    MEXEC_A.MARGS_IN = {
    otfile1
    'y'
    '/'
    'scan'
    num2str(maxgap1)
    '0'
    '0'
    };
    mintrp2
end

%tidy up
unix(['/bin/rm ' wkfile1 '.nc ' wkfile2 '.nc ' wkfile3 '.nc']);
