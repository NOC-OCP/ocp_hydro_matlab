function tstreams = msgetstreams
% function tstreams = msgetstreams
%
% first draft BAK JC032
% 
% mstar scs (mt) routine; requires mexec to be set up
%
% The scs files are searched for in a directory MEXEC_G.uway_root defined in
% the mexec setup. At sea, this will typically be a data area exported from a
% ship's computer and cross-mounted on the mexec processing machine
%
% This function searches for the unique set of scs streams in the
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
% for example.
%
% 2009-09-22 fixed at noc to work with either standard (comma delimited) or 
% sed-revised (space delimited) ACO files

m_common

% some users like to alias ls to have options that return extra chars at the
% end of file names
opt1 = 'ship'; opt2 = 'datasys_best'; get_cropt
[MEXEC.status result] = unix(['/bin/ls -1 ' uway_sed '/*ACO']);

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
streams = cell(1,nfiles);

for kf = 1:length(fnames) % sort out all the filenames
    fn = fnames{kf};
%     streams{kf} = fn(17:end);
    streams{kf} = fn(length(MEXEC_G.uway_sed)+2:end-4); %list seems to generate full path names
end

[ustreams ui uj] = unique(streams); % unique file/instrument streams

tstreams = ustreams(:);

return