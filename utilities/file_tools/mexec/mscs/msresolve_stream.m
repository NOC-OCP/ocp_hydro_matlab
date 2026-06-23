function tstream = msresolve_stream(instream)
% function tstream = msresolve_stream(instream)
%
% check whether the instream argument is an mexec short name
% for a longer techsas stream name. If yes, return the matching techsas name
% If no match is found, return the instream as the output.
%
% The correspondence table is set up in script mtnames
%
% 8 Sep 2009: SCS version of original techsas script, for JR195

names = msnames;

mn = names(:,1);
tn = names(:,3);

% hunt for mexec short name

k = strcmp(mn,instream);

if ~sum(k)
    % no match, so return the input name
    tstream = instream;
else
    ii = find(k);
    tstream = tn{ii(1)};
end