function mslookd(arg)
% function mslookd(arg)
%
% All streams in the scs directory are scanned, and mtdfinfo is used
% to produce a summary of earliest and latest data for each stream.
%
% The one possible argument is the character string 'f' or 'fast'
% in which case the number of data cycles is not counted.
% 
% mstar scs (mt) routine; requires mexec to be set up
%
% The scs files are searched for in a directory uway_root defined in
% cruise options. At sea, this will typically be a data area exported from a
% ship's computer and cross-mounted on the mexec processing machine
%
% first draft BAK JC032
%
%
% 8 Sep 2009: SCS version of original techsas script, for JR195
% The searched directory is uway_root, which for example can be
% /data/cruise/jcr/20090310/scs_copy/Compress
% The var names and units are taken from ascii file
% seatex-gga.TPL
% for example.

m_common

if nargin == 0; arg = ' '; end
tonly = ' ';
if strncmp(arg,'f',1) % set the tonly flag to f (fast); Otherwise it remains as ' '.
    tonly = 'f'; 
else
    m = ' Counting the number of data cycles in each file ';
    m3 = ' takes a long time when the number of lines is large';
    m2 = ' If you only want the times use "mslookd(''f'')" or "mslookd f"';
    fprintf(MEXEC_A.Mfidterm,'%s\n',m,m3,' ',m2,' ');
end 

% tstreams = msgetstreams;
% bak for jr195 17 Sep 2009.
% use msnames instead of msgetstreams, because we want to avoid some names.
% in particular, seatex-psxn has some formatting problems.
allnames = msnames;
numstreams = size(allnames,1);
tstreams = cell(numstreams,1);
for kloop = 1:numstreams;
    tstreams{kloop} = allnames{kloop,3};
end
    

for k = 1:length(tstreams)
    msdfinfo(tstreams{k},tonly)
end