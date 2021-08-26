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

scriptname = 'castpars'; oopt = 'minit'; get_cropt
mdocshow(mfilename, ['puts Niskin bottle information from .bl files and from opt_' mcruise ' into bot_' mcruise '_' stn_string '.nc']);

% resolve root directories for various file types
root_bot = mgetdir('M_CTD_BOT'); % the bottle file(s) is/are in the ascii files directory
scriptname = mfilename; oopt = 'blfilename'; get_cropt
infile = fullfile(root_botraw, infile);

arebottles = 0;

if exist(infile,'file')
    
    % first read the .bl file.
    cellall = mtextdload(infile,','); % load all text
    krow = 0; clear blpos
    for kline = 1:length(cellall)
        cellrow = cellall{kline};
        if length(cellrow) < 4
            % header lines
            continue
        else % found a bottle line
            krow = krow+1;
            blpos(krow,1) = str2num(cellrow{2});
        end
    end
    
    if krow>0
        
    scriptname = 'castpars'; oopt = 'nnisk'; get_cropt
    clear ds
    ds.position = [1:nnisk]';
    ds.sampnum = 100*stnlocal + ds.position;
    ds.statnum = stnlocal + zeros(nnisk,1);
    ds.niskin_flag = 9+zeros(nnisk,1); % default flag of 9 meaning not closed
    ds.niskin_flag(blpos) = 2; % if bottle closed, default closure flag is 2.
    
    scriptname = mfilename; oopt = 'nispos'; get_cropt; %niskin-position mapping information
    ds.niskin = niskin; 

    %get variables and units for msave
    varnames = {'sampnum','statnum','position','niskin','niskin_flag'};
    varunits = {'number','number','on.rosette','number', 'woce table 4.8'};
    force_set_var = 1; mvarnames_units; clear ds force_set_var
    
    %modify flags
    scriptname = mfilename; oopt = 'botflags'; get_cropt
    
    dataname = ['bot_' mcruise '_' stn_string];
    otfile = fullfile(root_bot, dataname);
    MEXEC_A.Mprog = mfilename;

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
    
    arebottles = 1;
    
    end
    
end

if ~arebottles
    warning(['no Niskin bottle info for station ' stn_string ' in ' infile])
else
    
    %write to sam_cruise_all.nc
    root_ctd = mgetdir('M_CTD');
    root_bot = mgetdir('M_CTD_BOT'); % the bottle file(s) is/are in the ascii files directory
    infile = fullfile(root_bot, ['bot_' mcruise '_' stn_string]);
    otfile = fullfile(root_ctd, ['sam_' mcruise '_all']);
    
    if exist(m_add_nc(infile),'file') == 2
        [d,h] = mloadq(infile,'/');
        clear hnew
        hnew.fldnam = h.fldnam; hnew.fldunt = h.fldunt;
        hnew.dataname = h.dataname; hnew.mstar_site = h.mstar_site; hnew.version = h.version;
        if sum(~isnan(d.sampnum))>0
            MEXEC_A.Mprog = mfilename;
            mfsave(otfile, d, hnew, '-merge', 'sampnum');
        end
    end
    
end

