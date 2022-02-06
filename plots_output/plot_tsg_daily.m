close all;
%==========================================================================
% Script to look at daily data from the underway and compare w/CTD streams
%
% User inputs the day and the stations
% This script plots Loads T and S in window 1 and fluor in window 2
% Also to add: the upper 250 meters of T, S oxy and fluorescence (and 
% turbidity and transmisttence) – set this up in MEXEC – set of parameters 
% using one set f scales. Add on the same picture annotation of bottle 
% stops/depths. Multiple pictures on one  (5 traces of T, S, oxy, fluor) 
%
% Save each day to a new filename and setup in output folder.
%==========================================================================

scriptname = 'plot_tsg_daily'; 
% get day to be plotted from user
if exist('day','var')
    m = ['Running script ' scriptname 'for day ' sprintf('%03d',day)];
    fprintf(MEXEC_A.Mfidterm,'%s\n',m)
else
    day = input('type day number ');
end
day_string = sprintf('%03d',day);
daylocal = day;
clear day % so that it doesn't persist
mcruise = MEXEC_G.MSCRIPT_CRUISE_STRING;
mdocshow(scriptname, sprintf('plots tsg data for day %d, add more info here', daylocal));


%% LOAD DATA
% get data from ocl (or met/surfmet?!?!?) directory
switch MEXEC_G.Mship
    case 'cook'
        abbrev = 'met_tsg';
    case 'jcr'
        abbrev = 'oceanlogger';
end
roottsg = mgetdir(abbrev);

infile1 = [roottsg '/' abbrev '_' mcruise '_01_medav_clean_cal']; %***check variable names in this one
if ~exist(infile1, 'file')
   infile1 = [roottsg '/' abbrev '_' mcruise '_01_medav_clean'];
end
[d h] = mload(infile1,'/');

switch MEXEC_G.Mship
   case 'jcr'
      d.salin = d.salinity;
      d.cond = d.conductivity;
      d.temp_h = d.tstemp; % bak on jr302 tstemp is housing; sampletemp is fluorometer
      d.temp_m = d.sstemp;
      d.flowrate = d.flowrate;
   case 'cook'
      d.salin = d.psal;
end

%% EXTRACT DATA FOR CHOSEN TIME PERIOD

d.dn = d.time/86400+datenum(h.data_time_origin);

dn1 = min(d.dn);
dn2 = max(d.dn);

day_start = daylocal + datenum([2018 0 0 0 0 0]);
day_end = daylocal + datenum([2018 0 0 0 0 0]) + 1;

%% PLOT
% Part 1: Do a daily plot of T&S in window and fluorescence in another 
% Part 2: the upper 250 meters of T, S oxy and fluorescence (and turbidity and 
% transmisttence) – set this up in MEXEC – set of parameters using one set 
% of scales. Add on the same picture annotation of bottle stops/depths. 
% Multiple pictures on one  (5 traces of T, S, oxy, fluorescence) – mplotxy

clear stn_str_all

bottom = max(d.temp_m);
top = min(d.temp_m);
%==========================================================================
% Part 1: TSG T, S and fluor
figure(101); clf
scrsz = get(0,'ScreenSize');
set(gcf,'Position',[1 0.1*scrsz(4) 0.4*scrsz(3) 0.8*scrsz(4)])
pl = .1; pb = .1; pw = .8; ph = .13;

h = subplot('position',[pl pb+5*ph pw 1.5*ph]) %'position',[left bottom width height]
plot(d.dn,d.temp_m,'k+-',d.dn,d.temp_h,'r+-')
hold on ;grid on
xlim([day_start day_end])
ha(1) = gca;
ylabel('temp');
%legend('temp_m','temp_h','location','best','orientation','horizontal')
legend('intake','housing','location','best','orientation','horizontal')
datetick('x',13,'keeplimits'); xlabel('time UTC'); % select date format 'hh:mm:ss' 
title(['TSG streams on day ',num2str(daylocal)]);

subplot('position',[pl pb+3*ph pw 1.5*ph])
plot(d.dn,d.psal,'k+-');
hold on ;grid on
xlim([day_start day_end])
ha(2) = gca;
ylabel('psal')
datetick('x',13,'keeplimits'); xlabel('time UTC');

subplot('position',[pl pb+1*ph pw 1.5*ph])
plot(d.dn,d.fluo,'g+-');
hold on ;grid on
xlim([day_start day_end])
ha(3) = gca;
ylabel('fluor')
datetick('x',13,'keeplimits'); xlabel('time UTC');

% Set up mplotxy
clear pdf
pdf.ncfile.name = infile1;
pdf.xlist='time';
pdf.time_scale=3    ;    % minutes after start time
% pdf.ylist='fluo temp_m temp_h cond trans deltat psal ';
pdf.ylist='temp_m temp_h cond fluo';
pdf.symbols = {'+'};  
pdf.startdc = [daylocal 0 0 0];
pdf.stopdc = [daylocal+1 0 0 0];
pdf.xax = [0 24];
pdf.ntick = [12 10];
mplotxy(pdf)

%==========================================================================
% Part 2: Surface (250 m) of CTD traces using mtplotxy

% resolve root directories for various file types
root_ctd = mgetdir('M_CTD');
prefix0 = ['sam_' mcruise '_'];
prefix1 = ['ctd_' mcruise '_'];
prefix2 = ['dcs_' mcruise '_'];
prefix4 = ['fir_' mcruise '_'];

% load sam_jc159_all.nc to figure out station numbers corresponding to user
% jday provided
infile0 = [root_ctd '/' prefix0 'all'];
[d0 h0] = mload(infile0,'/');
d0_time = datenum(h0.data_time_origin)+(d0.time)/86400;

nn = find(d0_time >= day_start & d0_time <= day_end);
new_time = d0.time(nn);
stns = unique(d0.statnum(nn));

var_all = [];
for k = 1:length(stns)

    stn = stns(k);
    stn_string = sprintf('%03d',stn);
    stn_str_all{k} = stn_string;
    stnlocal = stn; clear stn % so that it doesn't persist
    
    infile1 = [root_ctd '/' prefix1 stn_string '_2db']; %ctd_jc159_nnn_2db.nc
    infile2 = [root_ctd '/' prefix2 stn_string];
    infile3 = [root_ctd '/' prefix1 stn_string '_psal'];
    infile4 = [root_ctd '/' prefix4 stn_string '_ctd'];
    
    hraw = m_read_header(infile1);
    [ddcs hdcs]  = mload(infile2,'/');
    dcs_ts = ddcs.time_start(1);
    dcs_te = ddcs.time_end(1);
    dn_start = datenum(hdcs.data_time_origin)+dcs_ts/86400;
    dn_end = datenum(hdcs.data_time_origin)+dcs_te/86400;
    startdc = datevec(dn_start);
    stopdc = datevec(dn_end);
    
    % store CTD stream surface values for figure(101)
    [dd hd] = mload(infile1,'/');
    press_check = dd.press(1);
    if press_check > 10; disp(['surface pressure, ', press_check,'too deep']); break; end
    time = dd.time(1)/86400+datenum(hd.data_time_origin);
    var1 = [time,dd.temp1(1),dd.psal1(1),dd.fluor(1)];
    var_all = [var_all; var1];
    
    clear pshow1
    pshow1.newfigure = 'p';
    pshow1.plotsize = [18 8];
    pshow1.plotorg = [3 8];
    pshow1.over = 0;
    pshow1.ncfile.name = infile1;
    pshow1.xlist = 'press';
    pshow1.ylist = 'temp1 temp2 cond1 cond2 oxygen fluor';
    pshow1.startdc = startdc;
    pshow1.stopdc = stopdc;
    pshow1.xax = [0 250];
    mplotxy(pshow1);

%%%%%%%%%%%%%%%%% add bottle depths %%%%%%%%%%%%%%%%%%%%%%%%%%%
    pshow1.newfigure = 'none';
    pshow1.plotsize = [18 4];
    pshow1.plotorg = [3 1];
    pshow1.over = 0;  %overplot next file in same panel; keep same axes handle
    pshow1.xlist = 'upress';
    pshow1.ylist = 'udepth';
    pshow1.cols = 'k';
    pshow1.symbols = {'o'};
    pshow1.yax = [0 250];
    pshow1.yax = fliplr(pshow1.yax);
    pshow1.xax = [0 250];
    pshow1.ncfile.name = infile4;
    mplotxy(pshow1)

end

%%%% plot CTD surface stream values on TSG plot
figure(101)
plot(ha(1),var_all(:,1),var_all(:,2),'co','markerfacecolor','m','markersize',8); hold on
text(var_all(:,1),var_all(:,2)-0.01,stn_str_all)
text(var_all(1,1),25,'yellow')

plot(ha(2),var_all(:,1),var_all(:,3),'co','markerfacecolor','m','markersize',8); hold on
text(var_all(:,1),var_all(:,3)-0.01,stn_str_all)

plot(ha(3),var_all(:,1),var_all(:,4),'co','markerfacecolor','m','markersize',8); hold on
text(var_all(:,1),var_all(:,4)+0.01,stn_str_all)

return

% clear pshow2
% pshow2.ncfile.name = infile1;
% pshow2.xlist = 'fluor'; %data stream:
% pshow2.ylist = 'press';
% pshow2.startdc = startdc;
% pshow2.stopdc = stopdc;
% % pdf.symbols = {'+'};  
% % pdf.startdc = [daylocal 0 0 0];
% % pdf.stopdc = [daylocal+1 0 0 0];
% % pdf.xax = [0 24];
% % pdf.ntick = [12 10];
% % pdf.yax = m_autolims([bottom top],pdf.ntick(2));
% % pdf.yax = [pdf.yax; pdf.yax];
% pshow2.yax = [0 250];
% pshow2.yax = fliplr(pshow2.yax);
% mplotxy(pshow2);


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



%% SAVE FIGURES
% Setup to save daily figures to a new filename in designated output folder.












