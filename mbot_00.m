% mbot_00 : generate csv file of niskin closing flags, based on SBE .bl file
%
% Use: mbot_00        and then respond with station number, or for station 16
%      stn = 16; mbot_00;
%
% first draft bak on jr281, tidied up on jr302
% use this to generate a csv that describes which niskin bottle was
% in which position, as input to mbot_01 and mbot_02
%
%
% If bottles are swapped around or misfires occur, build the cruise specific table in the
% switch cases in cruise_options/
%
% default is 1:24 in positions 1:24
%
% further revision on jr302: inspect .bl file; default flag is 2 if there
% is a .bl entry; 3 otherwise. Some code adapted from mfir_00

minit; scriptname = mfilename;
mdocshow(scriptname, ['adds default Niskin bottle numbers and flags to bot_' mcruise '_' stn_string '.csv']);

root_botraw = mgetdir('M_CTD_BOT');
root_botcsv = mgetdir('M_CTD_CNV');
    
prefix1 = ['bot_' mcruise '_'];
prefix2 = ['ctd_' mcruise '_'];
infile = [root_botraw '/' prefix2 stn_string '.bl'];
otfile = [root_botcsv '/' prefix1 stn_string '.csv'];

% first read the .bl file.

m = ['infile = ' infile];
fprintf(MEXEC_A.Mfidterm,'%s\n','',m)

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
    end
end

if krow < kmax
    position(krow+1:end) = [];
end
% the 'position' array is now the list of bottles closed.
oopt = 'fixbl'; get_cropt

kpos = 1:24;
sampnum = 100*stnlocal + kpos;
stnarray = stnlocal * ones(24,1);  % default up to here. 24 bottles on each station
flag = 9*ones(24,1); % default flag of 9 meaning not closed
flag(position) = 2; % if bottle closed, default closure flag is 2.

oopt = 'nispos'; get_cropt; %niskin-position mapping information

out = [sampnum(:) stnarray(:) kpos(:) nis(:) flag(:)];

form = '%5d , %2d , %3d , %2d , %2d \n';

fid = fopen(otfile,'w');
fprintf(fid,'%s, %s, %s, %s, %s\n', 'sampnum', 'sta', 'niskin', 'bottle_number', 'bottle_qc_flag');
fprintf(fid,form,out');
fclose(fid);