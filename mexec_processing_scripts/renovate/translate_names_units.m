function nudict = translate_names_units(nutype)
% function nudict = translate_names_units(nu_schema)
%
% for various pairs of naming schema (mexec, sbe, exch_ctd, exch_sam)
% create a dictionary whose keys are (name, unit) pairs in out_schema
% and values are sets of possible corresponding names and units in
% in_schema (with names and units not necessarily being the same length)
%
% for backwards compatibility rather than using the dictionary type it is
% stored as a vector structure with fields name, unit, namesin, and unitsin
% e.g.
%
% nudict = translate_names_units('sbe');
% nudict(1).name = 'scan';
% nudict(1).unit = 'number';
% nudict(1).names = {'scan'};
% nudict(1).units = {'scan count'};
% nudict(2).name = 'transmittance';
% nudict(2).unit = 'percent';
% nudict(2).names = {'xmiss', 'CStarTr0', 'transmittance'};
% nudict(2).units = {'percent' '%'};
% nudict(3).name = 'oxygen_sbe1';
% nudict(3).units = 'umol/kg';
% nudict(3).names = {'sbox0Mm_slash_Kg', 'sbeox0Mm_slash_kg'};
% nudict(3).units = {};
% nudict(4).name = 'oxygen_sbe1';
% nudict(4).units = 'umol/L';
% nudict(4).names = {'sbox0Mm_slash_L', 'sbeox0Mm_slash_L'};
% nudict(4).units = {};
%
% or
%
% nudict = translate_names_units('mexec','exch_sam');
% nudict(1).name = 'CTDPRS';
% nudict(1).unit = 'DBAR';
% nudict(1).names = {'upress'};
% nudict(1).units = {'dbar'};
% nudict(2).name = 'OXYGEN';
% nudict(2).unit = 'UMOL/KG';
% nudict(2).name = {'botoxy', 'botoxya'};
% nudict(2).name = {'umol/kg'};

%list of units forms (unt.options) to rename to standardised mstar units forms (unt.munit)
%unt.options does not need to include unt.munit, only the options that would need to be changed

nudict = struct([]);

if strcmp(nuin,'sbe') && strcmp(nuot,'mexec')
t = readtable('ctd_renamelist.csv');
m = strcmp('/',t.varname);
t.varname(m) = t.sbename(m);
names = unique(t.varname);
for no = 1:length(names)
    nudict(no).name = names{no};
    m = strcmp(names{no},t.varname);
    nudict(no).namesin = t.sbename(m);
    nudict(no).unit = t.varunit(m){1}; %***
end

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

