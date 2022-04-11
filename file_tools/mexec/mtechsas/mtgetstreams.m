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

files = dir(fullfile(MEXEC_G.uway_root,'*.*'));
fnames = {d.name};
fnames = fnames(cellfun('length',fnames)>16); %just in case there are other files

strpart = @(tfilename) tfilename(17:end) %cut off date and time characters
streams = cellfun(strpart, fnames, 'UniformOutput', false); %stream name parts of file names

tstreams = unique(streams(:)); %unique file/instrument streams
