function m_print_comments(h)
% function m_print_comments(h)
%
% print comments from header h out to screen


c = h.comment;
delim = h.comment_delimiter_string;
h.comment_delimiter_string = delim;
delimindex = strfind(c,delim);
ncoms = length(delimindex);
for k = 2:ncoms %if there are no genuine comments ncoms will be 1 and this loop won't be executed
    disp(['comment: ' sprintf('%s',c(delimindex(k-1)+length(delim):delimindex(k)-1))]);
end
