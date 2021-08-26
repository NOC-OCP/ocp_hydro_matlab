% mco2_02: paste co2 data into sam file

scriptname = 'castpars'; oopt = 'minit'; get_cropt
mdocshow(mfilename, ['add documentation string for ' scriptname])

root_co2 = mgetdir('M_BOT_CO2');
root_ctd = mgetdir('M_CTD');
prefix1 = ['co2_' mcruise '_'];
prefix2 = ['sam_' mcruise '_'];
infile1 = fullfile(root_co2, [prefix1 '01']);
otfile2 = fullfile(root_ctd, [prefix2 stn_string]);


%--------------------------------
MEXEC_A.MARGS_IN = {
otfile2
infile1
'y'
'sampnum'
'sampnum'
'alk alk_flag dic dic_flag'
'alk alk_flag dic dic_flag'
};
mpaste
