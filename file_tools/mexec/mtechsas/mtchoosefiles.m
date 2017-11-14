function fnames = mtchoosefiles(instream,dn1,dn2)
% function fnames = mtchoosefiles(instream,dn1,dn2)
%
% identify files whos stream name matches instream and which have any
% data between matlab datenums dn1 and dn2
%
% The instream argument should be a techsas stream name, or an equivalent
% mexec short name
%
% First identify all the techsas files that match the tstream
% Then pull in the time sof first and last data cycle
% Then decide if the file is 'useful'
%
% first draft BAK JC032
% 
% mstar techsas (mt) routine; requires mexec to be set up
%
% The techsas files are searched for in a directory MEXEC_G.uway_root defined in
% the mexec setup. At sea, this will typically be a data area exported from a
% ship's computer and cross-mounted on the mexec processing machine
%

m_common
tstream = mtresolve_stream(instream);

matnames = mtgetstreamfilenames(tstream);

numf = length(matnames);

keep = nan+ones(numf,1);
for kn = 1:numf
    fn = matnames{kn};
    [t1 t2 n] = mtgetfiletimes(fn);
    %if n == 0; continue; end % no data
    %if t1 > dn2; continue; end % t1 not in range
    %if t2 < dn1; continue; end % t2 not in range
    % if we get here file is useful
    if n>0 & t1<dn2 & t2>dn1
        keep(kn) = 1;
    end
end

fnames = matnames(keep==1);
end
