function rescale
% function rescale(nsubs)

nsubs = length(get(gcf,'children')); % try to get number of subplots by interrogating figure

% To rescale vertical axes of bottle_inspection.m
% must give number of subplots as argument

ax = axis; % get axes of present subplot

for kloop = 1:nsubs
    subplot(1,nsubs,kloop);

    ax1 = axis;
    axis([ax1(1) ax1(2) ax(3) ax(4)]);


end