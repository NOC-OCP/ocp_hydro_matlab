function [matnames, varargout] = msgetstreamfilenames(instream,suf)
% function matnames = msgetstreamfilenames(instream,suf)
% function [matnames, result] = msgetstreamfilenames(instream,suf)
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
opt1 = 'ship'; opt2 = 'datasys_best'; get_cropt
[MEXEC.status, result] = unix(['/bin/ls -1 ' uway_sed '/' tstream suf]);
if MEXEC.status || contains(result, 'No such')
    tstream1 = replace(tstream,'_','-');
    [MEXEC.status, result] = unix(['/bin/ls -1 ' uway_sed '/' tstream1 suf]); %***temporary?
else
    tstream1 = tstream;
end
if nargout>1
    varargout{1} = result;
end
if MEXEC.status
    m = 'There appears to be a problem in msvars';
    m2 = result;
    fprintf(MEXEC_A.Mfider,'%s\n',' ',m,m2,' ')
    return
end

% unpack the result which seems to be returned as a single string
% containing (on unix) newline chars.
delim = newline; % delimeter of unix result seems to be newline on nosea1 (linux) on jc032

kd = strfind(result,delim);
kfiles = 0;
clear fnames

while ~isempty(kd)
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
    allstreams{kf} = fn(1:end-4); % truncate '.ACO' form end of file
    filenames{kf} = fn;
end

kmatch = strncmp(allstreams,tstream1,length(tstream));
matnames = filenames(kmatch);
matnames = matnames(:);

return
