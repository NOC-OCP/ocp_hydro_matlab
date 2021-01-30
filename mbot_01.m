% mbot_01: prepare data about niskin bottles, based on csv bottle file(s)
%
% Use: mbot_01        and then respond with station number, or for station 16
%      stn = 16; mbot_01;
%
% Loads information on Niskin bottles from either opt_cruise or a concatenated, comma-delimited file
%    with fields including either station, niskin OR sampnum = 100*station+niskin
%    and optionally
%        bottle_number, which otherwise will be set equal to niskin, and
%        bottle_qc_flag, which otherwise may be set in opt_cruise
%
% YLF jr16002 and jc145 modified heavily to use database and cruise-specific options

minit;
mdocshow(mfilename, ['puts Niskin bottle information from file specified in opt_' mcruise ' (by default, bot_' mcruise '_' stn_string '.csv) into bot_' mcruise '_' stn_string '.nc']);

% resolve root directories for various file types
root_bot = mgetdir('M_CTD_CNV'); % the csv bottle file(s) is/are in the ascii files directory
root_ctd = mgetdir('M_CTD');
dataname = ['bot_' mcruise '_' stn_string];
otfile = [root_ctd '/' dataname];

%load the sample information from the file produced by mbot_00
scriptname = 'mbot_00'; oopt = 'nbotfile'; get_cropt
ds_bot = dataset('File', botfile, 'Delimiter', ',');

%get expected fields
fn = ds_bot.Properties.VarNames;
if ~sum(strcmp('sampnum', fn))
    ds_bot.sampnum = ds_bot.statnum*100 + ds_bot.niskin;
end
if ~sum(strcmp('statnum', fn))
    ds_bot.statnum = floor(ds_bot.sampnum/100);
    ds_bot.niskin = ds_bot.sampnum - 100*ds_bot.statnum;
end
if ~sum(strcmp('bottle_number', fn))
    ds_bot.bottle_number = ds_bot.niskin;
end
if ~sum(strcmp('bottle_qc_flag', fn))
    ds_bot.bottle_qc_flag = 2+zeros(size(ds_bot.sampnum));
end

%extract info for this station
iista = find(ds_bot.statnum==stnlocal);

if length(iista)>0
    
    %eliminate lines about duplicate samples from the same bottle***
    [c, iiu] = unique(ds_bot.sampnum); ds_bot = ds_bot(iista(iiu),:);
    
    %get variables and units for msave
    varnames = {'sampnum','statnum','position','bottle_number','bottle_qc_flag'};
    varunits = {'number','number','on rosette','number', 'woce table 4.8'};
    ds = ds_bot; mvarnames_units; clear ds
    
    %modify flags
    scriptname = mfilename; oopt = 'botflags'; get_cropt
    
    timestring = ['[' sprintf('%d %d %d %d %d %d',MEXEC_G.MDEFAULT_DATA_TIME_ORIGIN) ']'];
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
    
else
    
    warning(['no Niskin bottle info for station ' stn_string])
    
end
