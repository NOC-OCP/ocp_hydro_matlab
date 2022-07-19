function rescale(nsubs)
% function rescale(nsubs)

nsubs = length(get(gcf,'children')); % try to get number of subplots by interrogating figure

% To rescale vertical axes of bottle_inspection.m
% must give number of subplots as argument

ax = axis; % get axes of present subplot

% nsubs = nsubs -1; % bak jc191. The legend is a child of the gcf, so the number of subplots is one less than the number of children.
%  The legend is sometimes but not always present, so I couldn't figure out
%  an automatic way to know how many subplots there are, so the number of
%  subs has to be declared as an argument.

for kloop = 1:nsubs
    subplot(1,nsubs,kloop);

    ax1 = axis;
    axis([ax1(1) ax1(2) ax(3) ax(4)]);


end
