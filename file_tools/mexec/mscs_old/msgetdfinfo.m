function [firstm lastm numdc] = msgetdfinfo(instream,tonly)
% function [firstm lastm numdc] = msgetdfinfo(instream,tonly)
%
% The argument should be a scs stream name
%
% get the time of the first and last data cycle in all scs files with stream name instream, and
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
% mstar scs (mt) routine; requires mexec to be set up
%
% The scs files are searched for in a directory uway_root defined in
% cruise options. At sea, this will typically be a data area exported from a
% ship's computer and cross-mounted on the mexec processing machine
%
% 8 Sep 2009: SCS version of original techsas script, for JR195
% The searched directory is uway_root, which for example can be
% /data/cruise/jcr/20090310/scs_copy/Compress
% The var names and units are taken from ascii file
% seatex-gga.TPL
% for example.

m_common
tstream = msresolve_stream(instream);
if nargin == 1; tonly = ' '; end

matnames = msgetstreamfilenames(tstream);

% bak for jr195 17 Sep 2009
% check if any files are found
if ~isempty(strfind(matnames{1},'No such file'))
    firstm = -1;
    lastm = -1;
    numdc = -1;
    return
end

nm = length(matnames);
t1 = nan+ones(nm,1);
t2 = t1;
num = t1;

firstm = 0; lastm = 0; numdc = 0;

if strncmp(tonly,'f',1) % faster option; don't count numdc in every file
    for kn = 1:nm
        [t1(kn) t2(kn) num(kn)] = msgetfiletimes(matnames{kn},tonly);
        if num(kn) ~= 0; firstm = t1(kn); break; end % quit when we find the first value of t1
    end

    for kn = nm:-1:1
        [t1(kn) t2(kn) num(kn)] = msgetfiletimes(matnames{kn},tonly);
        if num(kn) ~= 0; lastm = t2(kn); break; end % quit when we find the first value of t2 starting at the end
    end

    if firstm == 0; 
        numdc = nan;
    else
        numdc = -1;
    end

else
    for kn = 1:nm
        [t1(kn) t2(kn) num(kn)] = msgetfiletimes(matnames{kn});
    end

    firstm = min(t1(num>0));
    lastm = max(t2(num>0));
    numdc = nansum(num);
end

return

