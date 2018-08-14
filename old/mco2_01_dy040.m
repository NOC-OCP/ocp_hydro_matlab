% mco2_01: read in bottle nut data from csv file
%
% Use: mco2_01        
%
% NOTE: No need to respond with the station number because this script will
% operate on all stations at once based on a single input file.
%
% This version fo dy040, 25 Dec (note the date) 2015 by bak
% One input file from Ute contains a matrix for each variable of interest
%
% This script saves a single output file containing all stations, which can
% be pasted into each station sam file.


scriptname = 'mco2_01';

% resolve root directories for various file types
mcsetd('M_BOT_CO2'); root_co2 = MEXEC_G.MEXEC_CWD;
mcd('M_CTD'); % change working directory

prefix1 = ['co2_' MEXEC_G.MSCRIPT_CRUISE_STRING '_'];
prefix2 = ['co2_' MEXEC_G.MSCRIPT_CRUISE_STRING '_'];

infile1 = [root_co2 '/' prefix1 '01' '.mat'];
otfile2 = [root_co2 '/' prefix2 '01'];   

dataname = [prefix2 '01'];


if exist(infile1,'file')~=2;
    mess = ['File ' infile1 ' not found'];
    fprintf(MEXEC_A.Mfider,'%s\n',mess)
    return
end

indata = load(infile1); % load data from mat



switch MEXEC_G.MSCRIPT_CRUISE_STRING
    case 'dy040'
        %         varnames = {'position','statnum','sampnum','sio4','sio4_flag','po4','po4_flag','no3no2','no3no2_flag','nh4','nh4_flag'};
        %         varunits = {'number','number','number','umol/l','woceflag','umol/l','woceflag','umol/l','woceflag','umol/l','woceflag'};
        indata.matrix_dic = indata.matrix_dic_recalc; % later in cruise, 16 jan , ute removed dic and ta; use _recalc values instead. Need them for later logic
        indata.matrix_ta = indata.matrix_ta_recalc;
end

varall = { % ute's name, units, mexec_name
    'stn' 'number' 'statnum'
    'nisk' 'number' 'position'
    'instr' 'number' 'instrument'
    'cell_id' 'number' 'cell_id'
    'dic' 'umol/kg' 'dic'
    'dic_flag' 'woceflag' 'dic_flag'
    'dic_recalc' 'umol/kg' 'dic_recalc'
    'ta' 'umol/kg' 'alk'
    'ta_flag' 'woceflag' 'alk_flag'
    'ta_recalc' 'umol/kg' 'alk_recalc'
    };

utenames = varall(:,1); utenames = utenames(:)';
varunits = varall(:,2); varunits = varunits(:)';
varnames = varall(:,3); varnames = varnames(:)';

for kl = 1:length(varnames);
    clear vardat;
    cmd = ['vardat = indata.matrix_' utenames{kl} ';']; eval(cmd);
    cmd = [varnames{kl} ' = reshape(vardat,numel(vardat),1);']; eval(cmd)
end

varnames = ['sampnum'  varnames];
varunits = ['number' varunits];

switch MEXEC_G.MSCRIPT_CRUISE_STRING
    case 'dy040'
        sampnum = position + statnum*100;
        
        kdicnan = find(~isfinite(dic)); dic_flag(kdicnan) = 9; % data are nan -> flag should be 9
        kdicunset = find(isfinite(dic) & ~isfinite(dic_flag)); dic_flag(kdicunset) = 2; % data exist and flag unset, flag -> 2;
        dic(~isfinite(dic)) = nan; %make any inf values be nans
        dic_recalc(~isfinite(dic_recalc)) = nan;
        
        kalknan = find(~isfinite(alk)); alk_flag(kalknan) = 9; % data are nan -> flag should be 9
        kalkunset = find(isfinite(alk) & ~isfinite(alk_flag)); alk_flag(kalkunset) = 2; % data exist and flag unset, flag -> 2;
        alk(~isfinite(alk)) = nan; %make any inf values be nans
        alk_recalc(~isfinite(alk_recalc)) = nan;
        
        %         initial crude adjustment for instruments by bak
        
%         k64 = find(instrument == 64);
%         k65 = find(instrument == 65);
%         dic(k64) = 1.014*dic(k64);
% 
        
end


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

