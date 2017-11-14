% mdcs_03: find scan number corresponding to start and end of file
%          use this to populate the file dcs_[cruise]_[station]
%
% Use: mdcs_03        and then respond with station number, or for station 16
%      stn = 16; mdcs_03;
% jc069: graphical version by bak

scriptname = 'mdcs_03';
cruise = MEXEC_G.MSCRIPT_CRUISE_STRING;

if ~exist('stn','var')
    stn = input('type stn number ');
end
stn_string = sprintf('%03d',stn);
stnlocal = stn; clear stn % so that it doesn't persist

mdocshow(scriptname, ['interactively select start and end of cast, written to dcs_' cruise '_' stn_string '.nc']);

root_ctd = mgetdir('M_CTD'); % change working directory

prefix1 = ['ctd_' cruise '_'];
prefix2 = ['dcs_' cruise '_'];

infile1 = [root_ctd '/' prefix1 stn_string '_psal'];
% infile1 = [root_ctd '/' prefix1 stn_string '_1hz']; % A fudge so could edit the pressure
otfile1 = [root_ctd '/' prefix1 stn_string '_surf'];
otfile2 = [root_ctd '/' prefix2 stn_string ];


% pik data near surface for inspection
hinctd = m_read_header(infile1);
vnames = hinctd.fldnam;
vnum = strmatch('press',vnames,'exact');
if isempty (vnum)
    m = 'press not found';
    error(m)
end

[d h] = mload(infile1,'/');
%  d.psal1 = d.cond1;  % A temporary fudge so coudl edit pressure
%  d.psal2 = d.cond2;
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
scan_end = max(d.scan);
kfirst = 1;
plims = [-300 10];

while 1
    if kfirst == 0
        mess = ['choose : \n'];
        mess = [mess 'p   : plot all\n'];
        mess = [mess 'z   : zoom all panels to current x lims\n'];
        mess = [mess 'q   : quit\n'];
        mess = [mess 'w   : save values and proceed\n'];
        mess = [mess 'ss  : select start scan\n'];
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
            ha(1) = gca;
            if isfield(d, 'pumps'); ylabel('press (red if pumps off)'); else; ylabel('press'); end
%             set(gca,'ylim',plims);
            ht = get(ha(1),'title'); %handle for title
            set(ht,'string',infile1);
            set(ht,'interpreter','none');

            subplot('position',[pl pb+3*ph pw ph])
            plot(d.scan,d.cond1,'k+-');
            hold on ;grid on
            plot(d.scan,d.cond2,'r+-');
            ha(2) = gca;
            ylabel('cond');

            subplot('position',[pl pb+2*ph pw ph])
            plot(d.scan,d.psal1,'k+-');
            hold on ;grid on
            plot(d.scan,d.psal2,'r+-');
            ha(3) = gca;
            ylabel('psal')

            subplot('position',[pl pb+ph pw ph])
            plot(d.scan,d.temp1,'k+-');
            hold on ;grid on
            plot(d.scan,d.temp2,'r+-');
            ha(4) = gca;
            ylabel('temp')

            subplot('position',[pl pb pw ph])
            if isfield(d,'oxygen'); plot(d.scan,d.oxygen,'k+-');
	    else; plot(d.scan,d.oxygen1,'k+-',d.scan,d.oxygen2,'r+-'); end
            hold on ;grid on
            ha(5) = gca;
            ylabel('oxygen')

        case 'z'
            xl = get(gca,'xlim');
            for kp = 1:5
                set(ha(kp),'xlim',xl);
            end
        case 'ss'
            % select downcast start scan
            [x y] = ginput(1);
            scan_start = ceil(x)

        case 'se'
            % select upcast end scan
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
            if isfield(d, 'oxygen'); plot(d.scan(kok),d.oxygen(kok),'k+-');
	    else; plot(d.scan(kok),d.oxygen1(kok),'k+-',d.scan(kok),d.oxygen2(kok),'r+-'); end
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
kstart = min(find(scan >= scan_start - 1));
scanstart = floor(d.scan(kstart));
pstart = d.press(kstart);
tstart = d.time(kstart);
kend = max(find(scan <= scan_end + 1));
scanend = floor(d.scan(kend));
pend = d.press(kend);
tend = d.time(kend);

% set up the data time origin for times start,bottom,end

hinctd = m_read_header(infile1);
hindcs = m_read_header(otfile2);

dtoctd = hinctd.data_time_origin;
dtodcs = hindcs.data_time_origin;
dtodif = dtoctd-dtodcs;
if max(abs(dtodif)) > 0 % reset time origin if needed
    %--------------------------------
    % 2009-01-28 14:51:48
    % mchangetimeorigin
    % input files
    % Filename dcs_jr193_016.nc   Data Name :  dcs_jr193_016 <version> 2 <site> bak_macbook
    % output files
    % Filename dcs_jr193_016.nc   Data Name :  dcs_jr193_016 <version> 3 <site> bak_macbook
    MEXEC_A.MARGS_IN = {
        otfile2
        'y'
        ['[' num2str(hinctd.data_time_origin) ']']
        };
    mchangetimeorigin
    %--------------------------------
end

%--------------------------------
% 2009-01-28 14:41:30
% mcalib
% input files
% Filename dcs_jr193_016.nc   Data Name :  dcs_jr193_016 <version> 1 <site> bak_macbook
% output files
% Filename dcs_jr193_016.nc   Data Name :  dcs_jr193_016 <version> 2 <site> bak_macbook
MEXEC_A.MARGS_IN = {
    otfile2
    'y'
    'time_start'
    ['y(1,1) = ' num2str(tstart)]
    '/'
    '/'
    'dc_start'
    ['y(1,1) = ' num2str(kstart)]
    '/'
    '/'
    'scan_start'
    ['y(1,1) = ' num2str(scanstart)]
    '/'
    '/'
    'press_start'
    ['y(1,1) = ' num2str(pstart)]
    '/'
    '/'
    'time_end'
    ['y(1,1) = ' num2str(tend)]
    '/'
    '/'
    'dc_end'
    ['y(1,1) = ' num2str(kend)]
    '/'
    '/'
    'scan_end'
    ['y(1,1) = ' num2str(scanend)]
    '/'
    '/'
    'press_end'
    ['y(1,1) = ' num2str(pend)]
    '/'
    '/'
    ' '
    };
mcalib
%--------------------------------
