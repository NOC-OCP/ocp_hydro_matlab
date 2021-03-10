% mbathy_plot: use mplxyed to edit data
%
% Use: mbathy_plot       and then respond with day number, or for day 20
%      day = 20; mbathy_plot;
%

if exist('day','var')
    m = ['Running script ' mfilename ' for day ' sprintf('%03d',day)];
    fprintf(MEXEC_A.Mfidterm,'%s\n',m)
else
    day = input('type day number ');
end
day_string = sprintf('%03d',day);
daylocal = day;
clear day % so that it doesn't persist
mcruise = MEXEC_G.MSCRIPT_CRUISE_STRING;

%find files
[udirs, udcruise] = m_udirs;
simvar = mvarname_find({'ea600' 'sim'},udirs(:,1));
if length(simvar)>0
    iss = 1;
end
emvar = mvarname_find({'em120' 'em122'},udirs(:,1));
if length(emvar)>0
    ism = 1;
end
if iss
    filesb = [mgetdir(simvar) '/' simvar '_' mcruise '_d' day_string '_edt_av.nc'];
    if ~exist(filesb, 'file')
        iss = 0;
    end
end
if ism
    filemb = [mgetdir(emvar) '/' emvar '_' mcruise '_d' day_string '_edt_av.nc'];
    if ~exist(filemb, 'file')
        ism = 0;
    end
end

if ~iss & ~ism
    disp(['no bathymetry to edit on day ' num2str(daylocal)])
    return
end

%get gridded bathy interpolated to track
dn1 = datenum(MEXEC_G.MDEFAULT_DATA_TIME_ORIGIN(1),1,1)+daylocal-1;
dn2 = dn1+1;
switch MEXEC_G.Mshipdatasystem
    case 'rvdas'
        dnav = mrload(MEXEC_G.default_navstream,dn1,dn2);
    case 'techsas'
        dnav = mtload(MEXEC_G.default_navstream,dn1,dn2);
    case 'scs'
        dnav = msload(MEXEC_G.default_navstream,dn1,dn2);
    otherwise
        msg = ['choose ship navigation source and enter new case in msim_plot.m'];
        fprintf(2,'\n\n%s\n\n\n',msg);
        return
end
if ~isfield(dnav,'dnum'); dnav.dnum = dnav.time + MEXEC_G.uway_torg; end

% it's broken at this point and needs fixing
% dnav.time won't exist after mrload.




dt = 300; 
% dnav.time = dnav.time(1:dt:end); %about 5 minutes % bak dnav.time not
% needed
latvar = mvarname_find({'lat' 'latitude' 'seatex_gll_lat'},fieldnames(dnav));
lonvar = mvarname_find({'lon' 'long' 'longitude' 'seatex_gll_lon'},fieldnames(dnav));

scriptname = 'bathy'; oopt = 'bathy_grid'; get_cropt
if mean(dnav.(lonvar))<0 & mean(top.lon)>0; top.lon = top.lon-360; end
iix = find(top.lon>=min(dnav.(lonvar))-1 & top.lon<=max(dnav.(lonvar))+1); iiy = find(top.lat>=min(dnav.(latvar))-1 & top.lat<=max(dnav.(latvar))+1);
ssdeps = -interp2(top.lon(iix), top.lat(iiy)', top.depth(iiy,iix), dnav.(lonvar)(1:dt:end), dnav.(latvar)(1:dt:end));

%load and plot each file

files = {}; dvar1 = {}; dvar2 = {};
if iss
    files = [files; filesb];
    dvar1 = [dvar1; 'depth'];
    dvar2 = [dvar2; 'swath_depth'];
end
if ism
    files = [files; filemb];
    dvar1 = [dvar1; 'swath_depth'];
    dvar2 = [dvar2; 'depth'];
end

for fno = 1:length(files)
    
    [db, hb] = mloadq(files{fno},'/');
    db.dn = db.time/86400+datenum(hb.data_time_origin);
    
    % quick plot
    figure(101); clf
    
    plot(dnav.dnum(1:dt:end),ssdeps,'k'); % gridded bathymetry
    grid on; hold on;
    
    if isfield(db,dvar2{fno})
        plot(db.dn,db.(dvar2{fno}),'b+-'); % other bathy stream
        plot2ndbathy = 1;
    else
        plot2ndbathy = 0;
    end
        
    plot(db.dn,db.(dvar1{fno}),'r+-'); %main bathy for this file
    
    set(gca,'YDir','reverse');
    datetick('x',13);                      % select date format 'hh:mm:ss'
    title(['echo sounder depths on day ',num2str(daylocal)]);
    xlabel('time UTC');ylabel('depth (m)');
        
    % now set up mplxyed
    bottom = max(db.depth);
    top = min(db.depth);
    
    pdf.ncfile.name = files{fno};
    pdf.time_var='time';
    pdf.xlist='time';
    pdf.time_scale=3    ;    % minutes after start time
    pdf.symbols = {'+'};
    pdf.startdc = [daylocal 0 0 0];
    pdf.stopdc = [daylocal+1 0 0 0];
    pdf.xax = [0 24];
    pdf.ntick = [12 10];
    pdf.yax = m_autolims([bottom+100 top-100],pdf.ntick(2));
    if plot2ndbathy == 1
        pdf.ylist=sprintf('%s %s',dvar2{fno},dvar1{fno});
        pdf.yax = [pdf.yax; pdf.yax];
        pdf.varednum = 2;
    else
        pdf.ylist = dvar1{fno};
        pdf.varednum = 1;
    end
    pdf.yax = fliplr(pdf.yax);
    mplxyed(pdf)
    
end

%re-merge edited data
if iss & ism
    filesbot = filesb;
    filembot = filemb;
    mbathy_merge
end

%put into to _01 file again
if iss
    mday_02(simvar, daynumber);
end
if ism
    mday_02(emvar, daynumber);
end

