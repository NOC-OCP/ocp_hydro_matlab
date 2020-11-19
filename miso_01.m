% miso_01: read in bottle isotope data from csv file or files
%
% Use: miso_01
%
% The input iso data, example filename jc159_13ctdic.csv
%    is a comma-delimeted list of isotope data, with a single header line
%    containing fields 
%    Station, Niskin, d13C DIC PDB
%    or otherwise as specified in opt_cruise file
%
% A given data/flag variable cannot be in more than one file or it will
% be overwritten (so this does not support separating by station)
%
% Variable names are specified in the opt_cruise file

scriptname = 'miso_01';
mcruise = MEXEC_G.MSCRIPT_CRUISE_STRING;
mdocshow(scriptname, ['reads bottle del13C, Del14C, del18O data from .csv files into iso_' mcruise '_01.nc'])

% resolve root directories for various file types
root_iso = mgetdir('M_BOT_ISO');
dataname = ['iso_' mcruise '_01'];
otfile2 = [root_iso '/' dataname];

oopt = 'files'; get_cropt

% load and put into fields with standard names
sampnum = repmat(1:999,24,1)*100+repmat([1:24]',1,999); sampnum = sampnum(:);
varnames = {'sampnum';'statnum';'position'};
varnames_units = {'sampnum';'/';'number';'statnum';'/';'number';'/';'position';'/';'number'};
oopt = 'vars'; get_cropt %set vars: {varnames varunits origvarnames}
for fno = 1:length(files)
   infile = files{fno};
   if ~exist(infile, 'file'); warning(['file ' infile ' not found']); continue; end
   ds_iso = dataset('File', infile, 'Delimiter', ',');
   ds_iso_fn = ds_iso.Properties.VarNames;

   if sum(strcmp('sampnum', vars{fno}(:,1)))==0
      if sum(strcmp('Station', ds_iso_fn)) & sum(strcmp('Niskin', ds_iso_fn))
         ds_iso.sampnum = ds_iso.Station*100 + ds_iso.Niskin;
      else
         iis = find(strcmp('statnum', vars{fno}(:,1)));
         iin = find(strcmp('position', vars{fno}(:,1)));
	 if length(iis)>0 & length(iin)>0
	    ds_iso.sampnum = getfield(ds_iso, vars{fno}{iis,3})*100 + getfield(ds_iso, vars{fno}{iin,3});
	 end
      end
   end
   oopt = 'sampnum_parse'; get_cropt
  
   [c,ia,ib] = intersect(sampnum, ds_iso.sampnum);
   ds_iso = ds_iso(ib,:);

   ds_iso_fn = ds_iso.Properties.VarNames;

   %assign values to vars, and flags
   nvars = size(vars{fno},1);
   for kvar = 1:nvars %***2:nvars?***
      if sum(strcmp(vars{fno}{kvar,3}, ds_iso_fn))
         eval([vars{fno}{kvar,1} ' = NaN+sampnum;'])
         d = getfield(ds_iso, vars{fno}{kvar,3});
         if sum(strcmp([vars{fno}{kvar,3} '_rpt'], ds_iso_fn)) %there are replicates
	    dr = getfield(ds_iso, [vars{fno}{kvar,1} '_rpt']);
	    eval([vars{fno}{kvar,1} '(ia) = nanmean([d dr], 2);'])
	    eval([vars{fno}{kvar,1} '_repl = NaN+' vars{fno}{kvar,1} '; ' vars{fno}{kvar,1} '_repl(ia) = ~isnan(dr);'])
	 else
            eval([vars{fno}{kvar,1} '(ia) = d;']);%ds_iso.' vars{fno}{kvar,3} ';']);
	 end
      else
         %if it's a flag field that's not in ds_iso, set flags to 2 when data present, or 9 for missing
         ii = strfind(vars{fno}{kvar,1}, '_flag');
         if length(ii)>0
            eval([vars{fno}{kvar,1} ' = 9+zeros(length(sampnum),1);'])
            eval([vars{fno}{kvar,1} '(~isnan(' vars{fno}{kvar,1}(1:ii-1) ')) = 2;'])
         else
            warning(['no values found for iso variable ' vars{fno}{kvar,1}])
	    eval([vars{fno}{kvar,1} ' = NaN+zeros(length(sampnum),1);'])
         end
      end
      if ~sum(strcmp(vars{fno}{kvar,1},{'sampnum';'statnum';'position'})) & length(strfind(vars{fno}{kvar,1}, '_rpt'))==0
         varnames = [varnames; vars{fno}(kvar,1)];
         varnames_units = [varnames_units; vars{fno}(kvar,1); {'/'}; vars{fno}(kvar,2)];
      end
   end
   %adjust flags for repeats, make sure NaNs have flag 9 not 2, remove _rpt from varnames
   iir = [];
   for kvar = 1:nvars
      ii = strfind(vars{fno}{kvar,1}, '_flag');
      if length(ii)>0
         eval(['f = ' vars{fno}{kvar,1} ';'])
         if exist([vars{fno}{kvar,1}(1:ii-1) '_repl'], 'var')
            eval(['fr = ' vars{fno}{kvar,1}(1:ii-1) '_repl;'])
	    f(f==2 & fr==1) = 6;
	 end
	 eval(['d = ' vars{fno}{kvar,1}(1:ii-1) ';'])
	 f(isnan(d) & f==2) = 9;
	 eval([vars{fno}{kvar,1} ' = f;'])
      else
         if length(strfind(vars{fno}{kvar,1}, '_rpt'))>0
	    iir = [iir kvar];
	 end
      end
   end
   vars{fno}(iir,:) = [];
end

oopt = 'flags'; get_cropt %further modify flags if required

%get rid of station numbers with no data
m = zeros(size(sampnum));
for kvar = 4:length(varnames)
   eval(['d = ' varnames{kvar} ';'])
   if length(strfind(varnames{kvar}, '_flag'))==0
      m = m + ~isnan(d);
   else
      m = m + d<9;
   end
end
s = unique(statnum(find(m>0)));
iis = ismember(statnum, s);
for kvar = 1:length(varnames)
   eval(['d = ' varnames{kvar} ';']);
   d = d(iis);
   eval([varnames{kvar} ' = d;'])
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
