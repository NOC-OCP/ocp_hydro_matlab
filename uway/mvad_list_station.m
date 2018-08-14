% script mvad_list_station
%
% bak 2 April 2018; jc159
% 
% list some vmadcp and nav data around a station to 
% help identify times when the ship was 'on station', which may be a longer
% time than just when the CTD was in the water.
%
% Read in CTD in water time from dcs file.
% Then read in VMADCP data, which contains ship speed and absolute water
% speed
% Also read in ship heading from bestnav file
%
% List data cycles out, so you can identify the cycles where the ship speed
% is small and the heading is stable
% Format of times can easily be pasted into mvad_03_jc159_times.txt, for
% use in mvad_03.
%
% heading is interpolated onto ADCP timebase using complex arithmetic to carry direction.
%
% 
% i = sqrt(-1);
% pi = 4*atan(1);
% degrad = pi/180;
% chead = exp(i*(90-head)*degrad); % heading (0 = north) to complex number of magnitude 1
% head = real(90-log(chead/abs(chead))/i/degrad); % direction defined by complex number to heading (0 = north)
%
% if desired, set station number and os before use, eg
% stn = 4; os = 150; mvad_list_station;
%
% This version has a hardwired set of reference levels which are averaged
% to display the ADCP absolute velocity: 
% levsvad = 3:6;
%
% Ad a hardwired speed limit used to identify when the ship was coming onto
% or leaving station: 
% spdmin = 1; % m/s
% Also, data are listed for tbuffer days before and after the speed limit
% is reached:
% tbuffer = 3600/86400; % days


%reset constants, just in case
i = sqrt(-1);
pi = 4*atan(1);
degrad = pi/180;
mcruise = MEXEC_G.MSCRIPT_CRUISE_STRING;
scriptname = 'mvad_list_station';

spdmin = 1; % m/s
levsvad = 3:6; % levels for reducing adcp velocity for display
tbuffer = 3600/86400; % days


if exist('stn','var')
    m = ['Running script ' scriptname ' on station ' sprintf('%03d',stn)];
    fprintf(MEXEC_A.Mfidterm,'%s\n',m)
else
    stn = input('type stn number ');
end
stnlocal = stn; clear stn; % so it doesnt persist
stn_string = sprintf('%03d',stnlocal);

if exist('os','var')
    m = ['Running script ' scriptname ' for OS ' sprintf('%d',os)];
    fprintf(MEXEC_A.Mfidterm,'%s\n',m)
else
    os = input('Enter OS type: 75 or 150: ');
end
oslocal = os; clear os; % so it doesnt persist

inst = ['os' sprintf('%d',oslocal)];


root_nav = mgetdir('M_POS');  
fn_nav = [root_nav '/bst_' mcruise '_01.nc'];
[dnav hnav] = mload(fn_nav,'/');
dnav.dnum = datenum(hnav.data_time_origin)+dnav.time/86400;
dnav.chead =  exp(i*(90-dnav.heading_av_corrected)*degrad);

root_ctd = mgetdir('M_CTD');  
fn_dcs = [root_ctd '/dcs_' mcruise '_all.nc'];
[ddcs hdcs] = mload(fn_dcs,'/');
ddcs.dnum_start = datenum(hdcs.data_time_origin)+ddcs.time_start/86400;
ddcs.dnum_end = datenum(hdcs.data_time_origin)+ddcs.time_end/86400;

root_vmad = mgetdir('M_VMADCP');
fn_vad = [root_vmad '/mproc/' inst '_' mcruise '_01.nc'];
[dvad hvad] = mload(fn_vad,'/');
dvad.dnum = datenum(hvad.data_time_origin)+dvad.time/86400;

levsvad = 3:6;

dvad.dirn = 90-angle(dvad.uabs+i*dvad.vabs)/degrad;
dvad.dirn = mcrange(dvad.dirn,0,360);
dvad.shipdirn = 90-angle(dvad.uship+i*dvad.vship)/degrad;
dvad.shipdirn = mcrange(dvad.shipdirn,0,360);

dvad.refdnum = dvad.dnum(levsvad(1),:);
dvad.refuabs = nanmean(dvad.uabs(levsvad,:),1);
dvad.refvabs = nanmean(dvad.vabs(levsvad,:),1);
dvad.refspeed = nanmean(dvad.speed(levsvad,:),1);
dvad.refdirn = dvad.dirn(levsvad(1),:); % don't nanmean drection
dvad.refshipspd = nanmean(dvad.shipspd(levsvad,:),1);
dvad.refshipdirn = dvad.shipdirn(levsvad(1),:); % don't nanmean drection
dvad.shipchead = interp1(dnav.dnum,dnav.chead,dvad.refdnum);
dvad.shiphead = mcrange(real(90-log(dvad.shipchead./abs(dvad.shipchead))/i/degrad),0,360);


kdcs = find(ddcs.statnum == stnlocal);

% t1 = t2 - tbuffer (eg 1 hour)
% t2 arrive on station less than spdmin (eg 1 m/s = 2 knots)
% t3 CTD start
% t4 CTD end
% t5 leave station more than spdmin
% t6 = t5 + tbuffer

tform = 'yyyy mm dd HH MM SS';

% start and end times

t3 = ddcs.dnum_start(kdcs);
knav3 = min(find(dvad.refdnum >= t3));
knav2 = max(find(dvad.refdnum <= t3 & dvad.refshipspd >= spdmin))+1;
if isempty(knav2); knav2 = 1; end % start at beginning of file
t2 = dvad.refdnum(knav2);
knav1 = max(find(dvad.refdnum <= t2-tbuffer));
if isempty(knav1); knav1 = 1; end % start at beginning of file
t1 = dvad.refdnum(knav1);

t4 = ddcs.dnum_end(kdcs);
knav4 = max(find(dvad.refdnum <= t4));
knav5 = min(find(dvad.refdnum >= t4 & dvad.refshipspd >= spdmin))-1;
if isempty(knav5); knav5 = length(dvad.refdnum); end
t5 = dvad.refdnum(knav5);
knav6 = min(find(dvad.refdnum >= t5+tbuffer));
if isempty(knav6); knav6 = length(dvad.refdnum); end
t6 = dvad.refdnum(knav6);

fprintf(1,'\n');
fprintf(1,'%s\n',datestr(t1,tform),datestr(t2,tform),datestr(t3,tform),datestr(t4,tform),datestr(t5,tform),datestr(t6,tform))
fprintf(1,'\n');

fprintf(1,'%s %s %s %s %s\n',' yyyy mm dd HH MM SS ',' speed',' head','  uabs','  vabs')

for kl = knav1:knav6
    if kl == knav2; fprintf(1,'%s\n','speed limit'); end
    if kl == knav3; fprintf(1,'%s %03d %s\n','CTD',stnlocal,'start'); end
    fprintf(1,'%s%s%s %6.2f %5.0f %6.2f %6.2f\n','[',datestr(dvad.refdnum(kl),tform),']',dvad.refshipspd(kl),dvad.shiphead(kl),dvad.refuabs(kl),dvad.refvabs(kl));
    if kl == knav4; fprintf(1,'%s %03d %s\n','CTD',stnlocal,'end'); end
    if kl == knav5; fprintf(1,'%s\n','speed limit'); end
end