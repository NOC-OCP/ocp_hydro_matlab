function mtlookd(arg)
% function mtlookd(arg)
%
% All streams in the techsas directory are scanned, and mtdfinfo is used
% to produce a summary of earliest and latest data for each stream.
%
% The one possible argument is the character string 'f' or 'fast'
% in which case the number of data cycles is not counted.
% 
% mstar techsas (mt) routine; requires mexec to be set up
%
% The techsas files are searched for in a directory MEXEC_G.uway_root defined in
% the mexec setup. At sea, this will typically be a data area exported from a
% ship's computer and cross-mounted on the mexec processing machine
%
% first draft BAK JC032
%

if nargin == 0; arg = ' '; end
tonly = ' ';
if strncmp(arg,'f',1); tonly = 'f'; end % set the tonly flag to f (fast); Otherwise it remains as ' '.

tstreams = mtgetstreams;

for k = 1:length(tstreams)
    mtdfinfo(tstreams{k},tonly)
end