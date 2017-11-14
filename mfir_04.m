% mfir_04: paste ctd fir data into sam file
%
% Use: mfir_04        and then respond with station number, or for station 16
%      stn = 16; mfir_04;

scriptname = 'mfir_04';
cruise = MEXEC_G.MSCRIPT_CRUISE_STRING;

if ~exist('stn','var')
    stn = input('type stn number ');
end
stn_string = sprintf('%03d',stn);
stnlocal = stn; clear stn % so that it doesn't persist

mdocshow(scriptname, ['pastes CTD data at bottle firing times from fir_' cruise '_' stn_string '.nc to sam_' cruise '_' stn_string '.nc']);

root_ctd = mgetdir('M_CTD'); % change working directory
prefix1 = ['fir_' cruise '_'];
prefix2 = ['sam_' cruise '_'];
infile1 = [root_ctd '/' prefix1 stn_string '_ctd'];
otfile2 = [root_ctd '/' prefix2 stn_string];

var_copycell = mcvars_list(2);

% remove any vars from copy list that aren't available in both input files
numcopy = length(var_copycell);
% add initial 'u' to variable name to signify upcast
for kloop_scr = numcopy:-1:1
    var_copycell{kloop_scr} = ['u' var_copycell{kloop_scr}];
end
var_copycell = [{'time'} var_copycell];

numcopy = length(var_copycell);
h_input = m_read_header(infile1);
for kloop_scr = numcopy:-1:1
    if isempty(strmatch(var_copycell(kloop_scr),h_input.fldnam,'exact'))
        var_copycell(kloop_scr) = [];
    end
end

numcopy = length(var_copycell);
h_input = m_read_header(otfile2);
for kloop_scr = numcopy:-1:1
    if isempty(strmatch(var_copycell(kloop_scr),h_input.fldnam,'exact'))
        var_copycell(kloop_scr) = [];
    end
end

% now construct string with list of vars to be copied
var_copystr = ' ';
for kloop_scr = 1:length(var_copycell)
    var_copystr = [var_copystr var_copycell{kloop_scr} ' '];
end
var_copystr(1) = [];
var_copystr(end) = [];



%--------------------------------
% 2009-01-26 12:14:38
% mpaste
% input files
% Filename fir_jr193_016_ctd.nc   Data Name :  fir_jr193_016 <version> 21 <site> bak_macbook
% output files
% Filename sam_jr193_016.nc   Data Name :  sam_jr193_016 <version> 16 <site> bak_macbook
MEXEC_A.MARGS_IN = {
otfile2
infile1
'y'
'position'
'position'
%'time upress utemp ucond utemp1 ucond1 utemp2 ucond2 uasal upsal upsal1 upsal2 upotemp upotemp1 upotemp2 uoxygen'
%'time upress utemp ucond utemp1 ucond1 utemp2 ucond2 uasal upsal upsal1 upsal2 upotemp upotemp1 upotemp2 uoxygen'
var_copystr
var_copystr
};
mpaste
%--------------------------------
