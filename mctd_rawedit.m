% mctd_rawedit: display raw ctd data to check for spikes
%
% Use: mctd_rawedit        and then respond with station number, or for station 16
%      stn = 16; mctd_rawedit;

scriptname = 'mctd_rawedit';
cruise = MEXEC_G.MSCRIPT_CRUISE_STRING;
oopt = '';

if ~exist('stn','var')
    stn = input('type stn number ');
end
stn_string = sprintf('%03d',stn);
stnlocal = stn; clear stn % so that it doesn't persist

mdocshow(scriptname, ['allows interactive selection of bad data cycles, writes cleaned data to ctd_' cruise '_' stn_string '_raw_cleaned.nc']);

% resolve root directories for various file types
root_ctd = mgetdir('M_CTD');
prefix1 = ['ctd_' cruise '_'];
prefix2 = ['dcs_' cruise '_'];
infile1 = [root_ctd '/' prefix1 stn_string '_raw'];
infile2 = [root_ctd '/' prefix1 stn_string '_raw_original'];
infile3 = [root_ctd '/' prefix1 stn_string '_raw_cleaned'];
infile4 = [root_ctd '/' prefix2 stn_string ]; % dcs file

in1nc = m_add_nc(infile1);
in2nc = m_add_nc(infile2);
in3nc = m_add_nc(infile3);

if exist(in1nc,'file') == 2 & exist(in2nc,'file') ~= 2 & exist(in3nc,'file') ~= 2
    % raw file only, so no cleaning has been done yet; set up copy file
    cmd = ['/bin/mv ' in1nc ' ' in2nc]; unix(cmd);
    cmd = ['/bin/cp -p ' in2nc ' ' in3nc]; unix(cmd);
    cmd = ['chmod 644 ' in3nc]; unix(cmd);
    cmd = ['ln -s ' in3nc ' ' in1nc]; unix(cmd);
elseif exist(in1nc,'file') == 2 & exist(in2nc,'file') == 2 & exist(in3nc,'file') == 2
    % all files exist; cleaning has already been set up
    cmd = ['chmod 644 ' in3nc]; unix(cmd);
else
    mess = ['Unexpected result about which combination of '];
    fprintf(MEXEC_A.Mfider,'%s\n',mess,in1nc,in2nc,in3nc,'exist')
    return
end

% code added by YLF jr16002 to edit bad scans from raw_cleaned file
oopt = 'badscans'; get_cropt

[ddcs hdcs]  = mload(infile4,'/');
dcs_ts = ddcs.time_start(1);
dcs_te = ddcs.time_end(1);
dn_start = datenum(hdcs.data_time_origin)+dcs_ts/86400;
dn_end = datenum(hdcs.data_time_origin)+dcs_te/86400;
startdc = datevec(dn_start);
stopdc = datevec(dn_end);

close all

% 1 hz file, so we can see if any small spikes survive into final data for
% key variables
clear pshow1
pshow1.ncfile.name = infile3;
pshow1.xlist = 'time';
oopt = 'pshow1'; get_cropt
pshow1.startdc = startdc;
pshow1.stopdc = stopdc;
mplxyed(pshow1);

cmd = ['chmod 444 ' in3nc]; unix(cmd);

