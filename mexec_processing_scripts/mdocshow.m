function mdocshow(scriptname, scriptdocshort)
%function mdocshow(scriptname, scriptdocshort)
%
% print short documentation string for a script, if global variable MEXEC_G.ssd is set to true

m_common

if isfield(MEXEC_G, 'ssd') & MEXEC_G.ssd
   fprintf(MEXEC_A.Mfidterm,'Running %s: %s\n', scriptname, scriptdocshort);
end