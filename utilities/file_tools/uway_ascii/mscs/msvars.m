function msvars(instream)
% function msvars(instream)
%
% Display the vars in a scs file on the screen
% If the vars list is required to be returned to a script, call mtgetvars directly.
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
% call to msgetvars and display results;
%
% 8 Sep 2009: SCS version of original techsas script, for JR195
% The searched directory is MEXEC_G.uway_root, which for example can be
% /data/cruise/jcr/20090310/scs_copy/Compress
% The var names and units are taken from ascii file
% seatex-gga.TPL
% for example.


m_common
tstream = msresolve_stream(instream);

[v u] = msgetvars(tstream);
nv = length(v);

% find max length of any var name
len = 0;
for kv = 1:nv
    len = max(len,length(v{kv}));
end

len = max(10,len+2);
    
format = ['%' sprintf('%d',len) 's  %s\n'];

fprintf(MEXEC_A.Mfidterm,'%s\n',' ',tstream,' ')
for kv = 1:length(v)
    fprintf(MEXEC_A.Mfidterm,format,v{kv},u{kv})
end
fprintf(MEXEC_A.Mfidterm,'%s\n',' ')

return