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

files = dir(fullfile(MEXEC_G.uway_sed,'*.ACO'));
fnames = {d.name};
fnames = fnames(cellfun('length',fnames)>4); %just in case there are other files

strpart = @(sfilename) tfilename(1:end-4) %cut off suffix
streams = cellfun(strpart, fnames, 'UniformOutput', false); %stream name parts of file names

tstreams = unique(streams(:)); %unique file/instrument streams
