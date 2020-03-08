% mfir_04: paste ctd fir data into sam file
%
% Use: mfir_04        and then respond with station number, or for station 16
%      stn = 16; mfir_04;

minit; scriptname = mfilename;
mdocshow(scriptname, ['pastes CTD data at bottle firing times from fir_' mcruise '_' stn_string '.nc to sam_' mcruise '_' stn_string '.nc']);

root_ctd = mgetdir('M_CTD'); % change working directory
infile1 = [root_ctd '/fir_' mcruise '_' stn_string '_ctd'];
otfile2 = [root_ctd '/sam_' mcruise '_' stn_string];

var_copycell = mcvars_list(2);
gvar_copycell = mcvars_list(3);

% remove any vars from copy list that aren't available in both input files
% also add initial 'u' to variable name to signify upcast
numcopy = length(var_copycell);
h1 = m_read_header(infile1);
h2 = m_read_header(otfile2);
for kls = numcopy:-1:1
    var_copycell{kls} = ['u' var_copycell{kls}];
    if ~sum(strcmp(var_copycell(kls),h1.fldnam)) | ~sum(strcmp(var_copycell(kls),h2.fldnam))
        var_copycell(kls) = [];
    end
end
for kls = length(gvar_copycell):-1:1
    gvar_copycell{kls} = [gvar_copycell{kls} 'grad'];
    if sum(strcmp(var_copycell(kls),h1.fldnam)) & sum(strcmp(var_copycell(kls),h2.fldnam))
        var_copycell = [var_copycell gvar_copycell{kls}];
    end
end
var_copycell = [{'time'} var_copycell];

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
