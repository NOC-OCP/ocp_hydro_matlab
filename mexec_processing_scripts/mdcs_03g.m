
function mdcs_03g(stn)
% mdcs_03g: graphical user interface to check scan numbers corresponding to
% start, bottom, and end of cast (estimated in mdcs_01, or selected in a
% previous call to mdcs_03g) and modify if necessary
%
% Use: mdcs_03        and then respond with station number, or for station 16
%      stn = 16; mdcs_03;
% jc069: graphical version by bak
% jc159 ylf added circle for bottom scan/pressure
% jc159 3 April2018 bak add option to identify bottom pressure scan if you
% don't like the one it has chosen
% dy146 ylf treat start of cast the same
% sd025 ylf also end

m_common
opt1 = 'ctd_proc'; opt2 = 'minit'; get_cropt
fprintf(1,'interactively select (or confirm) start, bottom, and end of cast,\n written to dcs_%s_%s.nc.',mcruise,stn_string)
opt1 = 'ctd_proc'; opt2 = 'oxy_align'; get_cropt

root_ctd = mgetdir('M_CTD'); % change working directory

infile1 = fullfile(root_ctd, ['ctd_' mcruise '_' stn_string '_psal']);
infile0 = fullfile(root_ctd, ['ctd_' mcruise '_' stn_string '_24hz']);
otfile = fullfile(root_ctd, ['dcs_' mcruise '_' stn_string]);

[d, h] = mloadq(infile1,'/');
if ~sum(strcmp('press',h.fldnam))
    error('press not found in 1hz file')
end
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

%initial estimates
[dd,hd] = mloadq(otfile, '/');
opt1 = 'mstar'; get_cropt
if isfield(dd, 'dc_start')
    k_start = dd.dc_start;
    if docf
        tun = hd.fldunt(strcmp('time_start',hd.fldnam));
    end
else
    k_start = NaN;
end
if isfield(dd, 'dc_bot')
    k_bot = dd.dc_bot;
    if docf
        tun = hd.fldunt(strcmp('time_bot',hd.fldnam));
    end
else
    k_bot = NaN;
end
if isfield(dd, 'dc_end')
    k_end = dd.dc_end;
    if docf
        tun = hd.fldunt(strcmp('time_end',hd.fldnam));
    end
else
    k_end = NaN;
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
            
            ha(1) = subplot('position',[pl pb+4*ph pw 2*ph]);
            if isfield(d, 'pumps'); ii = find(d.pumps<1); else; ii = []; end %overplotting red if pumps not on. bak and ylf jr306, jan2015.
            plot(d.scan,-d.press,'k+-',d.scan(ii),-d.press(ii),'r+');
            hold on; grid on
            if ~isnan(k_bot)
                plot(d.scan(k_bot),-d.press(k_bot),'cp','markersize',10,'markerfacecolor','c');
            end
            if ~isnan(k_start)
                plot(d.scan(k_start),-d.press(k_start),'c<','markersize',10,'markerfacecolor','c');
            end
            if ~isnan(k_end)
                plot(d.scan(k_end),-d.press(k_end),'c^','markersize',10,'markerfacecolor','c');
            end
            if isfield(d, 'pumps'); ylabel('-press (red if pumps off)'); else; ylabel('-press'); end
            %             set(gca,'ylim',plims);
            ht = get(ha(1),'title');
            set(ht,'string',infile1,'interpreter','none');
            xlim(d.scan([1 end]))

            ha(2) = subplot('position',[pl pb+3*ph pw ph]);
            plot(d.scan,d.cond1,'k+-');
            hold on; grid on
            plot(d.scan,d.cond2,'r+-');
            xlim(d.scan([1 end]))
            set(ha(2),'YAxisLocation','right');
            ylabel('cond');
            
            ha(3) = subplot('position',[pl pb+2*ph pw ph]);
            plot(d.scan,d.psal1,'k+-');
            hold on; grid on
            plot(d.scan,d.psal2,'r+-');
            xlim(d.scan([1 end]))
            ylabel('psal')
            
            ha(4) = subplot('position',[pl pb+ph pw ph]);
            plot(d.scan,d.temp1,'k+-');
            hold on; grid on
            plot(d.scan,d.temp2,'r+-');
            xlim(d.scan([1 end]))
            set(ha(4),'YAxisLocation','right');
            ylabel('temp')
            
            ha(5) = subplot('position',[pl pb pw ph]);
            if isfield(d,'oxygen2'); plot(d.scan,d.oxygen1,'k+-',d.scan,d.oxygen2,'r+-');
            else; plot(d.scan,d.oxygen1,'k+-'); end
            hold on; grid on
            xlim(d.scan([1 end]))
            ylabel('oxygen')

            figure(102)
            
        case 'z'
            xl = get(gca,'xlim');
            for kp = 1:5
                set(ha(kp),'xlim',xl);
            end
            figure(102)
            
        case 'x'
            xl = []; 
            xl(1) = input('type x-axis lower limit   ');
            xl(2) = input('type x-axis upper limit   ');
            for kp = 1:5
                set(ha(kp),'xlim',xl);
            end
            figure(102)
            
        case 'ss'
            % select downcast start scan
            disp('select start scan on any panel');
            [x, y] = ginput(1);
            [~,k_start] = min(abs(d.scan-x));
            
        case 'sb'
            disp('select bottom scan on any panel');
            % select bottom scan
            [x, y] = ginput(1);
            [~,k_bot] = min(abs(d.scan-x));
            
        case 'se'
            % select upcast end scan
            disp('select end scan on any panel');
            if oxy_end
                fprintf(1,'later, oxygen will be truncated %d s before T and C\n',oxy_align)
            else
                fprintf(1,'later, oxygen will be truncated at the same point as T and C,\n unless you change settings under oxy_align in opt_%s',mcruise)
            end
            [x, y] = ginput(1);
            [~,k_end] = min(abs(d.scan-x));

        case 'pp'
            if ~isnan(k_start+k_end)
                kok = k_start:k_end;
            else
                if ~isnan(k_start)
                    kok = k_start:length(d.scan);
                elseif ~isnan(k_end)
                    kok = 1:k_end;
                else
                    kok = [];
                end
            end
            clear ha
            clf
            
            ha(1) = subplot('position',[pl pb+4*ph pw 2*ph]);
            if isfield(d, 'pumps'); ii = find(d.pumps(kok)<1); else; ii = []; end %overplotting red if pumps not on. bak and ylf jr306, jan2015.
            plot(d.scan(kok),-d.press(kok),'k+-',d.scan(kok(ii)),-d.press(kok(ii)),'r+');
            hold on ;grid on
            plot(d.scan(k_bot),-d.press(k_bot),'pc');
            xlim(d.scan(kok([1 end])))
            if isfield(d, 'pumps'); ylabel('press (red if pumps off)'); else; ylabel('press'); end
            ht = get(ha(1),'title'); %handle for title
            set(ht,'string',infile1);
            set(ht,'interpreter','none');
            
            ha(2) = subplot('position',[pl pb+3*ph pw ph]);
            plot(d.scan(kok),d.cond1(kok),'k+-');
            hold on ;grid on
            plot(d.scan(kok),d.cond2(kok),'r+-');
            xlim(d.scan(kok([1 end])))
            ylabel('cond');
            
            ha(3) = subplot('position',[pl pb+2*ph pw ph]);
            plot(d.scan(kok),d.psal1(kok),'k+-');
            hold on ;grid on
            plot(d.scan(kok),d.psal2(kok),'r+-');
            xlim(d.scan(kok([1 end])))
            ylabel('psal')
            
            ha(4) = subplot('position',[pl pb+ph pw ph]);
            plot(d.scan(kok),d.temp1(kok),'k+-');
            hold on ;grid on
            plot(d.scan(kok),d.temp2(kok),'r+-');
            xlim(d.scan(kok([1 end])))
            ylabel('temp')
            
            ha(5) = subplot('position',[pl pb pw ph]);
            if isfield(d,'oxygen2'); plot(d.scan(kok),d.oxygen1(kok),'k+-',d.scan(kok),d.oxygen2(kok),'r+-');
            else; plot(d.scan(kok),d.oxygen1(kok),'k+-'); end
            hold on ;grid on
            xlim(d.scan(kok([1 end])))
            ylabel('oxygen')

            figure(102)

        case 'w'
            break
        case 'q'
            return
        otherwise
    end
end
%%%%%%%%%%%%%%%%%%%%%%%%%%% end graphical part

% find the data cycle numbers and other parameters
clear ds hnew

if isfinite(k_start) && k_start~=dd.dc_start
    ds.dc_start = k_start;
    ds.scan_start = d.scan(ds.dc_start);
    ds.press_start = d.press(ds.dc_start);
    ds.time_start = d.time(ds.dc_start);
    [~,ds.dc24_start] = min(abs(d24.scan-ds.scan_start));
end

if isfinite(k_end) && (~isfield(dd, 'dc_end') || k_end~=dd.dc_end)
    ds.dc_end = k_end;
    ds.scan_end = d.scan(ds.dc_end);
    ds.press_end = d.press(ds.dc_end);
    ds.time_end = d.time(ds.dc_end);
    [~,ds.dc24_end] = min(abs(d24.scan-ds.scan_end));
end

if isfinite(k_bot) && k_bot~=dd.dc_bot
    ds.dc_bot = k_bot;
    ds.scan_bot = floor(d.scan(ds.dc_bot));
    ds.press_bot = d.press(ds.dc_bot);
    ds.time_bot = d.time(ds.dc_bot);
    [~,ds.dc24_bot] = min(abs(d24.scan-ds.scan_bot));
end

if exist('ds','var')
    hnew.fldnam = fieldnames(ds)';
    hnew.fldunt = repmat({' '},size(hnew.fldnam));
    hnew.fldunt(strncmp('dc',hnew.fldnam,2)) = {'number'};
    hnew.fldunt(strncmp('scan',hnew.fldnam,2)) = {'number'};
    hnew.fldunt(strncmp('press',hnew.fldnam,5)) = {'dbar'};
    if docf
        hnew.fldunt(strncmp('time',hnew.fldnam,4)) = tun;
    else
        hnew.fldunt(strncmp('time',hnew.fldnam,4)) = {'seconds'};
    end
    hnew.comment = 'automatically detected ';
    if isfield(ds,'dc_start'); hnew.comment = [hnew.comment 'start ']; end
    if isfield(ds,'dc_bot'); hnew.comment = [hnew.comment 'bottom ']; end
    if isfield(ds,'dc_end'); hnew.comment = [hnew.comment 'end ']; end
    hnew.comment = [hnew.comment 'of cast overwritten with manual selections\n'];

    MEXEC_A.Mprog = mfilename;
    mfsave(otfile, ds, hnew, '-addvars');
else
    h = m_read_header(otfile); h.comment = [h.comment ' cast start/bottom/end inspected but not changed\n'];
    ncfile.name = m_add_nc(otfile); m_write_header(ncfile,h);
end
