% mctd_rawshow: display raw ctd data to check for spikes 
%
% Use: mctd_rawshow        and then respond with station number, or for station 16
%      stn = 16; mctd_rawshow;

scriptname = 'mctd_rawshow';
cruise = MEXEC_G.MSCRIPT_CRUISE_STRING;
oopt = '';

if ~exist('stn','var')
    stn = input('type stn number ');
end
stn_string = sprintf('%03d',stn);
stnlocal = stn; clear stn % so that it doesn't persist

mdocshow(scriptname, ['plots 24 hz and 1 hz CTD data for station ' stn_string]);

% resolve root directories for various file types
root_ctd = mgetdir('M_CTD');
prefix1 = ['ctd_' cruise '_'];
prefix2 = ['dcs_' cruise '_'];
infile1 = [root_ctd '/' prefix1 stn_string '_raw'];
infile2 = [root_ctd '/' prefix2 stn_string ];
infile3 = [root_ctd '/' prefix1 stn_string '_psal'];

hraw = m_read_header(infile1);
[ddcs hdcs]  = mload(infile2,'/');
dcs_ts = ddcs.time_start(1);
dcs_te = ddcs.time_end(1);
dn_start = datenum(hdcs.data_time_origin)+dcs_ts/86400;
dn_end = datenum(hdcs.data_time_origin)+dcs_te/86400;
startdc = datevec(dn_start);
stopdc = datevec(dn_end);

close all

% 1 hz file, so we can see if any small spikes survive into final data for
% key variables
clear pshow5
pshow5.ncfile.name = infile3;
pshow5.xlist = 'time';
oopt = 'pshow5'; get_cropt
pshow5.startdc = startdc;
pshow5.stopdc = stopdc;
mplotxy(pshow5);

% raw data main variables
clear pshow1
pshow1.ncfile.name = infile1;
pshow1.xlist = 'time';
pshow1.ylist = 'temp1 temp2 cond1 cond2 press';
pshow1.startdc = startdc;
pshow1.stopdc = stopdc;
mplotxy(pshow1);

% raw data oxygen
clear pshow2
pshow2.ncfile.name = infile1;
pshow2.xlist = 'time';
oopt = 'pshow2'; get_cropt
pshow2.startdc = startdc;
pshow2.stopdc = stopdc;
pshow2.cols = 'kgrbmcy'; % so raw oxygen in this plot matches 1 hz trace in figure 1.
mplotxy(pshow2)

%raw data fluor trans
clear pshow3
pshow3.ncfile.name = infile1;
pshow3.xlist = 'time';
ylist = {'press' 'turbidity' 'fluor' 'transmittance' 'par'};
pshow3.startdc = startdc;
pshow3.stopdc = stopdc;
% remove any vars from show list that aren't available in the input file
numcopy = length(ylist);
for kloop_scr = numcopy:-1:1
    if isempty(strmatch(ylist(kloop_scr),hraw.fldnam,'exact'))
        ylist(kloop_scr) = [];
    end
end
pshow3.ylist = ' ';
for kloop_scr = 1:length(ylist)
    pshow3.ylist = [pshow3.ylist ylist{kloop_scr} ' '];
end
pshow3.ylist(1) = [];
pshow3.ylist(end) = [];

mplotxy(pshow3);

%raw data lat and lon, carried after jc069 for ladcp processing
oopt = 'pshow4'; get_cropt
if ~isempty(pshow4); mplotxy(pshow4); end


