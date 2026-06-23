function [d, h] = uway_edit_by_day(d, h, edfile, ddays, btol, vars_to_ed)
% apply previously selected edits then loop through days to choose new
% edits by hand

%apply previous manually selected edits
[d, ~] = apply_guiedits(d, 'dday', [edfile '*'], 0, btol);

if ~feature('ShowFigureWindows')
   warning('no display available to run GUI data editor; skipping')
   return
end

%choose new ones
edgrp_all = {};
for no = 1:length(ddays)
    ii = find(d.dday>=ddays(no)-1/24 & d.dday<=ddays(no)+1+1/24);
    if ~isempty(ii)
        edgrp_all = [edgrp_all; ii];
    end
end
fn = setdiff(fieldnames(d),[vars_to_ed 'dday']);
de = d; de = rmfield(de, setdiff(fn,vars_to_ed));
bads = gui_editpoints(de, 'dday', 'edfilepat', edfile, 'xgroups', edgrp_all);

%and apply them again
[d, comment] = apply_guiedits(d, 'dday', [edfile '*'], 0, btol);
if ~isempty(comment)
    h.comment = [h.comment comment];
end

