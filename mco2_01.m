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
cruise = MEXEC_G.MSCRIPT_CRUISE_STRING;

% Resolve root directories for various file types
root_co2 = mgetdir('M_BOT_CO2');
root_ctd = mgetdir('M_CTD');

% Set the name of the input file
input_file_name = [root_co2 '/co2_' cruiser '_01.mat']; % jr302

% Set up the output file name
prefix1 = ['co2_' cruise '_'];
dataname = [prefix1 '01'];
otfile = [root_ctd '/' prefix1 '01']; % di346 ; previously hardwired on jc032

%==========================================================================
% % infile1 = [root_co2 '/' prefix1 stn_string '.csv'];
% % prefix2 = ['co2_' MEXEC_G.MSCRIPT_CRUISE_STRING '_'];
% % otfile2 = [prefix2 stn_string];
% % 
% % dataname = [prefix2 stn_string];
% % indata=mtextdload(infile1,',');
%==========================================================================

root_co2 = mgetdir('M_BOT_CO2');

% Build the full pathname of the file and load file.
input_file_name_with_path = [root_co2 '/' input_file_name];
d = load(input_file_name_with_path);

% Split the input file into different variables.
% !!!Capitilization is important!!!
in_alk = d.TA;
in_alk_flag = d.TAflag;
in_dic = d.DIC;
in_dic_flag = d.DICflag;
in_sample_id = d.SAMPLE;
clear d

%=========================================
% First check for any CRM and remove.
numval = length(in_sample_id);
remove_list = zeros(size(in_alk));
for kl = 1:numval
   thisid = in_sample_id{kl};
   if ( strcmp(thisid(1:3),'CRM') )
      remove_list(kl) = 1; 
   end
end
remove_list = logical(remove_list);
in_alk(remove_list) = [];
in_alk_flag(remove_list) = [];
in_dic(remove_list) = [];
in_dic_flag(remove_list) = [];
in_sample_id(remove_list) = [];
%=========================================

% Initialize the sampnum, an ID used by mstar to track station number and
% niskin number.  This will become station_number*100 + niskin_number.
% This is the same length as the input number of observations.
in_sampnum = in_alk + nan;

numval = length(in_alk);    % Number of reported observations in input file.
statnum = nan(numval,1);    % Initialize a station number list for each reported observation.
nisnum = statnum;           % Initialize a niskin bottle number list for each obs.
end_char = cell(numval,1);  % Initialize the list of characters at the end of each sample ID.

% Loop over all the reported observations in the input file.
for kl = 1:numval
    thisid = in_sample_id{kl};             % Get the ID for this obs.
    statnum(kl) = str2num(thisid(5:7));    % Get station num from ID
    nisnum(kl) = str2num(thisid(9:10));    % Get niskin num from ID
    if length(thisid) > 10;                % For stations with a terminating
        end_char{kl} = thisid(11:end);     % character, get that character.
    end
    in_sampnum(kl) = statnum(kl)*100 + nisnum(kl);  % Compute the sampnum for this obs.
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
% jammed) will be retained as NaN and their flags will be rest from 4 to 9.
%!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

% Any flag should never be NaN, so any NaN values in the flag are set to 9.
% Also, if there are any NaN values in the observations, then the
% corresponding flags are also set to 9.  BUT, any missing observations,
% those can be NaN.
in_alk_flag(isnan(in_alk_flag)) = 9;
in_alk_flag(isnan(in_alk)) = 9;
in_dic_flag(isnan(in_dic_flag)) = 9;
in_dic_flag(isnan(in_dic)) = 9;

%==========================================================================
%indata_stn = statnum;
%indata_stn = unique(indata_stn);
%indata_stn = unique(statnum);  % Find the number of unique stations
%last_stn = max(indata_stn);    % Find the number of the last station reported.
%==========================================================================
last_stn = max(statnum);  % Find the number of the last station reported.
nsamps = 24*last_stn;     % Compute the maximum possible number of samples,
                          % assuming 24 bottle rosette

% Initialize output variables.  The length of these variables will be
% different from the initial number of observations because we will average
% the values from the same niskin bottle with the same flags together.
% Therefore, we need different variables.
alk = nan+zeros(nsamps,1);
alk_flag = 9+zeros(nsamps,1);
dic = alk;
dic_flag = alk_flag;
sampnum = alk;

% For each station,
for kstn = 1:last_stn
    % For each position on the rosette (i.e. each niskin bottle),
    for kpos = 1:24;
        % Running counter of all the possible bottles at all stations.
        % Starts at 1 for bottle 1, station 1, then bottle 1 station 2 is 25, etc.
        index = kpos+24*(kstn-1);
        snum = kstn*100+kpos;      % Compute the sampnum for this station-bottle combo.
        sampnum(index) = snum;     % Asign this sampnum to the list.
        kmatch = find(in_sampnum == snum);  % Search for reported observations with this sampnum.
        if isempty(kmatch)                  % If non are found, go the next sampnum.
            continue
        end
        
        alk_match = in_alk(kmatch);                    % Get alk for this sampnum
        alk_flag_match = in_alk_flag(kmatch);          % Get flags for alk for this sampnum
        % jr302: some samples have absent data and flag 1 indicating
        % analysis ashore. First look at flags >= 2
        fm = alk_flag_match;
        fm28 = find(fm >= 2 & fm <= 8); % the flag indicates there is a sample that has been analysed
        fm1 = find(fm == 1); % the flag indicates there is a sample that has been analysed
        if ~isempty(fm28) % a sample has been analysed and flagged; this sample will be reported.
            alk_best_flag = min(alk_flag_match);           % Get best quality flag for this sample; so if one replicate has flag = 3 it will be excluded
            kuse = find(alk_flag_match == alk_best_flag);  % Match best flag, eg all the 2s or all the 3s.
            alk(index) = m_nanmean(alk_match(kuse));       % Average only the best flag observations and store for output.
            alk_flag(index) = alk_best_flag;               % Store for output the best flag.
        elseif ~isempty(fm1); % samples have been drawn for analysis ashore
            alk(index) = nan;       
            alk_flag(index) = 1;              
        else  % no sample flagged. Absent data and flag == 9
            alk(index) = nan;      
            alk_flag(index) = 9;               
        end
        
        
        dic_match = in_dic(kmatch);                    % Get DIC for this sampnum
        dic_flag_match = in_dic_flag(kmatch);          % Get flags for DIC for this sampnum
        fm = dic_flag_match;
        fm28 = find(fm >= 2 & fm <= 8); % the flag indicates there is a sample that has been analysed
        fm1 = find(fm == 1); % the flag indicates there is a sample that has been analysed
        if ~isempty(fm28) % a sample has been analysed and flagged; this sample will be reported.
            dic_best_flag = min(dic_flag_match);           % Get best quality flag for this sample; so if one replicate has flag = 3 it will be excluded
            kuse = find(dic_flag_match == dic_best_flag);  % Match best flag, eg all the 2s or all the 3s.
            dic(index) = m_nanmean(dic_match(kuse));       % Average only the best flag observations and store for output.
            dic_flag(index) = dic_best_flag;               % Store for output the best flag.
        elseif ~isempty(fm1); % samples have been drawn for analysis ashore
            dic(index) = nan;       
            dic_flag(index) = 1;              
        else  % no sample flagged. Absent data and flag == 9
            dic(index) = nan;      
            dic_flag(index) = 9;               
        end
        

        % temporary fix: jc032
%         if (kstn == 13 & (kpos == 17 | kpos == 19)); alk_flag(index) = 4; end
    end
end

sampnum = sampnum(:);
alk = alk(:);
alk_flag = alk_flag(:);
dic = dic(:);
dic_flag = dic_flag(:);

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

% return
%--------------------------------
% 2009-03-09 20:49:09
% msave
% input files
% Filename    Data Name :   <version>  <site>
% output files
% Filename oxy_jc032_001.nc   Data Name :  oxy_jc032_001 <version> 1 <site> jc032MEXEC_A.MARGS_IN_1 = {
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
%----

