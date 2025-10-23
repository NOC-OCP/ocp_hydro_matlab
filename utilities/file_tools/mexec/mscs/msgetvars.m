function [vars, units] = msgetvars(instream)
% function [vars, units] = msgetvars(instream)
%
% first draft BAK JC032
% 
% mstar scs (mt) routine; requires mexec to be set up
%
% tstream is the part of the scs filename that does not include the
% date; ie the first 16 chars have been removed; eg
% 20090318-235958-SBE-SBE45.TSG
% becomes SBE-SBE45.TSG
% 
% The var and units list is taken from the first matching file in a unix
% ls command.
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
[~,result] = msgetstreamfilenames(tstream,'.TPL');
kd = strfind(result,newline);
result = result(1:kd(1)-1);
result = replace(result,newline,'');

scs_name = result;
% allcell = mtextdload(scs_name); % load the comma-delimited var names and units into a cell array
allcell = mtextdload(scs_name,',',0); % bak en697
numvarsfound = length(allcell);
vars = cell(numvarsfound,1); % set up empty cells
units = vars;

for kloop = 1:numvarsfound
    thisrow = allcell{kloop};
    vars{kloop} = thisrow{2};
    units{kloop} = thisrow{3};
end

return