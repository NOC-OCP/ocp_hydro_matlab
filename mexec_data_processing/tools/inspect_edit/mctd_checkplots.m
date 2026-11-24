function mctd_checkplots(stn, varargin)
%
% mctd_checkplots(stn, prev_stns)
% mctd_checkplots(stn, prev_stns, 'quick')
% 
% Makes a set of plots for checking issues with and corrections needed for
% CTDO dataa, using both 1 hz time series and more smoothed profiles. Data
% are truncated using the dcs (ctd_castcut) start and end of cast. 
%
% Second input argument sets the other stations to plot for comparison. If
% a scalar (including 0), plot that many immediately previous stations. If
% a vector, plot those stations. Stations that do not have a complete set 
% of files are skipped. 
%
% Optional third input argument is 'quick' to use the 10s averaged files
% (interpolating to 2 dbar) in place of 2 dbar down and upcast files, which 
% may not have been created yet.  
%
% plots are as follows
%
% theta, S, O vs pressure, theta-S, and theta-O for this and other 
% requested stations
%   Figure 102: CTD1, averaged downcast
%   Figure 103: CTD2, averaged downcast
%   Figure 104: CTD1, 1 hz, downcast solid and upcast dashed
%   Figure 105: CTD2, 1 hz, downcast solid and upcast dashed
% useful for highlighting sensor changes
% 
% theta, S, O vs pressure, theta-S, and theta-O for this station with
% down and upcast on the same plots
%   Figure 106: CTD1 and CTD2, averaged downcast
%   Figure 107: CTD1 and CTD2, averaged upcast
% useful for oxygen alignment and hysteresis as well as highlighting sensor
% steps/problems 
%
% theta, S, O vs pressure, theta-S, and theta-O for this station with
% primary and secondary on the same plots
%   Figure 108: CTD1 and CTD2, averaged downcast
%   Figure 109: CTD1 and CTD2, averaged upcast
% useful for oxygen alignment and hysteresis as well as highlighting sensor
% steps/problems 
%
% differences in theta, S, O for this station
%   Figure 108: up minus down cast, 2 dbar. useful for oxygen hysteresis. 
%   Figure 109: primary minus secondary, 1 hz. useful for sensor steps. 
%
% differences in theta, S, O for all requested stations
%   Figure 110: primary minus secondary, 1 hz. useful for sensor steps and
%   drifts. 
%
%

m_common
if MEXEC_G.quiet<=1; fprintf(1,'plotting CTD dataa from station %s along with dataa from selected previous stations',stn_string);end

quick = 0; %whether to use 10 hz (quick) or 2 dbar
if nargin>1
    nump = varargin{1};
    if nargin>2
        quick = varargin{2};
    end
else
    msg1 = '\n Type number of previous stations to view, a list of at least two station numbers, or return to quit\n';
    nump = input(msg1);
end

if numel(nump)>1
    slist = nump; 
elseif isscalar(nump)
    slist = stn+(-nump:-1);
    slist(slist<0) = []; % bak en705 19 july 2023 : allow station number zero
else
    disp('you should reply with a single number or a vector')
    return
end
clear nump msg1

opt1 = 'setup'; opt2 = 'pfiles'; run(MEXEC_G.opt_cruise) %
opt1 = 'ctd_proc'; opt2 = 'ctd_checkplots'; run(MEXEC_G.opt_cruise) %saltype
opt1 = 'ctd_proc'; opt2 = 'ctd_infiles'; run(MEXEC_G.opt_cruise) %raw resolution

% load data
klist = [slist(:)' stn];
sused = false(size(klist));
d2dn = cell(1,length(klist));
d2up = d2dn; d1 = d2dn; dc = d2dn;
stn0 = stn; 
for no = 1:length(klist)
    stn = klist(no);
    opt1 = 'setup'; opt2 = 'm_stn_string'; run(MEXEC_G.opt_cruise);
    found = true; done = false;
    while found & ~done
        [dc,~,found] = load_if_found(replace(pfiles.ctd_castcut,'stn_string',stn_string));
        sb = [dc.scan_start, dc.scan_bot, dc.scan_end];
        [d,~,found] = load_if_found(replace(pfiles.ctd_1hz,'stn_string',stn_string));
        [d1dn{no}, d1up{no}] = cast_split(d, sb);
        if quick
            [d,~,found] = load_if_found(replace(pfiles.ctd_10s,'stn_string',stn_string));
            [d2dn{no}, d2up{no}] = cast_split(d, sb);
        else
            [d2dn{no},~,found] = load_if_found(replace(pfiles.ctd_2db_dn,'stn_string',stn_string));
            [d2up{no},~,found] = load_if_found(replace(pfiles.ctd_2db_dn,'stn_string',stn_string));
        end
        done = true;
    end
    if found
        sused(no) = 1;
    elseif stn==stn0
        fprintf(2,'station %d was not loaded (check all files are available); exiting',stn)
        return
    else
        warning('skipping additional station %d',stn)
        continue
    end
end
d1dn = d1dn(sused); d1up = d1up(sused);
d2dn = d2dn(sused); d2up = d2up(sused);
klist = klist(sused);
nstn = length(klist);
stn = stn0;

lcolors = [0 0 1; 0 .8 0; .85 0 .85; 0 1 1; 1 0 0; 0 0 0];
if nstn>size(lcolors,1)
    lcolors = [repmat([.5 .5 .5],nstn-size(lcolors,1),1); lcolors];
elseif nstn<size(lcolors,1)
    lcolors = lcolors(end-nstn+1:end,:);
end
if quick
    avstr = '10s';
else
    avstr = '2dbar';
end

% which plots
%close all
if exist('ctd_cklist','var')
    cklist = ctd_cklist;
else
    cklist = 102:109;
end
cklist = cklist(:)'; % force to row

for plotlist = cklist
    
    figure(plotlist); clf
    switch plotlist

        case 102
            % avgd primary downcast, compare stations, test station last
            plot_multistations(['primary ' avstr ' down'], klist, lcolors, d2dn, [], saltype, 'oxy', 1)

        case 103
            % avgd secondary downcast, compare stations, test station last
            plot_multistations(['secondary ' avstr ' down'], klist, lcolors, d2dn, [], saltype, 'oxy', 2)

        case 104
            % 1hz primary, compare stations, test station last
            plot_multistations('primary 1 hz down (-) and up (--)', klist, lcolors, d1dn, d1up, saltype, 'oxy', 1)

        case 105
            % 1hz secondary, compare stations, test station last
            plot_multistations('secondary 1 hz down (-) and up (--)', klist, lcolors, d1dn, d1up, saltype, 'oxy', 2)

        case 106
            % avgd primary, compare stations, test station last
            plot_multistations(['primary ' avstr ' down (-) and up (--)'], klist, lcolors, d2dn, d2up, saltype, 'oxy', 1)

        case 107
            % avgd secondary, compare stations, test station last
            plot_multistations(['secondary ' avstr ' down (-) and up (--)'], klist, lcolors, d2dn, d2up, saltype, 'oxy', 2)

        case 108
            % avgd downcast primary and secondary, test station
            plot_multistations([avstr ' down primary (-) and secondary (--)'], klist(end), lcolors(end,:), d2dn(end), [], saltype, 'oxy', [1 2])

        case 109
            % avgd upcast primary and secondary, test station
            plot_multistations([avstr ' up primary (-) and secondary (--)'], klist(end), lcolors(end,:), d2up(end), [], saltype, 'oxy', [1 2])
            
        case 110
            % avgd up-down differences, vs pressure, test station last
            plot_diffs('1 hz up minus down, primary (-) and secondary (--)', klist(end), lcolors, saltype, 'oxy', d1dn(end), d1up(end), 'press', 'ud');
        
        case 111
            % avgd primary-secondary differences, vs pressure, test station
            % last
            plot_diffs('1 hz primary minus secondary, down (-) and upcast (--)', klist(end), lcolors, saltype, 'oxy', d1dn(end), d1up(end), 'press', 'ps');

        case 112
            % avgd up-down differences, vs time from bottom, test station last
            plot_diffs('1 hz up minus down, primary (-) and secondary (--)', klist(end), lcolors, saltype, 'oxy', d1dn(end), d1up(end), 'tab', 'ud');
        
        case 113
            % avgd primary-secondary differences, vs time from bottom, test station
            % last
            plot_diffs('1 hz primary minus secondary, down (-) and upcast (--)', klist(end), lcolors, saltype, 'oxy', d1dn(end), d1up(end), 'tab', 'ps');
            
    end
end

clear klist


function [d, h, found] = load_if_found(infile)

if exist(infile,'file')
    [d, h] = mload(infile,'/');
    found = true;
else
    d = []; h = [];
    found = false;
    warning('%s not found; skipping',infile)
end


function plot_multistations(titstr, klist, lcolors, data, datb, saltype, oxypre, sensnum)

if length(sensnum)==2 && isempty(datb)
    if isempty(datb)
        datb = data;
        sensb = sensnum(2); sensnum = sensnum(1);
    end
end

[nstn, lwid] = over_title(titstr, klist, lcolors);

%plot data
ss = num2str(sensnum);
for ks = 1:nstn
    subplot(231)
    plot(data{ks}.(['temp' ss]),-data{ks}.press,'linewidth',lwid,'color',lcolors(ks,:)); 
    hold on
    subplot(232)
    plot(data{ks}.([saltype ss]),-data{ks}.press,'linewidth',lwid,'color',lcolors(ks,:));
    hold on
    subplot(223)
    plot(data{ks}.([saltype ss]),data{ks}.(['potemp' ss]),'linewidth',lwid,'color',lcolors(ks,:));
    hold on
end
if isfield(data{1},[oxypre ss])
    for ks = 1:nstn
        subplot(233)
        plot(data{ks}.([oxypre ss]),-data{ks}.press,'linewidth',lwid,'color',lcolors(ks,:));
        hold on
        subplot(224)
        plot(data{ks}.([oxypre ss]),data{ks}.(['potemp' ss]),'linewidth',lwid,'color',lcolors(ks,:));
        hold on
    end
end

if ~isempty(datb)
    %add datb on top
    if exist('sensb','var')
        ss = num2str(sensb);
    end
    for ks = 1:nstn
        subplot(231)
        plot(datb{ks}.(['temp' ss]),-datb{ks}.press,'--','linewidth',lwid,'color',lcolors(ks,:));
        hold on
        subplot(232)
        plot(datb{ks}.([saltype ss]),-datb{ks}.press,'--','linewidth',lwid,'color',lcolors(ks,:));
        hold on
        subplot(223)
        plot(datb{ks}.([saltype ss]),datb{ks}.(['potemp' ss]),'--','linewidth',lwid,'color',lcolors(ks,:));
        hold on
    end
    if isfield(datb{1},[oxypre ss])
        for ks = 1:nstn
            subplot(233)
            plot(datb{ks}.([oxypre ss]),-datb{ks}.press,'--','linewidth',lwid,'color',lcolors(ks,:));
            hold on
            subplot(224)
            plot(datb{ks}.([oxypre ss]),datb{ks}.(['potemp' ss]),'--','linewidth',lwid,'color',lcolors(ks,:));
            hold on
        end
    end
end

subplot(231); grid on; title('temp'),ylabel('temp'),xlabel('-press')
subplot(232); grid on; title(saltype),ylabel(saltype),xlabel('-press')
subplot(223); grid on; title (['potemp-' saltype]),ylabel('potemp'),xlabel(saltype)
subplot(233); grid on; title ('oxy'),ylabel('oxy'),xlabel('-press')
subplot(224); grid on; title (['potemp-' oxypre]),ylabel('potemp'),xlabel(oxypre)

function plot_diffs(titstr, klist, lcolors, saltype, oxypre, data, datb, xvar, dtyp)

[nstn, lwid] = over_title(titstr, klist, lcolors);
if strcmp(xvar,'tfb')
    %time from bottom
    [~,ii] = max(data.press); ii = ii(1);
    data.tfb = abs(data.time-data.time(ii));
    [~,ii] = max(datb.press); ii = ii(1);
    datb.tfb = abs(datb.time-datb.time(ii));
end

vars = {'temp','potemp',saltype,oxypre};
switch dtyp
    case 'ps'
        for no = 1:length(vars)
            da.(vars{no}) = data.([vars{no} '1'])-data.([vars{no} '2']);
            db.(vars{no}) = datb.([vars{no} '1'])-datb.([vars{no} '2']);
        end
    case 'ud'
        for no = 1:length(vars)
            da.(vars{no}) = interp1(datb.(xvar),datb.([vars{no} '1']),data.(xvar))-data.([vars{no} '1']);
            if isfield(data,[vars{no} '2'])
                db.(vars{no}) = interp1(datb.(xvar),datb.([vars{no} '2']),data.(xvar))-data.([vars{no} '2']);
            end
        end
end


function [nstn, lwid] = over_title(titstr, klist, lcolors)

pos_title = [.05 .93 .9 .06];
lwid = 1;
axes('position',pos_title);
h = text(.5,.7,titstr); hold on
set(h,'HorizontalAlignment','center','VerticalAlignment','middle');
nstn = length(klist);
if nstn>1
    text(.1,.3,'stns')
    for no = 1:nstn
        text(.1+.6*no/nstn,.3,sprintf('%03d',klist(no)),'color',lcolors(no,:))
    end
else
    text(.1,.3,sprintf('stn %03d',klist),'color',lcolors)
end
axis([0 1 -.2 1]); axis off
