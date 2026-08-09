function [d, h] = uway_edit_by_day(d, h, edfile, ddays, btol, vars_to_ed, varargin)
% [d, h] = uway_edit_by_day(d, h, edfile, ddays, btol, vars_to_ed)
% [d, h] = uway_edit_by_day(d, h, edfile, ddays, btol, vars_to_ed, yl)
%
% on mstar structures d and h, apply previously selected edits from file
% edfile, then loop through ddays (decimal days) to choose new edits by
% hand 
%
% btol specifies the precision for edits recorded in edfile (see
% apply_guiedits)
% 
% vars_to_ed is a cell array list of variables to plot
% optional yl is a structure with the same members as vars_to_ed giving
% upper and lower limits for plotting each variable
% 
% called by mday_01_edit and mday_02_merge_av to NaN bad data, and by
% mctd_raw_show_check_edit to produce list of bad points to NaN later
% 
% points to flag (without NaNing)***

%apply previous manually selected edits
flag = 0; %NaN them
[d, ~] = apply_guiedits(d, 'dday', [edfile '*'], 0, btol, flag);

%choose new ones
edgrp_all = {};
for no = 1:length(ddays)
    ii = find(d.dday>=ddays(no)-1/24 & d.dday<=ddays(no)+1+1/24);
    if ~isempty(ii)
        edgrp_all = [edgrp_all; ii];
    end
end
dt = struct2table(d);
if nargin>6
    yl = varargin{1};
else
    yl = [];
end
bads = gui_editpoints(dt, 'dday', edgrp_all, [], 'edfilepre', edfile, 'yl', yl);

%and apply them again
[d, comment] = apply_guiedits(d, 'dday', [edfile '*'], 0, btol);
if ~isempty(comment)
    h.comment = [h.comment comment];
end

