% mctd_checkplots: read in ctd data
%
% Use: mctd_checkplots        and then respond with station number, or for station 16
%      stn = 16; mctd_checkplots;
%
% rewrite of mplotxy_ctdck on jr281 by bak march 2013. We need some
% different diagnostics than the ones available previously
%
% There are 10 plots available. 
%
% There are a selection of 1hz and 2 dbar plots. 1 hz plots are trimmed to
% start and end good scan numbers. 1 hz plots commonly have upcast as
% dashed lines.
%
% Some plots are for the input station only. 
%
% Others include a user-controllable selection of previous stations. 
% You can select 'The previous X stations', 
% where X can be any number, including zero.
% Or if you choose '-1' for the number of previous stations, you can offer
% a list of station numbers as an array eg [33 36 39], or 33:39.
%
% Stations that do not have a complete set of files (ctd_2db, ctd_2up,
% ctd_psal and dcs) are skipped
%
% plots are as follows
% plots 2 to 6 and 10 enable comparison with previous stations
% plots 7 to 9 are for examining this station only
%
% 1: mplotxy of the 1hz data
%
% 2 and 3: 2db profiles and theta-S for primary (2) and secondary (3), for this and all
% previous requested stations
%
% 4 and 5: 1hz profiles and theta-S for primary (4) and secondary (5), for this and all
% previous requested stations
%
% 6: theta-S for primary (left panel) and secondary (right panel), for this and all 
% previous requested stations. This is useful for looking at sensor drift.
%
% 7: 2db profiles and theta-S, primary and secondary overplotted. This station only
%
% 8: 1hz profiles and theta-S, primary and secondary overplotted. This station only
%
% 9: up_minus_down differences, using 2db and 2up files. This station only
%
% 10: primary_minus_secondary, using 1hz file, for this and all
% previous requested stations
% 
% The selection and order of plots can be controlled by the variable named
% ctd_cklist. ctd_cklist is an array that will control which
% plots are produced and the order they appear in.
% eg
%
% ctd_cklist = [2 3 7 10 6]; mctd_checkplots
%
% will produce plot 6 last and in the front figure window.
%

scriptname = 'mctd_checkplots';
minit
mdocshow(scriptname, ['plots CTD data from station ' stn_string ' along with data from interactively-chosen previous stations']);

msg1 = 'Type number of previous stations to view, or return to quit';
msg2 = 'Enter -1 if you want to enter a list of station numbers: ';
fprintf(1,'\n%s\n',msg1);
nump = input(msg2);


if (numel(nump) ~= 1)
    msg3 = 'You should reply with a single number';
    fprintf(2,'%s\n',msg3)
    return
end

if nump == -1
    % enter list
    slist = input('Enter list of stations as an array, eg [30 32 34] or 30:34 : ');
else
    % use the lst nump stations
    slist = stnlocal-nump:stnlocal-1;
    slist(slist<1) = [];
end

% stnlocal is now the local station number
% slist is the list of previous stations

root_ctd = mgetdir('M_CTD');

% load data

prefix1 = ['ctd_' mcruise '_'];
prefix2 = ['dcs_' mcruise '_'];

% load data

d2db = {};
h2db = {};
d2up = {};
h2up = {};
dpsal = {};
hpsal = {};
ddcs = {};
hdcs = {};
infiles = {};
sused = [];

for ks = [slist(:)' stnlocal];
    sstring = sprintf('%03d',ks);
    infile1 = m_add_nc([root_ctd '/' prefix1 sstring '_2db']);
    infile2 = m_add_nc([root_ctd '/' prefix1 sstring '_2up' ]);
    infile3 = m_add_nc([root_ctd '/' prefix1 sstring '_psal']);
    infile4 = m_add_nc([root_ctd '/' prefix2 sstring ]);
    % skip stations that don't have a complete set of files
    if exist(infile1,'file') ~= 2; continue; end
    if exist(infile2,'file') ~= 2; continue; end
    if exist(infile3,'file') ~= 2; continue; end
    if exist(infile4,'file') ~= 2; continue; end
    infiles{1,ks} = infile1;
    infiles{2,ks} = infile2;
    infiles{3,ks} = infile3;
    infiles{4,ks} = infile4;
    [d h] = mload(infile1,'/');
    d2db = [d2db d];
    h2db = [h2db h];
    [d h] = mload(infile2,'/');
    d2up = [d2up d];
    h2up = [h2up h];
    [d h] = mload(infile3,'/');
    dpsal = [dpsal d];
    hpsal = [hpsal h];
    [d h] = mload(infile4,'/');
    ddcs = [ddcs d];
    hdcs = [hdcs h];
    sused = [sused ks]; % list of stations that will be used
end
numused = length(sused);

if length(find(sused == stnlocal)) < 1
    msg = ['Station ' sprintf('%03d',stnlocal) ' was not loaded. Check all the files are available'];
    fprintf(2,'%s\n',msg)
end


col_list = 'krcmgb'; % colours to be used in reverse order. k for most recent station.
numcol = length(col_list);
clear cols
if numused <= numcol
    cols = fliplr(col_list(1:numused));
else
    cols(1:numcol) = col_list;
    cols(numcol+1:numused) = col_list(end);
    cols = fliplr(cols);
end
% cols is now a list of cols corresponding to the list of stations to plot


% plots

close all
lwid = 1;
pos_title = [.05 .93 .9 .06];

if exist('ctd_cklist','var')
    cklist = ctd_cklist;
else
    cklist = 1:10;
end

cklist = cklist(:)'; % force to row

for plotlist = cklist
    
    switch plotlist
        case 1
            
            % figure 1
            % mplotxy first
            
            clear pf1;
            pf1.xlist = 'time';
	        oopt = 'pf1'; get_cropt
            first = min(find(dpsal{end}.scan > ddcs{end}.scan_start));
            last = max(find(dpsal{end}.scan < ddcs{end}.scan_end));
            pf1.startdc = first; % good data only
            pf1.stopdc = last;
            pf1.ncfile.name = infiles{3,end}; % psal file
            
            mplotxy(pf1);
            
        case 2
            
            % figure 102
            % 2db primary, all stations, test station last
            
            figure(102)
            
            axes('position',pos_title);
            titstr = {
                ['Station ' sprintf('%03d',sused(end)) ' (' cols(end) ') primary - 2db'];
                [sprintf('%03d ',sused) ' (' cols ')']
                };
            h = text(.5,.5,titstr);
            set(h,'HorizontalAlignment','center');
            set(h,'VerticalAlignment','middle');
            axis off
            
            
            subplot(221)
            for ks = 1:numused
                plot(d2db{ks}.press,d2db{ks}.temp1,[cols(ks) '-'],'linewidth',lwid);
                hold on
            end; grid on
            title('temp')
            
            subplot(222)
            for ks = 1:numused
                oopt = 'sdata'; d = d2db; get_cropt
		        plot(d2db{ks}.press,sdata1,[cols(ks) '-'],'linewidth',lwid);
                hold on
            end; grid on
            title(tis)
            
            subplot(223)
            for ks = 1:numused
	            oopt = 'odata'; d = d2db; get_cropt
                plot(d2db{ks}.press,odata1,[cols(ks) '-'],'linewidth',lwid);
                hold on
            end; grid on
            title ('oxygen')
            
            subplot(224)
            for ks = 1:numused
	            oopt = 'sdata'; d = d2db; get_cropt
                plot(sdata1,d2db{ks}.potemp1,[cols(ks) '-'],'linewidth',lwid);
                hold on
            end; grid on
            title (['potemp-' tis])
            
        case 3
            
            % figure 103
            % 2db secondary, all stations, test station last
            
            figure(103)
            
            axes('position',pos_title);
            titstr = {
                ['Station ' sprintf('%03d',sused(end)) ' (' cols(end) ') secondary - 2db'];
                [sprintf('%03d ',sused) ' (' cols ')']
                };
            h = text(.5,.5,titstr);
            set(h,'HorizontalAlignment','center');
            set(h,'VerticalAlignment','middle');
            axis off
            
            
            subplot(221)
            for ks = 1:numused
                plot(d2db{ks}.press,d2db{ks}.temp2,[cols(ks) '-'],'linewidth',lwid);
                hold on
            end; grid on
            title ('temp')
            
            subplot(222)
            for ks = 1:numused
	            oopt = 'sdata'; d = d2db; get_cropt
                plot(d2db{ks}.press,sdata2,[cols(ks) '-'],'linewidth',lwid);
                hold on
            end; grid on
            title(tis)
            
            subplot(223)
            for ks = 1:numused
                oopt = 'odata'; d = d2db; get_cropt
		        plot(d2db{ks}.press,odata2,[cols(ks) '-'],'linewidth',lwid);
                hold on
            end; grid on
            title ('oxygen')
            
            subplot(224)
            for ks = 1:numused
	            oopt = 'sdata'; d = d2db; get_cropt
                plot(sdata2,d2db{ks}.potemp2,[cols(ks) '-'],'linewidth',lwid);
                hold on; grid on;
            end
            title (['potemp-' tis])
            
        case 4
            
            % figure 104
            % 1hz primary, all stations, test station last
            
            figure(104)
            
            axes('position',pos_title);
            titstr = {
                ['Station ' sprintf('%03d',sused(end)) ' (' cols(end) ') primary - 1hz'];
                [sprintf('%03d ',sused) ' (' cols ')']
                };
            h = text(.5,.5,titstr);
            set(h,'HorizontalAlignment','center');
            set(h,'VerticalAlignment','middle');
            axis off
            
            
            subplot(221)
            for ks = 1:numused
                kokd = find(dpsal{ks}.scan > ddcs{ks}.scan_start & dpsal{ks}.scan < ddcs{ks}.scan_bot);
                koku = find(dpsal{ks}.scan > ddcs{ks}.scan_bot & dpsal{ks}.scan < ddcs{ks}.scan_end);
                plot(dpsal{ks}.press(kokd),dpsal{ks}.temp1(kokd),[cols(ks) '-'],'linewidth',lwid);
                hold on; grid on;
                plot(dpsal{ks}.press(koku),dpsal{ks}.temp1(koku),[cols(ks) '--'],'linewidth',lwid);
            end
            title ('temp: dash for upcast')
            
            subplot(222)
            for ks = 1:numused
                kokd = find(dpsal{ks}.scan > ddcs{ks}.scan_start & dpsal{ks}.scan < ddcs{ks}.scan_bot);
                koku = find(dpsal{ks}.scan > ddcs{ks}.scan_bot & dpsal{ks}.scan < ddcs{ks}.scan_end);
		        oopt = 'sdata'; d = dpsal; get_cropt
                plot(dpsal{ks}.press(kokd),sdata1(kokd),[cols(ks) '-'],'linewidth',lwid);
                hold on
                plot(dpsal{ks}.press(koku),sdata1(koku),[cols(ks) '--'],'linewidth',lwid);
            end; grid on
            title ([tis ': dash for upcast'])
            
            subplot(223)
            for ks = 1:numused
                kokd = find(dpsal{ks}.scan > ddcs{ks}.scan_start & dpsal{ks}.scan < ddcs{ks}.scan_bot);
                koku = find(dpsal{ks}.scan > ddcs{ks}.scan_bot & dpsal{ks}.scan < ddcs{ks}.scan_end);
	            oopt = 'odata'; d = dpsal; get_cropt
                plot(dpsal{ks}.press(kokd),odata1(kokd),[cols(ks) '-'],'linewidth',lwid);
                hold on
                plot(dpsal{ks}.press(koku),odata1(koku),[cols(ks) '--'],'linewidth',lwid);
            end; grid on
            title ('oxygen: dash for upcast')
            
            subplot(224)
            for ks = 1:numused
                kokd = find(dpsal{ks}.scan > ddcs{ks}.scan_start & dpsal{ks}.scan < ddcs{ks}.scan_bot);
                koku = find(dpsal{ks}.scan > ddcs{ks}.scan_bot & dpsal{ks}.scan < ddcs{ks}.scan_end);
		        oopt = 'sdata'; d = dpsal; get_cropt
                plot(sdata1(kokd),dpsal{ks}.potemp1(kokd),[cols(ks) '-'],'linewidth',lwid);
                hold on; grid on;
                plot(sdata1(koku),dpsal{ks}.potemp1(koku),[cols(ks) '--'],'linewidth',lwid);
            end
            title (['potemp-' tis ': dash for upcast'])
            
        case 5
    
            % figure 105
            % 1hz secondary, all stations, test station last
            
            figure(105)
            
            axes('position',pos_title);
            titstr = {
                ['Station ' sprintf('%03d',sused(end)) ' (' cols(end) ') secondary - 1hz'];
                [sprintf('%03d ',sused) ' (' cols ')']
                };
            h = text(.5,.5,titstr);
            set(h,'HorizontalAlignment','center');
            set(h,'VerticalAlignment','middle');
            axis off
            
            
            subplot(221)
            for ks = 1:numused
                kokd = find(dpsal{ks}.scan > ddcs{ks}.scan_start & dpsal{ks}.scan < ddcs{ks}.scan_bot);
                koku = find(dpsal{ks}.scan > ddcs{ks}.scan_bot & dpsal{ks}.scan < ddcs{ks}.scan_end);
                plot(dpsal{ks}.press(kokd),dpsal{ks}.temp2(kokd),[cols(ks) '-'],'linewidth',lwid);
                hold on; grid on;
                plot(dpsal{ks}.press(koku),dpsal{ks}.temp2(koku),[cols(ks) '--'],'linewidth',lwid);
            end
            title ('temp: dash for upcast')
            
            subplot(222)
            for ks = 1:numused
                kokd = find(dpsal{ks}.scan > ddcs{ks}.scan_start & dpsal{ks}.scan < ddcs{ks}.scan_bot);
                koku = find(dpsal{ks}.scan > ddcs{ks}.scan_bot & dpsal{ks}.scan < ddcs{ks}.scan_end);
		        oopt = 'sdata'; d = dpsal; get_cropt
                plot(dpsal{ks}.press(kokd),sdata2(kokd),[cols(ks) '-'],'linewidth',lwid);
                hold on; grid on;
                plot(dpsal{ks}.press(koku),sdata2(koku),[cols(ks) '--'],'linewidth',lwid);
            end
            title ([tis ': dash for upcast'])
            
            subplot(223)
            for ks = 1:numused
                kokd = find(dpsal{ks}.scan > ddcs{ks}.scan_start & dpsal{ks}.scan < ddcs{ks}.scan_bot);
                koku = find(dpsal{ks}.scan > ddcs{ks}.scan_bot & dpsal{ks}.scan < ddcs{ks}.scan_end);
		        oopt = 'odata'; d = dpsal; get_cropt
                plot(dpsal{ks}.press(kokd),odata2(kokd),[cols(ks) '-'],'linewidth',lwid);
                hold on; grid on;
                plot(dpsal{ks}.press(koku),odata2(koku),[cols(ks) '--'],'linewidth',lwid);
            end
            title ('oxygen: dash for upcast')
            
            subplot(224)
            for ks = 1:numused
                kokd = find(dpsal{ks}.scan > ddcs{ks}.scan_start & dpsal{ks}.scan < ddcs{ks}.scan_bot);
                koku = find(dpsal{ks}.scan > ddcs{ks}.scan_bot & dpsal{ks}.scan < ddcs{ks}.scan_end);
		        oopt = 'sdata'; d = dpsal; get_cropt
                plot(sdata2(kokd),dpsal{ks}.potemp2(kokd),[cols(ks) '-'],'linewidth',lwid);
                hold on; grid on;
                plot(sdata2(koku),dpsal{ks}.potemp2(koku),[cols(ks) '--'],'linewidth',lwid);
            end
            title (['potemp-' tis ': dash for upcast'])
            
        case 6
                        
            % figure 106
            % 2db primary and secondary theta-S, all stations, test station last
            % bak on jr302; july 2014; theta-O as well
            
            figure(106)
            
            axes('position',pos_title);
            titstr = {
                ['Station ' sprintf('%03d',sused(end)) ' (' cols(end) ') primary & secondary - 2db'];
                [sprintf('%03d ',sused) ' (' cols ')']
                };
            h = text(.5,.5,titstr);
            set(h,'HorizontalAlignment','center');
            set(h,'VerticalAlignment','middle');
            axis off
            
            
            subplot(221)
            for ks = 1:numused
	            oopt = 'sdata'; d = d2db; get_cropt
                plot(sdata1,d2db{ks}.potemp1,[cols(ks) '-'],'linewidth',lwid);
                hold on
            end; grid on
            title (['theta-' tis ' primary'])
            
            subplot(222)
            for ks = 1:numused
	            oopt = 'sdata'; d = d2db; get_cropt
                plot(sdata2,d2db{ks}.potemp2,[cols(ks) '-'],'linewidth',lwid);
                hold on
            end; grid on
            title (['theta-' tis ' secondary'])
            
            subplot(223)
            for ks = 1:numused
	            oopt = 'odata'; d = d2db; get_cropt
                plot(odata1,d2db{ks}.potemp1,[cols(ks) '-'],'linewidth',lwid);
                hold on
            end; grid on
            title ('theta-O primary')
            
            subplot(224)
            for ks = 1:numused
	            oopt = 'odata'; d = d2db; get_cropt
                plot(odata2,d2db{ks}.potemp2,[cols(ks) '-'],'linewidth',lwid);
                hold on; grid on;
            end
            title ('theta-O secondary')
            
            
        case 7
            % now some plots from just this station
            
            % figure 107
            % 2db primary and secondary
            
            figure(107)
            
            axes('position',pos_title);
            titstr = {
                ['Station ' sprintf('%03d',sused(end)) ' primary & secondary - 2db'];
                ['primary (k) secondary (r)']
                };
            h = text(.5,.5,titstr);
            set(h,'HorizontalAlignment','center');
            set(h,'VerticalAlignment','middle');
            axis off
            
            
            subplot(221)
            for ks = numused
                plot(d2db{ks}.press,d2db{ks}.temp1,['k' '-'],'linewidth',lwid);
                hold on; grid on;
                plot(d2db{ks}.press,d2db{ks}.temp2,['r' '-'],'linewidth',lwid);
            end
            title ('temp')
            
            subplot(222)
            for ks = numused
	            oopt = 'sdata'; d = d2db; get_cropt
                plot(d2db{ks}.press,sdata1,['k' '-'],'linewidth',lwid);
                hold on; grid on;
                plot(d2db{ks}.press,sdata2,['r' '-'],'linewidth',lwid);
            end
            title (tis)
            
            subplot(223)
            for ks = numused
	            oopt = 'odata'; d = d2db; get_cropt
                plot(d2db{ks}.press,odata1,['k' '-'],'linewidth',lwid);
                hold on; grid on;
                plot(d2db{ks}.press,odata2,['r' '-'],'linewidth',lwid); % no secondary oxygen
            end
            title ('oxygen')
            
            subplot(224)
            for ks = numused
	            oopt = 'sdata'; d = d2db; get_cropt
                plot(sdata1,d2db{ks}.potemp1,['k' '-'],'linewidth',lwid);
                hold on; grid on;
                plot(sdata2,d2db{ks}.potemp2,['r' '-'],'linewidth',lwid);
            end
            title (['theta-' tis])
            
            
        case 8
            
            % figure 108
            % 1hz primary and secondary
            
            figure(108)
            
            axes('position',pos_title);
            titstr = {
                ['Station ' sprintf('%03d',sused(end)) ' primary & secondary - 1hz'];
                ['primary (k) secondary (r)']
                };
            h = text(.5,.5,titstr);
            set(h,'HorizontalAlignment','center');
            set(h,'VerticalAlignment','middle');
            axis off
            
            
            subplot(221)
            for ks = numused
                kokd = find(dpsal{ks}.scan > ddcs{ks}.scan_start & dpsal{ks}.scan < ddcs{ks}.scan_bot);
                koku = find(dpsal{ks}.scan > ddcs{ks}.scan_bot & dpsal{ks}.scan < ddcs{ks}.scan_end);
                plot(dpsal{ks}.press(kokd),dpsal{ks}.temp1(kokd),['k' '-'],'linewidth',lwid);
                hold on; grid on;
                plot(dpsal{ks}.press(koku),dpsal{ks}.temp1(koku),['k' '--'],'linewidth',lwid);
                plot(dpsal{ks}.press(kokd),dpsal{ks}.temp2(kokd),['r' '-'],'linewidth',lwid);
                plot(dpsal{ks}.press(koku),dpsal{ks}.temp2(koku),['r' '--'],'linewidth',lwid);
            end
            title ('temp: dash for upcast')
            
            subplot(222)
            for ks = numused
                kokd = find(dpsal{ks}.scan > ddcs{ks}.scan_start & dpsal{ks}.scan < ddcs{ks}.scan_bot);
                koku = find(dpsal{ks}.scan > ddcs{ks}.scan_bot & dpsal{ks}.scan < ddcs{ks}.scan_end);
		        oopt = 'sdata'; d = dpsal; get_cropt
                plot(dpsal{ks}.press(kokd),sdata1(kokd),['k' '-'],'linewidth',lwid);
                hold on; grid on;
                plot(dpsal{ks}.press(koku),sdata1(koku),['k' '--'],'linewidth',lwid);
                plot(dpsal{ks}.press(kokd),sdata2(kokd),['r' '-'],'linewidth',lwid);
                plot(dpsal{ks}.press(koku),sdata2(koku),['r' '--'],'linewidth',lwid);
            end
            title ([tis ': dash for upcast'])
            
            
            subplot(223)
            for ks = numused
                kokd = find(dpsal{ks}.scan > ddcs{ks}.scan_start & dpsal{ks}.scan < ddcs{ks}.scan_bot);
                koku = find(dpsal{ks}.scan > ddcs{ks}.scan_bot & dpsal{ks}.scan < ddcs{ks}.scan_end);
	        	oopt = 'odata'; d = dpsal; get_cropt
                plot(dpsal{ks}.press(kokd),odata1(kokd),['k' '-'],'linewidth',lwid);
                hold on; grid on;
                plot(dpsal{ks}.press(koku),odata1(koku),['k' '--'],'linewidth',lwid);
                plot(dpsal{ks}.press(kokd),odata2(kokd),['r' '-'],'linewidth',lwid);
                plot(dpsal{ks}.press(koku),odata2(koku),['r' '--'],'linewidth',lwid);
		end
            title ('oxygen: dash for upcast')
            
            
            subplot(224)
            for ks = numused
                kokd = find(dpsal{ks}.scan > ddcs{ks}.scan_start & dpsal{ks}.scan < ddcs{ks}.scan_bot);
                koku = find(dpsal{ks}.scan > ddcs{ks}.scan_bot & dpsal{ks}.scan < ddcs{ks}.scan_end);
		        oopt = 'sdata'; d = dpsal; get_cropt
                plot(sdata1(kokd),dpsal{ks}.temp1(kokd),['k' '-'],'linewidth',lwid);
                hold on; grid on;
                plot(sdata1(koku),dpsal{ks}.temp1(koku),['k' '--'],'linewidth',lwid);
                plot(sdata2(kokd),dpsal{ks}.temp2(kokd),['r' '-'],'linewidth',lwid);
                plot(sdata2(koku),dpsal{ks}.temp2(koku),['r' '--'],'linewidth',lwid);
            end
            title (['theta-' tis ': dash for upcast'])
            
         case 9
           
            % figure 109
            % 1hz primary and secondary up-down difference
            
            figure(109)
            
            axes('position',pos_title);
            titstr = {
                ['Station ' sprintf('%03d',sused(end)) ' up minus down - 2up & 2db'];
                [' ']
                };
            h = text(.5,.5,titstr);
            set(h,'HorizontalAlignment','center');
            set(h,'VerticalAlignment','middle');
            axis off
            
            
            subplot(321)
            for ks = numused
                upintrp = interp1(d2up{ks}.press,d2up{ks}.temp1,d2db{ks}.press);
                down = d2db{ks}.temp1;
                plot(d2db{ks}.press, upintrp-down,['k' '-'],'linewidth',lwid);
                hold on; grid on;
            end
            title ('temp1 up minus down diff');
            
            
            subplot(322)
            for ks = numused
                upintrp = interp1(d2up{ks}.press,d2up{ks}.temp2,d2db{ks}.press);
                down = d2db{ks}.temp2;
                plot(d2db{ks}.press, upintrp-down,['k' '-'],'linewidth',lwid);
                hold on; grid on;
            end
            title ('temp2 up minus down diff');
            
            
            subplot(323)
            for ks = numused
	            oopt = 'sdata'; d = d2up; get_cropt
                upintrp = interp1(d2up{ks}.press,sdata1,d2db{ks}.press);
                oopt = 'sdata'; d = d2db; get_cropt
                plot(d2db{ks}.press, upintrp-sdata1,['k' '-'],'linewidth',lwid);
                hold on; grid on;
            end
            title ([tis '1 up minus down diff']);
            
            
            subplot(324)
            for ks = numused
	            oopt = 'sdata'; d = d2up; get_cropt
                upintrp = interp1(d2up{ks}.press,sdata2,d2db{ks}.press);
                oopt = 'sdata'; d = d2db; get_cropt
                plot(d2db{ks}.press, upintrp-sdata2,['k' '-'],'linewidth',lwid);
                hold on; grid on;
            end
            title ([tis '2 up minus down diff']);
            
            
            subplot(325)
            for ks = numused
	            oopt = 'odata'; d = d2up; get_cropt
                upintrp = interp1(d2up{ks}.press,odata1,d2db{ks}.press);
		        oopt = 'odata'; d = d2db; get_cropt
                plot(d2db{ks}.press, upintrp-odata1,['k' '-'],'linewidth',lwid);
                hold on; grid on;
            end
            title ('oxygen 1 up minus down diff');

            subplot(326)
            for ks = numused
	            oopt = 'odata'; d = d2up; get_cropt
                upintrp = interp1(d2up{ks}.press,odata2,d2db{ks}.press);
                oopt = 'odata'; d = d2db; get_cropt
                plot(d2db{ks}.press, upintrp-odata2,['k' '-'],'linewidth',lwid);
                hold on; grid on;
            end
            title ('oxygen 2 up minus down diff');
            
         case 10
           
            
            % figure 110
            % 1hz primary and secondary difference
            
            figure(110)
            
            axes('position',pos_title);
            titstr = {
                ['Station ' sprintf('%03d',sused(end)) ' (' cols(end) ') primary minus secondary - 1hz'];
                [sprintf('%03d ',sused) ' (' cols ')']
                };
            h = text(.5,.5,titstr);
            set(h,'HorizontalAlignment','center');
            set(h,'VerticalAlignment','middle');
            axis off
            
            
            subplot(321)
            for ks = 1:numused
                kok = find(dpsal{ks}.scan > ddcs{ks}.scan_start & dpsal{ks}.scan < ddcs{ks}.scan_end);
                kmid = max(find(dpsal{ks}.scan < ddcs{ks}.scan_bot));
                plot((dpsal{ks}.time(kok)-dpsal{ks}.time(kmid))/60,dpsal{ks}.temp1(kok)-dpsal{ks}.temp2(kok),[cols(ks) '-'],'linewidth',lwid);
                hold on; grid on;
            end
            title ('temp diff');
            xlabel('minutes away from bottom');
            
            
            subplot(322) % repeat plot with forced axes
            for ks = 1:numused
                kok = find(dpsal{ks}.scan > ddcs{ks}.scan_start & dpsal{ks}.scan < ddcs{ks}.scan_end);
                kmid = max(find(dpsal{ks}.scan < ddcs{ks}.scan_bot));
                plot((dpsal{ks}.time(kok)-dpsal{ks}.time(kmid))/60,dpsal{ks}.temp1(kok)-dpsal{ks}.temp2(kok),[cols(ks) '-'],'linewidth',lwid);
                hold on; grid on;
            end
            title ('temp diff');
            xlabel('minutes away from bottom');
            axoff = m_nanmedian(dpsal{ks}.temp1(kok)-dpsal{ks}.temp2(kok)); % bak on jr302 17 jun 2014; centre axes on data if out of range
            if abs(axoff) < 0.004; axoff = 0; end
            if axoff ~= 0
                subplot(326)
                axis([0 1 0 1]);
                ht = text(.5,2/3,'temp diff axes not centred on zero');
                set(ht,'verticalalignment','middle')
                set(ht,'horizontalalignment','center')
                set(ht,'color','r')
                subplot(322)
            end
            ax = axis; ax(3:4) = [-0.005 0.005]+axoff; axis(ax);
            
            
            subplot(323)
            for ks = 1:numused
                kok = find(dpsal{ks}.scan > ddcs{ks}.scan_start & dpsal{ks}.scan < ddcs{ks}.scan_end);
                kmid = max(find(dpsal{ks}.scan < ddcs{ks}.scan_bot));
	            oopt = 'sdata'; d = dpsal; get_cropt
                plot((dpsal{ks}.time(kok)-dpsal{ks}.time(kmid))/60,sdata1(kok)-sdata2(kok),[cols(ks) '-'],'linewidth',lwid);
                hold on
            end; grid on
            title ([tis ' diff']);
            xlabel('minutes away from bottom');
            
            
            subplot(324)
            for ks = 1:numused
                kok = find(dpsal{ks}.scan > ddcs{ks}.scan_start & dpsal{ks}.scan < ddcs{ks}.scan_end);
                kmid = max(find(dpsal{ks}.scan < ddcs{ks}.scan_bot));
		        oopt = 'sdata'; d = dpsal; get_cropt
                plot((dpsal{ks}.time(kok)-dpsal{ks}.time(kmid))/60,sdata1(kok)-sdata2(kok),[cols(ks) '-'],'linewidth',lwid);
                hold on
            end; grid on
            title ('psal diff');
            xlabel('minutes away from bottom');
            axoff = m_nanmedian(sdata1(kok)-sdata2(kok)); % bak on jr302 17 jun 2014; centre axes on data if out of range
            if abs(axoff) < 0.004; axoff = 0; end
            if axoff ~= 0
                subplot(326)
                axis([0 1 0 1]);
                ht = text(.5,1/3,[tis ' diff axes not centred on zero']);
                set(ht,'verticalalignment','middle')
                set(ht,'horizontalalignment','center')
                set(ht,'color','r')
                subplot(324)
            end
            ax = axis; ax(3:4) = [-0.005 0.005]+axoff; axis(ax);
            
            subplot(325)
            for ks = 1:numused
                kok = find(dpsal{ks}.scan > ddcs{ks}.scan_start & dpsal{ks}.scan < ddcs{ks}.scan_end);
                kmid = max(find(dpsal{ks}.scan < ddcs{ks}.scan_bot));
		        oopt = 'odata'; d = dpsal; get_cropt
                plot((dpsal{ks}.time(kok)-dpsal{ks}.time(kmid))/60,odata1(kok)-odata2(kok),[cols(ks) '-'],'linewidth',lwid);
                hold on; grid on;
            end
            title ('oxy diff');
            xlabel('minutes away from bottom');
            
            
            subplot(326)
            for ks = 1:numused
                kok = find(dpsal{ks}.scan > ddcs{ks}.scan_start & dpsal{ks}.scan < ddcs{ks}.scan_end);
                kmid = max(find(dpsal{ks}.scan < ddcs{ks}.scan_bot));
		        oopt = 'odata'; d = dpsal; get_cropt
                plot((dpsal{ks}.time(kok)-dpsal{ks}.time(kmid))/60,odata1(kok)-odata2(kok),[cols(ks) '-'],'linewidth',lwid);
                hold on; grid on;
            end
            title ('oxy diff');
            xlabel('minutes away from bottom');
            ax = axis; ax(3:4) = [-30 30]; axis(ax);

            
        otherwise
    end
end















