% mfir_04: paste ctd fir data into sam file
%
% Use: mfir_04        and then respond with station number, or for station 16
%      stn = 16; mfir_04;

minit; scriptname = mfilename;
mdocshow(scriptname, ['pastes CTD data at bottle firing times from fir_' mcruise '_' stn_string '.nc to sam_' mcruise '_' stn_string '.nc']);

root_ctd = mgetdir('M_CTD'); % change working directory
infile1 = [root_ctd '/fir_' mcruise '_' stn_string '_ctd'];
otfile2 = [root_ctd '/sam_' mcruise '_' stn_string];

% get list of sample variables that are in both input files, with initial
% 'u' added to variable name to signify upcast
var_copycell = mcvars_list(2);
[var_copycell, junk] = mvars_in_file(var_copycell, infile1);
[var_copycell, var_copystr] = mvars_in_file(var_copycell, otfile2, 'u');

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
