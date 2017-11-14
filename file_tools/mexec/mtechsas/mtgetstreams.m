function tstreams = mtgetstreams
% function tstreams = mtgetstreams
%
% first draft BAK JC032
% 
% mstar techsas (mt) routine; requires mexec to be set up
%
% The techsas files are searched for in a directory MEXEC_G.uway_root defined in
% the mexec setup. At sea, this will typically be a data area exported from a
% ship's computer and cross-mounted on the mexec processing machine
%
% This function searches for the unique set of techsas streams in the
% MEXEC_G.uway_root directory
%
% Each tstream is the part of the techsas filename that does not include the
% date; ie the first 16 chars have been removed; eg
% 20090318-235958-SBE-SBE45.TSG
% becomes SBE-SBE45.TSG
%
m_common

% some users like to alias ls to have options that return extra chars at the
% end of file names
[MEXEC.status result] = unix(['/bin/ls -1 ' MEXEC_G.uway_root]);

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
    streams{kf} = fn(17:end);
end

[ustreams ui uj] = unique(streams); % unique file/instrument streams

tstreams = ustreams(:);

return