% mctd_03:
%
% input: _24hz
%
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
%     mloadq
%     grid_profile
%     gsw functions
%     mfsave
% and via get_cropt:
%      setdef_cropt_cast (castpars and mctd_03 cases)

m_common; MEXEC_A.mprog = mfilename;
scriptname = 'castpars'; oopt = 'minit'; get_cropt 
if MEXEC_G.quiet<=1; fprintf(1,'choosing preferred sensor, computing salinity, averaging to 1 hz for ctd_%s_%s_psal.nc\n',mcruise,stn_string); end

root_ctd = mgetdir('M_CTD');

prefix1 = ['ctd_' mcruise '_'];

infile1 = fullfile(root_ctd, [prefix1 stn_string '_24hz']);
otfile1 = fullfile(root_ctd, [prefix1 stn_string '_psal']);

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

%copy selected sensor to new names without sensor number
[d, h] = mloadq(infile1,'/');
vars = {'temp' 'cond' 'oxygen'};
for vno = 1:length(vars)
    name0 = [vars{vno} num2str(s_choice)];
    ii = find(strcmp(name0,h.fldnam));
    if ~isempty(ii)
        d.(vars{vno}) = d.(name0);
        h.fldnam = [h.fldnam vars{vno}];
        h.fldunt = [h.fldunt h.fldunt{ii}];
    end
end

%calculate derived variables
iig = find(d.press>-1.495); %gsw won't work on p<=-1.495
if length(iig)<length(d.press)
    m = {'negative pressures < -1.495 found, psal etc. will not be calculated for these points'};
    if min(d.press<-10)
        m = [m; 'you may also want to check in mctd_rawshow and set rangelim under mctd_02';
            'case in opt_' mcruise ' in case pressure spikes need to be edited out'];
        warning('%s\n',m{:});
    end
end
d.psal = NaN+d.cond; d.psal(iig) = gsw_SP_from_C(d.cond(iig),d.temp(iig),d.press(iig));
d.psal1 = NaN+d.cond; d.psal1(iig) = gsw_SP_from_C(d.cond1(iig),d.temp1(iig),d.press(iig));
d.psal2 = NaN+d.cond; d.psal2(iig) = gsw_SP_from_C(d.cond2(iig),d.temp2(iig),d.press(iig));
d.asal =  NaN+d.cond; d.asal(iig) = gsw_SA_from_SP(d.psal(iig),d.press(iig),h.longitude,h.latitude);
d.asal1 = NaN+d.cond; d.asal1(iig) = gsw_SA_from_SP(d.psal1(iig),d.press(iig),h.longitude,h.latitude);
d.asal2 = NaN+d.cond; d.asal2(iig) = gsw_SA_from_SP(d.psal2(iig),d.press(iig),h.longitude,h.latitude);
d.potemp = NaN+d.cond; d.potemp(iig) = gsw_pt0_from_t(d.asal(iig),d.temp(iig),d.press(iig));
d.potemp1 = NaN+d.cond; d.potemp1(iig) = gsw_pt0_from_t(d.asal1(iig),d.temp1(iig),d.press(iig));
d.potemp2 = NaN+d.cond; d.potemp2(iig) = gsw_pt0_from_t(d.asal2(iig),d.temp2(iig),d.press(iig));
% h.fldnam = [hnew.fldnam 'contemp' 'contemp1' 'contemp2'];
% h.fldunt = [hnew.fldunt 'degc90' 'degc90' 'degc90'];
% d.contemp = NaN+d.cond; d.contemp(iig) = gsw_CT_from_t(d.asal(iig),d.temp(iig),d.press(iig));
% d.contemp1  NaN+d.cond; d.contemp1(iig) = gsw_CT_from_t(d.asal1(iig),d.temp1(iig),d.press(iig));
% d.contemp2  NaN+d.cond; d.contemp2(iig) = gsw_CT_from_t(d.asal2(iig),d.temp2(iig),d.press(iig));

%new variable names and units
h.fldnam = [h.fldnam 'psal' 'psal1' 'psal2' 'asal' 'asal1' 'asal2' 'potemp' 'potemp1' 'potemp2'];
h.fldunt = [h.fldunt 'pss-78' 'pss-78' 'pss-78' 'g/kg' 'g/kg' 'g/kg' 'degc90' 'degc90' 'degc90'];
[h.fldnam, ii] = unique(h.fldnam);
h.fldunt = h.fldunt(ii);
h.comment = [h.comment '\n psal, asal, potemp, contemp calculated using gsw '];

%save to _24hz file
mfsave(infile1, d, h);


%find variables to copy, that are in both mcvars_list and the input file
var_copycell = mcvars_list(1);
[var_copycell, var_copystr] = mvars_in_file(var_copycell, infile1);
[d, h] = mloadq(infile1,var_copystr);
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

%average to 1hz, output to _psal file
scriptname = mfilename; oopt = '1hz_interp'; get_cropt
tg = [dnew.time(1):dnew.time(end)+1]; %end will be truncated anyway by setting grid_extrap to 0
if size(dnew.time,1)>1; tg = tg'; end
dnew = grid_profile(dnew, 'time', tg, 'meannum', 'num', 24, 'prefill', maxfill24, 'grid_extrap', [0 0], 'postfill', maxfill1);
mfsave(otfile1, dnew, hnew);
