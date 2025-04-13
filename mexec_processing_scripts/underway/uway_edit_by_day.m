function [d, h] = uway_edit_by_day(d, h, edfile, ddays, btol, vars_to_ed, varargin)
% [d, h] = uway_edit_by_day(d, h, edfile, ddays, btol, vars_to_ed)
% [d, h] = uway_edit_by_day(d, h, edfile, ddays, btol, vars_to_ed, vars_offset_scale)
%
% on mstar structures d and h, apply previously selected edits from file
% edfile, then loop through ddays (decimal days) to choose new edits by
% hand 
%
% btol specifies the precision for edits recorded in edfile (see
% apply_guiedits)
% 
% vars_to_ed is a cell array list of variables to plot
% optional vars_offset_scale is a matching cell array whose elements are
% [additive offset; scale factor] for each variable to make them fit in the
% same interval on the plot
% 
% called by mday_02_merge_av to NaN bad data, and by *** to produce list of
% points to flag (without NaNing)

%apply previous manually selected edits
[d, ~] = apply_guiedits(d, 'dday', [edfile '*'], 0, btol);

%choose new ones
edgrp_all = {};
for no = 1:length(ddays)
    ii = find(d.dday>=ddays(no)-1/24 & d.dday<=ddays(no)+1+1/24);
    if ~isempty(ii)
        edgrp_all = [edgrp_all; ii];
    end
end
fn = setdiff(fieldnames(d),[vars_to_ed 'dday']);
de = d; de = rmfield(de, setdiff(fn, vars_to_ed));
if nargin>6
    vars_offset_scale = varargin{1};
    %scale to plot multiple variables together
    de0 = de;
    for no = 1:length(vars_to_ed)
        de.(vars_to_ed{no}) = (de.(vars_to_ed{no})+vars_offset_scale{no}(1))*vars_offset_scale{no}(2);
    end
end
bads = gui_editpoints(de, 'dday', 'edfilepat', edfile, 'xgroups', edgrp_all);

%and apply them again
[d, comment] = apply_guiedits(d, 'dday', [edfile '*'], 0, btol);
if ~isempty(comment)
    h.comment = [h.comment comment];
end

