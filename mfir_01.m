% mfir_01: read in .bl file and create fir file
%
% Use: mfir_01        and then respond with station number, or for station 16
%      stn = 16; mfir_01;

scriptname = 'castpars'; oopt = 'minit'; get_cropt
mdocshow(mfilename, ['reads in .bl file to fir_' mcruise '_' stn_string '.nc']);

% resolve root directories for various file types
root_botraw = mgetdir('M_CTD_BOT');
root_ctd = mgetdir('M_CTD');
scriptname = mfilename; oopt = 'blinfile'; get_cropt
infile = fullfile(root_botraw, infile);
m = ['infile = ' infile]; fprintf(MEXEC_A.Mfidterm,'%s\n','',m)
dataname = ['fir_' mcruise '_' stn_string];
otfile = fullfile(root_ctd, dataname);

cellall = mtextdload(infile,',',10); % load all text
nr = size(cellall,1);

n = 1;
position = NaN; scan = NaN;
for kline = 1:nr
    if ~isempty(cellall{kline,4})
        position(n) = str2num(cellall{kline,2});
        scan(n) = str2num(cellall{kline,4});
        n = n+1;
    end
end

scriptname = mfilename; oopt = 'fixbl'; get_cropt

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
