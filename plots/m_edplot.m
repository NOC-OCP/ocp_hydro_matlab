function pdfot = m_edplot(pdfin,ncfile)

% This is all the work from mplotxy, but without the
% initialising call to proghd. Also called from mplxyed.
%
% see 'help mplotxy'

% DAS added following to control size of window and change plot size
pfigsize = [4 1 28 19];    %  This is set at the end of this program size in centimetre controls property of gcf
pplotsize = [21 14];       %  This set size of plot within window

m_common
m_margslocal
m_varargs

% MEXEC_A.MARGS_IN_LOCAL
% MEXEC_A.Mprog = 'mplotxy';
% m_proghd;

global x1 x2 r1 r2 c1 c2% needed in mplxyed
ntickdef = [10 10];
pdf = [];
if nargin < 1
    % no argments, create empty pdf
    pdfin = [];
    pdfot = [];
else
    pdfot = pdfin;
end

% if ncfile is input argument, use it;
% override pdfin.ncfile even if present
if nargin >= 2
    pdfin.ncfile = ncfile;
end

% sort out filename
if isfield(pdfin,'ncfile')
    ncfile = m_resolve_filename(pdfin.ncfile);
else
    fprintf(MEXEC_A.Mfidterm,'%s','Enter name of input disc file  ')
    fn_in = m_getfilename;
    ncfile = m_resolve_filename(fn_in);
end

ncfile = m_openin(ncfile); % check we have found a valid mstar file name
pdfot.ncfile = ncfile;

h = m_read_header(pdfot.ncfile);
m_print_header(h);

% sort out colors
if isfield(pdfin,'cols')
    cols = pdfin.cols;
else
    cols = 'krbmcgy';
    pdfin.cols = cols;
    pdfot.cols = cols;
end
% match matlab colors to LaTeX cols
% Use LaTeX colors in strings for y-tick labels because each tick
% label is a single text command, that may contain several tick labels.
col7 = 'krbgmcy';
colstrings7 = {'black' 'red' 'blue' 'green' 'magenta' 'cyan' 'yellow'};
clear colstrings
colstrings(1:length(cols)) = {'black'}; %default color for axis label if input col not recognised
for k = 1:length(cols)
    kc = strfind(col7,cols(k));
    if isempty(kc); continue; end
    colstrings(k) = colstrings7(kc);
end
if isfield(pdfin,'symbols')
    symbols = pdfin.symbols;
else
    symbols = {''};
    pdfin.symbols = symbols;
    pdfot.symbols = symbols;
end
if isfield(pdfin,'styles')
    styles = pdfin.styles;
else
    styles = {'-'};
    pdfin.styles = styles;
    pdfot.styles = styles;
end
if isfield(pdfin,'widths')
    widths = pdfin.widths;
else
    widths = [2];
    pdfin.widths = widths;
    pdfot.widths = widths;
end



% sort out xlist and ylist
if ~isfield(pdfin,'xlist')
    ok = 0;
    while ok == 0
        m = sprintf('%s\n','Type variable name or number of independent (x) variable: ');
        var = m_getinput(m,'s');
        vlist = m_getvlist(var,h);
        if length(vlist) ~= 1
            m = 'Must select one only';
            fprintf(MEXEC_A.Mfider,'%s\n',' ',m,' ');
            continue
        else
            ok = 1;
        end
    end
    pdfot.xlist = h.fldnam{vlist};
end

if ~isfield(pdfin,'ylist')
    ok = 0;
    while ok == 0
        m = sprintf('%s\n','Type variable names or numbers of dependent (y) variables: ');
        var = m_getinput(m,'s');
        vlist = m_getvlist(var,h);
        ok = 1;
    end
    pdfot.ylist = '';
    for k = 1:length(vlist)
        pdfot.ylist = [pdfot.ylist ' ' h.fldnam{vlist(k)}];
    end
    pdfot.ylist = m_remove_outside_spaces(pdfot.ylist);
end


%turn x and y var lists to numbers
xnumlist = m_getvlist(pdfot.xlist,h);
ynumlist = m_getvlist(pdfot.ylist,h);

xnum = xnumlist(1);
xname = h.fldnam{xnum};
% x = nc_varget(ncfile.name,xname);
% x = reshape(x,1,numel(x)); % reshape to row

numy = length(ynumlist);
yname = {}; y = [];
for k =1:numy
    ykname = h.fldnam{ynumlist(k)};
    yname = [yname ; ykname];
%     yk = nc_varget(ncfile.name,ykname);
%     yk = reshape(yk,1,numel(yk)); % reshape to rows
%     y = [y; yk];
end




% start and stop dcs and time options if present
dctime = 1;
startdc = nan;
stopdc = nan;
time_scale = nan;
tv = nan;
if isfield(pdfin,'startdc')
    startdc = pdfin.startdc;
end
if isfield(pdfin,'stopdc')
    stopdc = pdfin.stopdc;
end
if isfield(pdfin,'time_scale')
    time_scale = pdfin.time_scale;
end
if isfield(pdfin,'time_var')
    tv = m_getvlist(pdfin.time_var,h);
end
if isfield(pdfin,'dctime')
    dctime = pdfin.dctime;
end

    

% figure out the availability of a time variable
% if a variable is specified in time_var use that to select data
% next if x is a time variable, use that
% next hunt for a time variable in fldnam and take the first one found

tvarnum = nan;
if ~isnan(tv)
    tvarnum = tv;
elseif m_isvartime(xname)
    tvarnum = xnumlist(1); % x is a time variable
else
    % search for the first time variable in fldnam
    for kv = 1:h.noflds
        if m_isvartime(h.fldnam{kv})
            tvarnum = kv;
            break
        end
    end
end

% if we have found a time variable; read in the time data
if tvarnum > 0
    % get time units
    timename = h.fldnam{tvarnum};
    pdfot.time_var = timename;
    unit = h.fldunt{tvarnum};
    isdays = m_isunitdays(unit);
    issecs = m_isunitsecs(unit);
    %     if unit not recognised, assume it is seconds
    if isdays + issecs == 0
        m = ['time unit ' unit ' not recognised as days or seconds, assumed to be seconds'];
        fprintf(MEXEC_A.Mfider,'\n\n%s\n\n',m)
        issecs = 1;
    end
    time = nc_varget(ncfile.name,timename);
    if issecs == 1
        time = time/86400; % convert seconds to days after data_time_origin
    end
else
    dctime = 0;
end
    

% figure out the start and stop data cycles
if length(startdc) == 1
    % assume these are data cycle numbers; if they're nan default to first
    % and last data cycles
    if isnan(startdc); startdc = 1; end
    x1 = startdc;
    if tvarnum > 0
%         time_start_do = datenum(time(startdc)); % datenum relative to data_time_origin 
%         time_stop_do = datenum(time(stopdc));
        time_start_do = time(startdc); % datenum relative to data_time_origin 
        time_start = time_start_do + datenum(h.data_time_origin); % matlab datenum of startdc
    end
end
if length(stopdc) == 1
    % assume these are data cycle numbers; if they're nan default to first
    % and last data cycles
    if isnan(stopdc); stopdc = h.dimrows(xnum)*h.dimcols(xnum); end
    x2 = stopdc;
    if tvarnum > 0
%         time_start_do = datenum(time(startdc)); % datenum relative to data_time_origin 
%         time_stop_do = datenum(time(stopdc));
        time_stop_do = time(stopdc);
        time_stop = time_stop_do + datenum(h.data_time_origin);
    end
end

if (length(startdc) > 1 | length(stopdc) > 1 ) & isnan(tvarnum)
    m1 = 'Based on the startdc settings you appear to be trying ';
    m2 = 'to use time to select data cycles but no time variable was found, and ';
    m3 = 'you didn''t specify one using pdf.time_var';
    m = sprintf('%s\n',m1,m2,m3);
    error(m)
end

if length(startdc) > 1
    if length(startdc) == 4
        % specified as day of year and hh mm ss
        % the mapping from day number to time depends on leap years or not
        % assume the year is the year of the first data cycle in the time
        % variable
        t0 = datevec(datenum(h.data_time_origin) + time(1));
        y0 = t0(1);
        time_start = (startdc(1)-1) + datenum([y0 1 1 startdc(2:4)]); % matlab datenum of 'startdc'
    elseif length(startdc) == 6
        time_start = datenum(startdc); % matlab datenum of 'startdc'
    else
        m = 'Time format for startdc not recognised as having 1,4, or 6 elements';
        fprintf(MEXEC_A.Mfider,'%s\n',m);
        error(' ');
    end

    time_start_do = time_start - datenum(h.data_time_origin); % datenum relative to data_time_origin
    x1 = min(find(time >= time_start_do));
end

if length(stopdc) > 1
    if length(stopdc) == 4
        % specified as day of year and hh mm ss
        % the mapping from day number to time depends on leap years or not
        % assume the year is the year of the first data cycle in the time
        % variable
        t0 = datevec(datenum(h.data_time_origin) + time(1));
        y0 = t0(1);
        time_stop = (stopdc(1)-1) + datenum([y0 1 1 stopdc(2:4)]);
    elseif length(stopdc) == 6
        time_stop = datenum(stopdc);
    else
        m = 'Time format for stopdc not recognised as having 1,4, or 6 elements';
        fprintf(MEXEC_A.Mfider,'%s\n',m);
        error(' ');
    end

    time_stop_do = time_stop - datenum(h.data_time_origin);
    x2 = max(find(time <= time_stop_do));
end

% now load precisely the data required to plot
[r1 c1] = m_index_to_rowcol(x1,h,xnum);
[r2 c2] = m_index_to_rowcol(x2,h,xnum);

if h.dimcols(xnum) > 1
    if r1 ~= 1 | r2 ~= h.dimrows(xnum)
        m = 'The start and stop data cycles must be defined in such a way that';
        m2 = 'startdc is in row 1 of the x variable and stopdc is in the last row of the x variable';
        fprintf(MEXEC_A.Mfider,'%s\n',m,m2);
        error(' ')
    end
end

x = nc_varget(ncfile.name,xname,[r1-1 c1-1],[r2-r1+1,c2-c1+1]); %start at r1-1 because nc_varget is zero-based counting
x = reshape(x,1,numel(x)); % reshape to row

yname = {}; y = [];
for k =1:numy
    ykname = h.fldnam{ynumlist(k)};
    yname = [yname ; ykname];
    yk = nc_varget(ncfile.name,ykname,[r1-1 c1-1],[r2-r1+1,c2-c1+1]);
    yk = reshape(yk,1,numel(yk)); % reshape to rows
    y = [y; yk];
end


% sort out data and units for xlabel
xscale = 1;
if isnan(tvarnum)
    time_scale = 0;
else
    if tvarnum ~= xnum % time may have been used to select data but is not used in plotting
        time_scale = 0;
    else
        unit = h.fldunt{xnum};
        isdays = m_isunitdays(unit);
        issecs = m_isunitsecs(unit);
        %     if unit not recognised, assume it is seconds
        if isdays + issecs == 0
            m = ['time unit ' unit ' not recognised as days or seconds, assumed to be seconds'];
            fprintf(MEXEC_A.Mfider,'\n\n%s\n\n',m)
            issecs = 1;
        end
        xraw = x;
        if issecs == 1; x = x/86400; xscale = 1/86400; end % convert to days relative to data_time_origin

        if isnan(time_scale)
            time_scale = 2; % default: minutes after start time
            pdfot.time_scale = time_scale;
        end
    end
end


switch time_scale
    % recall that 
    % x contains the data in days after the data_time_origin; 
    % time_start_do is the time of the start time in days after the data_time_origin
    % case 0 is when x is not a time variable
    % In other cases x is a time variable and we control the scaling of x
    case 0
        xunits = h.fldunt{xnum};
        if tvarnum == xnum; x = xraw; end
    case 1
        xunits = 'seconds after start time';
        x = 86400*(x-time_start_do);
    case 2
        xunits = 'minutes after start time';
        x = 1440*(x-time_start_do);
    case 3
        xunits = 'hours after start time';
        x = 24*(x-time_start_do);
    case 4
        xunits = 'days after start time';
        x = 1*(x-time_start_do);
    case 9
        t0 = datevec(time_start);
        y0 = t0(1);
        xunits = ['day of year in ' sprintf('%04d',y0)];
        x = 1 + x + datenum(h.data_time_origin) - datenum([y0 1 1 0 0 0]);
    otherwise
        xunits = 'UNITS NOT SET';
end
global fstruct
if exist('time_scale','var'); fstruct.time_scale = time_scale; end
if exist('time_start_do','var')fstruct.time_start_do = time_start_do; end
if exist('time_start','var')fstruct.time_start = time_start; end
if exist('xscale','var')fstruct.xscale = xscale; end

% % % % fiddle by sga to get a sort of overxy
% % % % before first plot set pdfin.hold
% % % % pass this pdf into the second and subsequent plots
% % % 
% % % if isfield(pdfin,'fighandle')
% % %   figure(pdfin.fighandle);
% % %   hold on
% % % else
% % %   m_figure
% % %   if isfield(pdfin,'hold')
% % %     pdfot.fighandle = gcf;
% % %   end
% % % end

% Version of overxy on JC032, exploiting SGA's idea from JC031
if isfield(pdfin,'axeshandle') & isfield(pdfin,'over')
    if pdfin.over ~= 1
        pdfot.over = 0;
    else
        pdfin.newfigure = 'none';
        pdfot.axeshandle = pdfin.axeshandle;
        pdfot.over = 1;
    end
else
    pdfot.over = 0;
end
over = pdfot.over;
 
% Addition by BAK on JC032; adapted from mcontr to allow many plots on one
% page, controlled by pdfin.newfigure
if isfield(pdfin,'newfigure')
    newfigure = pdfin.newfigure;
else
    newfigure = 'landscape'; % new figure type 'landscape' 'portrait' or 'none'
end
pdfot.newfigure = newfigure;

% % % paperh = 29.6774; % A4 papersize
% % % paperw = 20.984;
% % % paperm = 0.25*2.54; % margin 0.635 cm = 0.25 inch
% Note on orientation, example using papertype usletter, 11 inches by 8.5:
% orient landscape: paperposition gives plot area 10.5 wide 8 high
% orient portrait:, the paper is now upright, but the plot area is still
% 'horizontal', ie 8 wide, 6 high
%
% so you need orient tall, to get a plot area 8 wide and 10.5 high.
%
if strncmp(newfigure,'l',1)
    m_figure
    set(gcf,'PaperType','a4');
    orient landscape
%     set(gcf,'PaperUnits','centimeters')
%     set(gcf,'PaperSize',[paperh paperw])
%     set(gcf,'PaperType','a4')
%     set(gcf,'PaperPosition',[paperm paperm paperh-2*paperm paperw-2*paperm])
elseif strncmp(newfigure,'p',1)
    m_figure
    set(gcf,'PaperType','a4');
%     orient portrait
    orient tall
%     set(gcf,'PaperUnits','centimeters')
%     set(gcf,'PaperSize',[paperw paperh])
%     set(gcf,'PaperType','a4');
%     set(gcf,'PaperPosition',[paperm paperm paperw-2*paperm paperh-2*paperm])
else
    newfigure = 'none';
    hold on
     % no new figure; allows new plots in same figure
end
    
% sort out axes & ticks
if isfield(pdfin,'xax')
    xax = pdfin.xax;
    if isfield(pdfin,'ntick')
        nxt = pdfin.ntick(1);
    else
        nxt = ntickdef(1);
    end
else
    % use a simple plot to detect limits and ticks for x
    plot(x,y(1,:));
    h0 = gca;
    xax = get(h0,'xlim');
    xt = get(h0,'xtick');
    nxt = length(xt)-1;
    clf;
    %     xax = m_autolims(x,nxt);
end
pdfot.xax = xax;
pdfot.ntick(1) = nxt;

% nyt is always defined by pdfin or default
if isfield(pdfin,'ntick')
        nyt = pdfin.ntick(2);
    else
        nyt = ntickdef(2);
end
if isfield(pdfin,'yax')
    yax = pdfin.yax;
else
    for k = 1:numy
        yax(k,1:2) = m_autolims(y(k,:),nyt);
    end
end
pdfot.yax = yax;
pdfot.ntick(2) = nyt;

% normalise x and y data onto [0 1] This will allow decreasing as well as
% increasing limits to be specified in pdf

% calculate tick values
xr = xax(2)-xax(1); % xrange
yr = yax(:,2)-yax(:,1); % y ranges
xti = xr/nxt; % x tick interval
yti = yr/nyt; % ytick interval for first y variable
xt = xax(1):xti:xax(2); % x tick values
xtraw = xt; %save for later; position of ticks will be normalised.
yt = yax(1,1):yti(1):yax(1,2); % y tick values, for first variable
ytall = nan+zeros(numy,nyt+1);
for k = 1:numy
    ytall(k,:) = yax(k,1):yti(k):yax(k,2); % tick values for all y variables
end

xnorm = (x-xax(1))/xr;
ynorm = nan+y; 
for k = 1:numy
    ynorm(k,:) = (y(k,:) - yax(k,1))./yr(k); % normalised y data in range 0 to 1; corresponds to axis min to axis max
end
xt = (xt-xax(1))/xr; %normalised ticks
yt = (yt-yax(1,1))/yr(1); % normalised ticks

% Set up up the parameters that control the plot layout
ox = 4; %axis origin in cm from bottom left of page
oy = 3; %axis origin in cm from bottom left of page
t1 = 0.3; % separation in cm between tick annotations and plot area
th = 0.8; % height allowed for text
tw = 2.0; % width allowed for text
yw = 4; % width alowed for y variable names 3 and above
%fs0 = 14; % default font size
fs0 = 18; % default font size D%
if isfield(pdfin,'plotorg')
    plotorg = pdfin.plotorg;
else
    plotorg = [4 3]; % default plot size
end
pdfot.plotorg = plotorg;
ox = plotorg(1); %axis origin in cm from bottom left of page
oy = plotorg(2); %axis origin in cm from bottom left of page

if isfield(pdfin,'plotsize')
    plotsize = pdfin.plotsize;
else
    plotsize = [18 12]; % default plot size
    plotsize = pplotsize; % Added by DAS set at 
end
pdfot.plotsize = plotsize;
pw = plotsize(1);
ph = plotsize(2);
posaxes = [ox oy plotsize];
fscale = min([plotsize(1)/max(16,plotsize(1)) plotsize(2)/max(12,plotsize(2)) 1]); %scaling of fonts if plot falls below a certain size
allscale = min([plotsize(1)/max(12,plotsize(1)) plotsize(2)/max(10,plotsize(2)) 1]); %scaling of distances if plot falls below a certain size
fontsize = max(4,floor(fs0*fscale));
t1 = t1*allscale;
th = th*allscale;
tw = tw*allscale;
yw = yw*allscale;

% plot the data, compiling the y ticklabels as we go
clear ytlabel ytstr
global hplot
for kv = 1:numy
    colindex = mod(kv,length(cols));
    if colindex == 0; colindex = length(cols); end
    symindex = mod(kv,length(symbols));
    if symindex == 0; symindex = length(symbols); end
    styleindex = mod(kv,length(styles));
    if styleindex == 0; styleindex = length(styles); end
    widthindex = mod(kv,length(widths));
    if widthindex == 0; widthindex = length(widths); end
    lines{kv} = [cols(colindex) symbols{symindex} styles{styleindex}];

    % construct y tick labels
    % remove trailing 0 or decimal point
    for k = 1:length(yt)
        str = sprintf('%10.3f',ytall(kv,k));
        while strcmp(str(end),'0') == 1
            str(end) = [];
        end
        if strcmp(str(end),'.') == 1; str(end) = []; end
        while strcmp(str(1),' ') == 1
            str(1) = [];
        end

        latex_str = ['\color{' colstrings{colindex} '}'];
        str = [latex_str str];
        ytstr{kv,k} = str;
    end

    if kv == 1; 
        if over == 0
            % open plot of required size
            ha = axes('position',[0 0 .01 .01]);
            set(ha,'units','centimeters');
            posnew = [plotorg plotsize];
            set(ha,'position',posnew);
        else
            ha = pdfin.axeshandle;
        end
        pdfot.axeshandle = ha;
        
        % plot first data

        hplot(kv) = plot(ha,xnorm,ynorm(1,:),lines{1},'linewidth',widths(1));
%         ha = gca; % removed on JC032; now set elsewhere
%         set(ha,'position',[.1 .15 .7 .7]);
        axis([0 1 0 1]);
        set(ha,'xtick',xt);
        set(ha,'ytick',yt);
        % switch off xtick labels
        for k = 1:length(xt)
            empty{k} = '';
        end
        set(ha,'xticklabel',empty);
        % switch off ytick labels
        for k = 1:length(yt)
            empty{k} = '';
        end
        set(ha,'yticklabel',empty);
        hold on; grid on;
        
%         set(gca,'units','centimeters'); % removed on JC032; now set elsewhere
        set(gcf,'defaultaxesfontsize',fontsize)
        set(gcf,'defaulttextfontsize',fontsize)

%         posnew = [posaxes]; % removed on JC032; now set elsewhere
%         set(gca,'position',posnew);
    else
        hplot(kv) = plot(ha,xnorm,ynorm(kv,:),lines{kv},'linewidth',widths(widthindex));
    end
end

if over == 1; return; end % no labels or heading for overplot vars

for k = 1:length(yt)
    %     ytlabel{k} = ytstr(1:2,k);
    ytlabel{k} = ytstr(:,k);
end

xposall = [-t1 pw+t1:tw:2*pw]; % first yticks at left; next set at right and then further right thereafter
for k = 1:length(yt)
    xpos2 = xposall;
    xpos = xpos2(1);
%     xpos_data = xax(1) + xr * xpos;
    ytl = ytlabel{k};
    while length(ytl) > 0

        % ngroup = 3
        ngroup = 2; % number of y variable annotations to display before moving to a new column
        n = min(ngroup,length(ytl));
        ytuse = ytl(1:n);

        ht = text(xpos,yt(k),ytuse);
        set(ht,'units','centimeters')
        pp = get(ht,'position');
        pp(1) = xpos;
        set(ht,'position',pp)
        if xpos < 0.5; set(ht,'HorizontalAlignment','right'); end
        if xpos > 0.5; set(ht,'HorizontalAlignment','left'); end

        xpos2(1) = [];
        xpos = xpos2(1);
        ytl(1:n) = [];
    end
end

% x tick labels
for k = 1:length(xt);
    str = sprintf('%10.3f',xtraw(k));
    while strcmp(str(end),'0') == 1; str(end) = []; end
    while strcmp(str(end),'.') == 1; str(end) = []; end
    while strcmp(str(1),' ') == 1; str(1) = []; end
    ht = text(xt(k),0,str);
    set(ht,'units','centimeters')
    pp = get(ht,'position');
    pp(2) = -t1;
    set(ht,'position',pp)
    set(ht,'HorizontalAlignment','center')
    set(ht,'VerticalAlignment','top')
end

if isfield(pdfin,'fighandle'); return; end

%Plot the title
% hh = ylabel('number'); set(hh,'interpreter','none');
plot_title = [h.dataname '  <vers>  ' sprintf('%s  ',h.mstar_site) sprintf('%4d ',h.version) ];
hh = text(.5,1,plot_title); set(hh,'interpreter','none');
set(hh,'units','centimeters')
set(hh,'position',[pw/2,ph+t1]);
set(hh,'HorizontalAlignment','center')
set(hh,'VerticalAlignment','bottom')
pdfot.handle_title_1 = hh; % save to pdfot so that title can be reset after end of plotting

%File name
plot_filename = ['File name:  ' ncfile.name];
hh = text(.5,1,plot_filename); set(hh,'interpreter','none');
set(hh,'units','centimeters')
set(hh,'position',[pw/2,ph+t1+th]);
set(hh,'HorizontalAlignment','center')
set(hh,'VerticalAlignment','bottom')
pdfot.handle_title_2 = hh; % save to pdfot so that title can be reset after end of plotting


% % % %Date string
% % % str = datestr(now,31);
% % % dateposx = 0;
% % % dateposy = 1.02;
% % % hh = text(dateposx,dateposy,str); %position normalised on xax and yax scales
% % % set(hh,'units','centimeters')
% % % set(hh,'position',[-0.9*ox,ph+th]);
% % % set(hh,'HorizontalAlignment','left')
% % % set(hh,'VerticalAlignment','bottom')
% % % set(hh,'fontsize',max(4,fontsize-4));

% % % %Prog string
% % % str = MEXEC_A.Mprog;
% % % progposx = 0;
% % % progposy = 1.1;
% % % hh = text(progposx,progposy,str); %position normalised on xax and yax scales
% % % set(hh,'units','centimeters')
% % % set(hh,'position',[-0.9*ox,ph+th+th]);
% % % set(hh,'HorizontalAlignment','left')
% % % set(hh,'VerticalAlignment','bottom')
% % % set(hh,'fontsize',max(4,fontsize-4));

%Prog & date string combined and rotated
str = [MEXEC_A.Mprog '  ' datestr(now,31)];
progposx = 0;
progposy = 1.1;
hh = text(progposx,progposy,str); %position normalised on xax and yax scales
set(hh,'units','centimeters')
set(hh,'position',[-0.9*ox,ph+t1+th]);
if plotorg(1) > 10; set(hh,'position',[-3,ph+t1+th]); end
set(hh,'HorizontalAlignment','right')
set(hh,'VerticalAlignment','top')
set(hh,'Rotation',90);
set(hh,'fontsize',max(4,fontsize-4));


%Start and stop strings
if dctime > 0
    pdfot.dctime = 1;
    % this is a time
    v1 = datevec(time_start);
    doy1 = 1 + floor(time_start - datenum([v1(1) 1 1 0 0 0]));
    v2 = datevec(time_stop);
    doy2 = 1 + floor(time_stop - datenum([v1(1) 1 1 0 0 0]));
    
    strstart = ['Start  ' sprintf('%04d%02d%02d %s %3d) %02d%02d%02d',v1(1:3),'(daynum',doy1,floor(v1(4:6)))];
    strstart = [strstart sprintf('%s%d',' dc ',x1)];
    strstop =  ['Stop  ' sprintf('%04d%02d%02d %s %3d) %02d%02d%02d',v2(1:3),'(daynum',doy2,floor(v2(4:6)))];
    strstop =  [strstop sprintf('%s%d',' dc ',x2)];
else
    pdfot.dctime = 0;
    strstart = ['Start ' sprintf('%s%d',' dc ',x1)];
    strstop = ['Stop ' sprintf('%s%d',' dc ',x2)];
end

startposx = -0.12;
startposy = -0.06;
hh = text(startposx,startposy,strstart); %position normalised on xax and yax scales
set(hh,'units','centimeters')
set(hh,'position',[-0.9*ox,-t1-th]);
if plotorg(1) > 10; set(hh,'position',[-3,-t1-th]); end
set(hh,'HorizontalAlignment','left')
set(hh,'VerticalAlignment','top')
set(hh,'fontsize',max(4,fontsize-2));


stopposx = -0.12;
stopposy = -0.12;
hh = text(stopposx,stopposy,strstop); %position normalised on xax and yax scales
set(hh,'units','centimeters')
set(hh,'position',[-0.9*ox,-t1-th-th]);
if plotorg(1) > 10; set(hh,'position',[-3,-t1-th-th]); end
set(hh,'HorizontalAlignment','left')
set(hh,'VerticalAlignment','top')
set(hh,'fontsize',max(4,fontsize-2));

% x label
strx = xname;
strxu = ['(' m_remove_outside_spaces(xunits) ')'];
xlabx = .5;
xlaby = -0.06;
xlabxu = .5;
xlabyu = -0.12;
hh = text(xlabx,xlaby,strx); %position normalised on xax and yax scales
set(hh,'units','centimeters')
set(hh,'position',[pw/2,-t1-th]);
set(hh,'HorizontalAlignment','center')
set(hh,'VerticalAlignment','top')
set(hh,'interpreter','none');
hh = text(xlabxu,xlabyu,strxu); %position normalised on xax and yax scales
set(hh,'units','centimeters')
set(hh,'position',[pw/2,-t1-th-th]);
set(hh,'HorizontalAlignment','center')
set(hh,'VerticalAlignment','top')
set(hh,'interpreter','none');


% strings for y variables
clear ystr;
ystrx = 0.7*pw:yw:2*pw;
ystry = -t1-th:-th:-10;

nshift = 2; % shift column of y labels to right every 2 labels
xshift = repmat(ystrx,nshift,1); xshift = reshape(xshift,1,numel(xshift));
yshift = repmat(ystry(1:nshift)',1,length(ystrx)); yshift = reshape(yshift,1,numel(yshift));

xshift = [-t1-tw -t1-tw xshift]; % put first two ylabels at left of axis; remainder below axis
yshift = [ph ph/2 yshift];

for kv = 1:numy
    colindex = mod(kv,length(cols));
    if colindex == 0; colindex = length(cols); end
%     latex_str = ['\color{' colstrings{colindex} '}'];
    str = [yname{kv} ' (' m_remove_outside_spaces(h.fldunt{ynumlist(kv)}) ')'];
%     str = [latex_str str];
    ystr{kv} = str;
    hh = text(xshift(kv),yshift(kv),ystr{kv});
    if kv < 3
        set(hh,'units','centimeters')
        set(hh,'position',[xshift(kv) yshift(kv)]);
        set(hh,'HorizontalAlignment','right')
        set(hh,'VerticalAlignment','bottom')
        set(hh,'rotation',90)
        set(hh,'interpreter','none');
        set(hh,'color',cols(colindex));
    else
        set(hh,'units','centimeters')
        set(hh,'position',[xshift(kv) yshift(kv)]);
        set(hh,'HorizontalAlignment','left')
        set(hh,'VerticalAlignment','top')
        set(hh,'fontsize',max(4,fontsize-2));
        set(hh,'interpreter','none');
        set(hh,'color',cols(colindex));
    end
end

% % set(gca,'units','centimeters');
% % posaxes = get(gca,'position');
% % if isfield(pdfin,'plotsize')
% %     plotsize = pdfin.plotsize;
% % else
% %     plotsize = [18 12];
% % end
% % pdfot.plotsize = plotsize;
% % posnew = [posaxes(1) posaxes(2) plotsize(1) plotsize(2)];
% % set(gca,'position',posnew);

% need to review all labelling;
% consider the detailed location and scaling; use mm instead of scaled values;
% need xtick labels

% DAS added this to get suitable size window on screen
set(gcf,'units','centimeters');
set(gcf,'position',pfigsize);

return


% % % % % % xax = pdf.xax;
% % % % % % yax = pdf.yax;
% % % % % ntdef = 0; % record whether number of ticks was default
% % % % % if isfield(pdf,'ntick')
% % % % %     ntick = pdf.ntick;
% % % % % else
% % % % %     ntick = [10 10];
% % % % %     ntdef = 1; % note that the number of ticks comes form default
% % % % %     pdf.ntick = ntick;
% % % % % end
% % % % % 

% % % % % nxt = ntick(1);
% % % % % nyt = ntick(2);
% % % % % 
% % % % % 
% % % % % %read header
% % % % % % h = m_read_header(ncfile);
% % % % % % m_print_header(h);
% % % % % 
% % % % % %turn x and y var lists to numbers
% % % % % xnumlist = m_getvlist(pdf.xlist,h);
% % % % % ynumlist = m_getvlist(pdf.ylist,h);
% % % % % 
% % % % % xnum = xnumlist(1);
% % % % % xname = h.fldnam{xnum};
% % % % % % x = nc_varget(ncfile.name,xname);
% % % % % % x = reshape(x,1,numel(x)); % reshape to row
% % % % % 
% % % % % numy = length(ynumlist);
% % % % % yname = {}; y = [];
% % % % % for k =1:numy
% % % % %     ykname = h.fldnam{ynumlist(k)};
% % % % %     yname = [yname ; ykname];
% % % % % %     yk = nc_varget(ncfile.name,ykname);
% % % % % %     yk = reshape(yk,1,numel(yk)); % reshape to rows
% % % % % %     y = [y; yk];
% % % % % end
% % % % % 



