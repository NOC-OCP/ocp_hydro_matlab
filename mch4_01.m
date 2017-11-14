% mch4_01: read in the bottle salinities
%
% Use: mch4_01        and then respond with station number, or for station 16
%      stn = 16; mch4_01;
% 
% first draft bak on jr302 20 jun 2014 to read Ian Brown's CH4/N2O data
%
scriptname = 'mch4_01';

if exist('stn','var')
    m = ['Running script ' scriptname ' on station ' sprintf('%03d',stn)];
    fprintf(MEXEC_A.Mfidterm,'%s\n',m)
else
    stn = input('type stn number ');
end
stn_string = sprintf('%03d',stn);
stnlocal = stn;
clear stn % so that it doesn't persist

% resolve root directories for various file types
root_ch4 = mgetdir('M_BOT_CH4');
prefix1 = ['ch4_' MEXEC_G.MSCRIPT_CRUISE_STRING '_']; % in prefix
prefix2 = ['ch4_' MEXEC_G.MSCRIPT_CRUISE_STRING '_']; % out prefix
infile1 = [root_ch4 '/' prefix1 '01.csv']; % all in one file
otfile2 = [root_ch4 '/' prefix2 stn_string];
dataname = [prefix2 stn_string];


indata=mtextdload(infile1,',');


% for variable arrays, parse to see which rows hold data
nrows=length(indata);
indexval =[];
for k=1:nrows
    data_cell=indata{k};
    if length(data_cell) < 12; continue; end
    if isempty(data_cell{1}); continue; end
    indexval = [indexval k];
end;

% now load the data to an array and assign variable names
varnames={'sampnum', 'ch4' 'ch4_flag' 'ch4_sat' 'n2o' 'n2o_flag' 'n2o_sat' 'ch4_temp'};
varunits={'number','nmol/l','woce_table_4.9','percent','nmol/l','woce_table_4.9','percent','degc'};

% wkdata reads all data
wkdata=ones(length(indexval),length(varnames))+nan;

for kloop=1:length(indexval)
    krow = indexval(kloop);
    data_cell = indata{krow};
    
    stat = str2num(data_cell{3});
    nis = str2num(data_cell{4});
    wkdata(kloop,1) = 100*stat+nis; % sampnum
    wkdata(kloop,2) = str2num(data_cell{11}); % ch4
    wkdata(kloop,3) = 2; % ch4 flag
    wkdata(kloop,4) = str2num(data_cell{12}); % ch4 sat
    wkdata(kloop,5) = str2num(data_cell{9}); % n2o
    wkdata(kloop,6) = 2; % n2o flag
    wkdata(kloop,7) = str2num(data_cell{10}); % n2o sat
    wkdata(kloop,8) = str2num(data_cell{8}); % analysis temp
end
    

% match this station
   
sampnum = wkdata(:,1);
kmatch = find(sampnum > stnlocal*100 & sampnum < stnlocal*100+99);

if isempty(kmatch); return; end % exit if no data for this station

wkdata = wkdata(kmatch,:);

otdata = nan(24,size(wkdata,2));
otdata(:,1) = 100*stnlocal+[1:24];
otdata(:,3) = 9;
otdata(:,6) = 9;

% paste into 24 rows
for kloop = 1:size(wkdata,1)
    sampnum = wkdata(kloop,1);
    otrow = find(otdata(:,1) == sampnum);
    otdata(otrow,:) = wkdata(kloop,:);
end

% save the data in the correct name
for kloop = 1:length(varnames)
    cmd = [varnames{kloop} ' = otdata(:,kloop);']; eval(cmd)
end


% sorting out units for msave

varnames_units = {};
for k = 1:length(varnames)
    varnames_units = [varnames_units; varnames(k)];
    varnames_units = [varnames_units; {'/'}];
    varnames_units = [varnames_units; varunits(k)];
end

timestring = ['[' sprintf('%d %d %d %d %d %d',MEXEC_G.MDEFAULT_DATA_TIME_ORIGIN) ']'];


%--------------------------------
% 2009-03-09 20:49:09
% msave
% input files
% Filename    Data Name :   <version>  <site>
% output files
% Filename oxy_jc032_001.nc   Data Name :  oxy_jc032_001 <version> 1 <site> jc032MEXEC_A.MARGS_IN_1 = {
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

