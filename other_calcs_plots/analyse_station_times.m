[d281 h281] = mload('dcs_jr281_all_pos','/');
[d069 h069] = mload('/local/users/pstar/jc069/data/ctd/dcs_jc069_pos_all','/');

n281 = length(d281.statnum);

d = d281;
n = n281;

ps = nan+ones(n,1);
pb = ps;
pe = ps;
t = nan(n,3); % 1 for down 2 for all 3 for up
pol = nan(3,3);
sparts = {'down' 'all' 'up'};
offsets = [15 30 15];

for ks = 1:n
    ps(ks) = d.press_start(ks);
    pb(ks) = d.press_bot(ks);
    pe(ks) = d.press_end(ks);
    if(ps(ks) > 50 | pe(ks) > 50); % not a full station
        t(ks,:) = nan;
    else
        t(ks,2) = (d.time_end(ks)-d.time_start(ks))/60; % time in minutes
        t(ks,3) = (d.time_end(ks)-d.time_bot(ks))/60; % time in minutes
        t(ks,1) = (d.time_bot(ks)-d.time_start(ks))/60; % time in minutes
    end
end

for kpart = 1:3
    tt = t(:,kpart);
    kok = find(~isnan(tt));
    pol(kpart,:)  = polyfit(pb(kok),tt(kok),2);
    tpred = polyval(pol(kpart,:),sort(pb));
    tresid = nanmean(tt-polyval(pol(kpart,:),pb));
    tstd = nanstd(tt-polyval(pol(kpart,:),pb));
    
    fignum = 100+kpart;
    figure(fignum)
    clf
    subplot(121)
    plot(pb,tt,'k+');
    hold on; grid on
    plot(sort(pb),tpred,'k-')
    plot(sort(pb),tpred+offsets(kpart),'k-')
end



n069 = length(d069.statnum);

d = d069;
n = n069;

ps = nan+ones(n,1);
pb = ps;
pe = ps;
t = nan(n,3); % 1 for down 2 for all 3 for up
for ks = 1:n
    ps(ks) = d.press_start(ks);
    pb(ks) = d.press_bot(ks);
    pe(ks) = d.press_end(ks);
    if(ps(ks) > 50 | pe(ks) > 50); % not a full station
        t(ks,:) = nan;
    else
        t(ks,2) = (d.time_end(ks)-d.time_start(ks))/60; % time in minutes
        t(ks,3) = (d.time_end(ks)-d.time_bot(ks))/60; % time in minutes
        t(ks,1) = (d.time_bot(ks)-d.time_start(ks))/60; % time in minutes
    end
end

for kpart = 1:3
    tt = t(:,kpart);
    
    fignum = 100+kpart;
    figure(fignum)
    
    plot(pb,tt,'r+');
    
    xlabel('max pressure (dbar)')
    ylabel('duration (minutes)')
    title({'jc069 (r)';'jr281 (k)';sparts{kpart}})
    
    kok = find(~isnan(tt));
    tpredc = polyval(pol(kpart,:),pb);
    tresidc = nanmedian(tt-tpredc)
    tstdc = nanstd(tt-tpredc);
    
    subplot(122)
    edges = [-100:5:200];
    nh = histc(tt-tpredc,edges);
    bar(edges,nh,'histc');
    ax = axis;
    ax(1:2) = [-20 120];
    axis(ax)
    grid on
    xlabel('minutes')
    title({'station time excess';'jc069 minus jr281';sparts{kpart}});
end

for kpart = 1:3
    fignum = 100+kpart;
    figure(fignum)
    
    fn = ['station_time_comparison_' sparts{kpart} '.ps'];
    cmd = ['print -dpsc ' fn]; eval(cmd);
end



