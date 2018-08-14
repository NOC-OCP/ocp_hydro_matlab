% mtsg_01: read in the bottle salinities
%
% Use: mtsg_01        and then respond with station number, or for station 16
%      stn = 16; mtsg_01;
%
% READS IN TSG CRATE DATA 
% OUTPUT = ctd/tsg_di346_###.nc   (where ### = crate number)
% and tsg_di346.nc (file containing all existing tsg bottle data appended)
% revised on jr302 bak 19 jun 2014 to mirror msal_01
%
% note the input file for crate 003 is now tsg_jr302_003.csv_linux
%
% where that file has been created with 
% mac2unix -n tsg_jr302_003.csv tsg_jr302_003.csv_linux
% which makes the file readable in linux with the correct cr/lf
%
% the adjustment and bath temperature is now set up in a table within this
% script

scriptname = 'mtsg_01';

clear batch bath_temperature batch_num stn

if exist('stn','var')
    m = ['Running script ' scriptname ' on tsg crate ' sprintf('%03d',stn)];
    fprintf(MEXEC_A.Mfidterm,'%s\n',m)
else
    stn = input('type tsg crate number ');
end
stn_string = sprintf('%03d',stn);
% clear stn % so that it doesn't persist

% resolve root directories for various file types

% ship =  MEXEC_G.Mship;
% tidying up on dy040 bak 17 dec 2015; version that had evolved on JCR no
% longer suitable for techsas; guessing what will work on cook based on new
% discovery
cruise = MEXEC_G.MSCRIPT_CRUISE_STRING;
ship = MEXEC_G.MSCRIPT_CRUISE_STRING(1:2);

% choose output directory
switch ship
    case 'jr'
        mcsetd('M_OCL'); root_out = MEXEC_G.MEXEC_CWD; % put the output files here
        otdir = 'M_OCL';
    case 'jc'
        mcsetd('M_MET_TSG'); root_out = MEXEC_G.MEXEC_CWD; % put the output files here. It looks like on jc069 bak preocessed the tsg files in the CTD directory
        otdir = 'M_MET_TSG'; % changed from M_CTD on dy040
    case 'dy'
        mcsetd('M_MET_TSG'); root_out = MEXEC_G.MEXEC_CWD; % put the output files here. It looks like on jc069 bak preocessed the tsg files in the CTD directory
        otdir = 'M_MET_TSG'; % changed from M_CTD on dy040
    otherwise
        return
end

mcsetd('M_BOT_SAL'); root_sal = MEXEC_G.MEXEC_CWD; % place the input csv files here

mcd('M_CTD'); % change working directory

prefix1 = ['tsg_' MEXEC_G.MSCRIPT_CRUISE_STRING '_'];
prefix2 = ['tsg_' MEXEC_G.MSCRIPT_CRUISE_STRING '_'];


infile1 = [root_sal '/' prefix1 stn_string '.csv_linux'];
otfile2 = [root_out '/' prefix2 stn_string];

dataname = [prefix2 stn_string];
indata=mtextdload(infile1,',');

% for variable arrays, parse to see which rows hold data
nrows=length(indata);
indexstn =[];
indexstd =[];
indextsg =[];
for k=1:nrows
    data_cell=indata{k};
    if length(data_cell) < 10; continue; end
    strng=data_cell{10};
    if isempty(strng); 
        continue;
    else
        fprintf(1,'%s\n',strng)
    end;
    if strmatch(strng(1),'s') % this is the sampnum heading line
        continue
    end
    sampraw = str2num(strng);
    if isempty(sampraw) % number not decoded
        continue
    end
    if(sampraw >= 00101 & sampraw <= 99901) % ctd sample
        indexstn = [indexstn k];
    end
    if(sampraw >= 999000 & sampraw <= 999999) % standard
        indexstd = [indexstd k];
    end
    if(sampraw >= 001000000 & sampraw <= 400235959) % time of tsg sample % bak on dy040; need to allow day > 366 after new year
        indextsg = [indextsg k];
    end
end;

indexstn = unique(indexstn);
indexstd = unique(indexstd);
indextsg = unique(indextsg);

index = indextsg;


% now load the data to an array and assign variable names
varnames={'salbot','run1','run2','run3','runavg','salinity','time', 'flag'};
varunits={'number','number','number','number','number','pss-78','seconds','woce table'};

% otdata has 24 rows, one for each niskin bottle
otdata=ones(length(index),9)+nan;
% otdata=ones(24,length(varnames))+nan;


l=1;
for krow=index
    data_cell = indata{krow};
    strng=data_cell{1};
    otdata(l,1)=str2double(strng(8:end));

    for kcol=[4:10];
        otdata(l,kcol-2)=str2double(data_cell{kcol});
    end;
    otdata(l,9)=2;

    l=l+1;
end;

pind=find(otdata(:,8)>1000000);


for kcol=1:length(varnames)
    
    if kcol<6
        cmd=[varnames{kcol} '=otdata(pind,kcol);'];eval(cmd);
    else
        cmd=[varnames{kcol} '=otdata(pind,kcol+1);'];eval(cmd);
       
    end;
end;

time=num2str(time);
sz=size(time);
year=2009;
seconds=time(:,sz(2)-1:sz(2));
minutes=time(:,sz(2)-3:sz(2)-2);
hours=time(:,sz(2)-5:sz(2)-4);
day=time(:,1:sz(2)-6);

% gdm adjusted to suit jan 1 = day 0 for underway processing
% hrp adjusted script from jc032 to include minutes (previously missing)
% from line below
time=(str2num(day)-1)*86400+str2num(hours)*60*60+str2num(minutes)*60+str2num(seconds);


% recalculating salinity
ind=[];

cruise = MEXEC_G.MSCRIPT_CRUISE_STRING;

switch cruise  % code adapted from new msal_01
    % bath_temperature, can be different for each station, depending on
    % sample number, and could even differ within a station if a
    % station had been split across two autosal runs at different
    % temperatures
    
    % adjustment, adj, can also be refined to vary within a station if
    % required
    
    % adj is the number of guildline counts to be added to the guildline
    % ratio. eg if the guildline display should be 1.99968 for P156, and
    % if the guildline display for a standard is 1.99970, then adj is
    % -2
    case 'example' % default if the bath temp is 24, to get started until the standardisation has been agreed
        bath_temperature = nan(size(index));
        adj = bath_temperature;    
        for k = 1:length(index)
            if stn >= 1 & stn <= 99999  % all crates
                bath_temperature(k) = 24; % norm on jr302
                adj(k) = 0;
            end
        end
    case 'jr302'
        bath_temperature = nan(size(index));
        adj = bath_temperature;
        
        g_adj = [ % offset and bath temperature for each crate, so the required values can be picked off with interpolation
            % this could be adapted to work on specific times, if you
            % wanted a different adjustment within a crate.
            1 24 0
            2 24 -2
            3 24 -7
            4 24 -11
            5 24 -12
            6 24 -20
            7 24 -15
            8 24 -9
            9 24 -13
            99999 24 -13
            ];
        % bath temp 24 on jr302. You could set this different for different sampnums within a station
        
        for k = 1:length(index)
                bath_temperature(k) = interp1(g_adj(:,1),g_adj(:,2),stn); %  stn is crate number in this script
                adj(k) = interp1(g_adj(:,1),g_adj(:,3),stn);
        end
    case 'jr306'
        bath_temperature = nan(size(index));
        adj = bath_temperature;
        
        g_adj = [ % offset and bath temperature for each crate, so the required values can be picked off with interpolation
            % this could be adapted to work on specific times, if you
            % wanted a different adjustment within a crate.
            1 24 -10
            2 24 -9
            99999 24 -13
            ];
        % bath temp 24 on jr306. You could set this different for different sampnums within a station
        
        for k = 1:length(index)
                bath_temperature(k) = interp1(g_adj(:,1),g_adj(:,2),stn); %  stn is crate number in this script
                adj(k) = interp1(g_adj(:,1),g_adj(:,3),stn);
        end
    case 'dy040'
        bath_temperature = nan(size(index));
        adj = bath_temperature;
        
        g_adj = [ % offset and bath temperature for each crate, so the required values can be picked off with interpolation
            % this could be adapted to work on specific times, if you
            % wanted a different adjustment within a crate.
            1 24 4
            2 24 3
            3 24 4
            4 24 0
            5 24 1
            6 24 2
            7 24 2
            8 24 4
            9 24 -2
            10 24 -2
            99999 24 -2
            ];
        % bath temp 24 on dy040. You could set this different for different sampnums within a station
        
        for k = 1:length(index)
                bath_temperature(k) = interp1(g_adj(:,1),g_adj(:,2),stn); %  stn is crate number in this script
                adj(k) = interp1(g_adj(:,1),g_adj(:,3),stn);
        end
    otherwise
        msg1 = ['You must set up a cruise specific case in this code,'];
        msg2 = ['in which you set the correct bath temperature and required adjustment to guildline values.'];
        msg3 = ['Follow jr302 as an example'];
        fprintf(2,'%s\n',msg1,msg2,msg3)
        return
end


salinity_adj=salinity*NaN;
for k=1:length(salinity)
    
    salinity_adj(k) = sw_sals((runavg(k)+adj(k)/1e5)/2, bath_temperature(k));    

end;

sal_adj_comment_string = ['Adjustments applied to runavg for Guildline offset are ' sprintf('%4d',adj)];

varnames=[varnames 'salinity_adj'];
varunits=[varunits 'pss-78'];

% sorting out units for msave

varnames_units = {};
for k = 1:length(varnames)
    varnames_units = [varnames_units; varnames(k)];
    varnames_units = [varnames_units; {'/'}];
    varnames_units = [varnames_units; varunits(k)];
end

timestring = ['[' sprintf('%d %d %d %d %d %d',MEXEC_G.MDEFAULT_DATA_TIME_ORIGIN) ']'];
clear stn;


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
    '7'
    '-1'
    sal_adj_comment_string
    ' '
    ' '
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

cmd = ['mcd ' otdir]; eval(cmd)

% append this to the whole of the tsg data
% !/bin/rm tsg_list
% !ls tsg_di368_0??.nc > tsg_list       

if exist('tsg_list')==2
    unix(['/bin/rm tsg_list'])
end;

unix(['ls -1 tsg_' MEXEC_G.MSCRIPT_CRUISE_STRING '_0??.nc > tsg_list'])
% makes new list of existing tsg crate files

cruise_file=['tsg_' MEXEC_G.MSCRIPT_CRUISE_STRING '_all.nc'];
cruise_name=['tsg_' MEXEC_G.MSCRIPT_CRUISE_STRING '_all'];

% output files
MEXEC_A.MARGS_IN = {
%'tsg_di346.nc'
%'tsg_di346'
cruise_file
cruise_name
'f'
'tsg_list'
'/'
'c'
};
mapend
%--------------------------------




