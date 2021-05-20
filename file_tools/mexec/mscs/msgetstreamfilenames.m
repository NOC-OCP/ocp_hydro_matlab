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

files = dir(fullfile(MEXEC_G.uway_sed, [tstream '.ACO']));

if ~isempty(files)

    fnames = {d.name};
    filenames = fnames(cellfun('length',fnames)>4); %just in case there are other files

    strpart = @(tfilename) tfilename(1:end-4) %cut suffix
    allstreams = cellfun(strpart, filenames, 'UniformOutput', false); %stream name parts of file names

    kmatch = strmatch(tstream,allstreams);
    matnames = filenames(kmatch);
    matnames = matnames(:);

else

    m = 'There appears to be a problem in msvars';
    m2 = result;
    fprintf(MEXEC_A.Mfider,'%s\n',' ',m,m2,' ')
    return

end
