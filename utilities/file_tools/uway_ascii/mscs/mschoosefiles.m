function fnames = mschoosefiles(instream,dn1,dn2)
% function fnames = mschoosefiles(instream,dn1,dn2)
%
% identify files whos stream name matches instream and which have any
% data between matlab datenums dn1 and dn2
%
% The instream argument should be a scs stream name, or an equivalent
% mexec short name
%
% First identify all the scs files that match the tstream
% Then pull in the time sof first and last data cycle
% Then decide if the file is 'useful'
%
% first draft BAK JC032
% 
% mstar scs (mt) routine; requires mexec to be set up
%
% The scs files are searched for in a directory MEXEC_G.uway_root defined in
% the mexec setup. At sea, this will typically be a data area exported from a
% ship's computer and cross-mounted on the mexec processing machine
%
% 8 Sep 2009: SCS version of original techsas script, for JR195
% The searched directory is MEXEC_G.uway_root, which for example can be
% /data/cruise/jcr/20090310/scs_copy/Compress
% The var names and units are taken from ascii file
% seatex-gga.TPL
% for example.

m_common
tstream = msresolve_stream(instream);

matnames = msgetstreamfilenames(tstream,'.ACO');

numf = length(matnames);

keep = nan+ones(numf,1);
for kn = 1:numf
    fn = matnames{kn};
    [t1 t2 n] = msgetfiletimes(fn);
    if n == 0; continue; end % no data
    if t1 > dn2; continue; end % t1 not in range
    if t2 < dn1; continue; end % t2 not in range
    
    % if we get here file is useful
    keep(kn) = 1;
end

fnames = matnames(keep==1);
end
    