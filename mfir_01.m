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
blinfile = fullfile(root_botraw, blinfile);
m = ['infile = ' blinfile]; fprintf(MEXEC_A.Mfidterm,'%s\n','',m)
dataname = ['fir_' mcruise '_' stn_string];
otfile = fullfile(root_ctd, dataname);

cellall = mtextdload(blinfile,',',10); % load all text
nr = size(cellall,1);

n = 1;
pos = NaN; scn = NaN;
for kline = 1:nr
    if ~isempty(cellall{kline,4})
        pos(n) = str2num(cellall{kline,2});
        scn(n) = str2num(cellall{kline,4});
        n = n+1;
    end
end
pos = pos(:);
scn = scn(:);

scriptname = 'castpars'; oopt = 'nnisk'; get_cropt
scriptname = mfilename; oopt = 'nispos'; get_cropt
niskc = niskc(:);
niskin = niskn(:);
[~,ia,ib] = intersect(pos,niskc);
position = niskc;
scan = NaN+niskc;
scan(ib) = scn(ia);
niskin_flag = 9+zeros(nnisk,1); %default flag 9 means not closed
niskin_flag(ib) = 2; %if bottle closed, defaults to 2
scriptname = mfilename; oopt = 'botflags'; get_cropt %change flags here

%--------------------------------
comment = ['input data from ' blinfile];
timestring = ['[' sprintf('%d %d %d %d %d %d',MEXEC_G.MDEFAULT_DATA_TIME_ORIGIN) ']'];
MEXEC_A.MARGS_IN = {
    otfile
    'scan'
    'position'
    'niskin'
    'niskin_flag'
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
    'niskin'
    '/'
    'number'
    'niskin_flag'
    '/'
    'woce table 4.8'
    '-1'
    '-1'
    };
msave
%--------------------------------
