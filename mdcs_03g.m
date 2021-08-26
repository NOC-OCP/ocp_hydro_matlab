% mdcs_03: find scan number corresponding to start and end of file
%          use this to populate the file dcs_[cruise]_[station]
%
% Use: mdcs_03        and then respond with station number, or for station 16
%      stn = 16; mdcs_03;
% jc069: graphical version by bak
% jc159 ylf added circle for bottom scan/pressure
% jc159 3 April2018 bak add option to identify bottom pressure scan if you
% don't like the one it has chosen


scriptname = 'castpars'; oopt = 'minit'; get_cropt
mdocshow(mfilename, ['interactively select start and end of cast, written to dcs_' mcruise '_' stn_string '.nc']);

root_ctd = mgetdir('M_CTD'); % change working directory

infile1 = fullfile(root_ctd, ['ctd_' mcruise '_' stn_string '_psal']);
infile0 = fullfile(root_ctd, ['ctd_' mcruise '_' stn_string '_24hz']);
otfile = fullfile(root_ctd, ['dcs_' mcruise '_' stn_string]);

% pik data near surface for inspection
hinctd = m_read_header(infile1);
vnames = hinctd.fldnam;
vnum = strmatch('press',vnames,'exact');
if isempty (vnum)
    m = 'press not found';
    error(m)
end

[d h] = mloadq(infile1,'/');
d24 = mloadq(infile0, 'scan', 'time', 'press', ' ');

%%%%%%%%%%%%%%%%%%%%%%%%%%% start graphical part

figure(102)
clf

scrsz = get(0,'ScreenSize');
set(gcf,'Position',[1 0.1*scrsz(4) 0.4*scrsz(3) 0.8*scrsz(4)])


np = 5;

pl = .1;
pb = .1;
pw = .8;
ph = .13;

%start here
scan_start = 1;
h = m_read_header(otfile);
if sum(strcmp('scan_start',h.fldnam))
    d0 = mloadq(otfile,'scan_start',' ');
    if d0.scan_start>1
        scan_start = d0.scan_start;
    end
end
scan_bot = nan; kbot = nan;
db = mloadq(otfile, 'scan_bot', 'press_bot', ' ');
scan_end = max(d.scan);
if sum(strcmp('scan_end',h.fldnam))
    d0 = mloadq(otfile,'scan_end',' ');
    if d0.scan_end<max(d.scan)
        scan_end = d0.scan_end;
    end
end

kfirst = 1;
plims = [-300 10];

while 1
    if kfirst == 0
        mess = ['use zoom/pan from figure toolbar, then choose : \n'];
        mess = [mess 'p   : plot all\n'];
        mess = [mess 'z   : zoom all panels to current x lims\n'];
        mess = [mess 'x   : change all panel x lims to range supplied next\n'];
        mess = [mess 'q   : quit without saving new values\n'];
        mess = [mess 'w   : save values and proceed\n'];
        mess = [mess 'ss  : select start scan\n'];
        mess = [mess 'sb  : select bottom scan\n'];
        mess = [mess 'se  : select end scan\n'];
        mess = [mess 'pp  : plot present selection\n'];
        mess = [mess '  :  '];
        a = input(mess,'s');
    else
        a = 'p';
        kfirst = 0;
    end
    switch a
        case 'p'
            clear ha
            clf
            
            subplot('position',[pl pb+4*ph pw 2*ph])
            if isfield(d, 'pumps'); ii = find(d.pumps<1); else; ii = []; end %overplotting red if pumps not on. bak and ylf jr306, jan2015.
            plot(d.scan,-d.press,'k+-',d.scan(ii),-d.press(ii),'r+');
            hold on ;grid on
            plot(db.scan_bot,-db.press_bot,'co','markersize',10,'markerfacecolor','c');
            ha(1) = gca;
            if isfield(d, 'pumps'); ylabel('press (red if pumps off)'); else; ylabel('-press'); end
            %             set(gca,'ylim',plims);
            ht = get(ha(1),'title'); %handle for title
            set(ht,'string',infile1);
            set(ht,'interpreter','none');
            
            subplot('position',[pl pb+3*ph pw ph])
            plot(d.scan,d.cond1,'k+-');
            hold on ;grid on
            plot(d.scan,d.cond2,'r+-');
            ha(2) = gca; set(ha(2),'YAxisLocation','right');
            ylabel('cond');
            
            subplot('position',[pl pb+2*ph pw ph])
            plot(d.scan,d.psal1,'k+-');
            hold on ;grid on
            plot(d.scan,d.psal2,'r+-');
            ha(3) = gca;
            ylabel('psal')
            
            subplot('position',[pl pb+ph pw ph])
            plot(d.scan,d.temp1,'k+-');
            hold on; grid on
            plot(d.scan,d.temp2,'r+-');
            ha(4) = gca; set(ha(4),'YAxisLocation','right');
            ylabel('temp')
            
            subplot('position',[pl pb pw ph])
            if isfield(d,'oxygen2'); plot(d.scan,d.oxygen1,'k+-',d.scan,d.oxygen2,'r+-');
            else; plot(d.scan,d.oxygen1,'k+-'); end
            hold on; grid on
            ha(5) = gca;
            ylabel('oxygen')
            
        case 'z'
            xl = get(gca,'xlim');
            for kp = 1:5
                set(ha(kp),'xlim',xl);
            end
            
        case 'x'
            xl = []; 
            xl(1) = input('type x-axis lower limit   ');
            xl(2) = input('type x-axis upper limit   ');
            for kp = 1:5
                set(ha(kp),'xlim',xl);
            end
            
        case 'ss'
            % select downcast start scan
            disp('select start scan on any panel');
            [x y] = ginput(1);
            scan_start = ceil(x)
            
        case 'sb'
            disp('select bottom scan on any panel');
            % select bottom scan
            [x y] = ginput(1);
            scan_bot = round(x)
            
        case 'se'
            % select upcast end scan
            disp('select end scan on any panel');
            disp('you may want to select based on T and C, and add oxy_end in cruise');
            disp('options file so that mctd_04 will truncate O when it goes bad (earlier)');
            [x y] = ginput(1);
            scan_end = floor(x)
        case 'pp'
            kok = find(d.scan > scan_start & d.scan < scan_end);
            clear ha
            clf
            
            subplot('position',[pl pb+4*ph pw 2*ph])
            if isfield(d, 'pumps'); ii = find(d.pumps(kok)<1); else; ii = []; end %overplotting red if pumps not on. bak and ylf jr306, jan2015.
            plot(d.scan(kok),-d.press(kok),'k+-',d.scan(kok(ii)),-d.press(kok(ii)),'r+');
            hold on ;grid on
            plot(db.scan_bot,-db.press_bot,'pc');
            ha(1) = gca;
            if isfield(d, 'pumps'); ylabel('press (red if pumps off)'); else; ylabel('press'); end
            %             ylabel('press');
            %             set(gca,'ylim',plims);
            ht = get(ha(1),'title'); %handle for title
            set(ht,'string',infile1);
            set(ht,'interpreter','none');
            
            subplot('position',[pl pb+3*ph pw ph])
            plot(d.scan(kok),d.cond1(kok),'k+-');
            hold on ;grid on
            plot(d.scan(kok),d.cond2(kok),'r+-');
            ha(2) = gca;
            ylabel('cond');
            
            subplot('position',[pl pb+2*ph pw ph])
            plot(d.scan(kok),d.psal1(kok),'k+-');
            hold on ;grid on
            plot(d.scan(kok),d.psal2(kok),'r+-');
            ha(3) = gca;
            ylabel('psal')
            
            subplot('position',[pl pb+ph pw ph])
            plot(d.scan(kok),d.temp1(kok),'k+-');
            hold on ;grid on
            plot(d.scan(kok),d.temp2(kok),'r+-');
            ha(4) = gca;
            ylabel('temp')
            
            subplot('position',[pl pb pw ph])
            if isfield(d,'oxygen2'); plot(d.scan(kok),d.oxygen1(kok),'k+-',d.scan(kok),d.oxygen2(kok),'r+-');
            else; plot(d.scan(kok),d.oxygen1(kok),'k+-'); end
            hold on ;grid on
            ha(5) = gca;
            ylabel('oxygen')
        case 'w'
            break
        case 'q'
            return
        otherwise
    end
end
%%%%%%%%%%%%%%%%%%%%%%%%%%% end graphical part

% find the data cycle numbers and other parameters
scan = d.scan;
clear ds

ds.dc_start = min(find(scan >= scan_start - 1));
ds.scan_start = floor(d.scan(ds.dc_start));
ds.press_start = d.press(ds.dc_start);
ds.time_start = d.time(ds.dc_start);

ds.dc_end = max(find(scan <= scan_end + 1));
ds.scan_end = floor(d.scan(ds.dc_end));
ds.press_end = d.press(ds.dc_end);
ds.time_end = d.time(ds.dc_end);

ds.dc24_start = min(find(d24.scan >= scan_start - 1));
ds.dc24_end = max(find(d24.scan <= scan_end + 1));

if isfinite(scan_bot)
    ds.dc_bot = min(find(scan >= scan_bot));
    ds.scan_bot = floor(d.scan(ds.dc_bot));
    ds.press_bot = d.press(ds.dc_bot);
    ds.time_bot = d.time(ds.dc_bot);
    ds.dc24_bot = min(find(d24.scan >= scan_bot));
end

clear hnew
hnew.fldnam = fieldnames(ds)'; 
hnew.fldunt = hnew.fldnam;
for no = 1:length(hnew.fldnam)
    ii = strfind(hnew.fldnam{no},'_');
    pre = hnew.fldnam{no}(1:ii-1);
    switch pre
        case {'dc' 'dc24' 'scan'}
            hnew.fldunt{no} = 'number';
        case 'press'
            hnew.fldunt{no} = 'dbar';
        case 'time'
            hnew.fldunt{no} = 'seconds';
        otherwise
            error('unknown dcs variable type');
    end
end

MEXEC_A.Mprog = mfilename;
mfsave(otfile, ds, hnew, '-addvars');
