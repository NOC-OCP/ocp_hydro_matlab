% mctd_03:
%   copy data from chosen sensors (set in opt_cruise) to temp, cond, and
%   oxygen (if two oxygen sensors),
%   and calculate psal, asal
%   average to 1 hz and calculate potemp, contemp
%
% Use: mctd_03        and then respond with station number, or for station 16
%      stn = 16; mctd_03;
% input: _24hz
% output: _psal

scriptname = 'castpars'; oopt = 'minit'; get_cropt 
mdocshow(mfilename, ['fills in choice of sensors, computes salinity, and averages to 1 hz in ctd_' mcruise '_' stn_string '_psal.nc']);

root_ctd = mgetdir('M_CTD');

prefix1 = ['ctd_' mcruise '_'];

infile1 = fullfile(root_ctd, [prefix1 stn_string '_24hz']);
infile2 = fullfile(root_ctd, ['dcs_' mcruise '_' stn_string]);
otfile1 = fullfile(root_ctd, [prefix1 stn_string '_psal']);
otfile2d = fullfile(root_ctd, [prefix1 stn_string '_2db']);
otfile2u = fullfile(root_ctd, [prefix1 stn_string '_2up']);
wkfile1 = ['wk1_' mfilename '_' datestr(now,30)];
wkfile_dvars = fullfile(root_ctd, ['wk_dvars_' mcruise '_' stn_string]); %this one persists through a later processing stage


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

MEXEC_A.Mprog = mfilename;

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
%now done in workspace

%find variables to copy, that are in both mcvars_list and the input file
var_copycell = mcvars_list(1);
[var_copycell, var_copystr] = mvars_in_file(var_copycell, wkfile1);
[d,h] = mloadq(wkfile1,var_copystr);
clear hnew dnew
hnew.data_time_origin = h.data_time_origin; 
hnew.dataname = h.dataname;
hnew.latitude = h.latitude;
hnew.longitude = h.longitude;
hnew.fldunt = {};
for no = 1:length(var_copycell)
    ii = find(strcmp(var_copycell{no},h.fldnam));
    hnew.fldunt = [hnew.fldunt h.fldunt{ii}];
    dnew.(var_copycell{no}) = d.(var_copycell{no});
end
hnew.fldnam = var_copycell;
hnew.comment = [h.comment '\n psal, asal, potemp, contemp calculated using gsw '];

%new variables
hnew.fldnam = [hnew.fldnam 'psal' 'psal1' 'psal2' 'asal' 'asal1' 'asal2' 'potemp' 'potemp1' 'potemp2'];
hnew.fldunt = [hnew.fldunt 'pss-78' 'pss-78' 'pss-78' 'g/kg' 'g/kg' 'g/kg' 'degc90' 'degc90' 'degc90'];

dnew.psal = gsw_SP_from_C(dnew.cond,dnew.temp,dnew.press);
dnew.psal1 = gsw_SP_from_C(dnew.cond1,dnew.temp1,dnew.press);
dnew.psal2 = gsw_SP_from_C(dnew.cond2,dnew.temp2,dnew.press);
dnew.asal = gsw_SA_from_SP(dnew.psal,dnew.press,h.longitude,h.latitude);
dnew.asal1 = gsw_SA_from_SP(dnew.psal1,dnew.press,h.longitude,h.latitude);
dnew.asal2 = gsw_SA_from_SP(dnew.psal2,dnew.press,h.longitude,h.latitude);
dnew.potemp = gsw_pt0_from_t(dnew.asal,dnew.temp,dnew.press);
dnew.potemp1 = gsw_pt0_from_t(dnew.asal1,dnew.temp1,dnew.press);
dnew.potemp2 = gsw_pt0_from_t(dnew.asal2,dnew.temp2,dnew.press);

% hnew.fldnam = [hnew.fldnam 'contemp' 'contemp1' 'contemp2'];
% hnew.fldunt = [hnew.fldunt 'degc90' 'degc90' 'degc90'];
% dnew.contemp = gsw_CT_from_t(dnew.asal,dnew.temp,dnew.press);
% dnew.contemp1 = gsw_CT_from_t(dnew.asal1,dnew.temp1,dnew.press);
% dnew.contemp2 = gsw_CT_from_t(dnew.asal2,dnew.temp2,dnew.press);

%save
mfsave(wkfile_dvars, dnew, hnew);

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
delete(m_add_nc(wkfile1));
