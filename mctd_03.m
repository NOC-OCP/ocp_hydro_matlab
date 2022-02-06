% mctd_03:
%
% input: _24hz
%
%   apply automatic edits as set in opt_cruise, mctd_rawedit case; 
%   copy data from sensors chosen in opt_cruise to temp, cond, and oxygen; 
%   calculate psal, asal, potemp using GSW;
%   average to 1 hz and fill gaps as set in opt_cruise
%
% outputs: _psal (1 hz, used for plots and ladcp)
%          wk_dvars_ (24 hz, used by mctd_04 to average to 2 dbar)
%
% Use: mctd_03        and then respond with station number, or for station 16
%      stn = 16; mctd_03;
%
% calls: 
%     mcalib2 (if sensors are being switched)
%     maddvars
%     mintrp2
%     mloadq
%     gsw functions
%     mfsave
% and via get_cropt:
%      setdef_cropt_cast (castpars and mctd_03 cases)

m_common; MEXEC_A.mprog = mfilename;
scriptname = 'castpars'; oopt = 'minit'; get_cropt 
mdocshow(mfilename, ['fills in choice of sensors, computes salinity, and averages to 1 hz in ctd_' mcruise '_' stn_string '_psal.nc']);

root_ctd = mgetdir('M_CTD');

prefix1 = ['ctd_' mcruise '_'];

infile1 = fullfile(root_ctd, [prefix1 stn_string '_24hz']);
otfile1 = fullfile(root_ctd, [prefix1 stn_string '_psal']);
wkfile1 = ['wk1_' mfilename '_' datestr(now,30)];
wkfile_dvars = fullfile(root_ctd, ['wk_dvars_' mcruise '_' stn_string]); %this one persists through a later processing stage


%identify preferred sensors for (T,C) and O on this station
scriptname = mfilename; oopt = 's_choice'; get_cropt 
if ismember(stnlocal, stns_alternate_s)
    s_choice = setdiff([1 2], s_choice);
end
scriptname = mfilename; oopt = 'o_choice'; get_cropt 
if ismember(stnlocal, stns_alternate_o)
   o_choice = setdiff([1 2],o_choice);
end
h = m_read_header(infile1);
if o_choice == 2 && ~sum(strcmp('oxygen2', h.fldnam))
   error(['no oxygen2 found; edit opt_' mcruise ' and/or templates/ctd_renamelist.csv and try again'])
end

%optional: edit out bad scans, ***change this to remove from data to be
%averaged, somehow***
%or even replace data from specified sensor with data from the other
%you should almost never do the second one because it will produce
%discontinuities; it's almost always better to switch the preferred sensor
%for the whole cast
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

%new variables
hnew.fldnam = [hnew.fldnam 'psal' 'psal1' 'psal2' 'asal' 'asal1' 'asal2' 'potemp' 'potemp1' 'potemp2'];
hnew.fldunt = [hnew.fldunt 'pss-78' 'pss-78' 'pss-78' 'g/kg' 'g/kg' 'g/kg' 'degc90' 'degc90' 'degc90'];
hnew.comment = [h.comment '\n psal, asal, potemp, contemp calculated using gsw '];

iig = find(dnew.press>-1.495); %gsw won't work on p<=-1.495
if length(iig)<length(dnew.press)
    m = {'negative pressures < -1.495 found, psal etc. will not be calculated for these points and'
        'you may also want to check in mctd_rawedit and set revars under mctd_rawedit case in'
        ['opt_' mcruise ' in case pressure spikes need to be edited out']};
    warning('%s\n',m{:});
end
dnew.psal = NaN+dnew.cond; dnew.psal(iig) = gsw_SP_from_C(dnew.cond(iig),dnew.temp(iig),dnew.press(iig));
dnew.psal1 = NaN+dnew.cond; dnew.psal1(iig) = gsw_SP_from_C(dnew.cond1(iig),dnew.temp1(iig),dnew.press(iig));
dnew.psal2 = NaN+dnew.cond; dnew.psal2(iig) = gsw_SP_from_C(dnew.cond2(iig),dnew.temp2(iig),dnew.press(iig));
dnew.asal =  NaN+dnew.cond; dnew.asal(iig) = gsw_SA_from_SP(dnew.psal(iig),dnew.press(iig),h.longitude(iig),h.latitude);
dnew.asal1 = NaN+dnew.cond; dnew.asal1(iig) = gsw_SA_from_SP(dnew.psal1(iig),dnew.press(iig),h.longitude(iig),h.latitude);
dnew.asal2 = NaN+dnew.cond; dnew.asal2(iig) = gsw_SA_from_SP(dnew.psal2(iig),dnew.press(iig),h.longitude(iig),h.latitude);
dnew.potemp = NaN+dnew.cond; dnew.potemp(iig) = gsw_pt0_from_t(dnew.asal(iig),dnew.temp(iig),dnew.press(iig));
dnew.potemp1 = NaN+dnew.cond; dnew.potemp1(iig) = gsw_pt0_from_t(dnew.asal1(iig),dnew.temp1(iig),dnew.press(iig));
dnew.potemp2 = NaN+dnew.cond; dnew.potemp2(iig) = gsw_pt0_from_t(dnew.asal2(iig),dnew.temp2(iig),dnew.press(iig));

% hnew.fldnam = [hnew.fldnam 'contemp' 'contemp1' 'contemp2'];
% hnew.fldunt = [hnew.fldunt 'degc90' 'degc90' 'degc90'];
% dnew.contemp = NaN+dnew.cond; dnew.contemp(iig) = gsw_CT_from_t(dnew.asal(iig),dnew.temp(iig),dnew.press(iig));
% dnew.contemp1  NaN+dnew.cond; dnew.contemp1(iig) = gsw_CT_from_t(dnew.asal1(iig),dnew.temp1(iig),dnew.press(iig));
% dnew.contemp2  NaN+dnew.cond; dnew.contemp2(iig) = gsw_CT_from_t(dnew.asal2(iig),dnew.temp2(iig),dnew.press(iig));

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
