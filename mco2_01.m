%==========================================================================
% mco2_01: read in the bottle co2 data
%
% Usage: mco2_01
%
% NOTE: No need to respond with the station number because this script will
% operate on all stations at once based on a single input file.
%
% This script assumes that the input file will be a .mat file (currently
% named "co2_for_Brian_dd-mm-yyyy.mat" and residing in the default
% directory defined by M_BOT_CO2) that has five variables, all
% vectors of length equal to the number of CO2 observations:
% TA      - measured values for total alkalinity
% DIC     - measured values for dissolved inorganic carbon
% TAflag  - data quality flag for TA
% DICflag - data quality flag for DIC
% SAMPLE  - a string of format ccc-sss-nnX where ccc is a 3-digit cruise
%           number, sss is a three digit station number, nn is a two digit
%           niskin number, and X is a character A, B, C, D, or R.
%
% This script will parse the matlab file into a format more easily copied
% into mstar.  Of particular note is that any replicate measurements *ON
% THE SAME NISKIN* will be selected so that only the average of the highest
% data quality flagged values will be reported on that bottle.
%
% UPDATED:
% Initial version BAK jc032?
% BAK & SFG on jr302 - 17 June 2014 changes to data flow/naming.
%   overhaul for Eithne Tynan CO2 data.
% SFG on jr302 - 18 June 2014 - more changes to naming, commenting.
%
% EXTENSIONS:
% Is there any way to pass the name of the data source file into the
% comments of the netcdf file that is output by this script?
%==========================================================================

scriptname = 'mco2_01';
mcruise = MEXEC_G.MSCRIPT_CRUISE_STRING
mdocshow(scriptname, ['add documentation string for ' scriptname])

% Resolve root directories for various file types
root_co2 = mgetdir('M_BOT_CO2');
root_ctd = mgetdir('M_CTD');

% Set the name of the input file, and load into structure indata
oopt = 'infile'; get_cropt
if ~exist('indata','var'); indata = load(input_file_name); end

% Set up the output file name
prefix1 = ['co2_' mcruise '_'];
dataname = [prefix1 '01'];
otfile = [root_co2 '/' prefix1 '01']; % di346 ; previously hardwired on jc032

% standardise the field names into structure data
oopt = 'varnames'; get_cropt
for no = 1:size(varnames,1)
   indata = setfield(indata, varnames{no,1}, getfield(indata, varnames{no,2}));
end

%=========================================
% First check for any CRM and remove. At the same time, change NaNs in flag fields to 9
if isfield(indata, 'sample_id');
   iicrm = find(strcmp('CRM', indata.sample_id));
   for no = 1:length(varnames)
      a = getfield(indata, varnames{no,1}); a(iicrm) = [];
      if ~isempty(strfind(varnames{no,1}, 'in_flag')); a(isnan(a)) = 9; end
      indata = setfield(indata, varnames{no,1}, a);
   end
end
%=========================================

if ~isfield(indata, 'sampnum')
   if ~isfield(indata, 'statnum') | ~isfield(indata, 'niskin')
      numval = length(indata.sample_id);    % Number of reported observations in input file.
      indata.statnum = NaN+zeros(numval,1); indata.niskin = indata.statnum;
      indata.end_char = cell(numval,1); % Initialize the list of characters at the end of each sample ID.
      % Loop over all the reported observations in the input file.
      for kl = 1:numval
         thisid = indata.sample_id{kl};             % Get the ID for this obs.
         indata.statnum(kl) = str2num(thisid(5:7));    % Get station num from ID
         indata.nisnum(kl) = str2num(thisid(9:10));    % Get niskin num from ID
         if length(thisid) > 10;                % For stations with a terminating
            indata.end_char{kl} = thisid(11:end);     % character, get that character.
         end
      end
   end
   indata.sampnum = indata.statnum*100 + indata.niskin;
end
%!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
% NOTE: Currently nothing is done with the end characters.
% No character -> single observation for this niskin
% A and B -> replicates from the same sample bottle from single niskin
% C -> if machine jams during processing an A or B.  The bad A or B will
%      be filled with NaN and its flag will be 4.
% D -> duplicate sample bottle taken from single niskin.
% R -> rerun if machine jams on single observation or on a D.  Again, the
%      value of the jamming observation will be NaN with flag of 4.
%
% Note that below, any NaN values (observations during which the machine
% jammed) will be retained as NaN and their flags will be reset from 4 to 9.
%!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

%initialize output variables
nbot = 24; nsta = max(indata.statnum)-min(indata.statnum)+1;
sampnum = repmat([min(indata.statnum):max(indata.statnum)],nbot,1)*100 + repmat([1:nbot]',1,nsta); sampnum = sampnum(:);
alk = NaN+sampnum; dic = alk;
alk_flag = 9+zeros(size(sampnum)); dic_flag = alk_flag;

%fill, averaging duplicates according to flags

if isfield(indata, 'alk')
   for k = 1:length(sampnum)
      iis = find(indata.sampnum==sampnum(k));
      iisv = intersect(iis, find(indata.alk_flag>1 & indata.alk_flag<9));
      if length(iisv)>0
	     d = indata.alk(iisv); f = indata.alk_flag(iisv);
         best_flag = min(f);
         alk(k) = mean(d(f==best_flag)); %if there are 2s, average those; if only 3s, average those; etc.
	     alk_flag(k) = best_flag;
         alk_flag(isnan(alk)) = 9; %***temporary until we have flags to input
	     if isnan(alk(k)) & alk_flag(k)<5
            warning(['no value for sampnum ' num2str(sampnum(k)) ' despite flag of ' num2str(alk_flag(k))]); 
         end
      elseif length(iis)>0
         alk(k) = NaN; alk_flag(k) = min(indata.alk_flag(iis)); %either 1 or 9
      end
   end
end

if isfield(indata, 'dic')
   for k = 1:length(sampnum)
      iis = find(indata.sampnum==sampnum(k));
      iisv = intersect(iis, find(indata.dic_flag>1 & indata.dic_flag<9));
      if length(iisv)>0
	     d = indata.dic(iisv); f = indata.dic_flag(iisv);
         best_flag = min(f);
         dic(k) = mean(d(f==best_flag)); %if there are 2s, average those; if only 3s, average those; etc.
	     dic_flag(k) = best_flag;
         dic_flag(isnan(dic)) = 9; %***temporary until we have flags to input
	     if isnan(dic(k)) & dic_flag(k)<5
            warning(['no value for sampnum ' num2str(sampnum(k)) ' despite flag of ' num2str(dic_flag(k))]); 
         end
      elseif length(iis)>0
         dic(k) = NaN; dic_flag(k) = min(indata.dic_flag(iis)); %either 1 or 9
      end
   end
end

oopt = 'flags'; get_cropt

% Some simple QC
kbad = find(dic < 1);
dic(kbad) = nan; dic_flag(kbad) = 9;
kbad = find(alk < 1);
alk(kbad) = nan; alk_flag(kbad) = 9;
dic_flag(dic < 1000 | dic > 3000) = 4;
alk_flag(alk < 1000 | alk > 3000) = 4;

% Set some basic metadata
timestring = ['[' sprintf('%d %d %d %d %d %d',MEXEC_G.MDEFAULT_DATA_TIME_ORIGIN) ']'];
varnames = {'sampnum' 'alk' 'alk_flag' 'dic' 'dic_flag'};
varunits = {'number' 'umol/kg' 'woce_table_4.9' 'umol/kg' 'woce_table_4.9'};

% Sorting out units for msave
varnames_units = {};
for k = 1:length(varnames)
    varnames_units = [varnames_units; varnames(k)];
    varnames_units = [varnames_units; {'/'}];
    varnames_units = [varnames_units; varunits(k)];
end

%--------------------------------
MEXEC_A.MARGS_IN_1 = {
    otfile
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

