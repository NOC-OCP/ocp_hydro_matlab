function [firstm lastm numdc] = mgetdfinfo(instream,tonly)
% function [firstm lastm numdc] = mgetdfinfo(instream,tonly)
%
% The argument should be a techsas stream name
%
% get the time of the first and last data cycle in all techsas files with stream name instream, and
% return the envelope times as matlab datenums; return a third argument which is the
% total number of data cycles in all the matching files.
%
% If the tonly flag is set to 'fast' or 'f', then only the earliest and 
% latest files containing data are inspected;
% In the fast option, numdc is returned as -1 if data are found, 
% or nan if no data are found.
%
% first draft BAK JC032
% 
% mstar techsas (mt) routine; requires mexec to be set up
%
% The techsas files are searched for in a directory uway_root defined in
% cruise options. At sea, this will typically be a data area exported from a
% ship's computer and cross-mounted on the mexec processing machine
%

m_common
tstream = mtresolve_stream(instream);
if nargin == 1; tonly = 0; end

matnames = mtgetstreamfilenames(tstream);

nm = length(matnames);
t1 = nan+ones(nm,1);
t2 = t1;
num = t1;

firstm = 0; lastm = 0; numdc = 0;

if strncmp(tonly,'f',1) % faster option; don't count numdc in every file
    for kn = 1:nm
        [t1(kn), t2(kn), num(kn)] = mtgetfiletimes(matnames{kn});
        if num(kn) > 0; firstm = t1(kn); break; end % quit when we find the first value of t1
    end

    for kn = nm:-1:1
        [t1(kn), t2(kn), num(kn)] = mtgetfiletimes(matnames{kn});
        if num(kn) > 0; lastm = t2(kn); break; end % quit when we find the first value of t2 starting at the end
    end

    if firstm == 0
        numdc = nan;
    else
        numdc = -1;
    end

else
    for kn = 1:nm
        [t1(kn), t2(kn), num(kn)] = mtgetfiletimes(matnames{kn});
    end

    firstm = min(t1(num>0));
    lastm = max(t2(num>0));
    numdc = m_nansum(num);
end

return

