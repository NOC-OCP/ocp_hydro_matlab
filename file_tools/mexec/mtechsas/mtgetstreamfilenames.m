function matnames = mtgetstreamfilenames(instream)
% function matnames = mtgetstreamfilenames(instream)
%
% first draft BAK JC032
%
% mstar techsas (mt) routine; requires mexec to be set up
%
% The techsas files are searched for in a directory MEXEC_G.uway_root defined in
% the mexec setup. At sea, this will typically be a data area exported from a
% ship's computer and cross-mounted on the mexec processing machine
%
% This function searches for the set of techsas files whose name matches
% the stream name provided in the argument. The search takes place in the
% MEXEC_G.uway_root directory
%
% Each tstream is the part of the techsas filename that does not include the
% date; ie the first 16 chars have been removed; eg
% 20090318-235958-SBE-SBE45.TSG
% becomes SBE-SBE45.TSG
%
m_common
tstream = mtresolve_stream(instream);


files = dir(fullfile(MEXEC_G.uway_root, ['*' tstream]));

if ~isempty(files)

    fnames = {d.name};
    filenames = fnames(cellfun('length',fnames)>16); %just in case there are other files

    strpart = @(tfilename) tfilename(17:end) %cut off date and time characters
    allstreams = cellfun(strpart, filenames, 'UniformOutput', false); %stream name parts of file names

    kmatch = strmatch(tstream,allstreams);
    matnames = filenames(kmatch);
    matnames = matnames(:);

else

    m = 'There appears to be a problem in mtvars';
    m2 = result;
    fprintf(MEXEC_A.Mfider,'%s\n',' ',m,m2,' ')
    return

end

