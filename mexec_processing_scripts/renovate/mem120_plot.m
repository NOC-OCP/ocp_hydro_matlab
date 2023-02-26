% mem120_plot: use mplxyed to edit data
%
% Use: mem120_plot       and then respond with day number, or for day 20
%      day = 20; mem120_plot;
%
% overhaul of this and mem120 on jr281
%
% sequence should be run msim_01 and mem120_01 to do median clean and
% 5 minute averages of each data stream
%
% then msim_02 and mem120_02 to cross-merge the datastreams
% then msim_plot and mem120_plot to edit bad data
%
% YLF edited 12/2015 (jr15003) to set axis limits based on em122 
%  swath_depth rather than simrad depth

scriptname = 'mem120_plot'; 

if exist('day','var')
    m = ['Running script ' scriptname 'for day ' sprintf('%03d',day)];
    fprintf(MEXEC_A.Mfidterm,'%s\n',m)
else
    day = input('type day number ');
end
day_string = sprintf('%03d',day);
daylocal = day;
clear day % so that it doesn't persist

%em120 file should have latest sim data merged on
switch MEXEC_G.MSCRIPT_CRUISE_STRING(1:2) % bak on jr281 march 2013; cook branch couldn't be tested on jr281
    % bak jc191 14 feb 2020: Discovery option doesn't seem to be here. But
    % ylf is out on Disocvery so has probably fixed it there ?
    case {'jc' 'dy'};
        root_em120 = mgetdir('M_EM120');
        prefix1 = ['em120_' MEXEC_G.MSCRIPT_CRUISE_STRING '_'];
    case 'jr'
        root_em120 = mgetdir('M_EM122');
        prefix1 = ['em122_' MEXEC_G.MSCRIPT_CRUISE_STRING '_'];
    otherwise
        msg = ['choose ship bathymetry source and enter new case in mem120_plot.m'];
        fprintf(2,'\n\n%s\n\n\n',msg);
        return
end

infile1 = [root_em120 '/' prefix1 'd' day_string '_edt'];

[de he] = mload(infile1,'/');
de.dn = de.time/86400+datenum(he.data_time_origin);

% bak on jc191. At some stage, the sim variable available was depth_uncor;
% this was to do with says where one of sim and em120 was not available,
% and a flaw in the logic of msim_02, where depth was overwritten with
% swath_depth. Therefore check which sim_depth is available.

kd = find(strncmp('depth',he.fldnam,5)); % finds 'depth' or 'depth_uncor'
if ~isempty(kd)
    sim_depth_str = he.fldnam{kd};
    cmd = ['de.depth_sim = de.' sim_depth_str ';']; eval(cmd);
else
    sim_depth_str = '';
    fprintf(2,'%s\n','No sim depth string recognised in em120_edt file. A sim variable should be present, even if it is all NaN');
    error();
end

% bak on jr281. Rather quick and dirty.
% load nav and calculate SS depths
dn1 = min(de.dn);
dn2 = max(de.dn);

switch MEXEC_G.Mshipdatasystem
    case 'techsas'
        dnav = mtload(MEXEC_G.default_navstream,dn1,dn2);
        navtime = dnav.time + MEXEC_G.uway_torg;
        navtime = navtime(1:300:end); % cull to about 5 minutes
        sslats = dnav.lat(1:300:end);
        sslons = dnav.long(1:300:end);
        ssdeps = sslats+nan;       
    case 'scs'
        dnav = msload(MEXEC_G.default_navstream,dn1,dn2);
        navtime = dnav.time + MEXEC_G.uway_torg;
        navtime = navtime(1:300:end); % cull to about 5 minutes
        sslats = dnav.seatex_gll_lat(1:300:end);
        sslons = dnav.seatex_gll_lon(1:300:end);
        ssdeps = sslats+nan;
    otherwise
        msg = ['choose ship navigation source and enter new case in msim_plot.m'];
        fprintf(2,'\n\n%s\n\n\n',msg);
        return
end

oopt = 'sbathy'; get_cropt %ssdeps
load(bfile); disp(bfile)
if ~exist('sslon') & exist('top'); sslon = top.lon; sslat = top.lat; ssdep = top.altitude; end
[ny,nx] = size(ssdep); ny = min(ny,length(sslat)); nx = min(nx,length(sslon)); %for some reason the n_atlantic file is not the right size but it's only off by 1 point so will fix later***
if mean(sslons)<0 & mean(sslon)>0; sslon = sslon-360; end
ssdeps = -interp2(sslon(1:nx), sslat(1:ny)', ssdep(1:ny,1:nx), sslons, sslats);

% figure; plot(sslons,'k*'); hold on; plot(sslon,'b*'); grid on
clear sslon

% quick plot
figure(101)
clf

% if isfield(de,'depth')
if isfield(de,'depth_sim') % bak jc191 name seems to be depth_uncor
%     plot(de.dn,de.depth,'b+-'); % sim if available
    plot(de.dn,de.depth_sim,'b+-'); % sim if available % bak jc191 name seems to be depth_uncor
else
   de.depth = NaN+de.swath_depth;
end

grid on;
hold on;

plot(navtime,ssdeps,'k'); % SS bathymetry

plot(de.dn,de.swath_depth,'r+-'); %em120 data to edit

set(gca,'YDir','reverse');
datetick('x',13);                      % select date format 'hh:mm:ss' 
% axis(tight)
title(['echo sounder depths on day ',num2str(daylocal)]);
xlabel('time UTC');ylabel('depth (m)');


% now set up mplxyed
bottom = max(de.swath_depth);
top = min(de.swath_depth);

pdf.ncfile.name = infile1;
pdf.time_var='time';
pdf.xlist='time';
pdf.time_scale=3    ;    % minutes after start time
% pdf.ylist='depth swath_depth ';
pdf.ylist= [ sim_depth_str ' swath_depth ']; % bak jc191
pdf.symbols = {'+'};  
pdf.startdc = [daylocal 0 0 0];
pdf.stopdc = [daylocal+1 0 0 0];
pdf.xax = [0 24];
pdf.ntick = [12 10];
pdf.yax = m_autolims([bottom+100 top-100],pdf.ntick(2));
pdf.yax = [pdf.yax; pdf.yax];
pdf.yax = fliplr(pdf.yax);
mplxyed(pdf)


