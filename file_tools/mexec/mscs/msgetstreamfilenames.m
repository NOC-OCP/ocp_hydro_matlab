function matnames = msgetstreamfilenames(instream)
% function matnames = msgetstreamfilenames(instream)
%
% first draft BAK JC032
%
% mstar scs (mt) routine; requires mexec to be set up
%
% The scs files are searched for in a directory MEXEC_G.uway_root defined in
% the mexec setup. At sea, this will typically be a data area exported from a
% ship's computer and cross-mounted on the mexec processing machine
%
% This function searches for the set of scs files whose name matches
% the stream name provided in the argument. The search takes place in the
% MEXEC_G.uway_root directory
%
% Each tstream is the part of the scs filename that does not include the
% date; ie the first 16 chars have been removed; eg
% 20090318-235958-SBE-SBE45.TSG
% becomes SBE-SBE45.TSG
%
% 8 Sep 2009: SCS version of original techsas script, for JR195
% The searched directory is MEXEC_G.uway_root, which for example can be
% /data/cruise/jcr/20090310/scs_copy/Compress
% The var names and units are taken from ascii file
% seatex-gga.TPL
% The data file would then be 
% seatex-gga.ACO
% for example.
% There is only one scs file expected, but this routine keeps its place
% for convenience of adapting the techsas software.
% Also, the scs Raw directory contains data split over several files
%
% 2009-09-22 fixed at noc to work with either standard (comma delimited) or 
% sed-revised (space delimited) ACO files

m_common
tstream = msresolve_stream(instream);

% some users like to alias ls to have options that return extra chars at the
% end of file names
[MEXEC.status result] = unix(['/bin/ls -1 ' MEXEC_G.uway_sed '/' tstream '.ACO']);

snl = sprintf('\n');
scr = sprintf('\r');

% unpack the result which seems to be returned as a single string
% containing (on unix) newline chars.

delim = snl; % delimeter of unix result seems to be newline on nosea1 (linux) on jc032

kd = strfind(result,delim);
kfiles = 0;
clear fnames

while length(kd) > 0
    kfiles = kfiles+1;
    fnames{kfiles} = result(1:kd(1)-1);
    result(1:kd(1)) = [];
    kd = strfind(result,delim);
end

nfiles = length(fnames);
allstreams = cell(1,nfiles);
filenames = allstreams;

for kf = 1:length(fnames) % sort out all the filenames
    fn = fnames{kf};
    slashind = strfind(fn,'/'); % remove anything up to and including the last slash
    if ~isempty(slashind); fn = fn(slashind(end)+1:end); end
%     allstreams{kf} = fn(17:end); % line of code from techsas, in which
%     date occurs at start of file name
    allstreams{kf} = fn(1:end-4); % truncate '.ACO' form end of file
    filenames{kf} = fn;
end

kmatch = strmatch(tstream,allstreams);
matnames = filenames(kmatch);
matnames = matnames(:);

return
