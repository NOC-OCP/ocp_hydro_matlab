% mcfc_02: paste cfc data into sam file

scriptname = 'castpars'; oopt = 'minit'; get_cropt
mdocshow(mfilename, ['add documentation string for ' scriptname])

root_cfc = mgetdir('M_BOT_CFC');
root_ctd = mgetdir('M_CTD');
prefix1 = ['cfc_' mcruise '_'];
prefix2 = ['sam_' mcruise '_'];
infile1 = fullfile(root_cfc, [prefix1 '01']);
otfile2 = fullfile(root_ctd, [prefix2 stn_string]);

% bak on jr281 march 2013
% allow for each cruise to have a specific cfc list
oopt = 'cfclist'; get_cropt

%--------------------------------
MEXEC_A.MARGS_IN = {
otfile2
infile1
'y'
'sampnum'
'sampnum'
cfcinlist
cfcotlist
};
mpaste
