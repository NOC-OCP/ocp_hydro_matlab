function [vars units] = mtgetvars(instream)
% function [vars units] = mtgetvars(instream)
%
% first draft BAK JC032
% 
% mstar techsas (mt) routine; requires mexec to be set up
%
% tstream is the part of the techsas filename that does not include the
% date; ie the first 16 chars have been removed; eg
% 20090318-235958-SBE-SBE45.TSG
% becomes SBE-SBE45.TSG
% 
% The var and units list is taken from the first matching file in a unix
% ls command.
%
% The techsas files are searched for in a directory MEXEC_G.uway_root defined in
% the mexec setup. At sea, this will typically be a data area exported from a
% ship's computer and cross-mounted on the mexec processing machine

m_common
tstream = mtresolve_stream(instream);

% some users like to alias ls to have options that return extra chars at the
% end of file names
[MEXEC.status result] = unix(['/bin/ls -1 ' MEXEC_G.uway_root '/*' tstream ' | head -1']);

if MEXEC.status == 1
    m = 'There appears to be a problem in mtvars';
    m2 = result;
    fprintf(MEXEC_A.Mfider,'%s\n',' ',m,m2,' ')
    return
end

% remove any c/r or nl characters from the result
snl = sprintf('\n'); knl = strfind(result,snl); result(knl) = [];
scr = sprintf('\r'); kcr = strfind(result,scr); result(kcr) = [];


ncf.name = result;

techsas_varnames = m_unpack_varnames(ncf);

for k = 1:length(techsas_varnames)
    techsas_units{k} = nc_attget(ncf.name,techsas_varnames{k},'units');
end

vars = techsas_varnames(:);
units = techsas_units(:);
return