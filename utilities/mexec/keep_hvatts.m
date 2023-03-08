function hnew = keep_hvatts(hnew, h)
% transfer variable attributes besides fldnam and fldunt from h to hnew
% using fldnam to match

hf = fieldnames(h);
hf = hf(strncmp('fld',hf,3));
hf = setdiff(hf,{'fldnam' 'fldunt'});

if ~isempty(hf)
    [~,ia,ib] = intersect(hnew.fldnam,h.fldnam);
    for fno = 1:length(hf)
        if ~isfield(hnew,hf{fno})
            hnew.(hf{fno}) = repmat({' '},size(hnew.fldnam));
%         elseif ~isempty(hnew.(hf{fno}))
%             warning('may overwrite %s',hf{fno})
        end
        hnew.(hf{fno})(ia) = h.(hf{fno})(ib);
    end
end
