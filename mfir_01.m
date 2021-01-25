% mfir_01: read in .bl file and create fir file
%
% Use: mfir_01        and then respond with station number, or for station 16
%      stn = 16; mfir_01;

minit;
mdocshow(mfilename, ['reads in .bl file to fir_' mcruise '_' stn_string '.nc']);

% resolve root directories for various file types
root_botraw = mgetdir('M_CTD_BOT');
root_ctd = mgetdir('M_CTD');
infile = [root_botraw '/ctd_' mcruise '_' stn_string '.bl'];
m = ['infile = ' infile]; fprintf(MEXEC_A.Mfidterm,'%s\n','',m)
prefix = ['fir_' mcruise '_'];
otfile = [root_ctd '/' prefix stn_string '_bl'];
dataname = [prefix stn_string];

cellall = mtextdload(infile,','); % load all text

krow = 0;
kmax = 50; % preallocate space for 50; after that the arrays will grow in the loop
position = nan+zeros(kmax,1);
scan = position;

for kline = 1:length(cellall)
    cellrow = cellall{kline};
    if length(cellrow) < 4
        % header lines
        continue
    else % found a bottle line
        krow = krow+1;
        position(krow) = str2num(cellrow{2});
        scan(krow) = str2num(cellrow{4});
    end
end

scriptname = mfilename; oopt = 'fixbl'; get_cropt

if krow < kmax
    position(krow+1:end) = [];
    scan(krow+1:end) = [];
end

%bak 30 march 2013 jr281
% if no bottles closed, eg on an aborted cast, the msave will crash if
% there are no cycles
% therefore create a sinle bottle entry, with nan for scan number
% the follow-up scripts will all work, and merge nans onto the single row of
% the bottle file.
if (length(position) == 0)
    position = nan;
    scan = nan;
end

%--------------------------------
comment = ['input data from ' infile];
timestring = ['[' sprintf('%d %d %d %d %d %d',MEXEC_G.MDEFAULT_DATA_TIME_ORIGIN) ']'];
MEXEC_A.MARGS_IN = {
    otfile
    'scan'
    'position'
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
    comment
    '/'
    '/'
    '8'
    'scan'
    '/'
    'number'
    'position'
    '/'
    'on.rosette'
    '-1'
    '-1'
    };
msave
%--------------------------------
