%list of units forms (unt.options) to rename to standardised mstar units forms (unt.munit)
%unt.options does not need to include unt.munit, only the options that would need to be changed
  
unt = struct([]);

unt(1).munit = 'number';
unt(1).options = {'Scan Count'}; %par

unt(length(unt)+1).munit = 'seconds';
unt(end).options = {'sec'; 's'};

unt(length(unt)+1).munit = 'deg';
unt(end).options = {'degrees'};

unt(length(unt)+1).munit = 'db';
unt(end).options = {'dbar'}; %switch? db is not correct

unt(length(unt)+1).munit = 'm';
unt(end).options = {'meters'; 'metres'; 'salt water, m'};

unt(length(unt)+1).munit = 'degc90';
unt(end).options = {'ITS-90, deg C'; 'deg C'};
%***deg C?

unt(length(unt)+1).mnuit = 'volts';
unt(end).options = {'V'};

unt(length(unt)+1).mnuit = 'percent';
unt(end).options = {'%'};

