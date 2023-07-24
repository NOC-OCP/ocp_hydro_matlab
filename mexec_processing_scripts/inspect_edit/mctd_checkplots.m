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

opt1 = 'castpars'; opt2 = 'minit'; get_cropt
if MEXEC_G.quiet<=1; fprintf(1,'plotting CTD data from station %s along with data from selected previous stations',stn_string);end

msg1 = '\n Type number of previous stations to view, a list of at least two station numbers, or return to quit\n';
nump = input(msg1);

if numel(nump)>1
    slist = nump; 
%     slist = slist(slist<stnlocal); % bak en705 19 july 2023; no reason why
%     we should only display earlier stations
elseif numel(nump)==1
    slist = stnlocal-nump:stnlocal-1;
    slist(slist<0) = []; % bak en705 19 july 2023 : allow station number zero
else
    disp('you should reply with a single number or a vector')
    return
end

% stnlocal is now the local station number
% slist is the list of previous stations

root_ctd = mgetdir('M_CTD');

% load data

prefix1 = ['ctd_' mcruise '_'];
prefix2 = ['dcs_' mcruise '_'];

% load data

klist = [slist(:)' stnlocal];
sused = false(size(klist));
infiles = cell(4,length(klist));
d2db = cell(1,length(klist));
d2up = d2db; dpsal = d2db; ddcs = d2db;
for no = 1:length(klist)
    ks = klist(no);
    sstring = sprintf('%03d',ks);
    infile1 = m_add_nc(fullfile(root_ctd, [prefix1 sstring '_2db']));
    infile2 = m_add_nc(fullfile(root_ctd, [prefix1 sstring '_2up']));
    infile3 = m_add_nc(fullfile(root_ctd, [prefix1 sstring '_psal']));
    infile4 = m_add_nc(fullfile(root_ctd, [prefix2 sstring]));
    % skip stations that don't have a complete set of files
    if exist(infile1,'file') && exist(infile2,'file') && exist(infile3,'file') && exist(infile4,'file')
        infiles{1,no} = infile1;
        infiles{2,no} = infile2;
        infiles{3,no} = infile3;
        infiles{4,no} = infile4;
        [d2db{no}, ~] = mloadq(infile1,'/');
        [d2up{no}, ~] = mloadq(infile2,'/');
        [dpsal{no}, ~] = mloadq(infile3,'/');
        [ddcs{no}, ~] = mloadq(infile4,'/');
        sused(no) = 1;
    end
end
infiles = infiles(:,sused);
d2db = d2db(:,sused); d2up = d2up(:,sused);
dpsal = dpsal(:,sused); ddcs = ddcs(:,sused);
sused = klist(sused);
numused = length(sused);

if sum(sused==stnlocal)<1
    msg = ['Station ' sprintf('%03d',stnlocal) ' was not loaded. Check all the files are available'];
    fprintf(2,'%s\n',msg)
end

lcolors = [0 0 1; 0 .8 0; .85 0 .85; 0 1 1; 1 0 0; 0 0 0];
if numused>size(lcolors,1)
    lcolors = [repmat([.5 .5 .5],numused-length(lcolors),1); lcolors];
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

saltype = 'psal';
opt1 = mfilename; opt2 = 'plot_saltype'; get_cropt
opt1 = 'castpars'; opt2 = 'oxyvars'; get_cropt; nox = size(oxyvars,1);
opt1 = 'castpars'; opt2 = 'oxy_align'; get_cropt

for plotlist = cklist
    
    switch plotlist
        case 1
            
            % figure 1
            % mplotxy first
            
            clear pf1;
            pf1.xlist = 'time';
            pf1.ylist = ['press temp ' saltype ' oxygen'];
            first = find(dpsal{end}.scan > ddcs{end}.scan_start, 1 );
            last = find(dpsal{end}.scan < ddcs{end}.scan_end, 1, 'last' );
            pf1.startdc = first; % good data only
            pf1.stopdc = last;
            if oxy_end
                pf1.stopdcv.oxygen = pf1.stopdc-oxy_align;
            end
            pf1.ncfile.name = infiles{3,end}; % psal file
            
            mplotxy(pf1);
            
        case 2
            
            % figure 102
            % 2db primary, all stations, test station last
            figure(102); clf
            axes('position',pos_title);
            titstr = {
                ['Station ' sprintf('%03d',sused(end)) ' (' cols(end) ') primary - 2db'];
                %[sprintf('%03d ',sused) ' (' cols ')']
                };
            h = text(.5,.5,titstr); hold on
            set(h,'HorizontalAlignment','center','VerticalAlignment','middle');
            for ks = 1:numused
                iic = ks+length(lcolors)-numused;
                text((ks-numused/2)/numused*.4+.45,0,sprintf('%03d ',sused(ks)),'color',lcolors(iic,:));
            end
            axis([0 1 -.2 1]); axis off
            
            for ks = 1:numused
                iic = ks+length(lcolors)-numused;
                
                subplot(221)
                plot(d2db{ks}.press,d2db{ks}.temp1,'linewidth',lwid,'color',lcolors(iic,:)); 
                hold on
                
                subplot(222)
                plot(d2db{ks}.press,d2db{ks}.([saltype '1']),'linewidth',lwid,'color',lcolors(iic,:));
                hold on
                
                subplot(223)
                plot(d2db{ks}.press,d2db{ks}.(oxyvars{1,2}),'linewidth',lwid,'color',lcolors(iic,:));
                hold on
                
                subplot(224)
                plot(d2db{ks}.([saltype '1']),d2db{ks}.potemp1,'linewidth',lwid,'color',lcolors(iic,:));
                hold on
    
            end
            subplot(221); grid on; title('temp')
            subplot(222); grid on; title(saltype)
            subplot(223); grid on; title ('oxygen')
            subplot(224); grid on; title (['potemp-' saltype])
            
        case 3
            
            % figure 103
            % 2db secondary, all stations, test station last
            figure(103); clf
            axes('position',pos_title);
            titstr = {
                ['Station ' sprintf('%03d',sused(end)) ' (' cols(end) ') secondary - 2db'];
                %[sprintf('%03d ',sused) ' (' cols ')']
                };
            h = text(.5,.5,titstr); hold on
            set(h,'HorizontalAlignment','center','VerticalAlignment','middle');
            for ks = 1:numused
                iic = ks+length(lcolors)-numused;
                text((ks-numused/2)/numused*.4+.45,0,sprintf('%03d ',sused(ks)),'color',lcolors(iic,:));
            end
            axis([0 1 -.2 1]); axis off
            
            for ks = 1:numused
                iic = ks+length(lcolors)-numused;
                
                subplot(221)
                plot(d2db{ks}.press,d2db{ks}.temp2,'linewidth',lwid,'color',lcolors(iic,:)); 
                hold on
                
                subplot(222)
                plot(d2db{ks}.press,d2db{ks}.([saltype '2']),'linewidth',lwid,'color',lcolors(iic,:));
                hold on
                
                subplot(223)
                if nox>1
                    plot(d2db{ks}.press,d2db{ks}.(oxyvars{2,2}),'linewidth',lwid,'color',lcolors(iic,:));
                    hold on
                end
                
                subplot(224)
                plot(d2db{ks}.([saltype '2']),d2db{ks}.potemp2,'linewidth',lwid,'color',lcolors(iic,:));
                hold on
    
            end
            subplot(221); grid on; title('temp')
            subplot(222); grid on; title(saltype)
            subplot(223); grid on; title ('oxygen')
            subplot(224); grid on; title (['potemp-' saltype])
            
        case 4
            
            % figure 104
            % 1hz primary, all stations, test station last
            figure(104); clf
            axes('position',pos_title);
            titstr = {
                ['Station ' sprintf('%03d',sused(end)) ' (' cols(end) ') primary - 1hz'];
                };
            h = text(.5,.5,titstr); hold on
            set(h,'HorizontalAlignment','center','VerticalAlignment','middle');
            for ks = 1:numused
                iic = ks+length(lcolors)-numused;
                text((ks-numused/2)/numused*.4+.45,0,sprintf('%03d ',sused(ks)),'color',lcolors(iic,:));
            end
            axis([0 1 -.2 1]); axis off
            
            for ks = 1:numused
                iic = ks+length(lcolors)-numused;
                kokd = find(dpsal{ks}.scan > ddcs{ks}.scan_start & dpsal{ks}.scan < ddcs{ks}.scan_bot);
                koku = find(dpsal{ks}.scan > ddcs{ks}.scan_bot & dpsal{ks}.scan < ddcs{ks}.scan_end);

                subplot(221)
                plot(dpsal{ks}.press(kokd),dpsal{ks}.temp1(kokd),'color',lcolors(iic,:),'linewidth',lwid);
                hold on
                plot(dpsal{ks}.press(koku),dpsal{ks}.temp1(koku),'color',lcolors(iic,:),'linewidth',lwid,'linestyle','--');
                
                subplot(222)
                sd = dpsal{ks}.([saltype '1']);
                plot(dpsal{ks}.press(kokd),sd(kokd),'color',lcolors(iic,:),'linewidth',lwid);
                hold on
                plot(dpsal{ks}.press(koku),sd(koku),'color',lcolors(iic,:),'linewidth',lwid,'linestyle','--');
                
                subplot(223)
                if oxy_end
                    kokdo = find(dpsal{ks}.scan > ddcs{ks}.scan_start & dpsal{ks}.scan < ddcs{ks}.scan_bot);
                    kokuo = find(dpsal{ks}.scan > ddcs{ks}.scan_bot & dpsal{ks}.scan < ddcs{ks}.scan_end-oxy_align*24);
                else
                    kokdo = kokd;
                    kokuo = koku;
                end
                od = dpsal{ks}.(oxyvars{1,2});
                plot(dpsal{ks}.press(kokdo),od(kokdo),'color',lcolors(iic,:),'linewidth',lwid);
                hold on
                plot(dpsal{ks}.press(kokuo),od(kokuo),'color',lcolors(iic,:),'linewidth',lwid,'linestyle','--');
                
                subplot(224)
                sd = dpsal{ks}.([saltype '1']);
                plot(sd(kokd),dpsal{ks}.potemp1(kokd),'color',lcolors(iic,:),'linewidth',lwid);
                hold on
                plot(sd(koku),dpsal{ks}.potemp1(koku),'color',lcolors(iic,:),'linewidth',lwid,'linestyle','--');
                
            end
            subplot(221); grid on; title ('temp: dash for upcast')
            subplot(222); grid on; title ([saltype ': dash for upcast'])
            subplot(223); grid on; title ('oxygen: dash for upcast')
            subplot(224); grid on; title (['potemp-' saltype ': dash for upcast'])
            
        case 5
            
            % figure 105
            % 1hz secondary, all stations, test station last
            figure(105); clf
            axes('position',pos_title);
            titstr = {
                ['Station ' sprintf('%03d',sused(end)) ' (' cols(end) ') secondary - 1hz'];
                };
            h = text(.5,.5,titstr); hold on
            set(h,'HorizontalAlignment','center','VerticalAlignment','middle');
            for ks = 1:numused
                iic = ks+length(lcolors)-numused;
                text((ks-numused/2)/numused*.4+.45,0,sprintf('%03d ',sused(ks)),'color',lcolors(iic,:));
            end
            axis([0 1 -.2 1]); axis off
            
            for ks = 1:numused
                iic = ks+length(lcolors)-numused;
                kokd = find(dpsal{ks}.scan > ddcs{ks}.scan_start & dpsal{ks}.scan < ddcs{ks}.scan_bot);
                koku = find(dpsal{ks}.scan > ddcs{ks}.scan_bot & dpsal{ks}.scan < ddcs{ks}.scan_end);

                subplot(221)
                plot(dpsal{ks}.press(kokd),dpsal{ks}.temp2(kokd),'color',lcolors(iic,:),'linewidth',lwid);
                hold on
                plot(dpsal{ks}.press(koku),dpsal{ks}.temp2(koku),'color',lcolors(iic,:),'linewidth',lwid,'linestyle','--');
                
                subplot(222)
                sd = dpsal{ks}.([saltype '2']);
                plot(dpsal{ks}.press(kokd),sd(kokd),'color',lcolors(iic,:),'linewidth',lwid);
                hold on
                plot(dpsal{ks}.press(koku),sd(koku),'color',lcolors(iic,:),'linewidth',lwid,'linestyle','--');
                
                subplot(223)
                if oxy_end
                    kokdo = find(dpsal{ks}.scan > ddcs{ks}.scan_start & dpsal{ks}.scan < ddcs{ks}.scan_bot);
                    kokuo = find(dpsal{ks}.scan > ddcs{ks}.scan_bot & dpsal{ks}.scan < ddcs{ks}.scan_end-oxy_align*24);
                else
                    kokdo = kokd;
                    kokuo = koku;
                end
                if nox>1
                    od = dpsal{ks}.(oxyvars{2,2});
                    plot(dpsal{ks}.press(kokdo),od(kokdo),'color',lcolors(iic,:),'linewidth',lwid);
                    hold on
                    plot(dpsal{ks}.press(kokuo),od(kokuo),'color',lcolors(iic,:),'linewidth',lwid,'linestyle','--');
                end
                
                subplot(224)
                sd = dpsal{ks}.([saltype '2']);
                plot(sd(kokd),dpsal{ks}.potemp2(kokd),'color',lcolors(iic,:),'linewidth',lwid);
                hold on
                plot(sd(koku),dpsal{ks}.potemp2(koku),'color',lcolors(iic,:),'linewidth',lwid,'linestyle','--');
                
            end
            subplot(221); grid on; title ('temp: dash for upcast')
            subplot(222); grid on; title ([saltype ': dash for upcast'])
            subplot(223); grid on; title ('oxygen: dash for upcast')
            subplot(224); grid on; title (['potemp-' saltype ': dash for upcast'])
            
        case 6
            
            % figure 106
            % 2db primary and secondary theta-S, all stations, test station last
            % bak on jr302; july 2014; theta-O as well
            figure(106); clf
            axes('position',pos_title);
            titstr = {
                ['Station ' sprintf('%03d',sused(end)) ' (' cols(end) ') primary & secondary - 2db'];
                };
            h = text(.5,.5,titstr); hold on
            set(h,'HorizontalAlignment','center','VerticalAlignment','middle');
            for ks = 1:numused
                iic = ks+length(lcolors)-numused;
                text((ks-numused/2)/numused*.4+.45,0,sprintf('%03d ',sused(ks)),'color',lcolors(iic,:));
            end
            axis([0 1 -.2 1]); axis off
            
            for ks = 1:numused
                iic = ks+length(lcolors)-numused;
                
                subplot(221)
                plot(d2db{ks}.([saltype '1']),d2db{ks}.potemp1,'color',lcolors(iic,:),'linewidth',lwid);
                hold on
                
                subplot(222)
                plot(d2db{ks}.([saltype '2']),d2db{ks}.potemp2,'color',lcolors(iic,:),'linewidth',lwid);
                hold on
                
                subplot(223)
                plot(d2db{ks}.(oxyvars{1,2}),d2db{ks}.potemp1,'color',lcolors(iic,:),'linewidth',lwid);
                hold on
                
                if nox>1
                    subplot(224)
                    plot(d2db{ks}.(oxyvars{2,2}),d2db{ks}.potemp2,'color',lcolors(iic,:),'linewidth',lwid);
                    hold on
                end
            end
            subplot(221); grid on; title (['theta-' saltype ' primary'])
            subplot(222); grid on; title (['theta-' saltype ' secondary'])
            subplot(223); grid on; title ('theta-O primary')
            if nox>1; subplot(224); grid on; title ('theta-O secondary'); end
            
            
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
                plot(d2db{ks}.press,d2db{ks}.([saltype '1']),['k' '-'],'linewidth',lwid);
                hold on; grid on;
                plot(d2db{ks}.press,d2db{ks}.([saltype '2']),['r' '-'],'linewidth',lwid);
            end
            title(saltype)
            
            subplot(223)
            for ks = numused
                plot(d2db{ks}.press,d2db{ks}.(oxyvars{1,2}),['k' '-'],'linewidth',lwid);
                hold on; grid on;
                if nox>1
                    plot(d2db{ks}.press,d2db{ks}.(oxyvars{2,2}),['r' '-'],'linewidth',lwid);
                end
            end
            title ('oxygen')
            
            subplot(224)
            for ks = numused
                plot(d2db{ks}.([saltype '1']),d2db{ks}.potemp1,['k' '-'],'linewidth',lwid);
                hold on; grid on;
                plot(d2db{ks}.([saltype '2']),d2db{ks}.potemp2,['r' '-'],'linewidth',lwid);
            end
            title (['theta-' saltype])
            
            
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
                sd = dpsal{ks}.([saltype '1']);
                plot(dpsal{ks}.press(kokd),sd(kokd),['k' '-'],'linewidth',lwid);
                hold on; grid on;
                plot(dpsal{ks}.press(koku),sd(koku),['k' '--'],'linewidth',lwid);
                sd = dpsal{ks}.([saltype '2']);
                plot(dpsal{ks}.press(kokd),sd(kokd),['r' '-'],'linewidth',lwid);
                plot(dpsal{ks}.press(koku),sd(koku),['r' '--'],'linewidth',lwid);
            end
            title ([saltype ': dash for upcast'])
            
            
            subplot(223)
            for ks = numused
                if oxy_end
                    kokd = find(dpsal{ks}.scan > ddcs{ks}.scan_start & dpsal{ks}.scan < ddcs{ks}.scan_bot);
                    koku = find(dpsal{ks}.scan > ddcs{ks}.scan_bot & dpsal{ks}.scan < ddcs{ks}.scan_end-oxy_align*24);
                else
                    kokd = find(dpsal{ks}.scan > ddcs{ks}.scan_start & dpsal{ks}.scan < ddcs{ks}.scan_bot);
                    koku = find(dpsal{ks}.scan > ddcs{ks}.scan_bot & dpsal{ks}.scan < ddcs{ks}.scan_end);
                end
                od = dpsal{ks}.(oxyvars{1,2});
                plot(dpsal{ks}.press(kokd),od(kokd),['k' '-'],'linewidth',lwid);
                hold on; grid on;
                plot(dpsal{ks}.press(koku),od(koku),['k' '--'],'linewidth',lwid);
                if nox>1
                    od = dpsal{ks}.(oxyvars{2,2});
                    plot(dpsal{ks}.press(kokd),od(kokd),['r' '-'],'linewidth',lwid);
                    plot(dpsal{ks}.press(koku),od(koku),['r' '--'],'linewidth',lwid);
                end
            end
            title ('oxygen: dash for upcast')
            
            
            subplot(224)
            for ks = numused
                kokd = find(dpsal{ks}.scan > ddcs{ks}.scan_start & dpsal{ks}.scan < ddcs{ks}.scan_bot);
                koku = find(dpsal{ks}.scan > ddcs{ks}.scan_bot & dpsal{ks}.scan < ddcs{ks}.scan_end);
                sd = dpsal{ks}.([saltype '1']);
                plot(sd(kokd),dpsal{ks}.temp1(kokd),['k' '-'],'linewidth',lwid);
                hold on; grid on;
                plot(sd(koku),dpsal{ks}.temp1(koku),['k' '--'],'linewidth',lwid);
                sd = dpsal{ks}.([saltype '2']);
                plot(sd(kokd),dpsal{ks}.temp2(kokd),['r' '-'],'linewidth',lwid);
                plot(sd(koku),dpsal{ks}.temp2(koku),['r' '--'],'linewidth',lwid);
            end
            title (['theta-' saltype ': dash for upcast'])
            
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
            
            if sum(~isnan(d2up{ks}.press))>1
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
                    upintrp = interp1(d2up{ks}.press,d2up{ks}.([saltype '1']),d2db{ks}.press);
                    plot(d2db{ks}.press, upintrp-d2db{ks}.([saltype '1']),['k' '-'],'linewidth',lwid);
                    hold on; grid on;
                end
                title ([saltype '1 up minus down diff']);
                
                
                subplot(324)
                for ks = numused
                    upintrp = interp1(d2up{ks}.press,d2up{ks}.([saltype '2']),d2db{ks}.press);
                    plot(d2db{ks}.press, upintrp-d2db{ks}.([saltype '2']),['k' '-'],'linewidth',lwid);
                    hold on; grid on;
                end
                title ([saltype '2 up minus down diff']);
                
                
                subplot(325)
                for ks = numused
                    upintrp = interp1(d2up{ks}.press,d2up{ks}.(oxyvars{1,2}),d2db{ks}.press);
                    plot(d2db{ks}.press, upintrp-d2db{ks}.(oxyvars{1,2}),['k' '-'],'linewidth',lwid);
                    hold on; grid on;
                end
                title ('oxygen 1 up minus down diff');
                
                subplot(326)
                if nox>1
                    for ks = numused
                        upintrp = interp1(d2up{ks}.press,d2up{ks}.(oxyvars{2,2}),d2db{ks}.press);
                        plot(d2db{ks}.press, upintrp-d2db{ks}.(oxyvars{2,2}),['k' '-'],'linewidth',lwid);
                        hold on; grid on;
                    end
                    title ('oxygen 2 up minus down diff');
                end
            end
            
        case 10
            
            % figure 110
            % 1hz primary and secondary difference
            figure(110); clf
            axes('position',pos_title);
            titstr = {
                ['Station ' sprintf('%03d',sused(end)) ' (' cols(end) ') primary minus secondary - 1hz'];
                };
            h = text(.5,.5,titstr); hold on
            set(h,'HorizontalAlignment','center','VerticalAlignment','middle');
            for ks = 1:numused
                iic = ks+length(lcolors)-numused;
                text((ks-numused/2)/numused*.4+.45,0,sprintf('%03d ',sused(ks)),'color',lcolors(iic,:));
            end
            axis([0 1 -.2 1]); axis off
            
            for ks = 1:numused
                iic = ks+length(lcolors)-numused;
                
                subplot(321)
                kok = find(dpsal{ks}.scan > ddcs{ks}.scan_start & dpsal{ks}.scan < ddcs{ks}.scan_end);
                kmid = find(dpsal{ks}.scan < ddcs{ks}.scan_bot, 1, 'last' );
                plot((dpsal{ks}.time(kok)-dpsal{ks}.time(kmid))/60,dpsal{ks}.temp1(kok)-dpsal{ks}.temp2(kok),[cols(ks) '-'],'linewidth',lwid);
                hold on
                
                subplot(322) %repeat with forced axes
                kok = find(dpsal{ks}.scan > ddcs{ks}.scan_start & dpsal{ks}.scan < ddcs{ks}.scan_end);
                kmid = find(dpsal{ks}.scan < ddcs{ks}.scan_bot, 1, 'last' );
                plot((dpsal{ks}.time(kok)-dpsal{ks}.time(kmid))/60,dpsal{ks}.temp1(kok)-dpsal{ks}.temp2(kok),[cols(ks) '-'],'linewidth',lwid);
                hold on
                
                subplot(323)
                kok = find(dpsal{ks}.scan > ddcs{ks}.scan_start & dpsal{ks}.scan < ddcs{ks}.scan_end);
                kmid = find(dpsal{ks}.scan < ddcs{ks}.scan_bot, 1, 'last' );
                sd1 = dpsal{ks}.([saltype '1']); sd2 = dpsal{ks}.([saltype '2']);
                plot((dpsal{ks}.time(kok)-dpsal{ks}.time(kmid))/60,sd1(kok)-sd2(kok),[cols(ks) '-'],'linewidth',lwid);
                hold on
                
                subplot(324) %zoomed version of above
                kok = find(dpsal{ks}.scan > ddcs{ks}.scan_start & dpsal{ks}.scan < ddcs{ks}.scan_end);
                kmid = find(dpsal{ks}.scan < ddcs{ks}.scan_bot, 1, 'last' );
                sd1 = dpsal{ks}.([saltype '1']); sd2 = dpsal{ks}.([saltype '2']);
                plot((dpsal{ks}.time(kok)-dpsal{ks}.time(kmid))/60,sd1(kok)-sd2(kok),[cols(ks) '-'],'linewidth',lwid);
                hold on
                
                if oxy_end
                    kok = find(dpsal{ks}.scan > ddcs{ks}.scan_start & dpsal{ks}.scan < ddcs{ks}.scan_end-oxy_align*24);
                end
                if nox>1
                    subplot(325)
                    kmid = find(dpsal{ks}.scan < ddcs{ks}.scan_bot, 1, 'last' );
                    od1 = dpsal{ks}.(oxyvars{1,2}); od2 = dpsal{ks}.(oxyvars{2,2});
                    plot((dpsal{ks}.time(kok)-dpsal{ks}.time(kmid))/60,od1(kok)-od2(kok),[cols(ks) '-'],'linewidth',lwid);
                    hold on
                    
                    subplot(326) %zoomed version of above
                    kmid = find(dpsal{ks}.scan < ddcs{ks}.scan_bot, 1, 'last' );
                    od1 = dpsal{ks}.(oxyvars{1,2}); od2 = dpsal{ks}.(oxyvars{2,2});
                    plot((dpsal{ks}.time(kok)-dpsal{ks}.time(kmid))/60,od1(kok)-od2(kok),[cols(ks) '-'],'linewidth',lwid);
                    hold on; grid on;
                end
                
            end
            subplot(321); grid on; title ('temp diff'); xlabel('minutes away from bottom');
            subplot(322); grid on; title ('temp diff'); xlabel('minutes away from bottom');
            axoff = m_nanmedian(dpsal{ks}.temp1(kok)-dpsal{ks}.temp2(kok)); % bak on jr302 17 jun 2014; centre axes on data if out of range
            if abs(axoff)>0.004 || isnan(axoff); axoff = 0; end
            ax = axis; ax(3:4) = [-0.005 0.005]+axoff; axis(ax);
            subplot(323); grid on; title ([saltype ' diff']); xlabel('minutes away from bottom');
            subplot(324); grid on; title ([saltype ' diff']); xlabel('minutes away from bottom');
            axoff = m_nanmedian(sd1(kok)-sd2(kok)); % bak on jr302 17 jun 2014; centre axes on data if out of range
            if abs(axoff)<0.004 || isnan(axoff); axoff = 0; end
            ax = axis; ax(3:4) = [-0.005 0.005]+axoff; axis(ax);
            if nox>1
                subplot(325); grid on; title ('oxy diff'); xlabel('minutes away from bottom');
                subplot(326); grid on; title ('oxy diff'); xlabel('minutes away from bottom');
                axoff = m_nanmedian(od1(kok)-od2(kok));
                if abs(axoff)<15 || isnan(axoff); axoff = 0; end
                ax = axis; ax(3:4) = [-20 20]+axoff; axis(ax);
            end
            
    end
end

clear klist
