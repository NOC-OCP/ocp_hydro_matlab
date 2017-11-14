% mwin_01: read in winch data corresponding to a CTD station
%
% Use: mwin_01        and then respond with station number, or for station 16
%      stn = 16; mwin_01;
% Original version for JC031/032 accesses data via rvs files/datapup/pstar
% Revised version by BAK for di344 Oct 2009
% Further revision by BAK 15 Nov 2009 intended to make it work equally well
% on SCS (JCR) and Techsas (Discovery/Cook) files
%
% Assumes file ctd_cruise_stn_1hz.nc exists. Times taken form this file,
% with an extra 600 seconds added at each end
%
% Script includes mcalc and datpik to ensure data are properly monotonic in
% time. Presumably BAK found some files sometime that were not monotonic.

scriptname = 'mwin_01';
cruise = MEXEC_G.MSCRIPT_CRUISE_STRING;
oopt = '';

if ~exist('stn','var')
    stn = input('type stn number ');
end
stn_string = sprintf('%03d',stn);
stnlocal = stn; clear stn % so that it doesn't persist

mdocshow(scriptname, ['adds winch data to win_' cruise '_' stn_string '.nc']);

% resolve root directories for various file types
root_win = mgetdir('M_CTD_WIN');
root_ctd = mgetdir('M_CTD');
infile1 = [root_ctd '/ctd_' cruise '_' stn_string '_1hz'];
otfile2 = [root_win '/win_' cruise '_' stn_string];
otfile3 = [root_win '/' 'wk_' scriptname '_' datestr(now,30)];
dataname = ['win_' cruise '_' stn_string];


%--------------------------------
% create rvs starts and end times

get_cropt; %time_window

h_in=m_read_header(infile1);
k_time=find(strcmp('time',h_in.fldnam));
t_start=datenum(h_in.data_time_origin)  + ( h_in.alrlim(k_time)+time_window(1))/86400;
t_end=datenum(h_in.data_time_origin)+(h_in.uprlim(k_time)+time_window(2))/86400;

t_start_vec=datevec(t_start);
t_end_vec=datevec(t_end);

daynum_start=t_start-datenum([t_start_vec(1) 1 1 0 0 0]);
daynum_start=1+floor(daynum_start);

daynum_end=t_end-datenum([t_end_vec(1) 1 1 0 0 0]);
daynum_end=1+floor(daynum_end);

rvsstreamname='winch';
datapupflags='';
yy_start =t_start_vec(1)-2000;
yy_end = t_end_vec(1)-2000;
timestart = t_start_vec(4)*10000+t_start_vec(5)*100;
timeend = t_end_vec(4)*10000+t_end_vec(5)*100;
daystart = daynum_start;
dayend = daynum_end;

instream = rvsstreamname; % this should be set in m_setup and picked up from a global var so that it doesn't have to be edited for each cruise/ship
flags = datapupflags;
varlist = '-';

if strncmp(MEXEC_G.Mshipdatasystem,'scs',3)
    mdatapupscs(yy_start,daystart,timestart,yy_end,dayend,timeend,...
        flags,instream,otfile2,varlist);
else % techsas
     mdatapuptechsas(yy_start,daystart,timestart,yy_end,dayend,timeend,...
        flags,instream,otfile2,varlist);
end


%--------------------------------
% 2009-01-29 08:10:09
% mheadr
% input files
% Filename /Users/bak/data/jr193/ctd/gps_jr193_d020_raw.nc   Data Name :  gps_nmea <version> 1 <site> pexec_
% output files
% Filename /Users/bak/data/jr193/ctd/gps_jr193_d020_raw.nc   Data Name :  gps_jr193_d020 <version> 1 <site> bak_macbook
MEXEC_A.MARGS_IN = {
otfile2
'y'
'1'
dataname
'/'
'2'
MEXEC_G.PLATFORM_TYPE
MEXEC_G.PLATFORM_IDENTIFIER
MEXEC_G.PLATFORM_NUMBER
'/'
% % % '4'
% % % torgstring
% % % '/'
'-1'
};
mheadr
%--------------------------------

hdr = m_read_header(otfile2);
noflds = hdr.noflds;
copystring = ['1~' sprintf('%d',noflds)];

%--------------------------------
% 2009-10-13 10:36:32
% mcalc
% input files
% Filename gyr_di344_d103_raw.nc   Data Name :  gyr_di344_d103 <version> 1 <site> di344_atsea
% output files
% Filename gyr_di344_d103_mon.nc   Data Name :  gyr_di344_d103 <version> 2 <site> di344_atsea
MEXEC_A.MARGS_IN = {
otfile2
otfile3
'/'
'time'
'y = m_flag_monotonic(x1);'
'tflag'
' '
' '
};
mcalc
%--------------------------------

%--------------------------------
% 2009-10-13 10:38:35
% mdatpik
% input files
% Filename gyr_di344_d103_mon.nc   Data Name :  gyr_di344_d103 <version> 2 <site> di344_atsea
% output files
% Filename gyr_di344_d103_mon2.nc   Data Name :  gyr_di344_d103 <version> 3 <site> di344_atsea
MEXEC_A.MARGS_IN = {
otfile3
otfile2
'2'
'tflag .5 1.5'
' '
copystring
};
mdatpik
%--------------------------------

unix(['/bin/rm ' otfile3 '.nc']);

