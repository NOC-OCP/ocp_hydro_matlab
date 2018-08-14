% msal_01: read in the bottle salinities
%
% Use: msal_01        and then respond with station number, or for station 16
%      stn = 16; msal_01;
% 
% Input adjustment to standard seawater and bath temperature when prompted
% 
% Complete overhaul on jr302 by BAK 7 June 2014. Ignore the first column
% of crate label, and sort out the values according to the sample number.
% 00101 to 99901 for CTD samples stations 1 to 999
% 999001 to 999999 for standards
% 001000000 to 366235959 for TSG timed samples dddhhmmss
%
% salinity_adj(k) = sw_sals((runavg(k)+adj)/2, bath_temperature);

scriptname = 'msal_01';
minit
mdocshow(scriptname, ['add documentation string for ' scriptname])


% resolve root directories for various file types
mcsetd('M_BOT_SAL'); root_sal = MEXEC_G.MEXEC_CWD;
mcd('M_CTD'); % change working directory

prefix1 = ['sal_' mcruise '_'];
prefix2 = ['sal_' mcruise '_'];

if ~exist('sal_csv_file', 'var')
    %   infile1 = [root_sal '/' prefix1 stn_string '.csv'];
    % bak on jr302: we now use an appended autosal csv file that contains all the analysed values.
    % prompt for name of appended auotsal csv file if it hasn't
    % been pre-set:
    sal_csv_file = input('type name of appended autosal csv file (eg sal_jr302_01.csv) ','s');
    infile1 = [root_sal '/' sal_csv_file];
else % bak on dy040: check the user wants to use the file name already set
    m = ['sal_csv_file already set to : ' sal_csv_file];
    fprintf(2,'\n\n%s\n\n\n',m)
    answer = input('do you wish to proceed with this csv file ? (answer y or n) ','s');
    if strcmp(answer,'y')
        infile1 = [root_sal '/' sal_csv_file];
    else
        clear sal_csv_file
        sal_csv_file = input('type name of appended autosal csv file (eg sal_jr302_01.csv) ','s');
        infile1 = [root_sal '/' sal_csv_file];
    end
end
otfile2 = [root_sal '/' prefix2 stn_string];
dataname = [prefix2 stn_string];

% bak on jr281 april 2013, for stations with no salt samples we want to
% generate a file with nan for data and 9 for flag

if ~exist(infile1, 'file')
    mess = ['csv file ' infile1 ' not found']; % bak on jc069 exit if file not in the right place
    fprintf(MEXEC_A.Mfider,'%s\n',mess);
    switch mcruise
        case 'jr281'
            oklist = [72]; % proceed on these stations. CTD but no salts
            if(isempty(find(oklist == stnlocal)));
                return
            end
            indata = {}; % the rest of the code seems to run fine if indata is empty.
        otherwise
            return % if not a special case, return after warning
    end
else
    indata=mtextdload(infile1,',');
end



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
    if(sampraw >= 001000000 & sampraw <= 366235959) % time of tsg sample
        indextsg = [indextsg k];
    end
end;

indexstn = unique(indexstn);
indexstd = unique(indexstd);
indextsg = unique(indextsg);

% now load the data to an array and assign variable names
varnames={'station','salbot','run1','run2','run3','runavg','salinity','sampnum', 'flag'};
varunits={'number','number','number','number','number','number','pss-78','number','woce table'};

% otdata has 24 rows, one for each niskin bottle
otdata=ones(length(indexstn),length(varnames)+1)+nan;
% otdata=ones(24,length(varnames))+nan;


l=1;
for krow=indexstn
    data_cell = indata{krow};
    strng=data_cell{1};
    % % %     otdata(l,1)=str2double(strng(4:6));
    % % %     otdata(l,2)=str2double(strng(8:end));
    % % % %     otdata(l,2)=str2double(strng(7:end));%for the badly named files
    % bak 12 jun 2014 revised on jr302 so station number is taken from sample number
    numeric = str2double(data_cell{10});
    numeric_stn = floor(numeric/100);
    if numeric_stn ~= stnlocal ; continue; end
    otdata(l,1) = numeric_stn;
    kunderscore = strfind(strng,'_'); % mod by BAK jc159 4 March 2018, search for the sample bottle number after the final underscore
    if length(kunderscore) > 0
        otdata(l,2) = str2double(strng(kunderscore(end)+1:end));
    else
        otdata(l,2) = str2double(strng(end-2:end)); % hope for the best if no underscore delimiter; may need to adjust where to pick up the bottle number
    end
    % end of revision
    
    for kcol=[4:10];
        otdata(l,kcol-1)=str2double(data_cell{kcol});
    end;
    otdata(l,10)=2;


    l=l+1;
end;

switch mcruise
    case 'jr302'
        if stnlocal == 7; otdata([1 2 3 4 5],10) = 3; end % set some flags. measured on wrong scale ?
        if stnlocal == 8; otdata([1 2 3 4 5],10) = 3; end % set some flags
    otherwise
end

% tidying up to make sure that there are 24 rows in each file

pind=find(otdata(:,9)<999000);
% position=otdata(pind,9)-stnlocal*100;
position=rem(otdata(pind,9),100); % bak  12 jun 2014 jr302. Different way to determine position when a crate contains samples from more than one station

station=ones(24,1)*stnlocal;
sampnum=[1:24]+stnlocal*100;
sampnum=sampnum(:);
flag=ones(24,1)*9;


for kcol=1:length(varnames)
    if kcol>1&&kcol<8
        cmd=[varnames{kcol} '=ones(24,1)+NaN;'];eval(cmd);
    end
    if kcol<7
        cmd=[varnames{kcol} '(position)=otdata(pind,kcol);'];eval(cmd);
     
    else
        cmd=[varnames{kcol} '(position)=otdata(pind,kcol+1);'];eval(cmd);
       
    end;
end;

% recalculating salinity
% bak on jr302: put the adjustment and bath temperature in here, instead of
% prompting from terminal every time.

% bath temperature can be different for every sample, in case a station is
% split across more than one autosal run

switch mcruise
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
        bath_temperature = nan(size(sampnum));
        adj = bath_temperature;    
        for k = 1:length(sampnum)
            if sampnum(k) >= 101 & sampnum <= 99999  % all stations
                bath_temperature(k) = 24; % norm on jr302
                adj(k) = 0;
            end
        end
    case 'jr302'
        bath_temperature = nan(size(sampnum));
        adj = bath_temperature;
        
        g_adj = [ % offset and bath temperature for each range of sample numbers, so the required values can be picked off with interpolation
            100 24 0
            2099 24 0
            2100 24 -1
            3099 24 -1
            3100 24 -2
            3299 24 -2
            3300 24 -3
            3699 24 -3
            3700 24 -4
            4099 24 -4
            4100 24 -5
            4699 24 -5
            4700 24 -6
            5499 24 -6
            5500 24 -7
            6099 24 -7
            6100 24 -8
            6399 24 -8
            6400 24 -9
            6599 24 -9
            6600 24 0 % other autosal
            6715 24 0
            6716 24 -9 % return to main autosal;
            7499 24 -9
            7500 24 -10
            7999 24 -10
            8000 24 -11
            9099 24 -11
            9100 24 -12
            14399 24 -12
            14400 24 -19
            15099 24 -19
            15100 24 -15
            16599 24 -15
            16600 24 -14 % stations analysed out of order while decision changed from -15 to -14
            16699 24 -14
            16700 24 -15
            16799 24 -15
            16800 24 -14
            16899 24 -14
            16900 24 -15
            16999 24 -15
            17000 24 -14
            17799 24 -14
            17800 24 -13
            19899 24 -13
            19900 24 -9
            20499 24 -9
            20500 24 -13
            23499 24 -13
            99999 24 -13 % boundaries refined at end of cruise
            ];
        % bath temp 24 on jr302. You could set this different for different sampnums within a station
        
        for k = 1:length(sampnum)
                bath_temperature(k) = interp1(g_adj(:,1),g_adj(:,2),sampnum(k)); % norm on jr302
                adj(k) = interp1(g_adj(:,1),g_adj(:,3),sampnum(k));
        end
    case 'jr306'
        bath_temperature = nan(size(sampnum));
        adj = bath_temperature;
        
        g_adj = [ % offset and bath temperature for each range of sample numbers, so the required values can be picked off with interpolation
%             100 24 0
%             99999 24 0 % boundaries refined at end of cruise
            100 24 -5
            599 24 -5
            600 24 -10
            1099 24 -10
            1100 24 -13
            1299 24 -13
            1300 24 -8
            1699 24 -8
            1700 24 -5
            1799 24 -5
            1800 24 -7
            1899 24 -7
            1900 24 -10
            1999 24 -10
            2000 24 -12
            2099 24 -12
            2100 24 -13
            2199 24 -13
            2200 24 -10
            2299 24 -10
            2300 24 -9
            2499 24 -9
            2500 24 -11
            2799 24 -11
            2800 24 -7
            3099 24 -7
            99999 24 -7
            ];
        % bath temp 24 on jr306. You could set this different for different sampnums within a station
        
        for k = 1:length(sampnum)
                bath_temperature(k) = interp1(g_adj(:,1),g_adj(:,2),sampnum(k)); % norm on jr302
                adj(k) = interp1(g_adj(:,1),g_adj(:,3),sampnum(k));
        end
    case 'dy040'
        bath_temperature = nan(size(sampnum));
        adj = bath_temperature;
        
        g_adj = [ % offset and bath temperature for each range of sample numbers, so the required values can be picked off with interpolation
            %             100 24 0
            %             99999 24 0 % boundaries refined at end of cruise
            100 24 4
            2699 24 4
            2700 24 6
            2999 24 6 
            3000 24 5
            3099 24 5
            3100 24 6
            3199 24 6
            3200 24 5
            3299 24 5
            3300 24 2
            3799 24 2
            3900 24 3
            4099 24 3
            4100 24 4
            4499 24 4
            4500 24 3
            4899 24 3
            4900 24 4
            5799 24 4
            5800 24 5
            6699 24 5
            6700 24 0
            7399 24 0
            7400 24 1
            9199 24 1
            9200 24 2
            11599 24 2
            11600 24 4
            12499 24 4
            12500 24 0
            12799 24 0
            12800 24 -2
            13099 24 -2
            13100 24 -2
            14599 24 -2
            50200 24 2
            50299 24 2
            ];
        % bath temp 24 on dy040. You could set this different for different sampnums within a station
        
        for k = 1:length(sampnum)
            bath_temperature(k) = interp1(g_adj(:,1),g_adj(:,2),sampnum(k)); % norm on jr302
            adj(k) = interp1(g_adj(:,1),g_adj(:,3),sampnum(k));
        end
    case 'jc159'
        bath_temperature = nan(size(sampnum));
        adj = bath_temperature;
        
        g_adj = [ % offset and bath temperature for each range of sample numbers, so the required values can be picked off with interpolation
            %             100 24 0
            %             99999 24 0 % boundaries refined at end of cruise
            100 21 0
            299 21 0
            300 21 0
            399 21 0
            400 21 -3
            499 21 -3
            500 21 -4
            599 21 -4
            600 21 -5
            799 21 -5
            800 21 -7
            899 21 -7
            900 21 -8
            999 21 -8
            1000 21 -9
            1099 21 -9
            1100 21 -11
            1199 21 -11
            1200 21 -12
            1299 21 -12
            1300 21 -10
            1399 21 -10
            1400 21 -12
            1499 21 -12
            1500 21 -13
            1599 21 -13
            1600 21 -16
            1699 21 -16
            1700 21 -14
            1799 21 -14
            1800 21 -11
            1899 21 -11
            1900 21 -11
            1999 21 -12
            2000 21 -12
            2099 21 -12
            2100 21 -10
            2199 21 -10
            2200 21 -13
            2299 21 -13
            2301 21 -4
            2324 21 -4
            2401 21 -7
            2424 21 -7
            2501 21 -1
            2524 21 -1
            2601 21 -5
            2624 21 -5
            2901 21 -7
            2924 21 -7
            99999 21 -7
            ];
        % bath temp 24 on dy040. You could set this different for different sampnums within a station
        
        for k = 1:length(sampnum)
            bath_temperature(k) = interp1(g_adj(:,1),g_adj(:,2),sampnum(k)); % norm on jr302
            adj(k) = interp1(g_adj(:,1),g_adj(:,3),sampnum(k));
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
    % changed on JC064
    % pef, scu
    % the above code is simpler and does the same thing
    % also, the bath temperature should not be hardcoded!
    %salinity_adj(k)=sw_salt((runavg(k)+adj)/2*sw_salrt(24),24,0);

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
%--------------------------------

