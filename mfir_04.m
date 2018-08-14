% mfir_04: paste ctd fir data into sam file
%
% Use: mfir_04        and then respond with station number, or for station 16
%      stn = 16; mfir_04;

scriptname = 'mfir_04';
minit
mdocshow(scriptname, ['pastes CTD data at bottle firing times from fir_' mcruise '_' stn_string '.nc to sam_' mcruise '_' stn_string '.nc']);

root_ctd = mgetdir('M_CTD'); % change working directory
prefix1 = ['fir_' mcruise '_'];
prefix2 = ['sam_' mcruise '_'];
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
h1 = m_read_header(infile1);
h2 = m_read_header(otfile2);
for kls = numcopy:-1:1
    if ~sum(strcmp(var_copycell(kls),h1.fldnam)) | ~sum(strcmp(var_copycell(kls),h2.fldnam))
        var_copycell(kls) = [];
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
MEXEC_A.MARGS_IN = {
otfile2
infile1
'y'
'position'
'position'
var_copystr
var_copystr
};
mpaste
%--------------------------------
