% mwin_01: read in winch data corresponding to a CTD station
%
% Use: mwin_01        and then respond with station number, or for station 16
%      stn = 16; mwin_01;
% Original version for JC031/032 accesses data via rvs files/datapup/pstar
% Revised version by BAK for di344 Oct 2009
% Further revision by BAK 15 Nov 2009 intended to make it work equally well
% on SCS (JCR) and Techsas (Discovery/Cook) files
%
% Assumes file ctd_cruise_stn_psal.nc exists. Times taken from this file,
% with an extra 600 seconds added at each end
%
% Script includes mcalc and datpik to ensure data are properly monotonic in
% time. Presumably BAK found some files sometime that were not monotonic.
%
% Additional option introduced by bak on jc159 15 April 2018 in opt_jc159 so that
% times can be specified to enable winch data to be read in when there are
% no ctd data, or to override times derived from ctd files. If no cruise and station-specific
% case is provided, times are taken from ctd file as usual.

scriptname = 'castpars'; oopt = 'minit'; get_cropt
if MEXEC_G.quiet<=1; fprintf(1,'adding winch data to win_%s_%s.nc\n',mcruise,stn_string); end

% resolve root directories for various file types
root_win = mgetdir('M_CTD_WIN');
root_ctd = mgetdir('M_CTD');
infile1 = fullfile(root_ctd, ['ctd_' mcruise '_' stn_string '_psal']);
otfile2 = fullfile(root_win, ['win_' mcruise '_' stn_string]);
wkfile3 = fullfile(root_win, ['wk_' scriptname '_' datestr(now,30)]);
dataname = ['win_' mcruise '_' stn_string];


%--------------------------------
% create rvs starts and end times

scriptname = mfilename; oopt = 'winchtime'; get_cropt; 

% bak on jc159 15 april 2018: need to be able to read in some winch data 
% on swivel test stations where there are no ctd files; new cruise opt to set
% winch_time_start and winch_time_end; example in opt_jc159
% this option can also be used to set winch start and end times different
% from ctd times, eg if CTD comms are lost when termination fails.
if exist('winch_time_start','var') && ~isnan(winch_time_start) && ~isnan(winch_time_end)
    t_start = datenum(winch_time_start);
    t_end = datenum(winch_time_end);
else
    h_in=m_read_header(infile1);
    k_time=find(strcmp('time',h_in.fldnam));
    t_start=datenum(h_in.data_time_origin)  + (h_in.alrlim(k_time)+time_window(1))/86400;
    t_end=datenum(h_in.data_time_origin)+(h_in.uprlim(k_time)+time_window(2))/86400;
end

t_start_vec=datevec(t_start);
t_end_vec=datevec(t_end);

daynum_start=t_start-datenum([t_start_vec(1) 1 1 0 0 0]);
daynum_start=1+floor(daynum_start);

daynum_end=t_end-datenum([t_end_vec(1) 1 1 0 0 0]);
daynum_end=1+floor(daynum_end);

switch MEXEC_G.Mship
    case 'sda'
        rvsstreamname = 'winchsda_v3';
    otherwise
        rvsstreamname='winch';
end
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

switch MEXEC_G.Mshipdatasystem
    case 'scs'
    mdatapupscs(yy_start,daystart,timestart,yy_end,dayend,timeend,...
        flags,instream,otfile2,varlist);
    case 'techsas'
     mdatapuptechsas(yy_start,daystart,timestart,yy_end,dayend,timeend,...
        flags,instream,otfile2,varlist);
    case 'rvdas'
        mrrvdas2mstar(instream,t_start_vec,t_end_vec,otfile2,varlist);
end


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
'-1'
};
mheadr;

hdr = m_read_header(otfile2);
noflds = hdr.noflds;
copystring = ['1~' sprintf('%d',noflds)];

MEXEC_A.MARGS_IN = {
otfile2
wkfile3
'/'
'time'
'y = m_flag_monotonic(x1);'
'tflag'
' '
' '
};
mcalc;

MEXEC_A.MARGS_IN = {
wkfile3
otfile2
'2'
'tflag .5 1.5'
' '
copystring
};
mdatpik;

delete(m_add_nc(wkfile3));
