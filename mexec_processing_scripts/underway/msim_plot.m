% msim_plot: use mplxyed to edit data
%
% Use: msim_plot       and then respond with day number, or for day 20
%      day = 20; msim_plot;
%
% overhaul of this and mem120 on jr281
%
% sequence should be run msim_01 and mem120_01 to do median clean and
% 5 minute averages of each data stream
%
% then msim_02 and mem120_02 to cross-merge the datastreams
% then msim_plot and mem120_plot to edit bad data

scriptname = 'msim_plot'; 
oopt = '';

if exist('day','var')
    m = ['Running script ' scriptname 'for day ' sprintf('%03d',day)];
    fprintf(MEXEC_A.Mfidterm,'%s\n',m)
else
    day = input('type day number ');
end
day_string = sprintf('%03d',day);
daylocal = day;
clear day % so that it doesn't persist

%sim file should have latest em120 data merged on
root_sim = mgetdir('M_SIM');
prefix1 = ['sim_' MEXEC_G.MSCRIPT_CRUISE_STRING '_'];
infile1 = [root_sim '/' prefix1 'd' day_string '_edt'];

[ds hs] = mload(infile1,'/');
ds.dn = ds.time/86400+datenum(hs.data_time_origin);
% bak on jr281. Rather quick and dirty.
% load nav and calculate SS depths
dn1 = min(ds.dn);
dn2 = max(ds.dn);

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
%[ny,nx] = size(ssdep); ny = min(ny,length(sslat)); nx = min(nx,length(sslon)); %for some reason the n_atlantic file is not the right size but it's only off by 1 point so will fix later***
if mean(sslons)<0 & mean(sslon)>0; sslon = sslon-360; end
iix = find(sslon>=min(sslons)-1 & sslon<=max(sslons)+1); iiy = find(sslat>=min(sslats)-1 & sslat<=max(sslats)+1);
ssdeps = -interp2(sslon(iix), sslat(iiy)', ssdep(iiy,iix), sslons, sslats);

% figure; plot(sslons,'k*'); hold on; plot(sslon,'b*'); grid on
clear sslon
% quick plot
figure(101)
clf

if isfield(ds,'swath_depth')
    plot(ds.dn,ds.swath_depth,'b+-'); % em120 if available
else
   ds.swath_depth = NaN+ds.depth;
end

grid on;
hold on;

plot(navtime,ssdeps,'k'); % SS bathymetry

plot(ds.dn,ds.depth,'r+-');

set(gca,'YDir','reverse');
datetick('x',13);                      % select date format 'hh:mm:ss' 
% axis(tight)
title(['echo sounder depths on day ',num2str(daylocal)]);
xlabel('time UTC');ylabel('depth (m)');



% now set up mplxyed
bottom = max(ds.depth);
top = min(ds.depth);

pdf.ncfile.name = infile1;
pdf.time_var='time';
pdf.xlist='time';
pdf.time_scale=3    ;    % minutes after start time
pdf.ylist='swath_depth depth';
pdf.symbols = {'+'};  
pdf.startdc = [daylocal 0 0 0];
pdf.stopdc = [daylocal+1 0 0 0];
pdf.xax = [0 24];
pdf.ntick = [12 10];
pdf.yax = m_autolims([bottom+100 top-100],pdf.ntick(2));
pdf.yax = [pdf.yax; pdf.yax];
pdf.yax = fliplr(pdf.yax);
mplxyed(pdf)

