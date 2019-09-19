% miso_01: read in bottle isotope data from csv file or files
%
% Use: miso_01
%
% The input iso data, example filename jc159_13ctdic.csv
%    is a comma-delimeted list of isotope data, with a single header line
%    containing fields 
%    Station, Niskin, d13C DIC PDB
%    or otherwise as specified in opt_cruise file

scriptname = 'miso_01';
mcruise = MEXEC_G.MSCRIPT_CRUISE_STRING;
mdocshow(scriptname, ['reads bottle del13C, Del14C, del18O data from .csv files into iso_' mcruise '_01.nc'])

% resolve root directories for various file types
root_iso = mgetdir('M_BOT_ISO');
dataname = ['iso_' mcruise '_01'];
otfile2 = [root_iso '/' dataname];

oopt = 'files'; get_cropt

% load and put into fields with standard names
for fno = 1:length(files)
   infile = files{fno};
   if ~exist(infile, 'file'); warning(['file ' infile ' not found']); continue; end
   ds_iso = dataset('File', infile, 'Delimiter', ',');
   ds_iso_fn = ds_iso.Properties.VarNames;

   if sum(strcmp('Station', ds_iso_fn)) & sum(strcmp('Niskin', ds_iso_fn))
      ds_iso.sampnum = ds_iso.Station*100 + ds_iso.Niskin;
   else
      oopt = 'sampnum_parse'; get_cropt
   end
    
   iig = find(ds_iso.sampnum>0 & ds_iso.sampnum<1e6);
   ds_iso = ds_iso(iig,:);

   oopt = 'vars'; get_cropt %set vars: {varnames varunits origvarnames}
   ds_iso_fn = ds_iso.Properties.VarNames;

   %assign values to vars, and flags
   nvars = size(vars{fno},1);
   for kvar = 1:nvars
      if sum(strcmp(vars{fno}{kvar,3}, ds_iso_fn))
         eval([vars{fno}{kvar,1} ' = ds_iso.' vars{fno}{kvar,3} ';']);
      else
         %if it's a flag field that's not in ds_iso, set flags to 2 when data present, or 9 for missing
         ii = strfind(vars{fno}{kvar,1}, '_flag');
         if length(ii)>0
            eval([vars{fno}{kvar,1} ' = 9+zeros(length(iig),1);'])
            eval([vars{fno}{kvar,1} '(~isnan(' vars{fno}{kvar,1}(1:ii-1) ')) = 2;'])
         else
            warning(['no values found for iso variable ' vars{fno}{kvar,1}])
	    eval([vars{fno}{kvar,1} ' = NaN+zeros(length(iig),1);'])
         end
      end
   end
end

oopt = 'flags'; get_cropt %modify flags if required

varnames = vars(:,1); varunits = vars(:,2); varnames_units = {};
for k = 1:length(varnames)
   varnames_units = [varnames_units; varnames(k)];
   varnames_units = [varnames_units; {'/'}];
   varnames_units = [varnames_units; varunits(k)];
end

timestring = ['[' sprintf('%d %d %d %d %d %d',MEXEC_G.MDEFAULT_DATA_TIME_ORIGIN) ']'];

%--------------------------------
MEXEC_A.MARGS_IN_1 = {
   otfile2
};
MEXEC_A.MARGS_IN_2 = varnames(:);
MEXEC_A.MARGS_IN_3 = {
' '
' '
'1'
dataname
'/'
'2'
MEXEC_G.PLATFORM_TYPE
MEXEC_G.PLATFORM_IDENTIFIER
MEXEC_G.PLATFORM_NUMBER
'/'
'4'
timestring
'/'
'8'
};
MEXEC_A.MARGS_IN_4 = varnames_units(:);
MEXEC_A.MARGS_IN_5 = {
'-1'
'-1'
};
MEXEC_A.MARGS_IN = [MEXEC_A.MARGS_IN_1; MEXEC_A.MARGS_IN_2; MEXEC_A.MARGS_IN_3; MEXEC_A.MARGS_IN_4; MEXEC_A.MARGS_IN_5];
msave
%--------------------------------
