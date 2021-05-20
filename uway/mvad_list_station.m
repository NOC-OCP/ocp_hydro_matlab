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
% if desired, set station number and inst before use, eg
% stn = 4; inst = 'os150nb'; mvad_list_station;
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

if exist('inst','var')
    m = ['Running script ' scriptname ' for VMADCP ' sprintf('%d',inst)];
    fprintf(MEXEC_A.Mfidterm,'%s\n',m)
else
    inst = input('Enter instrument type: os75nb or os150nb etc.: ','s');
end
instlocal = inst; clear inst; % so it doesn't persist


root_nav = mgetdir('M_POS');  
fn_nav = fullfile(root_nav, ['bst_' mcruise '_01.nc']);
[dnav hnav] = mloadq(fn_nav,'/');
dnav.dnum = datenum(hnav.data_time_origin)+dnav.time/86400;
dnav.chead =  exp(i*(90-dnav.heading_av_corrected)*degrad);

root_ctd = mgetdir('M_CTD');  
fn_dcs = fullfile(root_ctd, ['dcs_' mcruise '_' stn_string '.nc']);
[ddcs hdcs] = mloadq(fn_dcs,'/');
ddcs.dnum_start = datenum(hdcs.data_time_origin)+ddcs.time_start/86400;
ddcs.dnum_end = datenum(hdcs.data_time_origin)+ddcs.time_end/86400;

root_vmad = mgetdir('M_VMADCP');
fn_vad = fullfile(root_vmad, 'mproc', [instlocal '_' mcruise '_01.nc']);
[dvad hvad] = mloadq(fn_vad,'/');
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


times_explanation = {'t1 = t2 - tbuffer (eg 1 hour)'
't2 arrive on station less than spdmin (eg 1 m/s = 2 knots)'
't3 CTD start'
't4 CTD end'
't5 leave station more than spdmin'
't6 = t5 + tbuffer'};

tform = 'yyyy mm dd HH MM SS';

% start and end times

times(3) = ddcs.dnum_start;
knav3 = min(find(dvad.refdnum >= times(3)));
knav2 = max(find(dvad.refdnum <= times(3) & dvad.refshipspd >= spdmin))+1;
if isempty(knav2); knav2 = 1; end % start at beginning of file
times(2) = dvad.refdnum(knav2);
knav1 = max(find(dvad.refdnum <= times(2)-tbuffer));
if isempty(knav1); knav1 = 1; end % start at beginning of file
times(1) = dvad.refdnum(knav1);

times(4) = ddcs.dnum_end;
knav4 = max(find(dvad.refdnum <= times(4)));
knav5 = min(find(dvad.refdnum >= times(4) & dvad.refshipspd >= spdmin))-1;
if isempty(knav5); knav5 = length(dvad.refdnum); end
times(5) = dvad.refdnum(knav5);
knav6 = min(find(dvad.refdnum >= times(5)+tbuffer));
if isempty(knav6); knav6 = length(dvad.refdnum); end
times(6) = dvad.refdnum(knav6);

fprintf(1,'\n');
for no = 1:length(times_explanation)
fprintf(1,'%s   %s\n',datestr(times(no),tform),times_explanation{no});
end
fprintf(1,'\n');
fprintf(1,'%s %03d [%s] [%s]\n','wait',stnlocal,datestr(times(1),tform),datestr(times(6),tform));
fprintf(1,'%s %03d [%s] [%s]\n','wait',stnlocal,datestr(times(2),tform),datestr(times(5),tform));


fprintf(1,'%s %s %s %s %s\n',' yyyy mm dd HH MM SS ',' speed',' head','  uabs','  vabs')

if 0
for kl = knav1:knav6
    if kl == knav2; fprintf(1,'%s\n','speed limit'); end
    if kl == knav3; fprintf(1,'%s %03d %s\n','CTD',stnlocal,'start'); end
    fprintf(1,'%s%s%s %6.2f %5.0f %6.2f %6.2f\n','[',datestr(dvad.refdnum(kl),tform),']',dvad.refshipspd(kl),dvad.shiphead(kl),dvad.refuabs(kl),dvad.refvabs(kl));
    if kl == knav4; fprintf(1,'%s %03d %s\n','CTD',stnlocal,'end'); end
    if kl == knav5; fprintf(1,'%s\n','speed limit'); end
end
end