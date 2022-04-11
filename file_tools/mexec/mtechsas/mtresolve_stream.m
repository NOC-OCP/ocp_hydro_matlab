function tstream = mtresolve_stream(instream)
% function tstream = mtresolve_stream(instream)
%
% check whether the instream argument is an mexec short name
% for a longer techsas stream name. If yes, return the matching techsas name
% If no match is found, return the instream as the output.
%
% The correspondence table is set up in script mtnames

names = mtnames;

mn = names(:,1);
tn = names(:,3);

% hunt for mexec short name

k = strmatch(instream,mn,'exact');

if isempty(k)
    % no match, so return the input name
    tstream = instream;
else
    tstream = tn{k(1)};
end