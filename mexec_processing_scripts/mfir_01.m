function mfir_01(stn)
% mfir_01: read in .bl file and create fir file
%
% Use: mfir_01        and then respond with station number, or for station 16
%      stn = 16; mfir_01;

m_common
opt1 = 'castpars'; opt2 = 'minit'; get_cropt

% input file names
root_botraw = mgetdir('M_CTD_BOT');
root_ctd = mgetdir('M_CTD');
blinfile = fullfile(root_botraw,sprintf('%s_%03d.bl', upper(mcruise), stn));
if ~exist(blinfile,'file')
    blinfile = fullfile(root_botraw, sprintf('%s_%03d.bl', mcruise, stn));
end
opt1 = 'ctd_proc'; opt2 = 'blfilename'; get_cropt
if ~exist(blinfile,'file')
    fprintf(2,'.bl file for cast %03d not found; try sync again and enter to continue\n',stn);
    pause
    if ~exist(blinfile,'file')
        warning('no .bl file %s; skipping',blinfile)
        return
    end
end
if MEXEC_G.quiet<=1; fprintf(1,'reading in .bl file to fir_%s_%s.nc\n',mcruise,stn_string); end
dataname = ['fir_' mcruise '_' stn_string];
blotfile = fullfile(root_ctd, dataname);

cellall = mtextdload(blinfile,',',10); % load all text
if size(cellall,2)<4
    warning('no bottles for cast %s; skipping',stn_string)
    return
end
nr = size(cellall,1);

n = 1;
pos = NaN; scn = NaN;
for kline = 1:nr
    if ~isempty(cellall{kline,4})
        pos(n) = str2double(cellall{kline,2});
        scn(n) = str2double(cellall{kline,4});
        n = n+1;
    end
end
pos = pos(:);
scn = scn(:);

niskin_number = [1:24]'; niskin_pos = [1:24]';
opt1 = mfilename; opt2 = 'niskins'; get_cropt
niskin_number = niskin_number(:);
niskin_pos = niskin_pos(:);
[~,ia,ib] = intersect(pos,niskin_pos);
position = niskin_pos;
scan = NaN+position;
scan(ib) = scn(ia);
niskin_flag = 9+zeros(size(scan)); %default flag 9 means not closed
niskin_flag(ib) = 2; %if bottle closed, defaults to 2
m = isfinite(scan);
scan = scan(m); 
position = position(m); 
niskin = niskin_number(m); 
niskin_flag = niskin_flag(m);
clear m ia ib
opt1 = mfilename; opt2 = 'botflags'; get_cropt %change flags here
%check that possible bad code in opt file hasn't added dimensions
if size(niskin)==size(niskin_flag)
else
    error('niskin and niskin_flag sizes do not match; check opt_%s',mcruise)
end

%--------------------------------
comment = ['input data from ' blinfile];
timestring = ['[' sprintf('%d %d %d %d %d %d',MEXEC_G.MDEFAULT_DATA_TIME_ORIGIN) ']'];
MEXEC_A.MARGS_IN = {
    blotfile
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
