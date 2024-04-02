%==========================================================================
% mco2_01: read in the bottle co2 data
%
% Usage: mco2_01
%
% NOTE: No need to respond with the station number because this script will
% operate on all stations at once based on a single input file.
%
% This script assumes that the input file will be a .mat file (name 
% specified as cruise option and residing in the default
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
% ylf on dy146 - Mar 2022 - use mfsave
%
%==========================================================================

m_common
if MEXEC_G.quiet<=1; fprintf(1, 'reading in bottle co2 data and saving to co2_%s_01.nc and sam_%s_all.nc',mcruise,mcruise); end

% Resolve root directories for various file types
root_co2 = mgetdir('M_BOT_CO2');
root_ctd = mgetdir('M_CTD');

% Set the name of the input file, and load into structure indata
                input_file_name = fullfile(root_co2, ['co2_' mcruise '_01.mat']);
opt1 = mfilename; opt2 = 'infile'; get_cropt
if ~exist('indata','var'); indata = load(input_file_name); end

% Set up the output file name
prefix1 = ['co2_' mcruise '_'];
dataname = [prefix1 '01'];
otfile = fullfile(root_co2, [prefix1 '01']);

% standardise the field names into structure data
                varnames = {'alk' 'TA'
                    'alk_flag' 'TAflag'
                    'dic' 'DIC'
                    'dic_flag' 'DICflag'
                    'sample_id' 'SAMPLE'
                    };
opt1 = mfilename; opt2 = 'varnames'; get_cropt
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
   if ~isfield(indata, 'statnum') || ~isfield(indata, 'niskin')
      numval = length(indata.sample_id);    % Number of reported observations in input file.
      indata.statnum = NaN+zeros(numval,1); indata.niskin = indata.statnum;
      indata.end_char = cell(numval,1); % Initialize the list of characters at the end of each sample ID.
      % Loop over all the reported observations in the input file.
      for kl = 1:numval
         thisid = indata.sample_id{kl};             % Get the ID for this obs.
         indata.statnum(kl) = str2num(thisid(5:7));    % Get station num from ID
         indata.nisnum(kl) = str2num(thisid(9:10));    % Get niskin num from ID
         if length(thisid) > 10              % For stations with a terminating
            indata.end_char{kl} = thisid(11:end);     % character, get that character.
         end
      end
   end
   indata.sampnum = indata.statnum*100 + indata.niskin;
end

%initialize output variables
clear d
nbot = 24; nsta = max(indata.statnum)-min(indata.statnum)+1;
d.sampnum = repmat([min(indata.statnum):max(indata.statnum)],nbot,1)*100 + repmat([1:nbot]',1,nsta); 
d.sampnum = d.sampnum(:);
d.alk = NaN+d.sampnum; d.dic = d.alk;
d.alk_flag = 9+zeros(size(sampnum)); d.dic_flag = d.alk_flag;

%average duplicates according to flags
d = sam_dupl(indata, {'alk' 'dic'}, 'good');

opt1 = mfilename; opt2 = 'flags'; get_cropt

%and check for flags matching NaNs
d = hdata_flagnan(d);

% Some simple QC
kbad = (d.dic < 1);
d.dic(kbad) = nan; d.dic_flag(kbad) = 9;
kbad = (d.alk < 1 | d.alk > 5000);
d.alk(kbad) = nan; d.alk_flag(kbad) = 9;
d.dic_flag(d.dic < 1000 | d.dic > 3000) = 4;
d.alk_flag(d.alk < 1000 | d.alk > 3000) = 4;

% put into structure to save
clear dnew hnew
hnew.dataname = ['co2_' mcruise '_01'];
if iscell(input_file_name)
    hnew.comment = sprintf('co2 loaded from %s,' input_file_name{:});
else
    hnew.comment = sprintf('co2 loaded from %s',input_file_name);
end
hnew.fldnam = {'sampnum' 'alk' 'alk_flag' 'dic' 'dic_flag'};
hnew.fldunt = {'number' 'umol/kg' 'woce_table_4.9' 'umol/kg' 'woce_table_4.9'};
for no = 1:length(hnew.fldnam)
    dnew.(hnew.fldnam{no}) = d.(hnew.fldnam{no});
end

%save
mfsave(otfile, dnew, hnew)

%now add to sam file
samfile = fullfile(root_ctd, ['sam_' mcruise '_all']);
mfsave(samfile, dnew, hnew, '-merge', 'sampnum')
